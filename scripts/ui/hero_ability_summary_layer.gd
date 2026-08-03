extends Node2D

## Alpha.18 TAB 名將能力分層摘要。
## 顯示主戰專精、後備被動與營地傳承狀態，不接管 TAB 輸入。

const HeroAbilityCatalogScript = preload("res://scripts/data/hero_ability_layer_catalog.gd")

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
	visible = _main != null and str(_main.get("screen")) == "tab"
	if visible:
		queue_redraw()


func _draw() -> void:
	if _main == null or str(_main.get("screen")) != "tab":
		return
	var heroes_value: Variant = _main.get("heroes")
	if not (heroes_value is Dictionary):
		return
	var heroes: Dictionary = heroes_value as Dictionary
	var panel := Rect2(812, 118, 422, 492)
	draw_rect(panel, Color(0.055, 0.065, 0.075, 0.97), true)
	draw_rect(panel, Color(0.74, 0.59, 0.29, 0.92), false, 2.0)
	_draw_text("名將能力分層", panel.position + Vector2(20, 35), 21, Color(0.96, 0.82, 0.50), true)
	_draw_text("主戰專精不會混入一般主角卡池", panel.position + Vector2(20, 61), 13, Color(0.63, 0.68, 0.72))

	var y: float = panel.position.y + 92.0
	y = _draw_group("主戰・專精", _array_property("active_heroes"), &"active", heroes, y, 3)
	y += 12.0
	y = _draw_group("後備・被動", _array_property("reserve_heroes"), &"reserve", heroes, y, 3)
	y += 12.0
	_draw_group("營地・傳承待解鎖", _array_property("camp_heroes"), &"camp", heroes, y, 2)


func _draw_group(title: String, hero_ids: Array, position: StringName, heroes: Dictionary, start_y: float, max_rows: int) -> float:
	_draw_text(title, Vector2(832, start_y), 15, Color(0.88, 0.72, 0.40), true)
	var y: float = start_y + 25.0
	if hero_ids.is_empty():
		_draw_text("— 尚無名將 —", Vector2(844, y), 13, Color(0.52, 0.56, 0.59))
		return y + 21.0
	var rows: int = mini(hero_ids.size(), max_rows)
	for index in range(rows):
		var hero_id: String = str(hero_ids[index])
		var hero_def: Dictionary = heroes.get(hero_id, {}) as Dictionary
		var layer: Dictionary = HeroAbilityCatalogScript.layer_for_position(hero_id, position, heroes)
		var hero_name: String = str(hero_def.get("name", hero_id))
		var ability_name: String = str(layer.get("name", "未設定"))
		var tags: String = _tags_text(layer.get("build_tags", []) as Array)
		_draw_text("%s｜%s" % [hero_name, ability_name], Vector2(844, y), 13, Color(0.84, 0.87, 0.89), true)
		y += 19.0
		if not tags.is_empty():
			_draw_text(tags, Vector2(856, y), 11, Color(0.58, 0.70, 0.73))
			y += 17.0
	if hero_ids.size() > rows:
		_draw_text("另有 %d 名" % (hero_ids.size() - rows), Vector2(844, y), 11, Color(0.58, 0.61, 0.64))
		y += 17.0
	return y


func _array_property(property_name: String) -> Array:
	var value: Variant = _main.get(property_name)
	if value is Array:
		return value as Array
	return []


func _tags_text(tags: Array) -> String:
	var labels: Array[String] = []
	for value in tags:
		var label: String = _tag_label(StringName(str(value)))
		if not label.is_empty() and not labels.has(label):
			labels.append(label)
	return "Build：%s" % "／".join(labels) if not labels.is_empty() else ""


func _tag_label(tag: StringName) -> String:
	if tag == &"melee":
		return "近戰"
	if tag == &"ranged":
		return "遠戰"
	if tag == &"projectile":
		return "投射"
	if tag == &"poison" or tag == &"ailment":
		return "毒／異常"
	if tag == &"control":
		return "控制"
	if tag == &"support" or tag == &"shared":
		return "支援"
	return String(tag)


func _draw_text(text: String, position: Vector2, size: int, color: Color, bold: bool = false) -> void:
	var font_value: Font = _font_bold if bold else _font
	draw_string(font_value, position, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
