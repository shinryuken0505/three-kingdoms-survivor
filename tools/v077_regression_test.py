#!/usr/bin/env python3
from __future__ import annotations

import re
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MAIN = (ROOT / "scripts/main.gd").read_text(encoding="utf-8-sig")
PROJECT = (ROOT / "project.godot").read_text(encoding="utf-8-sig")

checks = {
    "version": (("v0.7.7" in PROJECT and "視覺與戰場手感修正版" in PROJECT) or ("v0.7.9" in PROJECT and "重玩性第一階段版" in PROJECT) or ("v0.8.1" in PROJECT and "系統整合修正版" in PROJECT) or ("v1.0.0" in PROJECT and "完整章節測試版" in PROJECT) or ("v1.2.0" in PROJECT and "故事演出與介面最佳化版" in PROJECT) or ("v1.4.0" in PROJECT and "章回奇遇演出深化版" in PROJECT) or ("v1.5.0" in PROJECT and "亂世圖鑑收藏版" in PROJECT) or ("V1.6.0" in PROJECT and "亂世新生" in PROJECT) or ("V1.6.1" in PROJECT and "音樂情境強化Patch" in PROJECT) or ("V1.6.2" in PROJECT and "音效層級強化Patch" in PROJECT) or ("V1.6.3" in PROJECT and "穩定性與存檔強化Patch" in PROJECT) or ("V1.7.1" in PROJECT and "視覺統一與介面美編版" in PROJECT) or ("V1.7.2" in PROJECT and "武將肖像全面修正版" in PROJECT) or ("V1.7.3" in PROJECT and "戰鬥動作強化版" in PROJECT)),
    "larger battlefield": "const WORLD: Rect2 = Rect2(0.0, 0.0, 3200.0, 2200.0)" in MAIN,
    "relative sprite scale": all(token in MAIN for token in [
        "PLAYER_SPRITE_SCALE: float = 1.68",
        "ENEMY_SPRITE_SCALE: float = 1.34",
        "ELITE_SPRITE_SCALE: float = 1.70",
        "BOSS_SPRITE_SCALE: float = 2.72",
    ]),
    "farther spawns": "rng.randf_range(650.0, 880.0)" in MAIN and "Vector2(480.0, 0.0)" in MAIN,
    "persistent facing": '"facing": Vector2.RIGHT' in MAIN and 'player["facing"] = dir' in MAIN,
    "outward blade origin": 'var attack_origin: Vector2 = player["pos"] + dir * 34.0' in MAIN,
    "outward blade visual": '"pos": attack_origin + dir * 14.0' in MAIN,
    "outward Zhang Fei": '"kind": "shockwave_visual"' in MAIN and "shock_radius: float = lerp(24.0" in MAIN,
    "visual cleanup": '"shockwave_visual"' in MAIN[MAIN.find("func update_zones"):MAIN.find("func draw_world") if MAIN.find("func draw_world") > MAIN.find("func update_zones") else len(MAIN)],
    "save version": "const CHECKPOINT_VERSION: int = 3" in MAIN,
}
for name, ok in checks.items():
    if not ok:
        raise SystemExit(f"V077_REGRESSION_FAIL: {name}")

# Every block opener must have an indented body. This catches the class of accidental
# misindentation that previously broke a CanvasItem draw call inside a match arm.
lines = MAIN.splitlines()
for i, raw in enumerate(lines):
    stripped = raw.strip()
    if not stripped or stripped.startswith("#") or not stripped.endswith(":"):
        continue
    # Quoted keys ending with a colon may be multiline Dictionary entries.
    # Known modified match arms are checked explicitly below.
    if re.match(r'^["\'][^"\']+["\']\s*:$', stripped):
        continue
    indent = len(raw) - len(raw.lstrip("\t"))
    j = i + 1
    while j < len(lines) and (not lines[j].strip() or lines[j].lstrip().startswith("#")):
        j += 1
    if j >= len(lines):
        raise SystemExit(f"V077_REGRESSION_FAIL: empty suite after line {i+1}")
    next_indent = len(lines[j]) - len(lines[j].lstrip("\t"))
    if next_indent <= indent:
        raise SystemExit(
            f"V077_REGRESSION_FAIL: body not indented after line {i+1}: {stripped}"
        )


