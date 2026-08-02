from pathlib import Path

path = Path("scripts/main.gd")
text = path.read_text(encoding="utf-8")
start = text.index("func handle_hero_config_key(key: int) -> void:\n")
end = text.index("\n\nfunc handle_config_replace_key", start)
replacement = '''func assign_hero_to_reserve(hid: String) -> void:
	if active_heroes.has(hid):
		active_heroes.erase(hid)
		hero_cooldowns.erase(hid)
	camp_heroes.erase(hid)
	if not reserve_heroes.has(hid):
		if reserve_heroes.size() >= reserve_limit():
			if not camp_heroes.has(hid):
				camp_heroes.append(hid)
			show_message("後備欄已滿（%d／%d），請先將一名後備武將移回營地。" % [reserve_heroes.size(), reserve_limit()], 2.8)
			play_sfx("ui_error")
			return
		reserve_heroes.append(hid)
	update_bonds()
	show_message("%s已編入後備，開始提供被動能力與羈絆。" % heroes[hid]["name"], 2.5)
	play_sfx("ui_confirm")
	if hero_config_origin == "intermission":
		save_run_checkpoint()


func assign_hero_to_camp(hid: String) -> void:
	active_heroes.erase(hid)
	reserve_heroes.erase(hid)
	hero_cooldowns.erase(hid)
	if not camp_heroes.has(hid):
		camp_heroes.append(hid)
	update_bonds()
	show_message("%s已移至營地待命。" % heroes[hid]["name"], 2.3)
	play_sfx("ui_confirm")
	if hero_config_origin == "intermission":
		save_run_checkpoint()


func assign_hero_to_active(hid: String) -> void:
	if active_heroes.has(hid):
		show_message("%s目前已在主戰陣容。" % heroes[hid]["name"], 1.8)
		return
	if active_heroes.size() >= active_limit():
		config_candidate = hid
		config_replace_index = 0
		screen = "config_replace"
		play_sfx("ui_confirm")
		return
	reserve_heroes.erase(hid)
	camp_heroes.erase(hid)
	active_heroes.append(hid)
	hero_cooldowns[hid] = hero_cooldown_value(hid)
	update_bonds()
	show_message("%s已調至主戰，技能由完整冷卻開始。" % heroes[hid]["name"], 2.5)
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
		return
	if is_down_key(key) or is_right_key(key):
		hero_config_index = wrapi(hero_config_index + 1, 0, order.size())
		play_sfx("ui_move")
		return
	if key == KEY_ESCAPE or key == KEY_TAB:
		close_hero_config()
		return

	var hid: String = order[hero_config_index]
	if key in [KEY_1, KEY_KP_1]:
		assign_hero_to_active(hid)
	elif key in [KEY_2, KEY_KP_2]:
		assign_hero_to_reserve(hid)
	elif key in [KEY_3, KEY_KP_3]:
		assign_hero_to_camp(hid)
	elif key in [KEY_X, KEY_C]:
		if reserve_heroes.has(hid):
			assign_hero_to_camp(hid)
		else:
			assign_hero_to_reserve(hid)
	elif is_confirm_key(key):
		# 快速操作：營地優先編入後備；後備調至主戰；主戰移至後備。
		if camp_heroes.has(hid):
			assign_hero_to_reserve(hid)
		elif reserve_heroes.has(hid):
			assign_hero_to_active(hid)
		else:
			assign_hero_to_reserve(hid)
'''
text = text[:start] + replacement + text[end:]
path.write_text(text, encoding="utf-8")
print("hero config assignment controls repaired")
