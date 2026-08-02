from pathlib import Path
import re
root = Path(__file__).resolve().parents[1]
main = (root / "scripts/main.gd").read_text(encoding="utf-8")
defs = set(re.findall(r"^func\s+([A-Za-z_]\w*)\s*\(", main, re.M))
required = {
    "apply_poison", "spread_poison", "damage_enemy", "damage_boss",
    "update_player_shots", "update_zones", "open_history_event",
    "apply_history_choice", "update_performance_guard", "rebuild_enemy_spatial_index",
    "save_run_checkpoint", "continue_run_from_checkpoint"
}
missing = sorted(required - defs)
if missing:
    raise SystemExit("MISSING_REQUIRED_FUNCTIONS: " + ", ".join(missing))
print("FUNCTION_REGRESSION_CHECK_OK")
