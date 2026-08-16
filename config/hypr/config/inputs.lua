-- Input configuration

hl.config({
    input = {
        -- sensitivity = -0.25,
        accel_profile = "flat",
        -- Keyboard is in Mac mode (Ctrl | Opt | Cmd). This swaps left Ctrl with
        -- left Super so the *thumb* key (Cmd) sends Ctrl -- app shortcuts land
        -- where a Mac user's hands expect them -- while the pinky sends Super
        -- for Hyprland. Linux keeps its clean Super=desktop / Ctrl=app split.
        kb_options = "ctrl:swap_lwin_lctl",
    },
    -- Uncomment the section below to enable software cursors; this can help with cursor display or behavior issues
    -- cursor = {
    --     no_hardware_cursors = 1,
    -- },
})

hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "down",       action = "close" })
hl.gesture({ fingers = 3, direction = "up",         action = "fullscreen" })
hl.gesture({ fingers = 3, direction = "left",       action = "float" })
