from __future__ import annotations

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
ERRORS: list[str] = []


def require(path: str) -> Path:
    target = ROOT / path
    if not target.exists():
        ERRORS.append(f"Missing: {path}")
    return target


def main() -> int:
    required = [
        "project.godot",
        "main.tscn",
        "scripts/main.gd",
        "scripts/game_data.gd",
        "scripts/chapter_manager.gd",
        "scripts/history_event_data.gd",
        "AI_START_HERE.md",
    ]
    for item in required:
        require(item)

    main_path = ROOT / "scripts/main.gd"
    if main_path.exists():
        text = main_path.read_text(encoding="utf-8")
        required_funcs = [
            "_ready", "_input", "open_levelup", "choose_levelup",
            "spawn_hero_encounter", "weighted_hero_pick",
            "apply_history_choice", "story_adjusted_boss_definition",
            "spawn_boss", "prepare_boss_loot", "accept_boss_loot",
            "save_run_checkpoint", "continue_run_from_checkpoint",
        ]
        for name in required_funcs:
            if not re.search(rf"^func\s+{re.escape(name)}\s*\(", text, re.MULTILINE):
                ERRORS.append(f"Missing function in main.gd: {name}")

        for state in ["levelup", "hero_encounter", "history_event", "boss_loot", "victory"]:
            if f'"{state}"' not in text:
                ERRORS.append(f"Screen state not found: {state}")

    project = ROOT / "project.godot"
    if project.exists():
        cfg = project.read_text(encoding="utf-8")
        if 'run/main_scene="res://main.tscn"' not in cfg:
            ERRORS.append("project.godot main scene mismatch")
        if 'config/features=PackedStringArray("4.7"' not in cfg:
            ERRORS.append("Godot 4.7 feature marker missing")

    if ERRORS:
        print("STATIC SMOKE TEST: FAIL")
        for error in ERRORS:
            print(f"- {error}")
        return 1

    print("STATIC SMOKE TEST: PASS")
    print("Note: this is not a Godot runtime or gameplay test.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
