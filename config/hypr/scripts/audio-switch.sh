#!/usr/bin/env bash
# Manually route system audio to one of the three outputs Kelly actually
# uses. Bound to SUPER+9, then 1 (Edifier), 2 (AirPods Pro), or 3 (LG TV) --
# see binds.lua's "audio_switch" submap.
#
# This replaces the old automatic BT-priority/TV-consent/desk-fallback chain
# (tv-audio.sh + audio-chain-watch.service, retired 2026-09-04): with only
# three devices in play, always picking the one asked for is simpler than
# ranking them, and "why did audio move" is always answered by "I pressed the
# key." See git history if the automatic behavior is ever wanted back.

set -uo pipefail

EDIFIER_SINK="alsa_output.usb-Generic_USB_Audio-00.HiFi__Speaker__sink"

# AirPods Pro. Matched by prefix because the trailing profile id (a2dp-sink
# vs. headset-head-unit) is not worth hardcoding -- there is only ever one
# Bluetooth output paired.
BT_MAC="04:9D:05:76:11:65"
BT_SINK_PREFIX="bluez_output.${BT_MAC//:/_}"

# The living-room TV. See the note below on why its profile has to be found,
# not assumed.
TV_HEAD=HDMI-A-1
CARD_PCI=0000:01:00.1
CARD="alsa_card.pci-${CARD_PCI//:/_}"
SINK_PREFIX="alsa_output.pci-${CARD_PCI//:/_}"
TV_NAME_MATCH="LG TV"

log() { printf '[audio-switch] %s\n' "$*" >&2; }
notify() {
    command -v notify-send >/dev/null 2>&1 && notify-send -a Hyprland -t 3000 "Audio" -- "$1"
    log "$1"
}

command -v pactl >/dev/null 2>&1 || { log "no pactl, nothing to do"; exit 1; }

sink_exists() { [[ -n ${1:-} ]] && pactl list short sinks | cut -f2 | grep -qx "$1"; }

# Drag whatever is already playing along. Without this a running game keeps
# streaming to the sink it opened on and only the *next* app follows.
move_streams() {
    local id
    while read -r id _; do
        [[ -n $id ]] && pactl move-sink-input "$id" "$1" >/dev/null 2>&1
    done < <(pactl list short sink-inputs)
}

switch_to() {
    pactl set-default-sink "$1" >/dev/null 2>&1 || return 1
    move_streams "$1"
    [[ $(pactl get-default-sink 2>/dev/null) == "$1" ]]
}

# Drop the GPU card's HDMI profile when it isn't the target. Its four digital
# outputs are mutually exclusive PulseAudio profiles, so leaving one active
# leaves a dead "AD102 ... Digital Stereo" entry sitting in every picker.
park_gpu_card() { pactl set-card-profile "$CARD" off >/dev/null 2>&1; sleep 0.3; }

alsa_card_index() {
    local d
    for d in /sys/class/sound/card*; do
        [[ -e $d/device ]] || continue
        if [[ "$(basename "$(readlink -f "$d/device")")" == "$CARD_PCI" ]]; then
            basename "$d" | tr -dc '0-9'
            return 0
        fi
    done
    return 1
}

# WHY THE TV'S PROFILE HAS TO BE FOUND, NOT ASSUMED: the GPU exposes its four
# digital outputs (3x DP + 1x HDMI) as profiles, and the driver assigns PCM
# slots to codec pins dynamically -- which profile is the TV moves across
# boots and hotplugs. What IS authoritative is the ELD each PCM device reads
# back from whatever is plugged into it, so this reads all four and picks the
# one that says HDMI (the card has exactly one physical HDMI port; the desk
# panels are DisplayPort). See the retired tv-audio.sh in git history for the
# full byte-level ELD writeup and the `--identify` tooling this dropped.
eld_map() {
    python3 - "$1" <<'PY'
import re, subprocess, sys

card = sys.argv[1]


def amixer(*args):
    return subprocess.run(["amixer", "-c", card, *args],
                          capture_output=True, text=True).stdout


elds = re.findall(r"numid=(\d+),iface=PCM,name='ELD',device=(\d+)", amixer("controls"))
elds.sort(key=lambda t: int(t[1]))

for rank, (numid, dev) in enumerate(elds):
    m = re.search(r": values=(.*)", amixer("cget", "numid=" + numid))
    toks = [x for x in m.group(1).split(",") if x.strip()] if m else []
    try:
        raw = bytes(int(x, 16) for x in toks)
    except ValueError:
        raw = b""
    if len(raw) < 20 or not raw[4] & 0x1f:
        conn, name = "none", "-"
    else:
        conn = {0: "HDMI", 1: "DisplayPort"}.get((raw[5] >> 2) & 3, "other")
        name = raw[20:20 + (raw[4] & 0x1f)].decode("ascii", "replace").strip() or "-"
    profile = "output:hdmi-stereo" + ("" if rank == 0 else f"-extra{rank}")
    print(f"{profile}\t{dev}\t{conn}\t{name}")
PY
}

activate_tv_profile() {
    local card_idx map line profile sink
    card_idx=$(alsa_card_index) || { log "no ALSA card at PCI $CARD_PCI"; return 1; }
    map=$(eld_map "$card_idx")
    line=$(awk -F'\t' -v n="$TV_NAME_MATCH" 'index($4, n) {print; exit}' <<<"$map")
    [[ -z $line ]] && line=$(awk -F'\t' '$3 == "HDMI" {print; exit}' <<<"$map")
    [[ -z $line ]] && return 1
    profile=${line%%$'\t'*}
    sink="$SINK_PREFIX.${profile#output:}"
    pactl set-card-profile "$CARD" "$profile" >/dev/null 2>&1
    for _ in {1..15}; do
        sink_exists "$sink" && { printf '%s' "$sink"; return 0; }
        sleep 0.2
    done
    return 1
}

case "${1:?usage: audio-switch.sh <1|2|3>}" in
    1)
        park_gpu_card
        if switch_to "$EDIFIER_SINK"; then
            notify "-> Edifier"
        else
            notify "Edifier not reachable"
            exit 1
        fi
        ;;
    2)
        park_gpu_card
        sink=$(pactl list short sinks | cut -f2 | grep -m1 "^${BT_SINK_PREFIX}")
        if [[ -z $sink ]]; then
            notify "connecting AirPods Pro..."
            bluetoothctl connect "$BT_MAC" >/dev/null 2>&1
            for _ in {1..15}; do
                sink=$(pactl list short sinks | cut -f2 | grep -m1 "^${BT_SINK_PREFIX}")
                [[ -n $sink ]] && break
                sleep 0.5
            done
        fi
        if [[ -n $sink ]] && switch_to "$sink"; then
            notify "-> AirPods Pro"
        else
            notify "AirPods Pro not reachable"
            exit 1
        fi
        ;;
    3)
        if ! hyprctl monitors | grep -q "^Monitor $TV_HEAD ("; then
            notify "TV is off (SUPER+0, 4 first)"
            exit 1
        fi
        sink=$(activate_tv_profile)
        if [[ -n $sink ]] && switch_to "$sink"; then
            notify "-> LG TV"
        else
            notify "LG TV not reachable"
            exit 1
        fi
        ;;
    *)
        notify "invalid target: $1"
        exit 1
        ;;
esac
