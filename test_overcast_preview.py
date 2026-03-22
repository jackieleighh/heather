#!/usr/bin/env python3
"""Quick visual preview of widget weather effects after the haze-band overhaul."""

from PIL import Image, ImageDraw, ImageFilter
import math, os, random

def hex_to_rgb(h):
    h = h.lstrip("#")
    if len(h) == 8:  # AARRGGBB
        h = h[2:]
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))

def draw_gradient(img, colors_hex):
    w, h = img.size
    draw = ImageDraw.Draw(img)
    rgbs = [hex_to_rgb(c) for c in colors_hex]
    for y in range(h):
        t = y / max(h - 1, 1)
        seg = t * (len(rgbs) - 1)
        i = min(int(seg), len(rgbs) - 2)
        f = seg - i
        r = int(rgbs[i][0] * (1 - f) + rgbs[i + 1][0] * f)
        g = int(rgbs[i][1] * (1 - f) + rgbs[i + 1][1] * f)
        b = int(rgbs[i][2] * (1 - f) + rgbs[i + 1][2] * f)
        draw.line([(0, y), (w, y)], fill=(r, g, b))

def composite_ellipse(base, bbox, color_rgba, blur_radius):
    w, h = base.size
    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    draw.ellipse(bbox, fill=color_rgba)
    if blur_radius > 0:
        layer = layer.filter(ImageFilter.GaussianBlur(radius=blur_radius))
    base.alpha_composite(layer)

def composite_circle(base, cx, cy, r, color_rgba, blur_radius):
    bbox = (cx - r, cy - r, cx + r, cy + r)
    composite_ellipse(base, bbox, color_rgba, blur_radius)

# ---------- Seeded RNG matching the Swift/Kotlin xorshift ----------
class SeededRNG:
    def __init__(self, seed):
        self.state = seed if seed != 0 else 1
        self.state &= 0xFFFFFFFFFFFFFFFF

    def next(self):
        self.state ^= (self.state << 13) & 0xFFFFFFFFFFFFFFFF
        self.state ^= (self.state >> 7)
        self.state ^= (self.state << 17) & 0xFFFFFFFFFFFFFFFF
        return self.state

    def next_double(self):
        return (self.next() % 10000) / 10000.0

# ---------- Effect renderers ----------

def draw_stars(img, count):
    w, h = img.size
    rng = SeededRNG(42)
    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    for _ in range(count):
        x = rng.next_double() * w
        y = rng.next_double() * h * 0.7
        star_size = 0.5 + rng.next_double() * 2.0
        phase = rng.next_double() * math.pi * 2
        twinkle = (math.sin(phase) + 1) / 2
        opacity = 0.08 + twinkle * 0.17
        radius = star_size * (0.8 + twinkle * 0.2)
        bbox = (x - radius, y - radius, x + radius, y + radius)
        draw.ellipse(bbox, fill=(255, 255, 255, int(opacity * 255)))
    img.alpha_composite(layer)

def draw_moon_glow(img, center=None):
    w, h = img.size
    sz_scale = min(w, h) / 400.0
    cx = center[0] if center else w * 0.8
    cy = center[1] if center else h * 0.12
    composite_circle(img, cx, cy, 36 * sz_scale,
                     (255, 255, 255, int(0.12 * 255)), 18 * sz_scale)
    composite_circle(img, cx, cy, 18 * sz_scale,
                     (255, 255, 255, int(0.28 * 255)), 6 * sz_scale)

def draw_top_darkening_band(img):
    w, h = img.size
    sz_scale = min(w, h) / 400.0
    bbox = (w * 0.5 - w * 0.7, -h * 0.075, w * 0.5 + w * 0.7, h * 0.075)
    composite_ellipse(img, bbox, (0, 0, 0, int(0.06 * 255)), 30 * sz_scale)

def draw_overcast_haze_bands(img):
    w, h = img.size
    sz_scale = min(w, h) / 400.0
    bands = [(0.20, 0.05), (0.45, 0.06), (0.70, 0.04)]
    band_h = h * 0.06
    for y_frac, alpha in bands:
        cy = h * y_frac
        bbox = (-w * 0.1, cy - band_h / 2, w * 1.1, cy + band_h / 2)
        composite_ellipse(img, bbox, (255, 255, 255, int(alpha * 255)), 40 * sz_scale)

def draw_sun_glow_overcast(img):
    w, h = img.size
    sz_scale = min(w, h) / 400.0
    glow_r = 70 * sz_scale
    composite_circle(img, w * 0.8, h * 0.12, glow_r,
                     (255, 255, 255, int(0.14 * 255)), 50 * sz_scale)

def draw_upper_lower_haze(img):
    w, h = img.size
    sz_scale = min(w, h) / 400.0
    composite_ellipse(img,
                      (w * 0.5 - w, h * 0.25 - h * 0.25, w * 0.5 + w, h * 0.25 + h * 0.25),
                      (255, 255, 255, int(0.03 * 255)), 100 * sz_scale)
    composite_ellipse(img,
                      (w * 0.5 - w * 0.9, h * 0.65 - h * 0.2, w * 0.5 + w * 0.9, h * 0.65 + h * 0.2),
                      (255, 255, 255, int(0.02 * 255)), 100 * sz_scale)

# ---------- Scene renderers ----------

def render_partly_cloudy_night(w, h):
    # partlyCloudy resolves to "sunny" for gradients; tier 3 (~60°F)
    grad = ["#FF1E1B4B", "#FF2E1065", "#FF086040"]
    img = Image.new("RGBA", (w, h))
    draw_gradient(img, grad)
    pc_center = (w * 0.75, h * 0.12)
    draw_stars(img, 50)
    draw_moon_glow(img, center=pc_center)
    draw_top_darkening_band(img)
    return img

def render_overcast_night(w, h):
    # overcast night; tier 3 (~60°F)
    grad = ["#FF0F0716", "#FF2E1065", "#FF086040"]
    img = Image.new("RGBA", (w, h))
    draw_gradient(img, grad)
    draw_sun_glow_overcast(img)   # same faint glow used day & night
    draw_overcast_haze_bands(img)
    draw_upper_lower_haze(img)
    return img

# ---------- Main ----------

def main():
    out_dir = os.path.join(os.path.dirname(__file__), "test_previews")
    os.makedirs(out_dir, exist_ok=True)

    sizes = {
        "small":  (170, 170),
        "medium": (338, 155),
        "large":  (338, 354),
    }

    scenes = {
        "partlyCloudy_night": render_partly_cloudy_night,
        "overcast_night":     render_overcast_night,
    }

    for scene_name, renderer in scenes.items():
        for size_name, (w, h) in sizes.items():
            img = renderer(w * 2, h * 2)
            path = os.path.join(out_dir, f"{scene_name}_{size_name}.png")
            img.save(path)
            print(f"Saved {path}  ({w*2}x{h*2})")

    print("\nDone!")

if __name__ == "__main__":
    main()
