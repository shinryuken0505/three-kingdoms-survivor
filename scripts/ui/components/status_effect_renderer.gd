class_name StatusEffectRenderer
extends RefCounted

## 狀態效果 HUD 的純排版模型。
##
## 實際 icon 載入與 CanvasItem 繪製仍由畫面層負責；此元件只計算位置、
## 顯示上限與倒數文字，確保主角頭上與右上 HUD 使用相同規格。

const ICON_SIZE: Vector2 = Vector2(34.0, 34.0)
const ICON_GAP: float = 6.0
const MAX_ABOVE_PLAYER: int = 3
const MAX_HUD_ITEMS: int = 7


static func above_player_layout(
	player_screen_position: Vector2,
	view_models: Array,
	view_size: Vector2 = Vector2(1280.0, 720.0)
) -> Array[Dictionary]:
	var visible_count: int = mini(MAX_ABOVE_PLAYER, view_models.size())
	if visible_count <= 0:
		return []
	var total_width: float = float(visible_count) * ICON_SIZE.x + float(visible_count - 1) * ICON_GAP
	var start_x: float = player_screen_position.x - total_width * 0.5
	var y: float = clampf(player_screen_position.y - 78.0, 10.0, view_size.y - ICON_SIZE.y - 10.0)
	var result: Array[Dictionary] = []
	for index in range(visible_count):
		var model: Dictionary = view_models[index] as Dictionary
		var rect := Rect2(Vector2(start_x + float(index) * (ICON_SIZE.x + ICON_GAP), y), ICON_SIZE)
		result.append(_slot(model, rect, index))
	return result


static func hud_layout(
	view_models: Array,
	anchor: Rect2 = Rect2(1018.0, 142.0, 244.0, 92.0)
) -> Array[Dictionary]:
	var visible_count: int = mini(MAX_HUD_ITEMS, view_models.size())
	var result: Array[Dictionary] = []
	var columns: int = maxi(1, int(floor((anchor.size.x + ICON_GAP) / (ICON_SIZE.x + ICON_GAP))))
	for index in range(visible_count):
		var model: Dictionary = view_models[index] as Dictionary
		var row: int = floori(float(index) / float(columns))
		var column: int = index % columns
		var rect := Rect2(
			anchor.position + Vector2(
				float(column) * (ICON_SIZE.x + ICON_GAP),
				float(row) * (ICON_SIZE.y + 18.0)
			),
			ICON_SIZE
		)
		result.append(_slot(model, rect, index))
	return result


static func duration_text(seconds: float) -> String:
	if seconds >= 10.0:
		return "%d" % int(ceil(seconds))
	return "%.1f" % maxf(0.0, seconds)


static func should_pulse(seconds: float) -> bool:
	return seconds > 0.0 and seconds <= 1.5


static func _slot(model: Dictionary, rect: Rect2, index: int) -> Dictionary:
	return {
		"index": index,
		"id": StringName(model.get("id", &"")),
		"rect": rect,
		"icon_path": str(model.get("icon_path", "")),
		"name_key": StringName(model.get("name_key", &"")),
		"desc_key": StringName(model.get("desc_key", &"")),
		"duration": maxf(0.0, float(model.get("duration", 0.0))),
		"duration_text": duration_text(float(model.get("duration", 0.0))),
		"stacks": maxi(1, int(model.get("stacks", 1))),
		"pulse": should_pulse(float(model.get("duration", 0.0))),
	}
