#!/usr/bin/env python3
"""Static consistency checks for the status-effect foundation and mounted HUD."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFS = ROOT / "scripts/data/status_effect_defs.gd"
ADAPTER = ROOT / "scripts/systems/combat/player_status_adapter.gd"
PRESENTER = ROOT / "scripts/ui/components/status_effect_presenter.gd"
MANAGER = ROOT / "scripts/systems/combat/status_effect_manager.gd"
RENDERER = ROOT / "scripts/ui/components/status_effect_renderer.gd"
PAINTER = ROOT / "scripts/ui/components/status_effect_icon_painter.gd"
HUD = ROOT / "scripts/ui/components/status_effect_hud.gd"
HUD_LAYER = ROOT / "scripts/ui/status_effect_hud_layer.gd"
MAIN_SCENE = ROOT / "main.tscn"

STATUS_RE = re.compile(r'^const\s+([A-Z_]+):\s+StringName\s*=\s*&"([a-z0-9_]+)"', re.MULTILINE)


def fail(message: str) -> None:
    print(f"[status-check] ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def read(path: Path) -> str:
    if not path.exists():
        fail(f"missing file: {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


def main() -> int:
    defs_text = read(DEFS)
    adapter_text = read(ADAPTER)
    presenter_text = read(PRESENTER)
    painter_text = read(PAINTER)
    hud_text = read(HUD)
    hud_layer_text = read(HUD_LAYER)
    main_scene_text = read(MAIN_SCENE)
    read(MANAGER)
    read(RENDERER)

    statuses = {
        name: status_id
        for name, status_id in STATUS_RE.findall(defs_text)
        if name not in {"STACK_REFRESH", "STACK_ADD", "STACK_REPLACE"}
    }
    if not statuses:
        fail("no status IDs found")

    for constant, status_id in sorted(statuses.items()):
        token = f"StatusEffectDefs.{constant}"
        if token not in presenter_text:
            fail(f"presenter fallback missing for {status_id}")
        name_key = f'status.%s.name" % status_id'
        desc_key = f'status.%s.desc" % status_id'
        if name_key not in defs_text or desc_key not in defs_text:
            fail(f"translation key generation missing for {status_id}")

    required_legacy = {
        "move_slow": "SLOW",
        "control_lock": "STUN",
        "vision_obscure": "SMOKE",
    }
    for field, constant in required_legacy.items():
        expected = f'"{field}": StatusEffectDefs.{constant}'
        if expected not in adapter_text:
            fail(f"legacy mapping missing: {field} -> {constant}")

    required_hud_calls = [
        "PlayerStatusAdapter.view_models",
        "StatusEffectPresenter.present",
        "StatusEffectRenderer.above_player_layout",
        "StatusEffectRenderer.hud_layout",
        "StatusEffectIconPainter.draw_slot",
    ]
    for call in required_hud_calls:
        if call not in hud_text:
            fail(f"HUD bridge missing call: {call}")

    for status_id in ["slow", "stun", "smoke", "poison", "burn", "silence", "bleed", "vulnerable"]:
        if f'&"{status_id}"' not in painter_text:
            fail(f"procedural painter missing status branch/color: {status_id}")

    required_layer_calls = [
        "StatusEffectHud.draw",
        "StatusEffectHud.hovered_item",
        "world_to_screen",
        "LEGACY_STATUS_MASK",
    ]
    for call in required_layer_calls:
        if call not in hud_layer_text:
            fail(f"mounted HUD layer missing integration token: {call}")
    if "status_effect_hud_layer.gd" not in main_scene_text or "StatusEffectHudLayer" not in main_scene_text:
        fail("main.tscn does not mount the status HUD layer")

    print(f"[status-check] OK ({len(statuses)} statuses, HUD mounted)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
