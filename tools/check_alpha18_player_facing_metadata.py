from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

required_files = [
    ROOT / "scripts/ui/levelup_card_metadata_layer.gd",
    ROOT / "scripts/ui/hero_ability_summary_layer.gd",
    ROOT / "scripts/data/hero_ability_layer_catalog.gd",
    ROOT / "scripts/systems/progression/progression_state_guard_layer.gd",
    ROOT / "main.tscn",
]

missing = [str(path.relative_to(ROOT)) for path in required_files if not path.exists()]
if missing:
    raise SystemExit(f"Missing Alpha.18 metadata/support files: {missing}")

scene = (ROOT / "main.tscn").read_text(encoding="utf-8")

# 這兩個浮動層曾造成 TAB 與升級畫面重疊，資料檔保留但不得掛入正式場景。
for forbidden_node in ["LevelupCardMetadataLayer", "HeroAbilitySummaryLayer", "BuildSummaryLayer"]:
    if forbidden_node in scene:
        raise SystemExit(f"Runtime scene must not mount deprecated floating UI: {forbidden_node}")

for required_node in ["LevelupPoolIntegrationLayer", "ProgressionStateGuardLayer"]:
    if required_node not in scene:
        raise SystemExit(f"main.tscn is missing required runtime node: {required_node}")

guard = (ROOT / "scripts/systems/progression/progression_state_guard_layer.gd").read_text(encoding="utf-8")
for token in ["invalid_ids", "clampi", "skill_levels.erase"]:
    if token not in guard:
        raise SystemExit(f"Progression state guard is missing token: {token}")

# 保留能力分層資料供未來內嵌式 TAB 使用，但不允許再以浮動面板直接掛載。
hero = (ROOT / "scripts/data/hero_ability_layer_catalog.gd").read_text(encoding="utf-8")
for token in ["specialization", "reserve_passive", "legacy_art"]:
    if token not in hero:
        raise SystemExit(f"Hero ability catalog is missing layer: {token}")

for path in required_files[:-1]:
    text = path.read_text(encoding="utf-8")
    if "PackedStringArray = PackedStringArray" in text:
        raise SystemExit(f"Unsafe constant expression found in {path.relative_to(ROOT)}")

print("Alpha.18 metadata/runtime mounting checks passed.")
