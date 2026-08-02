class_name HeroPositionPickerScreen
extends RefCounted

## 主戰／後備／營地位置選擇彈窗的純排版模型。
## 共用 ModalRenderer 與 PanelRenderer，避免各畫面自行手算置中與內距。

const OPTION_COUNT: int = 4
const TARGET_KEYS: Array[StringName] = [
	&"ui.hero_config.target.active",
	&"ui.hero_config.target.reserve",
	&"ui.hero_config.target.camp",
	&"ui.common.cancel",
]


static func layout(view_size: Vector2 = Vector2(1280.0, 720.0)) -> Dictionary:
	var base: Dictionary = ModalRenderer.layout(view_size, Vector2(620.0, 350.0))
	var modal: Rect2 = base["modal"] as Rect2
	var content: Rect2 = PanelRenderer.content_rect(modal, Vector2(42.0, 24.0))
	var title: Rect2 = Rect2(content.position, Vector2(content.size.x, 52.0))
	var footer_height: float = 28.0
	var footer: Rect2 = Rect2(
		Vector2(content.position.x, content.end.y - footer_height),
		Vector2(content.size.x, footer_height)
	)
	var option_area: Rect2 = Rect2(
		Vector2(content.position.x, title.end.y + 20.0),
		Vector2(content.size.x, maxf(0.0, footer.position.y - title.end.y - 34.0))
	)
	return {
		"backdrop": base["backdrop"],
		"modal": modal,
		"content": content,
		"title": title,
		"option_area": option_area,
		"options": option_rects(option_area),
		"footer": footer,
	}


static func option_rects(area: Rect2) -> Array[Rect2]:
	var result: Array[Rect2] = []
	var gap: float = 10.0
	var height: float = maxf(0.0, (area.size.y - gap * float(OPTION_COUNT - 1)) / float(OPTION_COUNT))
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
