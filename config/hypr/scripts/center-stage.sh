#!/usr/bin/env bash
# Put the focused window center stage on the webcam monitor, floating over
# whatever is already there. Press again to send it back exactly where it was.
#
# WHY: on a call you are on camera, and the webcam sits above the center panel.
# Reading a window on a side panel means being filmed in profile. This drags
# any window -- Slack, a browser, a doc being talked through -- into the
# eyeline for the duration of the call, then puts it back.
#
# Deliberately generic. An earlier version of this was a Slack-only workspace;
# a single bind that works on the focused window covers Slack and everything
# else without a pile of per-app workspaces to maintain.
#
# The window is PINNED while it is center stage, so switching workspaces on the
# center panel does not lose it -- that is what makes it an overlay rather than
# just a window that moved. Drop the pin/unpin lines if that is not wanted.
#
#   center-stage.sh          floating overlay at $SIZE of the panel, pinned
#   center-stage.sh --full   same trip, but fullscreen on that panel
#
# State is remembered per window address in $STATE, so the return trip restores
# the original workspace and tiled/floating state rather than guessing.

set -uo pipefail

MODE=window
[[ ${1:-} == --full ]] && MODE=full

CAM_MON=DP-2                       # the panel the webcam sits above
SIZE=${CENTER_STAGE_SIZE:-0.7}     # fraction of the usable monitor area

STATE="${XDG_RUNTIME_DIR:-/tmp}/center-stage.state"

log() { printf '[center-stage] %s\n' "$*" >&2; }
notify() {
    # `--` because the messages can start with "->", which notify-send would
    # otherwise try to parse as an option.
    command -v notify-send >/dev/null 2>&1 && notify-send -a Hyprland -t 2000 -- "Center stage" "$1"
    log "$1"
}

# Hyprland's pin dispatcher is a toggle, and moving a pinned window between
# workspaces can clear the pin by itself -- so check before toggling, or the
# return trip pins a window that was already unpinned.
unpin_if_pinned() {
    local a=$1 pinned
    pinned=$(hyprctl clients -j | python3 -c "
import json,sys
a = sys.argv[1]
print(next((str(c['pinned']).lower() for c in json.load(sys.stdin) if c['address'] == a), 'false'))
" "$a")
    [[ $pinned == true ]] && hyprctl dispatch "hl.dsp.window.pin({ window = \"address:$a\" })" >/dev/null
    return 0
}

unfullscreen_if_fullscreen() {
    local a=$1 fs
    fs=$(hyprctl clients -j | python3 -c "
import json,sys
a = sys.argv[1]
print(next((c['fullscreen'] for c in json.load(sys.stdin) if c['address'] == a), 0))
" "$a")
    [[ $fs != 0 ]] && hyprctl dispatch "hl.dsp.window.fullscreen({ window = \"address:$a\" })" >/dev/null
    return 0
}

addr=$(hyprctl activewindow -j | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("address",""))')
[[ -z $addr || $addr == null ]] && { notify "no focused window"; exit 0; }

# ---- return trip -----------------------------------------------------------
if [[ -f $STATE ]]; then
    read -r saved_addr saved_ws saved_float saved_mode < "$STATE"
    if [[ $saved_addr == "$addr" ]]; then
        # Clear fullscreen first: a fullscreen window ignores the move back and
        # would land on the old workspace still fullscreen. Checked rather than
        # toggled blindly, since SUPER+F may have already cleared it by hand.
        unfullscreen_if_fullscreen "$addr"
        unpin_if_pinned "$addr"
        hyprctl dispatch "hl.dsp.window.move({ workspace = \"$saved_ws\", window = \"address:$addr\" })" >/dev/null
        [[ $saved_float == tiled ]] &&
            hyprctl dispatch "hl.dsp.window.float({ action = \"off\", window = \"address:$addr\" })" >/dev/null
        rm -f "$STATE"
        notify "back to $saved_ws"
        exit 0
    fi
    # A different window is being sent up: release the previous one first so
    # there is never more than one pinned overlay left behind.
    unfullscreen_if_fullscreen "$saved_addr"
    unpin_if_pinned "$saved_addr"
    hyprctl dispatch "hl.dsp.window.move({ workspace = \"$saved_ws\", window = \"address:$saved_addr\" })" >/dev/null 2>&1
    [[ $saved_float == tiled ]] &&
        hyprctl dispatch "hl.dsp.window.float({ action = \"off\", window = \"address:$saved_addr\" })" >/dev/null 2>&1
fi

# ---- outbound --------------------------------------------------------------
read -r ws floatstate < <(hyprctl activewindow -j | python3 -c '
import json, sys
d = json.load(sys.stdin)
w = d["workspace"]
# Named workspaces need the name: selector; numbered ones are just the number.
print(("name:" + w["name"]) if w["id"] < 0 else w["name"],
      "floating" if d["floating"] else "tiled")
')

read -r W H X Y < <(hyprctl monitors -j | CAM_MON="$CAM_MON" SIZE="$SIZE" python3 -c '
import json, os, sys
mon = next((m for m in json.load(sys.stdin) if m["name"] == os.environ["CAM_MON"]), None)
if mon is None:
    sys.exit(1)
f = float(os.environ["SIZE"])
s = mon["scale"]
# Logical pixels: Hyprland positions windows in the scaled coordinate space,
# not the panel native one. reserved is [left, top, right, bottom] -- the bar.
lw, lh = mon["width"] / s, mon["height"] / s
l, t, r, b = mon["reserved"]
uw, uh = lw - l - r, lh - t - b
w, h = round(uw * f), round(uh * f)
print(w, h, round(mon["x"] + l + (uw - w) / 2), round(mon["y"] + t + (uh - h) / 2))
') || { notify "monitor $CAM_MON not found"; exit 0; }

printf '%s %s %s %s\n' "$addr" "$ws" "$floatstate" "$MODE" > "$STATE"

# Order matters: hand the window to the target monitor's workspace BEFORE
# placing it. Positioning a floating window over another monitor's area does
# not reassign it -- it keeps its old workspace and snaps back on the next
# layout pass.
hyprctl dispatch "hl.dsp.window.float({ action = \"on\", window = \"address:$addr\" })" >/dev/null
hyprctl dispatch "hl.dsp.window.move({ monitor = \"$CAM_MON\", window = \"address:$addr\" })" >/dev/null
if [[ $MODE == full ]]; then
    # No pin here: pinning is about surviving a workspace switch, which a
    # fullscreen window does not do anyway, and the two states fight.
    hyprctl dispatch "hl.dsp.window.fullscreen({ window = \"address:$addr\" })" >/dev/null
    notify "-> $CAM_MON (fullscreen)"
else
    hyprctl dispatch "hl.dsp.window.resize({ x = $W, y = $H, exact = true, window = \"address:$addr\" })" >/dev/null
    hyprctl dispatch "hl.dsp.window.move({ x = $X, y = $Y, exact = true, window = \"address:$addr\" })" >/dev/null
    hyprctl dispatch "hl.dsp.window.pin({ window = \"address:$addr\" })" >/dev/null
    notify "-> $CAM_MON (${W}x${H})"
fi
