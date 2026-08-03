extends SceneTree

## 執行方式：
## godot --headless --path . --script res://tests/recruitment_roster_coordinator_test.gd

var failures: Array[String] = []


func _init() -> void:
	test_begin_and_cancel()
	test_place_in_reserve()
	test_full_active_replacement()
	test_full_reserve_replacement()
	if failures.is_empty():
		print("[PASS] recruitment_roster_coordinator_test")
		quit(0)
		return
	for failure in failures:
		push_error("[FAIL] %s" % failure)
	quit(1)


func test_begin_and_cancel() -> void:
	var result: Dictionary = RecruitmentRosterCoordinator.begin("zhaoyun", [], [], [])
	check(StringName(result["result"]) == RecruitmentRosterCoordinator.RESULT_OPEN_PICKER, "recruitment should open picker")
	check(bool((result["initialization"] as Dictionary).get("ensure_known", false)), "new hero should request initialization")
	var cancelled: Dictionary = RecruitmentRosterCoordinator.choose_target("zhaoyun", 3, [], [], [], 2, 2)
	check(StringName(cancelled["result"]) == RecruitmentRosterCoordinator.RESULT_CANCELLED, "cancel target should leave recruitment")


func test_place_in_reserve() -> void:
	var active: Array = ["liubei"]
	var reserve: Array = []
	var camp: Array = []
	var result: Dictionary = RecruitmentRosterCoordinator.choose_target(
		"zhaoyun", 1, active, reserve, camp, 2, 2
	)
	check(StringName(result["result"]) == RecruitmentRosterCoordinator.RESULT_PLACED, "free reserve slot should place hero")
	check(reserve == ["zhaoyun"], "recruited hero should enter reserve")
	check(not active.has("zhaoyun") and not camp.has("zhaoyun"), "recruited hero should exist in one roster only")


func test_full_active_replacement() -> void:
	var active: Array = ["liubei"]
	var reserve: Array = []
	var camp: Array = []
	var target: Dictionary = RecruitmentRosterCoordinator.choose_target(
		"lvbu", 0, active, reserve, camp, 1, 1
	)
	check(StringName(target["result"]) == RecruitmentRosterCoordinator.RESULT_OPEN_REPLACEMENT, "full active slot should request replacement")
	var replaced: Dictionary = RecruitmentRosterCoordinator.confirm_replacement(
		"lvbu", HeroRosterManager.ACTIVE, 0, active, reserve, camp, 1, 1
	)
	check(StringName(replaced["result"]) == RecruitmentRosterCoordinator.RESULT_REPLACED, "active replacement should complete")
	check(active == ["lvbu"] and reserve == ["liubei"], "outgoing active hero should use free reserve slot")


func test_full_reserve_replacement() -> void:
	var active: Array = []
	var reserve: Array = ["guanyu"]
	var camp: Array = []
	var target: Dictionary = RecruitmentRosterCoordinator.choose_target(
		"zhaoyun", 1, active, reserve, camp, 1, 1
	)
	check(StringName(target["result"]) == RecruitmentRosterCoordinator.RESULT_OPEN_REPLACEMENT, "full reserve slot should request replacement")
	var replaced: Dictionary = RecruitmentRosterCoordinator.confirm_replacement(
		"zhaoyun", HeroRosterManager.RESERVE, 0, active, reserve, camp, 1, 1
	)
	check(reserve == ["zhaoyun"] and camp == ["guanyu"], "outgoing reserve hero should return to camp")
	check(StringName(replaced.get("replaced_to", &"")) == HeroRosterManager.CAMP, "result should expose outgoing destination")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
