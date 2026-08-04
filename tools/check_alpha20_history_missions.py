from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

history_path = ROOT / "scripts/systems/world/history_consequence_runtime_layer.gd"
mission_path = ROOT / "scripts/systems/world/chapter_mission_runtime_layer.gd"
scene_path = ROOT / "main.tscn"

for path in [history_path, mission_path, scene_path]:
    if not path.exists():
        raise SystemExit(f"Missing Alpha.20 history/mission file: {path.relative_to(ROOT)}")

history = history_path.read_text(encoding="utf-8")
for token in [
    "saved_civilians",
    "three_heroes_challenge",
    "wenji_return",
    "fire_plan",
    "merchant_spawn_timer",
    "hero_spawn_timer",
    "alpha20_history_wave_applied",
]:
    if token not in history:
        raise SystemExit(f"History consequence layer missing token: {token}")

mission = mission_path.read_text(encoding="utf-8")
for token in [
    "_trigger_guandu",
    "_trigger_changban",
    "_trigger_red_cliff",
    "alpha20_chapter_recap",
    "mission_a",
    "mission_b",
    "_trigger_chain_fire",
]:
    if token not in mission:
        raise SystemExit(f"Chapter mission layer missing token: {token}")

if "_chapter_index not in [4, 6, 7]" not in mission:
    raise SystemExit("Chapter missions are not limited to Guandu, Changban and Red Cliff")
if "_mission_done" not in mission or "_applied" not in history:
    raise SystemExit("Alpha.20 event deduplication is missing")
if "while zones.size() > 70" not in mission:
    raise SystemExit("Red Cliff fire zones are missing a performance cap")

scene = scene_path.read_text(encoding="utf-8")
for node_name in ["HistoryConsequenceRuntimeLayer", "ChapterMissionRuntimeLayer"]:
    if node_name not in scene:
        raise SystemExit(f"main.tscn is missing {node_name}")

unsafe_patterns = [
    "PackedStringArray = PackedStringArray",
    "const FLAGS: Dictionary = Dictionary(",
]
for pattern in unsafe_patterns:
    if pattern in history or pattern in mission:
        raise SystemExit(f"Unsafe Godot parser pattern found: {pattern}")

print("Alpha.20 history consequences and chapter missions checks passed.")
