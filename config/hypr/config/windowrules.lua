-- Window rules wiki https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Generic floating position
hl.window_rule({ match = { float = true }, center = true, persistent_size = true })

-- Picture-in-Picture
hl.window_rule({
    match             = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
    float             = true,
    keep_aspect_ratio = true,
    size              = { "max(monitor_w, monitor_h)*0.25", "min(monitor_w, monitor_h)*0.25" },
    pin               = true,
})

-- Gaming
local gamingApps = "^(steam_app.*|gamescope)$"
local gamingWorkspace = "name:gaming"

hl.window_rule({ match = { content = "game" }, workspace = gamingWorkspace })
hl.window_rule({ match = { xdg_tag = "^(.*game.*)$" }, workspace = gamingWorkspace, fullscreen_state = 2, content = "game", sync_fullscreen = true })
hl.window_rule({ match = { class = gamingApps }, workspace = gamingWorkspace })

-- gamescope tiling, TESTED AND UNRESOLVED -- do not re-try the obvious fix.
--
-- gamescope's own -f only fullscreens the game INSIDE gamescope; the
-- gamescope window itself still lands tiled on the host, so you get a
-- normal tiled window with gaps instead of borderless fullscreen. The
-- big gamingApps rule below is supposed to cover this but matches on
-- title = "^(.+)$", and gamescope maps its window before the game sets a
-- title, so at map time it misses.
--
-- A class-only rule with fullscreen_state = 2 does NOT fix it. Tried it
-- both in this file and live via `hyprctl eval`, with and without
-- size = { monitor_w, monitor_h }: the rule registers without error and
-- the window still comes up tiled at 2544x1388. fullscreen_state appears
-- to set only the internal (client-facing) state, not to make Hyprland
-- actually fullscreen the window.
--
-- Workarounds that DO work: pass -b (borderless) to gamescope, or hit
-- Super+F inside gamescope to toggle fullscreen at runtime.
hl.window_rule({ match = { class = "^(steam)$", title = "^(Friends List)$" }, float = true })
hl.window_rule({ match = { class = "^(steam)$", title = "^(Launching\\.{3})$" }, float = true, center = true, workspace = gamingWorkspace })
-- The main Steam client window itself (library/big picture), not just the
-- games it launches. Excludes the two special windows above so Friends List
-- doesn't get dragged onto the gaming workspace along with it.
hl.window_rule({ match = { class = "^(steam)$", title = "negative:^(Friends List|Launching\\.{3})$" }, workspace = gamingWorkspace })
hl.window_rule({
    match = {
        class         = gamingApps,
        title         = "^(.+)$",
        initial_title = "negative:^(.*\\\\home\\\\.*)$",
    },
    content          = "game",
    decorate         = false,
    fullscreen_state = 2,
    size             = { "monitor_w", "monitor_h" },
    sync_fullscreen  = true,
})
hl.window_rule({
    match = {
        class         = "^(steam_app.*)$",
        initial_title = "^$",
    },
    center           = true,
    float            = true,
    fullscreen       = false,
    fullscreen_state = 0,
    workspace        = gamingWorkspace,
})

-- Apps
-- Human browsers live on the third display's first workspace (absolute 7;
-- see workspaces.lua). Non-silent so opening a link still pulls focus there.
-- Chrome for Testing is class chromium-browser, so it is not caught here.
hl.window_rule({ match = { class = "^(google-chrome|zen)$" }, workspace = "7" })

-- Keep agent-launched browser sessions out of the interactive workspaces.
-- Chrome for Testing shares chromium-browser's class, so identify it by the
-- product name in its initial title instead of catching regular Chromium too.
hl.window_rule({
    match = {
        class         = "^(chromium-browser)$",
        initial_title = "^(.*Google Chrome for Testing)$",
    },
    workspace = "name:Agent Processes silent",
})

hl.window_rule({ match = { class = "^(.*\\.exe)$", float = true }, monitor = PRIMARY_MONITOR, center = true, fullscreen_state = 0 })
hl.window_rule({ match = { class = "^(.*[Ll]auncher.*)$" }, float = true, monitor = PRIMARY_MONITOR })
hl.window_rule({ match = { class = "^(vesktop|discord)$" }, monitor = PRIMARY_MONITOR })
hl.window_rule({ match = { class = "^(.*[Cc]alc.*)$" }, float = true, size = { "max(monitor_w, monitor_h)*0.17", "min(monitor_w, monitor_h)*0.43" } })
hl.window_rule({ match = { class = "^(org\\.kde\\.keditfiletype)$" }, float = true })
hl.window_rule({ match = { class = "^(org\\.kde\\.ark)$" }, size = { "max(monitor_w, monitor_h)*0.40", "min(monitor_w, monitor_h)*0.40" } })
hl.window_rule({ match = { class = "^(.*satty.*)$", title = "^(Satty)$" }, min_size = { "max(monitor_w, monitor_h)*0.35", "min(monitor_w, monitor_h)*0.35" }, float = true })
hl.window_rule({ match = { class = "^(dev\\.)?(noctalia\\.Noctalia(\\.Settings)?)$" }, float = true, size = { "monitor_w*0.70", "monitor_h*0.70" } })

