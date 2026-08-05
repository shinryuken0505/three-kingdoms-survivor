from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAIN = ROOT / "scripts/main.gd"
PROJECT = ROOT / "project.godot"


def replace_once(text: str, old: str, new: str) -> str:
    if new in text:
        return text
    if old not in text:
        raise SystemExit(f"missing patch anchor: {old[:100]}")
    return text.replace(old, new, 1)


def patch_main() -> None:
    text = MAIN.read_text(encoding="utf-8")
    text = text.replace('const GAME_VERSION: String = "V2.0.0-alpha.21"', 'const GAME_VERSION: String = "V2.0.0-alpha.22"')
    text = text.replace('V2.0.0 Alpha.21・武魂覺醒', 'V2.0.0 Alpha.22・亂世傳承')

    preload_anchor = 'const Alpha21BossPatterns = preload("res://scripts/systems/boss/alpha21_boss_patterns.gd")\n'
    preload_block = preload_anchor + (
        'const Alpha22MetaProgression = preload("res://scripts/systems/meta/alpha22_meta_progression.gd")\n'
        'const Alpha22Codex = preload("res://scripts/systems/meta/alpha22_codex.gd")\n'
        'const Alpha22Achievements = preload("res://scripts/systems/meta/alpha22_achievements.gd")\n'
    )
    if 'Alpha22MetaProgression' not in text:
        text = replace_once(text, preload_anchor, preload_block)

    var_anchor = 'var alpha21_boss_phase: int = 1\n'
    var_block = var_anchor + (
        'var alpha22_meta_state: Dictionary = {}\n'
        'var alpha22_codex_state: Dictionary = {}\n'
        'var alpha22_achievement_state: Dictionary = {}\n'
        'var alpha22_last_rewards: Array[String] = []\n'
    )
    if 'var alpha22_meta_state' not in text:
        text = replace_once(text, var_anchor, var_block)

    save_anchor = '\t"latest_ending": {},\n'
    save_block = save_anchor + (
        '\t"meta_progression": {},\n'
        '\t"codex": {},\n'
        '\t"achievements": {},\n'
    )
    if '"meta_progression"' not in text:
        text = replace_once(text, save_anchor, save_block)

    init_anchor = '\talpha21_boss_phase = 1\n'
    if 'alpha22_initialize_profile()' not in text:
        text = replace_once(text, init_anchor, init_anchor + '\talpha22_initialize_profile()\n')

    damage_anchor = 'func alpha21_identity_damage_multiplier() -> float:\n\treturn Alpha21CombatIdentity.base_damage_multiplier(chosen_identity)\n'
    damage_block = 'func alpha21_identity_damage_multiplier() -> float:\n\treturn Alpha21CombatIdentity.base_damage_multiplier(chosen_identity) * alpha22_legacy_damage_multiplier()\n'
    if 'alpha22_legacy_damage_multiplier()' not in text:
        text = replace_once(text, damage_anchor, damage_block)

    if 'func alpha22_initialize_profile()' not in text:
        text += r'''

# Alpha.22：局外傳承、圖鑑、成就與永久解鎖。
func alpha22_initialize_profile() -> void:
	alpha22_meta_state = Alpha22MetaProgression.normalize(save_data.get("meta_progression", {}))
	alpha22_codex_state = Alpha22Codex.normalize(save_data.get("codex", {}))
	var achievements_raw: Variant = save_data.get("achievements", {})
	alpha22_achievement_state = achievements_raw.duplicate(true) if achievements_raw is Dictionary else {}
	alpha22_last_rewards.clear()
	alpha22_apply_starting_bonuses()


func alpha22_apply_starting_bonuses() -> void:
	if player.is_empty():
		return
	var vitality: float = Alpha22MetaProgression.modifier(alpha22_meta_state, "vitality")
	var fortune: float = Alpha22MetaProgression.modifier(alpha22_meta_state, "fortune")
	var max_hp: float = float(player.get("max_hp", 1.0)) * (1.0 + vitality)
	player["max_hp"] = max_hp
	player["hp"] = min(max_hp, float(player.get("hp", max_hp)) * (1.0 + vitality))
	player["alpha22_coin_bonus"] = fortune
	player["alpha22_insight_bonus"] = Alpha22MetaProgression.modifier(alpha22_meta_state, "insight")


func alpha22_legacy_damage_multiplier() -> float:
	return 1.0 + Alpha22MetaProgression.modifier(alpha22_meta_state, "resolve")


func alpha22_record_run_result(result: Dictionary) -> Dictionary:
	alpha22_meta_state = Alpha22MetaProgression.award_for_run(alpha22_meta_state, result)
	var completion: Dictionary = Alpha22Codex.completion(alpha22_codex_state, alpha22_codex_totals())
	var metrics: Dictionary = {
		"runs": int(alpha22_meta_state.get("lifetime_runs", 0)),
		"kills": int(alpha22_meta_state.get("lifetime_kills", 0)),
		"bosses": int(alpha22_meta_state.get("lifetime_bosses", 0)),
		"chapter": int(alpha22_meta_state.get("best_chapter", 0)),
		"codex_percent": int(round(float(completion.get("ratio", 0.0)) * 100.0)),
	}
	alpha22_achievement_state = Alpha22Achievements.evaluate(alpha22_achievement_state, metrics)
	var reward: int = int(alpha22_achievement_state.get("reward_total", 0))
	if reward > 0:
		alpha22_meta_state["legacy_points"] = int(alpha22_meta_state.get("legacy_points", 0)) + reward
	alpha22_last_rewards = alpha22_achievement_state.get("newly_unlocked", []).duplicate()
	alpha22_achievement_state["reward_total"] = 0
	alpha22_achievement_state["newly_unlocked"] = []
	alpha22_commit_profile()
	return {"legacy_earned":int(alpha22_meta_state.get("last_earned", 0)), "achievements":alpha22_last_rewards.duplicate()}


func alpha22_discover(category: String, id: String, details: Dictionary = {}) -> void:
	alpha22_codex_state = Alpha22Codex.discover(alpha22_codex_state, category, id, details)
	alpha22_commit_profile()


func alpha22_purchase_upgrade(id: String) -> bool:
	var before: int = int(alpha22_meta_state.get("upgrades", {}).get(id, 0))
	alpha22_meta_state = Alpha22MetaProgression.purchase(alpha22_meta_state, id)
	var after: int = int(alpha22_meta_state.get("upgrades", {}).get(id, 0))
	if after > before:
		alpha22_commit_profile()
		return true
	return false


func alpha22_commit_profile() -> void:
	save_data["meta_progression"] = alpha22_meta_state.duplicate(true)
	save_data["codex"] = alpha22_codex_state.duplicate(true)
	save_data["achievements"] = alpha22_achievement_state.duplicate(true)


func alpha22_codex_totals() -> Dictionary:
	return {
		"heroes": heroes.size(),
		"bosses": 6,
		"relics": relic_defs.size(),
		"endings": 8,
	}


func alpha22_menu_entries() -> Array[String]:
	return ["傳承", "圖鑑", "成就"]


func alpha22_summary() -> String:
	var completion: Dictionary = Alpha22Codex.completion(alpha22_codex_state, alpha22_codex_totals())
	return "傳承點%d｜圖鑑%d/%d｜成就%d/%d" % [
		int(alpha22_meta_state.get("legacy_points", 0)),
		int(completion.get("found", 0)),
		int(completion.get("total", 0)),
		alpha22_achievement_state.get("unlocked", {}).size(),
		Alpha22Achievements.DEFINITIONS.size(),
	]
'''

    MAIN.write_text(text, encoding="utf-8")


def patch_project() -> None:
    text = PROJECT.read_text(encoding="utf-8")
    text = text.replace('三國人生錄：亂世倖存 V2.0.0-alpha.21', '三國人生錄：亂世倖存 V2.0.0-alpha.22')
    PROJECT.write_text(text, encoding="utf-8")


if __name__ == "__main__":
    patch_main()
    patch_project()
    print("Alpha.22 meta progression patch applied")
