class_name PanelRenderer
extends RefCounted

## 共用 Panel 繪製元件。
## 畫面只提供矩形與樣式，不在各自 renderer 重複邊框與內距規則。

const DEFAULT_PADDING: Vector2 = Vector2(18.0, 14.0)


static func draw(
	canvas: CanvasItem,
	rect: Rect2,
	fill: Color = Color(0.035, 0.04, 0.041, 0.96),
	border: Color = Color(0.42, 0.40, 0.33, 1.0),
	border_width: float = 1.2
) -> Rect2:
	if canvas == null or rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return Rect2()
	canvas.draw_rect(rect, fill, true)
	canvas.draw_rect(rect, border, false, border_width)
	return content_rect(rect)


static func content_rect(rect: Rect2, padding: Vector2 = DEFAULT_PADDING) -> Rect2:
	var safe_padding := Vector2(
		minf(maxf(0.0, padding.x), rect.size.x * 0.5),
		minf(maxf(0.0, padding.y), rect.size.y * 0.5)
	)
	return Rect2(rect.position + safe_padding, rect.size - safe_padding * 2.0)


static func split_vertical(rect: Rect2, top_height: float, gap: float = 10.0) -> Dictionary:
	var safe_height: float = clampf(top_height, 0.0, rect.size.y)
	var safe_gap: float = clampf(gap, 0.0, maxf(0.0, rect.size.y - safe_height))
	return {
		"top": Rect2(rect.position, Vector2(rect.size.x, safe_height)),
		"bottom": Rect2(
			Vector2(rect.position.x, rect.position.y + safe_height + safe_gap),
			Vector2(rect.size.x, maxf(0.0, rect.size.y - safe_height - safe_gap))
		),
	}
