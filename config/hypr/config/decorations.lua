-- Look and feel configuration

hl.config({
    general = {
        -- Keep gaps and borders EVEN. The panels run at scale 1.5, where a
        -- logical size maps to whole physical pixels only if it is even
        -- (1.5 = 3/2). Odd gaps push tiled windows to odd sizes, and the
        -- compositor then resamples them onto a half pixel, which softens
        -- the whole surface. gaps_in was 3; at 4 a two-column split on a
        -- 2560-wide panel is 1268 logical -> 1902 physical exactly.
        gaps_in = 4,
        gaps_out = 8,
        border_size = 2,
        extend_border_grab_area = 10,
        resize_on_border = true,
        col = {
            -- Palette-driven, not hardcoded: ROSEPRIMARY/ROSESECONDARY come
            -- from the live Noctalia palette via colors.lua, so switching
            -- palette in Noctalia re-tints the borders along with everything
            -- else. Under "Rosé Pine" this is rose -> foam.
            active_border = {
                colors = { ROSEPRIMARY, ROSESECONDARY },
                angle = 45,
            },
            inactive_border = GLASSEDGE,
        },
    },
    -- Groups were still on the stock CachyOS blue/green, which is the one
    -- place the desktop visibly stopped being Rosé Pine. Now on the palette:
    -- secondary for active, error for locked, muted for inactive.
    group = {
        col = {
            border_active = ROSESECONDARY,
            border_inactive = GLASSEDGE,
            border_locked_active = ROSEERROR,
            border_locked_inactive = GLASSEDGE,
        },
        groupbar = {
            col = {
                active = ROSESECONDARY,
                inactive = "rgba(" .. ROSE_MUTED .. "ff)",
                locked_active = ROSEERROR,
                locked_inactive = "rgba(" .. ROSE_MUTED .. "ff)",
            },
        },
    },
    decoration = {
        rounding = 10,
        -- Unfocused-window de-emphasis is opacity only -- dim_inactive is
        -- false, so dim_strength (0.5) is inert and changing it does
        -- nothing. The gap between these two IS the effect; keep the
        -- falloff at 0.03 (see git history for the earlier values).
        active_opacity = 0.93,
        inactive_opacity = 0.90,
        fullscreen_opacity = 1,
        blur = {
            -- Wider and softer, fewer passes: 8/3 is a bigger kernel than
            -- the old 5/4 for less GPU work, and the softer falloff is what
            -- makes glass read as depth instead of smear.
            size = 8,
            passes = 3,
            -- Frosted-glass tuning. ignore_opacity keeps blur at full
            -- strength behind translucent windows instead of scaling it
            -- with window opacity -- without it the wallpaper bleeds
            -- through sharp.
            ignore_opacity = true,
            -- xray: blur samples the wallpaper, not the windows underneath.
            -- Stacked translucent windows stop compounding into mud, every
            -- pane gets the same clean plate, and it is cheaper (no
            -- per-window re-blur).
            xray = true,
            -- Higher vibrancy pulls wallpaper saturation through the ink
            -- surfaces; without it the near-black tint reads as grey glass.
            vibrancy = 0.55,
            vibrancy_darkness = 0.25,
            noise = 0.02,
            contrast = 0.85,
            brightness = 1.0,
            popups = true,
            popups_ignorealpha = 0.2,
        },
        shadow = {
            enabled = true,
            -- Floating-card shadow: long, soft, dropped slightly downward.
            range = 40,
            render_power = 4,
            offset = { 0, 6 },
            color = GLASSDARK,
            color_inactive = "rgba(0b0a1433)",
        },
        -- Corner vignette (no chromatic aberration: it blurs text at 4K). One
        -- fullscreen pass per frame; drop this first if GPU headroom matters.
        screen_shader = os.getenv("HOME") .. "/.config/hypr/shaders/glass.frag",
    },
})
