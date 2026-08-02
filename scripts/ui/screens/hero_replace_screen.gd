class_name HeroReplaceScreen
extends RefCounted

## 主戰／後備滿額時的替換畫面純排版與游標模型。

const VIEW_SIZE: Vector2 = Vector2(1280.0, 720.0)


static func layout(item_count: int, view_size: Vector2 = VIEW_SIZE) -> Dictionary:
	var modal_width: float = 760.0
	var modal_height: float = clampf(210.0 + float(maxi(1, item_count)) * 62.0, 360.0, 620.0)
	var modal: Rect2 = Rect2(
		Vector2((view_size.x - modal_width) * 0.5, (view_size.y - modal_height) * 0.5),
		Vector2(modal_width, modal_height)
	)
	var title: Rect2 = Rect2(modal.position + Vector2(30.0, 24.0), Vector2(modal.size.x - 60.0, 54.0))
	var list: Rect2 = Rect2(modal.position + Vector2(42.0, 94.0), Vector2(modal.size.x - 84.0, modal.size.y - 158.0))
	return {
		"backdrop": Rect2(Vector2.ZERO, view_size),
		"modal": modal,
		"title": title,
		"list": list,
		"rows": row_rects(list, item_count),
		"footer": Rect2(modal.position + Vector2(42.0, modal.size.y - 48.0), Vector2(modal.size.x - 84.0, 26.0)),
	}


static func row_rects(area: Rect2, item_count: int) -> Array[Rect2]:
	var result: Array[Rect2] = []
	if item_count <= 0:
		return result
	var gap: float = 8.0
	var row_height: float = minf(54.0, (area.size.y - gap * float(item_count - 1)) / float(item_count))
	for index in range(item_count):
		result.append(Rect2(
			Vector2(area.position.x, area.position.y + float(index) * (row_height + gap)),
			Vector2(area.size.x, row_height)
		))
	return result


static func normalized_index(index: int, item_count: int) -> int:
	if item_count <= 0:
		return 0
	return posmod(index, item_count)


static func title_key(mode: StringName) -> StringName:
	return &"ui.hero_replace.active_title" if mode == HeroRosterManager.ACTIVE else &"ui.hero_replace.reserve_title"