# Explicitly verify the modified match-arm bodies are indented.
for arm in ['"slash_visual":', '"shockwave_visual":']:
    indexes = [i for i, line in enumerate(lines) if line.strip() == arm]
    if not indexes:
        raise SystemExit(f"V077_REGRESSION_FAIL: missing match arm {arm}")
    for i in indexes:
        arm_indent = len(lines[i]) - len(lines[i].lstrip("\t"))
        j = i + 1
        while j < len(lines) and (not lines[j].strip() or lines[j].lstrip().startswith("#")):
            j += 1
        body_indent = len(lines[j]) - len(lines[j].lstrip("\t"))
        if body_indent <= arm_indent:
            raise SystemExit(f"V077_REGRESSION_FAIL: unindented body for {arm} at line {i+1}")

# Verify starter portraits do not contain a near-black slab over the central lower face.
# Hair is outside this ROI; a solid mask across half the face would exceed the threshold.
for ident in ["swordsman", "hunter", "poisoner", "heroine"]:
    p = ROOT / "assets" / "portraits" / f"{ident}_default.png"
    with Image.open(p).convert("RGBA") as im:
        if im.size != (256, 320):
            raise SystemExit(f"V077_REGRESSION_FAIL: {ident} portrait size {im.size}")
        roi = im.crop((100, 120, 156, 188))
        pixels = list(roi.getdata())
        opaque = [px for px in pixels if px[3] > 200]
        near_black = [px for px in opaque if max(px[:3]) < 42]
        ratio = len(near_black) / max(1, len(opaque))
        if ratio > 0.12:
            raise SystemExit(
                f"V077_REGRESSION_FAIL: {ident} central face near-black ratio {ratio:.3f}"
            )

# Updated battle sprites remain 4-frame horizontal sheets.
for ident in ["swordsman", "hunter", "poisoner", "heroine", "liubei", "guanyu", "zhangfei", "lvbu"]:
    p = ROOT / "assets" / "sprites" / f"{ident}_default.png"
    with Image.open(p) as im:
        if im.size != (256, 64):
            raise SystemExit(f"V077_REGRESSION_FAIL: {ident} sprite sheet size {im.size}")
        if im.mode != "RGBA":
            raise SystemExit(f"V077_REGRESSION_FAIL: {ident} sprite mode {im.mode}")

# Guard the exact previous parser regression.
def call_arg_counts(text: str, name: str):
    token = name + "("
    pos = 0
    while True:
        start = text.find(token, pos)
        if start < 0:
            return
        i = start + len(token)
        depth = 1
        quote = None
        escaped = False
        j = i
        while j < len(text) and depth:
            ch = text[j]
            if quote:
                if escaped:
                    escaped = False
                elif ch == "\\":
                    escaped = True
                elif ch == quote:
                    quote = None
            else:
                if ch in ("'", '"'):
                    quote = ch
                elif ch in "([{":
                    depth += 1
                elif ch in ")]} ":
                    if ch != " ":
                        depth -= 1
            j += 1
        if depth:
            raise SystemExit(f"V077_REGRESSION_FAIL: unterminated {name} call")
        args = text[i:j-1]
        top = 0
        quote = None
        escaped = False
        commas = 0
        for ch in args:
            if quote:
                if escaped:
                    escaped = False
                elif ch == "\\":
                    escaped = True
                elif ch == quote:
                    quote = None
            else:
                if ch in ("'", '"'):
                    quote = ch
                elif ch in "([{":
                    top += 1
                elif ch in ")]}":
                    top -= 1
                elif ch == "," and top == 0:
                    commas += 1
        yield 0 if not args.strip() else commas + 1
        pos = j

for func, minimum in {"draw_texture_rect": 3, "draw_texture_rect_region": 4, "draw_arc": 6, "draw_circle": 3}.items():
    for argc in call_arg_counts(MAIN, func):
        if argc < minimum:
            raise SystemExit(f"V077_REGRESSION_FAIL: {func} has {argc} args, needs {minimum}")

print("V077_REGRESSION_OK")
for name in checks:
    print(" -", name)
