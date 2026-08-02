class_name HeroRosterController
extends RefCounted

## 名將整備的互動決策層。
##
## 只判斷「下一步要做什麼」，不直接繪圖、不播放音效、不寫存檔。
## main.gd 或未來的 screen controller 依回傳 action 執行對應操作。

const ACTION_NONE: StringName = &"none"
const ACTION_CLOSE: StringName = &"close"
const ACTION_MOVE_CURSOR: StringName = &"move_cursor"
const ACTION_OPEN_POSITION_PICKER: StringName = &"open_position_picker"
const ACTION_CLOSE_POSITION_PICKER: StringName = &"close_position_picker"
const ACTION_MOVE_HERO: StringName = &"move_hero"
const ACTION_OPEN_REPLACEMENT: StringName = &"open_replacement"
const ACTION_CONFIRM_REPLACEMENT: StringName = &"confirm_replacement"
const ACTION_CANCEL_REPLACEMENT: StringName = &"cancel_replacement"
const ACTION_ALREADY_ASSIGNED: StringName = &"already_assigned"

const TARGETS: Array[StringName] = [
	HeroRosterManager.ACTIVE,
	HeroRosterManager.RESERVE,
	HeroRosterManager.CAMP,
]


static func open_picker_for(hero_id: String, current_state: StringName) -> Dictionary:
	var index: int = TARGETS.find(current_state)
	if index < 0:
		index = 2
	return {
		"action": ACTION_OPEN_POSITION_PICKER,
		"hero_id": hero_id,
		"target_index": index,
		"target_state": TARGETS[index],
	}


static func resolve_target(
	hero_id: String,
	target_index: int,
	active: Array,
	reserve: Array,
	camp: Array,
	active_capacity: int,
	reserve_capacity: int
) -> Dictionary:
	if target_index < 0 or target_index >= TARGETS.size():
		return {"action": ACTION_CLOSE_POSITION_PICKER, "reason": "cancelled"}

	var target_state: StringName = TARGETS[target_index]
	var current_state: StringName = HeroRosterManager.state_of(hero_id, active, reserve, camp)
	if target_state == current_state:
		return {
			"action": ACTION_ALREADY_ASSIGNED,
			"hero_id": hero_id,
			"state": current_state,
		}

	if target_state == HeroRosterManager.ACTIVE and active.size() >= active_capacity:
		return {
			"action": ACTION_OPEN_REPLACEMENT,
			"hero_id": hero_id,
			"mode": HeroRosterManager.ACTIVE,
			"pool_size": active.size(),
		}

	if target_state == HeroRosterManager.RESERVE and reserve.size() >= reserve_capacity:
		return {
			"action": ACTION_OPEN_REPLACEMENT,
			"hero_id": hero_id,
			"mode": HeroRosterManager.RESERVE,
			"pool_size": reserve.size(),
		}

	return {
		"action": ACTION_MOVE_HERO,
		"hero_id": hero_id,
		"from": current_state,
		"to": target_state,
	}


static func resolve_replacement(
	candidate_id: String,
	mode: StringName,
	selected_index: int,
	active: Array,
	reserve: Array
) -> Dictionary:
	var pool: Array = active if mode == HeroRosterManager.ACTIVE else reserve
	if selected_index < 0 or selected_index >= pool.size():
		return {
			"action": ACTION_CANCEL_REPLACEMENT,
			"hero_id": candidate_id,
			"mode": mode,
		}
	return {
		"action": ACTION_CONFIRM_REPLACEMENT,
		"hero_id": candidate_id,
		"replaced_id": str(pool[selected_index]),
		"mode": mode,
		"index": selected_index,
	}


static func wrap_cursor(current: int, delta: int, item_count: int) -> int:
	if item_count <= 0:
		return 0
	return wrapi(current + delta, 0, item_count)
