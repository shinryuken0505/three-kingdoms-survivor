extends SceneTree

## 執行方式：
## godot --headless --path . --script res://tests/hero_roster_session_test.gd

var failures: Array[String] = []


func _init() -> void:
	test_reset()
	test_position_picker()
	test_replacement()
	test_selected_hero()
	if failures.is_empty():
		print("[PASS] hero_roster_session_test")
		quit(0)
		return
	for failure in failures:
		push_error("[FAIL] %s" % failure)
	quit(1)


func test_reset() -> void:
	var session := HeroRosterSession.new()
	session.hero_index = 4
	session.candidate_id = "guanyu"
	session.position_picker_open = true
	session.reset(&"camp")
	check(session.hero_index == 0, "reset should restore hero index")
	check(session.origin == &"camp", "reset should keep the requested origin")
	check(session.candidate_id.is_empty(), "reset should clear replacement candidate")
	check(not session.position_picker_open, "reset should close position picker")


func test_position_picker() -> void:
	var session := HeroRosterSession.new()
	session.open_position_picker("zhangfei", 5)
	check(session.position_picker_open, "picker should open")
	check(session.position_candidate_id == "zhangfei", "picker should keep candidate id")
	check(session.position_index == 1, "picker index should wrap to valid range")
	session.close_position_picker()
	check(not session.position_picker_open, "picker should close")
	check(session.position_candidate_id.is_empty(), "picker close should clear candidate")


func test_replacement() -> void:
	var session := HeroRosterSession.new()
	session.open_position_picker("lvbu", 0)
	session.open_replacement("lvbu", HeroRosterManager.RESERVE)
	check(session.has_replacement(), "replacement should become active")
	check(session.candidate_id == "lvbu", "replacement should keep candidate id")
	check(session.replacement_mode == HeroRosterManager.RESERVE, "replacement should keep mode")
	check(not session.position_picker_open, "replacement should close picker")
	session.close_replacement()
	check(not session.has_replacement(), "replacement close should clear state")


func test_selected_hero() -> void:
	var session := HeroRosterSession.new()
	var order: Array[String] = ["liubei", "guanyu", "zhangfei"]
	var empty_order: Array[String] = []
	session.hero_index = 9
	check(session.selected_hero_id(order) == "zhangfei", "selected hero should clamp to last entry")
	check(session.hero_index == 2, "selected hero should normalize stored index")
	check(session.selected_hero_id(empty_order).is_empty(), "empty order should return empty id")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
