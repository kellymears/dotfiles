#!/usr/bin/env bash
# Follow the display: put audio on the living-room TV while its head is up,
# and put it back where it was when the head goes away.
#
#   tv-audio.sh            do the switch (hooked to monitor.added /
#                          monitor.removed / hyprland.start in monitors.lua)
#   tv-audio.sh --status   print the display-to-PCM map and the current sink
#
# WHY THE TV IS NOT SIMPLY PICKABLE
#
# The 4090's HDA card exposes its four digital outputs (3x DP + 1x HDMI) as
# PROFILES, not as ports you can pick between. Exactly one can be active at a
# time, so the TV's sink does not merely sit unselected in the picker -- it
# does not EXIST unless the card is on that output's profile.
#
# WirePlumber cannot work this out for itself: the NVIDIA driver reports all
# four ports as `available: yes` whether or not anything is plugged in (see
# `pactl list cards`), so its "switch to the available port" policy has nothing
# to go on. Hyprland knows which head is really up, so it drives the profile.
#
# WHICH PROFILE IS THE TV: ASK, DO NOT ASSUME
#
# There is no fixed answer, and this is the trap that cost a round of "sound is
# coming out of the wrong monitor". The obvious mapping -- codec pin order --
# is WRONG: the TV is pin 0x7, the 4th and last pin, which suggests the 4th
# profile (`hdmi-stereo-extra3`), and that profile was in fact playing out of a
# DisplayPort panel. The driver assigns PCM slots to pins dynamically, so pin
# order is not device order, and the answer can differ across boots and
# hotplugs.
#
# What IS authoritative is the ELD each PCM device reads back from whatever is
# plugged into it -- monitor name and connection type, straight from the sink
# display. So this script reads all four and picks the one that says HDMI (the
# card has exactly one physical HDMI port; the panels are DisplayPort). By hand:
#
#   amixer -c NVidia controls | grep ELD          # numid per PCM device
#   amixer -c NVidia cget numid=<n>               # raw ELD bytes
#
# or run this script with --status, which decodes them.
#
# Profile names then follow PulseAudio's convention: PCM devices in ascending
# order map to hdmi-stereo, -extra1, -extra2, -extra3.
#
# NOTE ON NAMING IN AUDIO PICKERS: the sink is called something like "AD102
# High Definition Audio Controller Digital Stereo (HDMI 2)" -- the chip, not
# the TV, and the trailing number is the profile slot, NOT which monitor. It
# cannot be renamed usefully by a static WirePlumber rule, because which slot
# the TV occupies is exactly the thing that moves. --status is the way to know.
#
# TO TURN THIS OFF: drop the hl.on lines in monitors.lua. Nothing else calls it.

set -uo pipefail

TV_HEAD=HDMI-A-1
CARD_PCI=0000:01:00.1
CARD="alsa_card.pci-${CARD_PCI//:/_}"
SINK_PREFIX="alsa_output.pci-${CARD_PCI//:/_}"

# Preferred way to recognise the TV among the ELDs, checked before falling back
# to "whichever output reports an HDMI connection".
TV_NAME_MATCH="LG TV"

# THE CHAIN, most wanted first. This replaced an older "remember whatever was
# in use before the TV took over and restore that" scheme. Restoring the
# previous sink sounds harmless and is not: the remembered value was whatever
# happened to be default at the time, so one stray pick poisons it until
# something overwrites it. It had in fact latched onto the DualSense Edge's
# headphone jack, which meant every TV-off restored audio to a game controller.
# An explicit ranking cannot drift like that.
#
#   1. Bluetooth headphones  -- if they are connected they are in your ears
#   2. the living-room TV    -- when its head is actually up
#   3. the S/PDIF desk DAC   -- the everyday desk output
#   4. the center panel      -- genuine last resort, see --identify
#
# Still true, and still the reason tiers 3 and 4 are checked rather than
# assumed: WirePlumber refuses any sink whose port jack-detect calls
# unavailable -- the USB DAC's Speaker and Headphones ports both report
# `not available` with nothing plugged in, so `set-default-sink` on them
# silently loses to WirePlumber's own pick. Every switch is verified below and
# logged honestly when it does not take.

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/hypr"

