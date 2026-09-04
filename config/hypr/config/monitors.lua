-- Monitor wiki https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Outputs are named in variables.lua (MONITOR1..3). Find them with `hyprctl monitors`.
--
-- POSITIONS ARE IN *LOGICAL* PIXELS, NOT PHYSICAL ONES.
-- At scale 1.5 each 3840px panel is 2560 logical px wide, so the three
-- monitors must start at 0 / 2560 / 5120. If you change `scale`, you MUST
-- recompute these or you leave dead gaps between displays and the mouse
-- cannot cross from one to the next. (At scale 2 they would be 1920 wide,
-- starting 0 / 1920 / 3840.)
--
-- 1.5 IS A DELIBERATE TRADEOFF, AND IT COSTS A LITTLE SHARPNESS.
--
-- It is a fractional scale, so any window whose logical size x 1.5 is not
-- a whole number cannot land on physical pixels -- a window 1385 logical
-- px tall wants 2077.5 -- and the compositor resamples the whole surface
-- onto that half pixel. Everything picks up a slight softness. Apps that
-- ship only 1x/2x asset tiers (Electron ones especially -- Discord
-- avatars, emoji, icons) also get an upscaled 1x rather than a real 2x.
--
-- Scale 2 fixes both: 1:1 pixel mapping, no resampling, true 2x assets.
-- It was tried and reverted -- a 1920x1080 logical workspace per panel is
-- simply too big to work in, and clawing the density back via per-app zoom
-- means configuring every app one at a time. 2560x1440 with a touch of
-- softness wins. Revisit if per-app zoom ever stops being a chore.
--
-- What does NOT help, so don't bother re-testing it: chasing this with
-- --force-device-scale-factor on an Electron/Chromium app. On Wayland it
-- multiplies with the compositor scale instead of replacing it (measured:
-- 1.5 -> DPR 2.25, 2 -> DPR 3.0), so it is a zoom knob, not a sharpness
-- knob. Those apps already render at the full 1.5 via fractional-scale-v1
-- as long as they are native Wayland -- see ELECTRON_OZONE_PLATFORM_HINT
-- in environment.lua, which is the setting that actually matters.
--
-- IMPORTANT: these are pinned to 144Hz deliberately.
--
-- All three panels advertise 3840x2160@240, but the RTX 4090 is DisplayPort
-- 1.4a and 4K@240 requires DSC. There is not enough display bandwidth for
-- three of them at once: asking for 240 makes the atomic modeset fail with
-- "Invalid argument", and the third monitor silently stays black (detected,
-- EDID readable, but `enabled=disabled` in /sys/class/drm).
--
-- 3x 4K@144 commits cleanly. If you ever drop to two monitors you can raise
-- one of these back to @240.

