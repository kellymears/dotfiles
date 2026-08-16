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
                colors = { CACHYLGREEN, CACHYDGREEN },
                angle = 45,
            },
            inactive_border = CACHYGRAY,
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
        dim_special = 0.3,
        rounding = 10,
        active_opacity = 0.95,
        inactive_opacity = 0.85,
        fullscreen_opacity = 1,
        blur = {
            size = 5,
            passes = 4,
            special = true,
        },
    },
})
