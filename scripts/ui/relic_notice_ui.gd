class_name RelicNoticeUI
extends RefCounted


static func draw(host: Node, notice: Dictionary) -> void:
	if notice.is_empty():
		return
	var rid := str(notice.get("id", ""))
	if rid == "" or not host.relic_defs.has(rid):
		return
	var rdef: Dictionary = host.relic_defs[rid]
	var overlay := Color(0.0, 0.0, 0.0, 0.72)
	host.draw_rect(Rect2(Vector2.ZERO, host.VIEW), overlay, true)
	var panel_size := Vector2(660.0, 430.0)
	var panel := Rect2((host.VIEW - panel_size) * 0.5, panel_size)
	var rarity := str(rdef.get("rarity", "common"))
	var accent: Color = host.relic_rarity_color(rarity)
	host.draw_panel(panel, Color(0.035, 0.041, 0.039, 0.995), accent, 2.8)
	var upgraded := bool(notice.get("upgraded", false))
	var title := "遺物升級" if upgraded else "取得新遺物"
	host.draw_text(title, panel.position + Vector2(0, 48), 34, Color8(244, 218, 157), true, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x)
	host.draw_texture_contain(host.relic_tex[rid], Rect2(panel.position + Vector2(54, 92), Vector2(166, 166)))
	var old_level := int(notice.get("old_level", 0))
	var new_level := int(notice.get("new_level", 1))
	host.draw_text(str(rdef.get("name", rid)), panel.position + Vector2(250, 116), 28, accent, true)
	var level_text := "Lv.%d → Lv.%d" % [old_level, new_level] if upgraded else "Lv.%d" % new_level
	host.draw_text(level_text, panel.position + Vector2(250, 151), 21, Color8(232, 218, 184), true)
	var tags: Array = rdef.get("tags", []) as Array
	var tag_text := "｜".join(tags.map(func(v): return str(v)))
	if tag_text == "":
		tag_text = "通用流派"
	host.draw_text(tag_text, panel.position + Vector2(250, 182), 15, Color8(170, 184, 174), true)
	host.draw_wrapped(str(rdef.get("desc", "")), Rect2(panel.position + Vector2(250, 207), Vector2(350, 94)), 17, Color8(215, 220, 211), 24.0, true)
	var reason := str(notice.get("reason", ""))
	if reason != "":
		host.draw_text(reason, panel.position + Vector2(54, 300), 15, Color8(164, 169, 159), true, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 108)
	var button := Rect2(Vector2(panel.get_center().x - 150.0, panel.end.y - 78.0), Vector2(300.0, 52.0))
	host.draw_rect(button, Color(0.46, 0.32, 0.12, 0.96), true)
	host.draw_rect(button, Color8(237, 205, 132), false, 2.0)
	host.draw_centered_text("確認收下", button, 34.0, 21, Color8(250, 237, 203), true)
