extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	var manager := EndingManager.new()
	var invalid := manager.validate_context({})
	check(not invalid.is_empty(), "empty ending context should be rejected")
	var context := {
		"run_id": "test-run",
		"mode": "story",
		"difficulty": "story",
		"chapter_id": "final",
		"chapter_title": "最終章",
		"boss_id": "final_boss",
		"identity": "swordsman",
		"stats": {},
		"equipment": {},
		"completed_chapters": ["a", "b"],
		"route_tags": {},
		"faction_momentum": {},
	}
	check(manager.validate_context(context).is_empty(), "valid ending context should pass")
	var snapshot := manager.build_snapshot(context)
	check(int(snapshot.get("snapshot_version", 0)) == EndingManager.SNAPSHOT_VERSION, "snapshot version should be current")
	check(str(snapshot.get("run_id", "")) == "test-run", "run id should persist")
	check(str(snapshot.get("boss_id", "")) == "final_boss", "boss id should persist")
	check((snapshot.get("completed_chapters", []) as Array).size() == 2, "completed chapters should persist")
	finish()


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func finish() -> void:
	if failures.is_empty():
		print("[PASS] ending_manager_test")
		quit(0)
		return
	for failure in failures:
		push_error("[FAIL] %s" % failure)
	quit(1)
