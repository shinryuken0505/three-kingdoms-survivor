from pathlib import Path
import re

path = Path('scripts/main.gd')
text = path.read_text(encoding='utf-8')

# State used by the explicit position picker and capacity-specific replacement dialog.
anchor = 'var config_replace_index: int = 0\n'
addition = (
    'var config_replace_index: int = 0\n'
    'var hero_position_picker_open: bool = false\n'
    'var hero_position_index: int = 0\n'
    'var hero_position_candidate: String = ""\n'
    'var config_replace_mode: String = "active" # active／reserve\n'
)
if 'var hero_position_picker_open:' not in text:
    if anchor not in text:
        raise SystemExit('hero config state anchor not found')
    text = text.replace(anchor, addition, 1)

# Replace the complete hero config input handler. Enter/Space now opens an explicit picker.
pattern = re.compile(r'func handle_hero_config_key\(key: int\) -> void:\n.*?(?=\nfunc handle_config_replace_key\()', re.S)
replacement = '''func handle_hero_config_key(key: int) -> void:
\tvar order: Array[String] = known_hero_order()
\tif order.is_empty():
\t\tclose_hero_config()
\t\treturn
\thero_config_index = clampi(hero_config_index, 0, order.size() - 1)
\tif hero_position_picker_open:
\t\thandle_hero_position_picker_key(key)
\t\treturn
\tif is_up_key(key) or is_left_key(key):
\t\thero_config_index = wrapi(hero_config_index - 1, 0, order.size())
\t\tplay_sfx("ui_move")
\telif is_down_key(key) or is_right_key(key):
\t\thero_config_index = wrapi(hero_config_index + 1, 0, order.size())
\t\tplay_sfx("ui_move")
\telif key == KEY_ESCAPE or key == KEY_TAB:
\t\tclose_hero_config()
\telif is_confirm_key(key):
\t\thero_position_candidate = order[hero_config_index]
\t\tvar current_state: String = hero_roster_state(hero_position_candidate)
\t\thero_position_index = 0 if current_state == "active" else (1 if current_state == "reserve" else 2)
\t\thero_position_picker_open = true
\t\tplay_sfx("ui_confirm")


func handle_hero_position_picker_key(key: int) -> void:
\tif key == KEY_ESCAPE or key == KEY_TAB:
\t\thero_position_picker_open = false
\t\tplay_sfx("ui_cancel")
\t\treturn
\tif is_up_key(key) or is_left_key(key):
\t\thero_position_index = wrapi(hero_position_index - 1, 0, 4)
\t\tplay_sfx("ui_move")
\t\treturn
\tif is_down_key(key) or is_right_key(key):
\t\thero_position_index = wrapi(hero_position_index + 1, 0, 4)
\t\tplay_sfx("ui_move")
\t\treturn
\tif not is_confirm_key(key):
\t\treturn
\tif hero_position_index == 3:
\t\thero_position_picker_open = false
\t\tplay_sfx("ui_cancel")
\t\treturn
\tvar hid: String = hero_position_candidate
\tif hid == "" or not heroes.has(hid):
\t\thero_position_picker_open = false
\t\treturn
\tvar current_state: String = hero_roster_state(hid)
\tvar target_state: String = ["active", "reserve", "camp"][hero_position_index]
\tif current_state == target_state:
\t\tshow_message("%s目前已在%s。" % [heroes[hid]["name"], "主戰" if target_state == "active" else ("後備" if target_state == "reserve" else "營地")], 2.0)
\t\thero_position_picker_open = false
\t\tplay_sfx("ui_error")
\t\treturn
\tif target_state == "active" and active_heroes.size() >= active_limit():
\t\tconfig_candidate = hid
\t\tconfig_replace_mode = "active"
\t\tconfig_replace_index = 0
\t\thero_position_picker_open = false
\t\tscreen = "config_replace"
\t\tplay_sfx("ui_confirm")
\t\treturn
\tif target_state == "reserve" and reserve_heroes.size() >= reserve_limit():
\t\tconfig_candidate = hid
\t\tconfig_replace_mode = "reserve"
\t\tconfig_replace_index = 0
\t\thero_position_picker_open = false
\t\tscreen = "config_replace"
\t\tplay_sfx("ui_confirm")
\t\treturn
\tmatch target_state:
\t\t"active":
\t\t\tassign_hero_to_active(hid)
\t\t"reserve":
\t\t\tassign_hero_to_reserve(hid)
\t\t"camp":
\t\t\tassign_hero_to_camp(hid)
\thero_position_picker_open = false
'''
text, count = pattern.subn(replacement, text, count=1)
if count != 1:
    raise SystemExit('handle_hero_config_key block not found')

