class_name BossLootUI
extends RefCounted


static func draw(host: Node, loot: Dictionary) -> void:
	host.draw_rect(Rect2(Vector2.ZERO, host.VIEW), Color8(22, 25, 24), true)
	var panel := Rect2(180, 72, 920, 570)
	host.draw_panel(panel, Color(0.035, 0.04, 0.039, 0.99), Color8(213, 169, 76), 2.4)

	var header := Rect2(235, 92, 810, 94)
	host.draw_text("敵將擊破", header.position + Vector2(0, 42), 43, Color8(244, 210, 132), true, HORIZONTAL_ALIGNMENT_CENTER, header.size.x)
	host.draw_text(str(loot.get("boss_name", "敵將")), header.position + Vector2(0, 78), 24, Color8(222, 217, 199), true, HORIZONTAL_ALIGNMENT_CENTER, header.size.x)

	var relic_id := str(loot.get("relic", ""))
	var equipment_id := str(loot.get("equipment", ""))
	var left := Rect2(235, 205, 375, 270)
	var right := Rect2(670, 205, 375, 270)

	host.draw_panel(left, Color(0.045, 0.05, 0.05, 0.96), Color8(135, 118, 83), 1.3)
	host.draw_text("遺物戰利品", left.position + Vector2(24, 34), 21, Color8(221, 205, 165), true)
	if relic_id != "" and host.relic_defs.has(relic_id):
		host.draw_texture_contain(host.relic_tex[relic_id], Rect2(left.position + Vector2(126, 58), Vector2(120, 120)))
		var relic_name := "%s　Lv.%d" % [str(host.relic_defs[relic_id]["name"]), host.relic_level(relic_id) + 1 if host.has_relic(relic_id) else 1]
		host.draw_text(relic_name, left.position + Vector2(24, 204), 20, host.relic_rarity_color(str(host.relic_defs[relic_id].get("rarity", "common"))), true, HORIZONTAL_ALIGNMENT_CENTER, left.size.x - 48)
		host.draw_wrapped(str(host.relic_defs[relic_id]["desc"]), Rect2(left.position + Vector2(24, 218), Vector2(left.size.x - 48, 42)), 12, Color8(193, 200, 192), 17.0, true)

	host.draw_panel(right, Color(0.045, 0.05, 0.05, 0.96), Color8(135, 118, 83), 1.3)
	host.draw_text("裝備掉落", right.position + Vector2(24, 34), 21, Color8(221, 205, 165), true)
	if equipment_id != "" and host.equipment_defs.has(equipment_id):
		var edef: Dictionary = host.equipment_defs[equipment_id]
		host.draw_texture_contain(host.equipment_tex[equipment_id], Rect2(right.position + Vector2(126, 58), Vector2(120, 120)))
		var equipment_name := "%s｜%s" % [host.equipment_slot_name(str(edef["slot"])), edef["name"]]
		host.draw_text(equipment_name, right.position + Vector2(24, 204), 20, host.relic_rarity_color(str(edef.get("rarity", "common"))), true, HORIZONTAL_ALIGNMENT_CENTER, right.size.x - 48)
		host.draw_wrapped(str(edef["desc"]), Rect2(right.position + Vector2(24, 218), Vector2(right.size.x - 48, 42)), 12, Color8(193, 200, 192), 17.0, true)
	else:
		host.draw_centered_text("本次未掉落裝備", right, 145.0, 18, Color8(146, 153, 146))

	var coin_rect := Rect2(390, 492, 500, 42)
	host.draw_centered_text("銅錢 +%d" % int(loot.get("coins", 0)), coin_rect, 28.0, 20, Color8(239, 202, 105), true)
	var button := Rect2(480, 550, 320, 58)
	host.draw_rect(button, Color(0.48, 0.34, 0.13, 0.92), true)
	host.draw_centered_text("收下戰利品", button, 37.0, 22, Color8(244, 229, 193), true)
