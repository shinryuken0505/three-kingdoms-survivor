class_name RecruitmentRosterCoordinator
extends RefCounted

## 招賢館與名將整備共用的編成協調流程。
##
## 新名將先建立位置選擇狀態，再沿用 HeroRosterController 與
## HeroRosterEventApplier 的規則。此層只修改傳入的編成陣列並回傳初始化計畫，
## 不處理遭遇冷卻、畫面切換、音效或玩家存檔。

const RESULT_OPEN_PICKER: StringName = &"open_picker"
const RESULT_CANCELLED: StringName = &"cancelled"
const RESULT_ALREADY_ASSIGNED: StringName = &"already_assigned"
const RESULT_OPEN_REPLACEMENT: StringName = &"open_replacement"
const RESULT_PLACED: StringName = &"placed"
const RESULT_REPLACED: StringName = &"replaced"
const RESULT_ERROR: StringName = &"error"


static func begin(hero_id: String, active: Array, reserve: Array, camp: Array) -> Dictionary:
	if hero_id.is_empty():
		return {"result": RESULT_ERROR, "reason": &"missing_hero"}
	var request: Dictionary = RecruitmentPlacementService.begin(hero_id, active, reserve, camp)
	return {
		"result": RESULT_OPEN_PICKER,
		"hero_id": hero_id,
		"current_state": StringName(request.get("current_state", HeroRosterManager.UNKNOWN)),
		"target_index": int((request.get("picker", {}) as Dictionary).get("target_index", 0)),
		"initialization": RecruitmentPlacementService.initialization_payload(hero_id),
	}


static func choose_target(
	hero_id: String,
	target_index: int,
	active: Array,
	reserve: Array,
	camp: Array,
	active_capacity: int,
	reserve_capacity: int
) -> Dictionary:
	if target_index == 3:
		return cancel(hero_id)
	var decision: Dictionary = RecruitmentPlacementService.resolve_target(
		hero_id, target_index, active, reserve, camp, active_capacity, reserve_capacity
	)
	var action: StringName = StringName(decision.get("action", HeroRosterController.ACTION_NONE))
	match action:
		HeroRosterController.ACTION_ALREADY_ASSIGNED:
			return {
				"result": RESULT_ALREADY_ASSIGNED,
				"hero_id": hero_id,
				"state": StringName(decision.get("state", HeroRosterManager.UNKNOWN)),
				"initialization": RecruitmentPlacementService.initialization_payload(hero_id),
			}
		HeroRosterController.ACTION_OPEN_REPLACEMENT:
			return {
				"result": RESULT_OPEN_REPLACEMENT,
				"hero_id": hero_id,
				"mode": StringName(decision.get("mode", HeroRosterManager.ACTIVE)),
				"replacement_index": 0,
				"initialization": RecruitmentPlacementService.initialization_payload(hero_id),
			}
		HeroRosterController.ACTION_MOVE_HERO:
			var event: Dictionary = {
				"event": HeroRosterInputController.EVENT_MOVE_HERO,
				"hero_id": hero_id,
				"from": StringName(decision.get("from", HeroRosterManager.UNKNOWN)),
				"to": StringName(decision.get("to", HeroRosterManager.CAMP)),
			}
			var applied: Dictionary = HeroRosterEventApplier.apply(
				event, active, reserve, camp, active_capacity, reserve_capacity
			)
			if StringName(applied.get("result", &"")) != HeroRosterEventApplier.RESULT_ROSTER_CHANGED:
				return {"result": RESULT_ERROR, "reason": applied.get("reason", &"place_failed")}
			return {
				"result": RESULT_PLACED,
				"hero_id": hero_id,
				"to": StringName(applied.get("to", HeroRosterManager.UNKNOWN)),
				"initialization": RecruitmentPlacementService.initialization_payload(hero_id),
			}
	return {"result": RESULT_ERROR, "reason": &"invalid_target"}


static func confirm_replacement(
	hero_id: String,
	mode: StringName,
	replacement_index: int,
	active: Array,
	reserve: Array,
	camp: Array,
	active_capacity: int,
	reserve_capacity: int
) -> Dictionary:
	var pool: Array = active if mode == HeroRosterManager.ACTIVE else reserve
	if replacement_index < 0 or replacement_index >= pool.size():
		return {"result": RESULT_ERROR, "reason": &"invalid_replacement"}
	var replaced_id: String = str(pool[replacement_index])
	var event: Dictionary = {
		"event": HeroRosterInputController.EVENT_CONFIRM_REPLACEMENT,
		"hero_id": hero_id,
		"replaced_id": replaced_id,
		"mode": mode,
		"index": replacement_index,
	}
	var applied: Dictionary = HeroRosterEventApplier.apply(
		event, active, reserve, camp, active_capacity, reserve_capacity
	)
	if StringName(applied.get("result", &"")) != HeroRosterEventApplier.RESULT_ROSTER_CHANGED:
		return {"result": RESULT_ERROR, "reason": applied.get("reason", &"replace_failed")}
	return {
		"result": RESULT_REPLACED,
		"hero_id": hero_id,
		"replaced_id": replaced_id,
		"to": mode,
		"replaced_to": StringName(applied.get("replaced_to", HeroRosterManager.CAMP)),
		"initialization": RecruitmentPlacementService.initialization_payload(hero_id),
	}


static func cancel(hero_id: String) -> Dictionary:
	var cancelled: Dictionary = RecruitmentPlacementService.cancel(hero_id)
	return {
		"result": RESULT_CANCELLED,
		"hero_id": str(cancelled.get("hero_id", hero_id)),
	}