# Replace replacement handler so active and reserve capacity are handled separately.
pattern = re.compile(r'func handle_config_replace_key\(key: int\) -> void:\n.*?(?=\nfunc [a-zA-Z0-9_]+\()', re.S)
replacement = '''func handle_config_replace_key(key: int) -> void:
\tvar pool: Array = active_heroes if config_replace_mode == "active" else reserve_heroes
\tconfig_replace_index = clampi(config_replace_index, 0, pool.size())
\tif is_up_key(key) or is_left_key(key):
\t\tconfig_replace_index = wrapi(config_replace_index - 1, 0, pool.size() + 1)
\t\tplay_sfx("ui_move")
\telif is_down_key(key) or is_right_key(key):
\t\tconfig_replace_index = wrapi(config_replace_index + 1, 0, pool.size() + 1)
\t\tplay_sfx("ui_move")
\telif key == KEY_ESCAPE or key == KEY_TAB:
\t\tconfig_candidate = ""
\t\tscreen = "hero_config"
\t\tplay_sfx("ui_cancel")
\telif is_confirm_key(key):
\t\tif config_replace_index >= pool.size():
\t\t\tconfig_candidate = ""
\t\t\tscreen = "hero_config"
\t\t\tplay_sfx("ui_cancel")
\t\t\treturn
\t\tvar old_id: String = str(pool[config_replace_index])
\t\tvar new_id: String = config_candidate
\t\tif config_replace_mode == "active":
\t\t\tactive_heroes[config_replace_index] = new_id
\t\t\treserve_heroes.erase(new_id)
\t\t\tcamp_heroes.erase(new_id)
\t\t\tplace_hero_in_support(old_id)
\t\t\thero_cooldowns.erase(old_id)
\t\t\thero_cooldowns[new_id] = hero_cooldown_value(new_id)
\t\t\tshow_message("%s編入主戰，%s轉入後援。" % [heroes[new_id]["name"], heroes[old_id]["name"]], 2.6)
\t\telse:
\t\t\treserve_heroes[config_replace_index] = new_id
\t\t\tactive_heroes.erase(new_id)
\t\t\thero_cooldowns.erase(new_id)
\t\t\tcamp_heroes.erase(new_id)
\t\t\tif not camp_heroes.has(old_id):
\t\t\t\tcamp_heroes.append(old_id)
\t\t\tshow_message("%s編入後備，%s返回營地。" % [heroes[new_id]["name"], heroes[old_id]["name"]], 2.6)
\t\tupdate_bonds()
\t\tplay_sfx("ui_confirm")
\t\tconfig_candidate = ""
\t\tscreen = "hero_config"
\t\tif hero_config_origin == "intermission":
\t\t\tsave_run_checkpoint()
'''
text, count = pattern.subn(replacement, text, count=1)
if count != 1:
    raise SystemExit('handle_config_replace_key block not found')

# Status tag colors and clear Enter hint in the list screen.
text = text.replace(
    'draw_text(state, rect.position + Vector2(445, 27), 15, Color8(133, 221, 155) if state == "主戰" else Color8(180, 191, 183), true, HORIZONTAL_ALIGNMENT_RIGHT, 90)',
    'var state_color: Color = Color8(238, 201, 110) if state == "主戰" else (Color8(116, 184, 226) if state == "後備" else Color8(154, 160, 154))\n\t\tdraw_text("【%s】" % state, rect.position + Vector2(445, 27), 15, state_color, true, HORIZONTAL_ALIGNMENT_RIGHT, 90)'
)

# Remove old faux number buttons and replace with a single explicit instruction.
old_ui = re.compile(r'\tvar state_label: String = "主戰".*?draw_text\("↑↓選擇名將.*?\n', re.S)
new_ui = '''\tvar state_label: String = "主戰" if active_heroes.has(selected_id) else ("後備" if reserve_heroes.has(selected_id) else "營地")
\tvar state_color: Color = Color8(238, 201, 110) if state_label == "主戰" else (Color8(116, 184, 226) if state_label == "後備" else Color8(154, 160, 154))
\tdraw_text("目前編成：【%s】" % state_label, Vector2(108, 620), 16, state_color, true)
\tdraw_text("↑↓選擇名將　Enter／Space調整位置　Esc／Tab返回", Vector2(1160, 650), 14, Color8(181, 189, 181), false, HORIZONTAL_ALIGNMENT_RIGHT, 720)
\tif hero_position_picker_open:
\t\tdraw_hero_position_picker()
'''
text, count = old_ui.subn(new_ui, text, count=1)
if count != 1:
    raise SystemExit('hero config footer block not found')

