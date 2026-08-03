class_name StatusEffectIconPainter
extends RefCounted

## 無外部素材時的程式化狀態圖示。
##
## 畫面層提供 CanvasItem 與 StatusEffectRenderer 產生的 slot，即可繪製清晰的
## 像素風提示。正式 icon 素材完成後，可保留此元件作為 fallback。


static func draw_slot(canvas: CanvasItem, slot: Dictionary, font: Font) -> void:
	var rect: Rect2 = slot.get("rect", Rect2()) as Rect2
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	var status_id: StringName = StringName(slot.get("id", &""))
	var base_color: Color = _status_color(status_id)
	var pulse_alpha: float = 0.72 if bool(slot.get("pulse", false)) else 0.96
	canvas.draw_rect(rect, Color(0.035, 0.04, 0.045, pulse_alpha), true)
	canvas.draw_rect(rect, base_color, false, 2.0)
	_draw_symbol(canvas, rect, status_id, base_color)

	var duration_text: String = str(slot.get("duration_text", ""))
	if not duration_text.is_empty() and font != null:
		canvas.draw_string(
			font,
			rect.position + Vector2(2.0, rect.size.y + 12.0),
			duration_text,
			HORIZONTAL_ALIGNMENT_CENTER,
			rect.size.x,
			10,
			Color(0.94, 0.94, 0.90)
		)
	var stacks: int = int(slot.get("stacks", 1))
	if stacks > 1 and font != null:
		canvas.draw_circle(rect.end - Vector2(7.0, 7.0), 7.0, Color(0.08, 0.08, 0.08, 0.95))
		canvas.draw_string(
			font,
			rect.end - Vector2(13.0, 3.0),
			str(stacks),
			HORIZONTAL_ALIGNMENT_CENTER,
			12.0,
			10,
			Color.WHITE
		)


static func _draw_symbol(canvas: CanvasItem, rect: Rect2, status_id: StringName, color: Color) -> void:
	var center: Vector2 = rect.get_center()
	match status_id:
		&"slow":
			canvas.draw_line(center + Vector2(-9.0, -7.0), center + Vector2(8.0, 8.0), color, 3.0)
			canvas.draw_line(center + Vector2(-9.0, 7.0), center + Vector2(8.0, -8.0), color, 3.0)
		&"stun":
			var points := PackedVector2Array([
				center + Vector2(-4.0, -12.0), center + Vector2(5.0, -3.0),
				center + Vector2(0.0, -3.0), center + Vector2(6.0, 12.0),
				center + Vector2(-7.0, 2.0), center + Vector2(-2.0, 2.0),
			])
			canvas.draw_polyline(points, color, 3.0)
		&"smoke":
			canvas.draw_arc(center + Vector2(-5.0, 2.0), 8.0, PI, TAU, 14, color, 3.0)
			canvas.draw_arc(center + Vector2(6.0, -3.0), 7.0, 0.0, PI, 14, color, 3.0)
		&"poison":
			canvas.draw_circle(center, 8.0, color)
			canvas.draw_circle(center + Vector2(-4.0, -2.0), 2.0, Color(0.06, 0.07, 0.06))
			canvas.draw_circle(center + Vector2(4.0, -2.0), 2.0, Color(0.06, 0.07, 0.06))
		&"burn":
			var flame := PackedVector2Array([
				center + Vector2(0.0, -12.0), center + Vector2(8.0, 2.0),
				center + Vector2(3.0, 11.0), center + Vector2(-7.0, 5.0),
				center + Vector2(-4.0, -4.0),
			])
			canvas.draw_colored_polygon(flame, color)
		&"silence":
			canvas.draw_circle(center, 10.0, color, false, 3.0)
			canvas.draw_line(center + Vector2(-8.0, 8.0), center + Vector2(8.0, -8.0), color, 3.0)
		&"bleed":
			var drop := PackedVector2Array([
				center + Vector2(0.0, -12.0), center + Vector2(8.0, 1.0),
				center + Vector2(5.0, 10.0), center + Vector2(-5.0, 10.0),
				center + Vector2(-8.0, 1.0),
			])
			canvas.draw_colored_polygon(drop, color)
		&"vulnerable":
			canvas.draw_line(center + Vector2(-10.0, -10.0), center + Vector2(10.0, 10.0), color, 3.0)
			canvas.draw_line(center + Vector2(10.0, -10.0), center + Vector2(-10.0, 10.0), color, 3.0)
			canvas.draw_circle(center, 4.0, color, false, 2.0)
		_:
			canvas.draw_circle(center, 8.0, color)


static func _status_color(status_id: StringName) -> Color:
	match status_id:
		&"slow":
			return Color8(105, 190, 232)
		&"stun":
			return Color8(246, 211, 82)
		&"smoke":
			return Color8(186, 126, 205)
		&"poison":
			return Color8(117, 202, 91)
		&"burn":
			return Color8(237, 111, 57)
		&"silence":
			return Color8(166, 116, 214)
		&"bleed":
			return Color8(213, 65, 73)
		&"vulnerable":
			return Color8(235, 164, 73)
		_:
			return Color8(190, 194, 188)
