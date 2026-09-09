#!/usr/bin/python3
"""catsaver -- black overlay screensaver with a pixel cat bounding across the
desk panels.

Why this exists: DPMS-off on this box re-trains all four heads on wake, and
one of the DP panels regularly comes back stuck at 1920x1080@60. A black
overlay is nearly as OLED-friendly as power-off (black OLED pixels are
unpowered) and never triggers a modeset. The TV is deliberately left alone;
see the OUTPUTS default.

Wired up by noctalia's idle "command" action (config.toml [idle]). Run by
hand to preview:

    catsaver.py                 # live, until killed
    catsaver.py --preview x.png # render a frame strip to a PNG, no display

Sprite is drawn in a 22x17 grid, scaled up SCALE times. Frames: "stand" and "step"
alternate for the walk; "sit" is the crouched pause.
"""
import os
import random
import sys
import time

# Logical-pixel world: the outputs below are laid side by side in Gdk
# monitor order; the cat moves through the combined span.
OUTPUTS = ("DP-1", "DP-2", "DP-3")
SCALE = 7           # sprite pixel -> logical pixels
FPS = 30
SPEED = 110.0       # logical px/s, a walk
STRIDE = 0.28       # seconds per walk frame
FLOOR = 0           # paws on the bottom edge: he walks the bezel
SIT_MIN, SIT_MAX = 2.0, 6.0   # how long a sit lasts
SIT_EVERY = (6.0, 20.0)       # seconds of walking between sits

# Deliberately not full-brightness: OLED panels, and the whole point is to
# be gentle. Outline is a warm near-black so it reads on pure black.
PALETTE = {
    "O": (0.78, 0.50, 0.26),  # orange
    "D": (0.26, 0.15, 0.09),  # outline / stripes
    "W": (0.86, 0.80, 0.68),  # cream muzzle, belly, paws
    "K": (0.08, 0.08, 0.08),  # eyes
    "P": (0.83, 0.55, 0.60),  # inner ear, nose
    "E": (0.95, 0.95, 0.92),  # eye glint
}

# 22 wide x 17 tall, cat faces right. "." is transparent.
FRAMES = {
    "stand": [
        "..........DD......DD..",
        "..........DPD....DPD..",
        "..........DOPD..DPOD..",
        "..........DOOODDOOOD..",
        ".........DOOOOOOOOOOD.",
        ".........DOOOOOOOOOOD.",
        "..DD.....DOKEOOOOKEOD.",
        ".DOOD....DOKKOOOOKKOD.",
        ".DOOD....DOOOOOOOOOOD.",
        "..DOD..DDDOOOWPWOOOOD.",
        "..DODDDOOOOOOWWWOOOD..",
        "...DOOOOOOOOOOOOOOD...",
        "...DOOODOOODOOOOOD....",
        "...DOOOOOOOOOOOOOD....",
        "....DOD.DOD..DOD.DOD..",
        "....DWD.DWD..DWD.DWD..",
        "....DDD.DDD..DDD.DDD..",
    ],
    "step": [
        "..........DD......DD..",
        "..........DPD....DPD..",
        "..........DOPD..DPOD..",
        "..........DOOODDOOOD..",
        ".........DOOOOOOOOOOD.",
        ".........DOOOOOOOOOOD.",
        "..DD.....DOKEOOOOKEOD.",
        ".DOOD....DOKKOOOOKKOD.",
        ".DOOD....DOOOOOOOOOOD.",
        "..DOD..DDDOOOWPWOOOOD.",
        "..DODDDOOOOOOWWWOOOD..",
        "...DOOOOOOOOOOOOOOD...",
        "...DOOODOOODOOOOOD....",
        "...DOOOOOOOOOOOOOD....",
        "...DOD..DOD.DOD..DOD..",
        "..DWD...DWD..DWD..DWD.",
        "..DDD...DDD..DDD..DDD.",
    ],
    "sit": [
        "......................",
        "......................",
        "..........DD......DD..",
        "..........DPD....DPD..",
        "..........DOPD..DPOD..",
        "..........DOOODDOOOD..",
        ".........DOOOOOOOOOOD.",
        ".DD......DOOOOOOOOOOD.",
        "DOOD.....DOKEOOOOKEOD.",
        "DOOD.....DOKKOOOOKKOD.",
        ".DOD...DDDOOOOOOOOOOD.",
        ".DODDDDOOOOOOWPWOOOOD.",
        "..DOOOOOOOOOOWWWOOOD..",
        "..DOOOODOOODOOOOOOOD..",
        "..DOOOOOOOOOOOOOOOOD..",
        "..DWWDDWWDDOODWWDDWWD.",
        "..DDD.DDD.....DDD.DDD.",
    ],
}
SPRITE_W = len(FRAMES["stand"][0])
SPRITE_H = len(FRAMES["stand"])


