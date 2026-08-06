class_name BossLootUI
extends RefCounted


static func draw(host: Node, loot: Dictionary) -> void:
	host.draw_rect(Rect2(Vector2.ZERO, host.VIEW), Color8(18, 21, 20), true)

	var safe_margin := Vector2(72.0, 42.0)
	var safe_rect := Rect2(safe_margin, host.VIEW - safe_margin * 2.0)
	var panel_size := Vector2(min(980.0, safe_rect.size.x), min(594.0, safe_rect.size.y))
	var panel := Rect2(safe_rect.position + (safe_rect.size - panel_size) * 0.5, panel_size)
	host.draw_panel(panel, Color(0.028, 0.034, 0.032, 0.99), Color8(213, 169, 76), 2.6)

	var inner := panel.grow(-36.0)
	var header := Rect2(inner.position, Vector2(inner.size.x, 92.0))
	host.draw_text("敵將擊破", header.position + Vector2(0, 40), 42, Color8(244, 210, 132), true, HORIZONTAL_ALIGNMENT_CENTER, header.size.x)
	host.draw_text(str(loot.get("boss_name", "敵將")), header.position + Vector2(0, 75), 23, Color8(222, 217, 199), true, HORIZONTAL_ALIGNMENT_CENTER, header.size.x)

	var card_gap := 28.0
	var card_y := header.end.y + 20.0
	var card_h := 278.0
	var card_w := (inner.size.x - card_gap) * 0.5
	var left := Rect2(Vector2(inner.position.x, card_y), Vector2(card_w, card_h))
	var right := Rect2(Vector2(left.end.x + card_gap, card_y), Vector2(card_w, card_h))

	_draw_relic_card(host, left, loot)
	_draw_equipment_card(host, right, loot)

	var coin_rect := Rect2(Vector2(inner.position.x, left.end.y + 14.0), Vector2(inner.size.x, 42.0))
	host.draw_centered_text("銅錢　+%d" % int(loot.get("coins", 0)), coin_rect, 29.0, 21, Color8(239, 202, 105), true)

	var button_size := Vector2(340.0, 58.0)
	var button := Rect2(Vector2(panel.get_center().x - button_size.x * 0.5, panel.end.y - 82.0), button_size)
	host.draw_rect(button, Color(0.48, 0.34, 0.13, 0.94), true)
	host.draw_rect(button, Color8(235, 199, 119), false, 2.0)
	host.draw_centered_text("收下戰利品", button, 38.0, 22, Color8(250, 236, 201), true)


static func _draw_relic_card(host: Node, rect: Rect2, loot: Dictionary) -> void:
	host.draw_panel(rect, Color(0.043, 0.049, 0.047, 0.97), Color8(135, 118, 83), 1.4)
	host.draw_text("遺物戰利品", rect.position + Vector2(22, 32), 21, Color8(221, 205, 165), true)
	var relic_id := str(loot.get("relic", ""))
	if relic_id == "" or not host.relic_defs.has(relic_id):
		host.draw_centered_text("本次未取得遺物", rect, 146.0, 18, Color8(146, 153, 146))
		return
	var rdef: Dictionary = host.relic_defs[relic_id]
	var owned := host.has_relic(relic_id)
	var next_level := min(host.MAX_RELIC_LEVEL, host.relic_level(relic_id) + 1) if owned else 1
	var rarity := str(rdef.get("rarity", "common"))
	var rarity_text := host.relic_rarity_name(rarity) if host.has_method("relic_rarity_name") else rarity.to_upper()
	host.draw_texture_contain(host.relic_tex[relic_id], Rect2(rect.position + Vector2((rect.size.x - 112.0) * 0.5, 50), Vector2(112, 112)))
	host.draw_text("%s　Lv.%d" % [str(rdef.get("name", relic_id)), next_level], rect.position + Vector2(18, 190), 20, host.relic_rarity_color(rarity), true, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 36)
	host.draw_text("%s｜%s" % [rarity_text, "升級" if owned else "新取得"], rect.position + Vector2(18, 216), 14, Color8(179, 187, 177), true, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 36)
	host.draw_wrapped(str(rdef.get("desc", "")), Rect2(rect.position + Vector2(22, 224), Vector2(rect.size.x - 44, 46)), 12, Color8(205, 211, 202), 17.0, true)


static func _draw_equipment_card(host: Node, rect: Rect2, loot: Dictionary) -> void:
	host.draw_panel(rect, Color(0.043, 0.049, 0.047, 0.97), Color8(135, 118, 83), 1.4)
	host.draw_text("裝備掉落", rect.position + Vector2(22, 32), 21, Color8(221, 205, 165), true)
	var equipment_id := str(loot.get("equipment", ""))
	if equipment_id == "" or not host.equipment_defs.has(equipment_id):
		host.draw_centered_text("本次未掉落裝備", rect, 146.0, 18, Color8(146, 153, 146))
		return
	var edef: Dictionary = host.equipment_defs[equipment_id]
	var rarity := str(edef.get("rarity", "common"))
	host.draw_texture_contain(host.equipment_tex[equipment_id], Rect2(rect.position + Vector2((rect.size.x - 112.0) * 0.5, 50), Vector2(112, 112)))
	var equipment_name := "%s｜%s" % [host.equipment_slot_name(str(edef.get("slot", ""))), str(edef.get("name", equipment_id))]
	host.draw_text(equipment_name, rect.position + Vector2(18, 192), 20, host.relic_rarity_color(rarity), true, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 36)
	host.draw_text("掉落裝備｜可於整備頁配置", rect.position + Vector2(18, 216), 14, Color8(179, 187, 177), true, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 36)
	host.draw_wrapped(str(edef.get("desc", "")), Rect2(rect.position + Vector2(22, 224), Vector2(rect.size.x - 44, 46)), 12, Color8(205, 211, 202), 17.0, true)
