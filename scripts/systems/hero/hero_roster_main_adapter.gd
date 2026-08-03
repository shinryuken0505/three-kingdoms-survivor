class_name HeroRosterMainAdapter
extends RefCounted

## 提供 main.gd 可直接呼叫的名將整備接線入口。
##
## 此層包裝 FlowCoordinator、Feedback 與 Presenter，回傳：
## - 更新後的舊欄位值
## - 是否切換畫面
## - 是否更新編成與存檔
## - 音效 ID 與已本地化提示文字
## main.gd 後續只需套用結果，不再重複判斷三層輸入流程。


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
	var flow: Dictionary = HeroRosterFlowCoordinator.handle_key(
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
	var flow: Dictionary = HeroRosterFlowCoordinator.handle_action(
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
	var feedback: Dictionary = HeroRosterFeedback.from_flow(flow)
	var presentation: Dictionary = HeroRosterFeedbackPresenter.present(feedback, hero_defs)
	var command: StringName = StringName(flow.get("ui_command", HeroRosterFlowCoordinator.UI_NONE))
	return {
		"handled": bool(flow.get("handled", false)),
		"ui_command": command,
		"legacy_state": (flow.get("legacy_state", {}) as Dictionary).duplicate(true),
		"roster_changed": bool(flow.get("roster_changed", false)),
		"should_sync_roster": bool(flow.get("roster_changed", false)),
		"should_save_checkpoint": bool(flow.get("roster_changed", false)),
		"screen_command": _screen_command(command),
		"sfx": StringName(presentation.get("sfx", &"")),
		"message": str(presentation.get("message", "")),
		"message_id": StringName(presentation.get("message_id", &"")),
		"message_params": (presentation.get("params", {}) as Dictionary).duplicate(true),
		"input_event": (flow.get("input_event", {}) as Dictionary).duplicate(true),
		"apply_result": (flow.get("apply_result", {}) as Dictionary).duplicate(true),
	}


static func _screen_command(command: StringName) -> StringName:
	match command:
		HeroRosterFlowCoordinator.UI_OPEN_REPLACEMENT:
			return &"config_replace"
		HeroRosterFlowCoordinator.UI_CLOSE_REPLACEMENT,
		HeroRosterFlowCoordinator.UI_ROSTER_CHANGED,
		HeroRosterFlowCoordinator.UI_ALREADY_ASSIGNED,
		HeroRosterFlowCoordinator.UI_ERROR:
			return &"hero_config"
		HeroRosterFlowCoordinator.UI_CLOSE_SCREEN:
			return &"close_hero_config"
	return &"keep"
