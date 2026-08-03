#!/usr/bin/env python3
"""Static integration guard for the Alpha.17 consolidation batch."""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = [
    "scripts/core/screen_ids.gd",
    "scripts/core/screen_router.gd",
    "scripts/core/input_router.gd",
    "scripts/core/screen_route_registry.gd",
    "scripts/core/ui_input_command.gd",
    "scripts/ui/screens/intermission_layout.gd",
    "scripts/ui/screens/intermission_screen_model.gd",
    "scripts/ui/screens/intermission_input_controller.gd",
    "scripts/systems/hero/hero_roster_session.gd",
    "scripts/systems/hero/hero_roster_input_controller.gd",
    "scripts/systems/hero/hero_roster_event_applier.gd",
    "scripts/systems/hero/hero_roster_flow_coordinator.gd",
    "scripts/systems/hero/hero_roster_main_adapter.gd",
    "scripts/systems/hero/hero_roster_main_effects.gd",
    "scripts/systems/hero/recruitment_roster_coordinator.gd",
    "scripts/systems/combat/player_status_adapter.gd",
    "scripts/ui/components/status_effect_hud.gd",
    "scripts/ui/status_effect_hud_layer.gd",
    "tests/alpha17_integration_smoke_test.gd",
]


def fail(message: str) -> None:
    print(f"[alpha17-check] ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def read(relative: str) -> str:
    path = ROOT / relative
    if not path.exists():
        fail(f"missing file: {relative}")
    return path.read_text(encoding="utf-8")


def require(text: str, token: str, location: str) -> None:
    if token not in text:
        fail(f"missing token {token!r} in {location}")


def main() -> int:
    for relative in REQUIRED_FILES:
        read(relative)

    scene = read("main.tscn")
    require(scene, "StatusEffectHudLayer", "main.tscn")
    require(scene, "res://scripts/ui/status_effect_hud_layer.gd", "main.tscn")

    registry = read("scripts/core/screen_route_registry.gd")
    for screen_id in [
        "ScreenIds.INTERMISSION",
        "ScreenIds.HERO_CONFIG",
        "ScreenIds.HERO_POSITION_PICKER",
        "ScreenIds.CONFIG_REPLACE",
    ]:
        require(registry, screen_id, "screen_route_registry.gd")

    intermission = read("scripts/ui/screens/intermission_screen_model.gd")
    require(intermission, "IntermissionLayout.build", "intermission_screen_model.gd")
    require(intermission, "IntermissionLayout.button_rects", "intermission_screen_model.gd")

    hero_flow = read("scripts/systems/hero/hero_roster_flow_coordinator.gd")
    for token in [
        "InputRouter.action_for_key",
        "HeroRosterInputController.handle",
        "HeroRosterEventApplier.apply",
        "HeroRosterLegacyBridge.legacy_from_session",
    ]:
        require(hero_flow, token, "hero_roster_flow_coordinator.gd")

    status_layer = read("scripts/ui/status_effect_hud_layer.gd")
    require(status_layer, "StatusEffectHud.draw", "status_effect_hud_layer.gd")
    require(status_layer, 'screen_id in ["game", "boss_intro"]', "status_effect_hud_layer.gd")

    smoke = read("tests/alpha17_integration_smoke_test.gd")
    for token in [
        "test_main_scene_wiring",
        "test_screen_registry",
        "test_intermission_contract",
        "test_status_hud_contract",
        "test_hero_roster_contract",
    ]:
        require(smoke, token, "alpha17_integration_smoke_test.gd")

    print(f"[alpha17-check] OK ({len(REQUIRED_FILES)} required files)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
