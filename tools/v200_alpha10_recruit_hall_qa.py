from pathlib import Path
root = Path(__file__).resolve().parents[1]
main = (root / 'scripts' / 'main.gd').read_text(encoding='utf-8')
data = (root / 'scripts' / 'game_data.gd').read_text(encoding='utf-8')
checks = {
    '招賢館世界標記': 'E 招賢館' in main,
    '候選1至3人': 'func recruit_candidate_count()' in main and 'return 1 if roll < 0.12 else (2 if roll < 0.55 else 3)' in main,
    '刷新費用遞增': 'var costs: Array[int] = [20, 40, 70, 110, 170]' in main,
    '免費刷新遺物': 'bole_eye' in data and 'recruit_refresh_is_free' in main,
    '不提前顯示名將頭像': 'draw_sprite_frame(sprite_tex[current_encounter]' not in main,
    '主戰解鎖曲線': '第1章2、第3章3、第7章4、第10章5' in main,
}
failed = [name for name, ok in checks.items() if not ok]
if failed:
    raise SystemExit('ALPHA10_QA_FAIL: ' + '、'.join(failed))
print('ALPHA10_RECRUIT_HALL_QA_OK')
