#!/usr/bin/env bash
# Toggle the living-room TV on HDMI-A-1. Bound to SUPER + 0, 4 (see
# binds.lua's "monitor_toggle" submap; monitor-toggle.sh delegates index 4
# straight here).
#
# WHY A KEYBIND AND NOT AUTOMATIC
#
# There is no local signal for "TV powered off". Measured across two power
# cycles, sampling once a second: HPD stays connected, EDID still reads 256B,
# all 36 modes still enumerate, the TV answers ping, and both webOS ports
# (3000/3001) stay open. Nothing moves. "Off" on this set is a screen state,
# not a power state -- webOS keeps running (Quick Start+), so from the GPU's
# side the display never left, and windows never migrate off it.
#
# CEC would answer this, but the NVIDIA proprietary driver registers no CEC
# adapter -- there is no /dev/cec* on this box -- so that needs a USB-CEC
# dongle. The webOS SSAP getPowerState call can distinguish Active from
# Screen Off, but wants TLS on 3001, a pairing handshake, and a polling
# daemon, all hostage to the TV's DHCP lease.
#
# So: press the key. Off tears the head down and pulls windows back to the
# main panels; on runs the drop/enable/restore dance in tv-kick.sh.

set -uo pipefail

TV=HDMI-A-1
HERE="$(dirname "$(readlink -f "$0")")"

notify() {
    command -v notify-send >/dev/null 2>&1 && notify-send -a Hyprland -t 3000 "TV" "$1"
    printf '[tv-toggle] %s\n' "$1" >&2
}

if [[ "$(cat "/sys/class/drm/card1-$TV/status" 2>/dev/null)" != connected ]]; then
    notify "not connected"
    exit 0
fi

if [[ "$(cat "/sys/class/drm/card1-$TV/enabled" 2>/dev/null)" == enabled ]]; then
    # Tearing down the head is what migrates the windows -- that is the whole
    # point of the "off" direction. Hyprland moves them to the next monitor.
    hyprctl eval "hl.monitor({output=\"$TV\", disabled=true})" >/dev/null
    sleep 1
    notify "off -- windows moved back"
    "$HERE/tv-audio.sh"
else
    # tv-kick does the real work and is a no-op if the TV is already lit, so
    # a double-press cannot wedge anything.
    TV_KICK_DELAY=0 "$HERE/tv-kick.sh"
    if [[ "$(cat "/sys/class/drm/card1-$TV/enabled" 2>/dev/null)" == enabled ]]; then
        notify "on -- 3840x2160@60"
        "$HERE/tv-audio.sh" --prefer-tv
    else
        # A failed enable (seen 2026-08-23: FRL link training flake) leaves
        # Hyprland believing the head is up while /sys says dark, and that
        # stale state makes the next light_tv commit merge into a no-op. Flush
        # it with an explicit disabled=true, then kick once more.
        notify "enable failed -- flushing stale state and retrying"
        hyprctl eval "hl.monitor({output=\"$TV\", disabled=true})" >/dev/null
        sleep 2
        TV_KICK_DELAY=0 "$HERE/tv-kick.sh"
        if [[ "$(cat "/sys/class/drm/card1-$TV/enabled" 2>/dev/null)" == enabled ]]; then
            notify "on -- 3840x2160@60 (after retry)"
            "$HERE/tv-audio.sh" --prefer-tv
        else
            notify "failed to enable after retry, see hyprland log"
        fi
    fi
fi
