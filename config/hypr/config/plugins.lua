-- hyprpm plugin configuration.
--
-- Plugins themselves are enabled with `hyprpm enable <name>` (state lives in
-- ~/.local/share/hyprpm), and loaded at startup by the `hyprpm reload -n` in
-- autostart.lua. This file only configures the ones that are loaded, and every
-- block is guarded: a plugin that failed to rebuild after a Hyprland bump must
-- not take the whole config down with it.
--
-- Currently enabled: hymission (bound in binds.lua), hyprfocus,
-- dynamic-cursors.
--
-- Deliberately NOT enabled: hyprbars. Title bars are dead space on a setup
-- where everything is tiled; the window's position already identifies it.

------------------------------------------------------------------------------
-- dynamic-cursors -- VirtCode/hypr-dynamic-cursors
--
-- Physical-feeling cursor: it rotates toward the direction of travel, and
-- shake-to-find magnifies it, the same gesture macOS and Plasma use. The
-- upstream manifest pins per Hyprland release and carries an explicit pin for
-- v0.56.2, so this rebuilds cleanly on `hyprpm update` -- but check that a pin
-- exists before taking a Hyprland update, or the plugin drops out.
------------------------------------------------------------------------------
if hl.plugin and hl.plugin.dynamic_cursors then
    hl.config({
        plugin = {
            dynamic_cursors = {
                enabled = true,

                -- No motion effect. rotate/tilt/stretch were tried and the
                -- swinging cursor is a distraction, not a feature -- you
                -- track the pointer constantly and it never stops moving.
                -- The plugin stays loaded purely for shake-to-find below,
                -- which Hyprland has no built-in equivalent for.
                mode      = "none",
                -- Degrees of movement before the shape is re-rendered. Lower
                -- is smoother and costs a cursor redraw per step; 2 is the
                -- upstream default and is already fine on a 4090.
                threshold = 2,

                shake = {
                    enabled   = true,
                    -- Lower threshold = triggers on smaller shakes. 6.0 is
                    -- upstream default; 5.5 catches a deliberate wiggle
                    -- without firing during normal fast mouse movement.
                    threshold = 5.5,
                    base      = 4.0,
                    speed     = 4.0,
                    -- Cap the magnification. Upstream default 0.0 is
                    -- unlimited, which on three 4K panels can balloon the
                    -- cursor to absurd size before you stop shaking.
                    limit     = 8.0,
                    timeout   = 1500,
                    effects   = false,
                },

                hyprcursor = {
                    -- rose-pine-hyprcursor is a real hyprcursor theme (SVG),
                    -- so the rotated/magnified cursor stays vector-sharp
                    -- instead of resampling a 24px XCursor bitmap.
                    -- See HYPRCURSOR_THEME in environment.lua.
                    enabled    = true,
                    nearest    = 1,
                    resolution = -1,
                },
            },
        },
    })
end
