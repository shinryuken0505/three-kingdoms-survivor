class_name Alpha20DemoProfile
extends RefCounted

const DEMO_CHAPTER_LIMIT := 7

static func new_run(mode: String, identity_id: String) -> Dictionary:
	return {"version":"alpha.20","mode":mode,"identity":identity_id,"chapters_seen":[],"tutorial_complete":false,"demo_chapter_limit":DEMO_CHAPTER_LIMIT}

static func chapter_available(chapter_index: int, mode: String) -> bool:
	if mode != "story": return true
	return chapter_index < DEMO_CHAPTER_LIMIT

static func summary(demo_state: Dictionary, challenge_state: Dictionary, director_state: Dictionary) -> String:
	var completion := "完成" if bool(challenge_state.get("completed", false)) else "進行中"
	return "Alpha.20｜%s｜章節挑戰%s" % [str(director_state.get("title", "亂世交鋒")), completion]
