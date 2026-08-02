class_name EndingManager
extends RefCounted

const EndingData = preload("res://scripts/ending_data.gd")


func build_snapshot(context: Dictionary) -> Dictionary:
	var ending: Dictionary = select_ending(context)
	return {
		"ending_id": str(ending.get("id", "historical_witness")),
		"title": str(ending.get("title", "亂世見證者")),
		"narration": str(ending.get("narration", "")),
		"historian_comment": str(ending.get("historian_comment", "")),
		"unlock_rewards": _string_array(ending.get("unlock_rewards", [])),
		"chapter_id": str(context.get("chapter_id", "")),
		"chapter_title": str(context.get("chapter_title", "")),
		"identity": str(context.get("identity", "")),
		"elapsed": float(context.get("elapsed", 0.0)),
		"stats": _dictionary_copy(context.get("stats", {})),
		"active_heroes": _string_array(context.get("active_heroes", [])),
		"reserve_heroes": _string_array(context.get("reserve_heroes", [])),
		"active_bonds": _string_array(context.get("active_bonds", [])),
		"relics": _string_array(context.get("relics", [])),
		"equipment": _dictionary_copy(context.get("equipment", {})),
		"history_log": _string_array(context.get("history_log", [])),
		"route_tags": _dictionary_copy(context.get("route_tags", {})),
		"rewrite_rate": float(context.get("rewrite_rate", 0.0)),
		"created_at": Time.get_datetime_string_from_system()
	}


func select_ending(context: Dictionary) -> Dictionary:
	var definitions: Array[Dictionary] = EndingData.definitions()
	var selected: Dictionary = definitions[0] if not definitions.is_empty() else {}
	var selected_priority: int = int(selected.get("priority", -1))
	for definition in definitions:
		if not _matches(definition, context):
			continue
		var priority: int = int(definition.get("priority", 0))
		if priority > selected_priority:
			selected = definition
			selected_priority = priority
	return selected.duplicate(true)


func _matches(definition: Dictionary, context: Dictionary) -> bool:
	var requirements: Dictionary = _dictionary_copy(definition.get("requirements", {}))
	if requirements.is_empty():
		return true
	var min_rewrite_rate: float = float(requirements.get("min_rewrite_rate", -1.0))
	if min_rewrite_rate >= 0.0 and float(context.get("rewrite_rate", 0.0)) < min_rewrite_rate:
		return false
	var required_tag: String = str(requirements.get("route_tag", ""))
	if required_tag != "":
		var route_tags: Dictionary = _dictionary_copy(context.get("route_tags", {}))
		if not bool(route_tags.get(required_tag, false)):
			return false
		var momentum: Dictionary = _dictionary_copy(context.get("faction_momentum", {}))
		if int(momentum.get(required_tag, 0)) < int(requirements.get("min_momentum", 0)):
			return false
	return true


func _dictionary_copy(value: Variant) -> Dictionary:
	return (value as Dictionary).duplicate(true) if value is Dictionary else {}


func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item in value:
			result.append(str(item))
	return result
