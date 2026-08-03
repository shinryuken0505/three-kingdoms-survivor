from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = [
    "scripts/data/identity_upgrade_path_catalog.gd",
    "scripts/systems/progression/levelup_offer_service.gd",
    "scripts/ui/build_summary_layer.gd",
    "tests/identity_upgrade_path_catalog_test.gd",
]

REQUIRED_WEAPONS = ["blade", "bow", "poison", "rings"]
REQUIRED_SCENE_MARKERS = [
    "BuildSummaryLayer",
    "res://scripts/ui/build_summary_layer.gd",
    "LevelupPoolIntegrationLayer",
]


def fail(message: str) -> None:
    raise SystemExit(f"Alpha.18 upgrade path check failed: {message}")


def main() -> None:
    for relative in REQUIRED_FILES:
        if not (ROOT / relative).is_file():
            fail(f"missing {relative}")

    catalog = (ROOT / "scripts/data/identity_upgrade_path_catalog.gd").read_text(encoding="utf-8")
    for weapon in REQUIRED_WEAPONS:
        if f'"{weapon}"' not in catalog:
            fail(f"missing weapon path: {weapon}")
    for marker in ["primary", "secondary", "blocked", "path_priority", "source_label"]:
        if marker not in catalog:
            fail(f"catalog missing marker: {marker}")

    service = (ROOT / "scripts/systems/progression/levelup_offer_service.gd").read_text(encoding="utf-8")
    for marker in ["IdentityPathScript.decorate_pool", "build_summary", "_take_unique"]:
        if marker not in service:
            fail(f"service missing integration: {marker}")

    scene = (ROOT / "main.tscn").read_text(encoding="utf-8")
    for marker in REQUIRED_SCENE_MARKERS:
        if marker not in scene:
            fail(f"scene missing marker: {marker}")

    print("Alpha.18 upgrade path architecture OK")


if __name__ == "__main__":
    main()
