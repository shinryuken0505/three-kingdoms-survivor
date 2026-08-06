from pathlib import Path
import re

path = Path('scripts/main.gd')
text = path.read_text(encoding='utf-8')

text = text.replace('const BossLootUIScript = preload("res://scripts/ui/boss_loot_ui.gd")', 'const BossLootUIScript = preload("res://scripts/ui/boss_loot_ui.gd")\nconst RelicNoticeUIScript = preload("res://scripts/ui/relic_notice_ui.gd")', 1)
text = text.replace('const GAME_VERSION: String = "V2.0.0-alpha.28"', 'const GAME_VERSION: String = "V2.0.0-alpha.29"', 1)
text = text.replace('var pending_boss_loot: Dictionary = {}', 'var pending_boss_loot: Dictionary = {}\nvar pending_relic_notice: Dictionary = {}', 1)

input_needle = '\tvar confirm: bool = key_event.is_action_pressed("ui_accept") or is_confirm_key(key)\n'
input_insert = input_needle + '''\tif not pending_relic_notice.is_empty():
\t\tif confirm or key == KEY_ESCAPE:
\t\t\tpending_relic_notice.clear()
\t\t\tplay_sfx("ui_confirm")
\t\t\tqueue_redraw()
\t\t\tget_viewport().set_input_as_handled()
\t\treturn
'''
if input_needle in text and 'if not pending_relic_notice.is_empty()' not in text:
    text = text.replace(input_needle, input_insert, 1)

helper = '''

func open_relic_notice(rid: String, reason: String, upgraded: bool, old_level: int, new_level: int) -> void:
\tif rid == "" or not relic_defs.has(rid):
\t\treturn
\tpending_relic_notice = {
\t\t"id": rid,
\t\t"reason": reason,
\t\t"upgraded": upgraded,
\t\t"old_level": old_level,
\t\t"new_level": new_level
\t}
\tmodal_input_lock_until_ms = Time.get_ticks_msec() + 160

'''
if 'func open_relic_notice(' not in text:
    text = text.replace('\nfunc grant_relic(rid: String, reason: String, counts_toward_chapter_limit: bool = true) -> bool:', helper + 'func grant_relic(rid: String, reason: String, counts_toward_chapter_limit: bool = true) -> bool:', 1)

start = text.find('func grant_relic(rid: String, reason: String, counts_toward_chapter_limit: bool = true) -> bool:')
end = text.find('\nfunc grant_random_relic(', start)
if start < 0 or end < 0:
    raise SystemExit('grant_relic block not found')
block = text[start:end]
if 'var previous_level:' not in block:
    block = block.replace('\tvar already_owned: bool = relics.has(rid)\n', '\tvar already_owned: bool = relics.has(rid)\n\tvar previous_level: int = relic_level(rid) if already_owned else 0\n', 1)
if 'open_relic_notice(rid, reason' not in block:
    lines = block.splitlines()
    out = []
    for line in lines:
        if line.lstrip().startswith('trigger_relic(rid,'):
            indent = line[:len(line) - len(line.lstrip())]
            out.append(indent + 'open_relic_notice(rid, reason, already_owned, previous_level, relic_level(rid))')
        out.append(line)
    block = '\n'.join(out)
text = text[:start] + block + text[end:]

# Add the notice as the final overlay of _draw(), so it never clashes with the base screen.
draw_start = text.find('func _draw() -> void:')
if draw_start < 0:
    raise SystemExit('_draw function not found')
draw_end = text.find('\nfunc ', draw_start + 10)
if draw_end < 0:
    draw_end = len(text)
draw_block = text[draw_start:draw_end]
if 'RelicNoticeUIScript.draw(self, pending_relic_notice)' not in draw_block:
    draw_block = draw_block.rstrip() + '\n\tif not pending_relic_notice.is_empty():\n\t\tRelicNoticeUIScript.draw(self, pending_relic_notice)\n\n'
text = text[:draw_start] + draw_block + text[draw_end:]

# Extend self-test with deterministic notice validation.
marker = '\tknown_heroes = {"liubei": true, "guanyu": true, "zhangfei": true}\n'
validation = '''\tif pending_relic_notice.is_empty() or str(pending_relic_notice.get("id", "")) != granted:
\t\tself_test_fail("新遺物提示未建立")
\t\treturn
\tif int(pending_relic_notice.get("new_level", 0)) != 2 or not bool(pending_relic_notice.get("upgraded", false)):
\t\tself_test_fail("遺物升級提示內容錯誤")
\t\treturn
\tpending_relic_notice.clear()
'''
if marker in text and '新遺物提示未建立' not in text:
    text = text.replace(marker, validation + marker, 1)

path.write_text(text, encoding='utf-8')

report = Path('docs/art/alpha29_relic_reward_presentation.md')
report.parent.mkdir(parents=True, exist_ok=True)
report.write_text('''# Alpha.29 遺物獎勵呈現驗收

- 遊戲版本：V2.0.0-alpha.29
- 新取得遺物顯示獨立卡片：名稱、稀有度、等級、完整效果、流派標籤。
- 重複取得顯示升級前後等級，不重複增加背包項目。
- 提示採覆蓋層，不改變原本 Boss 結算、商店或戰場畫面狀態。
- Boss 戰利品依 1280×720 安全區重新置中。
- 遺物、裝備、銅錢與確認按鈕使用獨立資訊區塊。
- 「收下戰利品」按鈕以容器中心計算，不使用舊固定座標。
- 自動測試新增遺物提示建立與升級內容驗證。
''', encoding='utf-8')
