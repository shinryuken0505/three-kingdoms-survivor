#!/usr/bin/env python3
"""Lightweight structural checks for AI-assisted Godot refactors.

This does not replace Godot parsing or gameplay tests. It catches the failures that
have repeatedly occurred while patching the large main controller: duplicate
functions, missing paired screen handlers/renderers, accidental raw screen IDs,
and incomplete hero-roster integration layers.
"""

from __future__ import annotations

import re
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "scripts"
MAIN = SCRIPTS / "main.gd"

FUNC_RE = re.compile(r"^func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(", re.MULTILINE)
RAW_SCREEN_RE = re.compile(r"\bscreen\s*=\s*\"([a-z0-9_]+)\"")
CLASS_NAME_RE = re.compile(r"^class_name\s+([A-Za-z_][A-Za-z0-9_]*)", re.MULTILINE)

# Screens that historically broke because input and drawing were changed separately.
PAIRED_SCREEN_FUNCTIONS = {
    "hero_config": ("handle_hero_config_key", "draw_hero_config_screen"),
    "hero_position_picker": (
        "handle_hero_position_picker_key",
        "draw_hero_position_picker",
    ),
    "config_replace": ("handle_config_replace_key", "draw_config_replace_screen"),
    "hero_candidate": ("handle_hero_candidate_key", "draw_hero_candidate_screen"),
    "intermission": ("handle_intermission_key", "draw_intermission_screen"),
}

REQUIRED_ARCHITECTURE_FILES = {
    "scripts/core/screen_ids.gd": "ScreenIds",
    "scripts/core/localization_service.gd": "LocalizationService",
    "scripts/core/screen_router.gd": "ScreenRouter",
    "scripts/core/input_router.gd": "InputRouter",
    "scripts/systems/hero/hero_roster_manager.gd": "HeroRosterManager",
    "scripts/systems/hero/hero_roster_controller.gd": "HeroRosterController",
    "scripts/systems/hero/hero_roster_view_model.gd": "HeroRosterViewModel",
    "scripts/systems/hero/hero_roster_session.gd": "HeroRosterSession",
    "scripts/systems/hero/hero_roster_input_controller.gd": "HeroRosterInputController",
    "scripts/systems/hero/hero_roster_event_applier.gd": "HeroRosterEventApplier",
    "scripts/systems/hero/hero_roster_flow_coordinator.gd": "HeroRosterFlowCoordinator",
    "scripts/systems/hero/hero_roster_main_adapter.gd": "HeroRosterMainAdapter",
    "scripts/systems/hero/hero_roster_main_effects.gd": "HeroRosterMainEffects",
    "scripts/systems/hero/recruitment_placement_service.gd": "RecruitmentPlacementService",
    "scripts/systems/hero/recruitment_roster_coordinator.gd": "RecruitmentRosterCoordinator",
}


def fail(message: str) -> None:
    print(f"[architecture-guard] ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def check_duplicate_functions(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    counts = Counter(FUNC_RE.findall(text))
    duplicates = sorted(name for name, count in counts.items() if count > 1)
    if duplicates:
        fail(f"duplicate functions in {path.relative_to(ROOT)}: {', '.join(duplicates)}")


def check_main_screen_pairs() -> None:
    text = MAIN.read_text(encoding="utf-8")
    functions = set(FUNC_RE.findall(text))
    for screen_id, required in PAIRED_SCREEN_FUNCTIONS.items():
        missing = [name for name in required if name not in functions]
        if missing:
            fail(f"screen '{screen_id}' is missing paired functions: {', '.join(missing)}")


def report_raw_screen_ids() -> None:
    text = MAIN.read_text(encoding="utf-8")
    ids = sorted(set(RAW_SCREEN_RE.findall(text)))
    print(
        "[architecture-guard] raw screen IDs still in main.gd "
        f"({len(ids)}): {', '.join(ids)}"
    )
    # Migration is incremental. This is intentionally a report, not a failure yet.


def check_required_architecture_files() -> None:
    for relative_path, expected_class in REQUIRED_ARCHITECTURE_FILES.items():
        path = ROOT / relative_path
        if not path.exists():
            fail(f"required architecture file missing: {relative_path}")
        text = path.read_text(encoding="utf-8")
        classes = CLASS_NAME_RE.findall(text)
        if expected_class not in classes:
            fail(
                f"{relative_path} must declare class_name {expected_class}; "
                f"found: {', '.join(classes) if classes else 'none'}"
            )


def main() -> int:
    if not MAIN.exists():
        fail("scripts/main.gd not found")
    for path in sorted(SCRIPTS.rglob("*.gd")):
        check_duplicate_functions(path)
    check_required_architecture_files()
    check_main_screen_pairs()
    report_raw_screen_ids()
    print("[architecture-guard] OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
