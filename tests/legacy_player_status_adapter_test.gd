extends SceneTree

## 執行方式：
## godot --headless --path . --script res://tests/legacy_player_status_adapter_test.gd

var failures: Array[String] = []


func _init() -> void:
	test_empty_player()
	test_legacy_fields()
	test_priority_order()
	if failures.is_empty():
		print("[PASS] legacy_player_status_adapter_test")
		quit(0)
		return
	for failure in failures:
		push_error("[FAIL] %s" % failure)
	quit(1)


func test_empty_player() -> void:
	var player: Dictionary = {}
	check(not LegacyPlayerStatusAdapter.has_visible_status(player), "empty player should have no visible status")
	check(LegacyPlayerStatusAdapter.view_models_from_player(player).is_empty(), "empty player should create no view model")


func test_legacy_fields() -> void:
	var player: Dictionary = {
		"move_slow": 2.2,
		"control_lock": 0.45,
		"vision_obscure": 3.0,
	}
	var models: Array[Dictionary] = LegacyPlayerStatusAdapter.view_models_from_player(player)
	check(models.size() == 3, "three active legacy fields should create three statuses")
	check(_contains(models, &"slow"), "move_slow should map to slow")
	check(_contains(models, &"stun"), "control_lock should map to stun")
	check(_contains(models, &"smoke"), "vision_obscure should map to smoke")


func test_priority_order() -> void:
	var player: Dictionary = {
		"move_slow": 2.2,
		"control_lock": 0.45,
		"vision_obscure": 3.0,
	}
	var models: Array[Dictionary] = LegacyPlayerStatusAdapter.view_models_from_player(player)
	check(StringName(models[0].get("id", &"")) == &"stun", "stun should be displayed first")
	check(float(models[0].get("duration", 0.0)) == 0.45, "adapter should preserve remaining duration")


func _contains(models: Array[Dictionary], status_id: StringName) -> bool:
	for model in models:
		if StringName(model.get("id", &"")) == status_id:
			return true
	return false


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
