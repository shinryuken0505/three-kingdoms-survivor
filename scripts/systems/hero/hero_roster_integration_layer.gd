extends Node

## 名將整備正式接線層。
##
## 在 hero_config／config_replace 畫面期間暫停 main.gd 舊輸入入口，改由
## HeroRosterMainAdapter 與 HeroRosterMainEffects 接管。離開目標畫面後立即恢復
## main.gd 輸入，因此商人、營地、章間返回與其他既有畫面仍沿用原流程。

const TARGET_SCREENS: Array[String] = ["hero_config", "config_replace"]

var _main: Node = null
var _owns_input: bool = false


func _ready() -> void:
	_main = get_parent()
	set_process(true)
	set_process_input(true)


func _exit_tree() -> void:
	_restore_main_input()


func _process(_delta: float) -> void:
	if _main == null:
		return
	var should_own: bool = str(_main.get("screen")) in TARGET_SCREENS
	if should_own == _owns_input:
		return
	_owns_input = should_own
	_main.set_process_input(not _owns_input)


func _input(event: InputEvent) -> void:
	if not _owns_input or _main == null:
		return
	if not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	var key: Key = key_event.keycode
	if key == KEY_NONE:
		key = key_event.physical_keycode
	if key == KEY_NONE and key_event.unicode == 32:
		key = KEY_SPACE
	var action: StringName = _normalized_action(InputRouter.action_for_key(key))
	if action == InputRouter.ACTION_NONE:
		return
	var result: Dictionary = _handle_action(action)
	if bool(result.get("handled", false)):
		get_viewport().set_input_as_handled()


func _normalized_action(action: StringName) -> StringName:
	if action == InputRouter.ACTION_LEFT:
		return InputRouter.ACTION_UP
	if action == InputRouter.ACTION_RIGHT:
		return InputRouter.ACTION_DOWN
	if action == InputRouter.ACTION_TAB:
		var state: Dictionary = _legacy_state()
		if bool(state.get("hero_position_picker_open", false)) or str(_main.get("screen")) == "config_replace":
			return InputRouter.ACTION_CANCEL
	return action


func _handle_action(action: StringName) -> Dictionary:
	var order: Array[String] = []
	var raw_order: Array = _main.call("known_hero_order") as Array
	for value in raw_order:
		order.append(str(value))
	if order.is_empty():
		_main.call("close_hero_config")
		return {"handled": true}

	var active: Array = _main.get("active_heroes") as Array
	var reserve: Array = _main.get("reserve_heroes") as Array
	var camp: Array = _main.get("camp_heroes") as Array
	var origin: StringName = StringName(str(_main.get("hero_config_origin")))
	var adapter_result: Dictionary = HeroRosterMainAdapter.handle_action(
		action,
		_legacy_state(),
		order,
		active,
		reserve,
		camp,
		int(_main.call("active_limit")),
		int(_main.call("reserve_limit")),
		_main.get("heroes") as Dictionary
	)
	var effects: Dictionary = HeroRosterMainEffects.build(adapter_result, origin)
	_apply_effects(effects)
	return adapter_result


func _legacy_state() -> Dictionary:
	return {
		"hero_config_index": int(_main.get("hero_config_index")),
		"hero_config_origin": str(_main.get("hero_config_origin")),
		"config_candidate": str(_main.get("config_candidate")),
		"config_replace_index": int(_main.get("config_replace_index")),
		"config_replace_mode": str(_main.get("config_replace_mode")),
		"hero_position_picker_open": bool(_main.get("hero_position_picker_open")),
		"hero_position_index": int(_main.get("hero_position_index")),
		"hero_position_candidate": str(_main.get("hero_position_candidate")),
	}


func _apply_effects(effects: Dictionary) -> void:
	if bool(effects.get("apply_legacy_state", false)):
		var legacy: Dictionary = effects.get("legacy_state", {}) as Dictionary
		for key in legacy:
			_main.set(str(key), legacy[key])

	var cooldowns: Dictionary = _main.get("hero_cooldowns") as Dictionary
	var cooldown_remove: Array = effects.get("cooldown_remove", []) as Array
	for hero_id in cooldown_remove:
		cooldowns.erase(str(hero_id))
	var cooldown_start: Array = effects.get("cooldown_start", []) as Array
	for hero_id in cooldown_start:
		var hid: String = str(hero_id)
		cooldowns[hid] = float(_main.call("hero_cooldown_value", hid))

	if bool(effects.get("sync_roster", false)):
		_main.call("update_bonds")
	if bool(effects.get("save_checkpoint", false)):
		_main.call("save_run_checkpoint")

	match StringName(effects.get("screen_command", HeroRosterMainEffects.SCREEN_KEEP)):
		HeroRosterMainEffects.SCREEN_HERO_CONFIG:
			_main.set("screen", "hero_config")
		HeroRosterMainEffects.SCREEN_CONFIG_REPLACE:
			_main.set("screen", "config_replace")
		HeroRosterMainEffects.SCREEN_CLOSE_HERO_CONFIG:
			_main.call("close_hero_config")

	var sfx: String = str(effects.get("play_sfx", ""))
	if not sfx.is_empty():
		_main.call("play_sfx", sfx)
	if bool(effects.get("show_message", false)):
		_main.call("show_message", str(effects.get("message", "")), 2.4)
	if bool(effects.get("queue_redraw", false)):
		_main.call("queue_redraw")


func _restore_main_input() -> void:
	if _main != null and is_instance_valid(_main):
		_main.set_process_input(true)
	_owns_input = false