def parse(rows):
    px = []
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            if ch != ".":
                px.append((x, y, PALETTE[ch]))
    return px


PIXELS = {name: parse(rows) for name, rows in FRAMES.items()}


class Cat:
    """Walks back and forth along the bottom of the panels, reverses at the
    world edges, and sits down for a moment now and then. The baseline
    nudges a few px per crossing so one row of pixels never carries it."""

    def __init__(self, world_w, world_h, seed=None):
        self.rng = random.Random(seed)
        self.w, self.h = world_w, world_h
        self.cw, self.ch = SPRITE_W * SCALE, SPRITE_H * SCALE
        self.x = self.rng.uniform(0, world_w - self.cw)
        self.dir = self.rng.choice((-1, 1))
        self.base = self._pick_base()
        self.phase = "walk"
        self.t = 0.0
        self.until = self._next_sit()

    def _pick_base(self):
        # At most one sprite pixel of lift, so the paws stay on the bezel
        # while the exact rows still vary a little per crossing.
        return self.h - FLOOR - self.rng.uniform(0, SCALE)

    def _next_sit(self):
        return self.t + self.rng.uniform(*SIT_EVERY)

    @property
    def frame(self):
        if self.phase == "sit":
            return "sit"
        return "step" if int(self.t / STRIDE) % 2 else "stand"

    def step(self, dt):
        self.t += dt
        if self.phase == "sit":
            if self.t >= self.until:
                self.phase = "walk"
                self.until = self._next_sit()
            return
        self.x += self.dir * SPEED * dt
        if self.x <= 0 or self.x + self.cw >= self.w:
            self.x = max(0.0, min(self.x, self.w - self.cw))
            self.dir = -self.dir
            self.base = self._pick_base()
        if self.t >= self.until:
            self.phase = "sit"
            self.until = self.t + self.rng.uniform(SIT_MIN, SIT_MAX)

    @property
    def y(self):
        """Top-left y of the sprite; base is where the paws sit."""
        return self.base - self.ch

    def draw(self, cr, ox, oy):
        """Draw into a cairo context whose origin is world (ox, oy)."""
        cr.save()
        cr.translate(self.x - ox, self.y - oy)
        if self.dir < 0:
            cr.translate(self.cw, 0)
            cr.scale(-1, 1)
        cr.set_antialias(1)  # CAIRO_ANTIALIAS_NONE
        for px, py, (r, g, b) in PIXELS[self.frame]:
            cr.set_source_rgb(r, g, b)
            cr.rectangle(px * SCALE, py * SCALE, SCALE, SCALE)
            cr.fill()
        cr.restore()


def preview(path):
    import cairo
    frames = list(FRAMES)
    pad = 20
    w = (SPRITE_W * SCALE + pad) * len(frames) + pad
    h = SPRITE_H * SCALE + 2 * pad
    surf = cairo.ImageSurface(cairo.FORMAT_RGB24, w, h)
    cr = cairo.Context(surf)
    cr.set_source_rgb(0, 0, 0)
    cr.paint()
    cat = Cat(10_000, 10_000, seed=1)
    cat.dir = 1
    for i, name in enumerate(frames):
        cat.x = pad + i * (SPRITE_W * SCALE + pad)
        cat.base = pad + SPRITE_H * SCALE
        cat.phase = "sit" if name == "sit" else "walk"
        cat.t = 0.0 if name == "stand" else STRIDE
        cat.draw(cr, 0, 0)
    surf.write_to_png(path)
    print(f"wrote {path} ({w}x{h}): {' / '.join(frames)}")


