#!/usr/bin/env python3
"""Static checks for build-aware level-up pool wiring."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "scripts/data/upgrade_card_catalog.gd"
PROFILE = ROOT / "scripts/systems/progression/player_build_profile.gd"
FILTER = ROOT / "scripts/systems/progression/upgrade_pool_filter.gd"
SERVICE = ROOT / "scripts/systems/progression/levelup_offer_service.gd"
LAYER = ROOT / "scripts/systems/progression/levelup_pool_integration_layer.gd"
SCENE = ROOT / "main.tscn"
TEST = ROOT / "tests/levelup_offer_service_test.gd"

EXPECTED_SKILLS = {
    "damage", "attack_speed", "move_speed", "max_hp", "armor", "crit",
    "magnet", "dash", "hero_cd", "projectile", "pierce", "poison",
    "multishot", "heal",
}


def fail(message: str) -> None:
    print(f"[levelup-pool] ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def read(path: Path) -> str:
    if not path.exists():
        fail(f"missing file: {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


def main() -> int:
    catalog = read(CATALOG)
    profile = read(PROFILE)
    filter_text = read(FILTER)
    service = read(SERVICE)
    layer = read(LAYER)
    scene = read(SCENE)
    read(TEST)

    ids = set(re.findall(r'^\t"([a-z0-9_]+)": \{', catalog, re.MULTILINE))
    missing = EXPECTED_SKILLS - ids
    if missing:
        fail(f"catalog missing legacy skill IDs: {sorted(missing)}")

    for weapon in ['&"blade"', '&"bow"', '&"poison"', '&"rings"']:
        if weapon not in profile:
            fail(f"weapon classification missing: {weapon}")

    for required in ["filter_candidates", "is_compatible"]:
        if required not in filter_text:
            fail(f"upgrade filter missing API: {required}")

    for required in ["UpgradeCardCatalog.decorate_pool", "UpgradePoolFilter.filter_candidates", "PlayerBuildProfile.build"]:
        if required not in service:
            fail(f"offer service missing integration call: {required}")

    if 'screen")) != "levelup"' not in layer and 'current_screen != "levelup"' not in layer:
        fail("runtime layer does not guard levelup screen")
    if '_main.set("level_choices", offer)' not in layer:
        fail("runtime layer does not apply generated offer")

    if "levelup_pool_integration_layer.gd" not in scene or "LevelupPoolIntegrationLayer" not in scene:
        fail("main.tscn does not mount level-up integration layer")

    print(f"[levelup-pool] OK ({len(ids)} classified skills, runtime layer mounted)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
