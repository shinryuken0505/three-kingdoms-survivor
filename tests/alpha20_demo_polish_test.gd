extends SceneTree

func _init() -> void:
	var profile := Alpha20DemoDirector.profile("red_cliffs", "story")
	assert(str(profile.get("title", "")) == "赤壁火海")
	assert((profile.get("hazards", []) as Array).size() >= 2)
	var challenge := Alpha20ChallengeTracker.start_chapter("red_cliffs", profile)
	challenge = Alpha20ChallengeTracker.update(challenge, 0.25, 95, 1.0, false)
	assert(bool(challenge.get("completed", false)))
	var low_hp := Alpha20DemoDirector.adaptive_pressure(profile, 0.20, 0, 90.0)
	assert(float(low_hp.get("player_damage_mult", 1.0)) > 1.0)
	assert(Alpha20DemoProfile.chapter_available(5, "story"))
	assert(not Alpha20DemoProfile.chapter_available(8, "story"))
	print("ALPHA20_DEMO_POLISH_TEST_OK")
	quit(0)