def run():
    # gtk4-layer-shell has to be in the process before libgtk resolves its
    # wayland symbols, and from Python the typelib import order cannot
    # guarantee that (the LayerShell typelib itself pulls Gtk in first).
    # Without it every window is a plain toplevel and GTK warns "not a
    # layer surface". So re-exec once with the library preloaded.
    lib = "/usr/lib/libgtk4-layer-shell.so"
    if lib not in os.environ.get("LD_PRELOAD", ""):
        env = dict(os.environ)
        env["LD_PRELOAD"] = ":".join(filter(None, (env.get("LD_PRELOAD"), lib)))
        # Renderer, measured steady-state on the 3x 2560x1440 overlays:
        # cairo 68% of a core (software-composites every frame), vulkan 5%
        # and noisy (VK_SUBOPTIMAL_KHR each frame), ngl 2%. ngl it is.
        env.setdefault("GSK_RENDERER", "ngl")
        os.execve(sys.executable, [sys.executable, *sys.argv], env)
    import gi
    gi.require_version("Gtk", "4.0")
    gi.require_version("Gdk", "4.0")
    gi.require_version("Gtk4LayerShell", "1.0")
    from gi.repository import Gdk, GLib, Gtk, Gtk4LayerShell as Shell

    app = Gtk.Application(application_id="me.kellymears.catsaver")

    def activate(app):
        display = Gdk.Display.get_default()
        mons = [m for m in display.get_monitors() if m.get_connector() in OUTPUTS]
        mons.sort(key=lambda m: m.get_geometry().x)
        if not mons:
            print("catsaver: none of", OUTPUTS, "present", file=sys.stderr)
            app.quit()
            return
        # World = the covered outputs laid contiguously, in logical px.
        offsets, x = {}, 0
        for m in mons:
            g = m.get_geometry()
            offsets[m.get_connector()] = x
            x += g.width
        world_h = min(m.get_geometry().height for m in mons)
        cat = Cat(x, world_h)
        # Each output gets a black Gtk.Fixed and one sprite-sized
        # DrawingArea that is moved around inside it. Only the sprite
        # repaints per tick; repainting three full 2560x1440 surfaces at
        # 30 fps cost a whole core.
        css = Gtk.CssProvider()
        css.load_from_string(".catsaver { background: #000; }")
        Gtk.StyleContext.add_provider_for_display(
            display, css, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
        sprites = []  # (fixed, area, world offset x)
        for m in mons:
            win = Gtk.Window(application=app)
            Shell.init_for_window(win)
            Shell.set_layer(win, Shell.Layer.OVERLAY)
            Shell.set_monitor(win, m)
            Shell.set_keyboard_mode(win, Shell.KeyboardMode.NONE)
            Shell.set_exclusive_zone(win, -1)
            for edge in (Shell.Edge.TOP, Shell.Edge.BOTTOM,
                         Shell.Edge.LEFT, Shell.Edge.RIGHT):
                Shell.set_anchor(win, edge, True)
            win.add_css_class("catsaver")
            fixed = Gtk.Fixed()
            fixed.add_css_class("catsaver")
            area = Gtk.DrawingArea()
            area.set_size_request(cat.cw, cat.ch)

            def on_draw(_a, cr, _w, _h):
                cr.save()
                cr.translate(-cat.x, -cat.y)
                cat.draw(cr, 0, 0)
                cr.restore()

            area.set_draw_func(on_draw)
            fixed.put(area, 0, 0)
            win.set_child(fixed)
            win.set_cursor(Gdk.Cursor.new_from_name("none"))
            win.present()
            sprites.append((fixed, area, offsets[m.get_connector()]))

        last = [time.monotonic()]
        shown = [None]

        def tick():
            now = time.monotonic()
            cat.step(min(now - last[0], 0.1))
            last[0] = now
            key = (round(cat.x), round(cat.y), cat.frame, cat.dir)
            if key == shown[0]:
                return True
            shown[0] = key
            for fixed, area, ox in sprites:
                fixed.move(area, cat.x - ox, cat.y)
                area.queue_draw()
            return True

        GLib.timeout_add(int(1000 / FPS), tick)

    app.connect("activate", activate)
    app.run(None)


if __name__ == "__main__":
    if len(sys.argv) >= 3 and sys.argv[1] == "--preview":
        preview(sys.argv[2])
    else:
        run()
