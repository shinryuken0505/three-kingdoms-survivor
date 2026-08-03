from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

required = [
    ROOT / "scripts/data/hero_specialization_offer_catalog.gd",
    ROOT / "scripts/systems/progression/levelup_offer_service.gd",
    ROOT / "scripts/systems/progression/levelup_pool_integration_layer.gd",
    ROOT / "scripts/ui/levelup_card_metadata_layer.gd",
    ROOT / "scripts/ui/build_summary_layer.gd",
    ROOT / "tests/hero_specialization_offer_catalog_test.gd",
]

missing = [str(path.relative_to(ROOT)) for path in required if not path.exists()]
if missing:
    raise SystemExit(f"Missing Alpha.18 specialization files: {missing}")

catalog = required[0].read_text(encoding="utf-8")
for token in ["ROLE_SKILLS", "hero_specialization", "source_hero_id", "merge_with_pool"]:
    if token not in catalog:
        raise SystemExit(f"Hero specialization catalog is missing token: {token}")

service = required[1].read_text(encoding="utf-8")
for token in ["HeroSpecializationScript", "specialization_cards", "mini(2, count)"]:
    if token not in service:
        raise SystemExit(f"Level-up offer service is missing specialization integration: {token}")

integration = required[2].read_text(encoding="utf-8")
if "hero_defs" not in integration or "heroes_value" not in integration:
    raise SystemExit("Level-up integration does not pass hero definitions")

metadata = required[3].read_text(encoding="utf-8")
for token in ["主將專精", "source_hero_name", "來源："]:
    if token not in metadata:
        raise SystemExit(f"Level-up metadata is missing specialization display: {token}")

summary = required[4].read_text(encoding="utf-8")
for token in ["路線完成度", "下一步建議", "invested_levels"]:
    if token not in summary:
        raise SystemExit(f"Build summary is missing guidance token: {token}")

for path in required:
    text = path.read_text(encoding="utf-8")
    if "PackedStringArray = PackedStringArray" in text:
        raise SystemExit(f"Unsafe constant expression found in {path.relative_to(ROOT)}")

print("Alpha.18 specialization offer checks passed.")
