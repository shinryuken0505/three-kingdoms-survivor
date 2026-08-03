from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REQUIRED = [
    "scripts/data/hero_ability_layer_catalog.gd",
    "scripts/systems/hero/recruitment_placement_service.gd",
    "scripts/systems/hero/recruitment_roster_coordinator.gd",
    "scripts/systems/hero/recruitment_roster_guard_layer.gd",
    "tests/hero_ability_layer_catalog_test.gd",
]


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    for relative in REQUIRED:
        require((ROOT / relative).exists(), f"missing Alpha.18 hero/recruitment file: {relative}")

    scene = (ROOT / "main.tscn").read_text(encoding="utf-8")
    require("RecruitmentRosterGuardLayer" in scene, "recruitment roster guard is not mounted")
    require("recruitment_roster_guard_layer.gd" in scene, "recruitment roster guard script missing from scene")

    catalog = (ROOT / "scripts/data/hero_ability_layer_catalog.gd").read_text(encoding="utf-8")
    for token in ["specialization", "reserve_passive", "legacy_art", "build_tags"]:
        require(token in catalog, f"hero ability catalog missing token: {token}")

    coordinator = (ROOT / "scripts/systems/hero/recruitment_roster_coordinator.gd").read_text(encoding="utf-8")
    require("PlacementServiceScript" in coordinator, "recruitment coordinator must preload placement service")
    require("match action:" not in coordinator, "recruitment coordinator still uses unsafe match patterns")

    guard = (ROOT / "scripts/systems/hero/recruitment_roster_guard_layer.gd").read_text(encoding="utf-8")
    for token in ["normalize", "known_heroes", "hero_skill_levels", "hero_bond_levels", "hero_cooldowns"]:
        require(token in guard, f"recruitment guard missing initialization token: {token}")

    print("Alpha.18 hero ability and recruitment checks passed")


if __name__ == "__main__":
    main()