# Insert position picker renderer before replacement screen.
marker = '\n\nfunc draw_config_replace_screen() -> void:\n'
picker = '''

func draw_hero_position_picker() -> void:
\tdraw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.0, 0.0, 0.0, 0.62), true)
\tvar panel: Rect2 = Rect2(335, 135, 610, 450)
\tdraw_panel(panel, Color(0.028, 0.034, 0.035, 0.99), Color8(215, 181, 105), 2.2)
\tvar hid: String = hero_position_candidate
\tvar hero_name: String = str(heroes.get(hid, {}).get("name", hid))
\tdraw_centered_text("調整%s的編成位置" % hero_name, panel, 54.0, 28, Color8(239, 215, 159), true)
\tdraw_centered_text("選擇新位置；欄位已滿時才會進入替換名單。", panel, 88.0, 14, Color8(180, 190, 181))
\tvar labels: Array[String] = ["主戰", "後備", "營地", "取消"]
\tvar descriptions: Array[String] = [
\t\t"跟隨出戰，可施放主動技能。",
\t\t"提供後備能力與羈絆效果。",
\t\t"暫不參戰，也不提供後備能力。",
\t\t"保持目前編成位置。"
\t]
\tfor i in range(labels.size()):
\t\tvar r: Rect2 = Rect2(panel.position.x + 55, panel.position.y + 125 + i * 72, panel.size.x - 110, 58)
\t\tvar selected: bool = i == hero_position_index
\t\tdraw_panel(r, Color(0.42, 0.30, 0.13, 0.92) if selected else Color(0.045, 0.051, 0.051, 0.96), Color8(230, 194, 112) if selected else Color8(96, 99, 91), 1.8 if selected else 1.0)
\t\tdraw_text(("▶ " if selected else "　") + labels[i], r.position + Vector2(18, 25), 19, Color8(241, 224, 185), selected)
\t\tdraw_text(descriptions[i], r.position + Vector2(145, 24), 14, Color8(191, 201, 191), false, HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 160)
\tdraw_centered_text("↑↓選擇　Enter／Space確認　Esc取消", panel, 420.0, 13, Color8(169, 178, 169))
'''
if 'func draw_hero_position_picker()' not in text:
    if marker not in text:
        raise SystemExit('draw config replace marker not found')
    text = text.replace(marker, picker + marker, 1)

# Replace config replacement renderer with capacity-specific copy and centered layout.
pattern = re.compile(r'func draw_config_replace_screen\(\) -> void:\n.*?(?=\nfunc [a-zA-Z0-9_]+\()', re.S)
replacement = '''func draw_config_replace_screen() -> void:
\tdraw_overlay_backdrop()
\tvar panel: Rect2 = Rect2(250, 95, 780, 530)
\tdraw_panel(panel, Color(0.035, 0.04, 0.041, 0.985), Color8(220, 188, 112), 2.0)
\tvar is_active: bool = config_replace_mode == "active"
\tvar title: String = "主戰欄已滿：選擇替換名將" if is_active else "後備欄已滿：選擇返回營地的名將"
\tdraw_centered_text(title, panel, 55.0, 28, Color8(239, 215, 159), true)
\tif config_candidate != "" and heroes.has(config_candidate):
\t\tdraw_centered_text("準備編入%s：%s" % ["主戰" if is_active else "後備", heroes[config_candidate]["name"]], panel, 92.0, 18, heroes[config_candidate]["color"], true)
\tvar pool: Array = active_heroes if is_active else reserve_heroes
\tfor i in range(pool.size() + 1):
\t\tvar label: String = "取消替換"
\t\tif i < pool.size():
\t\t\tvar hid: String = str(pool[i])
\t\t\tlabel = ("替換 %s" if is_active else "%s返回營地") % heroes[hid]["name"]
\t\tvar rect: Rect2 = Rect2(panel.position.x + 85, panel.position.y + 130 + i * 66, panel.size.x - 170, 50)
\t\tvar selected: bool = i == config_replace_index
\t\tdraw_panel(rect, Color(0.53, 0.36, 0.14, 0.86) if selected else Color(0.045, 0.05, 0.05, 0.94), Color8(226, 190, 108) if selected else Color8(93, 96, 89), 1.6 if selected else 1.0)
\t\tdraw_centered_text(("▶ " if selected else "") + label, rect, 32.0, 20, Color8(238, 226, 198), selected)
\tdraw_centered_text("↑↓選擇　Enter／Space確認　Esc取消", panel, panel.size.y - 24.0, 13, Color8(170, 179, 170))
'''
text, count = pattern.subn(replacement, text, count=1)
if count != 1:
    raise SystemExit('draw_config_replace_screen block not found')

path.write_text(text, encoding='utf-8')
print('Hero roster assignment UI refined.')
