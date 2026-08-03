class_name HeroRosterMainAdapter
extends RefCounted

## 提供 main.gd 可直接呼叫的名將整備接線入口。
##
## 明確 preload 相依腳本，避免 Godot 在掃描多個 class_name 時因解析順序
## 導致 Adapter 被誤判為 parser error。

const FlowCoordinatorScript = preload("res://scripts/systems/hero/hero_roster_flow_coordinator.gd")
const FeedbackScript = preload("res://scripts/systems/hero/hero_roster_feedback.gd")
const FeedbackPresenterScript = preload("res://scripts/systems/hero/hero_roster_feedback_presenter.gd")


static func handle_key(
	key: Key,
	legacy_state: Dictionary,
	hero_order: Array[String],
	active: Array,
	reserve: Array,
	camp: Array,
	active_capacity: int,
	reserve_capacity: int,
	hero_defs: Dictionary
) -> Dictionary:
	var flow: Dictionary = FlowCoordinatorScript.handle_key(
		key,
		legacy_state,
		hero_order,
		active,
		reserve,
		camp,
		active_capacity,
		reserve_capacity
	)
	return _build_result(flow, hero_defs)


static func handle_action(
	action: StringName,
	legacy_state: Dictionary,
	hero_order: Array[String],
	active: Array,
	reserve: Array,
	camp: Array,
	active_capacity: int,
	reserve_capacity: int,
	hero_defs: Dictionary
) -> Dictionary:
	var flow: Dictionary = FlowCoordinatorScript.handle_action(
		action,
		legacy_state,
		hero_order,
		active,
		reserve,
		camp,
		active_capacity,
		reserve_capacity
	)
	return _build_result(flow, hero_defs)


static func _build_result(flow: Dictionary, hero_defs: Dictionary) -> Dictionary:
	var feedback: Dictionary = FeedbackScript.from_flow(flow)
	var command: StringName = StringName(flow.get("ui_command", FlowCoordinatorScript.UI_NONE))
	return {
		"handled": bool(flow.get("handled", false)),
		"ui_command": command,
		"legacy_state": (flow.get("legacy_state", {}) as Dictionary).duplicate(true),
		"roster_changed": bool(flow.get("roster_changed", false)),
		"should_sync_roster": bool(flow.get("roster_changed", false)),
		"should_save_checkpoint": bool(flow.get("roster_changed", false)),
		"screen_command": _screen_command(command),
		"sfx": StringName(feedback.get("sfx", &"")),
		"message": FeedbackPresenterScript.message(feedback, hero_defs),
		"message_id": StringName(feedback.get("message_id", &"")),
		"message_params": (feedback.get("params", {}) as Dictionary).duplicate(true),
		"input_event": (flow.get("input_event", {}) as Dictionary).duplicate(true),
		"apply_result": (flow.get("apply_result", {}) as Dictionary).duplicate(true),
	}


static func _screen_command(command: StringName) -> StringName:
	if command == FlowCoordinatorScript.UI_OPEN_REPLACEMENT:
		return &"config_replace"
	if command in [
		FlowCoordinatorScript.UI_CLOSE_REPLACEMENT,
		FlowCoordinatorScript.UI_ROSTER_CHANGED,
		FlowCoordinatorScript.UI_ALREADY_ASSIGNED,
		FlowCoordinatorScript.UI_ERROR,
	]:
		return &"hero_config"
	if command == FlowCoordinatorScript.UI_CLOSE_SCREEN:
		return &"close_hero_config"
	return &"keep"
