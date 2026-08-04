from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

profile_path = ROOT / "scripts/systems/combat/identity_combat_profile.gd"
runtime_path = ROOT / "scripts/systems/combat/identity_combat_runtime_layer.gd"
scene_path = ROOT / "main.tscn"
test_path = ROOT / "tests/identity_combat_profile_test.gd"

for path in [profile_path, runtime_path, scene_path, test_path]:
    if not path.exists():
        raise SystemExit(f"Missing Alpha.19 identity combat file: {path.relative_to(ROOT)}")

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

scene = scene_path.read_text(encoding="utf-8")
if "IdentityCombatRuntimeLayer" not in scene:
    raise SystemExit("main.tscn is missing IdentityCombatRuntimeLayer")

unsafe_patterns = [
    'const PROFILES: Dictionary = Dictionary(',
    'match action:\n\t\tProfileScript.',
]
for pattern in unsafe_patterns:
    if pattern in profile or pattern in runtime:
        raise SystemExit(f"Unsafe Godot parser pattern found: {pattern}")

print("Alpha.19 identity combat checks passed.")
