-- Input configuration

hl.config({
    input = {
        -- sensitivity = -0.25,
        accel_profile = "flat",
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
