from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

required = {
    "hud": ROOT / "scripts/ui/combat_feedback_hud_layer.gd",
    "shockwave": ROOT / "scripts/systems/hero/zhangfei_shockwave_runtime_layer.gd",
    "tactics": ROOT / "scripts/systems/combat/enemy_tactics_runtime_layer.gd",
    "scene": ROOT / "main.tscn",
}

for name, path in required.items():
    if not path.exists():
        raise SystemExit(f"Missing Alpha.19 combat feedback file ({name}): {path.relative_to(ROOT)}")

hud = required["hud"].read_text(encoding="utf-8")
for token in ["DASH_RECT", "BOSS_WARNING_RECT", "dash_timer", "shield_break", "boss_ability_banner"]:
    if token not in hud:
        raise SystemExit(f"Combat feedback HUD is missing token: {token}")

shockwave = required["shockwave"].read_text(encoding="utf-8")
for token in ["zhangfei", "previous_radius", "hit_uids", "damage_enemy", "damage_boss", "knock"]:
    if token not in shockwave:
        raise SystemExit(f"Zhang Fei shockwave is missing token: {token}")

if "_cast_active = is_zhangfei" not in shockwave:
    raise SystemExit("Zhang Fei shockwave does not guard against duplicate cast detection")

tactics = required["tactics"].read_text(encoding="utf-8")
for token in ["alpha19_tactic_ready", "volley_", "area_denial", "control_support", "flanker", "formation_core"]:
    if token not in tactics:
        raise SystemExit(f"Enemy tactics layer is missing token: {token}")

scene = required["scene"].read_text(encoding="utf-8")
for node in ["CombatFeedbackHudLayer", "ZhangfeiShockwaveRuntimeLayer", "EnemyTacticsRuntimeLayer"]:
    if node not in scene:
        raise SystemExit(f"main.tscn is missing {node}")

unsafe = [
    "PackedStringArray = PackedStringArray",
    "match action:\n\t\tProfileScript.",
]
for path in required.values():
    text = path.read_text(encoding="utf-8")
    for pattern in unsafe:
        if pattern in text:
            raise SystemExit(f"Unsafe Godot parser pattern in {path.relative_to(ROOT)}: {pattern}")

print("Alpha.19 combat feedback checks passed.")
