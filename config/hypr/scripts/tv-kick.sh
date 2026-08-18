#!/usr/bin/env bash
# Bring up the living-room TV on HDMI-A-1, and (in --boot mode) force every
# panel through a fresh modeset after a reboot.
#
# WHY THIS EXISTS
#
# The NVIDIA driver cannot enable a 4th display head in a single atomic commit
# while the three DP panels are already running 3840x2160@144 at 10bpc. Every
# mode on HDMI-A-1 is rejected -- the whole ladder, all the way down to
# 640x480 -- with "Invalid argument" on ATOMIC_TEST_ONLY, and the connector
# sits at `enabled=disabled` in /sys/class/drm while still reporting a valid
# EDID and a full mode list. It looks exactly like a dead cable.
#
# It is NOT a bandwidth wall, which is the trap here. The identical
# 3x4K144@10bpc + TV@4K60 configuration runs fine -- but only if the HDMI head
# was brought up first. The driver just cannot make that *transition* in one
# step. So: drop the panels low, light the TV, put the panels back.
#
# Measured on 610.57.04 / Hyprland 0.56.2 (see monitors.lua for the matching
# note). The 240Hz failure documented in monitors.lua looks the same in the
# logs but is a real bandwidth limit -- do not confuse the two, this trick
# will not help there.
#
# MODES
#
#   tv-kick.sh          hotplug mode (monitor.added hook). No-op unless the
#                       TV is connected but dark. The original behavior.
#
#   tv-kick.sh --boot   boot mode (hyprland.start hook). Runs the full
#                       drop / light-TV / restore cycle UNCONDITIONALLY, then
#                       verifies every head against its intended mode and
#                       re-runs the cycle (twice, max) on any mismatch.
#
# Boot mode exists because of the 2026-08-17 reboot: the driver fumbled the
# initial bring-up (three "nvidia-modeset: ERROR ... surface registration"
# lines in dmesg) and left DP-3 walked down the mode ladder at 1080p and DP-2
# BLACK while both DRM and Hyprland reported it healthy at 144.05 -- DP link
# training failed silently at the panel. The black state is invisible to
# software, so boot mode does not try to detect it: it forces fresh link
# training on every panel, every boot. Costs a few seconds of flicker.
#
# The verify step CAN see the mode-ladder case (wrong reported mode) and the
# dark-TV case (/sys/class/drm), so those get retried. A panel that is black
# while reporting the right mode cannot be caught -- the unconditional cycle
# is the mitigation, not the verification.
#
# Safe to run any time in either mode.

set -uo pipefail

BOOT=0
[[ "${1:-}" == "--boot" ]] && BOOT=1

PANELS=(DP-1 DP-2 DP-3)
POSITIONS=(0x0 2560x0 5120x0)

# Exact refresh strings matter. `hyprctl eval` silently no-ops on a mode that
# is not an exact match -- "3840x2160@95" returns "ok" and changes nothing,
# because the panel's mode is 95.03. Only the unknown-*field* case errors
# loudly. Take these from `hyprctl monitors all` availableModes verbatim.
PANEL_HI="3840x2160@144.05"
PANEL_LO="3840x2160@60"
PANEL_SCALE="1.5"
PANEL_BITDEPTH=10
PANEL_SDRBRIGHTNESS=3.0

TV=HDMI-A-1
TV_MODE="3840x2160@60"
TV_POSITION="7680x0"
# scale 2 -> 1920x1080 logical. Right for couch distance; 1.5 would give a
# 2560x1440 workspace that is unreadable from across the room.
TV_SCALE="2"

log() { printf '[tv-kick] %s\n' "$*" >&2; }

connected() { [[ "$(cat "/sys/class/drm/card1-$TV/status" 2>/dev/null)" == connected ]]; }
lit()       { [[ "$(cat "/sys/class/drm/card1-$TV/enabled" 2>/dev/null)" == enabled ]]; }

