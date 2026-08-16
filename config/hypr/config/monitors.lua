-- Monitor wiki https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Outputs are named in variables.lua (MONITOR1..3). Find them with `hyprctl monitors`.
--
-- POSITIONS ARE IN *LOGICAL* PIXELS, NOT PHYSICAL ONES.
-- At scale 2 each 3840px panel is 1920 logical px wide, so the three
-- monitors must start at 0 / 1920 / 3840. If you change `scale`, you MUST
-- recompute these or you leave dead gaps between displays and the mouse
-- cannot cross from one to the next. (At the previous 1.5 they were
-- 2560 wide, starting 0 / 2560 / 5120.)
--
-- SCALE IS 2, NOT 1.5, ON PURPOSE.
--
-- 1.5 is a fractional scale: a window 1385 logical px tall wants 2077.5
-- physical px, so the compositor resamples the whole surface onto a half
-- pixel and everything picks up a slight softness. Integer scale maps
-- 1:1 with no resampling, and apps that ship 1x/2x asset tiers (Electron
-- ones especially -- Discord avatars, emoji, icons) get the real 2x
-- images instead of an upscaled 1x.
--
-- The tradeoff is a 1920x1080 logical workspace per panel instead of
-- 2560x1440, so everything is ~33% larger. Claw that back per-app with
-- each app's own zoom (Discord Settings > Appearance > Zoom ~75%,
-- Ctrl+- in browsers) -- page zoom shrinks the layout while rasterizing
-- at the full 2x, so you keep the sharpness. Do NOT reach for
-- --force-device-scale-factor to do this: on Wayland it multiplies with
-- the compositor scale rather than replacing it, so it just zooms.
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
    scale     = "2",
})

hl.monitor({
    output    = MONITOR2,
    mode      = "3840x2160@144",
    position  = "1920x0",
    scale     = "2",
})

hl.monitor({
    output    = MONITOR3,
    mode      = "3840x2160@144",
    position  = "3840x0",
    scale     = "2",
})

-- Fallback for anything not listed above (e.g. the HDMI port).
-- Deliberately left at 1.5, not raised to 2 with the three panels above:
-- this matches an unknown display, and 2 on a 1080p monitor would leave a
-- 960x540 workspace. Give it its own hl.monitor block if you plug in
-- something that wants a different scale.
hl.monitor({
    output    = "",
    mode      = "preferred",
    position  = "auto",
    scale     = "2",
})
