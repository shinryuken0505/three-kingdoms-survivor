extends SceneTree

const BuildRules = preload("res://scripts/systems/build/alpha19_build_rules.gd")
const HeroMastery = preload("res://scripts/systems/hero/alpha19_hero_mastery.gd")
const HistoryInfluence = preload("res://scripts/systems/world/alpha19_history_influence.gd")
const ChapterGimmicks = preload("res://scripts/systems/chapter/alpha19_chapter_gimmicks.gd")

func _init() -> void:
	var failures: Array[String] = []
	var melee := BuildRules.evaluate("swordsman", "blade", {"damage":3,"armor":2}, [])
	if str(melee.get("id", "")) != "melee": failures.append("blade build did not resolve to melee")
	if BuildRules.skill_allowed("blade", "poison", {}): failures.append("blade incorrectly allowed new poison branch")
	var mastery := HeroMastery.evaluate(["huangzhong","zhugeliang"], [], {"huangzhong":5,"zhugeliang":4})
	if float(mastery.get("damage_mult", 1.0)) <= 1.0: failures.append("mastery damage bonus missing")
	if not (mastery.get("awakened", []) as Array).has("huangzhong"): failures.append("level 5 awakening missing")
	var history := HistoryInfluence.evaluate({"protected_civilians":true}, {}, {"蜀":4.0}, 0.3)
	if float(history.get("merchant_time_mult", 1.0)) >= 1.0: failures.append("benevolent merchant support missing")
	var gimmick := ChapterGimmicks.for_chapter("yiling_battle")
	if not str(gimmick.get("label", "")).contains("烈火"): failures.append("Yiling gimmick missing")
	if failures.is_empty():
		print("ALPHA19_RULES_TEST_OK")
		quit(0)
	else:
		for failure in failures: push_error(failure)
		quit(1)
