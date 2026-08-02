class_name IntermissionLayout
extends RefCounted

## 章間整備畫面的純排版模型。
##
## 所有矩形由安全區推導，Panel 內距統一使用 PanelRenderer，避免各區塊
## 自行手算後因內容增加而互相壓疊。

const VIEW_SIZE: Vector2 = Vector2(1280.0, 720.0)
const OUTER_MARGIN: float = 34.0
const HEADER_HEIGHT: float = 72.0
const FOOTER_HEIGHT: float = 104.0
const COLUMN_GAP: float = 22.0
const PANEL_PADDING: Vector2 = Vector2(24.0, 22.0)
const SECTION_GAP: float = 14.0


static func build(view_size: Vector2 = VIEW_SIZE) -> Dictionary:
	var safe: Rect2 = Rect2(
		Vector2(OUTER_MARGIN, OUTER_MARGIN),
		Vector2(maxf(0.0, view_size.x - OUTER_MARGIN * 2.0), maxf(0.0, view_size.y - OUTER_MARGIN * 2.0))
	)
	var header: Rect2 = Rect2(safe.position, Vector2(safe.size.x, minf(HEADER_HEIGHT, safe.size.y)))
	var footer_height: float = minf(FOOTER_HEIGHT, maxf(0.0, safe.size.y - header.size.y - SECTION_GAP * 2.0))
	var footer: Rect2 = Rect2(
		Vector2(safe.position.x, safe.end.y - footer_height),
		Vector2(safe.size.x, footer_height)
	)
	var content_top: float = header.end.y + SECTION_GAP
	var content_bottom: float = footer.position.y - SECTION_GAP
	var content_height: float = maxf(0.0, content_bottom - content_top)
	var column_width: float = maxf(0.0, (safe.size.x - COLUMN_GAP) * 0.5)
	var left: Rect2 = Rect2(
		Vector2(safe.position.x, content_top),
		Vector2(column_width, content_height)
	)
	var right: Rect2 = Rect2(
		Vector2(left.end.x + COLUMN_GAP, content_top),
		Vector2(column_width, content_height)
	)

	var left_inner: Rect2 = PanelRenderer.content_rect(left, PANEL_PADDING)
	var right_inner: Rect2 = PanelRenderer.content_rect(right, PANEL_PADDING)
	var result_height: float = minf(94.0, left_inner.size.y)
	var remaining_after_result: float = maxf(0.0, left_inner.size.y - result_height - SECTION_GAP * 2.0)
	var carry_height: float = minf(150.0, remaining_after_result * 0.56)
	var history_height: float = maxf(0.0, remaining_after_result - carry_height)
	var previous_result: Rect2 = Rect2(left_inner.position, Vector2(left_inner.size.x, result_height))
	var carry_over: Rect2 = Rect2(
		Vector2(left_inner.position.x, previous_result.end.y + SECTION_GAP),
		Vector2(left_inner.size.x, carry_height)
	)
	var history: Rect2 = Rect2(
		Vector2(left_inner.position.x, carry_over.end.y + SECTION_GAP),
		Vector2(left_inner.size.x, history_height)
	)

	return {
		"safe": safe,
		"header": header,
		"content": Rect2(Vector2(safe.position.x, content_top), Vector2(safe.size.x, content_height)),
		"left_panel": left,
		"left_content": left_inner,
		"right_panel": right,
		"right_content": right_inner,
		"previous_result": previous_result,
		"carry_over": carry_over,
		"history": history,
		"footer": footer,
		"button_row": PanelRenderer.content_rect(footer, Vector2(18.0, 22.0)),
	}


static func button_rects(row: Rect2, count: int, gap: float = 12.0) -> Array[Rect2]:
	var result: Array[Rect2] = []
	if count <= 0:
		return result
	var safe_gap: float = maxf(0.0, gap)
	var width: float = maxf(0.0, (row.size.x - safe_gap * float(count - 1)) / float(count))
	for index in range(count):
		result.append(Rect2(
			Vector2(row.position.x + float(index) * (width + safe_gap), row.position.y),
			Vector2(width, row.size.y)
		))
	return result
