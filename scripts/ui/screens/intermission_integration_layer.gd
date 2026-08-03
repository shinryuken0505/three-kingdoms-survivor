extends Node

## 章間整備輸入正式接線層。
##
## 只在 intermission 畫面暫停 main.gd 舊輸入，改由 IntermissionInputController
## 統一方向鍵與確認／取消；實際選項行為仍呼叫 main.gd 既有公開方法，確保存檔、
## BGM、裝備頁與下一章流程不變。

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
	var should_own: bool = str(_main.get("screen")) == "intermission"
	if should_own == _owns_input:
		return
	_owns_input = should_own
	if should_own:
		_main.set_process_input(false)
	else:
		_restore_main_input()


func _input(event: InputEvent) -> void:
	if not _owns_input or _main == null or not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	var key: Key = key_event.keycode
	if key == KEY_NONE:
		key = key_event.physical_keycode
	if key == KEY_NONE and key_event.unicode == 32:
		key = KEY_SPACE
	var action: StringName = InputRouter.action_for_key(key)
	var options: Array = _main.call("intermission_options") as Array
	var result: Dictionary = IntermissionInputController.handle(
		action,
		int(_main.get("option_index")),
		options.size()
	)
	if not bool(result.get("handled", false)):
		return
	_main.set("option_index", int(result.get("selected_index", 0)))
	match StringName(result.get("command", IntermissionInputController.COMMAND_NONE)):
		IntermissionInputController.COMMAND_CURSOR:
			_main.call("play_sfx", "ui_move")
		IntermissionInputController.COMMAND_CANCEL:
			_main.call("return_to_menu")
		IntermissionInputController.COMMAND_CONFIRM:
			_main.call("play_sfx", "ui_confirm")
			_activate_selected(options)
	_main.call("queue_redraw")
	get_viewport().set_input_as_handled()


func _activate_selected(options: Array) -> void:
	if options.is_empty():
		return
	var index: int = clampi(int(_main.get("option_index")), 0, options.size() - 1)
	var selected: String = str(options[index])
	match selected:
		"名將整備":
			_main.call("open_hero_config", "intermission")
		"裝備整備":
			_main.set("previous_screen", "intermission")
			_main.set("screen", "tab")
			_main.set("tab_page", 1)
			_main.set("tab_index", 0)
			_main.set("tab_scroll", 0)
		"儲存章節進度":
			if bool(_main.call("save_run_checkpoint")):
				_main.call("show_message", "章節進度已手動保存。", 2.4)
			else:
				_main.call("show_message", "目前無法建立章節存檔。", 2.4)
		"進入下一章":
			_main.call("begin_next_chapter")
		_:
			_main.call("return_to_menu")


func _restore_main_input() -> void:
	if _main != null and is_instance_valid(_main):
		_main.set_process_input(true)
	_owns_input = false
