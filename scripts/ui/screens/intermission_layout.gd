class_name IntermissionLayout
extends RefCounted

## 章間整備畫面的純排版模型。
##
## 所有矩形由安全區推導，Panel 內距統一使用 PanelRenderer，避免各區塊
## 自行手算後因內容增加而互相壓疊。
##
## Alpha.57 hotfix：安全邊界、Header / Footer 與欄間距依目前虛擬畫布縮放，
## 並保證所有回傳 Rect2 都落在 safe rect 內，避免縮放後整體右偏或底部裁切。

const VIEW_SIZE: Vector2 = Vector2(1280.0, 720.0)
const OUTER_MARGIN: float = 34.0
const HEADER_HEIGHT: float = 72.0
const FOOTER_HEIGHT: float = 104.0
const COLUMN_GAP: float = 22.0
const PANEL_PADDING: Vector2 = Vector2(24.0, 22.0)
const SECTION_GAP: float = 14.0


static func build(view_size: Vector2 = VIEW_SIZE) -> Dictionary:
	var width: float = maxf(1.0, view_size.x)
	var height: float = maxf(1.0, view_size.y)
	var margin: float = minf(OUTER_MARGIN, minf(width * 0.04, height * 0.04))
	var safe: Rect2 = Rect2(
		Vector2(margin, margin),
		Vector2(maxf(0.0, width - margin * 2.0), maxf(0.0, height - margin * 2.0))
	)
	var section_gap: float = minf(SECTION_GAP, safe.size.y * 0.025)
	var column_gap: float = minf(COLUMN_GAP, safe.size.x * 0.025)
	var header_height: float = minf(HEADER_HEIGHT, safe.size.y * 0.12)
	var header: Rect2 = Rect2(safe.position, Vector2(safe.size.x, header_height))
	var footer_target: float = minf(FOOTER_HEIGHT, safe.size.y * 0.18)
	var footer_height: float = minf(
		footer_target,
		maxf(0.0, safe.size.y - header.size.y - section_gap * 2.0)
	)
	var footer: Rect2 = Rect2(
		Vector2(safe.position.x, safe.end.y - footer_height),
		Vector2(safe.size.x, footer_height)
	)
	var content_top: float = header.end.y + section_gap
	var content_bottom: float = footer.position.y - section_gap
	var content_height: float = maxf(0.0, content_bottom - content_top)
	var column_width: float = maxf(0.0, (safe.size.x - column_gap) * 0.5)
	var left: Rect2 = Rect2(
		Vector2(safe.position.x, content_top),
		Vector2(column_width, content_height)
	)
	var right: Rect2 = Rect2(
		Vector2(left.end.x + column_gap, content_top),
		Vector2(maxf(0.0, safe.end.x - (left.end.x + column_gap)), content_height)
	)

	var padding_scale: float = minf(1.0, minf(width / VIEW_SIZE.x, height / VIEW_SIZE.y))
	var panel_padding: Vector2 = Vector2(
		maxf(12.0, PANEL_PADDING.x * padding_scale),
		maxf(10.0, PANEL_PADDING.y * padding_scale)
	)
	var left_inner: Rect2 = PanelRenderer.content_rect(left, panel_padding)
	var right_inner: Rect2 = PanelRenderer.content_rect(right, panel_padding)
	var result_height: float = minf(94.0 * maxf(0.75, padding_scale), left_inner.size.y)
	var remaining_after_result: float = maxf(0.0, left_inner.size.y - result_height - section_gap * 2.0)
	var carry_height: float = minf(150.0 * maxf(0.75, padding_scale), remaining_after_result * 0.56)
	var history_height: float = maxf(0.0, remaining_after_result - carry_height)
	var previous_result: Rect2 = Rect2(left_inner.position, Vector2(left_inner.size.x, result_height))
	var carry_over: Rect2 = Rect2(
		Vector2(left_inner.position.x, previous_result.end.y + section_gap),
		Vector2(left_inner.size.x, carry_height)
	)
	var history: Rect2 = Rect2(
		Vector2(left_inner.position.x, carry_over.end.y + section_gap),
		Vector2(left_inner.size.x, history_height)
	)
	var footer_padding: Vector2 = Vector2(
		maxf(10.0, 18.0 * padding_scale),
		maxf(10.0, 22.0 * padding_scale)
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
		"button_row": PanelRenderer.content_rect(footer, footer_padding),
	}


static func button_rects(row: Rect2, count: int, gap: float = 12.0) -> Array[Rect2]:
	var result: Array[Rect2] = []
	if count <= 0:
		return result
	var safe_gap: float = maxf(0.0, minf(gap, row.size.x / maxf(1.0, float(count) * 4.0)))
	var width: float = maxf(0.0, (row.size.x - safe_gap * float(count - 1)) / float(count))
	for index in range(count):
		result.append(Rect2(
			Vector2(row.position.x + float(index) * (width + safe_gap), row.position.y),
			Vector2(width, row.size.y)
		))
	return result
