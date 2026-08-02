class_name ModalRenderer
extends RefCounted

## 共用 Modal 背景與置中排版。

const DEFAULT_SIZE: Vector2 = Vector2(620.0, 420.0)


static func layout(
	view_size: Vector2 = Vector2(1280.0, 720.0),
	modal_size: Vector2 = DEFAULT_SIZE,
	margin: float = 24.0
) -> Dictionary:
	var maximum := Vector2(maxf(0.0, view_size.x - margin * 2.0), maxf(0.0, view_size.y - margin * 2.0))
	var safe_size := Vector2(minf(modal_size.x, maximum.x), minf(modal_size.y, maximum.y))
	var modal := Rect2((view_size - safe_size) * 0.5, safe_size)
	return {
		"backdrop": Rect2(Vector2.ZERO, view_size),
		"modal": modal,
		"content": PanelRenderer.content_rect(modal, Vector2(28.0, 24.0)),
	}


static func draw_backdrop(canvas: CanvasItem, rect: Rect2, alpha: float = 0.66) -> void:
	if canvas == null:
		return
	canvas.draw_rect(rect, Color(0.0, 0.0, 0.0, clampf(alpha, 0.0, 1.0)), true)


static func draw(
	canvas: CanvasItem,
	view_size: Vector2 = Vector2(1280.0, 720.0),
	modal_size: Vector2 = DEFAULT_SIZE,
	fill: Color = Color(0.028, 0.034, 0.035, 0.995),
	border: Color = Color(0.84, 0.71, 0.41, 1.0)
) -> Dictionary:
	var result := layout(view_size, modal_size)
	draw_backdrop(canvas, result["backdrop"])
	PanelRenderer.draw(canvas, result["modal"], fill, border, 2.0)
	return result
