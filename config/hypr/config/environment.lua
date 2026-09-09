-- Environmental variables (for reference https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/)
-- if you use UWSM, define your variables in ~/.config/uwsm/env
-- if you don't use UWSM, define your variables here (e.g. hl.env("QT_QPA_PLATFORM", "wayland"))

-- NVIDIA (RTX 4090, nvidia-open 610.x)
hl.env("GBM_BACKEND", "nvidia-drm")                -- force GBM as a backend
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")      -- GLX vendor for XWayland
hl.env("LIBVA_DRIVER_NAME", "nvidia")              -- hardware video accel
hl.env("NVD_BACKEND", "direct")                    -- required by libva-nvidia-driver >= 0.0.10
hl.env("__GL_GSYNC_ALLOWED", "1")                  -- allow VRR on G-Sync capable panels

-- Default terminal for anything that reads $TERMINAL
hl.env("TERMINAL", "ghostty")

-- Chromeless: Qt draws its own titlebar on Wayland unless told not to.
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- Electron/Chromium apps (1Password, Discord, Obsidian, Chrome) default to
-- XWayland, where they render at 1x and get upscaled by the compositor --
-- visibly blurry at scale 1.5 on a 4K panel. These make them go native.
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- CachyOS ships BROWSER=firefox in ~/.config/uwsm/env (from /etc/skel).
-- Declared here too so the tracked config is the source of truth.
hl.env("BROWSER", "zen-browser")

-- Cursor: Bibata Modern Ice. BreezeX-RosePine matched the palette but is a
-- Breeze outline arrow -- generic in a way the rest of the desktop is not.
-- Bibata is white and rounded, and reads as deliberate at 4K.
--
-- HYPRCURSOR_* covers native Wayland, XCURSOR_* covers XWayland and the GTK
-- fallback. Both must name a theme that actually exists in the respective
-- format, and they are NOT the same install:
--   hyprcursor -> ~/.local/share/icons/Bibata-Modern-Ice (vector .hlc, v2.0.6)
--   XCursor    -> /usr/share/icons/Bibata-Modern-Ice (bibata-cursor-theme-bin)
-- The hyprcursor one is what keeps the pointer sharp when dynamic-cursors'
-- shake-to-find magnifies it; without it that falls back to scaling a 24px
-- bitmap. rose-pine-hyprcursor is still installed if this needs reverting.
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE", "24")
