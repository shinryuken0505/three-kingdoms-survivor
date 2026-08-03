extends SceneTree

## 執行方式：
## godot --headless --path . --script res://tests/hero_roster_main_adapter_test.gd

var failures: Array[String] = []


func _init() -> void:
	test_snapshot_contract()
	test_open_and_cancel_picker()
	test_move_and_save_flags()
	test_replacement_screen_command()
	if failures.is_empty():
		print("[PASS] hero_roster_main_adapter_test")
		quit(0)
		return
	for failure in failures:
		push_error("[FAIL] %s" % failure)
	quit(1)


func test_snapshot_contract() -> void:
	var state: Dictionary = HeroRosterMainState.snapshot(2, "intermission", "lvbu", 1, "reserve", true, 2, "guanyu")
	var validation: Dictionary = HeroRosterMainState.validate(state)
	check(bool(validation.get("ok", false)), "snapshot should contain every legacy key")
	check(HeroRosterMainState.changed_keys(state, state.duplicate(true)).is_empty(), "identical snapshots should report no changes")


func test_open_and_cancel_picker() -> void:
	var active: Array = ["liubei"]
	var reserve: Array = ["guanyu"]
	var camp: Array = []
	var state: Dictionary = HeroRosterLegacyBridge.default_legacy_state()
	var heroes := {
		"liubei": {"name": "劉備"},
		"guanyu": {"name": "關羽"},
	}
	var opened: Dictionary = HeroRosterMainAdapter.handle_action(
		InputRouter.ACTION_CONFIRM, state, ["liubei", "guanyu"], active, reserve, camp, 2, 2, heroes
	)
	check(StringName(opened["screen_command"]) == &"keep", "opening picker should keep hero config screen")
	state = opened["legacy_state"] as Dictionary
	check(bool(state.get("hero_position_picker_open", false)), "picker flag should open")
	var closed: Dictionary = HeroRosterMainAdapter.handle_action(
		InputRouter.ACTION_CANCEL, state, ["liubei", "guanyu"], active, reserve, camp, 2, 2, heroes
	)
	check(StringName(closed["sfx"]) == &"ui_cancel", "cancel should request cancel sound")
	check(not bool((closed["legacy_state"] as Dictionary).get("hero_position_picker_open", true)), "cancel should close picker")


func test_move_and_save_flags() -> void:
	var active: Array = ["liubei"]
	var reserve: Array = ["guanyu"]
	var camp: Array = []
	var state: Dictionary = HeroRosterLegacyBridge.default_legacy_state()
	state["hero_config_index"] = 1
	state["hero_position_picker_open"] = true
	state["hero_position_candidate"] = "guanyu"
	state["hero_position_index"] = 2
	var result: Dictionary = HeroRosterMainAdapter.handle_action(
		InputRouter.ACTION_CONFIRM,
		state,
		["liubei", "guanyu"],
		active,
		reserve,
		camp,
		2,
		2,
		{"liubei": {"name": "劉備"}, "guanyu": {"name": "關羽"}}
	)
	check(bool(result.get("roster_changed", false)), "moving to camp should change roster")
	check(bool(result.get("should_sync_roster", false)), "roster change should request sync")
	check(bool(result.get("should_save_checkpoint", false)), "roster change should expose checkpoint flag")
	check(camp.has("guanyu") and not reserve.has("guanyu"), "formal roster arrays should be updated")


func test_replacement_screen_command() -> void:
	var active: Array = ["liubei"]
	var reserve: Array = []
	var camp: Array = ["lvbu"]
	var state: Dictionary = HeroRosterLegacyBridge.default_legacy_state()
	state["hero_config_index"] = 1
	state["hero_position_picker_open"] = true
	state["hero_position_candidate"] = "lvbu"
	state["hero_position_index"] = 0
	var result: Dictionary = HeroRosterMainAdapter.handle_action(
		InputRouter.ACTION_CONFIRM,
		state,
		["liubei", "lvbu"],
		active,
		reserve,
		camp,
		1,
		1,
		{"liubei": {"name": "劉備"}, "lvbu": {"name": "呂布"}}
	)
	check(StringName(result["screen_command"]) == &"config_replace", "full active target should request replacement screen")
	check(StringName(result["sfx"]) == &"ui_confirm", "replacement screen should request confirm sound")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
