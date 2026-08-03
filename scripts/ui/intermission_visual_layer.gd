extends Node2D

## Alpha.18 章間整備新版視覺層。
## 僅負責繪製，不接管輸入；既有 main.gd 的 option_index 與操作流程保持不變。

const VIEW_SIZE := Vector2(1280.0, 720.0)

var _main: Node = null
var _font: Font = null
var _font_bold: Font = null


func _ready() -> void:
	_main = get_parent()
	_font = SystemFont.new()
	(_font as SystemFont).font_names = PackedStringArray(["Microsoft JhengHei", "Noto Sans CJK TC", "Arial"])
	_font_bold = SystemFont.new()
	(_font_bold as SystemFont).font_names = (_font as SystemFont).font_names
	(_font_bold as SystemFont).font_weight = 700
	set_process(true)


func _process(_delta: float) -> void:
	visible = _main != null and str(_main.get("screen")) == "intermission"
	if visible:
		queue_redraw()


func _draw() -> void:
	if _main == null or str(_main.get("screen")) != "intermission":
		return
	_draw_backdrop()
	_draw_header()
	_draw_information_panels()
	_draw_action_row()


func _draw_backdrop() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW_SIZE), Color(0.035, 0.045, 0.055, 0.97), true)
	draw_rect(Rect2(34, 26, 1212, 650), Color(0.075, 0.085, 0.095, 0.98), true)
	draw_rect(Rect2(34, 26, 1212, 650), Color(0.73, 0.59, 0.31, 0.85), false, 2.0)


func _draw_header() -> void:
	var chapter: Dictionary = _safe_call_dictionary("current_chapter")
	var chapter_title: String = str(chapter.get("title", "亂世旅程"))
	var place: String = str(chapter.get("place", ""))
	_draw_text("章間整備", Vector2(64, 66), 32, Color(0.96, 0.84, 0.52), true)
	_draw_text("上一章：%s%s" % [chapter_title, "・%s" % place if not place.is_empty() else ""], Vector2(64, 98), 18, Color(0.80, 0.82, 0.84))
	_draw_text("整理戰果、調整名將與裝備，再決定下一步。", Vector2(64, 124), 16, Color(0.64, 0.68, 0.72))


func _draw_information_panels() -> void:
	var left := Rect2(58, 154, 372, 354)
	var middle := Rect2(454, 154, 372, 354)
	var right := Rect2(850, 154, 372, 354)
	_draw_panel(left, "上一章結果", _previous_result_lines())
	_draw_panel(middle, "承接資源", _carry_over_lines())
	_draw_panel(right, "史勢演變與整備", _history_and_roster_lines())


func _draw_panel(rect: Rect2, title: String, lines: Array[String]) -> void:
	draw_rect(rect, Color(0.105, 0.115, 0.125, 0.98), true)
	draw_rect(rect, Color(0.42, 0.44, 0.46, 0.85), false, 1.5)
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, 44)), Color(0.16, 0.15, 0.13, 0.96), true)
	_draw_text(title, rect.position + Vector2(18, 29), 19, Color(0.94, 0.80, 0.48), true)
	var y: float = rect.position.y + 72.0
	for line in lines.slice(0, 10):
		_draw_text("• %s" % line, Vector2(rect.position.x + 18, y), 15, Color(0.84, 0.86, 0.87))
		y += 27.0


func _draw_action_row() -> void:
	var options: Array = _safe_call_array("intermission_options")
	if options.is_empty():
		return
	var selected: int = clampi(int(_main.get("option_index")), 0, options.size() - 1)
	var gap: float = 12.0
	var row := Rect2(58, 538, 1164, 106)
	var width: float = (row.size.x - gap * float(options.size() - 1)) / float(options.size())
	for index in range(options.size()):
		var rect := Rect2(row.position.x + index * (width + gap), row.position.y, width, 70)
		var is_selected: bool = index == selected
		var fill := Color(0.34, 0.25, 0.12, 0.98) if is_selected else Color(0.12, 0.13, 0.14, 0.98)
		var border := Color(0.98, 0.77, 0.34, 1.0) if is_selected else Color(0.38, 0.40, 0.42, 0.9)
		draw_rect(rect, fill, true)
		draw_rect(rect, border, false, 2.0 if is_selected else 1.0)
		_draw_centered_text(str(options[index]), rect, 16, Color(1.0, 0.92, 0.72) if is_selected else Color(0.78, 0.80, 0.82), is_selected)
	_draw_text("方向鍵選擇　Enter／Space 確認　Esc 返回主選單", Vector2(58, 631), 14, Color(0.58, 0.61, 0.64))


func _previous_result_lines() -> Array[String]:
	var stats_value: Variant = _main.get("run_stats")
	var stats: Dictionary = stats_value as Dictionary if stats_value is Dictionary else {}
	return [
		"擊敗敵軍：%d" % int(stats.get("kills", stats.get("enemies_defeated", 0))),
		"精英擊破：%d" % int(stats.get("elite_kills", 0)),
		"承受傷害：%d" % int(round(float(stats.get("damage_taken", 0.0)))),
		"取得銅錢：%d" % int(stats.get("coins_gained", 0)),
		"完成章節後已自動建立存檔。",
	]


func _carry_over_lines() -> Array[String]:
	var player_value: Variant = _main.get("player")
	var player: Dictionary = player_value as Dictionary if player_value is Dictionary else {}
	var relics: Array = _main.get("relics") as Array
	var equipment: Array = _main.get("equipment_inventory") as Array
	return [
		"主角等級：Lv.%d" % int(player.get("level", 1)),
		"目前生命：%d／%d" % [int(round(float(player.get("hp", 0.0)))), int(round(float(player.get("max_hp", 0.0))))],
		"持有銅錢：%d" % int(player.get("coins", _main.get("coins") if _main.get("coins") != null else 0)),
		"遺物數量：%d" % relics.size(),
		"裝備庫存：%d" % equipment.size(),
	]


func _history_and_roster_lines() -> Array[String]:
	var result: Array[String] = []
	var history_value: Variant = _main.get("history_log")
	if history_value is Array:
		var history: Array = history_value as Array
		var start: int = maxi(0, history.size() - 4)
		for index in range(start, history.size()):
			result.append(str(history[index]))
	var active: Array = _main.get("active_heroes") as Array
	var reserve: Array = _main.get("reserve_heroes") as Array
	var camp: Array = _main.get("camp_heroes") as Array
	result.append("主戰名將：%d　後備：%d　營地：%d" % [active.size(), reserve.size(), camp.size()])
	if result.size() == 1:
		result.push_front("本章尚未留下新的史勢紀錄。")
	return result


func _safe_call_dictionary(method_name: String) -> Dictionary:
	if _main.has_method(method_name):
		var value: Variant = _main.call(method_name)
		if value is Dictionary:
			return value as Dictionary
	return {}


func _safe_call_array(method_name: String) -> Array:
	if _main.has_method(method_name):
		var value: Variant = _main.call(method_name)
		if value is Array:
			return value as Array
	return []


func _draw_text(text: String, position: Vector2, size: int, color: Color, bold: bool = false) -> void:
	draw_string(_font_bold if bold else _font, position, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


func _draw_centered_text(text: String, rect: Rect2, size: int, color: Color, bold: bool = false) -> void:
	var font_value: Font = _font_bold if bold else _font
	var width: float = font_value.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var x: float = rect.position.x + maxf(8.0, (rect.size.x - width) * 0.5)
	var y: float = rect.position.y + rect.size.y * 0.5 + size * 0.36
	draw_string(font_value, Vector2(x, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
