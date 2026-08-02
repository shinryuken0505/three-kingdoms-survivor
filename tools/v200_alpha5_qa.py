from pathlib import Path
import re, sys
root=Path(__file__).resolve().parents[1]
main=(root/'scripts/main.gd').read_text(encoding='utf-8')
data=(root/'scripts/game_data.gd').read_text(encoding='utf-8')
checks={
 'version':'V2.0.0-alpha.5' in main,
 'merchant_types':'static func merchant_types()' in data,
 'merchant_runtime':'func choose_merchant_kind()' in main and 'merchant_kind' in main,
 'first_clear':'first_clear' in main and 'boss_defeat_counts' in main,
 'equipment_metadata':all(x in data for x in ['source','recommended_hero','set_id','unique_effect']),
 'new_equipment':all(x in data for x in ['tiger_tally','fire_strategy','yellow_heaven_scroll','xiliang_armor'])
}
for k,v in checks.items(): print(('PASS' if v else 'FAIL'),k)
if not all(checks.values()): sys.exit(1)
