class_name StatusBadgeRenderer
extends RefCounted

## 共用狀態徽章元件。
## 適用於名將位置、裝備稀有度與短狀態文字，不承擔翻譯責任。

const MIN_HEIGHT: float = 24.0
const HORIZONTAL_PADDING: float = 10.0


static func measure(font: Font, text: String, font_size: int = 12) -> Vector2:
	var text_size := Vector2.ZERO
	if font != null and not text.is_empty():
		text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size)
	return Vector2(maxf(MIN_HEIGHT, text_size.x + HORIZONTAL_PADDING * 2.0), maxf(MIN_HEIGHT, text_size.y + 8.0))


static func rect_at(position: Vector2, font: Font, text: String, font_size: int = 12) -> Rect2:
	return Rect2(position, measure(font, text, font_size))


static func draw(
	canvas: CanvasItem,
	rect: Rect2,
	fill: Color,
	border: Color,
	border_width: float = 1.0
) -> Rect2:
	PanelRenderer.draw(canvas, rect, fill, border, border_width)
	return PanelRenderer.content_rect(rect, Vector2(HORIZONTAL_PADDING, 4.0))


static func state_colors(state: StringName) -> Dictionary:
	match state:
		HeroRosterManager.ACTIVE:
			return {"fill": Color(0.34, 0.16, 0.12, 0.96), "border": Color(0.88, 0.54, 0.35, 1.0)}
		HeroRosterManager.RESERVE:
			return {"fill": Color(0.12, 0.24, 0.32, 0.96), "border": Color(0.42, 0.72, 0.88, 1.0)}
		HeroRosterManager.CAMP:
			return {"fill": Color(0.12, 0.29, 0.19, 0.96), "border": Color(0.44, 0.78, 0.54, 1.0)}
		_:
			return {"fill": Color(0.18, 0.19, 0.18, 0.96), "border": Color(0.48, 0.50, 0.48, 1.0)}
