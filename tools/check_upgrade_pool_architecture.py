#!/usr/bin/env python3
"""Static checks for melee/ranged upgrade-pool foundations."""

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
PROFILE = ROOT / "scripts/systems/progression/player_build_profile.gd"
FILTER = ROOT / "scripts/systems/progression/upgrade_pool_filter.gd"
TEST = ROOT / "tests/upgrade_pool_filter_test.gd"


def fail(message: str) -> None:
    print(f"[upgrade-pool-check] ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def read(path: Path) -> str:
    if not path.exists():
        fail(f"missing file: {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


def main() -> int:
    profile = read(PROFILE)
    pool_filter = read(FILTER)
    test = read(TEST)
    for token in ["class_name PlayerBuildProfile", "MELEE", "RANGED", "classify_weapon"]:
        if token not in profile:
            fail(f"profile contract missing: {token}")
    for token in ["class_name UpgradePoolFilter", "required_tags", "blocked_tags", "entry_tags", "build_offer"]:
        if token not in pool_filter:
            fail(f"filter contract missing: {token}")
    for token in ["sword", "bow", "poison_entry", "first two cards"]:
        if token not in test:
            fail(f"test coverage marker missing: {token}")
    print("[upgrade-pool-check] OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
