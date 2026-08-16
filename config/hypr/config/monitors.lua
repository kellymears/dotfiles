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

hl.monitor({
    output    = MONITOR1,
    mode      = "3840x2160@144",
    position  = "0x0",
    scale     = "1.5",
})

hl.monitor({
    output    = MONITOR2,
    mode      = "3840x2160@144",
    position  = "2560x0",
    scale     = "1.5",
})

hl.monitor({
    output    = MONITOR3,
    mode      = "3840x2160@144",
    position  = "5120x0",
    scale     = "1.5",
})

-- Fallback for anything not listed above (e.g. the HDMI port).
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
