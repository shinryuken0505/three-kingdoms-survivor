#!/usr/bin/env python3
"""Static checks for screen routing, UI commands, and intermission composition."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCREEN_IDS = ROOT / "scripts/core/screen_ids.gd"
ROUTES = ROOT / "scripts/core/screen_route_registry.gd"
COMMANDS = ROOT / "scripts/core/ui_input_command.gd"
INTERMISSION_LAYOUT = ROOT / "scripts/ui/screens/intermission_layout.gd"
INTERMISSION_MODEL = ROOT / "scripts/ui/screens/intermission_screen_model.gd"
TEST = ROOT / "tests/navigation_architecture_test.gd"

ID_RE = re.compile(r'^const\s+([A-Z_]+):\s+StringName\s*=\s*&"([a-z0-9_]+)"', re.MULTILINE)


def fail(message: str) -> None:
    print(f"[navigation-check] ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def read(path: Path) -> str:
    if not path.exists():
        fail(f"missing file: {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


def main() -> int:
    ids_text = read(SCREEN_IDS)
    routes_text = read(ROUTES)
    commands_text = read(COMMANDS)
    model_text = read(INTERMISSION_MODEL)
    read(INTERMISSION_LAYOUT)
    test_text = read(TEST)

    screen_constants = [name for name, _ in ID_RE.findall(ids_text)]
    if not screen_constants:
        fail("no screen IDs found")
    for constant in screen_constants:
        token = f"ScreenIds.{constant}: route("
        if token not in routes_text:
            fail(f"route missing for ScreenIds.{constant}")

    for command in ["UP", "DOWN", "LEFT", "RIGHT", "CONFIRM", "CANCEL", "TAB", "PAUSE"]:
        if f"const {command}: StringName" not in commands_text:
            fail(f"UI command missing: {command}")

    required_model_calls = [
        "IntermissionLayout.build",
        "IntermissionLayout.button_rects",
        "TextLayout.row_rects",
        "move_selection",
        "action_at",
    ]
    for call in required_model_calls:
        if call not in model_text:
            fail(f"intermission model missing: {call}")

    for coverage in ["_test_intermission_model", "_test_screen_routes", "_test_input_commands"]:
        if coverage not in test_text:
            fail(f"test coverage missing: {coverage}")

    print(f"[navigation-check] OK ({len(screen_constants)} screen routes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
