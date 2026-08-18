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
            active_border = {
                colors = { ROSEIRIS, ROSEFOAM },
                angle = 45,
            },
            inactive_border = GLASSEDGE,
        },
    },
    group = {
        col = {
            border_active = CACHYLBLUE,
            border_inactive = CACHYGRAY,
            border_locked_active = CACHYDBLUE,
            border_locked_inactive = CACHYGRAY,
        },
        groupbar = {
            col = {
                active = CACHYLGREEN,
                inactive = CACHYGRAY,
                locked_active = CACHYDBLUE,
                locked_inactive = CACHYGRAY,
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
            size = 5,
            passes = 4,
            -- Frosted-glass tuning. ignore_opacity keeps blur at full
            -- strength behind translucent windows instead of scaling it
            -- with window opacity -- without it the wallpaper bleeds
            -- through sharp.
            ignore_opacity = true,
            vibrancy = 0.4,
            vibrancy_darkness = 0.2,
            noise = 0.015,
            contrast = 0.9,
            brightness = 1.0,
            popups = true,
            popups_ignorealpha = 0.2,
        },
        shadow = {
            enabled = true,
            range = 24,
            render_power = 3,
            color = GLASSDARK,
            color_inactive = "rgba(0b0a1433)",
        },
    },
})
