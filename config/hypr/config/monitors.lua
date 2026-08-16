-- Monitor wiki https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Outputs are named in variables.lua (MONITOR1..3). Find them with `hyprctl monitors`.
--
-- POSITIONS ARE IN *LOGICAL* PIXELS, NOT PHYSICAL ONES.
-- At scale 1.5 each 3840px panel is 2560 logical px wide, so the three
-- monitors must start at 0 / 2560 / 5120. If you change `scale`, you MUST
-- recompute these or you leave dead gaps between displays and the mouse
-- cannot cross from one to the next.
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
hl.monitor({
    output    = "",
    mode      = "preferred",
    position  = "auto",
    scale     = "1.5",
})
