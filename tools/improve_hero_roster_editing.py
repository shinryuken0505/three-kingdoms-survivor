from pathlib import Path

path = Path("scripts/main.gd")
text = path.read_text(encoding="utf-8")

handler_start = text.index("func handle_hero_config_key(key: int) -> void:\n")
handler_end = text.index("\n\nfunc handle_config_replace_key", handler_start)
new_handler = r'''func assign_hero_roster(hid: String, target: String) -> void:
	if not heroes.has(hid):
		return
	match target:
		"active":
			if active_heroes.has(hid):
				show_message("%s已在主戰欄。" % heroes[hid]["name"], 1.8)
				return
			if active_heroes.size() >= active_limit():
				config_candidate = hid
				config_replace_index = 0
				screen = "config_replace"
				return
			reserve_heroes.erase(hid)
			camp_heroes.erase(hid)
			active_heroes.append(hid)
			hero_cooldowns[hid] = hero_cooldown_value(hid)
			show_message("%s編入主戰，技能由完整冷卻開始。" % heroes[hid]["name"], 2.4)
		"reserve":
			if reserve_heroes.has(hid):
				show_message("%s已在後備欄，持續提供被動與羈絆。" % heroes[hid]["name"], 1.9)
				return
			if reserve_heroes.size() >= reserve_limit():
				show_message("後備欄已滿（%d／%d），請先將其他名將移至營地。" % [reserve_heroes.size(), reserve_limit()], 2.5)
				play_sfx("ui_error")
				return
			active_heroes.erase(hid)
			camp_heroes.erase(hid)
			hero_cooldowns.erase(hid)
			reserve_heroes.append(hid)
			show_message("%s編入後備，開始提供被動與羈絆。" % heroes[hid]["name"], 2.4)
		"camp":
			if camp_heroes.has(hid):
				show_message("%s已在營地待命。" % heroes[hid]["name"], 1.8)
				return
			active_heroes.erase(hid)
			reserve_heroes.erase(hid)
			hero_cooldowns.erase(hid)
			camp_heroes.append(hid)
			show_message("%s移至營地，不再提供後備被動。" % heroes[hid]["name"], 2.4)
	update_bonds()
	play_sfx("ui_confirm")
	if hero_config_origin == "intermission":
		save_run_checkpoint()


func handle_hero_config_key(key: int) -> void:
	var order: Array[String] = known_hero_order()
	if order.is_empty():
		close_hero_config()
		return
	hero_config_index = clampi(hero_config_index, 0, order.size() - 1)
	if is_up_key(key) or is_left_key(key):
		hero_config_index = wrapi(hero_config_index - 1, 0, order.size())
		play_sfx("ui_move")
	elif is_down_key(key) or is_right_key(key):
		hero_config_index = wrapi(hero_config_index + 1, 0, order.size())
		play_sfx("ui_move")
	elif key == KEY_ESCAPE or key == KEY_TAB:
		close_hero_config()
	elif key in [KEY_1, KEY_KP_1]:
		assign_hero_roster(order[hero_config_index], "active")
	elif key in [KEY_2, KEY_KP_2, KEY_X]:
		assign_hero_roster(order[hero_config_index], "reserve")
	elif key in [KEY_3, KEY_KP_3, KEY_C]:
		assign_hero_roster(order[hero_config_index], "camp")
	elif is_confirm_key(key):
		var hid: String = order[hero_config_index]
		var state: String = hero_roster_state(hid)
		if state == "active":
			assign_hero_roster(hid, "reserve")
		elif state == "reserve":
			assign_hero_roster(hid, "active")
		else:
			assign_hero_roster(hid, "reserve")
'''
text = text[:handler_start] + new_handler + text[handler_end:]

old_footer = '''\tvar action: String = "移至後援" if active_heroes.has(selected_id) else ("調至主戰" if active_heroes.size() < active_limit() else "選擇替換主戰名將")\n\tdraw_text("Enter／Space：%s" % action, Vector2(108, 632), 18, Color8(237, 216, 168), true)\n\tdraw_text("X／C切換後備／營地　Esc／Tab返回", Vector2(1160, 632), 15, Color8(181, 189, 181), false, HORIZONTAL_ALIGNMENT_RIGHT, 510)'''
new_footer = '''\tvar state_label: String = "主戰" if active_heroes.has(selected_id) else ("後備被動" if reserve_heroes.has(selected_id) else "營地待命")\n\tdraw_text("目前位置：%s" % state_label, Vector2(108, 616), 16, Color8(230, 211, 168), true)\n\tvar action_y: float = 640.0\n\tvar action_labels: Array[String] = ["1 主戰", "2 後備被動", "3 營地"]\n\tfor action_i in range(action_labels.size()):\n\t\tvar action_rect: Rect2 = Rect2(300 + action_i * 220, action_y - 25, 200, 36)\n\t\tvar selected_state: bool = (action_i == 0 and active_heroes.has(selected_id)) or (action_i == 1 and reserve_heroes.has(selected_id)) or (action_i == 2 and camp_heroes.has(selected_id))\n\t\tdraw_panel(action_rect, Color(0.43, 0.30, 0.12, 0.90) if selected_state else Color(0.045, 0.052, 0.052, 0.94), Color8(232, 196, 112) if selected_state else Color8(101, 101, 86), 1.4 if selected_state else 1.0)\n\t\tdraw_centered_text(action_labels[action_i], action_rect, 24.0, 14, Color8(239, 224, 187), selected_state)\n\tdraw_text("↑↓選擇名將　Enter快速切換　Esc／Tab返回", Vector2(1160, 659), 13, Color8(181, 189, 181), false, HORIZONTAL_ALIGNMENT_RIGHT, 620)'''
if old_footer not in text:
    raise SystemExit("hero config footer target not found")
text = text.replace(old_footer, new_footer, 1)

path.write_text(text, encoding="utf-8")
print("hero roster editing improved")
