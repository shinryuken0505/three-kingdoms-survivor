class_name Alpha20ChallengeTracker
extends RefCounted

static func start_chapter(chapter_id: String, director_profile: Dictionary) -> Dictionary:
	var objective: Dictionary = director_profile.get("objective", {})
	return {
		"chapter_id":chapter_id,
		"type":str(objective.get("type", "kills")),
		"target":float(objective.get("target", 45)),
		"label":str(objective.get("label", "擊破45名敵軍")),
		"reward_coins":int(objective.get("reward_coins", 28)),
		"progress":0.0,
		"completed":false,
		"just_completed":false,
	}

static func update(state: Dictionary, delta: float, gained_kills: int, hp_ratio: float, boss_active: bool) -> Dictionary:
	var out := state.duplicate(true)
	if bool(out.get("completed", false)): return out
	match str(out.get("type", "kills")):
		"kills": out["progress"] = float(out.get("progress", 0.0)) + float(gained_kills)
		"survive": out["progress"] = float(out.get("progress", 0.0)) + delta
		"healthy":
			if hp_ratio >= 0.35 or boss_active:
				out["progress"] = float(out.get("progress", 0.0)) + delta
	if float(out.get("progress", 0.0)) >= float(out.get("target", 1.0)):
		out["completed"] = true
		out["just_completed"] = true
	return out

static func progress_text(state: Dictionary) -> String:
	return "%s（%d/%d）" % [str(state.get("label", "章節挑戰")), int(state.get("progress", 0.0)), int(state.get("target", 1.0))]
