#!/usr/bin/env python3
"""Generate Play Store screenshots for Heather weather app."""

from PIL import Image, ImageDraw, ImageFont
import math
import random

random.seed(42)

# --- Dimensions ---
W, H = 1080, 1920

# --- Font paths ---
FONT_DIR = 'ios/HeatherWidget/Fonts'
POPPINS_BOLD = f'{FONT_DIR}/Poppins-Bold.ttf'
POPPINS_SEMI = f'{FONT_DIR}/Poppins-SemiBold.ttf'
POPPINS_MED = f'{FONT_DIR}/Poppins-Medium.ttf'
POPPINS_REG = f'{FONT_DIR}/Poppins-Regular.ttf'
QUICK_BOLD = f'{FONT_DIR}/Quicksand-Bold.ttf'
QUICK_MED = f'{FONT_DIR}/Quicksand-Medium.ttf'
QUICK_REG = f'{FONT_DIR}/Quicksand-Regular.ttf'

# --- Colors ---
CREAM = (250, 250, 250)
CHAR_PATH = 'android/app/src/main/res/drawable-xxxhdpi/ic_launcher_foreground.png'


def lerp_color(a, b, t):
    return tuple(int(a[i] * (1 - t) + b[i] * t) for i in range(3))


def create_gradient(w, h, colors):
    img = Image.new('RGB', (w, h))
    n = len(colors) - 1
    for y in range(h):
        t = y / h
        seg = min(int(t * n), n - 1)
        lt = (t * n) - seg
        c = lerp_color(colors[seg], colors[seg + 1], lt)
        for x in range(w):
            img.putpixel((x, y), c)
    return img


def load_heather_character(opacity=0.30):
    char_img = Image.open(CHAR_PATH).convert('RGBA')
    w_c, h_c = char_img.size
    new_char = Image.new('RGBA', (w_c, h_c), (0, 0, 0, 0))
    for cy in range(h_c):
        for cx in range(w_c):
            r, g, b, a = char_img.getpixel((cx, cy))
            brightness = (r + g + b) / 3
            if brightness < 80:
                darkness = (80 - brightness) / 80
                op = int(darkness * 255 * opacity)
                new_char.putpixel((cx, cy), (0, 0, 0, min(op, int(255 * opacity))))
    return new_char


def paste_heather(img, char_img, x, y, height):
    scale = height / char_img.height
    new_w = int(char_img.width * scale)
    resized = char_img.resize((new_w, height), Image.LANCZOS)
    img.paste(resized, (x, y), resized)
    return img


