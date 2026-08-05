from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REQUIRED = {
    "scripts/main.gd": ["V2.0.0-alpha.20", "Alpha20DemoDirector", "alpha20_initialize_run", "alpha20_trigger_hazard"],
    "scripts/systems/demo/alpha20_demo_director.gd": ["class_name Alpha20DemoDirector", "adaptive_pressure", "pick_hazard"],
    "scripts/systems/demo/alpha20_challenge_tracker.gd": ["class_name Alpha20ChallengeTracker", "start_chapter", "progress_text"],
    "scripts/systems/demo/alpha20_demo_profile.gd": ["class_name Alpha20DemoProfile", "DEMO_CHAPTER_LIMIT"],
    "tests/alpha20_demo_polish_test.gd": ["ALPHA20_DEMO_POLISH_TEST_OK"],
    "docs/ALPHA20_DEMO_POLISH.md": ["Alpha.20", "chapter challenges"],
}

for relative, markers in REQUIRED.items():
    path = ROOT / relative
    if not path.exists():
        raise SystemExit(f"missing: {relative}")
    text = path.read_text(encoding="utf-8")
    for marker in markers:
        if marker not in text:
            raise SystemExit(f"missing marker {marker!r} in {relative}")

print("ALPHA20_DEMO_POLISH_STRUCTURE_OK")
