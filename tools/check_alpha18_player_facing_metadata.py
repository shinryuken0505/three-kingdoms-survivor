from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

required_files = [
    ROOT / "scripts/ui/levelup_card_metadata_layer.gd",
    ROOT / "scripts/ui/hero_ability_summary_layer.gd",
    ROOT / "scripts/data/hero_ability_layer_catalog.gd",
    ROOT / "main.tscn",
]

missing = [str(path.relative_to(ROOT)) for path in required_files if not path.exists()]
if missing:
    raise SystemExit(f"Missing Alpha.18 player-facing metadata files: {missing}")

scene = (ROOT / "main.tscn").read_text(encoding="utf-8")
for node_name in ["LevelupCardMetadataLayer", "HeroAbilitySummaryLayer"]:
    if node_name not in scene:
        raise SystemExit(f"main.tscn is missing {node_name}")

levelup = (ROOT / "scripts/ui/levelup_card_metadata_layer.gd").read_text(encoding="utf-8")
for token in ["主角技能", "共用被動", "新流派入口", "build_tags"]:
    if token not in levelup:
        raise SystemExit(f"Level-up metadata layer is missing token: {token}")

hero = (ROOT / "scripts/ui/hero_ability_summary_layer.gd").read_text(encoding="utf-8")
for token in ["主戰・專精", "後備・被動", "營地・傳承待解鎖", "layer_for_position"]:
    if token not in hero:
        raise SystemExit(f"Hero ability summary layer is missing token: {token}")

# 避免重複踩到已知 Godot parser 問題。
for path in required_files[:-1]:
    text = path.read_text(encoding="utf-8")
    if "PackedStringArray = PackedStringArray" in text:
        raise SystemExit(f"Unsafe constant expression found in {path.relative_to(ROOT)}")

print("Alpha.18 player-facing metadata checks passed.")
