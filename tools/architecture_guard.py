#!/usr/bin/env python3
"""Lightweight structural checks for AI-assisted Godot refactors.

This does not replace Godot parsing or gameplay tests. It catches the failures that
have repeatedly occurred while patching the large main controller: duplicate
functions, missing paired screen handlers/renderers, and accidental raw screen IDs.
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
    required = [
        SCRIPTS / "core" / "screen_ids.gd",
        SCRIPTS / "core" / "localization_service.gd",
        SCRIPTS / "systems" / "hero" / "hero_roster_manager.gd",
        SCRIPTS / "systems" / "hero" / "hero_roster_controller.gd",
        SCRIPTS / "systems" / "hero" / "hero_roster_view_model.gd",
    ]
    missing = [str(path.relative_to(ROOT)) for path in required if not path.exists()]
    if missing:
        fail(f"required architecture files missing: {', '.join(missing)}")


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
