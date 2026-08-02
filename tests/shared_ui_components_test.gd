extends SceneTree

## 執行方式：
## godot --headless --path . --script res://tests/shared_ui_components_test.gd

var failures: Array[String] = []


func _init() -> void:
	test_menu_option_styles()
	test_status_badge_colors()
	test_text_layout_reuse()
	test_replacement_rows()
	if failures.is_empty():
		print("[PASS] shared_ui_components_test")
		quit(0)
		return
	for failure in failures:
		push_error("[FAIL] %s" % failure)
	quit(1)


func test_menu_option_styles() -> void:
	var normal: Dictionary = MenuOptionRenderer.style(false, true)
	var selected: Dictionary = MenuOptionRenderer.style(true, true)
	var disabled: Dictionary = MenuOptionRenderer.style(false, false)
	check(float(selected["border_width"]) > float(normal["border_width"]), "selected option should have stronger border")
	check(disabled["fill"] != normal["fill"], "disabled option should use a distinct fill")


func test_status_badge_colors() -> void:
	var active: Dictionary = StatusBadgeRenderer.state_colors(HeroRosterManager.ACTIVE)
	var reserve: Dictionary = StatusBadgeRenderer.state_colors(HeroRosterManager.RESERVE)
	var camp: Dictionary = StatusBadgeRenderer.state_colors(HeroRosterManager.CAMP)
	check(active["border"] != reserve["border"], "active and reserve badges should be distinguishable")
	check(reserve["border"] != camp["border"], "reserve and camp badges should be distinguishable")


func test_text_layout_reuse() -> void:
	var direct: Dictionary = TextLayout.visible_range(12, 8, 5)
	var screen_range: Dictionary = HeroConfigScreen.visible_rows(12, 8, 5)
	check(direct == screen_range, "hero config should delegate visible rows to TextLayout")


func test_replacement_rows() -> void:
	var area := Rect2(100.0, 100.0, 500.0, 240.0)
	var rows: Array[Rect2] = HeroReplaceScreen.row_rects(area, 4)
	check(rows.size() == 4, "replacement screen should create one row per hero")
	for row in rows:
		check(area.encloses(row), "replacement row should remain inside list area")
	for index in range(1, rows.size()):
		check(rows[index - 1].end.y <= rows[index].position.y, "replacement rows should not overlap")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
