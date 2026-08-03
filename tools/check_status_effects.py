#!/usr/bin/env python3
"""Static consistency checks for the status-effect foundation."""

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

    print(f"[status-check] OK ({len(statuses)} statuses)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
