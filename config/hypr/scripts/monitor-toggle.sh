#!/usr/bin/env bash
# Enable/disable one display by index (1-4), independent of the others.
# Bound to SUPER+O then 1/2/3/4 (see binds.lua's "monitor_kick" submap).
#
# WHY: a KVM-switched panel (Steam Deck on display 3, a MacBook on display 1)
# needs the GPU's own output torn down while another source drives the
# monitor, without losing whatever workspace was on it -- disabling a Hyprland
# output migrates its windows to another display, same as tv-toggle.sh's TV
# branch. Re-enabling brings it back as a target monitor; workspaces do not
# auto-return (that's Hyprland's normal behavior, not something this fixes).
#
# 1-3 (the DP panels) always run together at boot -- the "3x4K144@10bpc runs
# cleanly" case documented in monitors.lua -- so a direct disable/enable is
# safe; this does not need tv-kick.sh's drop-other-heads dance, which exists
# only for the bandwidth trap of adding a 4TH head. It still runs
# panel-kick.sh afterward per Kelly's ask: kick on every change, so a flaky
# modeset never leaves a panel at the wrong resolution/refresh unnoticed.
#
# 4 (the TV) is not handled here -- it delegates straight to tv-toggle.sh,
# which already does the correct enable dance, caffeine, and audio-profile
# switch. Re-implementing that here would just be a second copy to keep in
# sync.

set -uo pipefail

HERE="$(dirname "$(readlink -f "$0")")"
IDX="${1:?usage: monitor-toggle.sh <1-4>}"

notify() {
    command -v notify-send >/dev/null 2>&1 && notify-send -a Hyprland -t 3000 "Display $IDX" "$1"
    printf '[monitor-toggle] %s\n' "$1" >&2
}

if [[ "$IDX" == "4" ]]; then
    exec "$HERE/tv-toggle.sh"
fi

case "$IDX" in
    1) OUT=DP-1; POS=0x0    ;;
    2) OUT=DP-2; POS=2560x0 ;;
    3) OUT=DP-3; POS=5120x0 ;;
    *) notify "invalid index: $IDX"; exit 1 ;;
esac

# Matches monitors.lua's panel spec. Kept in sync by hand -- see that file if
# these ever drift (e.g. the 240Hz two-monitor case in its header comment).
MODE="3840x2160@144.05"
SCALE="1.5"
BITDEPTH=10
SDRBRIGHTNESS=3.0

enabled() { [[ "$(cat "/sys/class/drm/card1-$OUT/enabled" 2>/dev/null)" == enabled ]]; }

if enabled; then
    hyprctl eval "hl.monitor({output=\"$OUT\", disabled=true})" >/dev/null
    notify "off -- windows moved to another display"
else
    # disabled=false is explicit -- see tv-kick.sh's light_tv for why a spec
    # that only names a mode would otherwise merge into a still-disabled spec.
    hyprctl eval "hl.monitor({output=\"$OUT\", mode=\"$MODE\", position=\"$POS\", scale=\"$SCALE\", bitdepth=$BITDEPTH, sdrbrightness=$SDRBRIGHTNESS, disabled=false})" >/dev/null
    notify "on -- $MODE"
fi

"$HERE/panel-kick.sh"
