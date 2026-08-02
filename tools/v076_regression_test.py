#!/usr/bin/env python3
from pathlib import Path
import re, wave, json
from PIL import Image
root=Path(__file__).resolve().parents[1]
main=(root/'scripts/main.gd').read_text(encoding='utf-8')
data=(root/'scripts/game_data.gd').read_text(encoding='utf-8')
checks={
 'dodge cooldown':'"dash_cd": 5.0' in main and 'Space閃避' in main and 'player["dash_timer"] = max(0.72, cd)' in main,
 'active-only history':'if not active_heroes.has(str(hid))' in main and '後備名將不應解鎖史勢特殊選項' in main,
 'tab paging':'var tab_scroll: int = 0' in main and '後備名將（↑↓捲動）' in main,
 'save menu':('繼續遊戲（章間存檔）' in main or '繼續遊戲' in main) and ('章間旅程已保存' in main or '讀取存檔' in main),
 'new enemy AI':all(k in main for k in ['"crossbow"','"drummer"','"firepot"','"assassin"']),
 'double boss data':data.count('"support_boss"')>=2,
 'lu bu tuning':'"hp": 3560.0' in data and 'boss["attack_cd"] = 1.78' in main,
 'zhangfei outward':'(1.0 - alpha)' in main,
 'BGM fix':'if bgm_name == name and current.playing' in main and 'bgm_player_alt' in main,
}
for name,ok in checks.items():
    if not ok: raise SystemExit('FAIL '+name)
for fn in ['enemy_crossbow_default.png','enemy_drummer_default.png','enemy_firepot_default.png','enemy_assassin_default.png','liru_default.png','chengong_default.png']:
    matches=list((root/'assets').rglob(fn))
    if not matches: raise SystemExit('MISSING '+fn)
    with Image.open(matches[0]) as im: im.verify()
for p in (root/'assets/audio').glob('bgm_*.wav'):
    with wave.open(str(p),'rb') as w:
        if w.getnframes()/w.getframerate()<30: raise SystemExit('SHORT '+p.name)
print('V076_REGRESSION_OK')
for k in checks: print(' -',k)
