extends SceneTree

## 章間畫面模型、畫面路由與輸入命令的純邏輯測試。

var failures: Array[String] = []


func _init() -> void:
	_test_intermission_model()
	_test_compact_intermission_model()
	_test_screen_routes()
	_test_input_commands()
	if failures.is_empty():
		print("[navigation-architecture-test] OK")
		quit(0)
	else:
		for failure in failures:
			push_error("[navigation-architecture-test] %s" % failure)
		quit(1)


func _test_intermission_model() -> void:
	var data := {
		"previous_result": ["擊敗張角", "獲得銅錢 120"],
		"carry_over": ["生命恢復 20%", "保留寶物 1 件"],
		"history": ["黃巾勢力衰退", "董卓開始進京"],
		"right_entries": [
			{"id": "heroes", "label": "主將編成"},
			{"id": "equipment", "label": "裝備整理"},
		],
	}
	var plan: Dictionary = IntermissionScreenModel.build(data, 2)
	_assert(int(plan.get("selected_action", -1)) == 2, "intermission selection should be preserved")
	var actions: Array = plan.get("actions", []) as Array
	_assert(actions.size() == 4, "intermission should expose four default actions")
	_assert(bool((actions[2] as Dictionary).get("selected", false)), "selected action flag missing")
	_assert(IntermissionScreenModel.move_selection(0, -1, 4) == 3, "selection should wrap left")
	_assert(IntermissionScreenModel.move_selection(3, 1, 4) == 0, "selection should wrap right")
	var first_rect: Rect2 = (actions[0] as Dictionary).get("rect", Rect2()) as Rect2
	_assert(IntermissionScreenModel.action_at(plan, first_rect.get_center()) == 0, "action hit test failed")
	_assert(IntermissionScreenModel.action_at(plan, Vector2(-20.0, -20.0)) == -1, "outside hit should return -1")
	_assert_sections_do_not_overlap(plan)


func _test_compact_intermission_model() -> void:
	var many_lines: Array[String] = []
	for index in range(30):
		many_lines.append("歷史事件 %d" % index)
	var plan: Dictionary = IntermissionScreenModel.build({"history": many_lines}, 99, Vector2(960.0, 540.0))
	_assert(int(plan.get("selected_action", -1)) == 3, "selection should clamp on compact layout")
	var history: Dictionary = plan.get("history", {}) as Dictionary
	_assert(int(history.get("hidden_count", 0)) > 0, "overflowing history should report hidden lines")
	_assert_sections_do_not_overlap(plan)
	for value in plan.get("actions", []) as Array:
		var rect: Rect2 = (value as Dictionary).get("rect", Rect2()) as Rect2
		_assert(rect.size.x >= 0.0 and rect.size.y >= 0.0, "compact action rect must remain valid")


func _test_screen_routes() -> void:
	var routes: Dictionary = ScreenRouteRegistry.defaults()
	_assert(routes.size() == ScreenIds.all().size(), "every ScreenIds entry should have one route")
	_assert(ScreenRouteRegistry.validate(routes).is_empty(), "default route registry should validate")
	var pause: Dictionary = ScreenRouteRegistry.get_route(ScreenIds.PAUSE, routes)
	_assert(bool(pause.get(ScreenRouteRegistry.MODAL, false)), "pause route should be modal")
	_assert(bool(pause.get(ScreenRouteRegistry.PAUSES_WORLD, false)), "pause route should pause world")
	var broken: Dictionary = routes.duplicate(true)
	broken.erase(ScreenIds.INTERMISSION)
	_assert(not ScreenRouteRegistry.validate(broken).is_empty(), "missing route should be reported")


func _test_input_commands() -> void:
	_assert(UIInputCommand.from_keycode(KEY_UP) == UIInputCommand.UP, "up key mapping failed")
	_assert(UIInputCommand.from_keycode(KEY_W) == UIInputCommand.UP, "W key mapping failed")
	_assert(UIInputCommand.from_keycode(KEY_SPACE) == UIInputCommand.CONFIRM, "space confirm mapping failed")
	_assert(UIInputCommand.from_keycode(KEY_ESCAPE) == UIInputCommand.CANCEL, "escape cancel mapping failed")
	_assert(UIInputCommand.axis(UIInputCommand.LEFT) == Vector2i.LEFT, "left axis mapping failed")
	_assert(UIInputCommand.is_navigation(UIInputCommand.DOWN), "down should be navigation")
	_assert(not UIInputCommand.should_consume(UIInputCommand.NONE), "none command should not be consumed")
	var event := InputEventKey.new()
	event.keycode = KEY_ENTER
	event.pressed = true
	_assert(UIInputCommand.from_event(event) == UIInputCommand.CONFIRM, "pressed event mapping failed")
	event.echo = true
	_assert(UIInputCommand.from_event(event) == UIInputCommand.NONE, "echo event should be ignored")


func _assert_sections_do_not_overlap(plan: Dictionary) -> void:
	var previous: Rect2 = ((plan.get("previous_result", {}) as Dictionary).get("rect", Rect2()) as Rect2)
	var carry: Rect2 = ((plan.get("carry_over", {}) as Dictionary).get("rect", Rect2()) as Rect2)
	var history: Rect2 = ((plan.get("history", {}) as Dictionary).get("rect", Rect2()) as Rect2)
	_assert(previous.end.y <= carry.position.y, "previous result overlaps carry-over")
	_assert(carry.end.y <= history.position.y, "carry-over overlaps history")


func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
