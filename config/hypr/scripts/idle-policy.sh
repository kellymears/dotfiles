#!/usr/bin/env bash
# Caffeine (noctalia's idle inhibitor) follows the living-room TV head.
#
# WHY
#
# The idle timeouts in ~/.config/noctalia/config.toml exist for the three OLED
# panels -- five minutes of static bar and terminals is how you get burn-in.
# But noctalia's screen_off action is all-or-nothing: there is no per-monitor
# timeout, and `noctalia msg dpms-off` blanks every head. So a controller-only
# evening on the couch -- no keyboard, no mouse -- reads as idle and kills the
# game's display along with the desktop.
#
# The TV being lit is a good enough proxy for "someone is sitting in front of
# something that does not generate input", and it is already an explicit,
# deliberate act (SUPER + SHIFT + T -> tv-toggle.sh). So: TV up, idle is
# inhibited entirely; TV down, the normal timeouts apply.
#
# The cost is that the OLEDs also stay lit while the TV is on. Accepted: the
# TV is not on for long stretches unattended, and burn-in wants hours of the
# same static image, not an evening.
#
# Idempotent and safe to run at any time. Wired to monitor.added /
# monitor.removed / hyprland.start / config.reloaded in config/monitors.lua.

set -uo pipefail

TV=HDMI-A-1

log() { printf '[idle-policy] %s\n' "$*" >&2; }

# Same serialization rationale as gaming-monitor.sh: monitor.added fires once
# per head at boot, so several copies race. They agree on the answer, but two
# overlapping caffeine calls are not worth finding out about.
exec 9>"/tmp/idle-policy.lock"
flock -w 5 9 || { log "another instance holds the lock, skipping"; exit 0; }

# Hooks fire while the monitor set is still settling; let it finish before
# asking what exists.
sleep "${IDLE_POLICY_DELAY:-0.5}"

# `hyprctl monitors` lists only ENABLED heads, which is the question being
# asked -- not whether the cable is in. tv-toggle.sh's "off" direction tears
# the head down, and that is exactly what should re-arm the timeouts. (It
# cannot see the TV's own screen-off state; nothing local can. See the header
# of tv-toggle.sh.)
if hyprctl monitors | grep -q "^Monitor $TV ("; then
    noctalia msg caffeine-enable >/dev/null && log "TV up -- idle inhibited"
else
    noctalia msg caffeine-disable >/dev/null && log "TV down -- idle timeouts armed"
fi