# Tier 1 is matched by prefix, not by MAC: any Bluetooth sink at all means
# headphones are on your head. Tier 3 is a fixed name because it is one
# specific box.
BT_SINK_PREFIX="bluez_output."
SPDIF_SINK="alsa_output.usb-Generic_USB_Audio-00.HiFi__SPDIF__sink"

# Tier 4 has to be pinned by codec port id, written by --identify. The three
# desk panels report an IDENTICAL monitor_name and an identical product_id for
# two of them, so neither field picks one out; port id is the only thing that
# differs. If this file is absent tier 4 just takes the first DisplayPort
# output it finds, which is a coin flip between two panels and is why tier 4
# sits below the DAC rather than above it.
CENTER_PORT_FILE="$STATE_DIR/tv-audio-center-port"

# Used when --identify has not been run. 0x800 is an INFERENCE, not a reading:
# the three desk panels sit at port ids 0x200 / 0x800 / 0x2000, and the one at
# 0x200 is independently known to be DP-1 because it is the odd model out (a
# different product_id, matching the one monitor whose serial prefix differs in
# `hyprctl monitors`). Ascending port id then puts DP-2 in the middle. Confirm
# it by ear with --identify; if it is wrong, that writes the right value and
# this constant stops being consulted.
CENTER_PORT_DEFAULT="0x800"

log() { printf '[tv-audio] %s\n' "$*" >&2; }

command -v pactl >/dev/null 2>&1 || { log "no pactl, nothing to do"; exit 0; }
pactl info >/dev/null 2>&1 || { log "no pipewire/pulse server, nothing to do"; exit 0; }

# ALSA card index for the GPU, found by PCI address rather than by the "NVidia"
# id, which is only stable as long as there is one such card.
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

# One line per output: <profile>\t<pcm>\t<connection>\t<monitor name>\t<port id>
#
# port id is carried because the desk panels are the SAME MODEL: identical
# monitor_name AND identical product_id, so neither distinguishes them. The
# codec port id does, and it is what --identify records.
eld_map() {
    python3 - "$1" <<'PY'
import re, subprocess, sys

card = sys.argv[1]


def amixer(*args):
    return subprocess.run(["amixer", "-c", card, *args],
                          capture_output=True, text=True).stdout


# ELD controls exist for every output, not just the active profile's, which is
# what makes this readable without touching the card.
elds = re.findall(r"numid=(\d+),iface=PCM,name='ELD',device=(\d+)", amixer("controls"))
elds.sort(key=lambda t: int(t[1]))

for rank, (numid, dev) in enumerate(elds):
    m = re.search(r": values=(.*)", amixer("cget", "numid=" + numid))
    # A PCM with nothing plugged into it reports `values=` with an EMPTY list.
    # The old one-liner ran int("", 16) over that and raised ValueError, which
    # killed the whole map -- and because the caller reads eld_map's output to
    # find the TV, a crash here made it conclude "no output reports an HDMI
    # display" and silently skip the switch. Tolerate empty/garbage per row.
    toks = [x for x in m.group(1).split(",") if x.strip()] if m else []
    try:
        raw = bytes(int(x, 16) for x in toks)
    except ValueError:
        raw = b""
    # ELD baseline block: byte 4 low 5 bits = monitor name length, byte 5
    # bits 2-3 = connection type, name starts at byte 20.
    if len(raw) < 20 or not raw[4] & 0x1f:
        conn, name = "none", "-"
    else:
        conn = {0: "HDMI", 1: "DisplayPort"}.get((raw[5] >> 2) & 3, "other")
        name = raw[20:20 + (raw[4] & 0x1f)].decode("ascii", "replace").strip() or "-"
    port = int.from_bytes(raw[8:16], "little") if len(raw) >= 16 else 0
    profile = "output:hdmi-stereo" + ("" if rank == 0 else f"-extra{rank}")
    print(f"{profile}\t{dev}\t{conn}\t{name}\t0x{port:x}")
PY
}

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
    pactl set-default-sink "$1" >/dev/null 2>&1 || { log "could not set default sink $1"; return 1; }
    move_streams "$1"
    # Verify rather than assume -- see the jack-detect note above. WirePlumber
    # can quietly overrule set-default-sink and the only symptom is sound from
    # the wrong box.
    local actual
    actual=$(pactl get-default-sink 2>/dev/null)
    [[ $actual == "$1" ]] || { log "asked for $1 but WirePlumber kept $actual"; return 1; }
    return 0
}

