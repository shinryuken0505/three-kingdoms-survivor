extends Node2D

## Alpha.18 升級卡來源與 Build 標籤顯示層。
## 僅覆蓋補充資訊，不接管輸入，也不修改既有升級卡點擊區域。

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
	visible = _main != null and str(_main.get("screen")) == "levelup"
	if visible:
		queue_redraw()


func _draw() -> void:
	if _main == null or str(_main.get("screen")) != "levelup":
		return
	var choices: Array[Dictionary] = _offer_metadata()
	for index in range(choices.size()):
		_draw_card_metadata(index, choices[index])


func _offer_metadata() -> Array[Dictionary]:
	var integration: Node = _main.get_node_or_null("LevelupPoolIntegrationLayer")
	if integration == null or not integration.has_method("get_offer_metadata"):
		return []
	var value: Variant = integration.call("get_offer_metadata")
	if not (value is Array):
		return []
	var result: Array[Dictionary] = []
	for item in value as Array:
		if item is Dictionary:
			result.append(item as Dictionary)
	return result


func _draw_card_metadata(index: int, card: Dictionary) -> void:
	var col: int = index % 3
	var row: int = int(index / 3)
	var card_rect := Rect2(198 + col * 300, 188 + row * 230, 286, 220)
	var source_label: String = _source_label(StringName(str(card.get("category", "player_skill"))))
	var source_rect := Rect2(card_rect.position + Vector2(14, 12), Vector2(102, 24))
	draw_rect(source_rect, Color(0.07, 0.08, 0.09, 0.90), true)
	draw_rect(source_rect, Color(0.85, 0.68, 0.30, 0.95), false, 1.0)
	_draw_centered_text(source_label, source_rect, 12, Color(0.96, 0.86, 0.61), true)

	var source_hero_name: String = str(card.get("source_hero_name", ""))
	if not source_hero_name.is_empty():
		var hero_rect := Rect2(card_rect.position + Vector2(122, 12), Vector2(146, 24))
		draw_rect(hero_rect, Color(0.14, 0.10, 0.06, 0.94), true)
		draw_rect(hero_rect, Color(0.92, 0.65, 0.27, 0.95), false, 1.0)
		_draw_centered_text("來源：%s" % source_hero_name, hero_rect, 11, Color(1.0, 0.88, 0.62), true)

	var tags: Array[String] = _display_tags(card)
	var x: float = card_rect.position.x + 14.0
	var y: float = card_rect.end.y - 33.0
	for tag in tags:
		var width: float = clampf(_font.get_string_size(tag, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x + 18.0, 48.0, 92.0)
		if x + width > card_rect.end.x - 12.0:
			break
		var tag_rect := Rect2(Vector2(x, y), Vector2(width, 21))
		draw_rect(tag_rect, Color(0.12, 0.14, 0.16, 0.92), true)
		draw_rect(tag_rect, Color(0.38, 0.46, 0.50, 0.90), false, 1.0)
		_draw_centered_text(tag, tag_rect, 11, Color(0.80, 0.86, 0.88))
		x += width + 7.0

	var entry_tags: Array = card.get("entry_tags", []) as Array
	if not entry_tags.is_empty() and source_hero_name.is_empty():
		var entry_rect := Rect2(card_rect.position + Vector2(126, 12), Vector2(142, 24))
		draw_rect(entry_rect, Color(0.22, 0.10, 0.28, 0.94), true)
		draw_rect(entry_rect, Color(0.82, 0.46, 0.95, 0.95), false, 1.0)
		_draw_centered_text("新流派入口", entry_rect, 12, Color(0.95, 0.82, 1.0), true)


func _source_label(category: StringName) -> String:
	if category == &"shared":
		return "共用強化"
	if category == &"passive":
		return "共用被動"
	if category == &"hero_specialization":
		return "主將專精"
	if category == &"legacy_art":
		return "傳承戰法"
	return "主角技能"


func _display_tags(card: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for value in card.get("build_tags", []) as Array:
		var label: String = _tag_label(StringName(str(value)))
		if not label.is_empty() and not result.has(label):
			result.append(label)
		if result.size() >= 3:
			break
	return result


func _tag_label(tag: StringName) -> String:
	if tag == &"melee":
		return "近戰"
	if tag == &"ranged":
		return "遠戰"
	if tag == &"projectile":
		return "投射"
	if tag == &"poison" or tag == &"ailment":
		return "毒／異常"
	if tag == &"survival":
		return "生存"
	if tag == &"recovery":
		return "恢復"
	if tag == &"mobility":
		return "機動"
	if tag == &"hero":
		return "名將"
	if tag == &"crit":
		return "暴擊"
	if tag == &"control":
		return "控制"
	if tag == &"support" or tag == &"shared":
		return "泛用"
	return ""


func _draw_centered_text(text: String, rect: Rect2, size: int, color: Color, bold: bool = false) -> void:
	var font_value: Font = _font_bold if bold else _font
	var width: float = font_value.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var x: float = rect.position.x + maxf(4.0, (rect.size.x - width) * 0.5)
	var y: float = rect.position.y + rect.size.y * 0.5 + size * 0.35
	draw_string(font_value, Vector2(x, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
