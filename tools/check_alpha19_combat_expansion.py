from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

files = {
    "feedback": ROOT / "scripts/systems/combat/identity_combat_feedback_layer.gd",
    "specialization": ROOT / "scripts/systems/hero/active_hero_specialization_runtime_layer.gd",
    "threat": ROOT / "scripts/systems/combat/chapter_threat_runtime_layer.gd",
    "scene": ROOT / "main.tscn",
}

for name, path in files.items():
    if not path.exists():
        raise SystemExit(f"Missing Alpha.19 combat expansion file ({name}): {path.relative_to(ROOT)}")

feedback = files["feedback"].read_text(encoding="utf-8")
for token in ["damage_arc", "return_blade", "_update_poison_feedback", "_ring_returns", "attack_speed_buff"]:
    if token not in feedback:
        raise SystemExit(f"Identity combat feedback missing token: {token}")

specialization = files["specialization"].read_text(encoding="utf-8")
for token in ["alpha19_active_specialization_state", "guanyu", "huangzhong", "zhangjiao", "hero_cd_mult", "_remove_previous"]:
    if token not in specialization:
        raise SystemExit(f"Active hero specialization missing token: {token}")

threat = files["threat"].read_text(encoding="utf-8")
for token in ["chapter_number < 3", "alpha19_threat_applied", "shoot_cd", "ability_cd", "damage_mult"]:
    if token not in threat:
        raise SystemExit(f"Chapter threat layer missing token: {token}")

scene = files["scene"].read_text(encoding="utf-8")
for node in ["IdentityCombatFeedbackLayer", "ActiveHeroSpecializationRuntimeLayer", "ChapterThreatRuntimeLayer"]:
    if node not in scene:
        raise SystemExit(f"main.tscn is missing {node}")

for path in [files["feedback"], files["specialization"], files["threat"]]:
    text = path.read_text(encoding="utf-8")
    if "PackedStringArray = PackedStringArray" in text:
        raise SystemExit(f"Unsafe constant expression in {path.relative_to(ROOT)}")
    if "match action:" in text:
        raise SystemExit(f"Unsafe script-constant match pattern risk in {path.relative_to(ROOT)}")

print("Alpha.19 combat expansion checks passed.")
