extends SceneTree

## Alpha.17 單次驗收的快速整合測試。
## 執行方式：
## godot --headless --path . --script res://tests/alpha17_integration_smoke_test.gd

var failures: Array[String] = []


func _init() -> void:
	test_main_scene_wiring()
	test_screen_registry()
	test_intermission_contract()
	test_status_hud_contract()
	test_hero_roster_contract()
	if failures.is_empty():
		print("[PASS] alpha17_integration_smoke_test")
		quit(0)
		return
	for failure in failures:
		push_error("[FAIL] %s" % failure)
	quit(1)


func test_main_scene_wiring() -> void:
	var packed: PackedScene = load("res://main.tscn") as PackedScene
	check(packed != null, "main.tscn should load")
	if packed == null:
		return
	var root: Node = packed.instantiate()
	check(root != null, "main.tscn should instantiate")
	if root != null:
		check(root.has_node("StatusEffectHudLayer"), "main scene should mount StatusEffectHudLayer")
		check(root.has_method("draw_ending"), "ending route draw method should exist")
		check(root.has_method("handle_ending_key"), "ending route input method should exist")
		root.free()


func test_screen_registry() -> void:
	var missing: Array[String] = ScreenRouteRegistry.validate()
	check(missing.is_empty(), "every ScreenIds entry should have a route")
	var intermission: Dictionary = ScreenRouteRegistry.get_route(ScreenIds.INTERMISSION)
	check(str(intermission.get(ScreenRouteRegistry.DRAW_METHOD, "")) == "draw_intermission_screen", "intermission draw route should remain stable")
	check(str(intermission.get(ScreenRouteRegistry.INPUT_METHOD, "")) == "handle_intermission_key", "intermission input route should remain stable")


func test_intermission_contract() -> void:
	var model: Dictionary = IntermissionScreenModel.build({
		"selected_index": 1,
		"previous_result": ["章節完成"],
		"carry_over": ["銅錢 120"],
		"history": ["史勢演變"],
	}, 1, Vector2(1280.0, 720.0))
	var buttons: Array = model.get("actions", []) as Array
	check(buttons.size() == 4, "intermission should expose four default actions")
	check(IntermissionInputController.command_for_button(buttons, 1) != &"", "selected intermission action should have stable id")
	var layout: Dictionary = model.get("layout", {}) as Dictionary
	var left: Rect2 = layout.get("left_panel", Rect2()) as Rect2
	var right: Rect2 = layout.get("right_panel", Rect2()) as Rect2
	check(not left.intersects(right), "intermission columns should not overlap")


func test_status_hud_contract() -> void:
	var plan: Dictionary = StatusEffectHud.build(
		{"pos": Vector2.ZERO, "control_lock": 1.2, "move_slow": 2.5, "vision_obscure": 0.8},
		Vector2(640.0, 360.0)
	)
	check((plan.get("items", []) as Array).size() == 3, "legacy battle fields should produce three status items")
	check((plan.get("above_player", []) as Array).size() <= 3, "above-player status count should be capped")
	check(not str(plan.get("summary", "")).is_empty(), "status HUD should provide accessibility summary")


func test_hero_roster_contract() -> void:
	var active: Array = ["liubei"]
	var reserve: Array = []
	var camp: Array = ["guanyu"]
	var legacy: Dictionary = HeroRosterLegacyBridge.default_legacy_state()
	legacy["hero_config_index"] = 1
	var order: Array[String] = ["liubei", "guanyu"]
	var opened: Dictionary = HeroRosterFlowCoordinator.handle_action(
		InputRouter.ACTION_CONFIRM, legacy, order, active, reserve, camp, 1, 1
	)
	check(StringName(opened.get("ui_command", &"")) == HeroRosterFlowCoordinator.UI_OPEN_PICKER, "hero confirm should open picker")
	var feedback: Dictionary = HeroRosterFeedback.from_flow(opened)
	check(StringName(feedback.get("sfx", &"")) == HeroRosterFeedback.SFX_CONFIRM, "opening picker should request confirm sound")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