def draw_page_dots(draw, x, y, active_index, total=4):
    dot_size = 12
    active_h = 36
    gap = 10
    for i in range(total):
        if i == active_index:
            draw.rounded_rectangle(
                [x, y, x + dot_size, y + active_h],
                radius=dot_size // 2, fill=(250, 250, 250, 230))
            y += active_h + gap
        else:
            draw.ellipse([x, y, x + dot_size, y + dot_size], fill=(250, 250, 250, 127))
            y += dot_size + gap


def draw_translucent_card(base_img, x, y, w, h, radius=32, alpha=45):
    """Draw a translucent card using alpha compositing."""
    overlay = Image.new('RGBA', base_img.size, (0, 0, 0, 0))
    od = ImageDraw.Draw(overlay)
    od.rounded_rectangle([x, y, x + w, y + h], radius=radius,
                         fill=(250, 250, 250, alpha))
    return Image.alpha_composite(base_img, overlay)


def wrap_text(text, font, max_width, draw):
    words = text.split()
    lines = []
    current = ''
    for word in words:
        test = f'{current} {word}'.strip()
        bbox = draw.textbbox((0, 0), test, font=font)
        if bbox[2] - bbox[0] <= max_width:
            current = test
        else:
            if current:
                lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def text_w(draw, text, font):
    bbox = draw.textbbox((0, 0), text, font=font)
    return bbox[2] - bbox[0]


# ===========================================================================
# SCREENSHOT 1: Main Screen - Los Angeles - Sunny Shorts Weather Day
# ===========================================================================
def screenshot_main_la():
    colors = [(80, 200, 208), (255, 196, 0), (255, 104, 0)]
    img = create_gradient(W, H, colors).convert('RGBA')
    draw = ImageDraw.Draw(img)

    f_city = ImageFont.truetype(POPPINS_MED, 36)
    f_temp = ImageFont.truetype(POPPINS_BOLD, 220)
    f_deg = ImageFont.truetype(POPPINS_MED, 60)
    f_quip = ImageFont.truetype(POPPINS_BOLD, 52)
    f_cond = ImageFont.truetype(POPPINS_REG, 30)
    f_detail = ImageFont.truetype(POPPINS_MED, 28)
    f_detail_sm = ImageFont.truetype(POPPINS_REG, 24)
    f_hilo = ImageFont.truetype(QUICK_MED, 30)

    # Location
    city = "Los Angeles"
    cx = (W - text_w(draw, city, f_city)) // 2
    draw.text((cx, 200), city, fill=CREAM, font=f_city)

    # Temperature
    temp_str = "82"
    tw = text_w(draw, temp_str, f_temp)
    deg_str = "°F"
    dw = text_w(draw, deg_str, f_deg)
    total = tw + dw + 4
    tx = (W - total) // 2
    ty = 290
    draw.text((tx, ty), temp_str, fill=CREAM, font=f_temp)
    draw.text((tx + tw + 4, ty + 20), deg_str, fill=CREAM, font=f_deg)

    # High / Low
    hilo = "H:86°  L:71°"
    hx = (W - text_w(draw, hilo, f_hilo)) // 2
    draw.text((hx, ty + 240), hilo, fill=(250, 250, 250, 200), font=f_hilo)

    # Quip
    quip = "The sun is fully locked in. Very Sabrina Carpenter music video on a rooftop. Shorts and sunglasses bestie."
    lines = wrap_text(quip, f_quip, int(W * 0.88), draw)
    qy = 650
    for line in lines:
        lw = text_w(draw, line, f_quip)
        draw.text((W - 70 - lw, qy), line, fill=CREAM, font=f_quip)
        qy += 68

    # Condition + details
    dy = qy + 80
    cond = "Sunny"
    draw.text((W - 70 - text_w(draw, cond, f_cond), dy), cond, fill=(250, 250, 250, 200), font=f_cond)

    dy += 50
    chips = ["Feels 84°", "45%", "8 mph", "UV 7"]
    chip_x = 70
    for chip in chips:
        draw.text((chip_x, dy), chip, fill=(250, 250, 250, 242), font=f_detail)
        chip_x += text_w(draw, chip, f_detail) + 40

    dy += 50
    chips2 = ["Dew 58°", "10.0 mi", "1015 mb"]
    chip_x = 70
    for chip in chips2:
        draw.text((chip_x, dy), chip, fill=(250, 250, 250, 178), font=f_detail_sm)
        chip_x += text_w(draw, chip, f_detail_sm) + 40

    # Page dots
    draw_page_dots(draw, W - 40, H // 2 - 60, active_index=0)

    # Heather
    char_img = load_heather_character(opacity=0.22)
    img = paste_heather(img, char_img, W - 520, H - 560, 520)
    draw = ImageDraw.Draw(img)

    for i in range(3):
        dx = W // 2 - 30 + i * 30
        draw.ellipse([dx, H - 80, dx + 10, H - 70],
                     fill=(250, 250, 250, 230 if i == 0 else 120))

    return img.convert('RGB')


# ===========================================================================
# SCREENSHOT 2: Main Screen - New York - Partly Cloudy Flannel Weather Day
# ===========================================================================
def screenshot_main_ny():
    colors = [(104, 168, 220), (96, 208, 176), (255, 196, 0)]
    img = create_gradient(W, H, colors).convert('RGBA')
    draw = ImageDraw.Draw(img)

    f_city = ImageFont.truetype(POPPINS_MED, 36)
    f_temp = ImageFont.truetype(POPPINS_BOLD, 220)
    f_deg = ImageFont.truetype(POPPINS_MED, 60)
    f_quip = ImageFont.truetype(POPPINS_BOLD, 52)
    f_cond = ImageFont.truetype(POPPINS_REG, 30)
    f_detail = ImageFont.truetype(POPPINS_MED, 28)
    f_detail_sm = ImageFont.truetype(POPPINS_REG, 24)
    f_hilo = ImageFont.truetype(QUICK_MED, 30)

    city = "New York"
    cx = (W - text_w(draw, city, f_city)) // 2
    draw.text((cx, 200), city, fill=CREAM, font=f_city)

    temp_str = "58"
    tw = text_w(draw, temp_str, f_temp)
    deg_str = "°F"
    dw = text_w(draw, deg_str, f_deg)
    total = tw + dw + 4
    tx = (W - total) // 2
    ty = 290
    draw.text((tx, ty), temp_str, fill=CREAM, font=f_temp)
    draw.text((tx + tw + 4, ty + 20), deg_str, fill=CREAM, font=f_deg)

    hilo = "H:62°  L:49°"
    hx = (W - text_w(draw, hilo, f_hilo)) // 2
    draw.text((hx, ty + 240), hilo, fill=(250, 250, 250, 200), font=f_hilo)

    quip = "Sun and clouds at this temp. Literally the weather equivalent of a Taylor Swift bridge. Cozy sweater perfection bestie."
    lines = wrap_text(quip, f_quip, int(W * 0.88), draw)
    qy = 650
    for line in lines:
        lw = text_w(draw, line, f_quip)
        draw.text((W - 70 - lw, qy), line, fill=CREAM, font=f_quip)
        qy += 68

    dy = qy + 80
    cond = "Partly Cloudy"
    draw.text((W - 70 - text_w(draw, cond, f_cond), dy), cond,
              fill=(250, 250, 250, 200), font=f_cond)

    dy += 50
    for chip in ["Feels 55°", "62%", "12 mph", "UV 4"]:
        draw.text((70 + sum(text_w(draw, c, ImageFont.truetype(POPPINS_MED, 28)) + 40
                           for c in ["Feels 55°", "62%", "12 mph", "UV 4"][:["Feels 55°", "62%", "12 mph", "UV 4"].index(chip)]),
                   dy), chip, fill=(250, 250, 250, 242), font=ImageFont.truetype(POPPINS_MED, 28))

    dy += 50
    f_sm = ImageFont.truetype(POPPINS_REG, 24)
    chip_x = 70
    for chip in ["Dew 45°", "10.0 mi", "1018 mb"]:
        draw.text((chip_x, dy), chip, fill=(250, 250, 250, 178), font=f_sm)
        chip_x += text_w(draw, chip, f_sm) + 40

    draw_page_dots(draw, W - 40, H // 2 - 60, active_index=0)

    char_img = load_heather_character(opacity=0.18)
    img = paste_heather(img, char_img, W - 520, H - 560, 520)
    draw = ImageDraw.Draw(img)

    for i in range(3):
        dx = W // 2 - 30 + i * 30
        draw.ellipse([dx, H - 80, dx + 10, H - 70],
                     fill=(250, 250, 250, 230 if i == 0 else 120))

    return img.convert('RGB')


# ===========================================================================
# SCREENSHOT 3: Weekly Forecast - Los Angeles
# ===========================================================================
def screenshot_weekly_la():
    colors = [(80, 200, 208), (255, 196, 0), (255, 104, 0)]
    img = create_gradient(W, H, colors).convert('RGBA')

    f_header = ImageFont.truetype(QUICK_BOLD, 40)
    f_day = ImageFont.truetype(QUICK_BOLD, 32)
    f_date = ImageFont.truetype(QUICK_REG, 22)
    f_hi = ImageFont.truetype(QUICK_BOLD, 32)
    f_lo = ImageFont.truetype(QUICK_MED, 32)
    f_cond = ImageFont.truetype(POPPINS_REG, 20)
    f_stat = ImageFont.truetype(POPPINS_REG, 18)

    # Draw header on a temp draw
    tmp_draw = ImageDraw.Draw(img)
    header = "Next 10 days"
    hw = text_w(tmp_draw, header, f_header)
    tmp_draw.text((W - 70 - hw, 120), header, fill=CREAM, font=f_header)

    days = [
        ("Today", "Mar 12", "Sunny", "82°", "71°", "0%", "UV 7"),
        ("Thu", "Mar 13", "Mostly Sunny", "84°", "72°", "5%", "UV 7"),
        ("Fri", "Mar 14", "Partly Cloudy", "79°", "68°", "10%", "UV 5"),
        ("Sat", "Mar 15", "Sunny", "85°", "73°", "0%", "UV 8"),
        ("Sun", "Mar 16", "Overcast", "74°", "65°", "15%", "UV 3"),
        ("Mon", "Mar 17", "Rain", "68°", "60°", "75%", "UV 2"),
        ("Tue", "Mar 18", "Drizzle", "70°", "62°", "45%", "UV 3"),
        ("Wed", "Mar 19", "Mostly Sunny", "78°", "67°", "5%", "UV 6"),
        ("Thu", "Mar 20", "Sunny", "81°", "70°", "0%", "UV 7"),
        ("Fri", "Mar 21", "Partly Cloudy", "77°", "66°", "10%", "UV 5"),
    ]

    card_y = 210
    card_h = 130
    card_gap = 16
    margin = 50
    card_w = W - margin * 2

    # Draw all translucent cards first
    for i in range(len(days)):
        cy = card_y + i * (card_h + card_gap)
        img = draw_translucent_card(img, margin, cy, card_w, card_h, radius=32, alpha=45)

    # Now draw text on top
    draw = ImageDraw.Draw(img)
    # Re-draw header since alpha_composite may have changed image ref
    draw.text((W - 70 - hw, 120), header, fill=CREAM, font=f_header)

    for i, (day_name, date, cond, hi, lo, precip, uv) in enumerate(days):
        cy = card_y + i * (card_h + card_gap)

        # Day name (left)
        draw.text((margin + 28, cy + 18), day_name, fill=CREAM, font=f_day)
        # Date below day name
        draw.text((margin + 28, cy + 58), date, fill=(250, 250, 250, 200), font=f_date)

        # Condition (center-left)
        cond_x = margin + 220
        draw.text((cond_x, cy + 22), cond, fill=(250, 250, 250, 210), font=f_cond)
        # Precip + UV below condition
        stat = f"{precip}   {uv}"
        draw.text((cond_x, cy + 52), stat, fill=(250, 250, 250, 160), font=f_stat)

        # Hi/Lo (right aligned)
        hi_w = text_w(draw, hi, f_hi)
        lo_w = text_w(draw, lo, f_lo)
        right_edge = W - margin - 28
        draw.text((right_edge - hi_w - lo_w - 16, cy + 38), hi, fill=CREAM, font=f_hi)
        draw.text((right_edge - lo_w, cy + 38), lo, fill=(250, 250, 250, 140), font=f_lo)

    # Page dots
    draw_page_dots(draw, W - 40, H // 2 - 60, active_index=2)

    return img.convert('RGB')


# ===========================================================================
# SCREENSHOT 4: Details Page - Los Angeles (expanded cards)
# ===========================================================================
def screenshot_details_la():
    colors = [(80, 200, 208), (255, 196, 0), (255, 104, 0)]
    img = create_gradient(W, H, colors).convert('RGBA')

    f_header = ImageFont.truetype(QUICK_BOLD, 40)
    f_title = ImageFont.truetype(POPPINS_SEMI, 26)
    f_data = ImageFont.truetype(POPPINS_BOLD, 24)
    f_label = ImageFont.truetype(POPPINS_REG, 20)
    f_chart = ImageFont.truetype(POPPINS_REG, 16)
    f_hour = ImageFont.truetype(POPPINS_MED, 18)
    f_temp_val = ImageFont.truetype(POPPINS_BOLD, 22)

    margin = 50
    card_w = W - margin * 2

    # Header
    tmp_draw = ImageDraw.Draw(img)
    header = "Details"
    hw = text_w(tmp_draw, header, f_header)

    # Cards layout
    cards = [
        (220, 180),   # Conditions
        (430, 280),   # Temperature
        (740, 260),   # Rain
        (1030, 200),  # Sun
        (1260, 200),  # Sky
        (1490, 200),  # Air
    ]

    for cy, ch in cards:
        img = draw_translucent_card(img, margin, cy, card_w, ch, radius=32, alpha=45)

    draw = ImageDraw.Draw(img)
    draw.text((W - 70 - hw, 120), header, fill=CREAM, font=f_header)

    # --- Conditions Card ---
    cy = 220
    draw.text((margin + 28, cy + 16), "Conditions", fill=CREAM, font=f_title)
    hours = [("Now", "82°"), ("1pm", "83°"), ("2pm", "84°"), ("3pm", "84°"),
             ("4pm", "83°"), ("5pm", "81°"), ("6pm", "78°"), ("7pm", "75°")]
    hx = margin + 28
    for label, temp in hours:
        draw.text((hx, cy + 65), temp, fill=CREAM, font=f_temp_val)
        tw = text_w(draw, temp, f_temp_val)
        lw = text_w(draw, label, f_hour)
        draw.text((hx + (tw - lw) // 2, cy + 95), label,
                  fill=(250, 250, 250, 180), font=f_hour)
        hx += 118

    # --- Temperature Card ---
    cy = 430
    draw.text((margin + 28, cy + 16), "Temp", fill=CREAM, font=f_title)
    right = "86° / 71°"
    rw = text_w(draw, right, f_data)
    draw.text((W - margin - 28 - rw, cy + 18), right, fill=CREAM, font=f_data)

    # Chart area
    cl = margin + 70
    cr = W - margin - 28
    ct = cy + 65
    cb = cy + 245
    cw = cr - cl
    ch_h = cb - ct

    # Y-axis
    draw.text((margin + 22, ct - 6), "86°", fill=(250, 250, 250, 140), font=f_chart)
    draw.text((margin + 22, ct + ch_h // 2 - 6), "78°", fill=(250, 250, 250, 140), font=f_chart)
    draw.text((margin + 22, cb - 6), "71°", fill=(250, 250, 250, 140), font=f_chart)

    # Grid lines
    for gy in [ct, ct + ch_h // 2, cb]:
        draw.line([(cl, gy), (cr, gy)], fill=(250, 250, 250, 50), width=1)

    # Temperature curve
    temps = [72, 71, 71, 72, 73, 75, 78, 80, 82, 83, 84, 85,
             86, 85, 84, 83, 81, 78, 76, 75, 74, 73, 72, 72]
    t_min, t_max = 71, 86
    pts = []
    for i, t in enumerate(temps):
        px = cl + int(i / 23 * cw)
        py = cb - int((t - t_min) / (t_max - t_min) * ch_h)
        pts.append((px, py))

    for i in range(len(pts) - 1):
        draw.line([pts[i], pts[i + 1]], fill=(250, 250, 250, 180), width=3)

    dot = pts[12]
    draw.ellipse([dot[0] - 6, dot[1] - 6, dot[0] + 6, dot[1] + 6], fill=CREAM)

    for hr, lb in [(0, "12a"), (6, "6a"), (12, "12p"), (18, "6p")]:
        lx = cl + int(hr / 23 * cw)
        draw.text((lx - 10, cb + 4), lb, fill=(250, 250, 250, 140), font=f_chart)

    # --- Rain Card ---
    cy = 740
    draw.text((margin + 28, cy + 16), "Rain", fill=CREAM, font=f_title)
    draw.text((W - margin - 28 - text_w(draw, "0.00 in  0%", f_data), cy + 18),
              "0.00 in  0%", fill=CREAM, font=f_data)

    bl = margin + 70
    br = W - margin - 28
    bt = cy + 60
    bb = cy + 220
    bw = br - bl
    bh = bb - bt

    draw.text((margin + 18, bt - 6), "100%", fill=(250, 250, 250, 140), font=f_chart)
    draw.text((margin + 26, bt + bh // 2 - 6), "50%", fill=(250, 250, 250, 140), font=f_chart)
    draw.text((margin + 38, bb - 6), "0%", fill=(250, 250, 250, 140), font=f_chart)

    for gy in [bt, bt + bh // 2, bb]:
        draw.line([(bl, gy), (br, gy)], fill=(250, 250, 250, 50), width=1)

    # Small bars to show even low chances
    precip = [0, 0, 0, 0, 0, 3, 5, 2, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 3, 5, 2, 0, 0]
    bar_w = max(bw // 28, 8)
    for i, p in enumerate(precip):
        bx = bl + int(i / 23 * (bw - bar_w))
        bar_val = max(int(p / 100 * bh), 0)
        if bar_val > 2:
            draw.rounded_rectangle(
                [bx, bb - bar_val, bx + bar_w, bb],
                radius=bar_w // 2, fill=(250, 250, 250, 130))

    for hr, lb in [(0, "12a"), (6, "6a"), (12, "12p"), (18, "6p")]:
        lx = bl + int(hr / 23 * (bw - bar_w))
        draw.text((lx - 10, bb + 4), lb, fill=(250, 250, 250, 140), font=f_chart)

    # --- Sun Card ---
    cy = 1030
    draw.text((margin + 28, cy + 16), "Sun", fill=CREAM, font=f_title)

    col_x = [margin + 28, margin + 300, margin + 570]
    pairs = [("Sunrise", "6:42 am"), ("Sunset", "7:08 pm"), ("UV Index", "7 High")]
    for i, (lbl, val) in enumerate(pairs):
        draw.text((col_x[i], cy + 60), lbl, fill=(250, 250, 250, 160), font=f_label)
        draw.text((col_x[i], cy + 88), val, fill=CREAM, font=f_data)

    draw.text((margin + 28, cy + 140), "12h 26m of daylight",
              fill=(250, 250, 250, 160), font=f_label)

    # --- Sky Card ---
    cy = 1260
    draw.text((margin + 28, cy + 16), "Sky", fill=CREAM, font=f_title)

    pairs = [("Illumination", "89%"), ("Phase", "Waxing Gibbous")]
    for i, (lbl, val) in enumerate(pairs):
        draw.text((col_x[i], cy + 60), lbl, fill=(250, 250, 250, 160), font=f_label)
        draw.text((col_x[i], cy + 88), val, fill=CREAM, font=f_data)

    draw.text((margin + 28, cy + 140), "Venus  ·  Jupiter  ·  Mars visible tonight",
              fill=(250, 250, 250, 160), font=f_label)

    # --- Air Card ---
    cy = 1490
    draw.text((margin + 28, cy + 16), "Air", fill=CREAM, font=f_title)

    pairs = [("Wind", "8 mph SW"), ("Pressure", "1015 mb"), ("AQI", "42 Good")]
    for i, (lbl, val) in enumerate(pairs):
        draw.text((col_x[i], cy + 60), lbl, fill=(250, 250, 250, 160), font=f_label)
        draw.text((col_x[i], cy + 88), val, fill=CREAM, font=f_data)

    # AQI gradient bar
    bar_y = cy + 145
    bar_l = margin + 28
    bar_r = W - margin - 28
    bar_total = bar_r - bar_l

    aqi_colors = [
        (0.0, (80, 200, 80)), (0.2, (200, 200, 50)), (0.4, (240, 160, 40)),
        (0.6, (240, 100, 60)), (0.8, (200, 50, 80)), (1.0, (140, 40, 120)),
    ]

    for bx in range(bar_l, bar_r):
        t = (bx - bar_l) / bar_total
        for j in range(len(aqi_colors) - 1):
            if aqi_colors[j][0] <= t <= aqi_colors[j + 1][0]:
                lt = (t - aqi_colors[j][0]) / (aqi_colors[j + 1][0] - aqi_colors[j][0])
                c = lerp_color(aqi_colors[j][1], aqi_colors[j + 1][1], lt)
                draw.line([(bx, bar_y), (bx, bar_y + 10)], fill=(*c, 180))
                break

    # AQI indicator
    aqi_x = bar_l + int(42 / 500 * bar_total)
    draw.ellipse([aqi_x - 7, bar_y - 2, aqi_x + 7, bar_y + 12],
                 fill=CREAM, outline=(200, 200, 200))

    # Page dots
    draw_page_dots(draw, W - 40, H // 2 - 60, active_index=1)

    return img.convert('RGB')


# ===========================================================================
if __name__ == '__main__':
    import os
    out_dir = 'screenshots'

    print('Generating screenshot 1: LA main...')
    s1 = screenshot_main_la()
    p = os.path.join(out_dir, 'screenshot_1_la_main.png')
    s1.save(p, 'PNG')
    print(f'  {s1.size}, {os.path.getsize(p) / 1024:.0f} KB')

    print('Generating screenshot 2: NY main...')
    s2 = screenshot_main_ny()
    p = os.path.join(out_dir, 'screenshot_2_ny_main.png')
    s2.save(p, 'PNG')
    print(f'  {s2.size}, {os.path.getsize(p) / 1024:.0f} KB')

    print('Generating screenshot 3: LA weekly...')
    s3 = screenshot_weekly_la()
    p = os.path.join(out_dir, 'screenshot_3_la_weekly.png')
    s3.save(p, 'PNG')
    print(f'  {s3.size}, {os.path.getsize(p) / 1024:.0f} KB')

    print('Generating screenshot 4: LA details...')
    s4 = screenshot_details_la()
    p = os.path.join(out_dir, 'screenshot_4_la_details.png')
    s4.save(p, 'PNG')
    print(f'  {s4.size}, {os.path.getsize(p) / 1024:.0f} KB')

    print('\nDone! All screenshots in screenshots/')
