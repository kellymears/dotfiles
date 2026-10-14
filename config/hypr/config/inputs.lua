-- Input configuration

hl.config({
    input = {
        -- sensitivity = -0.25,
        accel_profile = "flat",
        -- Click to focus. Default (1) moves focus on hover, which makes it
        -- far too easy to lose focus by brushing the mouse across a display.
        -- 2 detaches pointer focus from keyboard focus: hover still delivers
        -- scroll/hover events to the window under the cursor, but keyboard
        -- focus only moves on click.
        follow_mouse = 2,
        touchpad = {
            -- Magic Trackpad: physical clicks only, and the button is chosen
            -- by finger count (1 left, 2 right, 3 middle) instead of libinput's
            -- default bottom-edge button areas, where a click in the
            -- bottom-centre strip is a middle click and pastes.
            clickfinger_behavior = true,
            tap_to_click = false,
            -- macOS-style content-follows-fingers; the mouse wheel is untouched.
            natural_scroll = true,
        },
    },
    cursor = {
        -- Hide the pointer after a few idle seconds. Mainly so it is not
        -- parked on top of the catsaver overlay, whose own "none" cursor
        -- never applies because pointer focus does not move while idle.
        inactive_timeout = 5,
        -- Uncomment to enable software cursors; this can help with cursor
        -- display or behavior issues.
        -- no_hardware_cursors = 1,
    },
})

-- Magic Trackpad scroll acceleration, macOS-style: slow drags move less than
-- the finger. Fast motion is held to about half speed: browsers coast from
-- the release speed, so anything faster launches the page. scroll_points are
-- output speeds at input speeds 0, 1, 2, ... units/ms, and libinput extends
-- the last segment's slope.
-- "custom 1 0 1" keeps pointer motion at the flat 1:1 everything else uses.
hl.device({
    name = "apple-inc.-magic-trackpad",
    accel_profile = "custom 1 0 1",
    scroll_points = "1 0 0.3 0.75 1.35 2.1 2.7 3.25 3.75 4.2 4.6",
})

hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "down",       action = "close" })
hl.gesture({ fingers = 3, direction = "up",         action = "fullscreen" })
hl.gesture({ fingers = 3, direction = "left",       action = "float" })
