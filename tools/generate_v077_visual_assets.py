from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Literal

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
PORTRAITS = ROOT / "assets" / "portraits"
SPRITES = ROOT / "assets" / "sprites"


@dataclass(frozen=True)
class CharacterStyle:
    key: str
    bg: tuple[int, int, int]
    accent: tuple[int, int, int]
    cloth: tuple[int, int, int]
    dark: tuple[int, int, int]
    skin: tuple[int, int, int]
    hair: tuple[int, int, int]
    weapon: Literal["blade", "bow", "needle", "rings", "spear"]
    hair_style: Literal["short", "hood", "bun", "long", "wild", "crown"]
    feminine: bool = False
    beard: bool = False


STYLES = [
    CharacterStyle(
        "swordsman", (42, 35, 25), (218, 173, 92), (112, 75, 43),
        (43, 30, 23), (221, 160, 113), (35, 26, 22), "blade", "short"
    ),
    CharacterStyle(
        "hunter", (25, 50, 44), (166, 215, 188), (43, 91, 73),
        (24, 40, 36), (220, 159, 112), (31, 25, 22), "bow", "hood"
    ),
    CharacterStyle(
        "poisoner", (35, 54, 24), (181, 224, 128), (64, 101, 48),
        (29, 47, 27), (218, 158, 112), (28, 25, 24), "needle", "bun"
    ),
    CharacterStyle(
        "heroine", (52, 31, 54), (232, 174, 190), (112, 54, 94),
        (45, 27, 48), (235, 170, 132), (29, 20, 34), "rings", "long", True
    ),
    CharacterStyle(
        "liubei", (24, 49, 40), (220, 192, 112), (52, 91, 70),
        (28, 46, 39), (215, 151, 103), (28, 24, 22), "blade", "crown", False, True
    ),
    CharacterStyle(
        "guanyu", (20, 55, 43), (205, 163, 70), (38, 91, 66),
        (25, 45, 34), (198, 132, 88), (20, 17, 16), "spear", "crown", False, True
    ),
    CharacterStyle(
        "zhangfei", (64, 37, 30), (214, 101, 65), (111, 55, 44),
        (40, 25, 21), (190, 119, 75), (19, 16, 14), "spear", "wild", False, True
    ),
    CharacterStyle(
        "lvbu", (67, 26, 31), (232, 175, 67), (135, 44, 53),
        (42, 20, 24), (209, 138, 91), (22, 14, 16), "spear", "crown", False, True
    ),
]


