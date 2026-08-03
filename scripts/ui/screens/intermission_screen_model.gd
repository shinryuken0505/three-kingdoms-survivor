class_name IntermissionScreenModel
extends RefCounted

## 章間整備畫面的純資料模型。
##
## 將上一章結果、承接資源、史勢演變與底部操作整合為單一繪製計畫，
## 畫面層只需依照回傳的區塊與文字列繪製，不再自行計算位置。

const DEFAULT_ACTION_KEYS: Array[String] = [
	"intermission.action.continue",
	"intermission.action.heroes",
	"intermission.action.equipment",
	"intermission.action.save",
]


static func build(
	data: Dictionary,
	selected_action: int = 0,
	view_size: Vector2 = Vector2(1280.0, 720.0)
) -> Dictionary:
	var layout: Dictionary = IntermissionLayout.build(view_size)
	var action_keys: Array[String] = _string_array(data.get("action_keys", DEFAULT_ACTION_KEYS))
	if action_keys.is_empty():
		action_keys = DEFAULT_ACTION_KEYS.duplicate()
	var selected: int = clampi(selected_action, 0, action_keys.size() - 1)
	var button_rects: Array[Rect2] = IntermissionLayout.button_rects(
		layout.get("button_row", Rect2()) as Rect2,
		action_keys.size()
	)
	var actions: Array[Dictionary] = []
	for index in range(action_keys.size()):
		actions.append({
			"index": index,
			"key": action_keys[index],
			"rect": button_rects[index],
			"selected": index == selected,
			"enabled": _action_enabled(data, index),
		})

	return {
		"layout": layout,
		"title_key": str(data.get("title_key", "intermission.title")),
		"subtitle": str(data.get("subtitle", "")),
		"previous_result": section(
			"intermission.section.previous_result",
			_string_array(data.get("previous_result", [])),
			layout.get("previous_result", Rect2()) as Rect2
		),
		"carry_over": section(
			"intermission.section.carry_over",
			_string_array(data.get("carry_over", [])),
			layout.get("carry_over", Rect2()) as Rect2
		),
		"history": section(
			"intermission.section.history",
			_string_array(data.get("history", [])),
			layout.get("history", Rect2()) as Rect2
		),
		"right_panel": _right_panel(data, layout.get("right_content", Rect2()) as Rect2),
		"actions": actions,
		"selected_action": selected,
	}


static func section(title_key: String, lines: Array[String], rect: Rect2) -> Dictionary:
	var title_height: float = minf(28.0, rect.size.y)
	var body: Rect2 = Rect2(
		Vector2(rect.position.x, rect.position.y + title_height),
		Vector2(rect.size.x, maxf(0.0, rect.size.y - title_height))
	)
	var max_rows: int = maxi(0, floori(body.size.y / 24.0))
	return {
		"title_key": title_key,
		"rect": rect,
		"title_rect": Rect2(rect.position, Vector2(rect.size.x, title_height)),
		"body_rect": body,
		"lines": lines.slice(0, mini(lines.size(), max_rows)),
		"hidden_count": maxi(0, lines.size() - max_rows),
	}


static func move_selection(current: int, direction: int, action_count: int) -> int:
	if action_count <= 0:
		return 0
	return posmod(current + direction, action_count)


static func action_at(plan: Dictionary, point: Vector2) -> int:
	for value in plan.get("actions", []) as Array:
		var action: Dictionary = value as Dictionary
		if (action.get("rect", Rect2()) as Rect2).has_point(point):
			return int(action.get("index", -1))
	return -1


static func _right_panel(data: Dictionary, rect: Rect2) -> Dictionary:
	var entries: Array[Dictionary] = []
	for value in data.get("right_entries", []) as Array:
		if value is Dictionary:
			entries.append((value as Dictionary).duplicate(true))
	var rows: Array[Rect2] = TextLayout.row_rects(rect, maxi(1, entries.size()), 8.0)
	for index in range(entries.size()):
		entries[index]["rect"] = rows[index]
	return {
		"title_key": str(data.get("right_title_key", "intermission.section.preparation")),
		"rect": rect,
		"entries": entries,
	}


static func _action_enabled(data: Dictionary, index: int) -> bool:
	var enabled_values: Array = data.get("action_enabled", []) as Array
	if index < 0 or index >= enabled_values.size():
		return true
	return bool(enabled_values[index])


static func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item in value as Array:
			result.append(str(item))
	return result
