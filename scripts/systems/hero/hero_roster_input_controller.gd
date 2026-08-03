class_name HeroRosterInputController
extends RefCounted

## 名將整備畫面的輸入協調層。
##
## 接收 InputRouter 的穩定 action，更新 HeroRosterSession，並呼叫
## HeroRosterController 產生下一步意圖。此層不直接修改正式編成陣列，
## 也不負責播放音效、切換畫面或寫入存檔。

const EVENT_NONE: StringName = &"none"
const EVENT_CURSOR_MOVED: StringName = &"cursor_moved"
const EVENT_OPEN_PICKER: StringName = &"open_picker"
const EVENT_CLOSE_PICKER: StringName = &"close_picker"
const EVENT_CLOSE_SCREEN: StringName = &"close_screen"
const EVENT_MOVE_HERO: StringName = &"move_hero"
const EVENT_OPEN_REPLACEMENT: StringName = &"open_replacement"
const EVENT_CONFIRM_REPLACEMENT: StringName = &"confirm_replacement"
const EVENT_CLOSE_REPLACEMENT: StringName = &"close_replacement"
const EVENT_ALREADY_ASSIGNED: StringName = &"already_assigned"


static func handle(
	action: StringName,
	session: HeroRosterSession,
	hero_order: Array[String],
	active: Array,
	reserve: Array,
	camp: Array,
	active_capacity: int,
	reserve_capacity: int
) -> Dictionary:
	if session == null:
		return {"event": EVENT_NONE, "handled": false, "reason": "missing_session"}

	var replacement_pool: Array = active if session.replacement_mode == HeroRosterManager.ACTIVE else reserve
	session.normalize(hero_order.size(), replacement_pool.size())

	if session.has_replacement():
		return _handle_replacement(action, session, active, reserve)
	if session.position_picker_open:
		return _handle_position_picker(
			action, session, active, reserve, camp, active_capacity, reserve_capacity
		)
	return _handle_main(action, session, hero_order, active, reserve, camp)


static func _handle_main(
	action: StringName,
	session: HeroRosterSession,
	hero_order: Array[String],
	active: Array,
	reserve: Array,
	camp: Array
) -> Dictionary:
	match action:
		InputRouter.ACTION_UP:
			session.hero_index = HeroRosterController.wrap_cursor(session.hero_index, -1, hero_order.size())
			return {"event": EVENT_CURSOR_MOVED, "handled": true, "index": session.hero_index}
		InputRouter.ACTION_DOWN:
			session.hero_index = HeroRosterController.wrap_cursor(session.hero_index, 1, hero_order.size())
			return {"event": EVENT_CURSOR_MOVED, "handled": true, "index": session.hero_index}
		InputRouter.ACTION_CONFIRM:
			var hero_id: String = session.selected_hero_id(hero_order)
			if hero_id.is_empty():
				return {"event": EVENT_NONE, "handled": true, "reason": "empty_roster"}
			var current_state: StringName = HeroRosterManager.state_of(hero_id, active, reserve, camp)
			var result: Dictionary = HeroRosterController.open_picker_for(hero_id, current_state)
			session.open_position_picker(hero_id, int(result.get("target_index", 0)))
			return {
				"event": EVENT_OPEN_PICKER,
				"handled": true,
				"hero_id": hero_id,
				"target_index": session.position_index,
			}
		InputRouter.ACTION_CANCEL, InputRouter.ACTION_TAB:
			return {"event": EVENT_CLOSE_SCREEN, "handled": true}
		_:
			return {"event": EVENT_NONE, "handled": false}


