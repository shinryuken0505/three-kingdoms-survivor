from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAIN = ROOT / "scripts/main.gd"
PROJECT = ROOT / "project.godot"


def replace_once(text: str, old: str, new: str) -> str:
    if new in text:
        return text
    if old not in text:
        raise SystemExit(f"missing patch anchor: {old[:80]}")
    return text.replace(old, new, 1)


def patch_main() -> None:
    text = MAIN.read_text(encoding="utf-8")
    text = text.replace('const GAME_VERSION: String = "V2.0.0-alpha.20"', 'const GAME_VERSION: String = "V2.0.0-alpha.21"')
    text = text.replace('V2.0.0 Alpha.20・戰場磨礪', 'V2.0.0 Alpha.21・武魂覺醒')

    anchor = 'const Alpha20DemoProfile = preload("res://scripts/systems/demo/alpha20_demo_profile.gd")\n'
    block = anchor + (
        'const Alpha21CombatIdentity = preload("res://scripts/systems/combat/alpha21_combat_identity.gd")\n'
        'const Alpha21HeroSignatures = preload("res://scripts/systems/hero/alpha21_hero_signatures.gd")\n'
        'const Alpha21BossPatterns = preload("res://scripts/systems/boss/alpha21_boss_patterns.gd")\n'
    )
    if 'Alpha21CombatIdentity' not in text:
        text = replace_once(text, anchor, block)

    var_anchor = 'var alpha20_last_kills: int = 0\n'
    var_block = var_anchor + (
        'var alpha21_identity_state: Dictionary = {}\n'
        'var alpha21_boss_sequence: int = 0\n'
        'var alpha21_boss_phase: int = 1\n'
    )
    if 'var alpha21_identity_state' not in text:
        text = replace_once(text, var_anchor, var_block)

    init_anchor = '\talpha20_prepare_chapter()\n\n\nfunc alpha20_prepare_chapter()'
    if 'alpha21_initialize_run()' not in text:
        text = replace_once(text, init_anchor, '\talpha20_prepare_chapter()\n\talpha21_initialize_run()\n\n\nfunc alpha20_prepare_chapter()')

    old_damage = 'var dmg: float = float(player["damage"]) * float(player.get("alpha19_damage_mult", 1.0)) * float(player.get("alpha20_damage_mult", 1.0)) * (1.0 + skill_level("damage") * 0.15) * (1.0 + relic_stat("damage_bonus"))'
    new_damage = 'var dmg: float = float(player["damage"]) * float(player.get("alpha19_damage_mult", 1.0)) * float(player.get("alpha20_damage_mult", 1.0)) * alpha21_identity_damage_multiplier() * (1.0 + skill_level("damage") * 0.15) * (1.0 + relic_stat("damage_bonus"))'
    if 'alpha21_identity_damage_multiplier()' not in text:
        text = replace_once(text, old_damage, new_damage)

    if 'func alpha21_initialize_run()' not in text:
        text += r'''

# Alpha.21：主角戰鬥辨識、名將招牌技與 Boss 階段資料。
func alpha21_initialize_run() -> void:
	alpha21_identity_state = Alpha21CombatIdentity.profile(chosen_identity)
	alpha21_boss_sequence = 0
	alpha21_boss_phase = 1
	var crit_bonus: float = Alpha21CombatIdentity.crit_bonus(chosen_identity)
	player["alpha21_crit_bonus"] = crit_bonus
	player["alpha21_dash_cd_mult"] = Alpha21CombatIdentity.dash_cooldown_multiplier(chosen_identity)
	show_message("Alpha.21武魂｜%s" % Alpha21CombatIdentity.summary(chosen_identity), 4.0)


func alpha21_identity_damage_multiplier() -> float:
	return Alpha21CombatIdentity.base_damage_multiplier(chosen_identity)


func alpha21_contextual_damage_multiplier(distance: float, is_dot: bool = false, is_return_hit: bool = false) -> float:
	return Alpha21CombatIdentity.contextual_damage_multiplier(chosen_identity, distance, is_dot, is_return_hit)


func alpha21_hero_signature(hero_id: String) -> Dictionary:
	return Alpha21HeroSignatures.signature(hero_id)


func alpha21_hero_cast_label(hero_id: String) -> String:
	return Alpha21HeroSignatures.cast_label(hero_id, int(hero_levels.get(hero_id, 1)))


func alpha21_boss_next_move() -> String:
	if boss.is_empty():
		return ""
	var boss_id: String = str(boss.get("id", boss.get("key", "")))
	var hp_ratio: float = float(boss.get("hp", 0.0)) / max(1.0, float(boss.get("max_hp", 1.0)))
	alpha21_boss_phase = Alpha21BossPatterns.phase_for_hp(boss_id, hp_ratio)
	var move_id: String = Alpha21BossPatterns.next_move(boss_id, alpha21_boss_sequence, hp_ratio)
	alpha21_boss_sequence += 1
	return move_id


func alpha21_boss_weakness_window(interrupted: bool = false) -> float:
	if boss.is_empty():
		return 0.0
	var boss_id: String = str(boss.get("id", boss.get("key", "")))
	return Alpha21BossPatterns.weakness_window(boss_id, interrupted)
'''

    MAIN.write_text(text, encoding="utf-8")


def patch_project() -> None:
    text = PROJECT.read_text(encoding="utf-8")
    text = text.replace('三國人生錄：亂世倖存 V2.0.0-alpha.20', '三國人生錄：亂世倖存 V2.0.0-alpha.21')
    PROJECT.write_text(text, encoding="utf-8")


if __name__ == "__main__":
    patch_main()
    patch_project()
    print("Alpha.21 combat identity patch applied")
