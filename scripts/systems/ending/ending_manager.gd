class_name EndingManager
extends RefCounted

const EndingData = preload("res://scripts/ending_data.gd")
const SNAPSHOT_VERSION: int = 2
const DEFAULT_ENDING_ID: String = "historical_witness"


func validate_context(context: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	for key in ["chapter_id", "chapter_title", "identity", "mode"]:
		if str(context.get(key, "")).strip_edges().is_empty():
			errors.append("missing ending context: %s" % key)
	if not (context.get("stats", {}) is Dictionary):
		errors.append("ending stats must be a Dictionary")
	if not (context.get("equipment", {}) is Dictionary):
		errors.append("ending equipment must be a Dictionary")
	return errors


func build_snapshot(context: Dictionary) -> Dictionary:
	var validation_errors: Array[String] = validate_context(context)
	if not validation_errors.is_empty():
		push_error("Ending context invalid: %s" % "; ".join(validation_errors))
	var ending: Dictionary = select_ending(context)
	return {
		"snapshot_version": SNAPSHOT_VERSION,
		"run_id": str(context.get("run_id", "")),
		"ending_id": str(ending.get("id", DEFAULT_ENDING_ID)),
		"title": str(ending.get("title", "亂世見證者")),
		"narration": str(ending.get("narration", "")),
		"historian_comment": str(ending.get("historian_comment", "")),
		"unlock_rewards": _string_array(ending.get("unlock_rewards", [])),
		"mode": str(context.get("mode", "story")),
		"difficulty": str(context.get("difficulty", "story")),
		"chapter_id": str(context.get("chapter_id", "")),
		"chapter_title": str(context.get("chapter_title", "")),
		"boss_id": str(context.get("boss_id", "")),
		"identity": str(context.get("identity", "")),
		"elapsed": float(context.get("elapsed", 0.0)),
		"stats": _dictionary_copy(context.get("stats", {})),
		"active_heroes": _string_array(context.get("active_heroes", [])),
		"reserve_heroes": _string_array(context.get("reserve_heroes", [])),
		"active_bonds": _string_array(context.get("active_bonds", [])),
		"relics": _string_array(context.get("relics", [])),
		"equipment": _dictionary_copy(context.get("equipment", {})),
		"completed_chapters": _string_array(context.get("completed_chapters", [])),
		"history_log": _string_array(context.get("history_log", [])),
		"route_tags": _dictionary_copy(context.get("route_tags", {})),
		"faction_momentum": _dictionary_copy(context.get("faction_momentum", {})),
		"rewrite_rate": float(context.get("rewrite_rate", 0.0)),
		"created_at_utc": Time.get_datetime_string_from_system(true)
	}


func select_ending(context: Dictionary) -> Dictionary:
	var definitions: Array[Dictionary] = EndingData.definitions()
	var matches: Array[Dictionary] = []
	for definition in definitions:
		if _matches(definition, context):
			matches.append(definition)
	if matches.is_empty():
		return {
			"id": DEFAULT_ENDING_ID,
			"title": "亂世見證者",
			"narration": "你走過亂世，留下屬於自己的足跡。",
			"historian_comment": "其志未必改天命，然其行已入史冊。",
			"unlock_rewards": []
		}
	matches.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ap: int = int(a.get("priority", 0))
		var bp: int = int(b.get("priority", 0))
		if ap != bp:
			return ap > bp
		return str(a.get("id", "")) < str(b.get("id", ""))
	)
	return matches[0].duplicate(true)


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
		var momentum_key: String = str({"han": "蜀", "wei": "魏", "wu": "吳"}.get(required_tag, required_tag))
		if int(momentum.get(momentum_key, 0)) < int(requirements.get("min_momentum", 0)):
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