# Any Bluetooth sink at all. First match wins; there is only ever one headset.
bt_sink() { pactl list short sinks | cut -f2 | grep -m1 "^${BT_SINK_PREFIX}"; }

# Parking the GPU card deletes its HDMI sinks. Do this BEFORE choosing a
# non-GPU target, never after: dropping the profile while that sink is still
# the configured default makes WirePlumber re-pick by priority the instant it
# vanishes, and that pick lands after ours. Park, then decide, and the decision
# sticks. It also keeps a dead entry out of every audio picker, where an app
# can helpfully select it and then play to nothing.
park_card() { pactl set-card-profile "$CARD" off >/dev/null 2>&1; sleep 0.3; }

# The center panel's row out of $map: recorded port id first, then the inferred
# default, then any DisplayPort output at all.
center_line() {
    local center line=""
    center=$(cat "$CENTER_PORT_FILE" 2>/dev/null)
    [[ -n $center ]] && line=$(awk -F'\t' -v p="$center" '$3 == "DisplayPort" && $5 == p {print; exit}' <<<"$map")
    [[ -z $line ]] && line=$(awk -F'\t' -v p="$CENTER_PORT_DEFAULT" '$3 == "DisplayPort" && $5 == p {print; exit}' <<<"$map")
    [[ -z $line ]] && line=$(awk -F'\t' '$3 == "DisplayPort" {print; exit}' <<<"$map")
    printf '%s' "$line"
}

# The resting state for the GPU card, and deliberately NOT `off`.
#
# Parking the card entirely is what made the center panel unpickable: only one
# of the card's four outputs exists as a sink at a time, so with the card off
# the panel is not merely unselected, it is absent from every picker. Resting
# on the center panel keeps exactly one GPU output present -- the one you might
# actually want to choose by hand -- while still tearing down the TV's sink,
# which is the part that mattered when leaving the TV.
rest_card() {
    local line profile
    line=$(center_line)
    if [[ -n $line ]]; then
        profile=${line%%$'\t'*}
        pactl set-card-profile "$CARD" "$profile" >/dev/null 2>&1
    else
        pactl set-card-profile "$CARD" off >/dev/null 2>&1
    fi
    sleep 0.3
}

# Bring up a GPU output and wait for its sink; the sink appears asynchronously
# after the profile change.
activate_profile() {
    local profile="$1" sink="$SINK_PREFIX.${1#output:}"
    pactl set-card-profile "$CARD" "$profile" >/dev/null 2>&1
    for _ in {1..15}; do sink_exists "$sink" && return 0; sleep 0.2; done
    return 1
}

card=$(alsa_card_index) || { log "no ALSA card at PCI $CARD_PCI"; exit 0; }

if [[ ${1:-} == --status ]]; then
    printf 'ALSA card %s (PCI %s)\n\n%-28s %-4s %-12s %-18s %s\n' "$card" "$CARD_PCI" PROFILE PCM CONNECTION DISPLAY PORT_ID
    eld_map "$card" | awk -F'\t' '{printf "%-28s %-4s %-12s %-18s %s\n", $1, $2, $3, $4, $5}'
    printf '\nactive profile: %s\n' "$(pactl list cards | sed -n "/$CARD/,/^Card #/p" | sed -n 's/.*Active Profile: //p')"
    printf 'default sink:   %s\n' "$(pactl get-default-sink)"
    exit 0
fi

exec 9>"/tmp/tv-audio.lock"
flock -w 5 9 || { log "another instance holds the lock, skipping"; exit 0; }

mkdir -p "$STATE_DIR"

map=$(eld_map "$card")

# --------------------------------------------------------------- --identify
# Which DisplayPort output is the CENTER panel cannot be read off the hardware.
# Two of the three desk panels are the same model: same monitor_name, same
# product_id. Only the codec port id differs, and nothing in it says "center".
# So ask the ears -- play a tone through each DisplayPort output and record the
# port id of whichever one you confirm.
if [[ ${1:-} == --identify ]]; then
    command -v paplay >/dev/null 2>&1 || { log "--identify needs paplay"; exit 1; }
    tone=$(mktemp /tmp/tv-audio-tone-XXXXXX.wav)
    python3 - "$tone" <<'PY'
