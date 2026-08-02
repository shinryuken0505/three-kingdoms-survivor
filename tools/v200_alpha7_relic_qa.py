from pathlib import Path
import re
root=Path(__file__).resolve().parents[1]
main=(root/'scripts/main.gd').read_text(encoding='utf-8')
data=(root/'scripts/game_data.gd').read_text(encoding='utf-8')
checks={
 'level dict':'var relic_levels: Dictionary' in main,
 'max new cap':'MAX_NEW_RELICS_PER_CHAPTER: int = 3' in main,
 'upgrade logic':'Lv.%d → Lv.%d' in main,
 'save levels':'"relic_levels": relic_levels.duplicate(true)' in main,
 'new relics':'"dragon_scale"' in data and '"imperial_edict"' in data,
}
for k,v in checks.items(): print(('PASS' if v else 'FAIL'),k)
raise SystemExit(0 if all(checks.values()) else 1)
