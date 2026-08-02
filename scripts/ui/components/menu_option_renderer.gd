class_name MenuOptionRenderer
extends RefCounted

## 共用選項按鈕繪製元件。
##
## 統一一般、選取與停用狀態，避免各畫面自行複製高亮與邊框邏輯。

const DEFAULT_FILL: Color = Color(0.045, 0.051, 0.051, 0.98)
const SELECTED_FILL: Color = Color(0.42, 0.30, 0.13, 0.94)
const DISABLED_FILL: Color = Color(0.035, 0.038, 0.038, 0.82)
const DEFAULT_BORDER: Color = Color(0.38, 0.39, 0.36, 1.0)
const SELECTED_BORDER: Color = Color(0.90, 0.76, 0.44, 1.0)
const DISABLED_BORDER: Color = Color(0.24, 0.25, 0.24, 1.0)


static func style(selected: bool, enabled: bool = true) -> Dictionary:
	if not enabled:
		return {
			"fill": DISABLED_FILL,
			"border": DISABLED_BORDER,
			"border_width": 1.0,
			"text": Color(0.48, 0.50, 0.48, 1.0),
		}
	if selected:
		return {
			"fill": SELECTED_FILL,
			"border": SELECTED_BORDER,
			"border_width": 1.8,
			"text": Color(0.95, 0.88, 0.73, 1.0),
		}
	return {
		"fill": DEFAULT_FILL,
		"border": DEFAULT_BORDER,
		"border_width": 1.0,
		"text": Color(0.78, 0.81, 0.78, 1.0),
	}


static func draw(
	canvas: CanvasItem,
	rect: Rect2,
	selected: bool,
	enabled: bool = true
) -> Dictionary:
	var option_style: Dictionary = style(selected, enabled)
	PanelRenderer.draw(
		canvas,
		rect,
		option_style["fill"],
		option_style["border"],
		float(option_style["border_width"])
	)
	return option_style


static func content_rect(rect: Rect2, horizontal_padding: float = 18.0, vertical_padding: float = 10.0) -> Rect2:
	return PanelRenderer.content_rect(rect, Vector2(horizontal_padding, vertical_padding))
