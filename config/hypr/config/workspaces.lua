-- Workspace rules wiki https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- Add your workspace rules here. Increment the workspace number as you go. Do not have duplicate workspaces.

-- GAMING WORKSPACE: TV FIRST, MIDDLE PANEL OTHERWISE.
--
-- The rule below is only the FALLBACK. Preference is MONITOR_TV, and that
-- cannot be decided here: workspace rules are evaluated once at config parse
-- time, while the TV comes and goes (tv-toggle.sh, and on boot it is still
-- dark when this file is read -- tv-kick.sh lights it seconds later).
--
-- So scripts/gaming-monitor.sh owns the live answer. It re-issues this rule --
-- and moves the workspace if it already exists -- on every monitor change,
-- picking MONITOR_TV when Hyprland has that head up and MONITOR2 when it does
-- not. The output names are hardcoded there, same as in tv-kick.sh; keep them
-- in step with variables.lua.
--
-- Deliberately NOT MONITOR1: that is the working panel, and a fullscreen game
-- landing on it buries whatever is being worked on.
hl.workspace_rule({ workspace = "name:gaming", monitor = MONITOR2, default = true })

hl.workspace_rule({ workspace = "1", monitor = MONITOR1, default = true, persistent = true })
hl.workspace_rule({ workspace = "2", monitor = MONITOR1, default = true, persistent = true })
hl.workspace_rule({ workspace = "3", monitor = MONITOR1, default = true, persistent = true })
hl.workspace_rule({ workspace = "4", monitor = MONITOR2, default = true, persistent = true })
hl.workspace_rule({ workspace = "5", monitor = MONITOR2, default = true, persistent = true })
hl.workspace_rule({ workspace = "6", monitor = MONITOR2, default = true, persistent = true })
hl.workspace_rule({ workspace = "7", monitor = MONITOR3, default = true, persistent = true })
hl.workspace_rule({ workspace = "8", monitor = MONITOR3, default = true, persistent = true })
hl.workspace_rule({ workspace = "name:Agent Processes", monitor = MONITOR3, default = true, persistent = true })

-- Three per monitor, which is what NUM_WPM = 3 in variables.lua already
-- assumes: SUPER + CONTROL + 1..3 (focus) and SUPER + SHIFT + CONTROL + 1..3
-- (send window) address them RELATIVELY, so "2" means the second workspace of
-- whichever monitor has focus -- 2, 5 or 8. The absolute numbers above only
-- matter to SUPER + ALT + n.
--
-- persistent keeps them alive while empty; without it an empty workspace is
-- destroyed the moment you look away, and the bar slots come and go.

-- For other layouts such as scrolling, see example below
-- hl.workspace_rule({ workspace = "1", monitor = MONITOR1, default = true, persistent = true, layout = scroling })

-- Re-resolve the gaming monitor whenever the monitor set changes, and after a
-- config reload (which reinstates the fallback rule above and would otherwise
-- silently un-prefer the TV while it is on).
--
-- monitor.added covers the TV being lit, by hotplug or by tv-kick.sh at boot;
-- monitor.removed covers tv-toggle.sh turning it off or the cable coming out.
-- The script is idempotent and self-serializing, so firing it on every head is
-- fine. It waits for the monitor set to settle before reading it.
local function gaming_monitor()
    hl.exec_cmd("~/.config/hypr/scripts/gaming-monitor.sh")
end

hl.on("monitor.added", gaming_monitor)
hl.on("monitor.removed", gaming_monitor)
hl.on("config.reloaded", gaming_monitor)
