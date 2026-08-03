#!/usr/bin/env python3
"""Static checks for Alpha.17 runtime scene wiring."""

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
SCENE = ROOT / "main.tscn"
LAYER = ROOT / "scripts/systems/hero/hero_roster_integration_layer.gd"


def fail(message: str) -> None:
    print(f"[runtime-integration] ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def main() -> int:
    scene = SCENE.read_text(encoding="utf-8")
    layer = LAYER.read_text(encoding="utf-8")
    required_scene_tokens = [
        "hero_roster_integration_layer.gd",
        "HeroRosterIntegrationLayer",
        "status_effect_hud_layer.gd",
    ]
    for token in required_scene_tokens:
        if token not in scene:
            fail(f"main.tscn missing {token}")
    required_layer_tokens = [
        "HeroRosterMainAdapter.handle_action",
        "HeroRosterMainEffects.build",
        "IntermissionInputController.handle",
        '"hero_config"',
        '"config_replace"',
        '"intermission"',
        "set_process_input(not _owns_input)",
        "save_run_checkpoint",
        "begin_next_chapter",
    ]
    for token in required_layer_tokens:
        if token not in layer:
            fail(f"integration layer missing {token}")
    print("[runtime-integration] OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
