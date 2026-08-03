class_name HeroRosterFlowCoordinator
extends RefCounted

## 名將整備完整流程的無畫面協調器。
##
## 將「舊欄位同步 → 實體鍵轉 action → Session 更新 → 編成事件套用」串成單一步驟。
## main.gd 後續只需依回傳的 ui_command 播音效、顯示訊息與切換畫面。

const UI_NONE: StringName = &"none"
const UI_CURSOR: StringName = &"cursor"
const UI_OPEN_PICKER: StringName = &"open_picker"
const UI_CLOSE_PICKER: StringName = &"close_picker"
const UI_OPEN_REPLACEMENT: StringName = &"open_replacement"
const UI_CLOSE_REPLACEMENT: StringName = &"close_replacement"
const UI_CLOSE_SCREEN: StringName = &"close_screen"
const UI_ROSTER_CHANGED: StringName = &"roster_changed"
const UI_ALREADY_ASSIGNED: StringName = &"already_assigned"
const UI_ERROR: StringName = &"error"


static func handle_key(
	key: Key,
	legacy_state: Dictionary,
	hero_order: Array[String],
	active: Array,
	reserve: Array,
	camp: Array,
	active_capacity: int,
	reserve_capacity: int
) -> Dictionary:
	return handle_action(
		InputRouter.action_for_key(key),
		legacy_state,
		hero_order,
		active,
		reserve,
		camp,
		active_capacity,
		reserve_capacity
	)


static func handle_action(
	action: StringName,
	legacy_state: Dictionary,
	hero_order: Array[String],
	active: Array,
	reserve: Array,
	camp: Array,
	active_capacity: int,
	reserve_capacity: int
) -> Dictionary:
	var session: HeroRosterSession = HeroRosterLegacyBridge.session_from_legacy(legacy_state)
	var input_event: Dictionary = HeroRosterInputController.handle(
		action,
		session,
		hero_order,
		active,
		reserve,
		camp,
		active_capacity,
		reserve_capacity
	)
	var apply_result: Dictionary = HeroRosterEventApplier.apply(
		input_event,
		active,
		reserve,
		camp,
		active_capacity,
		reserve_capacity
	)
	var next_legacy: Dictionary = HeroRosterLegacyBridge.legacy_from_session(session)
	return {
		"handled": bool(input_event.get("handled", false)),
		"action": action,
		"event": StringName(input_event.get("event", HeroRosterInputController.EVENT_NONE)),
		"ui_command": _ui_command(input_event, apply_result),
		"legacy_state": next_legacy,
		"input_event": input_event,
		"apply_result": apply_result,
		"roster_changed": bool(apply_result.get("changed", false)),
		"active": active,
		"reserve": reserve,
		"camp": camp,
	}


static func _ui_command(input_event: Dictionary, apply_result: Dictionary) -> StringName:
	var result_id: StringName = StringName(apply_result.get("result", HeroRosterEventApplier.RESULT_NONE))
	var event_id: StringName = StringName(input_event.get("event", HeroRosterInputController.EVENT_NONE))
	match result_id:
		HeroRosterEventApplier.RESULT_CURSOR:
			return UI_CURSOR
		HeroRosterEventApplier.RESULT_CLOSE:
			return UI_CLOSE_SCREEN
		HeroRosterEventApplier.RESULT_ROSTER_CHANGED:
			return UI_ROSTER_CHANGED
		HeroRosterEventApplier.RESULT_ALREADY_ASSIGNED:
			return UI_ALREADY_ASSIGNED
		HeroRosterEventApplier.RESULT_ERROR:
			return UI_ERROR
		HeroRosterEventApplier.RESULT_MODAL:
			match event_id:
				HeroRosterInputController.EVENT_OPEN_PICKER:
					return UI_OPEN_PICKER
				HeroRosterInputController.EVENT_CLOSE_PICKER:
					return UI_CLOSE_PICKER
				HeroRosterInputController.EVENT_OPEN_REPLACEMENT:
					return UI_OPEN_REPLACEMENT
				HeroRosterInputController.EVENT_CLOSE_REPLACEMENT:
					return UI_CLOSE_REPLACEMENT
	return UI_NONE
