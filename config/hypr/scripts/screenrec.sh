#!/usr/bin/env bash
# CleanShot-style screen recording, NVENC-accelerated via gpu-screen-recorder.
#
# WHY: one bind should both START and STOP, like CleanShot's record button --
# so this is a toggle. If a recording is already running, ANY invocation (any
# target) stops and finalizes it; otherwise it starts a new one against the
# chosen target. The 4090 does the H.264 encoding, so recording a 4K panel
# costs the CPU almost nothing.
#
#   screenrec.sh region      record a dragged box     (slurp)
#   screenrec.sh window      record the focused window
#   screenrec.sh screen      record the focused monitor
#   screenrec.sh (again)     stop + save (whatever the target)
#
# Desktop audio is captured by default; set SHOT_MIC=1 to add the mic too.
# Env: REC_DIR overrides the save folder.
set -euo pipefail

dir="${REC_DIR:-$HOME/Videos/Recordings}"
mkdir -p "$dir"
match="^gpu-screen-recorder"

# --- already recording? then this press means STOP ---
if pgrep -f "$match" >/dev/null 2>&1; then
    pkill -INT -f "$match"                      # SIGINT = stop + finalize
    for _ in $(seq 1 20); do
        pgrep -f "$match" >/dev/null 2>&1 || break
        sleep 0.25
    done
    last="$(ls -t "$dir"/recording_*.mp4 2>/dev/null | head -1 || true)"
    if [ -n "$last" ]; then
        printf '%s' "$last" | wl-copy               # path on the clipboard
        notify-send -a "Screen Recording" "Recording saved" "$(basename "$last")"
    else
        notify-send -a "Screen Recording" "Recording stopped" "$dir"
    fi
    exit 0
fi

# --- not recording: START against the chosen target ---
mode="${1:-screen}"
out="$dir/recording_$(date +%Y-%m-%d_%H-%M-%S).mp4"

audio="default_output"
[ "${SHOT_MIC:-0}" = "1" ] && audio="default_output|default_input"

region=()
case "$mode" in
    screen|output)
        win="$(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .name')"
        ;;
    window)
        # gpu-screen-recorder's true window capture is X11-only; on Wayland the
        # working equivalent is to record the focused window's rectangle as a
        # region. Fixed at start -- if the window is later moved or resized the
        # frame stays put, which is the tradeoff for not needing a portal dialog.
        geom="$(hyprctl activewindow -j | jq -r 'if .address then "\(.size[0])x\(.size[1])+\(.at[0])+\(.at[1])" else empty end')"
        if [ -z "$geom" ]; then
            notify-send -a "Screen Recording" "No focused window" "Nothing to record"
            exit 0
        fi
        win="region"
        region=(-region "$geom")
        ;;
    region|area)
        geom="$(slurp -f '%wx%h+%x+%y')" || exit 0   # cancelled selection
        win="region"
        region=(-region "$geom")
        ;;
    *) echo "usage: $0 <region|window|screen>" >&2; exit 2 ;;
esac

notify-send -a "Screen Recording" "Recording started ($mode)" "Press the record bind again to stop"

# exec so the running process is literally "gpu-screen-recorder ..." -- that is
# what the pgrep/pkill above matches when stopping.
exec gpu-screen-recorder \
    -w "$win" "${region[@]}" \
    -f 60 -k h264 -ac aac -a "$audio" \
    -q very_high -cursor yes \
    -o "$out"
