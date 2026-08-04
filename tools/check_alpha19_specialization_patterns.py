from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

required = [
    ROOT / "scripts/systems/hero/active_hero_signature_effect_layer.gd",
    ROOT / "scripts/systems/combat/enemy_attack_pattern_layer.gd",
    ROOT / "scripts/ui/combat_diagnostics_layer.gd",
    ROOT / "main.tscn",
]

missing = [str(path.relative_to(ROOT)) for path in required if not path.exists()]
if missing:
    raise SystemExit(f"Missing Alpha.19 specialization/pattern files: {missing}")

signature = required[0].read_text(encoding="utf-8")
for token in [
    "huatuo",
    "caocao",
    "zhangjiao",
    "taishici",
    "guanyu",
    "zhangfei",
    "_last_cast_key",
]:
    if token not in signature:
        raise SystemExit(f"Hero signature layer missing token: {token}")

patterns = required[1].read_text(encoding="utf-8")
for token in [
    "crossbow",
    "firepot",
    "spearman",
    "assassin",
    "caster_bind",
    "alpha19_pattern_cd",
]:
    if token not in patterns:
        raise SystemExit(f"Enemy attack pattern layer missing token: {token}")

if "_chapter_index < 2" not in patterns:
    raise SystemExit("Enemy attack patterns must remain disabled before chapter three")

hud = required[2].read_text(encoding="utf-8")
for token in [
    "debug_overlay",
    "alpha19_identity_state",
    "alpha19_reserve_passive_state",
    "alpha19_active_specialization_state",
]:
    if token not in hud:
        raise SystemExit(f"Combat diagnostics missing token: {token}")

scene = required[3].read_text(encoding="utf-8")
for node in [
    "ActiveHeroSignatureEffectLayer",
    "EnemyAttackPatternLayer",
    "CombatDiagnosticsLayer",
]:
    if node not in scene:
        raise SystemExit(f"main.tscn missing node: {node}")

unsafe = [
    "match hero_id:",
    "const PATTERNS = Dictionary(",
    "PackedStringArray = PackedStringArray",
]
for path in required[:3]:
    text = path.read_text(encoding="utf-8")
    for pattern in unsafe:
        if pattern in text:
            raise SystemExit(f"Unsafe Godot parser pattern in {path.relative_to(ROOT)}: {pattern}")

print("Alpha.19 specialization, enemy pattern, and diagnostics checks passed.")
