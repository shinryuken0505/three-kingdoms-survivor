class_name HeroReplaceScreen
extends RefCounted

## 主戰／後備滿額時的替換畫面純排版與游標模型。
## Modal 置中、邊界與內距統一交由共用元件計算。

const VIEW_SIZE: Vector2 = Vector2(1280.0, 720.0)


static func layout(item_count: int, view_size: Vector2 = VIEW_SIZE) -> Dictionary:
	var modal_height: float = clampf(210.0 + float(maxi(1, item_count)) * 62.0, 360.0, 620.0)
	var base: Dictionary = ModalRenderer.layout(view_size, Vector2(760.0, modal_height))
	var modal: Rect2 = base["modal"] as Rect2
	var content: Rect2 = PanelRenderer.content_rect(modal, Vector2(42.0, 24.0))
	var title: Rect2 = Rect2(content.position, Vector2(content.size.x, 54.0))
	var footer_height: float = 26.0
	var footer: Rect2 = Rect2(
		Vector2(content.position.x, content.end.y - footer_height),
		Vector2(content.size.x, footer_height)
	)
	var list: Rect2 = Rect2(
		Vector2(content.position.x, title.end.y + 16.0),
		Vector2(content.size.x, maxf(0.0, footer.position.y - title.end.y - 30.0))
	)
	return {
		"backdrop": base["backdrop"],
		"modal": modal,
		"content": content,
		"title": title,
		"list": list,
		"rows": row_rects(list, item_count),
		"footer": footer,
	}


static func row_rects(area: Rect2, item_count: int) -> Array[Rect2]:
	var result: Array[Rect2] = []
	if item_count <= 0:
		return result
	var gap: float = 8.0
	var row_height: float = maxf(0.0, minf(54.0, (area.size.y - gap * float(item_count - 1)) / float(item_count)))
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