def mix(a: tuple[int, int, int], b: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    return tuple(round(a[i] * (1.0 - t) + b[i] * t) for i in range(3))


def rgba(c: tuple[int, int, int], a: int = 255) -> tuple[int, int, int, int]:
    return c[0], c[1], c[2], a


def draw_portrait(style: CharacterStyle) -> None:
    # Work at 128x160 and enlarge with nearest-neighbour pixels.
    image = Image.new("RGBA", (128, 160), rgba(style.bg))
    draw = ImageDraw.Draw(image, "RGBA")

    # Background: subtle sun disc, clouds, and ground shapes.
    draw.ellipse((31, 9, 101, 79), fill=rgba(style.accent, 24), outline=rgba(style.accent, 90), width=2)
    for x, y, r in [(12, 34, 8), (108, 25, 6), (16, 65, 4), (112, 72, 9)]:
        draw.ellipse((x-r, y-r, x+r, y+r), fill=rgba(mix(style.bg, (245, 236, 211), 0.38), 70))
    draw.polygon([(0, 112), (18, 91), (36, 110), (54, 83), (78, 111), (101, 88), (128, 110), (128, 160), (0, 160)], fill=rgba(mix(style.bg, (0, 0, 0), 0.25), 170))

    # Cape, shoulders and layered armor.
    draw.polygon([(12, 159), (22, 102), (43, 87), (85, 87), (106, 102), (116, 159)], fill=rgba(style.dark))
    draw.rounded_rectangle((25, 91, 103, 159), radius=8, fill=rgba(style.cloth), outline=rgba(style.accent), width=2)
    draw.ellipse((15, 92, 49, 127), fill=rgba(mix(style.accent, style.cloth, 0.20)), outline=rgba(style.dark), width=2)
    draw.ellipse((79, 92, 113, 127), fill=rgba(mix(style.accent, style.cloth, 0.20)), outline=rgba(style.dark), width=2)
    draw.rectangle((39, 109, 89, 116), fill=rgba(mix(style.accent, (255, 235, 180), 0.22)))
    for x in range(40, 91, 12):
        draw.rounded_rectangle((x, 119, x + 8, 156), radius=2, fill=rgba(mix(style.cloth, style.dark, 0.18)), outline=rgba(style.accent, 170))

    # Neck and face. The only shadow is a narrow translucent cheek strip—not a mask.
    draw.rectangle((55, 76, 73, 96), fill=rgba(style.skin))
    draw.ellipse((39, 31, 89, 88), fill=rgba(style.hair))
    draw.ellipse((43, 37, 85, 88), fill=rgba(style.skin), outline=rgba(mix(style.skin, style.dark, 0.55)), width=1)
    draw.polygon([(76, 43), (84, 51), (83, 78), (76, 86), (72, 80), (75, 63)], fill=rgba(mix(style.skin, style.dark, 0.18), 105))
    draw.ellipse((39, 55, 47, 68), fill=rgba(style.skin))
    draw.ellipse((81, 55, 89, 68), fill=rgba(style.skin))

    # Hair silhouette and ornaments.
    if style.hair_style == "short":
        draw.polygon([(41, 45), (45, 28), (53, 21), (64, 25), (73, 20), (84, 31), (87, 46), (80, 42), (72, 36), (61, 43), (50, 36)], fill=rgba(style.hair))
    elif style.hair_style == "hood":
        draw.arc((32, 20, 96, 99), 185, 355, fill=rgba(style.accent), width=7)
        draw.polygon([(37, 45), (45, 27), (52, 42)], fill=rgba(style.accent))
        draw.polygon([(91, 45), (83, 27), (76, 42)], fill=rgba(style.accent))
        draw.polygon([(42, 42), (49, 25), (62, 37), (72, 25), (86, 42), (79, 45), (49, 45)], fill=rgba(style.hair))
    elif style.hair_style == "bun":
        draw.ellipse((55, 17, 73, 34), fill=rgba(style.hair))
        draw.polygon([(41, 45), (45, 29), (57, 23), (70, 27), (83, 24), (88, 45), (80, 42), (69, 34), (58, 42), (49, 35)], fill=rgba(style.hair))
        draw.line((64, 15, 85, 22), fill=rgba(style.accent), width=2)
    elif style.hair_style == "long":
        draw.polygon([(39, 43), (45, 25), (56, 20), (69, 24), (81, 18), (90, 38), (91, 104), (80, 97), (79, 52), (70, 38), (60, 47), (49, 36), (48, 100), (36, 106)], fill=rgba(style.hair))
        draw.ellipse((61, 15, 69, 23), fill=rgba(style.accent))
        draw.line((67, 18, 91, 11), fill=rgba(style.accent), width=2)
    elif style.hair_style == "wild":
        points = [(39, 49), (36, 34), (44, 37), (42, 24), (51, 30), (56, 17), (63, 28), (70, 16), (74, 30), (85, 23), (84, 36), (94, 35), (88, 51)]
        draw.polygon(points, fill=rgba(style.hair))
    elif style.hair_style == "crown":
        draw.polygon([(39, 45), (44, 28), (56, 23), (64, 30), (75, 21), (86, 33), (88, 46), (80, 41), (69, 35), (58, 43), (49, 35)], fill=rgba(style.hair))
        draw.polygon([(47, 31), (52, 15), (59, 26), (65, 11), (72, 26), (81, 15), (83, 34)], fill=rgba(style.accent), outline=rgba(style.dark))

    # Eyes, eyebrows, nose, mouth, blush/highlight.
    brow = mix(style.hair, (0, 0, 0), 0.2)
    draw.line((49, 55, 58, 53), fill=rgba(brow), width=2)
    draw.line((70, 53, 79, 55), fill=rgba(brow), width=2)
    eye_white = (240, 228, 211)
    draw.ellipse((49, 57, 59, 67), fill=rgba(eye_white), outline=rgba(style.dark))
    draw.ellipse((69, 57, 79, 67), fill=rgba(eye_white), outline=rgba(style.dark))
    iris = style.accent if style.feminine else mix(style.dark, style.accent, 0.25)
    draw.ellipse((53, 59, 57, 65), fill=rgba(iris))
    draw.ellipse((71, 59, 75, 65), fill=rgba(iris))
    draw.point((55, 60), fill=(255, 255, 255, 255))
    draw.point((73, 60), fill=(255, 255, 255, 255))
    draw.line((64, 61, 62, 72), fill=rgba(mix(style.skin, style.dark, 0.35)))
    draw.line((58, 78, 70, 78), fill=rgba((120, 48, 49) if style.feminine else (102, 55, 42)), width=1)
    draw.point((50, 72), fill=rgba((233, 130, 120), 130))
    draw.point((78, 72), fill=rgba((233, 130, 120), 130))

    if style.beard:
        beard_color = rgba(style.hair)
        if style.key == "guanyu":
            draw.polygon([(51, 76), (77, 76), (79, 119), (65, 139), (49, 120)], fill=beard_color)
            draw.line((58, 84, 61, 126), fill=rgba(mix(style.hair, (120, 85, 45), 0.24)), width=1)
            draw.line((69, 84, 67, 130), fill=rgba(mix(style.hair, (120, 85, 45), 0.24)), width=1)
        else:
            draw.polygon([(51, 76), (77, 76), (73, 94), (64, 101), (55, 94)], fill=beard_color)

    # Weapon silhouettes are placed to the side, never across the face.
    if style.weapon == "blade":
        draw.line((103, 84, 112, 151), fill=rgba((98, 72, 43)), width=3)
        draw.polygon([(99, 88), (107, 76), (114, 78), (109, 96)], fill=rgba((226, 226, 211)), outline=rgba(style.dark))
    elif style.weapon == "bow":
        draw.arc((5, 82, 43, 151), 270, 90, fill=rgba((133, 83, 42)), width=3)
        draw.line((24, 82, 24, 151), fill=rgba((236, 226, 193)), width=1)
        draw.line((24, 89, 39, 113), fill=rgba((236, 226, 193)), width=1)
    elif style.weapon == "needle":
        for i in range(3):
            draw.line((100 + i * 4, 99, 113 + i * 2, 72 + i * 8), fill=rgba((220, 225, 210)), width=1)
    elif style.weapon == "rings":
        draw.ellipse((4, 109, 36, 141), outline=rgba(style.accent), width=4)
        draw.ellipse((94, 109, 126, 141), outline=rgba(style.accent), width=4)
    elif style.weapon == "spear":
        draw.line((105, 66, 115, 157), fill=rgba((111, 76, 39)), width=3)
        draw.polygon([(100, 70), (111, 54), (119, 67), (111, 73)], fill=rgba((221, 222, 213)), outline=rgba(style.dark))

    # Pixel frame and highlights.
    draw.rectangle((2, 2, 125, 157), outline=rgba(style.dark), width=2)
    draw.rectangle((5, 5, 122, 154), outline=rgba(style.accent, 155), width=1)
    draw.line((28, 96, 98, 96), fill=rgba((255, 238, 185), 90), width=1)

    image.resize((256, 320), Image.Resampling.NEAREST).save(PORTRAITS / f"{style.key}_default.png")


def draw_sprite(style: CharacterStyle) -> None:
    sheet = Image.new("RGBA", (256, 64), (0, 0, 0, 0))
    draw = ImageDraw.Draw(sheet, "RGBA")
    for frame in range(4):
        ox = frame * 64
        bob = 1 if frame in (1, 3) else 0
        arm_shift = [0, 2, 0, -2][frame]
        leg_shift = [0, 1, 0, -1][frame]
        draw.ellipse((ox + 14, 51, ox + 50, 60), fill=(0, 0, 0, 80))
        draw.rectangle((ox + 21, 41 + leg_shift, ox + 28, 55 + leg_shift), fill=rgba(style.dark))
        draw.rectangle((ox + 36, 41 - leg_shift, ox + 43, 55 - leg_shift), fill=rgba(style.dark))
        draw.rectangle((ox + 19, 25 + bob, ox + 45, 45 + bob), fill=rgba(style.cloth), outline=rgba(style.dark))
        draw.rectangle((ox + 13, 28 + bob + arm_shift, ox + 21, 39 + bob + arm_shift), fill=rgba(style.accent))
        draw.rectangle((ox + 43, 28 + bob - arm_shift, ox + 51, 39 + bob - arm_shift), fill=rgba(style.accent))
        draw.rectangle((ox + 24, 14 + bob, ox + 40, 28 + bob), fill=rgba(style.skin), outline=rgba(style.dark))
        draw.point((ox + 28, 20 + bob), fill=rgba(style.dark))
        draw.point((ox + 36, 20 + bob), fill=rgba(style.dark))
        if style.hair_style == "hood":
            draw.polygon([(ox + 20, 18 + bob), (ox + 24, 8 + bob), (ox + 40, 8 + bob), (ox + 44, 18 + bob), (ox + 39, 15 + bob), (ox + 25, 15 + bob)], fill=rgba(style.accent))
        elif style.hair_style == "long":
            draw.rectangle((ox + 19, 12 + bob, ox + 25, 35 + bob), fill=rgba(style.hair))
            draw.rectangle((ox + 39, 12 + bob, ox + 45, 35 + bob), fill=rgba(style.hair))
            draw.polygon([(ox + 22, 14 + bob), (ox + 27, 7 + bob), (ox + 38, 7 + bob), (ox + 43, 14 + bob)], fill=rgba(style.hair))
            draw.point((ox + 33, 5 + bob), fill=rgba(style.accent))
        elif style.hair_style == "bun":
            draw.ellipse((ox + 28, 5 + bob, ox + 36, 13 + bob), fill=rgba(style.hair))
            draw.polygon([(ox + 21, 17 + bob), (ox + 25, 8 + bob), (ox + 32, 12 + bob), (ox + 39, 7 + bob), (ox + 44, 17 + bob)], fill=rgba(style.hair))
        elif style.hair_style == "wild":
            draw.polygon([(ox + 20, 17 + bob), (ox + 21, 8 + bob), (ox + 26, 11 + bob), (ox + 29, 4 + bob), (ox + 33, 11 + bob), (ox + 39, 5 + bob), (ox + 42, 12 + bob), (ox + 46, 9 + bob), (ox + 44, 18 + bob)], fill=rgba(style.hair))
        elif style.hair_style == "crown":
            draw.polygon([(ox + 21, 16 + bob), (ox + 25, 8 + bob), (ox + 32, 12 + bob), (ox + 39, 7 + bob), (ox + 44, 16 + bob)], fill=rgba(style.hair))
            draw.polygon([(ox + 23, 10 + bob), (ox + 27, 2 + bob), (ox + 31, 9 + bob), (ox + 35, 1 + bob), (ox + 39, 9 + bob), (ox + 43, 3 + bob), (ox + 44, 12 + bob)], fill=rgba(style.accent))
        else:
            draw.polygon([(ox + 21, 17 + bob), (ox + 23, 9 + bob), (ox + 28, 5 + bob), (ox + 33, 10 + bob), (ox + 39, 5 + bob), (ox + 44, 12 + bob), (ox + 43, 18 + bob)], fill=rgba(style.hair))

        # Armor details and weapon silhouette.
        draw.rectangle((ox + 25, 30 + bob, ox + 39, 34 + bob), fill=rgba(mix(style.accent, (255, 245, 190), 0.18)))
        if style.beard:
            draw.polygon([(ox + 26, 25 + bob), (ox + 38, 25 + bob), (ox + 36, 35 + bob), (ox + 32, 39 + bob), (ox + 28, 35 + bob)], fill=rgba(style.hair))
        if style.weapon == "blade":
            draw.line((ox + 50, 20 + bob - arm_shift, ox + 57, 49 + bob - arm_shift), fill=rgba((225, 226, 216)), width=3)
            draw.line((ox + 48, 23 + bob, ox + 53, 18 + bob), fill=rgba((116, 79, 42)), width=2)
        elif style.weapon == "bow":
            draw.arc((ox + 46, 17 + bob, ox + 62, 49 + bob), 270, 90, fill=rgba((139, 86, 43)), width=2)
            draw.line((ox + 54, 17 + bob, ox + 54, 49 + bob), fill=rgba((235, 227, 199)), width=1)
        elif style.weapon == "needle":
            draw.line((ox + 49, 27 + bob, ox + 60, 18 + bob), fill=rgba((232, 232, 220)), width=1)
            draw.line((ox + 49, 31 + bob, ox + 61, 27 + bob), fill=rgba((232, 232, 220)), width=1)
        elif style.weapon == "rings":
            draw.ellipse((ox + 5, 29 + bob, ox + 19, 43 + bob), outline=rgba(style.accent), width=2)
            draw.ellipse((ox + 45, 29 + bob, ox + 59, 43 + bob), outline=rgba(style.accent), width=2)
        elif style.weapon == "spear":
            draw.line((ox + 51, 8 + bob, ox + 56, 56 + bob), fill=rgba((111, 76, 39)), width=3)
            draw.polygon([(ox + 47, 12 + bob), (ox + 54, 3 + bob), (ox + 61, 11 + bob), (ox + 55, 15 + bob)], fill=rgba((225, 225, 214)))

    sheet.save(SPRITES / f"{style.key}_default.png")


def main() -> None:
    PORTRAITS.mkdir(parents=True, exist_ok=True)
    SPRITES.mkdir(parents=True, exist_ok=True)
    for style in STYLES:
        draw_portrait(style)
        draw_sprite(style)
    print(f"V077_VISUAL_ASSETS_OK portraits={len(STYLES)} sprites={len(STYLES)}")


if __name__ == "__main__":
    main()
