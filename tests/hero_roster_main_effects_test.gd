extends SceneTree

## 執行方式：
## godot --headless --path . --script res://tests/hero_roster_main_effects_test.gd

var failures: Array[String] = []


func _init() -> void:
	test_active_move_effects()
	test_support_move_effects()
	test_replacement_effects()
	test_intermission_save_policy()
	if failures.is_empty():
		print("[PASS] hero_roster_main_effects_test")
		quit(0)
		return
	for failure in failures:
		push_error("[FAIL] %s" % failure)
	quit(1)


func test_active_move_effects() -> void:
	var plan: Dictionary = HeroRosterMainEffects.build({
		"handled": true,
		"roster_changed": true,
		"screen_command": &"hero_config",
		"sfx": &"ui_confirm",
		"message": "moved",
		"legacy_state": {"hero_config_index": 0},
		"apply_result": {"hero_id": "guanyu", "to": HeroRosterManager.ACTIVE},
	}, &"camp")
	check((plan["cooldown_start"] as Array).has("guanyu"), "active move should start incoming cooldown")
	check((plan["cooldown_remove"] as Array).is_empty(), "active move should not remove incoming cooldown")
	check(not bool(plan["save_checkpoint"]), "camp move should not request intermission save")


func test_support_move_effects() -> void:
	var plan: Dictionary = HeroRosterMainEffects.build({
		"handled": true,
		"roster_changed": true,
		"screen_command": &"hero_config",
		"legacy_state": {},
		"apply_result": {"hero_id": "guanyu", "to": HeroRosterManager.RESERVE},
	}, &"merchant")
	check((plan["cooldown_remove"] as Array).has("guanyu"), "reserve move should remove active cooldown")
	check((plan["cooldown_start"] as Array).is_empty(), "reserve move should not start cooldown")


func test_replacement_effects() -> void:
	var plan: Dictionary = HeroRosterMainEffects.build({
		"handled": true,
		"roster_changed": true,
		"screen_command": &"hero_config",
		"legacy_state": {},
		"apply_result": {
			"hero_id": "lvbu",
			"replaced_id": "liubei",
			"to": HeroRosterManager.ACTIVE,
		},
	}, &"intermission")
	check((plan["cooldown_start"] as Array).has("lvbu"), "active replacement should start incoming cooldown")
	check((plan["cooldown_remove"] as Array).has("liubei"), "active replacement should remove outgoing cooldown")
	check(bool(plan["sync_roster"]), "replacement should sync roster")


func test_intermission_save_policy() -> void:
	var changed: Dictionary = HeroRosterMainEffects.build({
		"handled": true,
		"roster_changed": true,
		"screen_command": &"keep",
		"legacy_state": {},
		"apply_result": {},
	}, &"intermission")
	var cursor_only: Dictionary = HeroRosterMainEffects.build({
		"handled": true,
		"roster_changed": false,
		"screen_command": &"keep",
		"legacy_state": {},
		"apply_result": {},
	}, &"intermission")
	check(bool(changed["save_checkpoint"]), "changed intermission roster should save")
	check(not bool(cursor_only["save_checkpoint"]), "cursor movement should not save")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
