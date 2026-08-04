from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

paths = {
    "scene": ROOT / "main.tscn",
    "integration": ROOT / "scripts/systems/progression/levelup_pool_integration_layer.gd",
    "offer": ROOT / "scripts/systems/progression/levelup_offer_service.gd",
    "specialization": ROOT / "scripts/data/hero_specialization_offer_catalog.gd",
    "progression_guard": ROOT / "scripts/systems/progression/progression_state_guard_layer.gd",
    "recruitment_guard": ROOT / "scripts/systems/hero/recruitment_roster_guard_layer.gd",
    "test": ROOT / "tests/alpha18_release_contract_test.gd",
}

missing = [str(path.relative_to(ROOT)) for path in paths.values() if not path.exists()]
if missing:
    raise SystemExit(f"Missing Alpha.18 release files: {missing}")

scene = paths["scene"].read_text(encoding="utf-8")
for node in [
    "LevelupPoolIntegrationLayer",
    "ProgressionStateGuardLayer",
    "RecruitmentRosterGuardLayer",
    "IntermissionVisualLayer",
    "RecruitmentRosterVisualLayer",
]:
    if node not in scene:
        raise SystemExit(f"Release scene is missing node: {node}")

for forbidden in ["BuildSummaryLayer", "HeroAbilitySummaryLayer", "LevelupCardMetadataLayer"]:
    if forbidden in scene:
        raise SystemExit(f"Deprecated floating UI is mounted: {forbidden}")

integration = paths["integration"].read_text(encoding="utf-8")
for token in ["level_choice_ids", "get_offer_metadata", '_main.set("level_choices", level_choice_ids)']:
    if token not in integration:
        raise SystemExit(f"Level-up integration contract is missing: {token}")
if '_main.set("level_choices", offer)' in integration:
    raise SystemExit("Full card dictionaries must not be assigned to level_choices")

offer = paths["offer"].read_text(encoding="utf-8")
for token in ["hero_specializations", "specialization_taken", "_take_unique"]:
    if token not in offer:
        raise SystemExit(f"Offer balancing rule is missing: {token}")

specialization = paths["specialization"].read_text(encoding="utf-8")
for token in ["source_hero_id", "source_hero_name", "hero_specialization"]:
    if token not in specialization:
        raise SystemExit(f"Specialization catalog is missing: {token}")

for path_key in ["progression_guard", "recruitment_guard"]:
    text = paths[path_key].read_text(encoding="utf-8")
    if "extends Node" not in text:
        raise SystemExit(f"Runtime guard is malformed: {paths[path_key].relative_to(ROOT)}")

main_text = (ROOT / "scripts/main.gd").read_text(encoding="utf-8")
for bad_prefix in ["\na\t\tvar card_name", "\nS\t\tvar card_name"]:
    if bad_prefix in main_text:
        raise SystemExit("Stray character found before level-up card_name declaration")

print("Alpha.18 release contract checks passed.")
