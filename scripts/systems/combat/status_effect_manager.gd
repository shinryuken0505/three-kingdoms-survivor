class_name StatusEffectManager
extends RefCounted

## 狀態效果規則層。
##
## 使用 Array[Dictionary] 保存目前狀態，避免把 poisoned、burning 等欄位
## 繼續散落到 player Dictionary。此階段先提供純資料操作，不直接接管戰鬥傷害。


static func apply(
	current: Array,
	status_id: StringName,
	duration: float,
	stacks: int = 1,
	source_id: StringName = &""
) -> Dictionary:
	var definition: Dictionary = StatusEffectDefs.get_definition(status_id)
	if definition.is_empty():
		return {"ok": false, "reason": "unknown_status", "effects": current.duplicate(true)}
	if duration <= 0.0:
		return {"ok": false, "reason": "invalid_duration", "effects": current.duplicate(true)}

	var effects: Array = current.duplicate(true)
	var existing_index: int = find_index(effects, status_id)
	var incoming_stacks: int = maxi(1, stacks)
	var max_stacks: int = maxi(1, int(definition.get("max_stacks", 1)))
	var policy: StringName = StringName(definition.get("stack_policy", StatusEffectDefs.STACK_REFRESH))

	if existing_index < 0:
		effects.append(_new_effect(status_id, duration, mini(incoming_stacks, max_stacks), source_id, definition))
		return {"ok": true, "event": "added", "effects": sort_for_display(effects)}

	var effect: Dictionary = (effects[existing_index] as Dictionary).duplicate(true)
	match policy:
		StatusEffectDefs.STACK_ADD:
			effect["stacks"] = mini(max_stacks, int(effect.get("stacks", 1)) + incoming_stacks)
			effect["duration"] = maxf(float(effect.get("duration", 0.0)), duration)
		StatusEffectDefs.STACK_REPLACE:
			effect["stacks"] = mini(incoming_stacks, max_stacks)
			effect["duration"] = duration
		_:
			effect["stacks"] = maxi(int(effect.get("stacks", 1)), mini(incoming_stacks, max_stacks))
			effect["duration"] = maxf(float(effect.get("duration", 0.0)), duration)

	if not source_id.is_empty():
		effect["source_id"] = source_id
	effects[existing_index] = effect
	return {"ok": true, "event": "refreshed", "effects": sort_for_display(effects)}


static func tick(current: Array, delta: float) -> Dictionary:
	var effects: Array = []
	var expired: Array[StringName] = []
	for value in current:
		var effect: Dictionary = (value as Dictionary).duplicate(true)
		var remaining: float = maxf(0.0, float(effect.get("duration", 0.0)) - maxf(0.0, delta))
		effect["duration"] = remaining
		if remaining <= 0.0:
			expired.append(StringName(effect.get("id", &"")))
		else:
			effects.append(effect)
	return {"effects": sort_for_display(effects), "expired": expired}


static func remove(current: Array, status_id: StringName) -> Array:
	var effects: Array = []
	for value in current:
		var effect: Dictionary = value as Dictionary
		if StringName(effect.get("id", &"")) != status_id:
			effects.append(effect.duplicate(true))
	return sort_for_display(effects)


static func clear_negative(current: Array) -> Array:
	var effects: Array = []
	for value in current:
		var effect: Dictionary = value as Dictionary
		var definition: Dictionary = StatusEffectDefs.get_definition(StringName(effect.get("id", &"")))
		if not bool(definition.get("is_negative", true)):
			effects.append(effect.duplicate(true))
	return sort_for_display(effects)


static func has(current: Array, status_id: StringName) -> bool:
	return find_index(current, status_id) >= 0


static func find_index(current: Array, status_id: StringName) -> int:
	for index in range(current.size()):
		var effect: Dictionary = current[index] as Dictionary
		if StringName(effect.get("id", &"")) == status_id:
			return index
	return -1


static func sort_for_display(current: Array) -> Array:
	var effects: Array = current.duplicate(true)
	effects.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		var left_priority: int = int(left.get("priority", 0))
		var right_priority: int = int(right.get("priority", 0))
		if left_priority == right_priority:
			return str(left.get("id", "")) < str(right.get("id", ""))
		return left_priority > right_priority
	)
	return effects


static func to_view_model(current: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in sort_for_display(current):
		var effect: Dictionary = value as Dictionary
		result.append({
			"id": StringName(effect.get("id", &"")),
			"icon_path": str(effect.get("icon_path", "")),
			"name_key": StringName(effect.get("name_key", &"")),
			"desc_key": StringName(effect.get("desc_key", &"")),
			"duration": maxf(0.0, float(effect.get("duration", 0.0))),
			"stacks": maxi(1, int(effect.get("stacks", 1))),
			"priority": int(effect.get("priority", 0)),
		})
	return result


static func _new_effect(
	status_id: StringName,
	duration: float,
	stacks: int,
	source_id: StringName,
	definition: Dictionary
) -> Dictionary:
	return {
		"id": status_id,
		"duration": duration,
		"stacks": stacks,
		"source_id": source_id,
		"priority": int(definition.get("priority", 0)),
		"icon_path": str(definition.get("icon_path", "")),
		"name_key": StringName(definition.get("name_key", &"")),
		"desc_key": StringName(definition.get("desc_key", &"")),
	}
