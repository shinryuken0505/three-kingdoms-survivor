extends SceneTree

## 執行方式：
## godot --headless --path . --script res://tests/hero_roster_flow_coordinator_test.gd

var failures: Array[String] = []


func _init() -> void:
	test_legacy_roundtrip()
	test_move_to_camp_flow()
	test_active_replacement_flow()
	test_cancel_priority()
	test_feedback_contract()
	if failures.is_empty():
		print("[PASS] hero_roster_flow_coordinator_test")
		quit(0)
		return
	for failure in failures:
		push_error("[FAIL] %s" % failure)
	quit(1)


func test_legacy_roundtrip() -> void:
	var legacy := {
		"hero_config_index": 2,
		"hero_config_origin": "intermission",
		"config_candidate": "lvbu",
		"config_replace_index": 1,
		"config_replace_mode": "reserve",
		"hero_position_picker_open": true,
		"hero_position_index": 2,
		"hero_position_candidate": "guanyu",
	}
	var session: HeroRosterSession = HeroRosterLegacyBridge.session_from_legacy(legacy)
	var restored: Dictionary = HeroRosterLegacyBridge.legacy_from_session(session)
	check(restored == legacy, "legacy state should roundtrip without field loss")


func test_move_to_camp_flow() -> void:
	var active: Array = ["liubei"]
	var reserve: Array = ["guanyu"]
	var camp: Array = []
	var legacy: Dictionary = HeroRosterLegacyBridge.default_legacy_state()
	legacy["hero_config_index"] = 1
	var order: Array[String] = ["liubei", "guanyu"]
	var open_result: Dictionary = HeroRosterFlowCoordinator.handle_action(
		InputRouter.ACTION_CONFIRM, legacy, order, active, reserve, camp, 2, 2
	)
	legacy = open_result["legacy_state"] as Dictionary
	check(StringName(open_result["ui_command"]) == HeroRosterFlowCoordinator.UI_OPEN_PICKER, "confirm should open position picker")
	# 後備目前索引為1，往下移到營地索引2。
	var move_cursor: Dictionary = HeroRosterFlowCoordinator.handle_action(
		InputRouter.ACTION_DOWN, legacy, order, active, reserve, camp, 2, 2
	)
	legacy = move_cursor["legacy_state"] as Dictionary
	var confirm: Dictionary = HeroRosterFlowCoordinator.handle_action(
		InputRouter.ACTION_CONFIRM, legacy, order, active, reserve, camp, 2, 2
	)
	check(bool(confirm.get("roster_changed", false)), "camp confirmation should change roster")
	check(camp.has("guanyu") and not reserve.has("guanyu"), "hero should move from reserve to camp")
	check(not bool((confirm["legacy_state"] as Dictionary).get("hero_position_picker_open", true)), "picker should close after move")


func test_active_replacement_flow() -> void:
	var active: Array = ["liubei"]
	var reserve: Array = []
	var camp: Array = ["lvbu"]
	var order: Array[String] = ["liubei", "lvbu"]
	var legacy: Dictionary = HeroRosterLegacyBridge.default_legacy_state()
	legacy["hero_config_index"] = 1
	var open_picker: Dictionary = HeroRosterFlowCoordinator.handle_action(
		InputRouter.ACTION_CONFIRM, legacy, order, active, reserve, camp, 1, 1
	)
	legacy = open_picker["legacy_state"] as Dictionary
	# 營地索引2，向上兩次到主戰索引0。
	for _step in range(2):
		var moved: Dictionary = HeroRosterFlowCoordinator.handle_action(
			InputRouter.ACTION_UP, legacy, order, active, reserve, camp, 1, 1
		)
		legacy = moved["legacy_state"] as Dictionary
	var open_replace: Dictionary = HeroRosterFlowCoordinator.handle_action(
		InputRouter.ACTION_CONFIRM, legacy, order, active, reserve, camp, 1, 1
	)
	legacy = open_replace["legacy_state"] as Dictionary
	check(StringName(open_replace["ui_command"]) == HeroRosterFlowCoordinator.UI_OPEN_REPLACEMENT, "full active slot should open replacement")
	var replaced: Dictionary = HeroRosterFlowCoordinator.handle_action(
		InputRouter.ACTION_CONFIRM, legacy, order, active, reserve, camp, 1, 1
	)
	check(active == ["lvbu"], "incoming hero should occupy active slot")
	check(reserve == ["liubei"], "outgoing active hero should use free reserve slot")
	check(camp.is_empty(), "incoming hero should be removed from camp")
	check(bool(replaced.get("roster_changed", false)), "replacement should report roster change")


func test_cancel_priority() -> void:
	var active: Array = ["liubei"]
	var reserve: Array = []
	var camp: Array = ["lvbu"]
	var order: Array[String] = ["liubei", "lvbu"]
	var legacy: Dictionary = HeroRosterLegacyBridge.default_legacy_state()
	legacy["hero_position_picker_open"] = true
	legacy["hero_position_candidate"] = "lvbu"
	var close_picker: Dictionary = HeroRosterFlowCoordinator.handle_action(
		InputRouter.ACTION_CANCEL, legacy, order, active, reserve, camp, 1, 1
	)
	check(StringName(close_picker["ui_command"]) == HeroRosterFlowCoordinator.UI_CLOSE_PICKER, "cancel should close picker before screen")
	legacy = close_picker["legacy_state"] as Dictionary
	var close_screen: Dictionary = HeroRosterFlowCoordinator.handle_action(
		InputRouter.ACTION_CANCEL, legacy, order, active, reserve, camp, 1, 1
	)
	check(StringName(close_screen["ui_command"]) == HeroRosterFlowCoordinator.UI_CLOSE_SCREEN, "second cancel should close main screen")


func test_feedback_contract() -> void:
	var feedback: Dictionary = HeroRosterFeedback.from_flow({
		"ui_command": HeroRosterFlowCoordinator.UI_ROSTER_CHANGED,
		"input_event": {},
		"apply_result": {
			"hero_id": "lvbu",
			"to": HeroRosterManager.ACTIVE,
			"replaced_id": "liubei",
			"replaced_to": HeroRosterManager.RESERVE,
		},
	})
	check(StringName(feedback["sfx"]) == HeroRosterFeedback.SFX_CONFIRM, "roster change should request confirm sound")
	check(StringName(feedback["message_id"]) == &"message.hero_roster.replaced", "replacement should use stable message id")
	check((feedback["params"] as Dictionary).get("replaced_id", "") == "liubei", "feedback should preserve replaced hero id")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
