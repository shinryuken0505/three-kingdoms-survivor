class_name HeroRosterFeedback
extends RefCounted

## 將流程結果轉成穩定的提示 ID、音效 ID 與畫面命令。
##
## 不直接產生玩家可見中文，避免流程依賴顯示文字。main.gd 可暫時依 message_id
## 對應既有訊息；多國語言落地後直接改由 LocalizationService 處理。

const FlowCoordinatorScript = preload("res://scripts/systems/hero/hero_roster_flow_coordinator.gd")

const SFX_NONE: StringName = &""
const SFX_MOVE: StringName = &"ui_move"
const SFX_CONFIRM: StringName = &"ui_confirm"
const SFX_CANCEL: StringName = &"ui_cancel"
const SFX_ERROR: StringName = &"ui_error"


static func from_flow(flow: Dictionary) -> Dictionary:
	var command: StringName = StringName(flow.get("ui_command", FlowCoordinatorScript.UI_NONE))
	var event: Dictionary = flow.get("input_event", {}) as Dictionary
	var applied: Dictionary = flow.get("apply_result", {}) as Dictionary

	if command == FlowCoordinatorScript.UI_CURSOR:
		return _feedback(command, SFX_MOVE)

	if command in [
		FlowCoordinatorScript.UI_OPEN_PICKER,
		FlowCoordinatorScript.UI_OPEN_REPLACEMENT,
	]:
		return _feedback(command, SFX_CONFIRM)

	if command in [
		FlowCoordinatorScript.UI_CLOSE_PICKER,
		FlowCoordinatorScript.UI_CLOSE_REPLACEMENT,
		FlowCoordinatorScript.UI_CLOSE_SCREEN,
	]:
		return _feedback(command, SFX_CANCEL)

	if command == FlowCoordinatorScript.UI_ALREADY_ASSIGNED:
		return _feedback(
			command,
			SFX_ERROR,
			&"message.hero_roster.already_assigned",
			{
				"hero_id": str(applied.get("hero_id", event.get("hero_id", ""))),
				"state": StringName(applied.get("state", event.get("state", &""))),
			}
		)

	if command == FlowCoordinatorScript.UI_ROSTER_CHANGED:
		var replaced_id: String = str(applied.get("replaced_id", ""))
		var message_id: StringName = &"message.hero_roster.moved"
		if not replaced_id.is_empty():
			message_id = &"message.hero_roster.replaced"
		return _feedback(
			command,
			SFX_CONFIRM,
			message_id,
			{
				"hero_id": str(applied.get("hero_id", "")),
				"to": StringName(applied.get("to", &"")),
				"replaced_id": replaced_id,
				"replaced_to": StringName(applied.get("replaced_to", &"")),
			}
		)

	if command == FlowCoordinatorScript.UI_ERROR:
		return _feedback(
			command,
			SFX_ERROR,
			&"message.hero_roster.error",
			{"reason": StringName(applied.get("reason", &"unknown"))}
		)

	return _feedback(FlowCoordinatorScript.UI_NONE, SFX_NONE)


static func _feedback(
	command: StringName,
	sfx: StringName,
	message_id: StringName = &"",
	params: Dictionary = {}
) -> Dictionary:
	return {
		"ui_command": command,
		"sfx": sfx,
		"message_id": message_id,
		"params": params.duplicate(true),
	}
