#!/usr/bin/env python3
"""Normalize damaged portrait assets into standards-compliant PNG files.

The tool intentionally does not redraw or resize character art. It only rewrites files
whose strict Pillow decode fails or whose actual format is not PNG. For damaged PNGs,
Pillow's truncated-image recovery is used as a last-resort pixel salvage path.

Usage:
    python tools/normalize_portrait_assets.py          # diagnostic only
    python tools/normalize_portrait_assets.py --write # replace recoverable broken files
"""

from __future__ import annotations

import argparse
import hashlib
import sys
from pathlib import Path

from PIL import Image, ImageFile

ROOT = Path(__file__).resolve().parents[1]
PORTRAIT_DIR = ROOT / "assets" / "portraits"
REPORT_PATH = ROOT / "portrait-normalize-report.txt"
PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def strict_probe(path: Path) -> tuple[bool, str, tuple[int, int] | None, str]:
    try:
        with Image.open(path) as image:
            detected_format = str(image.format or "")
            size = image.size
            image.load()
        signature_ok = path.read_bytes()[:8] == PNG_SIGNATURE
        strict_ok = detected_format.upper() == "PNG" and signature_ok
        reason = "strict PNG ok" if strict_ok else f"actual format={detected_format or 'unknown'}, signature_ok={signature_ok}"
        return strict_ok, detected_format, size, reason
    except Exception as exc:  # Pillow exposes several decoder-specific exception types.
        return False, "", None, f"strict decode failed: {type(exc).__name__}: {exc}"


def salvage_to_png(path: Path, output_path: Path) -> tuple[bool, str, tuple[int, int] | None]:
    previous = ImageFile.LOAD_TRUNCATED_IMAGES
    ImageFile.LOAD_TRUNCATED_IMAGES = True
    try:
        with Image.open(path) as source:
            detected_format = str(source.format or "")
            source.load()
            size = source.size
            # Preserve pixels and alpha/palette where possible. Copy detaches from the source stream.
            image = source.copy()
        output_path.parent.mkdir(parents=True, exist_ok=True)
        image.save(output_path, format="PNG", optimize=False)
        # Require the rewritten file to pass a fresh strict decode before accepting it.
        ok, _, rewritten_size, reason = strict_probe(output_path)
        if not ok or rewritten_size != size:
            output_path.unlink(missing_ok=True)
            return False, f"rewritten verification failed: {reason}", size
        return True, f"recovered from {detected_format or 'unknown'}", size
    except Exception as exc:
        output_path.unlink(missing_ok=True)
        return False, f"salvage failed: {type(exc).__name__}: {exc}", None
    finally:
        ImageFile.LOAD_TRUNCATED_IMAGES = previous


def create_placeholder(path: Path) -> None:
    # Technical fallback only; not character artwork.
    image = Image.new("RGBA", (96, 128), (28, 30, 32, 255))
    pixels = image.load()
    for y in range(image.height):
        for x in range(image.width):
            if ((x // 16) + (y // 16)) % 2 == 0:
                pixels[x, y] = (44, 47, 50, 255)
    image.save(path, format="PNG", optimize=False)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true", help="Replace recoverable broken portrait files in-place.")
    args = parser.parse_args()

    if not PORTRAIT_DIR.is_dir():
        print(f"Portrait directory not found: {PORTRAIT_DIR}", file=sys.stderr)
        return 2

    lines: list[str] = []
    repaired: list[str] = []
    unresolved: list[str] = []
    healthy = 0

    placeholder = PORTRAIT_DIR / "placeholder.png"
    if not placeholder.exists():
        if args.write:
            create_placeholder(placeholder)
            repaired.append("placeholder.png (created technical fallback)")
            lines.append("REPAIRED placeholder.png | created technical 96x128 fallback")
        else:
            lines.append("MISSING placeholder.png | --write will create technical fallback")

    candidates = sorted(path for path in PORTRAIT_DIR.glob("*.png") if path.is_file())
    for path in candidates:
        ok, detected_format, size, reason = strict_probe(path)
        if ok:
            healthy += 1
            continue

        original_hash = sha256(path)
        temp_path = path.with_name(path.name + ".normalized.tmp.png")
        recovered, recovery_reason, recovered_size = salvage_to_png(path, temp_path)
        if not recovered:
            unresolved.append(path.name)
            lines.append(f"UNRESOLVED {path.name} | {reason} | {recovery_reason}")
            continue

        if args.write:
            temp_path.replace(path)
            repaired.append(path.name)
            new_hash = sha256(path)
            lines.append(
                f"REPAIRED {path.name} | {reason} | {recovery_reason} | "
                f"size={recovered_size} | sha256 {original_hash[:12]} -> {new_hash[:12]}"
            )
        else:
            temp_path.unlink(missing_ok=True)
            lines.append(
                f"RECOVERABLE {path.name} | {reason} | {recovery_reason} | size={recovered_size}"
            )

    summary = (
        f"Portrait normalization summary: healthy={healthy}, repaired={len(repaired)}, "
        f"unresolved={len(unresolved)}, write={args.write}"
    )
    report = "\n".join([summary, *lines, "", "Unresolved: " + (", ".join(unresolved) if unresolved else "none")]) + "\n"
    REPORT_PATH.write_text(report, encoding="utf-8")
    print(report, end="")

    # Do not fail here: Godot import/self-test is the authoritative validation. Keeping this zero-exit
    # also lets CI expose exactly which remaining asset paths Godot rejects.
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
