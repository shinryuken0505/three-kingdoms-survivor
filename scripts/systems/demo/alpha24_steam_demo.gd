class_name Alpha24SteamDemo
extends RefCounted

const STORY_CHAPTER_LIMIT: int = 7

const TUTORIAL_STEPS := [
	{"id":"move","label":"使用方向鍵或 WASD 移動", "target":4.0},
	{"id":"attack","label":"靠近敵人並完成第一次攻擊", "target":1.0},
	{"id":"dash","label":"按下 Space 閃避一次", "target":1.0},
	{"id":"levelup","label":"拾取經驗並完成一次升級", "target":1.0},
	{"id":"hero","label":"遇見並招募一名名將", "target":1.0},
]

const QUALITY_PROFILES := {
	"high":{"enemy_cap":110,"particle_cap":190,"shot_cap":180,"damage_number_cap":72,"hazard_mult":1.0},
	"medium":{"enemy_cap":92,"particle_cap":145,"shot_cap":145,"damage_number_cap":56,"hazard_mult":1.08},
	"low":{"enemy_cap":72,"particle_cap":95,"shot_cap":110,"damage_number_cap":40,"hazard_mult":1.18},
}

static func new_state() -> Dictionary:
	return {
		"tutorial_index":0,
		"tutorial_done":false,
		"tutorial_progress":{},
		"quality":"high",
		"demo_completed":false,
		"feedback_prompted":false,
	}

static func normalize(value: Variant) -> Dictionary:
	var state := new_state()
	if value is Dictionary:
		for key in value:
			state[key] = value[key]
	return state

static func current_tutorial(state: Dictionary) -> Dictionary:
	if bool(state.get("tutorial_done", false)):
		return {}
	var index := int(state.get("tutorial_index", 0))
	if index < 0 or index >= TUTORIAL_STEPS.size():
		return {}
	return TUTORIAL_STEPS[index].duplicate(true)

static func advance_tutorial(state: Dictionary, event_id: String, amount: float = 1.0) -> Dictionary:
	var result := normalize(state)
	var step := current_tutorial(result)
	if step.is_empty() or str(step.get("id", "")) != event_id:
		return result
	var progress: Dictionary = result.get("tutorial_progress", {}).duplicate(true)
	var total := float(progress.get(event_id, 0.0)) + amount
	progress[event_id] = total
	result["tutorial_progress"] = progress
	if total >= float(step.get("target", 1.0)):
		result["tutorial_index"] = int(result.get("tutorial_index", 0)) + 1
		if int(result["tutorial_index"]) >= TUTORIAL_STEPS.size():
			result["tutorial_done"] = true
	return result

static func demo_chapter_allowed(mode: String, chapter_number: int) -> bool:
	return mode != "story" or chapter_number <= STORY_CHAPTER_LIMIT

static func completion_message(route_name: String, ending_title: String) -> String:
	var route := route_name if route_name != "" else "史勢未定"
	var ending := ending_title if ending_title != "" else "亂世未完"
	return "Steam Demo 完成｜路線：%s｜結局預兆：%s\n正式版將延續赤壁之後的歷史分歧、名將養成與更多結局。" % [route, ending]

static func quality_for_frame_time(frame_ms: float, current: String = "high") -> String:
	if frame_ms >= 28.0:
		return "low"
	if frame_ms >= 20.0:
		return "medium"
	if frame_ms <= 15.5 and current != "high":
		return "high"
	return current if QUALITY_PROFILES.has(current) else "high"

static func quality_profile(id: String) -> Dictionary:
	return QUALITY_PROFILES.get(id, QUALITY_PROFILES["high"]).duplicate(true)

static func release_readiness(version: String, has_save: bool, tutorial_done: bool, parse_errors: int, missing_assets: int) -> Dictionary:
	var checks := {
		"version": version.find("alpha.24") >= 0,
		"save": has_save,
		"tutorial": tutorial_done,
		"parse": parse_errors == 0,
		"assets": missing_assets == 0,
	}
	var ready := true
	for value in checks.values():
		ready = ready and bool(value)
	return {"ready":ready,"checks":checks}
