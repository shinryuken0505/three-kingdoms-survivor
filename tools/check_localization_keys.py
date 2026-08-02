#!/usr/bin/env python3
"""Check that all PO catalogs expose the same msgid set.

This is intentionally dependency-free so it can run in GitHub Actions and locally.
It ignores the empty PO header msgid and reports missing/extra keys per locale.
"""
from __future__ import annotations

import ast
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOGS = {
    "zh_TW": ROOT / "localization" / "game.zh_TW.po",
    "zh_CN": ROOT / "localization" / "game.zh_CN.po",
    "en": ROOT / "localization" / "game.en.po",
    "ja": ROOT / "localization" / "game.ja.po",
}


def parse_msgids(path: Path) -> set[str]:
    if not path.exists():
        raise FileNotFoundError(path)
    keys: set[str] = set()
    collecting = False
    current = ""
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if line.startswith("msgid "):
            if collecting and current:
                keys.add(current)
            collecting = True
            current = ast.literal_eval(line[6:].strip())
            continue
        if collecting and line.startswith('"'):
            current += ast.literal_eval(line)
            continue
        if collecting and line.startswith("msgstr"):
            if current:
                keys.add(current)
            collecting = False
            current = ""
    if collecting and current:
        keys.add(current)
    keys.discard("")
    return keys


def main() -> int:
    try:
        parsed = {locale: parse_msgids(path) for locale, path in CATALOGS.items()}
    except (OSError, SyntaxError, ValueError) as exc:
        print(f"Localization parse error: {exc}", file=sys.stderr)
        return 2

    reference = parsed["zh_TW"]
    failed = False
    for locale, keys in parsed.items():
        missing = sorted(reference - keys)
        extra = sorted(keys - reference)
        if missing or extra:
            failed = True
            print(f"[{locale}] key mismatch")
            if missing:
                print("  missing:")
                for key in missing:
                    print(f"    - {key}")
            if extra:
                print("  extra:")
                for key in extra:
                    print(f"    + {key}")
        else:
            print(f"[{locale}] OK ({len(keys)} keys)")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
