"""Deterministic original placeholder art for Milestone 1.

Draws pixel art with flat colors from the master palette. Nothing here is
traced from another game, and nothing is model-generated imagery.
Re-run from the repo root: python tools/generate_placeholders.py
"""

from __future__ import annotations

import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# RGBA. No pure black or white; outline is a dark purple-brown.
C = {
    "outline": (42, 36, 48, 255),
    "grass_d": (58, 86, 48, 255),
    "grass": (78, 112, 58, 255),
    "grass_l": (108, 138, 70, 255),
    "grass_h": (148, 168, 92, 255),
    "path": (154, 136, 114, 255),
    "path_d": (118, 102, 86, 255),
    "path_l": (186, 168, 142, 255),
    "path_c": (96, 84, 72, 255),
    "gravel": (132, 122, 112, 255),
    "gravel_d": (104, 96, 88, 255),
    "brick": (150, 84, 68, 255),
    "brick_d": (112, 60, 54, 255),
    "brick_l": (176, 112, 90, 255),
    "cream": (214, 198, 170, 255),
    "cream_d": (176, 158, 132, 255),
    "cream_s": (148, 128, 112, 255),
    "roof": (112, 62, 68, 255),
    "roof_d": (74, 44, 52, 255),
    "roof_l": (148, 86, 90, 255),
    "wood": (124, 84, 52, 255),
    "wood_d": (86, 58, 38, 255),
    "wood_l": (164, 118, 74, 255),
    "glass": (126, 162, 176, 255),
    "glass_d": (78, 110, 136, 255),
    "glass_h": (186, 206, 196, 255),
    "leaf": (52, 96, 58, 255),
    "leaf_d": (36, 70, 48, 255),
    "leaf_l": (86, 128, 72, 255),
    "trunk": (98, 68, 46, 255),
    "trunk_d": (68, 48, 36, 255),
    "skin": (214, 164, 132, 255),
    "skin_d": (176, 122, 98, 255),
    "hair": (72, 52, 40, 255),
    "hair_l": (108, 78, 56, 255),
    "shirt": (70, 96, 142, 255),
    "shirt_d": (48, 68, 108, 255),
    "shirt_l": (104, 128, 168, 255),
    "pants": (54, 52, 68, 255),
    "pants_d": (40, 38, 52, 255),
    "shoe": (48, 40, 38, 255),
    "gold": (196, 156, 78, 255),
    "paper": (220, 210, 190, 255),
    "grey": (168, 164, 158, 255),
    "grey_d": (112, 108, 104, 255),
    "bun": (186, 180, 170, 255),
    "bun_d": (140, 134, 126, 255),
    "cardigan": (96, 112, 78, 255),
    "cardigan_d": (68, 82, 58, 255),
    "skirt": (92, 64, 72, 255),
    "skirt_d": (68, 46, 54, 255),
    "carpet": (128, 64, 68, 255),
    "carpet_d": (96, 48, 54, 255),
    "carpet_l": (156, 90, 90, 255),
    "plaster": (196, 184, 164, 255),
    "plaster_d": (158, 146, 128, 255),
    "moss": (70, 102, 64, 255),
    "lamp": (232, 196, 140, 255),
    "flower": (176, 96, 92, 255),
    "flower2": (196, 164, 78, 255),
    "soil": (92, 70, 52, 255),
}

PALETTE_RGB = {rgb[:3] for rgb in C.values()}
CLEAR = (0, 0, 0, 0)
Image = list[list[tuple[int, int, int, int]]]


def new_image(w: int, h: int) -> Image:
    return [[CLEAR for _ in range(w)] for _ in range(h)]


def setp(img: Image, x: int, y: int, color: tuple[int, int, int, int]) -> None:
    if 0 <= y < len(img) and 0 <= x < len(img[0]):
        img[y][x] = color


def fill_rect(img: Image, x: int, y: int, w: int, h: int, color: tuple[int, int, int, int]) -> None:
    for yy in range(y, y + h):
        for xx in range(x, x + w):
            setp(img, xx, yy, color)


def fill_ellipse(img: Image, cx: int, cy: int, rx: int, ry: int, color: tuple[int, int, int, int]) -> None:
    if rx <= 0 or ry <= 0:
        return
    for y in range(cy - ry, cy + ry + 1):
        for x in range(cx - rx, cx + rx + 1):
            if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1.0:
                setp(img, x, y, color)


