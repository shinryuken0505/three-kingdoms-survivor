extends Node2D

## Alpha.18 升級卡精簡來源提示。
## 僅在卡片頂部留出的小空間顯示必要來源，不再繪製 Build 標籤列，
## 避免壓住既有卡名、等級、敘述與 Enter／Space 提示。

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
	var cards: Array[Dictionary] = _offer_metadata()
	var count: int = mini(5, cards.size())
	if count <= 0:
		return
	var columns: int = 3 if count > 3 else count
	var rows: int = 2 if count > 3 else 1
	var card_width: float = 300.0
	var card_height: float = 220.0 if rows == 2 else 360.0
	var start_x: float = 640.0 - float(columns) * card_width * 0.5
	for index in range(count):
		var column: int = index % columns
		var row: int = int(index / columns)
		var card_rect: Rect2 = Rect2(
			start_x + float(column) * card_width + 8.0,
			155.0 + float(row) * (card_height + 14.0),
			card_width - 16.0,
			card_height
		)
		_draw_source_hint(card_rect, cards[index])


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


func _draw_source_hint(card_rect: Rect2, card: Dictionary) -> void:
	var category: StringName = StringName(str(card.get("category", "player_skill")))
	var source_hero_name: String = str(card.get("source_hero_name", ""))
	var entry_tags: Array = card.get("entry_tags", []) as Array
	var text: String = ""
	if category == &"hero_specialization" and not source_hero_name.is_empty():
		text = "主將專精・%s" % source_hero_name
	elif not entry_tags.is_empty():
		text = "新流派入口"
	elif category == &"shared" or category == &"passive":
		text = "共用能力"
	if text.is_empty():
		return
	var hint_rect: Rect2 = Rect2(card_rect.position + Vector2(14.0, 9.0), Vector2(card_rect.size.x - 28.0, 22.0))
	var border: Color = Color(0.80, 0.62, 0.28, 0.90)
	if category == &"hero_specialization":
		border = Color(0.94, 0.68, 0.28, 0.95)
	elif not entry_tags.is_empty():
		border = Color(0.72, 0.43, 0.86, 0.95)
	draw_rect(hint_rect, Color(0.055, 0.06, 0.065, 0.88), true)
	draw_rect(hint_rect, border, false, 1.0)
	_draw_centered_text(text, hint_rect, 11, Color(0.92, 0.86, 0.70), true)


func _draw_centered_text(text: String, rect: Rect2, size: int, color: Color, bold: bool = false) -> void:
	var font_value: Font = _font_bold if bold else _font
	var width: float = font_value.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var x: float = rect.position.x + maxf(4.0, (rect.size.x - width) * 0.5)
	var y: float = rect.position.y + rect.size.y * 0.5 + float(size) * 0.35
	draw_string(font_value, Vector2(x, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
