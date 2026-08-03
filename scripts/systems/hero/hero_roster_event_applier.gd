class_name HeroRosterEventApplier
extends RefCounted

## 將 HeroRosterInputController 回傳事件套用到正式編成資料。
##
## 此橋接層專門處理主戰、後備與營地陣列，以及舊 main.gd 需要同步的
## 畫面暫存欄位。輸入 Controller 不直接改資料；main.gd 只需依事件結果
## 播放音效、顯示訊息與切換畫面。

const RESULT_NONE: StringName = &"none"
const RESULT_CURSOR: StringName = &"cursor"
const RESULT_MODAL: StringName = &"modal"
const RESULT_ROSTER_CHANGED: StringName = &"roster_changed"
const RESULT_CLOSE: StringName = &"close"
const RESULT_ALREADY_ASSIGNED: StringName = &"already_assigned"
const RESULT_ERROR: StringName = &"error"


static func apply(
	event: Dictionary,
	active: Array,
	reserve: Array,
	camp: Array,
	active_capacity: int,
	reserve_capacity: int
) -> Dictionary:
	var event_id: StringName = StringName(event.get("event", HeroRosterInputController.EVENT_NONE))
	match event_id:
		HeroRosterInputController.EVENT_CURSOR_MOVED:
			return {"result": RESULT_CURSOR, "changed": false, "index": int(event.get("index", 0))}
		HeroRosterInputController.EVENT_OPEN_PICKER,
		HeroRosterInputController.EVENT_CLOSE_PICKER,
		HeroRosterInputController.EVENT_OPEN_REPLACEMENT,
		HeroRosterInputController.EVENT_CLOSE_REPLACEMENT:
			return {"result": RESULT_MODAL, "changed": false, "event": event_id}
		HeroRosterInputController.EVENT_CLOSE_SCREEN:
			return {"result": RESULT_CLOSE, "changed": false}
		HeroRosterInputController.EVENT_ALREADY_ASSIGNED:
			return {
				"result": RESULT_ALREADY_ASSIGNED,
				"changed": false,
				"hero_id": str(event.get("hero_id", "")),
				"state": StringName(event.get("state", &"")),
			}
		HeroRosterInputController.EVENT_MOVE_HERO:
			return _move_hero(event, active, reserve, camp, active_capacity, reserve_capacity)
		HeroRosterInputController.EVENT_CONFIRM_REPLACEMENT:
			return _replace_hero(event, active, reserve, camp)
		_:
			return {"result": RESULT_NONE, "changed": false}


static func _move_hero(
	event: Dictionary,
	active: Array,
	reserve: Array,
	camp: Array,
	active_capacity: int,
	reserve_capacity: int
) -> Dictionary:
	var hero_id: String = str(event.get("hero_id", ""))
	var target: StringName = StringName(event.get("to", &""))
	if hero_id.is_empty():
		return {"result": RESULT_ERROR, "changed": false, "reason": "missing_hero"}

	var moved: Dictionary = HeroRosterManager.move_to(
		hero_id,
		target,
		active,
		reserve,
		camp,
		active_capacity,
		reserve_capacity
	)
	if not bool(moved.get("ok", false)):
		return {
			"result": RESULT_ERROR,
			"changed": false,
			"reason": str(moved.get("reason", "move_failed")),
			"hero_id": hero_id,
			"target": target,
		}
	return {
		"result": RESULT_ROSTER_CHANGED,
		"changed": true,
		"hero_id": hero_id,
		"from": StringName(event.get("from", &"")),
		"to": target,
	}


static func _replace_hero(
	event: Dictionary,
	active: Array,
	reserve: Array,
	camp: Array
) -> Dictionary:
	var hero_id: String = str(event.get("hero_id", ""))
	var replaced_id: String = str(event.get("replaced_id", ""))
	var mode: StringName = StringName(event.get("mode", HeroRosterManager.ACTIVE))
	var index: int = int(event.get("index", -1))
	var pool: Array = active if mode == HeroRosterManager.ACTIVE else reserve
	if hero_id.is_empty() or replaced_id.is_empty() or index < 0 or index >= pool.size():
		return {"result": RESULT_ERROR, "changed": false, "reason": "invalid_replacement"}
	if str(pool[index]) != replaced_id:
		return {"result": RESULT_ERROR, "changed": false, "reason": "stale_replacement"}

	HeroRosterManager.remove_everywhere(hero_id, active, reserve, camp)
	pool[index] = hero_id
	if not camp.has(replaced_id):
		camp.append(replaced_id)
	HeroRosterManager.remove_duplicates(active, reserve, camp)
	return {
		"result": RESULT_ROSTER_CHANGED,
		"changed": true,
		"hero_id": hero_id,
		"replaced_id": replaced_id,
		"mode": mode,
		"index": index,
		"to": mode,
		"replaced_to": HeroRosterManager.CAMP,
	}
