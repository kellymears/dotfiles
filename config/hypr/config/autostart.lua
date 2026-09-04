-- Auto-start config
-- if you dont use UWSM add your auto start programs here, otherwise use XDG autostart https://wiki.archlinux.org/title/XDG_Autostart

hl.on("hyprland.start", function ()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("noctalia")
    hl.exec_cmd("xhost +SI:localuser:root")
    hl.exec_cmd("hyprpm reload -n") -- load enabled plugins (hymission, hyprfocus, dynamic-cursors, hyprwinwrap)
end)

-- 1Password, started to the tray. `op` is load-bearing for every Carrot build
-- (MISo injects secrets via `op inject`), and the CLI talks to the desktop
-- app -- if it is not running, builds fail with "cannot connect to 1Password
-- app" partway through.
hl.on("hyprland.start", function()
    hl.exec_cmd("1password --silent")
end)