-- vicinae launcher. It is an ordinary xdg-shell window here, NOT a layer
-- surface: vicinae 0.26.3 segfaults in
-- LayerShellQt::QWaylandLayerSurface::requestActivate() on the second close of
-- any given process, so launcher_window.layer_shell.enabled is false in
-- ~/.config/vicinae/settings.json. Turn layer shell back on once that is fixed
-- upstream and this rule becomes unnecessary -- a layer_rule would be needed
-- instead, since window rules never match layer surfaces.
--
-- Float + centre would be inherited from the generic floating rule at the top
-- of this file, but it is stated explicitly so the launcher does not silently
-- start tiling if that rule ever changes. Blur comes from the global
-- decoration.blur (the window is translucent at opacity 0.8), so it needs no
-- rule of its own.
hl.window_rule({
    name  = "vicinae-launcher",
    match = { class = "^(vicinae)$" },
    float = true,
    center = true,
    pin = true,
    -- No scale-in. The global windows animation is spring "rubber" +
    -- "popin 87%", which on a centred, pinned launcher has nowhere to travel,
    -- so it reads as the window wobbling in place. "popin 100%" starts the
    -- window at full size, leaving the geometry animation with nothing to do
    -- while the separate fade animation still runs -- i.e. it just fades in.
    animation = "popin 100%",
})
-- Opacity Overrides
local terminals = "^(kitty|ghostty|[Kk]onsole|Alacritty|gnome-terminal|xfce[0-9]?-terminal)$"

-- Browsers: near-opaque, not opaque. Page content stays legible at 0.96
-- while the toolbar/tab strip picks up the xray glass plate like everything
-- else. Fullscreen (video) is still 1.0 via fullscreen_opacity.
hl.window_rule({ match = { class = "^(firefox|zen|google-chrome|chromium-browser)$" }, opacity = "0.96 override 0.94 override 1.0 override" })
hl.window_rule({ match = { class = terminals }, opacity = "1.0 override" }) -- Override opacity in favor of terminal settings for opacity. If your terminal doesn't support transparency, you can remove this rule.
hl.window_rule({ match = { class = "^(mpv|org.kde.haruna|.*plex.*|org\\.kde\\.gwenview|.*vlc.*)$" }, opacity = "1.0 override" })

-- Float Utility Windows
local floatApps = {
    { class = "^(kvantummanager|qt[56]ct|nwg-look)$" },
    { class = "^(org.pulseaudio.pavucontrol|blueman-manager|nm-applet|nm-connection-editor)$" },
    { title = "^(Winetricks.*|Protontricks.*)$" },
}
for _, m in ipairs(floatApps) do hl.window_rule({ match = m, float = true }) end

-- Float Common Modals
local modalMatches = {
    { title = "^(Open|Authentication Required|Add Folder to Workspace|Choose Files|Save As|Confirm to replace files|File Operation Progress)$" },
    { initial_title = "^(Open File)$" },
    { class = "^([Xx]dg-desktop-portal-gtk)$" },
    { title = "^(File Upload|Choose wallpaper|Library)(.*)$" },
    { class = "^(.*dialog.*)$" },
    { title = "^(.*dialog.*)$" },
    { class = "^(hyprland-share-picker)$"},
}
for _, m in ipairs(modalMatches) do hl.window_rule({ match = m, float = true }) end

-- Ignore maximize requests from all apps. You'll probably like this.
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- Glass layers --------------------------------------------------------------
-- ignore_alpha skips fully/mostly transparent pixels so rounded corners don't
-- get a square blur halo.

-- The Noctalia shell surfaces (bar, dock, panels, launcher, notifications).
-- Deliberately NOT noctalia-wallpaper.
hl.layer_rule({
    name  = "glass-noctalia",
    match = { namespace = "^(noctalia-(bar|dock|launcher|notification|attached-panel|control-center|settings|osd).*)$" },
    blur  = true,
    ignore_alpha = 0.3,
})

-- Everything else that is a layer surface (tooltips, satty, GTK layer-shell
-- popovers, any future bar) gets the same glass. Wallpaper layers are
-- excluded: blurring the wallpaper itself is a fullscreen pass for nothing.
hl.layer_rule({
    name  = "glass-all",
    match = { namespace = "^(?!.*(wallpaper|mpvpaper|hyprpaper|swww|background)).*$" },
    blur  = true,
    ignore_alpha = 0.3,
})

-- Scratchpads -------------------------------------------------------------
-- Populate them by hand with SUPER+SHIFT+` / N / M. Auto-launching a terminal
-- into one does not work with ghostty: --gtk-single-instance means the window
-- is created by the already-running process, so neither --title nor --class
-- applies and no window rule can match it. A terminal that honours --class
-- (kitty) could be auto-placed here instead.