def blit(dst: Image, src: Image, ox: int, oy: int) -> None:
    for y, row in enumerate(src):
        for x, pixel in enumerate(row):
            if pixel[3] == 0:
                continue
            setp(dst, ox + x, oy + y, pixel)


def outline(img: Image) -> Image:
    h = len(img)
    w = len(img[0])
    solid = [[img[y][x][3] > 200 for x in range(w)] for y in range(h)]
    out = [row[:] for row in img]
    ink = C["outline"]
    for y in range(h):
        for x in range(w):
            if solid[y][x]:
                continue
            if any(
                0 <= x + dx < w and 0 <= y + dy < h and solid[y + dy][x + dx]
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))
            ):
                out[y][x] = ink
    return out


def mirror(img: Image) -> Image:
    w = len(img[0])
    return [[img[y][w - 1 - x] for x in range(w)] for y in range(len(img))]


def noise(x: int, y: int) -> int:
    return ((x * 73 + y * 151) ^ (x * 17 + y * 31)) & 255


def write_png(path: Path, img: Image) -> None:
    h = len(img)
    w = len(img[0])
    raw = bytearray()
    for row in img:
        raw.append(0)
        for r, g, b, a in row:
            if a and (r, g, b) not in PALETTE_RGB:
                raise SystemExit(f"color {(r, g, b)} is outside the master palette ({path.name})")
            if (r, g, b) in ((0, 0, 0), (255, 255, 255)) and a:
                raise SystemExit(f"pure black/white in {path.name}")
            raw.extend((r, g, b, a))
    def chunk(tag: bytes, data: bytes) -> bytes:
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

    ihdr = struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0)
    png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", zlib.compress(bytes(raw), 9)) + chunk(b"IEND", b"")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(png)


def write_gpl(path: Path) -> None:
    lines = ["GIMP Palette", "Name: The Calling Master", "Columns: 8", "#"]
    for name in sorted(C):
        r, g, b, _a = C[name]
        lines.append(f"{r:3d} {g:3d} {b:3d} {name}")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def grass_tile(alt: bool) -> Image:
    img = new_image(32, 32)
    fill_rect(img, 0, 0, 32, 32, C["grass"])
    for y in range(32):
        for x in range(32):
            n = noise(x + (17 if alt else 0), y)
            if n > 210:
                setp(img, x, y, C["grass_l"])
            elif n < 30:
                setp(img, x, y, C["grass_d"])
            elif alt and n in (40, 41):
                setp(img, x, y, C["grass_h"])
    return img


def path_tile() -> Image:
    img = new_image(32, 32)
    fill_rect(img, 0, 0, 32, 32, C["path_d"])
    fill_rect(img, 1, 1, 14, 14, C["path"])
    fill_rect(img, 17, 1, 14, 14, C["path"])
    fill_rect(img, 1, 17, 14, 14, C["path_l"])
    fill_rect(img, 17, 17, 14, 14, C["path"])
    setp(img, 8, 22, C["path_c"])
    setp(img, 9, 23, C["path_c"])
    setp(img, 24, 6, C["path_c"])
    return img


def gravel_tile() -> Image:
    img = new_image(32, 32)
    fill_rect(img, 0, 0, 32, 32, C["gravel"])
    for y in range(32):
        for x in range(32):
            n = noise(x + 3, y + 9)
            if n > 190:
                setp(img, x, y, C["gravel_d"])
            elif n < 18:
                setp(img, x, y, C["path_l"])
    return img


def wood_tile() -> Image:
    img = new_image(32, 32)
    fill_rect(img, 0, 0, 32, 32, C["wood"])
    for y in (0, 8, 16, 24):
        fill_rect(img, 0, y, 32, 1, C["wood_d"])
        fill_rect(img, 0, y + 1, 32, 1, C["wood_l"])
    for x in (6, 20):
        fill_rect(img, x, 0, 1, 8, C["wood_d"])
        fill_rect(img, x + 8, 8, 1, 8, C["wood_d"])
        fill_rect(img, x, 16, 1, 8, C["wood_d"])
        fill_rect(img, x + 4, 24, 1, 8, C["wood_d"])
    return img


