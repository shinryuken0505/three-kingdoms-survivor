from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

required = [
    ROOT / "scripts/data/chapter_identity_catalog.gd",
    ROOT / "scripts/systems/world/chapter_identity_runtime_layer.gd",
    ROOT / "scripts/systems/combat/boss_phase_runtime_layer.gd",
    ROOT / "tests/chapter_identity_catalog_test.gd",
    ROOT / "main.tscn",
]

missing = [str(path.relative_to(ROOT)) for path in required if not path.exists()]
if missing:
    raise SystemExit(f"Missing Alpha.20 files: {missing}")

catalog = required[0].read_text(encoding="utf-8")
for token in [
    "yellow_turban",
    "luoyang",
    "hulao",
    "xuzhou",
    "guandu",
    "jingzhou",
    "changban",
    "red_cliff",
    "event_a",
    "event_b",
    "boss_phase_damage",
]:
    if token not in catalog:
        raise SystemExit(f"Chapter identity catalog missing token: {token}")

runtime = required[1].read_text(encoding="utf-8")
for token in [
    "alpha20_chapter_identity_applied",
    "_update_battle_events",
    "_apply_first_event",
    "_apply_second_event",
    "current_index_value",
]:
    if token not in runtime:
        raise SystemExit(f"Chapter identity runtime missing token: {token}")

boss = required[2].read_text(encoding="utf-8")
for token in [
    "ratio <= 0.65",
    "ratio <= 0.35",
    "alpha20_phase",
    "_spawn_phase_warnings",
    "_apply_history_consequence",
]:
    if token not in boss:
        raise SystemExit(f"Boss phase runtime missing token: {token}")

scene = required[4].read_text(encoding="utf-8")
for node in ["ChapterIdentityRuntimeLayer", "BossPhaseRuntimeLayer"]:
    if node not in scene:
        raise SystemExit(f"main.tscn missing {node}")

unsafe = [
    "PackedStringArray = PackedStringArray",
    "match action:\n\t\tCatalogScript.",
]
for path in required[:3]:
    text = path.read_text(encoding="utf-8")
    for pattern in unsafe:
        if pattern in text:
            raise SystemExit(f"Unsafe Godot parser pattern in {path.relative_to(ROOT)}: {pattern}")

print("Alpha.20 chapter identity checks passed.")
