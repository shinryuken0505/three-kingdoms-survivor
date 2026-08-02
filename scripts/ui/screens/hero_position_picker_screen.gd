class_name HeroPositionPickerScreen
extends RefCounted

## 主戰／後備／營地位置選擇彈窗的純排版模型。

const OPTION_COUNT: int = 4
const TARGET_KEYS: Array[StringName] = [
	&"ui.hero_config.target.active",
	&"ui.hero_config.target.reserve",
	&"ui.hero_config.target.camp",
	&"ui.common.cancel",
]


static func layout(view_size: Vector2 = Vector2(1280.0, 720.0)) -> Dictionary:
	var modal_size: Vector2 = Vector2(620.0, 350.0)
	var modal: Rect2 = Rect2((view_size - modal_size) * 0.5, modal_size)
	var title: Rect2 = Rect2(modal.position + Vector2(28.0, 24.0), Vector2(modal.size.x - 56.0, 52.0))
	var option_area: Rect2 = Rect2(modal.position + Vector2(42.0, 96.0), Vector2(modal.size.x - 84.0, 192.0))
	return {
		"backdrop": Rect2(Vector2.ZERO, view_size),
		"modal": modal,
		"title": title,
		"option_area": option_area,
		"options": option_rects(option_area),
		"footer": Rect2(modal.position + Vector2(42.0, 302.0), Vector2(modal.size.x - 84.0, 28.0)),
	}


static func option_rects(area: Rect2) -> Array[Rect2]:
	var result: Array[Rect2] = []
	var gap: float = 10.0
	var height: float = (area.size.y - gap * float(OPTION_COUNT - 1)) / float(OPTION_COUNT)
	for index in range(OPTION_COUNT):
		result.append(Rect2(
			Vector2(area.position.x, area.position.y + float(index) * (height + gap)),
			Vector2(area.size.x, height)
		))
	return result


static func normalized_index(index: int) -> int:
	return posmod(index, OPTION_COUNT)


static func target_key(index: int) -> StringName:
	return TARGET_KEYS[normalized_index(index)]
