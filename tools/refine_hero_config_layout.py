from pathlib import Path
import re

path = Path("scripts/main.gd")
text = path.read_text(encoding="utf-8")

new_func = r'''func draw_hero_config_screen() -> void:
	if hero_config_origin != "intermission":
		draw_overlay_backdrop()
	else:
		draw_rect(Rect2(Vector2.ZERO, VIEW), Color8(24, 29, 29), true)

	var root: Rect2 = Rect2(72, 42, 1136, 636)
	draw_panel(root, Color(0.03, 0.036, 0.038, 0.985), Color8(182, 151, 89), 2.0)
	draw_text("名將整備", root.position + Vector2(36, 48), 34, Color8(239, 214, 156), true)
	draw_text(
		"主戰 %d／%d　後備 %d／%d　營地 %d" % [active_heroes.size(), active_limit(), reserve_heroes.size(), reserve_limit(), camp_heroes.size()],
		root.position + Vector2(root.size.x - 36, 45), 16, Color8(193, 201, 193), true,
		HORIZONTAL_ALIGNMENT_RIGHT, 440
	)

	# 主戰與後備各自獨立成列，玩家可直接看懂目前編成。
	var active_panel: Rect2 = Rect2(108, 112, 1040, 76)
	draw_panel(active_panel, Color(0.04, 0.045, 0.044, 0.96), Color8(132, 112, 70), 1.2)
	draw_text("主戰陣容", active_panel.position + Vector2(14, 24), 17, Color8(235, 211, 153), true)
	var active_slots_x: float = active_panel.position.x + 104.0
	var active_slot_w: float = min(174.0, (active_panel.size.x - 118.0 - 10.0 * float(max(0, active_limit() - 1))) / float(max(1, active_limit())))
	for slot_i in range(active_limit()):
		var slot_rect: Rect2 = Rect2(active_slots_x + slot_i * (active_slot_w + 10.0), active_panel.position.y + 9.0, active_slot_w, 58.0)
		draw_panel(slot_rect, Color(0.05, 0.055, 0.053, 0.96), Color8(112, 103, 79), 1.0)
		if slot_i < active_heroes.size():
			var slot_id: String = str(active_heroes[slot_i])
			draw_texture_contain(portrait_tex[slot_id], Rect2(slot_rect.position + Vector2(5, 5), Vector2(44, 48)))
			draw_text(str(heroes[slot_id]["name"]), slot_rect.position + Vector2(56, 25), 15, heroes[slot_id]["color"], true, HORIZONTAL_ALIGNMENT_LEFT, max(60.0, slot_rect.size.x - 62.0))
			draw_text("Lv.%d" % int(hero_bond_level(slot_id)), slot_rect.position + Vector2(56, 45), 11, Color8(177, 186, 177))
		else:
			draw_centered_text("空位", slot_rect, 35.0, 14, Color8(126, 132, 126))

	var reserve_panel: Rect2 = Rect2(108, 198, 1040, 76)
	draw_panel(reserve_panel, Color(0.035, 0.043, 0.048, 0.96), Color8(82, 125, 151), 1.2)
	draw_text("後備陣容", reserve_panel.position + Vector2(14, 24), 17, Color8(157, 207, 232), true)
	var reserve_slots_x: float = reserve_panel.position.x + 104.0
	var reserve_count: int = max(1, reserve_limit())
	var reserve_slot_w: float = min(174.0, (reserve_panel.size.x - 118.0 - 10.0 * float(max(0, reserve_count - 1))) / float(reserve_count))
	for slot_i in range(reserve_count):
		var slot_rect: Rect2 = Rect2(reserve_slots_x + slot_i * (reserve_slot_w + 10.0), reserve_panel.position.y + 9.0, reserve_slot_w, 58.0)
		draw_panel(slot_rect, Color(0.043, 0.052, 0.058, 0.96), Color8(83, 126, 151), 1.0)
		if slot_i < reserve_heroes.size():
			var slot_id: String = str(reserve_heroes[slot_i])
			draw_texture_contain(portrait_tex[slot_id], Rect2(slot_rect.position + Vector2(5, 5), Vector2(44, 48)))
			draw_text(str(heroes[slot_id]["name"]), slot_rect.position + Vector2(56, 25), 15, heroes[slot_id]["color"], true, HORIZONTAL_ALIGNMENT_LEFT, max(60.0, slot_rect.size.x - 62.0))
			draw_text("被動 Lv.%d" % int(hero_bond_level(slot_id)), slot_rect.position + Vector2(56, 45), 11, Color8(157, 199, 220))
		else:
			draw_centered_text("空位", slot_rect, 35.0, 14, Color8(111, 137, 149))

	var order: Array[String] = known_hero_order()
	if order.is_empty():
		draw_text("尚未結識任何名將。", Vector2(108, 320), 22, Color8(196, 202, 195))
		return
	hero_config_index = clampi(hero_config_index, 0, order.size() - 1)

	var list_panel: Rect2 = Rect2(108, 290, 500, 326)
	draw_panel(list_panel, Color(0.038, 0.043, 0.044, 0.96), Color8(102, 96, 76), 1.2)
	draw_text("全部名將", list_panel.position + Vector2(18, 30), 20, Color8(225, 205, 160), true)
	var visible_count: int = 5
	var start: int = clampi(hero_config_index - int(visible_count / 2), 0, max(0, order.size() - visible_count))
	var finish: int = min(order.size(), start + visible_count)
	for i in range(start, finish):
		var hid: String = order[i]
		var row: int = i - start
		var rect: Rect2 = Rect2(list_panel.position.x + 12, list_panel.position.y + 48 + row * 52, list_panel.size.x - 24, 46)
		if i == hero_config_index:
			draw_rect(rect, Color(0.45, 0.31, 0.12, 0.88), true)
		draw_texture_contain(portrait_tex[hid], Rect2(rect.position + Vector2(5, 4), Vector2(40, 38)))
		var state: String = "主戰" if active_heroes.has(hid) else ("後備" if reserve_heroes.has(hid) else "營地")
		var state_color: Color = Color8(232, 196, 112) if state == "主戰" else (Color8(129, 191, 225) if state == "後備" else Color8(157, 164, 157))
		draw_text("%s　Lv.%d" % [heroes[hid]["name"], hero_bond_level(hid)], rect.position + Vector2(53, 29), 17, heroes[hid]["color"], true, HORIZONTAL_ALIGNMENT_LEFT, 270)
		var badge: Rect2 = Rect2(rect.end.x - 92, rect.position.y + 8, 78, 30)
		draw_panel(badge, Color(state_color.r, state_color.g, state_color.b, 0.13), state_color, 1.0)
		draw_centered_text(state, badge, 21.0, 13, state_color, true)

	var selected_id: String = order[hero_config_index]
	var detail_panel: Rect2 = Rect2(630, 290, 518, 326)
	draw_panel(detail_panel, Color(0.045, 0.05, 0.05, 0.94), heroes[selected_id]["color"], 1.5)
	draw_texture_contain(portrait_tex[selected_id], Rect2(detail_panel.position + Vector2(18, 22), Vector2(156, 204)))
	draw_text(str(heroes[selected_id]["name"]), detail_panel.position + Vector2(198, 48), 30, heroes[selected_id]["color"], true, HORIZONTAL_ALIGNMENT_LEFT, 285)
	draw_text(str(heroes[selected_id]["title"]), detail_panel.position + Vector2(198, 78), 17, Color8(223, 212, 179), true, HORIZONTAL_ALIGNMENT_LEFT, 285)
	draw_text("主動技能", detail_panel.position + Vector2(198, 112), 15, Color8(228, 204, 150), true)
	draw_wrapped(str(heroes[selected_id]["active"]), Rect2(detail_panel.position + Vector2(198, 122), Vector2(286, 62)), 13, Color8(207, 214, 205), 19.0)
	draw_text("後備能力", detail_panel.position + Vector2(198, 198), 15, Color8(157, 207, 232), true)
	draw_wrapped(str(heroes[selected_id]["passive"]), Rect2(detail_panel.position + Vector2(198, 208), Vector2(286, 58)), 13, Color8(207, 214, 205), 19.0)
	var state_label: String = "主戰" if active_heroes.has(selected_id) else ("後備" if reserve_heroes.has(selected_id) else "營地")
	var state_color: Color = Color8(232, 196, 112) if state_label == "主戰" else (Color8(129, 191, 225) if state_label == "後備" else Color8(157, 164, 157))
	var state_badge: Rect2 = Rect2(detail_panel.position.x + 18, detail_panel.end.y - 64, 156, 34)
	draw_panel(state_badge, Color(state_color.r, state_color.g, state_color.b, 0.13), state_color, 1.0)
	draw_centered_text("目前：%s" % state_label, state_badge, 24.0, 14, state_color, true)
	draw_text("Enter／Space 調整位置", detail_panel.position + Vector2(198, 294), 14, Color8(230, 211, 168), true)

	draw_text("↑↓選擇名將　Enter／Space調整位置　Esc／Tab返回", Vector2(root.position.x + root.size.x - 36, root.end.y - 17), 13, Color8(181, 189, 181), false, HORIZONTAL_ALIGNMENT_RIGHT, 640)
'''

pattern = re.compile(r"func draw_hero_config_screen\(\) -> void:\n.*?\n\nfunc draw_config_replace_screen\(\) -> void:", re.S)
match = pattern.search(text)
if not match:
    raise SystemExit("draw_hero_config_screen block not found")
text = text[:match.start()] + new_func + "\n\nfunc draw_config_replace_screen() -> void:" + text[match.end():]
path.write_text(text, encoding="utf-8")
print("refined hero config layout")
