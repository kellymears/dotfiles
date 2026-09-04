#!/usr/bin/env bash
# Force the three DP panels through a fresh drop/restore cycle to recover
# from a bad post-wake modeset (wrong resolution or refresh rate), without
# touching the TV head. Bound to SUPER+0, 0.
#
# This is the panel half of tv-kick.sh's cycle() with the TV branch removed
# -- see tv-kick.sh's header for why the drop-then-restore dance is needed
# at all (NVIDIA can't modeset a running panel directly into a corrected
# mode; dropping to a low mode first and restoring unwedges it).

set -uo pipefail

PANELS=(DP-1 DP-2 DP-3)
POSITIONS=(0x0 2560x0 5120x0)

PANEL_HI="3840x2160@144.05"
PANEL_LO="3840x2160@60"
PANEL_SCALE="1.5"
PANEL_BITDEPTH=10
PANEL_SDRBRIGHTNESS=3.0

log() { printf '[panel-kick] %s\n' "$*" >&2; }

set_panel() {
    hyprctl eval "hl.monitor({output=\"$1\", mode=\"$2\", position=\"$3\", scale=\"$PANEL_SCALE\", bitdepth=$PANEL_BITDEPTH, sdrbrightness=$PANEL_SDRBRIGHTNESS})" >/dev/null
}

set_panels() {
    local mode=$1 i
    for i in "${!PANELS[@]}"; do
        set_panel "${PANELS[$i]}" "$mode" "${POSITIONS[$i]}"
    done
}

exec 9>"/tmp/panel-kick.lock"
if ! flock -n 9; then
    log "another instance holds the lock, skipping"
    exit 0
fi

log "dropping panels to $PANEL_LO"
set_panels "$PANEL_LO"
sleep 2
log "restoring panels to $PANEL_HI"
set_panels "$PANEL_HI"
log "done"
