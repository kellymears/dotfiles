#!/usr/bin/env bash
# Make the focused window the biggest one on its workspace.
#
# dwindle is pure BSP -- every window is a peer and there is no master slot to
# promote into (that is the master layout's idea, and switching layouts per
# workspace is a bigger commitment). What there IS is `swapwindow`, which trades
# two windows' positions in the tree. Swap the focused window with the largest
# one and the focused window inherits the big slot.
#
# The catch: swapwindow only takes a DIRECTION, not a target window (verified --
# passing `window =` is rejected). So this works out which way the big window
# lies and steps toward it, then checks whether it actually landed. In a 2-3
# window layout that is one hop; in a deeper tree the nearest neighbour in that
# direction may not be the big one, so it iterates -- and gives up rather than
# thrashing if a step stops making the focused window bigger.
#
# Floating windows are ignored: they overlap everything and are not part of the
# tiling tree, so "largest" would be meaningless with them in the running.
#
# Bound to SUPER + SHIFT + Return.

set -uo pipefail

MAX_HOPS=4

log() { printf '[promote] %s\n' "$*" >&2; }

# Prints: <active_area> <direction-or-empty> <n_tiled>
survey() {
    hyprctl clients -j | python3 -c '
import json, subprocess, sys

active = json.loads(subprocess.run(["hyprctl", "activewindow", "-j"],
                                   capture_output=True, text=True).stdout or "{}")
addr = active.get("address")
if not addr:
    print("0  0"); sys.exit()

ws = active["workspace"]["id"]
wins = [c for c in json.load(sys.stdin)
        if c["workspace"]["id"] == ws and not c["floating"] and not c["hidden"]]

def area(c): return c["size"][0] * c["size"][1]
def centre(c): return (c["at"][0] + c["size"][0] / 2, c["at"][1] + c["size"][1] / 2)

me = next((c for c in wins if c["address"] == addr), None)
if me is None or len(wins) < 2:
    print(f"{area(me) if me else 0}  {len(wins)}"); sys.exit()

big = max(wins, key=area)
if big["address"] == addr:
    print(f"{area(me)}  {len(wins)}"); sys.exit()

(mx, my), (bx, by) = centre(me), centre(big)
dx, dy = bx - mx, by - my
# Step along the dominant axis; ties go horizontal, which matches how dwindle
# splits a fresh workspace.
d = ("r" if dx > 0 else "l") if abs(dx) >= abs(dy) else ("d" if dy > 0 else "u")
print(f"{area(me)} {d} {len(wins)}")
'
}

read -r area dir count < <(survey)

if [[ ${count:-0} -lt 2 ]]; then
    log "nothing to swap with (${count:-0} tiled window(s))"
    exit 0
fi

if [[ -z ${dir:-} || $dir =~ ^[0-9]+$ ]]; then
    log "already the largest window"
    exit 0
fi

for _ in $(seq $MAX_HOPS); do
    hyprctl dispatch "hl.dsp.window.swap({ direction = \"$dir\" })" >/dev/null
    sleep 0.15
    read -r new_area new_dir new_count < <(survey)
    if [[ -z ${new_dir:-} || $new_dir =~ ^[0-9]+$ ]]; then
        log "promoted (area $area -> $new_area)"
        exit 0
    fi
    # Stop on NO MOVEMENT, not on "area got no bigger". A hop can trade places
    # with an equal-sized peer and still be progress -- it changes which
    # neighbour lies between you and the big window. Bailing on the first
    # non-improving hop stalls one swap short in any layout deeper than two.
    if [[ $new_area == "$area" && $new_dir == "$dir" ]]; then
        log "swap changed nothing (still $new_area, still $new_dir) -- stopping"
        exit 0
    fi
    area=$new_area; dir=$new_dir
done

log "gave up after $MAX_HOPS hops"
