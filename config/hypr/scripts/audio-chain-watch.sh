#!/usr/bin/env bash
# Re-run the audio chain whenever the set of sinks changes.
#
# WHY THIS EXISTS
#
# tv-audio.sh is hooked to Hyprland monitor.added / monitor.removed, which
# covers tier 2 -- the TV head coming and going. It does NOT cover tier 1.
# Bluetooth headphones connecting or disconnecting is not a monitor event, so
# without this the chain never re-evaluates when you take the AirPods out. The
# symptom is specific and annoying: case your AirPods mid-game and the sound
# arrives at the desk instead of the TV you are sitting in front of, because
# WirePlumber fell back down its own list rather than down yours.
#
# Only sink add/remove is interesting here. Volume moves and default-sink
# changes fire constantly and mean nothing to the chain.
#
# COOLDOWN, AND WHY IT IS NOT OPTIONAL
#
# tv-audio.sh itself adds and removes sinks -- parking the GPU card deletes
# one, activating a profile creates one -- so its own work echoes straight back
# as more sink events. Without a cooldown this chases its own tail forever.
# tv-audio.sh's flock is the second line of defence: a run that starts while
# another holds the lock exits rather than queueing.
#
# TO TURN THIS OFF:  systemctl --user disable --now audio-chain-watch

set -uo pipefail
SCRIPT="$(dirname "$(readlink -f "$0")")/tv-audio.sh"
COOLDOWN=4

# Start well in the past: with last=0 the very first event, which arrives
# within seconds of boot, would be swallowed by its own cooldown.
last=-3600

pactl subscribe 2>/dev/null | while read -r line; do
    case "$line" in
        *"'new' on sink"*|*"'remove' on sink"*) ;;
        *) continue ;;
    esac
    (( SECONDS - last < COOLDOWN )) && continue

    # Let WirePlumber take its reflex first, THEN assert the chain over it.
    # Losing a race here is not theoretical: removing the Bluetooth sink makes
    # WirePlumber grab the GPU card and light a profile by priority -- measured,
    # it landed on the TV's output with the TV switched off, i.e. silence. We
    # want the last word, so we deliberately do not try to be first.
    sleep 1

    # stderr is left attached on purpose so tv-audio.sh's own log lines land in
    # the journal. Debugging this without them is guesswork.
    "$SCRIPT" >/dev/null
    last=$SECONDS
done
