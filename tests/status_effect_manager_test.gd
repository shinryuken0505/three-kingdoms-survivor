extends SceneTree

## 執行方式：
## godot --headless --path . --script res://tests/status_effect_manager_test.gd

var failures: Array[String] = []


func _init() -> void:
	test_add_and_tick()
	test_stack_limit()
	test_refresh_policy()
	test_display_priority()
	test_renderer_layout()
	if failures.is_empty():
		print("[PASS] status_effect_manager_test")
		quit(0)
		return
	for failure in failures:
		push_error("[FAIL] %s" % failure)
	quit(1)


func test_add_and_tick() -> void:
	var added: Dictionary = StatusEffectManager.apply([], StatusEffectDefs.POISON, 5.0, 2, &"archer")
	check(bool(added.get("ok", false)), "poison should be added")
	var effects: Array = added.get("effects", []) as Array
	check(effects.size() == 1, "added effect count should be one")
	var ticked: Dictionary = StatusEffectManager.tick(effects, 1.25)
	var remaining: Array = ticked.get("effects", []) as Array
	check(absf(float((remaining[0] as Dictionary).get("duration", 0.0)) - 3.75) < 0.01, "tick should reduce duration")
	var expired: Dictionary = StatusEffectManager.tick(remaining, 4.0)
	check((expired.get("effects", []) as Array).is_empty(), "expired status should be removed")
	check((expired.get("expired", []) as Array).has(StatusEffectDefs.POISON), "expired list should include poison")


func test_stack_limit() -> void:
	var first: Dictionary = StatusEffectManager.apply([], StatusEffectDefs.POISON, 3.0, 7)
	var second: Dictionary = StatusEffectManager.apply(first.get("effects", []) as Array, StatusEffectDefs.POISON, 2.0, 5)
	var effect: Dictionary = ((second.get("effects", []) as Array)[0]) as Dictionary
	check(int(effect.get("stacks", 0)) == 9, "poison stacks should respect max_stacks")
	check(absf(float(effect.get("duration", 0.0)) - 3.0) < 0.01, "add policy should keep longer duration")


func test_refresh_policy() -> void:
	var first: Dictionary = StatusEffectManager.apply([], StatusEffectDefs.STUN, 1.0)
	var second: Dictionary = StatusEffectManager.apply(first.get("effects", []) as Array, StatusEffectDefs.STUN, 2.5)
	var effect: Dictionary = ((second.get("effects", []) as Array)[0]) as Dictionary
	check(int(effect.get("stacks", 0)) == 1, "refresh status should not add stacks")
	check(absf(float(effect.get("duration", 0.0)) - 2.5) < 0.01, "refresh status should keep longer duration")


func test_display_priority() -> void:
	var effects: Array = []
	effects = (StatusEffectManager.apply(effects, StatusEffectDefs.SLOW, 4.0).get("effects", []) as Array)
	effects = (StatusEffectManager.apply(effects, StatusEffectDefs.STUN, 2.0).get("effects", []) as Array)
	check(StringName((effects[0] as Dictionary).get("id", &"")) == StatusEffectDefs.STUN, "higher priority status should display first")


func test_renderer_layout() -> void:
	var models: Array[Dictionary] = StatusEffectManager.to_view_model(
		StatusEffectManager.apply([], StatusEffectDefs.BLEED, 0.9, 3).get("effects", []) as Array
	)
	var slots: Array[Dictionary] = StatusEffectRenderer.above_player_layout(Vector2(640.0, 360.0), models)
	check(slots.size() == 1, "renderer should create one slot")
	check(bool(slots[0].get("pulse", false)), "status below 1.5 seconds should pulse")
	check(str(slots[0].get("duration_text", "")) == "0.9", "duration text should keep one decimal below ten seconds")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
