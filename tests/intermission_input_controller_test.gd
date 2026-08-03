extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	test_cursor_wraps()
	test_confirm_and_cancel()
	test_empty_buttons()
	if failures.is_empty():
		print("[PASS] intermission_input_controller_test")
		quit(0)
		return
	for failure in failures:
		push_error("[FAIL] %s" % failure)
	quit(1)


func test_cursor_wraps() -> void:
	var left: Dictionary = IntermissionInputController.handle(InputRouter.ACTION_LEFT, 0, 4)
	check(int(left["selected_index"]) == 3, "left from first button should wrap to last")
	var right: Dictionary = IntermissionInputController.handle(InputRouter.ACTION_RIGHT, 3, 4)
	check(int(right["selected_index"]) == 0, "right from last button should wrap to first")
	check(StringName(right["command"]) == IntermissionInputController.COMMAND_CURSOR, "direction should return cursor command")


func test_confirm_and_cancel() -> void:
	var confirm: Dictionary = IntermissionInputController.handle(InputRouter.ACTION_CONFIRM, 2, 4)
	check(bool(confirm["handled"]), "confirm should be handled")
	check(StringName(confirm["command"]) == IntermissionInputController.COMMAND_CONFIRM, "confirm command should be stable")
	var cancel: Dictionary = IntermissionInputController.handle(InputRouter.ACTION_CANCEL, 1, 4)
	check(StringName(cancel["command"]) == IntermissionInputController.COMMAND_CANCEL, "cancel command should be stable")
	var buttons: Array = [{"id": &"continue"}, {"id": &"hero_config"}, {"id": &"save"}, {"id": &"menu"}]
	check(IntermissionInputController.command_for_button(buttons, 5) == &"hero_config", "button command should normalize index")


func test_empty_buttons() -> void:
	var result: Dictionary = IntermissionInputController.handle(InputRouter.ACTION_CONFIRM, 8, 0)
	check(not bool(result["handled"]), "empty button list should ignore input")
	check(int(result["selected_index"]) == 0, "empty button list should normalize index to zero")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