def carpet_tile() -> Image:
    img = new_image(32, 32)
    fill_rect(img, 0, 0, 32, 32, C["carpet"])
    fill_rect(img, 0, 0, 2, 32, C["carpet_d"])
    fill_rect(img, 30, 0, 2, 32, C["carpet_d"])
    fill_rect(img, 14, 0, 4, 32, C["carpet_l"])
    return img


def plaster_tile() -> Image:
    img = new_image(32, 32)
    fill_rect(img, 0, 0, 32, 32, C["plaster"])
    fill_rect(img, 0, 28, 32, 4, C["wood_d"])
    for y in range(32):
        for x in range(32):
            if noise(x + 4, y + 2) > 230:
                setp(img, x, y, C["plaster_d"])
    return img


def church_front() -> Image:
    w, h = 384, 160
    img = new_image(w, h)
    # Steeple and cross.
    fill_rect(img, 180, 4, 24, 48, C["roof_d"])
    fill_rect(img, 188, 0, 8, 10, C["roof"])
    fill_rect(img, 189, 1, 6, 14, C["cream"])
    fill_rect(img, 184, 5, 16, 4, C["cream"])
    # Roof mass, slightly lighter ridge.
    for y in range(36, 96):
        inset = max(0, (52 - y) // 2)
        tone = C["roof_l"] if 186 <= (192) and abs((y // 3) - 20) < 2 else C["roof"]
        if (y // 5) % 2 == 0:
            tone = C["roof_d"] if tone == C["roof"] else C["roof"]
        fill_rect(img, inset, y, w - inset * 2, 1, tone)
    fill_rect(img, 188, 40, 8, 56, C["roof_l"])
    fill_rect(img, 0, 92, w, 6, C["roof_d"])
    # Weathered wall.
    fill_rect(img, 6, 98, w - 12, 48, C["cream"])
    for y in range(100, 144):
        for x in range(8, w - 8):
            if noise(x, y) > 240:
                setp(img, x, y, C["cream_d"])
    fill_rect(img, 6, 140, w - 12, 14, C["brick"])
    for x in range(8, w - 8, 10):
        setp(img, x, 146, C["brick_d"])
        setp(img, x + 4, 142, C["brick_l"])
    # Moss and a crack at the foundation.
    fill_rect(img, 18, 150, 10, 3, C["moss"])
    fill_rect(img, 340, 148, 8, 2, C["moss"])
    setp(img, 210, 152, C["brick_d"])
    setp(img, 211, 153, C["brick_d"])
    setp(img, 212, 154, C["path_c"])
    # Windows (centers near x=72 and x=312, y=116).
    for wx in (52, 292):
        fill_rect(img, wx, 104, 40, 28, C["wood_d"])
        fill_rect(img, wx + 3, 107, 34, 22, C["glass"])
        fill_rect(img, wx + 18, 107, 2, 22, C["wood_d"])
        fill_rect(img, wx + 3, 116, 34, 2, C["wood_d"])
        setp(img, wx + 8, 110, C["glass_h"])
        setp(img, wx + 28, 122, C["glass_d"])
    # Door, centered at x=192.
    fill_rect(img, 164, 108, 56, 46, C["wood_d"])
    fill_rect(img, 168, 112, 22, 38, C["wood"])
    fill_rect(img, 194, 112, 22, 38, C["wood_l"])
    fill_rect(img, 176, 120, 8, 12, C["wood_d"])
    fill_rect(img, 200, 120, 8, 12, C["wood_d"])
    setp(img, 188, 132, C["gold"])
    setp(img, 196, 132, C["gold"])
    # Step.
    fill_rect(img, 156, 152, 72, 6, C["path_d"])
    fill_rect(img, 160, 154, 64, 3, C["path"])
    return outline(img)


def actor_frame(facing: str, frame: int, elder: bool) -> Image:
    img = new_image(32, 48)
    bob = 0
    if frame == 1:
        bob = 1
    elif frame in (2, 4):
        bob = -1
    leg = 0
    if frame >= 2:
        leg = (frame - 2) % 4
    left_dx = (0, 0, -2, 0, 2, 0)[frame] if not elder else 0
    right_dx = (0, 0, 2, 0, -2, 0)[frame] if not elder else 0
    if elder:
        shirt, shirt_d, shirt_l = C["cardigan"], C["cardigan_d"], C["moss"]
        hair, hair_l = C["bun"], C["bun_d"]
        legs, legs_d = C["skirt"], C["skirt_d"]
    else:
        shirt, shirt_d, shirt_l = C["shirt"], C["shirt_d"], C["shirt_l"]
        hair, hair_l = C["hair"], C["hair_l"]
        legs, legs_d = C["pants"], C["pants_d"]

    def body(y0: int) -> None:
        fill_rect(img, 11, y0 + 22, 10, 11, shirt)
        fill_rect(img, 11, y0 + 22, 10, 2, shirt_l)
        fill_rect(img, 8, y0 + 24, 3, 8, shirt_d)
        fill_rect(img, 21, y0 + 24, 3, 8, shirt_d)
        if not elder:
            fill_rect(img, 14, y0 + 22, 4, 2, C["paper"])
        fill_rect(img, 12 + left_dx, y0 + 33, 4, 8, legs)
        fill_rect(img, 17 + right_dx, y0 + 33, 4, 8, legs_d if leg in (0, 2) else legs)
        fill_rect(img, 12 + left_dx, y0 + 40, 4, 3, C["shoe"])
        fill_rect(img, 17 + right_dx, y0 + 40, 4, 3, C["shoe"])

    y0 = bob
    if facing == "down":
        body(y0)
        fill_rect(img, 11, y0 + 10, 10, 12, C["skin"])
        fill_rect(img, 11, y0 + 18, 10, 3, C["skin_d"])
        fill_rect(img, 10, y0 + 8, 12, 7, hair)
        fill_rect(img, 11, y0 + 14, 10, 2, hair)
        setp(img, 15, y0 + 9, hair_l)
        setp(img, 13, y0 + 15, C["outline"])
        setp(img, 18, y0 + 15, C["outline"])
        if elder:
            fill_rect(img, 9, y0 + 6, 14, 6, hair)
            setp(img, 12, y0 + 15, C["grey_d"])
            setp(img, 19, y0 + 15, C["grey_d"])
            setp(img, 15, y0 + 15, C["grey_d"])
        if frame == 1 and not elder:
            setp(img, 13, y0 + 15, C["skin_d"])
            setp(img, 18, y0 + 15, C["skin_d"])
    elif facing == "up":
        body(y0)
        fill_rect(img, 10, y0 + 8, 12, 14, hair)
        fill_rect(img, 12, y0 + 16, 8, 4, C["skin_d"])
        setp(img, 14, y0 + 10, hair_l)
        if elder:
            fill_rect(img, 9, y0 + 5, 14, 8, hair)
    else:
        # Left profile. Right is mirrored.
        fill_rect(img, 12, y0 + 22, 9, 11, shirt)
        fill_rect(img, 12, y0 + 22, 9, 2, shirt_l)
        fill_rect(img, 18, y0 + 24, 3, 8, shirt_d)
        if not elder:
            setp(img, 14, y0 + 23, C["paper"])
        fill_rect(img, 13 + left_dx, y0 + 33, 3, 8, legs)
        fill_rect(img, 17 + right_dx, y0 + 33, 3, 8, legs_d)
        fill_rect(img, 13 + left_dx, y0 + 40, 3, 3, C["shoe"])
        fill_rect(img, 17 + right_dx, y0 + 40, 3, 3, C["shoe"])
        fill_rect(img, 11, y0 + 10, 9, 11, C["skin"])
        fill_rect(img, 10, y0 + 8, 10, 6, hair)
        fill_rect(img, 10, y0 + 12, 3, 6, hair)
        setp(img, 12, y0 + 15, C["outline"])
        if elder:
            fill_rect(img, 12, y0 + 5, 8, 6, hair)
            setp(img, 12, y0 + 15, C["grey_d"])
    framed = outline(img)
    fill_ellipse(framed, 16, 45, 6, 2, (42, 36, 48, 90))
    return framed


def player_sheet() -> Image:
    sheet = new_image(32 * 6, 48 * 4)
    for row, facing in enumerate(("down", "up", "left", "right")):
        for col in range(6):
            frame = actor_frame("left" if facing == "right" else facing, col, False)
            if facing == "right":
                frame = mirror(frame)
            blit(sheet, frame, col * 32, row * 48)
    return sheet


def margaret_sheet() -> Image:
    sheet = new_image(64, 48)
    blit(sheet, actor_frame("down", 0, True), 0, 0)
    blit(sheet, actor_frame("down", 1, True), 32, 0)
    return sheet


def tree(kind: int) -> Image:
    img = new_image(48, 80)
    fill_ellipse(img, 24, 74, 10, 3, (42, 36, 48, 80))
    fill_rect(img, 21, 48, 6, 26, C["trunk_d"])
    fill_rect(img, 22, 48, 3, 26, C["trunk"])
    if kind == 0:
        fill_ellipse(img, 24, 36, 16, 16, C["leaf_d"])
        fill_ellipse(img, 22, 34, 12, 12, C["leaf"])
        fill_ellipse(img, 18, 30, 5, 4, C["leaf_l"])
    elif kind == 1:
        fill_ellipse(img, 24, 34, 14, 18, C["leaf_d"])
        fill_ellipse(img, 24, 32, 10, 13, C["leaf"])
        fill_ellipse(img, 20, 26, 4, 4, C["leaf_l"])
    else:
        fill_ellipse(img, 22, 38, 18, 13, C["leaf_d"])
        fill_ellipse(img, 28, 30, 8, 8, C["leaf"])
        fill_ellipse(img, 16, 34, 8, 7, C["leaf_l"])
    return outline(img)


def bench() -> Image:
    img = new_image(48, 32)
    fill_rect(img, 6, 18, 4, 10, C["wood_d"])
    fill_rect(img, 38, 18, 4, 10, C["wood_d"])
    fill_rect(img, 4, 14, 40, 6, C["wood"])
    fill_rect(img, 4, 14, 40, 2, C["wood_l"])
    fill_rect(img, 6, 8, 36, 3, C["wood_d"])
    fill_rect(img, 8, 6, 3, 8, C["wood_d"])
    fill_rect(img, 37, 6, 3, 8, C["wood_d"])
    return outline(img)


def notice_board() -> Image:
    img = new_image(32, 48)
    fill_rect(img, 14, 28, 4, 18, C["wood_d"])
    fill_rect(img, 4, 6, 24, 26, C["wood_d"])
    fill_rect(img, 6, 8, 20, 22, C["paper"])
    setp(img, 16, 10, C["gold"])
    for y in (14, 17, 20, 23):
        fill_rect(img, 9, y, 14, 1, C["cream_s"])
    return outline(img)


def lamp_post() -> Image:
    img = new_image(24, 56)
    fill_rect(img, 10, 18, 4, 34, C["grey_d"])
    fill_rect(img, 11, 18, 2, 34, C["grey"])
    fill_rect(img, 4, 8, 16, 12, C["grey_d"])
    fill_rect(img, 6, 10, 12, 8, C["lamp"])
    fill_rect(img, 8, 6, 8, 3, C["grey_d"])
    return outline(img)


def flowers() -> Image:
    img = new_image(48, 32)
    fill_ellipse(img, 24, 22, 16, 6, C["soil"])
    fill_rect(img, 10, 16, 2, 8, C["leaf_d"])
    fill_rect(img, 18, 14, 2, 8, C["moss"])
    fill_rect(img, 28, 15, 2, 8, C["leaf"])
    fill_rect(img, 34, 17, 2, 7, C["leaf_d"])
    fill_rect(img, 8, 12, 4, 4, C["flower"])
    fill_rect(img, 16, 10, 4, 4, C["flower2"])
    fill_rect(img, 26, 11, 4, 4, C["cream_d"])
    fill_rect(img, 33, 13, 3, 3, C["flower"])
    setp(img, 22, 18, C["leaf_dry"])
    setp(img, 23, 19, C["leaf_dry"])
    return outline(img)


def door_mat() -> Image:
    img = new_image(48, 16)
    fill_rect(img, 2, 3, 44, 10, C["brick_d"])
    fill_rect(img, 4, 5, 40, 6, C["brick"])
    setp(img, 12, 8, C["brick_l"])
    setp(img, 30, 7, C["path_c"])
    return outline(img)


def pew() -> Image:
    img = new_image(80, 24)
    fill_rect(img, 4, 14, 72, 6, C["wood"])
    fill_rect(img, 4, 14, 72, 2, C["wood_l"])
    fill_rect(img, 4, 6, 72, 4, C["wood_d"])
    fill_rect(img, 6, 8, 3, 12, C["wood_d"])
    fill_rect(img, 71, 8, 3, 12, C["wood_d"])
    fill_rect(img, 36, 10, 6, 3, C["carpet_d"])
    return outline(img)


def altar() -> Image:
    img = new_image(48, 32)
    fill_rect(img, 8, 20, 4, 8, C["wood_d"])
    fill_rect(img, 36, 20, 4, 8, C["wood_d"])
    fill_rect(img, 4, 14, 40, 8, C["wood"])
    fill_rect(img, 8, 12, 32, 4, C["paper"])
    fill_rect(img, 22, 8, 4, 6, C["gold"])
    return outline(img)


def chairs() -> Image:
    img = new_image(32, 40)
    for i, y in enumerate((8, 14, 20)):
        fill_rect(img, 6, y, 20, 3, C["wood"])
        fill_rect(img, 6, y - 4, 3, 6, C["grey_d"])
        fill_rect(img, 23, y - 4, 3, 6, C["grey_d"])
        fill_rect(img, 8, y + 3, 2, 6, C["grey"])
        fill_rect(img, 22, y + 3, 2, 6, C["grey"])
    return outline(img)


def cross() -> Image:
    img = new_image(16, 32)
    fill_rect(img, 6, 4, 4, 24, C["wood"])
    fill_rect(img, 2, 10, 12, 4, C["wood_l"])
    return outline(img)


def window_sprite() -> Image:
    img = new_image(32, 48)
    fill_rect(img, 4, 6, 24, 36, C["wood_d"])
    fill_rect(img, 7, 10, 18, 28, C["glass_d"])
    fill_rect(img, 8, 18, 16, 8, C["glass"])
    fill_rect(img, 12, 12, 8, 8, C["carpet"])
    fill_rect(img, 15, 10, 2, 28, C["gold"])
    fill_rect(img, 7, 22, 18, 2, C["gold"])
    fill_rect(img, 10, 8, 12, 3, C["wood"])
    return outline(img)


def glow() -> Image:
    img = new_image(64, 64)
    cx = cy = 31
    for y in range(64):
        for x in range(64):
            d = ((x - cx) ** 2 + (y - cy) ** 2) ** 0.5
            if d > 31:
                continue
            # Stepped falloff so nearest filtering stays in palette.
            band = 220 if d < 6 else 160 if d < 12 else 100 if d < 18 else 55 if d < 24 else 24
            img[y][x] = (232, 196, 140, band)
    return img


def main() -> None:
    tiles = new_image(32 * 7, 32)
    for i, tile in enumerate(
        (grass_tile(False), grass_tile(True), path_tile(), gravel_tile(), wood_tile(), carpet_tile(), plaster_tile())
    ):
        blit(tiles, tile, i * 32, 0)
    files = {
        ROOT / "assets/tilesets/grounds_atlas.png": tiles,
        ROOT / "assets/environments/church_front.png": church_front(),
        ROOT / "assets/characters/player_sheet.png": player_sheet(),
        ROOT / "assets/characters/margaret.png": margaret_sheet(),
        ROOT / "assets/props/tree.png": tree(0),
        ROOT / "assets/props/tree_b.png": tree(1),
        ROOT / "assets/props/tree_c.png": tree(2),
        ROOT / "assets/props/bench.png": bench(),
        ROOT / "assets/props/notice_board.png": notice_board(),
        ROOT / "assets/props/lamp.png": lamp_post(),
        ROOT / "assets/props/flowers.png": flowers(),
        ROOT / "assets/props/door_mat.png": door_mat(),
        ROOT / "assets/props/pew.png": pew(),
        ROOT / "assets/props/altar.png": altar(),
        ROOT / "assets/props/chairs.png": chairs(),
        ROOT / "assets/props/cross.png": cross(),
        ROOT / "assets/props/sanctuary_window.png": window_sprite(),
        ROOT / "assets/lights/soft_glow.png": glow(),
    }
    for path, img in files.items():
        write_png(path, img)
        print(f"wrote {path.relative_to(ROOT)} {len(img[0])}x{len(img)}")
    write_gpl(ROOT / "assets/source/palette/the_calling_master.gpl")
    print(f"palette colors: {len(C)}")


if __name__ == "__main__":
    main()
