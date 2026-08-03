extends SceneTree

## 執行方式：
## godot --headless --path . --script res://tests/hero_roster_input_controller_test.gd

var failures: Array[String] = []


func _init() -> void:
	test_main_cursor_and_open_picker()
	test_move_to_camp()
	test_open_and_confirm_replacement()
	test_cancel_paths()
	if failures.is_empty():
		print("[PASS] hero_roster_input_controller_test")
		quit(0)
		return
	for failure in failures:
		push_error("[FAIL] %s" % failure)
	quit(1)


func test_main_cursor_and_open_picker() -> void:
	var session := HeroRosterSession.new()
	var order: Array[String] = ["liubei", "guanyu", "zhangfei"]
	var active: Array = ["liubei"]
	var reserve: Array = ["guanyu"]
	var camp: Array = ["zhangfei"]
	var moved: Dictionary = HeroRosterInputController.handle(
		InputRouter.ACTION_DOWN, session, order, active, reserve, camp, 2, 2
	)
	check(StringName(moved.get("event", &"")) == HeroRosterInputController.EVENT_CURSOR_MOVED, "down should move main cursor")
	check(session.hero_index == 1, "main cursor should point at second hero")
	var opened: Dictionary = HeroRosterInputController.handle(
		InputRouter.ACTION_CONFIRM, session, order, active, reserve, camp, 2, 2
	)
	check(StringName(opened.get("event", &"")) == HeroRosterInputController.EVENT_OPEN_PICKER, "confirm should open picker")
	check(session.position_picker_open, "picker state should be open")
	check(session.position_candidate_id == "guanyu", "picker should keep selected hero")
	check(session.position_index == 1, "picker should start at current reserve state")


func test_move_to_camp() -> void:
	var session := HeroRosterSession.new()
	session.open_position_picker("liubei", 2)
	var result: Dictionary = HeroRosterInputController.handle(
		InputRouter.ACTION_CONFIRM,
		session,
		["liubei"],
		["liubei"],
		[],
		[],
		2,
		2
	)
	check(StringName(result.get("event", &"")) == HeroRosterInputController.EVENT_MOVE_HERO, "camp target should emit move event")
	check(StringName(result.get("to", &"")) == HeroRosterManager.CAMP, "move event should target camp")
	check(not session.position_picker_open, "picker should close after move decision")


func test_open_and_confirm_replacement() -> void:
	var session := HeroRosterSession.new()
	session.open_position_picker("zhangfei", 0)
	var active: Array = ["liubei", "guanyu"]
	var opened: Dictionary = HeroRosterInputController.handle(
		InputRouter.ACTION_CONFIRM,
		session,
		["liubei", "guanyu", "zhangfei"],
		active,
		[],
		["zhangfei"],
		2,
		2
	)
	check(StringName(opened.get("event", &"")) == HeroRosterInputController.EVENT_OPEN_REPLACEMENT, "full active roster should open replacement")
	check(session.has_replacement(), "replacement state should be active")
	check(session.replacement_mode == HeroRosterManager.ACTIVE, "replacement mode should be active")
	HeroRosterInputController.handle(
		InputRouter.ACTION_DOWN,
		session,
		["liubei", "guanyu", "zhangfei"],
		active,
		[],
		["zhangfei"],
		2,
		2
	)
	check(session.replacement_index == 1, "replacement cursor should move")
	var confirmed: Dictionary = HeroRosterInputController.handle(
		InputRouter.ACTION_CONFIRM,
		session,
		["liubei", "guanyu", "zhangfei"],
		active,
		[],
		["zhangfei"],
		2,
		2
	)
	check(StringName(confirmed.get("event", &"")) == HeroRosterInputController.EVENT_CONFIRM_REPLACEMENT, "confirm should emit replacement event")
	check(str(confirmed.get("hero_id", "")) == "zhangfei", "replacement should preserve candidate")
	check(str(confirmed.get("replaced_id", "")) == "guanyu", "replacement should identify selected hero")
	check(not session.has_replacement(), "replacement state should clear after confirm")


func test_cancel_paths() -> void:
	var session := HeroRosterSession.new()
	var closed: Dictionary = HeroRosterInputController.handle(
		InputRouter.ACTION_CANCEL, session, ["liubei"], ["liubei"], [], [], 2, 2
	)
	check(StringName(closed.get("event", &"")) == HeroRosterInputController.EVENT_CLOSE_SCREEN, "cancel on main screen should close screen")
	session.open_position_picker("liubei", 0)
	var picker_closed: Dictionary = HeroRosterInputController.handle(
		InputRouter.ACTION_CANCEL, session, ["liubei"], ["liubei"], [], [], 2, 2
	)
	check(StringName(picker_closed.get("event", &"")) == HeroRosterInputController.EVENT_CLOSE_PICKER, "cancel should close picker first")
	session.open_replacement("zhangfei", HeroRosterManager.ACTIVE)
	var replacement_closed: Dictionary = HeroRosterInputController.handle(
		InputRouter.ACTION_CANCEL, session, ["liubei", "zhangfei"], ["liubei"], [], ["zhangfei"], 1, 2
	)
	check(StringName(replacement_closed.get("event", &"")) == HeroRosterInputController.EVENT_CLOSE_REPLACEMENT, "cancel should close replacement first")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
