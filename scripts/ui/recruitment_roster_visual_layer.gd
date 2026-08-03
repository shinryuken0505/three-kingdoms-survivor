extends Node2D

## 招賢館位置選擇與滿額替換的統一視覺層。
## 沿用 main.gd 既有輸入與欄位，只將資訊層級、名將流向與焦點重新呈現。

const TARGET_LABELS = ["編入主戰", "編入後備", "留在營地", "取消招募"]

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
	visible = _should_draw()
	if visible:
		queue_redraw()


func _should_draw() -> bool:
	if _main == null:
		return false
	if bool(_main.get("hero_position_picker_open")):
		return true
	return str(_main.get("screen")) == "config_replace" and not str(_main.get("config_candidate")).is_empty()


func _draw() -> void:
	if not _should_draw():
		return
	_draw_dim()
	if bool(_main.get("hero_position_picker_open")):
		_draw_position_picker()
	else:
		_draw_replacement_picker()


func _draw_dim() -> void:
	draw_rect(Rect2(0, 0, 1280, 720), Color(0.015, 0.02, 0.025, 0.78), true)


func _draw_position_picker() -> void:
	var hero_id: String = str(_main.get("hero_position_candidate"))
	var hero_name: String = _hero_name(hero_id)
	var selected: int = clampi(int(_main.get("hero_position_index")), 0, TARGET_LABELS.size() - 1)
	var panel := Rect2(190, 92, 900, 536)
	_draw_panel(panel)
	_draw_text("招賢館・安排名將去向", Vector2(230, 142), 28, Color(0.96, 0.81, 0.46), true)
	_draw_text("%s 已接受邀請，請決定本次編成位置。" % hero_name, Vector2(230, 177), 17, Color(0.82, 0.84, 0.86))
	_draw_roster_capacity(Vector2(230, 214))

	for index in range(TARGET_LABELS.size()):
		var rect := Rect2(230, 270 + index * 70, 820, 54)
		var chosen: bool = index == selected
		var available: bool = _target_available(index)
		var fill := Color(0.34, 0.24, 0.10, 0.98) if chosen else Color(0.10, 0.115, 0.125, 0.98)
		var border := Color(0.98, 0.76, 0.30, 1.0) if chosen else Color(0.38, 0.40, 0.42, 0.9)
		draw_rect(rect, fill, true)
		draw_rect(rect, border, false, 2.0 if chosen else 1.0)
		var suffix: String = _target_suffix(index, available)
		var color := Color(1.0, 0.92, 0.70) if chosen else (Color(0.76, 0.79, 0.81) if available else Color(0.66, 0.54, 0.43))
		_draw_text("%s%s" % [TARGET_LABELS[index], suffix], rect.position + Vector2(22, 34), 17, color, chosen)
	_draw_text("位置已滿時會進入替換名單，不會直接覆蓋或遺失原名將。", Vector2(230, 580), 14, Color(0.62, 0.66, 0.69))


func _draw_replacement_picker() -> void:
	var hero_id: String = str(_main.get("config_candidate"))
	var hero_name: String = _hero_name(hero_id)
	var mode: String = str(_main.get("config_replace_mode"))
	var pool: Array = _main.get("active_heroes") as Array if mode == "active" else _main.get("reserve_heroes") as Array
	var selected: int = clampi(int(_main.get("config_replace_index")), 0, pool.size())
	var mode_label: String = "主戰" if mode == "active" else "後備"
	var panel := Rect2(170, 72, 940, 576)
	_draw_panel(panel)
	_draw_text("%s名額已滿・選擇替換" % mode_label, Vector2(212, 124), 28, Color(0.96, 0.81, 0.46), true)
	_draw_text("將 %s 編入%s，原名將會自動轉往安全位置。" % [hero_name, mode_label], Vector2(212, 160), 17, Color(0.82, 0.84, 0.86))

	var max_rows: int = mini(pool.size() + 1, 6)
	for index in range(max_rows):
		var rect := Rect2(212, 202 + index * 64, 856, 50)
		var chosen: bool = index == selected
		draw_rect(rect, Color(0.34, 0.24, 0.10, 0.98) if chosen else Color(0.10, 0.115, 0.125, 0.98), true)
		draw_rect(rect, Color(0.98, 0.76, 0.30, 1.0) if chosen else Color(0.38, 0.40, 0.42, 0.9), false, 2.0 if chosen else 1.0)
		var label: String
		if index >= pool.size():
			label = "取消替換，返回位置選擇"
		else:
			var replaced_id: String = str(pool[index])
			label = "%s　→　%s" % [_hero_name(replaced_id), _replacement_destination(mode)]
		_draw_text(label, rect.position + Vector2(20, 32), 16, Color(1.0, 0.92, 0.70) if chosen else Color(0.78, 0.80, 0.82), chosen)
	_draw_text("確認後會同步更新圖鑑、技能、羈絆與主動冷卻。", Vector2(212, 610), 14, Color(0.62, 0.66, 0.69))


func _draw_roster_capacity(position: Vector2) -> void:
	var active: Array = _main.get("active_heroes") as Array
	var reserve: Array = _main.get("reserve_heroes") as Array
	var camp: Array = _main.get("camp_heroes") as Array
	var active_limit: int = int(_main.call("active_limit")) if _main.has_method("active_limit") else active.size()
	var reserve_limit: int = int(_main.call("reserve_limit")) if _main.has_method("reserve_limit") else reserve.size()
	_draw_text("主戰 %d／%d　　後備 %d／%d　　營地 %d" % [active.size(), active_limit, reserve.size(), reserve_limit, camp.size()], position, 16, Color(0.74, 0.77, 0.80), true)


func _target_available(index: int) -> bool:
	if index >= 2:
		return true
	var active: Array = _main.get("active_heroes") as Array
	var reserve: Array = _main.get("reserve_heroes") as Array
	if index == 0:
		var limit: int = int(_main.call("active_limit")) if _main.has_method("active_limit") else active.size()
		return active.size() < limit
	var reserve_limit: int = int(_main.call("reserve_limit")) if _main.has_method("reserve_limit") else reserve.size()
	return reserve.size() < reserve_limit


func _target_suffix(index: int, available: bool) -> String:
	if index >= 2:
		return ""
	return "（有空位）" if available else "（已滿，需替換）"


func _replacement_destination(mode: String) -> String:
	return "後援／營地" if mode == "active" else "營地"


func _hero_name(hero_id: String) -> String:
	var heroes_value: Variant = _main.get("heroes")
	if heroes_value is Dictionary:
		var heroes: Dictionary = heroes_value as Dictionary
		var definition: Dictionary = heroes.get(hero_id, {}) as Dictionary
		return str(definition.get("name", hero_id))
	return hero_id


func _draw_panel(rect: Rect2) -> void:
	draw_rect(rect, Color(0.065, 0.075, 0.085, 0.99), true)
	draw_rect(rect, Color(0.77, 0.61, 0.30, 0.95), false, 2.0)


func _draw_text(text: String, position: Vector2, size: int, color: Color, bold: bool = false) -> void:
	draw_string(_font_bold if bold else _font, position, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
