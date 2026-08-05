extends SceneTree

const Meta = preload("res://scripts/systems/meta/alpha22_meta_progression.gd")
const Codex = preload("res://scripts/systems/meta/alpha22_codex.gd")
const Achievements = preload("res://scripts/systems/meta/alpha22_achievements.gd")

func _init() -> void:
	var state: Dictionary = Meta.normalize({})
	state = Meta.award_for_run(state, {"kills":160, "bosses":2, "chapter":3, "cleared":true})
	assert(int(state.get("legacy_points", 0)) == 13)
	assert(int(state.get("lifetime_runs", 0)) == 1)
	var bought: Dictionary = Meta.purchase(state, "vitality")
	assert(int(bought.get("upgrades", {}).get("vitality", 0)) == 1)
	assert(Meta.modifier(bought, "vitality") > 0.0)

	var codex: Dictionary = Codex.normalize({})
	codex = Codex.discover(codex, "heroes", "guan_yu", {"name":"關羽"})
	codex = Codex.discover(codex, "bosses", "lu_bu")
	assert(Codex.is_discovered(codex, "heroes", "guan_yu"))
	var completion: Dictionary = Codex.completion(codex, {"heroes":8, "bosses":6, "relics":10, "endings":8})
	assert(int(completion.get("found", 0)) == 2)

	var achievement_state: Dictionary = Achievements.evaluate({}, {
		"runs":1,
		"kills":160,
		"bosses":2,
		"chapter":3,
		"codex_percent":10,
	})
	assert(bool(achievement_state.get("unlocked", {}).get("first_run", false)))
	assert(bool(achievement_state.get("unlocked", {}).get("hundred_kills", false)))
	assert(int(achievement_state.get("reward_total", 0)) == 5)
	print("ALPHA22_META_PROGRESSION_OK")
	quit(0)
