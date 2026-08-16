-- Auto-start config
-- if you dont use UWSM add your auto start programs here, otherwise use XDG autostart https://wiki.archlinux.org/title/XDG_Autostart

hl.on("hyprland.start", function ()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("noctalia")
    hl.exec_cmd("xhost +SI:localuser:root")
end)

-- Scratchpad terminal, parked in the `term` special workspace (SUPER + `).
-- single-instance must be off or this window joins the existing process and
-- the title rule above never sees it.
hl.on("hyprland.start", function()
    hl.exec_cmd("ghostty --gtk-single-instance=false --title=scratchterm")
end)
