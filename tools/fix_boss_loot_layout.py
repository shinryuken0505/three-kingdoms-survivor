from pathlib import Path

path = Path("scripts/main.gd")
text = path.read_text(encoding="utf-8")
start = text.index("func draw_boss_loot_screen() -> void:\n")
end = text.index("\n\nfunc draw_result_screen() -> void:", start)
replacement = '''func draw_boss_loot_screen() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color8(22, 25, 24), true)
	var panel: Rect2 = Rect2(180, 72, 920, 570)
	draw_panel(panel, Color(0.035, 0.04, 0.039, 0.99), Color8(213, 169, 76), 2.4)

	var header: Rect2 = Rect2(235, 92, 810, 94)
	draw_text("敵將擊破", header.position + Vector2(0, 42), 43, Color8(244, 210, 132), true, HORIZONTAL_ALIGNMENT_CENTER, header.size.x)
	draw_text(str(pending_boss_loot.get("boss_name", "敵將")), header.position + Vector2(0, 78), 24, Color8(222, 217, 199), true, HORIZONTAL_ALIGNMENT_CENTER, header.size.x)

	var relic_id: String = str(pending_boss_loot.get("relic", ""))
	var equipment_id: String = str(pending_boss_loot.get("equipment", ""))
	var left: Rect2 = Rect2(235, 205, 375, 270)
	var right: Rect2 = Rect2(670, 205, 375, 270)

	draw_panel(left, Color(0.045, 0.05, 0.05, 0.96), Color8(135, 118, 83), 1.3)
	draw_text("遺物戰利品", left.position + Vector2(24, 34), 21, Color8(221, 205, 165), true)
	if relic_id != "" and relic_defs.has(relic_id):
		draw_texture_contain(relic_tex[relic_id], Rect2(left.position + Vector2(126, 58), Vector2(120, 120)))
		var relic_name: String = "%s　Lv.%d" % [str(relic_defs[relic_id]["name"]), relic_level(relic_id) + 1 if has_relic(relic_id) else 1]
		draw_text(relic_name, left.position + Vector2(24, 204), 20, relic_rarity_color(str(relic_defs[relic_id].get("rarity", "common"))), true, HORIZONTAL_ALIGNMENT_CENTER, left.size.x - 48)
		draw_wrapped(str(relic_defs[relic_id]["desc"]), Rect2(left.position + Vector2(24, 218), Vector2(left.size.x - 48, 42)), 12, Color8(193, 200, 192), 17.0, true)

	draw_panel(right, Color(0.045, 0.05, 0.05, 0.96), Color8(135, 118, 83), 1.3)
	draw_text("裝備掉落", right.position + Vector2(24, 34), 21, Color8(221, 205, 165), true)
	if equipment_id != "" and equipment_defs.has(equipment_id):
		var edef: Dictionary = equipment_defs[equipment_id]
		draw_texture_contain(equipment_tex[equipment_id], Rect2(right.position + Vector2(126, 58), Vector2(120, 120)))
		var equipment_name: String = "%s｜%s" % [equipment_slot_name(str(edef["slot"])), edef["name"]]
		draw_text(equipment_name, right.position + Vector2(24, 204), 20, relic_rarity_color(str(edef.get("rarity", "common"))), true, HORIZONTAL_ALIGNMENT_CENTER, right.size.x - 48)
		draw_wrapped(str(edef["desc"]), Rect2(right.position + Vector2(24, 218), Vector2(right.size.x - 48, 42)), 12, Color8(193, 200, 192), 17.0, true)
	else:
		draw_centered_text("本次未掉落裝備", right, 145.0, 18, Color8(146, 153, 146))

	var coin_rect: Rect2 = Rect2(390, 492, 500, 42)
	draw_centered_text("銅錢 +%d" % int(pending_boss_loot.get("coins", 0)), coin_rect, 28.0, 20, Color8(239, 202, 105), true)
	var button: Rect2 = Rect2(480, 550, 320, 58)
	draw_rect(button, Color(0.48, 0.34, 0.13, 0.92), true)
	draw_centered_text("收下戰利品", button, 37.0, 22, Color8(244, 229, 193), true)
'''
text = text[:start] + replacement + text[end:]
path.write_text(text, encoding="utf-8")
print("boss loot layout repaired")