import math, struct, sys, wave
w = wave.open(sys.argv[1], "wb"); w.setnchannels(2); w.setsampwidth(2); w.setframerate(48000)
n = 36000
w.writeframes(b"".join(
    struct.pack("<hh", v, v) for v in
    (int(12000 * math.sin(2 * math.pi * 660 * t / 48000)
         * min(1.0, t / 2400.0, (n - t) / 2400.0)) for t in range(n))))
w.close()
PY
    printf 'Playing a tone through each DisplayPort output.\n'
    printf 'Plug headphones into the panel you are testing if it has no speakers.\n'
    saved=""
    while IFS=$'\t' read -r profile pcm conn name port; do
        [[ $conn == DisplayPort ]] || continue
        printf '\n  %s  (pcm %s, port %s)\n' "$profile" "$pcm" "$port"
        if ! activate_profile "$profile"; then
            printf '    could not bring that output up, skipping\n'
            continue
        fi
        paplay --device="$SINK_PREFIX.${profile#output:}" "$tone" 2>/dev/null
        read -r -p '    was that the CENTER screen? [y/N] ' ans </dev/tty
        [[ ${ans,,} == y* ]] && { saved="$port"; break; }
    done <<<"$map"
    rm -f "$tone"
    rest_card
    if [[ -n $saved ]]; then
        printf '%s\n' "$saved" > "$CENTER_PORT_FILE"
        log "center panel recorded: port $saved"
    else
        log "nothing confirmed -- $CENTER_PORT_FILE left alone"
    fi
    exit 0
fi

# ------------------------------------------------------------------- tier 1
# Bluetooth headphones. If they are connected they are on your head, and that
# beats every box in the room.
bt=$(bt_sink)
if [[ -n $bt ]]; then
    rest_card
    switch_to "$bt" && { log "audio -> $bt (bluetooth)"; exit 0; }
fi

# ------------------------------------------------------------------- tier 2
# The living-room TV, but only while its head is really up. Name match first --
# if a DisplayPort-to-HDMI adapter ever shows up on a panel, connection type
# alone stops being a unique answer.
if hyprctl monitors | grep -q "^Monitor $TV_HEAD ("; then
    line=$(awk -F'\t' -v n="$TV_NAME_MATCH" 'index($4, n) {print; exit}' <<<"$map")
    [[ -z $line ]] && line=$(awk -F'\t' '$3 == "HDMI" {print; exit}' <<<"$map")
    if [[ -n $line ]]; then
        profile=${line%%$'\t'*}
        display=$(cut -f4 <<<"$line")
        if activate_profile "$profile" && switch_to "$SINK_PREFIX.${profile#output:}"; then
            log "audio -> $display ($profile)"
            exit 0
        fi
        log "could not settle audio on $profile -- falling through"
    else
        log "$TV_HEAD is up but no output reports an HDMI display -- falling through"
        log "$(printf '%s' "$map" | tr '\t' ' ')"
    fi
fi

# ------------------------------------------------------------------- tier 3
# The desk DAC. Settle the GPU card first (see the note by park_card).
rest_card
if sink_exists "$SPDIF_SINK"; then
    switch_to "$SPDIF_SINK" && { log "audio -> S/PDIF (desk)"; exit 0; }
fi

# ------------------------------------------------------------------- tier 4
# Last resort: the center panel's own output. Only reached if the DAC is gone.
line=$(center_line)
[[ -s $CENTER_PORT_FILE ]] || log "center panel not confirmed (run --identify) -- using $CENTER_PORT_DEFAULT"
if [[ -n $line ]]; then
    profile=${line%%$'\t'*}
    display=$(cut -f4 <<<"$line")
    if activate_profile "$profile" && switch_to "$SINK_PREFIX.${profile#output:}"; then
        log "audio -> $display ($profile, last resort)"
        exit 0
    fi
fi

# Nothing in the chain was reachable. Follow WirePlumber rather than leaving
# streams pointed at a sink that does not exist.
actual=$(pactl get-default-sink 2>/dev/null)
move_streams "$actual"
log "nothing in the chain was reachable -- left on ${actual:-unknown}"
