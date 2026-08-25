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
freeze_pid=""
cleanup() {
    if [[ -n "$freeze_pid" ]]; then
        kill "$freeze_pid" 2>/dev/null || true
    fi
    rm -f "$tmp"
}
trap cleanup EXIT

# Region capture uses slurp and grim directly; hyprshot's background watcher can
# race the interactive selection. Other modes keep hyprshot's frozen raw grab.
# Gauge success by image data because hyprshot's raw-mode exit code is unreliable.
if [[ "$mode" == region || "$mode" == area ]]; then
    # Freeze before slurp takes focus. Attached shell panels may close while
    # selecting, but grim still samples this frozen compositor frame, so the
    # panel remains present in the resulting screenshot.
    hyprpicker -r -z >/dev/null 2>&1 &
    freeze_pid=$!
    sleep 0.2
    geometry="$(slurp -d)" || exit 0
    [[ -n "$geometry" ]] && grim -g "$geometry" "$tmp" 2>/dev/null || true
    kill "$freeze_pid" 2>/dev/null || true
    wait "$freeze_pid" 2>/dev/null || true
    freeze_pid=""
else
    hyprshot "${hs[@]}" --raw -s -z > "$tmp" 2>/dev/null || true
fi
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
