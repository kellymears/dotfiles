#!/usr/bin/env bash
# CleanShot-style still capture: grab -> annotate in satty -> copy + save.
#
# WHY: the stock Print bind fired a screenshot straight to disk with no chance
# to crop, arrow, or blur first. This routes every capture through satty so the
# annotation bar comes up the way CleanShot's does -- draw on it, hit Enter to
# copy, or Ctrl+S to save the annotated version over the original.
#
# The raw grab is always written to $SHOT_DIR first (via a temp file, so a
# cancelled selection never leaves an empty PNG behind). satty then opens that
# temp for markup; Enter copies the annotated image to the clipboard, the Save
# button overwrites the on-disk file with your annotations. Either way you end
# up with the shot on disk AND, if you want it, on the clipboard.
#
#   screenshot.sh region     drag a box            (slurp)
#   screenshot.sh window     the focused window    (no click)
#   screenshot.sh screen     the focused monitor   (no click)
#
# Env: SHOT_DIR overrides the save folder.
set -euo pipefail

mode="${1:-region}"
dir="${SHOT_DIR:-$HOME/Pictures/Screenshots}"
mkdir -p "$dir"
out="$dir/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"

case "$mode" in
    region|area)   hs=(-m region) ;;
    window)        hs=(-m window -m active) ;;   # focused window, no picker
    screen|output) hs=(-m output -m active) ;;   # active monitor, no picker
    *) echo "usage: $0 <region|window|screen>" >&2; exit 2 ;;
esac

tmp="$(mktemp --suffix=.png)"
trap 'rm -f "$tmp"' EXIT

# --raw dumps PNG to stdout with no save/notification of its own; -z freezes
# the screen so a moving window doesn't smear the selection. hyprshot's exit
# code is unreliable in --raw mode (it can return 1 after a perfectly good
# capture), so gauge success by whether any image data actually landed: a
# cancelled region selection yields an empty file, a real grab does not.
hyprshot "${hs[@]}" --raw -s -z > "$tmp" 2>/dev/null || true
if [ ! -s "$tmp" ]; then
    # Selection cancelled or grab failed -- say so instead of vanishing.
    # (slurp aborts the whole capture if any KEY is pressed mid-selection;
    # only mouse drag + release completes it.)
    notify-send -a Screenshot -t 3000 "Nothing captured" "Selection cancelled or grab failed ($mode)"
    exit 0
fi
cp -- "$tmp" "$out"

satty --filename "$tmp" \
      --output-filename "$out" \
      --copy-command wl-copy \
      --actions-on-enter save-to-clipboard \
      --early-exit
