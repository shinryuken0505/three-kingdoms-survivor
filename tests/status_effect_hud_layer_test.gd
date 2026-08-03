extends SceneTree

## 執行方式：
## godot --headless --path . --script res://tests/status_effect_hud_layer_test.gd

var failures: Array[String] = []


func _init() -> void:
	test_scene_has_hud_layer()
	test_layer_script_contract()
	if failures.is_empty():
		print("[PASS] status_effect_hud_layer_test")
		quit(0)
		return
	for failure in failures:
		push_error("[FAIL] %s" % failure)
	quit(1)


func test_scene_has_hud_layer() -> void:
	var scene_text: String = FileAccess.get_file_as_string("res://main.tscn")
	check(scene_text.contains("StatusEffectHudLayer"), "main.tscn should contain status HUD child")
	check(scene_text.contains("status_effect_hud_layer.gd"), "main.tscn should attach HUD layer script")


func test_layer_script_contract() -> void:
	var script_text: String = FileAccess.get_file_as_string("res://scripts/ui/status_effect_hud_layer.gd")
	check(script_text.contains("StatusEffectHud.draw("), "layer should draw through StatusEffectHud")
	check(script_text.contains("world_to_screen"), "layer should use main world-to-screen conversion")
	check(script_text.contains("StatusEffectHud.hovered_item"), "layer should expose hover tooltip")
	check(script_text.contains("LEGACY_STATUS_MASK"), "layer should cover the legacy single-status label")
	check(not script_text.contains("player[\"move_slow\"] ="), "layer must not mutate battle status")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