-- HDR: ON DEMAND, NOT DESKTOP-WIDE. There is deliberately no `cm` here.
--
-- The panels are real HDR10 (EDID advertises SMPTE ST2084 + BT2020, ~604
-- nits peak), the RTX 4090 exposes VK_EXT_hdr_metadata /
-- VK_EXT_swapchain_colorspace / HDR10_ST2084, and Hyprland 0.56 has
-- render:cm_enabled. Forcing cm = "hdr" here DOES work, but it puts the
-- whole desktop in HDR and every SDR app then gets tone-mapped, which
-- looked washed out even after raising sdrbrightness -- see below.
--
-- Instead this relies on render:cm_auto_hdr (default 1, "Auto-switch to
-- hdr mode when fullscreen app is in hdr"). Leaving cm unset gives a
-- plain sRGB desktop with no tone mapping, and Hyprland flips the output
-- to HDR by itself when a fullscreen client actually presents HDR, then
-- flips back on exit. Desktop stays honest, games still get HDR.
--
-- bitdepth = 10 is kept unconditionally (XBGR2101010 rather than
-- XRGB8888). It costs nothing, is proven stable on all three panels at
-- 4K144, gives smoother SDR gradients, and means the depth is already
-- there when auto-switch fires -- 8-bit HDR bands badly in dark scenes.
--
-- IMPORTANT: getting HDR to a game needs more than this file. Stock
-- Proton has no Wayland driver at all, so games run on XWayland where
-- HDR is impossible, and gamescope does not help -- it reports
-- "uMaxLum: 80, uRefLum: 80 / bExposeHDRSupport: false" under Hyprland
-- and hides HDR from the game. What works is proton-cachyos-slr (ships
-- winewayland.drv + DXGI HDR in dxgi.dll) with PROTON_ENABLE_WAYLAND=1
-- in the game's launch options, so the game is a native Wayland client.
--
-- sdrbrightness is INERT while the desktop is SDR. It only applies when
-- the output is actually in HDR, i.e. during an auto-switch, where it
-- sets how SDR surfaces (Steam overlay, notifications, a windowed app
-- alongside the game) are lit. Kept because it is tuned and free.
--
-- 3.0 comes from the desktop-wide-HDR experiment: SDR white maps to
-- sdrMaxLuminance, which Hyprland pins at 80 nits, and 80 nits of white
-- on a 604-nit OLED reads as flat grey. 2.0 / 2.5 / 3.0 were run side by
-- side on the three panels; 3.0 won and 1.5 was still visibly grey.
-- There is no upper clamp -- Hyprland accepted 3.0 as-is. Even at 3.0 the
-- desktop still read as slightly washed, which is what drove the move to
-- on-demand HDR; do not read this value as "the washout is solved".
--
-- Tune here rather than turning HDR back off:
--   sdrbrightness -- SDR white multiplier. Raise if still dim/grey.
--   sdrsaturation -- default 1.0. Only touch this if colours look off
--                    AFTER brightness is right; washout is a luminance
--                    problem first, and moving both at once tells you
--                    nothing about which one helped.
-- To revert HDR entirely, drop bitdepth/cm/sdrbrightness from all three.
--
-- NOTE: `hyprctl keyword` does NOT work with this Lua config -- it fails
-- with "keyword can't work with non-legacy parsers. Use eval." Live test:
--   hyprctl eval 'hl.monitor({output="DP-1", mode="3840x2160@144", position="0x0", scale="1.5", bitdepth=10, cm="hdr", sdrbrightness=1.5})'
-- Valid cm values: auto, srgb, wide, edid, hdr, hdredid.
-- Field names are all lowercase: sdrbrightness, NOT sdrBrightness, which
-- errors with "unknown field". Unknown keys are a hard error, so a typo'd
-- tweak fails loudly rather than silently doing nothing.

hl.monitor({
    output    = MONITOR1,
    mode      = "3840x2160@144",
    position  = "0x0",
    scale     = "1.5",
    bitdepth  = 10,
    sdrbrightness = 3.0,
})

hl.monitor({
    output    = MONITOR2,
    mode      = "3840x2160@144",
    position  = "2560x0",
    scale     = "1.5",
    bitdepth  = 10,
    sdrbrightness = 3.0,
})

hl.monitor({
    output    = MONITOR3,
    mode      = "3840x2160@144",
    position  = "5120x0",
    scale     = "1.5",
    bitdepth  = 10,
    sdrbrightness = 3.0,
})

-- LIVING-ROOM TV. THIS BLOCK ALONE IS NOT ENOUGH -- SEE THE HOOK BELOW.
--
-- scale 2 -> 1920x1080 logical, which is what you want from a couch. It sits
-- at 7680x0, immediately right of MONITOR3 (which ends at 5120 + 2560).
--
-- This will FAIL to come up on its own, and the failure looks like a dead
-- cable: EDID reads fine, full mode list, a CRTC gets assigned, and then
-- every mode is rejected with "Invalid argument" on ATOMIC_TEST_ONLY while
-- /sys/class/drm/card1-HDMI-A-1/enabled stays `disabled`.
--
-- IT IS NOT A BANDWIDTH LIMIT, which is the trap -- it reads identically to
-- the 240Hz note above, but the cause is different and the fix is different.
-- The driver simply cannot enable a 4th head in one atomic commit while the
-- three panels are already at 4K144 10bpc. Measured: the ladder was walked
-- all the way down to 640x480 and *every* mode failed, so it is not about
-- pixels. Bring the TV up first and 3x4K144@10bpc + TV@4K60 then runs
-- together indefinitely.
--
-- So the hook below drops the panels to 60Hz, lights the TV, and puts them
-- back. Costs a few seconds of flicker on hotplug. Do not "simplify" this
-- into just the hl.monitor block; it will silently stop working.
-- bitdepth/sdrbrightness match the three panels above. The TV went without
-- both, which meant a cm_auto_hdr switch here would have landed at 8-bit --
-- exactly the banding the note above warns about, and worst on the dark
-- scenes this display exists for.
--
-- If the TV ever fails to come up after touching this block, bitdepth is the
-- first thing to drop: 10bpc changes the 4th-head modeset that tv-kick.sh is
-- tuned around, and that failure looks like a dead cable (see above).
--
-- 2026-08-20: that happened. On Hyprland 0.56.2 the TV's 10bpc swapchain
-- asks GBM for XR30 and the allocation is refused ("format XR30 isn't
-- supported by primary backend"), so the head never lights even though
-- hyprctl reports it enabled. The three DP panels are unaffected (they get
-- XBGR2101010). Held at 8bpc until a driver/Hyprland update makes XR30
-- allocatable again; expect banding on dark scenes until then.
hl.monitor({
    output    = MONITOR_TV,
    mode      = "3840x2160@60",
    position  = "7680x0",
    scale     = "2",
    bitdepth  = 8,
    sdrbrightness = 3.0,
})

-- Runs on hotplug. The script is a no-op when the TV is absent or already
-- lit, so firing it unconditionally on every monitor.added is fine.
local function kick_tv()
    hl.exec_cmd("~/.config/hypr/scripts/tv-kick.sh")
end

-- At startup, run tv-kick in --boot mode instead: an unconditional
-- drop/light-TV/restore of every head, with verify-and-retry. A reboot can
-- leave a panel walked down the mode ladder (wrong resolution) or black with
-- a silently failed DP link while the driver still reports it healthy (both
-- happened on 2026-08-17); the forced re-modeset fixes both, at the cost of
-- a few seconds of flicker per boot. Details in tv-kick.sh's header.
local function boot_restore()
    hl.exec_cmd("~/.config/hypr/scripts/tv-kick.sh --boot")
end

-- Audio follows the TV head. The NVIDIA HDA card exposes its four digital
-- outputs as mutually exclusive PROFILES, so the TV's sink does not exist at
-- all unless the card is on the TV's profile -- and WirePlumber cannot pick
-- that for itself, because the driver reports every HDMI/DP port as
-- `available` whether or not anything is plugged in. Hyprland knows which head
-- is really up, so it drives the profile.
--
-- WHICH profile is the TV is not fixed and must not be hardcoded: PCM slots
-- are assigned to codec pins dynamically, so it moves. The script reads the
-- ELD off each output and picks the one whose display says HDMI --
-- `tv-audio.sh --status` prints the map. Details in the script.
--
-- hyprland.start is included for the TV-absent boot: WirePlumber restores the
-- HDMI profile from its own state and would otherwise leave the default sink
-- pointing at a TV that is not there.
local function tv_audio()
    hl.exec_cmd("~/.config/hypr/scripts/tv-audio.sh")
end

hl.on("monitor.added", kick_tv)
hl.on("hyprland.start", boot_restore)
hl.on("monitor.added", tv_audio)
hl.on("monitor.removed", tv_audio)
hl.on("hyprland.start", tv_audio)

-- Fallback for anything else not listed above.
-- At 2, so it does not track the 1.5 on the three panels above. Fine for
-- another 4K panel; on a 1080p display it would leave a 960x540 workspace.
-- Give anything you actually plug in its own hl.monitor block rather than
-- relying on this.
hl.monitor({
    output    = "",
    mode      = "preferred",
    position  = "auto",
    scale     = "2",
})