static func _handle_position_picker(
	action: StringName,
	session: HeroRosterSession,
	active: Array,
	reserve: Array,
	camp: Array,
	active_capacity: int,
	reserve_capacity: int
) -> Dictionary:
	match action:
		InputRouter.ACTION_UP:
			session.position_index = HeroPositionPickerScreen.normalized_index(session.position_index - 1)
			return {"event": EVENT_CURSOR_MOVED, "handled": true, "index": session.position_index}
		InputRouter.ACTION_DOWN:
			session.position_index = HeroPositionPickerScreen.normalized_index(session.position_index + 1)
			return {"event": EVENT_CURSOR_MOVED, "handled": true, "index": session.position_index}
		InputRouter.ACTION_CANCEL:
			session.close_position_picker()
			return {"event": EVENT_CLOSE_PICKER, "handled": true}
		InputRouter.ACTION_CONFIRM:
			var hero_id: String = session.position_candidate_id
			var decision: Dictionary = HeroRosterController.resolve_target(
				hero_id,
				session.position_index,
				active,
				reserve,
				camp,
				active_capacity,
				reserve_capacity
			)
			return _apply_target_decision(session, decision)
		_:
			return {"event": EVENT_NONE, "handled": false}


static func _apply_target_decision(session: HeroRosterSession, decision: Dictionary) -> Dictionary:
	var action: StringName = StringName(decision.get("action", HeroRosterController.ACTION_NONE))
	match action:
		HeroRosterController.ACTION_MOVE_HERO:
			session.close_position_picker()
			return {
				"event": EVENT_MOVE_HERO,
				"handled": true,
				"hero_id": str(decision.get("hero_id", "")),
				"from": StringName(decision.get("from", &"")),
				"to": StringName(decision.get("to", &"")),
			}
		HeroRosterController.ACTION_OPEN_REPLACEMENT:
			var hero_id: String = str(decision.get("hero_id", ""))
			var mode: StringName = StringName(decision.get("mode", HeroRosterManager.ACTIVE))
			session.open_replacement(hero_id, mode)
			return {
				"event": EVENT_OPEN_REPLACEMENT,
				"handled": true,
				"hero_id": hero_id,
				"mode": mode,
			}
		HeroRosterController.ACTION_ALREADY_ASSIGNED:
			session.close_position_picker()
			return {
				"event": EVENT_ALREADY_ASSIGNED,
				"handled": true,
				"hero_id": str(decision.get("hero_id", "")),
				"state": StringName(decision.get("state", &"")),
			}
		_:
			session.close_position_picker()
			return {"event": EVENT_CLOSE_PICKER, "handled": true}


static func _handle_replacement(
	action: StringName,
	session: HeroRosterSession,
	active: Array,
	reserve: Array
) -> Dictionary:
	var pool: Array = active if session.replacement_mode == HeroRosterManager.ACTIVE else reserve
	match action:
		InputRouter.ACTION_UP:
			session.replacement_index = HeroReplaceScreen.normalized_index(session.replacement_index - 1, pool.size())
			return {"event": EVENT_CURSOR_MOVED, "handled": true, "index": session.replacement_index}
		InputRouter.ACTION_DOWN:
			session.replacement_index = HeroReplaceScreen.normalized_index(session.replacement_index + 1, pool.size())
			return {"event": EVENT_CURSOR_MOVED, "handled": true, "index": session.replacement_index}
		InputRouter.ACTION_CANCEL:
			session.close_replacement()
			return {"event": EVENT_CLOSE_REPLACEMENT, "handled": true}
		InputRouter.ACTION_CONFIRM:
			var decision: Dictionary = HeroRosterController.resolve_replacement(
				session.candidate_id,
				session.replacement_mode,
				session.replacement_index,
				active,
				reserve
			)
			if StringName(decision.get("action", &"")) != HeroRosterController.ACTION_CONFIRM_REPLACEMENT:
				return {"event": EVENT_NONE, "handled": true, "reason": "invalid_replacement"}
			var result: Dictionary = {
				"event": EVENT_CONFIRM_REPLACEMENT,
				"handled": true,
				"hero_id": str(decision.get("hero_id", "")),
				"replaced_id": str(decision.get("replaced_id", "")),
				"mode": StringName(decision.get("mode", HeroRosterManager.ACTIVE)),
				"index": int(decision.get("index", 0)),
			}
			session.close_replacement()
			return result
		_:
			return {"event": EVENT_NONE, "handled": false}
