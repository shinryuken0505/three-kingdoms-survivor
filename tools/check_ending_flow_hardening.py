from pathlib import Path

root = Path(__file__).resolve().parents[1]
main = (root / "scripts/main.gd").read_text(encoding="utf-8")
chapter = (root / "scripts/chapter_manager.gd").read_text(encoding="utf-8")
manager = (root / "scripts/systems/ending/ending_manager.gd").read_text(encoding="utf-8")
routes = (root / "scripts/core/screen_route_registry.gd").read_text(encoding="utf-8")

checks = {
    "final boss loot before ending": 'prepare_boss_loot()\n\t\tscreen = "boss_loot"' in main,
    "finalization after loot": 'chapter_manager.is_final_chapter()' in main and 'finalize_campaign_ending()' in main,
    "transactional ending save": 'var previous_save_data: Dictionary = save_data.duplicate(true)' in main,
    "save failure retains checkpoint": 'save_data = previous_save_data' in main,
    "chapter finalization API": 'func can_finalize_campaign()' in chapter,
    "snapshot schema": 'const SNAPSHOT_VERSION: int = 2' in manager,
    "ending draw route alias": 'func draw_ending()' in main,
    "ending input route alias": 'func handle_ending_key(' in main,
    "registry ending route": 'ScreenIds.ENDING: route(&"draw_ending", &"handle_ending_key")' in routes,
}
failed = [name for name, ok in checks.items() if not ok]
if failed:
    raise SystemExit("ending flow checks failed: " + ", ".join(failed))
print("[PASS] ending flow hardening checks")
