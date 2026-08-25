#!/usr/bin/env bash
# Toggle the browser workspace (7, first slot on DP-3) between its home
# display and the middle panel (DP-2), where the webcam is. For Google Meet:
# press once to bring Chrome under the camera, again to send it home.
#
# A workspace is a container that lives on one monitor; workspace.move
# re-homes the container, so every window in it (Chrome, Zen, ...) comes
# along. Nothing is re-parented or re-tiled by hand. See gaming-monitor.sh
# for the same mechanism driven by monitor hotplug instead of a keybind.
#
# The `workspace = "7"` window rule is unaffected: new browser windows keep
# joining workspace 7 wherever it currently sits.

set -uo pipefail

WS=7
HOME_MON=DP-3
MEET_MON=DP-2

current=$(hyprctl workspaces | sed -n "s/^workspace ID $WS ($WS) on monitor \(.*\):$/\1/p")

if [[ -z $current ]]; then
    # Persistent workspaces always exist, so this is a rules problem, not a runtime one.
    notify-send "browser-monitor" "workspace $WS not found" 2>/dev/null
    exit 1
fi

if [[ $current == "$MEET_MON" ]]; then
    target=$HOME_MON
else
    target=$MEET_MON
fi

hyprctl dispatch "hl.dsp.workspace.move({ workspace = \"$WS\", monitor = \"$target\" })" >/dev/null
hyprctl dispatch "hl.dsp.focus({ workspace = $WS })" >/dev/null