set_panel() {
    hyprctl eval "hl.monitor({output=\"$1\", mode=\"$2\", position=\"$3\", scale=\"$PANEL_SCALE\", bitdepth=$PANEL_BITDEPTH, sdrbrightness=$PANEL_SDRBRIGHTNESS})" >/dev/null
}

set_panels() {
    local mode=$1 i
    for i in "${!PANELS[@]}"; do
        set_panel "${PANELS[$i]}" "$mode" "${POSITIONS[$i]}"
    done
}

light_tv() {
    # disabled=false is explicit: monitor specs merge, so if anything (a
    # previous run, a manual `disabled=true`) left that flag set, a spec that
    # only names a mode inherits it and the commit succeeds into a still-dark
    # output.
    hyprctl eval "hl.monitor({output=\"$TV\", mode=\"$TV_MODE\", position=\"$TV_POSITION\", scale=\"$TV_SCALE\", disabled=false})" >/dev/null
}

# True when Hyprland reports the panel at PANEL_HI. Catches the
# walked-down-the-ladder case only -- a black panel reports healthy here.
panel_ok() {
    hyprctl monitors | grep -A1 "^Monitor $1 " | grep -q "3840x2160@144.05"
}

verify() {
    local ok=0 p
    for p in "${PANELS[@]}"; do
        panel_ok "$p" || { log "verify: $p is not at $PANEL_HI"; ok=1; }
    done
    if connected && ! lit; then
        log "verify: $TV connected but dark"
        ok=1
    fi
    return $ok
}

# One full drop / light-TV / restore pass. Order matters: the TV head must be
# enabled while the panels are LOW -- see the header. Restoring the panels
# with the TV already lit is the transition that is known to work; enabling
# the TV with panels at 144 is the one that is known to fail.
cycle() {
    set_panels "$PANEL_LO"
    sleep 2
    if connected && ! lit; then
        light_tv
        sleep 3
        if lit; then
            log "$TV enabled at $TV_MODE"
        else
            log "$TV still dark after enable attempt"
        fi
    fi
    set_panels "$PANEL_HI"
    sleep 2
    log "panels restored to $PANEL_HI"
}

# Crash safety net: if we die mid-cycle, put any panel still reporting a
# non-HI mode back up. After a clean cycle every panel reports HI and this
# recommits nothing -- deliberately, because an extra recommit with all four
# heads up has been observed to knock the TV head dark (2026-08-17).
rescue_panels() {
    local i
    for i in "${!PANELS[@]}"; do
        panel_ok "${PANELS[$i]}" || set_panel "${PANELS[$i]}" "$PANEL_HI" "${POSITIONS[$i]}"
    done
}
trap rescue_panels EXIT

# Serialize runs: hyprland.start and per-monitor monitor.added events can
# fire together during bring-up, and two interleaved cycles would fight.
exec 9>"/tmp/tv-kick.lock"
if ! flock -n 9; then
    log "another instance holds the lock, skipping"
    trap - EXIT
    exit 0
fi

# Give Hyprland a moment to finish its own (possibly failed) bring-up before
# issuing commits on top of it. Boot needs longer than hotplug: the
# 2026-08-17 failure happened ~20s after boot while things were still
# settling.
sleep "${TV_KICK_DELAY:-$( ((BOOT)) && echo 10 || echo 2 )}"

if ((BOOT)); then
    log "boot mode: unconditional drop/restore for fresh link training"
    cycle
    for attempt in 1 2; do
        if verify; then
            log "verify: all heads at intended modes"
            exit 0
        fi
        log "verify failed -- rerunning cycle (retry $attempt of 2)"
        cycle
    done
    if verify; then
        log "verify: all heads at intended modes"
    else
        log "verify STILL failing after 2 retries -- needs manual attention (hyprctl monitors all / dmesg)"
    fi
    exit 0
fi

# Hotplug mode -- the original behavior.
if ! connected; then
    log "$TV not connected, nothing to do"
    exit 0
fi

if lit; then
    log "$TV already enabled, nothing to do"
    exit 0
fi

log "$TV connected but dark -- running drop/enable/restore"
cycle
