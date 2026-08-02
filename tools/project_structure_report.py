from __future__ import annotations

from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def main() -> None:
    scripts = sorted(ROOT.glob("scripts/*.gd"))
    print(f"Project: {ROOT.name}")
    print(f"GDScript files: {len(scripts)}")
    for path in scripts:
        text = path.read_text(encoding="utf-8")
        funcs = re.findall(r"^func\s+([A-Za-z0-9_]+)\s*\(", text, re.MULTILINE)
        print(f"- {path.relative_to(ROOT)}: {len(text.splitlines())} lines, {len(funcs)} functions")
        if path.name == "main.gd":
            groups = {
                "input": [f for f in funcs if f.startswith("handle_") or f in {"_input"}],
                "draw": [f for f in funcs if f.startswith("draw_")],
                "update": [f for f in funcs if f.startswith("update_")],
                "save": [f for f in funcs if "save" in f or "checkpoint" in f],
            }
            for name, values in groups.items():
                print(f"  {name}: {len(values)}")

    for dirname in ["assets", "localization", "docs", "tools"]:
        count = sum(1 for p in (ROOT / dirname).rglob("*") if p.is_file())
        print(f"{dirname}: {count} files")


if __name__ == "__main__":
    main()
