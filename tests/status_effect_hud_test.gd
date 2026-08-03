extends SceneTree

## 執行方式：
## godot --headless --path . --script res://tests/status_effect_hud_test.gd

var failures: Array[String] = []


func _init() -> void:
	test_empty_player()
	test_legacy_layout_and_priority()
	test_hover_lookup()
	test_accessibility_summary()
	if failures.is_empty():
		print("[PASS] status_effect_hud_test")
		quit(0)
		return
	for failure in failures:
		push_error("[FAIL] %s" % failure)
	quit(1)


func test_empty_player() -> void:
	var plan: Dictionary = StatusEffectHud.build({}, Vector2(640.0, 360.0))
	check((plan.get("items", []) as Array).is_empty(), "empty player should produce no status items")
	check((plan.get("above_player", []) as Array).is_empty(), "empty player should produce no player slots")
	check((plan.get("hud", []) as Array).is_empty(), "empty player should produce no HUD slots")


func test_legacy_layout_and_priority() -> void:
	var player := {
		"move_slow": 4.0,
		"control_lock": 1.2,
		"vision_obscure": 3.0,
		"bleeding": 6.0,
		"bleed_stacks": 3,
	}
	var plan: Dictionary = StatusEffectHud.build(player, Vector2(640.0, 360.0))
	var items: Array = plan.get("items", []) as Array
	var above: Array = plan.get("above_player", []) as Array
	var hud: Array = plan.get("hud", []) as Array
	check(items.size() == 4, "four active legacy statuses should be presented")
	check(above.size() == StatusEffectRenderer.MAX_ABOVE_PLAYER, "above-player layout should obey display limit")
	check(hud.size() == 4, "HUD should include every active status under HUD limit")
	check(StringName((items[0] as Dictionary).get("id", &"")) == StatusEffectDefs.STUN, "stun should be first by priority")
	check(int((items[1] as Dictionary).get("stacks", 1)) == 3, "bleed stacks should be preserved")


func test_hover_lookup() -> void:
	var plan: Dictionary = StatusEffectHud.build({"move_slow": 4.0}, Vector2(640.0, 360.0))
	var slots: Array = plan.get("hud", []) as Array
	check(not slots.is_empty(), "hover test requires one HUD slot")
	if slots.is_empty():
		return
	var rect: Rect2 = (slots[0] as Dictionary).get("rect", Rect2()) as Rect2
	var item: Dictionary = StatusEffectHud.hovered_item(plan, rect.get_center())
	check(StringName(item.get("id", &"")) == StatusEffectDefs.SLOW, "hover should return matching presented item")
	check(StatusEffectHud.hovered_item(plan, Vector2.ZERO).is_empty(), "outside point should not resolve an item")


func test_accessibility_summary() -> void:
	var plan: Dictionary = StatusEffectHud.build(
		{"control_lock": 1.2, "bleeding": 5.0, "bleed_stacks": 2},
		Vector2(640.0, 360.0)
	)
	var summary: String = str(plan.get("summary", ""))
	check(not summary.is_empty(), "active statuses should produce accessibility summary")
	check(summary.contains("2層"), "summary should announce stack count")
	check(summary.contains("秒"), "summary should announce duration")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
