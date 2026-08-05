class_name Alpha22Achievements
extends RefCounted

const DEFINITIONS := {
	"first_run": {"label":"亂世初行", "metric":"runs", "target":1, "reward":2},
	"veteran": {"label":"百戰餘生", "metric":"runs", "target":10, "reward":5},
	"hundred_kills": {"label":"以一當百", "metric":"kills", "target":100, "reward":3},
	"thousand_kills": {"label":"千軍辟易", "metric":"kills", "target":1000, "reward":8},
	"boss_hunter": {"label":"名將剋星", "metric":"bosses", "target":10, "reward":6},
	"chapter_five": {"label":"官渡留名", "metric":"chapter", "target":5, "reward":5},
	"codex_25": {"label":"博聞強記", "metric":"codex_percent", "target":25, "reward":4},
	"codex_50": {"label":"通曉群雄", "metric":"codex_percent", "target":50, "reward":7},
}

static func evaluate(raw: Dictionary, metrics: Dictionary) -> Dictionary:
	var state: Dictionary = raw.duplicate(true)
	var unlocked: Dictionary = state.get("unlocked", {}) if state.get("unlocked", {}) is Dictionary else {}
	var newly_unlocked: Array[String] = []
	var reward_total: int = 0
	for id in DEFINITIONS.keys():
		if bool(unlocked.get(id, false)):
			continue
		var def: Dictionary = DEFINITIONS[id]
		var value: int = int(metrics.get(str(def.get("metric", "")), 0))
		if value >= int(def.get("target", 1)):
			unlocked[id] = true
			newly_unlocked.append(id)
			reward_total += int(def.get("reward", 0))
	state["unlocked"] = unlocked
	state["newly_unlocked"] = newly_unlocked
	state["reward_total"] = reward_total
	return state

static func progress(id: String, metrics: Dictionary) -> Dictionary:
	var def: Dictionary = DEFINITIONS.get(id, {})
	if def.is_empty():
		return {"value":0, "target":1, "ratio":0.0}
	var value: int = int(metrics.get(str(def.get("metric", "")), 0))
	var target: int = max(1, int(def.get("target", 1)))
	return {"value":value, "target":target, "ratio":clamp(float(value) / float(target), 0.0, 1.0)}
