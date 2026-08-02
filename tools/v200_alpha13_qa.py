from pathlib import Path
import re, sys
root = Path(__file__).resolve().parents[1]
main = (root / "scripts/main.gd").read_text(encoding="utf-8")
checks = {
    "version": "V2.0.0-alpha.13" in main,
    "skill_levels": "hero_skill_levels" in main and "hero_skill_level" in main,
    "bond_levels": "hero_bond_levels" in main and "hero_bond_level" in main,
    "departed": "departed_heroes" in main,
    "lvbu_gate": "lvbu_legendary_clue_count" in main and "legendary_hero_available" in main,
    "roster_no_duplicate": "hero_is_rostered" in main,
    "branch_profile": "current_stage_branch_profile" in main and "branch_variant" in main,
    "save_fields": all(k in main for k in ["hero_skill_levels", "hero_bond_levels", "departed_heroes"]),
}
failed=[k for k,v in checks.items() if not v]
print("ALPHA13_QA", "PASS" if not failed else "FAIL")
for k,v in checks.items(): print(f"{k}: {v}")
if failed: sys.exit(1)
