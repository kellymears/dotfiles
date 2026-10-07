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

hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "down",       action = "close" })
hl.gesture({ fingers = 3, direction = "up",         action = "fullscreen" })
hl.gesture({ fingers = 3, direction = "left",       action = "float" })
