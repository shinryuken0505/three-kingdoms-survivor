class_name Alpha22MetaProgression
extends RefCounted

const DEFAULT_STATE := {
	"legacy_points": 0,
	"lifetime_runs": 0,
	"lifetime_kills": 0,
	"lifetime_bosses": 0,
	"best_chapter": 0,
	"unlocks": {},
	"upgrades": {},
}

const UPGRADES := {
	"vitality": {"label":"百戰餘生", "max_level":5, "base_cost":2, "effect_per_level":0.03},
	"fortune": {"label":"亂世積財", "max_level":5, "base_cost":2, "effect_per_level":0.04},
	"insight": {"label":"識人之明", "max_level":4, "base_cost":3, "effect_per_level":0.05},
	"resolve": {"label":"不屈戰意", "max_level":4, "base_cost":3, "effect_per_level":0.025},
}

static func normalize(raw: Dictionary) -> Dictionary:
	var state: Dictionary = DEFAULT_STATE.duplicate(true)
	for key in raw.keys():
		state[key] = raw[key]
	if not state.get("unlocks", {}) is Dictionary:
		state["unlocks"] = {}
	if not state.get("upgrades", {}) is Dictionary:
		state["upgrades"] = {}
	return state

static func award_for_run(state: Dictionary, result: Dictionary) -> Dictionary:
	var next: Dictionary = normalize(state)
	var kills: int = max(0, int(result.get("kills", 0)))
	var bosses: int = max(0, int(result.get("bosses", 0)))
	var chapter: int = max(0, int(result.get("chapter", 0)))
	var cleared: bool = bool(result.get("cleared", false))
	var earned: int = 1 + int(kills / 80) + bosses * 2 + chapter
	if cleared:
		earned += 3
	next["legacy_points"] = int(next.get("legacy_points", 0)) + earned
	next["lifetime_runs"] = int(next.get("lifetime_runs", 0)) + 1
	next["lifetime_kills"] = int(next.get("lifetime_kills", 0)) + kills
	next["lifetime_bosses"] = int(next.get("lifetime_bosses", 0)) + bosses
	next["best_chapter"] = max(int(next.get("best_chapter", 0)), chapter)
	next["last_earned"] = earned
	return next

static func upgrade_cost(id: String, current_level: int) -> int:
	var def: Dictionary = UPGRADES.get(id, {})
	if def.is_empty():
		return 999
	return int(def.get("base_cost", 2)) + current_level * 2

static func purchase(state: Dictionary, id: String) -> Dictionary:
	var next: Dictionary = normalize(state)
	var def: Dictionary = UPGRADES.get(id, {})
	if def.is_empty():
		return next
	var upgrades: Dictionary = next.get("upgrades", {})
	var level: int = int(upgrades.get(id, 0))
	if level >= int(def.get("max_level", 1)):
		return next
	var cost: int = upgrade_cost(id, level)
	if int(next.get("legacy_points", 0)) < cost:
		return next
	next["legacy_points"] = int(next.get("legacy_points", 0)) - cost
	upgrades[id] = level + 1
	next["upgrades"] = upgrades
	return next

static func modifier(state: Dictionary, id: String) -> float:
	var normalized: Dictionary = normalize(state)
	var level: int = int(normalized.get("upgrades", {}).get(id, 0))
	return float(UPGRADES.get(id, {}).get("effect_per_level", 0.0)) * level
