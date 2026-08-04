class_name IntermissionInputController
extends RefCounted

## 章間整備畫面的純輸入協調器。
## 不直接切換 main.gd 畫面，只回傳穩定 command 與新的選取索引。

const InputRouterScript = preload("res://scripts/core/input_router.gd")

const COMMAND_NONE: StringName = &"none"
const COMMAND_CURSOR: StringName = &"cursor"
const COMMAND_CONFIRM: StringName = &"confirm"
const COMMAND_CANCEL: StringName = &"cancel"


static func handle(action: StringName, selected_index: int, button_count: int) -> Dictionary:
	var safe_count: int = maxi(0, button_count)
	var safe_index: int = 0 if safe_count == 0 else posmod(selected_index, safe_count)
	if safe_count == 0:
		return _result(false, COMMAND_NONE, 0)
	if action == InputRouterScript.ACTION_LEFT or action == InputRouterScript.ACTION_UP:
		return _result(true, COMMAND_CURSOR, posmod(safe_index - 1, safe_count))
	if action == InputRouterScript.ACTION_RIGHT or action == InputRouterScript.ACTION_DOWN:
		return _result(true, COMMAND_CURSOR, posmod(safe_index + 1, safe_count))
	if action == InputRouterScript.ACTION_CONFIRM:
		return _result(true, COMMAND_CONFIRM, safe_index)
	if action == InputRouterScript.ACTION_CANCEL:
		return _result(true, COMMAND_CANCEL, safe_index)
	return _result(false, COMMAND_NONE, safe_index)


static func command_for_button(buttons: Array, selected_index: int) -> StringName:
	if buttons.is_empty():
		return &""
	var index: int = posmod(selected_index, buttons.size())
	var button: Dictionary = buttons[index] as Dictionary
	return StringName(button.get("id", button.get("key", &"")))


static func _result(handled: bool, command: StringName, selected_index: int) -> Dictionary:
	return {
		"handled": handled,
		"command": command,
		"selected_index": selected_index,
	}
