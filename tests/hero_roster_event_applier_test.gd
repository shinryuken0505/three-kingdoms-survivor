extends SceneTree

## 執行方式：
## godot --headless --path . --script res://tests/hero_roster_event_applier_test.gd

var failures: Array[String] = []


func _init() -> void:
	test_move_to_camp()
	test_replace_active_prefers_reserve()
	test_replace_reserve_to_camp()
	test_stale_replacement()
	if failures.is_empty():
		print("[PASS] hero_roster_event_applier_test")
		quit(0)
		return
	for failure in failures:
		push_error("[FAIL] %s" % failure)
	quit(1)


func test_move_to_camp() -> void:
	var active: Array = ["liubei"]
	var reserve: Array = ["guanyu"]
	var camp: Array = []
	var result := HeroRosterEventApplier.apply({
		"event": HeroRosterInputController.EVENT_MOVE_HERO,
		"hero_id": "guanyu",
		"from": HeroRosterManager.RESERVE,
		"to": HeroRosterManager.CAMP,
	}, active, reserve, camp, 2, 2)
	check(result["result"] == HeroRosterEventApplier.RESULT_ROSTER_CHANGED, "move should report roster change")
	check(camp == ["guanyu"], "hero should move to camp")
	check(reserve.is_empty(), "hero should leave reserve")


func test_replace_active_prefers_reserve() -> void:
	var active: Array = ["liubei", "guanyu"]
	var reserve: Array = []
	var camp: Array = ["lvbu"]
	var result := HeroRosterEventApplier.apply({
		"event": HeroRosterInputController.EVENT_CONFIRM_REPLACEMENT,
		"hero_id": "lvbu",
		"replaced_id": "guanyu",
		"mode": HeroRosterManager.ACTIVE,
		"index": 1,
	}, active, reserve, camp, 2, 2)
	check(active == ["liubei", "lvbu"], "incoming hero should occupy active slot")
	check(reserve == ["guanyu"], "outgoing active hero should use free reserve slot")
	check(not camp.has("lvbu"), "incoming hero should leave camp")
	check(result["replaced_to"] == HeroRosterManager.RESERVE, "result should report reserve destination")


func test_replace_reserve_to_camp() -> void:
	var active: Array = ["liubei"]
	var reserve: Array = ["guanyu"]
	var camp: Array = ["zhangfei"]
	var result := HeroRosterEventApplier.apply({
		"event": HeroRosterInputController.EVENT_CONFIRM_REPLACEMENT,
		"hero_id": "zhangfei",
		"replaced_id": "guanyu",
		"mode": HeroRosterManager.RESERVE,
		"index": 0,
	}, active, reserve, camp, 2, 1)
	check(reserve == ["zhangfei"], "incoming hero should occupy reserve slot")
	check(camp == ["guanyu"], "outgoing reserve hero should move to camp")
	check(result["replaced_to"] == HeroRosterManager.CAMP, "result should report camp destination")


func test_stale_replacement() -> void:
	var active: Array = ["liubei"]
	var reserve: Array = []
	var camp: Array = ["lvbu"]
	var result := HeroRosterEventApplier.apply({
		"event": HeroRosterInputController.EVENT_CONFIRM_REPLACEMENT,
		"hero_id": "lvbu",
		"replaced_id": "guanyu",
		"mode": HeroRosterManager.ACTIVE,
		"index": 0,
	}, active, reserve, camp, 1, 1)
	check(result["result"] == HeroRosterEventApplier.RESULT_ERROR, "stale selection should be rejected")
	check(active == ["liubei"], "stale selection must not mutate roster")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
