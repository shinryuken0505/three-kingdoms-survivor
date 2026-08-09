class_name HeroConfigScreen
extends RefCounted

## 名將整備主畫面的純排版與顯示資料轉換。
## 不直接修改主戰、後備或營地陣列；所有編成規則交由 HeroRosterController。
##
## Alpha.57 hotfix：欄位寬度由安全區比例推導，不再以 420 / 306 固定像素硬排，
## 避免視窗縮放、不同長寬比與文字膨脹時右側資訊被推出畫面。

const VIEW_SIZE: Vector2 = Vector2(1280.0, 720.0)
const OUTER_MARGIN: float = 34.0
const HEADER_HEIGHT: float = 66.0
const FOOTER_HEIGHT: float = 66.0
const COLUMN_GAP: float = 18.0
const LIST_RATIO: float = 0.37
const ROSTER_RATIO: float = 0.27
const MIN_LIST_WIDTH: float = 280.0
const MIN_ROSTER_WIDTH: float = 220.0
const MIN_DETAIL_WIDTH: float = 260.0


static func layout(view_size: Vector2 = VIEW_SIZE) -> Dictionary:
	var width: float = maxf(1.0, view_size.x)
	var height: float = maxf(1.0, view_size.y)
	var margin: float = minf(OUTER_MARGIN, minf(width * 0.04, height * 0.04))
	var safe_size: Vector2 = Vector2(
		maxf(0.0, width - margin * 2.0),
		maxf(0.0, height - margin * 2.0)
	)
	var safe: Rect2 = Rect2(Vector2(margin, margin), safe_size)
	var header_height: float = minf(HEADER_HEIGHT, safe.size.y * 0.12)
	var footer_height: float = minf(FOOTER_HEIGHT, safe.size.y * 0.12)
	var vertical_gap: float = minf(12.0, safe.size.y * 0.025)
	var header: Rect2 = Rect2(safe.position, Vector2(safe.size.x, header_height))
	var footer: Rect2 = Rect2(
		Vector2(safe.position.x, safe.end.y - footer_height),
		Vector2(safe.size.x, footer_height)
	)
	var content_top: float = header.end.y + vertical_gap
	var content_bottom: float = footer.position.y - vertical_gap
	var content: Rect2 = Rect2(
		Vector2(safe.position.x, content_top),
		Vector2(safe.size.x, maxf(0.0, content_bottom - content_top))
	)

	var gap: float = minf(COLUMN_GAP, content.size.x * 0.025)
	var usable_width: float = maxf(0.0, content.size.x - gap * 2.0)
	var list_width: float = usable_width * LIST_RATIO
	var roster_width: float = usable_width * ROSTER_RATIO
	var detail_width: float = usable_width - list_width - roster_width

	# 在支援的最小視窗仍保留三欄最低可讀寬度；若空間不足則等比例縮小，
	# 不讓 detail 欄出現負數或跑出 safe rect。
	var minimum_total: float = MIN_LIST_WIDTH + MIN_ROSTER_WIDTH + MIN_DETAIL_WIDTH
	if usable_width >= minimum_total:
		list_width = maxf(MIN_LIST_WIDTH, list_width)
		roster_width = maxf(MIN_ROSTER_WIDTH, roster_width)
		detail_width = usable_width - list_width - roster_width
		if detail_width < MIN_DETAIL_WIDTH:
			var shortage: float = MIN_DETAIL_WIDTH - detail_width
			var reducible_list: float = maxf(0.0, list_width - MIN_LIST_WIDTH)
			var take_from_list: float = minf(shortage, reducible_list)
			list_width -= take_from_list
			shortage -= take_from_list
			roster_width = maxf(MIN_ROSTER_WIDTH, roster_width - shortage)
			detail_width = usable_width - list_width - roster_width
	elif usable_width > 0.0:
		var scale: float = usable_width / minimum_total
		list_width = MIN_LIST_WIDTH * scale
		roster_width = MIN_ROSTER_WIDTH * scale
		detail_width = maxf(0.0, usable_width - list_width - roster_width)

	var hero_list: Rect2 = Rect2(content.position, Vector2(list_width, content.size.y))
	var roster: Rect2 = Rect2(
		Vector2(hero_list.end.x + gap, content.position.y),
		Vector2(roster_width, content.size.y)
	)
	var detail: Rect2 = Rect2(
		Vector2(roster.end.x + gap, content.position.y),
		Vector2(maxf(0.0, content.end.x - (roster.end.x + gap)), content.size.y)
	)
	return {
		"safe": safe,
		"header": header,
		"footer": footer,
		"content": content,
		"hero_list": hero_list,
		"roster": roster,
		"detail": detail,
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
