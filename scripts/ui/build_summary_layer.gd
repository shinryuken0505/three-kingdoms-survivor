extends Node2D

## Alpha.18 主角 Build 摘要顯示層。
##
## 在升級與 TAB 畫面右上角顯示目前主角路線、核心標籤及已投入的核心能力。
## 不接管輸入，也不覆寫 main.gd 的既有 UI。

const OfferServiceScript = preload("res://scripts/systems/progression/levelup_offer_service.gd")

var _main: Node = null


func _ready() -> void:
	_main = get_parent()
	z_index = 120
	set_process(true)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if _main == null:
		return
	var screen: String = str(_main.get("screen"))
	if screen != "levelup" and screen != "tab":
		return
	var player_value: Variant = _main.get("player")
	var levels_value: Variant = _main.get("skill_levels")
	if not (player_value is Dictionary) or not (levels_value is Dictionary):
		return
	var player: Dictionary = player_value as Dictionary
	if player.is_empty():
		return
	var summary: Dictionary = OfferServiceScript.build_summary(player, levels_value as Dictionary)
	_draw_panel(summary, screen)


func _draw_panel(summary: Dictionary, screen: String) -> void:
	var font_value: Variant = _main.get("font")
	if not (font_value is Font):
		return
	var ui_font: Font = font_value as Font
	var rect: Rect2 = Rect2(968, 18, 292, 112 if screen == "levelup" else 132)
	draw_rect(rect, Color(0.055, 0.045, 0.035, 0.92), true)
	draw_rect(rect, Color(0.82, 0.66, 0.34, 0.85), false, 2.0)
	draw_string(ui_font, rect.position + Vector2(14, 25), "目前路線｜%s" % str(summary.get("path_name", "通用成長")), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.98, 0.86, 0.58))
	var tag_text: String = "標籤：%s" % _joined(summary.get("tags", []) as Array, "／")
	draw_string(ui_font, rect.position + Vector2(14, 52), tag_text, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 28, 14, Color(0.88, 0.88, 0.86))
	var developed: Array = summary.get("developed", []) as Array
	var progress_text: String = "核心投入：尚未成形"
	if not developed.is_empty():
		progress_text = "核心投入：%s" % _skill_names(developed)
	draw_string(ui_font, rect.position + Vector2(14, 78), progress_text, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 28, 14, Color(0.76, 0.84, 0.91))
	if screen == "tab":
		draw_string(ui_font, rect.position + Vector2(14, 105), "升級將優先提供符合此路線的核心能力。", HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 28, 13, Color(0.72, 0.72, 0.70))


func _skill_names(skill_ids: Array) -> String:
	var definitions_value: Variant = _main.get("skill_defs")
	if not (definitions_value is Dictionary):
		return _joined(skill_ids, "、")
	var definitions: Dictionary = definitions_value as Dictionary
	var names: Array[String] = []
	for value in skill_ids:
		var skill_id: String = str(value)
		var definition: Dictionary = definitions.get(skill_id, {}) as Dictionary
		names.append(str(definition.get("name", skill_id)))
	return "、".join(names)


func _joined(values: Array, separator: String) -> String:
	var strings: Array[String] = []
	for value in values:
		strings.append(str(value))
	return separator.join(strings)
