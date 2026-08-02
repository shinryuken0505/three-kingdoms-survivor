from pathlib import Path
import re

path = Path('scripts/main.gd')
text = path.read_text(encoding='utf-8')

# The input state already opens hero_position_picker_open, but the renderer was never
# generated into main.gd. Keep the picker as an overlay on hero_config for stability.
hero_config_pattern = re.compile(
    r'(func draw_hero_config_screen\(\) -> void:\n.*?)(?=\nfunc draw_config_replace_screen\(\) -> void:)',
    re.S,
)
match = hero_config_pattern.search(text)
if not match:
    raise SystemExit('draw_hero_config_screen block not found')

block = match.group(1)
if 'draw_hero_position_picker()' not in block:
    block = block.rstrip() + '\n\tif hero_position_picker_open:\n\t\tdraw_hero_position_picker()\n'
    text = text[:match.start(1)] + block + text[match.end(1):]

if 'func draw_hero_position_picker() -> void:' not in text:
    marker = '\nfunc draw_config_replace_screen() -> void:\n'
    if marker not in text:
        raise SystemExit('draw_config_replace_screen marker not found')
    renderer = '''
func draw_hero_position_picker() -> void:
\tdraw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.0, 0.0, 0.0, 0.66), true)
\tvar panel: Rect2 = Rect2(335, 132, 610, 456)
\tdraw_panel(panel, Color(0.028, 0.034, 0.035, 0.995), Color8(215, 181, 105), 2.2)
\tvar hid: String = hero_position_candidate
\tvar hero_name: String = str(heroes.get(hid, {}).get("name", hid))
\tdraw_centered_text("調整%s的編成位置" % hero_name, panel, 54.0, 28, Color8(239, 215, 159), true)
\tdraw_centered_text("欄位未滿時直接編入；已滿時再選擇替換名將。", panel, 88.0, 14, Color8(180, 190, 181))
\tvar labels: Array[String] = ["主戰", "後備", "營地", "取消"]
\tvar descriptions: Array[String] = [
\t\t"跟隨出戰，可施放主動技能。",
\t\t"提供後備能力與羈絆效果。",
\t\t"暫不參戰，也不提供後備效果。",
\t\t"保持目前編成位置。"
\t]
\tfor i in range(labels.size()):
\t\tvar r: Rect2 = Rect2(panel.position.x + 52, panel.position.y + 120 + i * 74, panel.size.x - 104, 60)
\t\tvar selected: bool = i == hero_position_index
\t\tdraw_panel(r, Color(0.42, 0.30, 0.13, 0.94) if selected else Color(0.045, 0.051, 0.051, 0.98), Color8(230, 194, 112) if selected else Color8(96, 99, 91), 1.8 if selected else 1.0)
\t\tdraw_text(("▶ " if selected else "　") + labels[i], r.position + Vector2(18, 27), 19, Color8(241, 224, 185), selected)
\t\tdraw_text(descriptions[i], r.position + Vector2(142, 26), 14, Color8(191, 201, 191), false, HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 158)
\tdraw_centered_text("↑↓選擇　Enter／Space確認　Esc取消", panel, 430.0, 13, Color8(169, 178, 169))

'''
    text = text.replace(marker, '\n' + renderer + 'func draw_config_replace_screen() -> void:\n', 1)

# Make sure every input change requests a redraw immediately.
input_pattern = re.compile(r'(func handle_hero_config_key\(key: int\) -> void:\n.*?)(?=\nfunc handle_hero_position_picker_key\()', re.S)
m = input_pattern.search(text)
if m:
    iblock = m.group(1)
    if '\t\tqueue_redraw()\n' not in iblock:
        iblock = iblock.replace('\t\thero_position_picker_open = true\n\t\tplay_sfx("ui_confirm")', '\t\thero_position_picker_open = true\n\t\tplay_sfx("ui_confirm")\n\t\tqueue_redraw()', 1)
        text = text[:m.start(1)] + iblock + text[m.end(1):]

path.write_text(text, encoding='utf-8')
print('hero position picker renderer ensured')
