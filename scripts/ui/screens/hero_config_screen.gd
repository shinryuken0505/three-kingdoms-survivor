class_name HeroConfigScreen
extends RefCounted

## 名將整備主畫面的純排版與顯示資料轉換。
## 不直接修改主戰、後備或營地陣列；所有編成規則交由 HeroRosterController。

const VIEW_SIZE: Vector2 = Vector2(1280.0, 720.0)
const OUTER_MARGIN: float = 34.0
const HEADER_HEIGHT: float = 66.0
const FOOTER_HEIGHT: float = 66.0
const COLUMN_GAP: float = 18.0


static func layout(view_size: Vector2 = VIEW_SIZE) -> Dictionary:
	var safe: Rect2 = Rect2(
		Vector2(OUTER_MARGIN, OUTER_MARGIN),
		view_size - Vector2(OUTER_MARGIN * 2.0, OUTER_MARGIN * 2.0)
	)
	var header: Rect2 = Rect2(safe.position, Vector2(safe.size.x, HEADER_HEIGHT))
	var footer: Rect2 = Rect2(
		Vector2(safe.position.x, safe.end.y - FOOTER_HEIGHT),
		Vector2(safe.size.x, FOOTER_HEIGHT)
	)
	var content: Rect2 = Rect2(
		Vector2(safe.position.x, header.end.y + 12.0),
		Vector2(safe.size.x, footer.position.y - header.end.y - 24.0)
	)
	var list_width: float = 420.0
	var roster_width: float = 306.0
	var detail_width: float = content.size.x - list_width - roster_width - COLUMN_GAP * 2.0
	return {
		"safe": safe,
		"header": header,
		"footer": footer,
		"content": content,
		"hero_list": Rect2(content.position, Vector2(list_width, content.size.y)),
		"roster": Rect2(
			Vector2(content.position.x + list_width + COLUMN_GAP, content.position.y),
			Vector2(roster_width, content.size.y)
		),
		"detail": Rect2(
			Vector2(content.position.x + list_width + roster_width + COLUMN_GAP * 2.0, content.position.y),
			Vector2(detail_width, content.size.y)
		),
	}


static func visible_rows(total_count: int, selected_index: int, max_rows: int = 9) -> Dictionary:
	return TextLayout.visible_range(total_count, selected_index, max_rows)


static func state_label_key(state: StringName) -> StringName:
	match state:
		HeroRosterManager.ACTIVE:
			return &"ui.hero_config.state.active"
		HeroRosterManager.RESERVE:
			return &"ui.hero_config.state.reserve"
		HeroRosterManager.CAMP:
			return &"ui.hero_config.state.camp"
		_:
			return &"ui.hero_config.state.unknown"


static func state_badge_colors(state: StringName) -> Dictionary:
	return StatusBadgeRenderer.state_colors(state)


static func footer_hint_keys(position_picker_open: bool, replacement_open: bool) -> Array[StringName]:
	if replacement_open:
		return [&"ui.common.move", &"ui.common.confirm", &"ui.common.cancel"]
	if position_picker_open:
		return [&"ui.common.move", &"ui.common.confirm", &"ui.common.cancel"]
	return [&"ui.common.move", &"ui.hero_config.change_position", &"ui.common.back"]
