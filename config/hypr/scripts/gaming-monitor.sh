#!/usr/bin/env bash
# Pin the `gaming` workspace to the best screen that is actually up.
#
# Preference: the living-room TV (HDMI-A-1) when it is lit, otherwise the
# middle panel (DP-2). Never DP-1 -- that is the working monitor and a game
# landing there buries whatever is on it.
#
# WHY A SCRIPT AND NOT JUST A WORKSPACE RULE
#
# `hl.workspace_rule({ workspace = "name:gaming", monitor = ... })` in
# workspaces.lua is evaluated once, at config parse time, and the TV comes and
# goes (see tv-toggle.sh / tv-kick.sh). So the static rule holds only the
# fallback, and this script re-issues it -- plus moves the workspace if it
# already exists -- every time the monitor set changes. It is idempotent and
# safe to run at any time.
#
# The rule is re-issued rather than added: Hyprland keys workspace rules by
# their selector, so a second `name:gaming` rule replaces the first instead of
# stacking (verified with `hyprctl workspacerules`).
#
# NOTE: `hyprctl keyword` does not work with the Lua config -- everything here
# goes through `hyprctl eval` / `hyprctl dispatch` with Lua argument syntax.
# The old flat form (`dispatch moveworkspacetomonitor name:gaming HDMI-A-1`)
# is a parse error, not a silent no-op.

set -uo pipefail

TV=HDMI-A-1
FALLBACK=DP-2
WS=gaming

log() { printf '[gaming-monitor] %s\n' "$*" >&2; }

# Serialize: monitor.added fires once per head during boot, so several copies
# can be in flight at once. They would all reach the same answer, but two
# overlapping workspace moves are not worth finding out about.
exec 9>"/tmp/gaming-monitor.lock"
flock -w 5 9 || { log "another instance holds the lock, skipping"; exit 0; }

# Hooks fire while the monitor set is still settling -- on a removal Hyprland
# is in the middle of evacuating workspaces off the dying head. Let it finish
# before asking what exists.
sleep "${GAMING_MONITOR_DELAY:-0.5}"

# `hyprctl monitors` lists only ENABLED heads (disabled ones need `monitors
# all`), which is exactly the question being asked: can a window go there.
# This is deliberately not the /sys/class/drm check that tv-kick.sh uses --
# that one is about the DRM connector, this one is about what Hyprland will
# accept as a placement target.
if hyprctl monitors | grep -q "^Monitor $TV ("; then
    target=$TV
else
    target=$FALLBACK
fi

hyprctl eval "hl.workspace_rule({ workspace = \"name:$WS\", monitor = \"$target\", default = true })" >/dev/null

# Move an existing gaming workspace too. The rule alone only decides where the
# workspace is *created*, so without this, turning the TV on mid-session leaves
# a running game stranded on DP-2.
current=$(hyprctl workspaces | sed -n "s/^workspace ID -\?[0-9]* ($WS) on monitor \(.*\):$/\1/p")

if [[ -z $current ]]; then
    log "rule -> $target ($WS does not exist yet)"
elif [[ $current == "$target" ]]; then
    log "rule -> $target ($WS already there)"
else
    hyprctl dispatch "hl.dsp.workspace.move({ workspace = \"name:$WS\", monitor = \"$target\" })" >/dev/null
    log "rule -> $target, moved $WS off $current"
fi
