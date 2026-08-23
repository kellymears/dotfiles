-- Colors
--
-- Two sources, in priority order:
--
--  1. NOCTALIA -- the live Noctalia palette, set in hyprland.lua from the
--     generated noctalia.lua. This is the real source of truth: change the
--     palette in Noctalia and the borders follow, along with GTK, Qt, btop,
--     ghostty and the shell itself. Noctalia only exports four roles
--     (primary, secondary, surface, error), which is exactly what the border
--     and group colors below need.
--
--  2. The Rosé Pine literals -- the fallback, used on a fresh checkout before
--     Noctalia has ever applied templates, and as the reference for anything
--     Noctalia does not export. Keep them matching the "Rosé Pine" builtin so
--     the fallback is not a visibly different desktop.

-- Rosé Pine reference (https://rosepinetheme.com/palette/)
ROSE_BASE    = "191724"
ROSE_SURFACE = "1f1d2e"
ROSE_MUTED   = "6e6a86"
ROSE_SUBTLE  = "908caa"
ROSE_TEXT    = "e0def4"
ROSE_LOVE    = "eb6f92"
ROSE_GOLD    = "f6c177"
ROSE_ROSE    = "ebbcba"
ROSE_PINE    = "31748f"
ROSE_FOAM    = "9ccfd8"
ROSE_IRIS    = "c4a7e7"

-- Noctalia hands back "rgb(rrggbb)"; Hyprland gradients here want an alpha.
-- Pull the hex out of either form and re-wrap it at the requested opacity.
local function hexOf(value, fallback)
    if type(value) ~= "string" then return fallback end
    local hex = value:match("#?(%x%x%x%x%x%x)")
    return hex or fallback
end

local function rgba(value, alpha, fallback)
    return "rgba(" .. hexOf(value, fallback) .. alpha .. ")"
end

local N = NOCTALIA or {}

-- Rosé Pine accents (translucent, for the glass look).
-- Under the "Rosé Pine" builtin these resolve to primary=rose, secondary=foam.
ROSEPRIMARY   = rgba(N.primary,   "cc", ROSE_ROSE)
ROSESECONDARY = rgba(N.secondary, "cc", ROSE_FOAM)
ROSESURFACE   = rgba(N.surface,   "ff", ROSE_BASE)
ROSEERROR     = rgba(N.error,     "ff", ROSE_LOVE)

-- Kept as named literals: these are fixed accents, not palette roles, and
-- there is nothing in Noctalia's four-role export to map them onto.
ROSEIRIS  = "rgba(" .. ROSE_IRIS .. "cc)"
ROSEFOAM  = "rgba(" .. ROSE_FOAM .. "cc)"
ROSEPINE  = "rgba(" .. ROSE_PINE .. "cc)"

-- Glass edges. The inactive border is a bare white wash rather than a palette
-- color on purpose -- it has to read as "not focused" against any wallpaper,
-- including a moving one, and a tinted edge competes with the active gradient.
GLASSEDGE = "rgba(ffffff26)"
GLASSDARK = "rgba(0b0a1466)"

-- Cachy colors (CachyOS defaults; still referenced by misc.lua's splash).
CACHYLGREEN = "rgba(82dcccff)"
CACHYMGREEN = "rgba(00aa84ff)"
CACHYDGREEN = "rgba(007d6fff)"
CACHYLBLUE  = "rgba(01ccffff)"
CACHYMBLUE  = "rgba(182545ff)"
CACHYDBLUE  = "rgba(111826ff)"
CACHYWHITE  = "rgba(ffffffff)"
CACHYGREY   = "rgba(ddddddff)"
CACHYGRAY   = "rgba(798bb2ff)"
