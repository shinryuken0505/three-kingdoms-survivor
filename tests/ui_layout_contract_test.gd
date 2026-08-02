extends SceneTree

## 執行方式：
## godot --headless --path . --script res://tests/ui_layout_contract_test.gd

var failures: Array[String] = []


func _init() -> void:
	test_position_picker_layout()
	test_replace_layout()
	test_intermission_layout()
	if failures.is_empty():
		print("[PASS] ui_layout_contract_test")
		quit(0)
		return
	for failure in failures:
		push_error("[FAIL] %s" % failure)
	quit(1)


func test_position_picker_layout() -> void:
	var layout: Dictionary = HeroPositionPickerScreen.layout()
	var modal: Rect2 = layout["modal"] as Rect2
	var options: Array = layout["options"] as Array
	check(options.size() == HeroPositionPickerScreen.OPTION_COUNT, "position picker should expose four options")
	check(Rect2(Vector2.ZERO, Vector2(1280.0, 720.0)).encloses(modal), "position picker modal should stay inside view")
	check(not _overlaps_sequence(options), "position picker options should not overlap")


func test_replace_layout() -> void:
	var layout: Dictionary = HeroReplaceScreen.layout(5)
	var modal: Rect2 = layout["modal"] as Rect2
	var rows: Array = layout["rows"] as Array
	check(rows.size() == 5, "replacement layout should expose one row per hero")
	check(Rect2(Vector2.ZERO, Vector2(1280.0, 720.0)).encloses(modal), "replacement modal should stay inside view")
	check(not _overlaps_sequence(rows), "replacement rows should not overlap")


func test_intermission_layout() -> void:
	var layout: Dictionary = IntermissionLayout.build()
	var previous_result: Rect2 = layout["previous_result"] as Rect2
	var carry_over: Rect2 = layout["carry_over"] as Rect2
	var history: Rect2 = layout["history"] as Rect2
	var left_content: Rect2 = layout["left_content"] as Rect2
	var buttons: Array = IntermissionLayout.button_rects(layout["button_row"] as Rect2, 5)
	check(left_content.encloses(previous_result), "previous result should stay inside left content")
	check(left_content.encloses(carry_over), "carry over should stay inside left content")
	check(left_content.encloses(history), "history should stay inside left content")
	check(previous_result.end.y <= carry_over.position.y, "previous result and carry over should not overlap")
	check(carry_over.end.y <= history.position.y, "carry over and history should not overlap")
	check(buttons.size() == 5, "intermission should expose five equal buttons")
	check(not _overlaps_sequence(buttons), "intermission buttons should not overlap")


func _overlaps_sequence(rects: Array) -> bool:
	for index in range(rects.size()):
		var current: Rect2 = rects[index] as Rect2
		for other_index in range(index + 1, rects.size()):
			if current.intersects(rects[other_index] as Rect2):
				return true
	return false


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
