-- CachyOS Hyprland Configuration

-- Noctalia palette bridge.
--
-- Enabling the `hyprland` template in Noctalia's theme settings makes it
-- render ~/.config/hypr/noctalia.lua from the ACTIVE palette (currently
-- builtin "Rosé Pine") and keep it in sync whenever the palette changes.
--
-- We take only its `colors` table. We deliberately do NOT call its
-- apply_theme(): that overwrites general.col.active_border with a single flat
-- colour and would destroy the rotating iris->foam gradient set up in
-- decorations.lua + animations.lua.
--
-- The literal string require("noctalia") has to stay in THIS file. Noctalia's
-- template post-hook (templates/hyprland/apply.sh) greps hyprland.lua for it
-- and appends its own apply_theme() call if it does not find one -- which is
-- exactly the flattening we are avoiding.
--
-- pcall, because noctalia.lua is generated machine state: it does not exist on
-- a fresh checkout until Noctalia has applied templates once.
local ok, noctalia = pcall(require, "noctalia")
NOCTALIA = ok and noctalia.colors or nil

require("config.animations")
require("config.autostart")
require("config.colors")
require("config.decorations")
require("config.variables")
require("config.environment")
require("config.inputs")
require("config.binds")
require("config.misc")
require("config.monitors")
require("config.plugins")
require("config.windowrules")
require("config.workspaces")
