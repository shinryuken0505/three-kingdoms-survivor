from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

profile_path = ROOT / "scripts/systems/combat/identity_combat_profile.gd"
runtime_path = ROOT / "scripts/systems/combat/identity_combat_runtime_layer.gd"
reserve_service_path = ROOT / "scripts/systems/hero/reserve_passive_service.gd"
reserve_runtime_path = ROOT / "scripts/systems/hero/reserve_passive_runtime_layer.gd"
scene_path = ROOT / "main.tscn"
test_paths = [
    ROOT / "tests/identity_combat_profile_test.gd",
    ROOT / "tests/reserve_passive_service_test.gd",
]

for path in [profile_path, runtime_path, reserve_service_path, reserve_runtime_path, scene_path, *test_paths]:
    if not path.exists():
        raise SystemExit(f"Missing Alpha.19 combat file: {path.relative_to(ROOT)}")

profile = profile_path.read_text(encoding="utf-8")
for token in ["blade", "bow", "poison", "rings", "spread_stack_threshold", "multishot_thresholds"]:
    if token not in profile:
        raise SystemExit(f"Identity combat profile missing token: {token}")

runtime = runtime_path.read_text(encoding="utf-8")
for token in [
    "_remove_previous_adjustments",
    "alpha19_identity_state",
    "_update_poison_spread",
    "_blade_counter_timer",
    "_ring_combo",
]:
    if token not in runtime:
        raise SystemExit(f"Identity combat runtime missing token: {token}")

if 'player["damage"] = float(player.get("damage", 1.0)) *' not in runtime:
    raise SystemExit("Identity combat runtime is not applying real player damage changes")
if 'player["poison_power"]' not in runtime or 'player["projectile_mult"]' not in runtime:
    raise SystemExit("Identity combat runtime is not applying poison/projectile changes")

reserve_service = reserve_service_path.read_text(encoding="utf-8")
for token in ["PASSIVES", "CAPS", "aggregate", "sources"]:
    if token not in reserve_service:
        raise SystemExit(f"Reserve passive service missing token: {token}")
reserve_runtime = reserve_runtime_path.read_text(encoding="utf-8")
for token in ["_remove_previous", "alpha19_reserve_state", "hero_cd_mult", "attack_interval"]:
    if token not in reserve_runtime:
        raise SystemExit(f"Reserve passive runtime missing token: {token}")

scene = scene_path.read_text(encoding="utf-8")
for node_name in ["IdentityCombatRuntimeLayer", "ReservePassiveRuntimeLayer"]:
    if node_name not in scene:
        raise SystemExit(f"main.tscn is missing {node_name}")

unsafe_patterns = [
    'const PROFILES: Dictionary = Dictionary(',
    'match action:\n\t\tProfileScript.',
]
for path in [profile_path, runtime_path, reserve_service_path, reserve_runtime_path]:
    text = path.read_text(encoding="utf-8")
    for pattern in unsafe_patterns:
        if pattern in text:
            raise SystemExit(f"Unsafe Godot parser pattern found in {path.relative_to(ROOT)}: {pattern}")

print("Alpha.19 identity combat and reserve passive checks passed.")
