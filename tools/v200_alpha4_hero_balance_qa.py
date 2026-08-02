from pathlib import Path
import sys
root = Path(__file__).resolve().parents[1]
data = (root / 'scripts/game_data.gd').read_text(encoding='utf-8')
main = (root / 'scripts/main.gd').read_text(encoding='utf-8')
hero_ids = ['liubei','guanyu','zhangfei','huatuo','caocao','sunjian','taishici','zhangjiao','diaochan','sunshangxiang','zhenji','lvlingqi','wangyi','caiwenji','daqiao']
missing = []
for hid in hero_ids:
    marker = '\n\t\t"' + hid + '":\n\t\t{'
    pos = data.find(marker)
    if pos < 0:
        missing.append((hid, 'record'))
        continue
    chunk = data[pos:pos + 1100]
    for key in ('balance_tier','combat_role','cooldown_mult','identity','legendary'):
        if '"' + key + '"' not in chunk:
            missing.append((hid, key))
for token in ('apply_hero_balance_identity','hero_has_legendary','cooldown_mult','dash_timer'):
    if token not in main:
        missing.append(('main.gd', token))
if missing:
    print('FAIL', missing)
    sys.exit(1)
print('PASS hero balance profiles=' + str(len(hero_ids)))
