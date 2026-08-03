extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	test_state_keys()
	test_fallback_message()
	test_missing_hero_fallback()
	if failures.is_empty():
		print("[PASS] hero_roster_feedback_presenter_test")
		quit(0)
		return
	for failure in failures:
		push_error("[FAIL] %s" % failure)
	quit(1)


func test_state_keys() -> void:
	check(HeroRosterFeedbackPresenter.state_key(HeroRosterManager.ACTIVE) == &"ui.hero_roster.state.active", "active state key mismatch")
	check(HeroRosterFeedbackPresenter.state_key(HeroRosterManager.RESERVE) == &"ui.hero_roster.state.reserve", "reserve state key mismatch")
	check(HeroRosterFeedbackPresenter.state_key(HeroRosterManager.CAMP) == &"ui.hero_roster.state.camp", "camp state key mismatch")


func test_fallback_message() -> void:
	var heroes := {
		"lvbu": {"name": "呂布"},
		"liubei": {"name": "劉備"},
	}
	var feedback := {
		"message_id": &"message.hero_roster.replaced",
		"params": {
			"hero_id": "lvbu",
			"to": HeroRosterManager.ACTIVE,
			"replaced_id": "liubei",
			"replaced_to": HeroRosterManager.RESERVE,
		},
	}
	var text: String = HeroRosterFeedbackPresenter.message(feedback, heroes)
	check(text.contains("呂布"), "message should contain incoming hero name")
	check(text.contains("劉備"), "message should contain replaced hero name")
	check(not text.contains("{hero_name}"), "message placeholders should be resolved")


func test_missing_hero_fallback() -> void:
	check(HeroRosterFeedbackPresenter.hero_name("unknown_hero", {}) == "unknown_hero", "unknown hero should fall back to stable id")
	check(HeroRosterFeedbackPresenter.hero_name("", {}) == "—", "empty hero should use readable placeholder")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
