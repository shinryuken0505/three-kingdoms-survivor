extends SceneTree

const CombatIdentity = preload("res://scripts/systems/combat/alpha21_combat_identity.gd")
const HeroSignatures = preload("res://scripts/systems/hero/alpha21_hero_signatures.gd")
const BossPatterns = preload("res://scripts/systems/boss/alpha21_boss_patterns.gd")

func _initialize() -> void:
	assert(CombatIdentity.base_damage_multiplier("swordsman") > CombatIdentity.base_damage_multiplier("poisoner"))
	assert(CombatIdentity.contextual_damage_multiplier("archer", 500.0) > CombatIdentity.contextual_damage_multiplier("archer", 100.0))
	assert(CombatIdentity.contextual_damage_multiplier("poisoner", 100.0, true) > CombatIdentity.base_damage_multiplier("poisoner"))
	assert(CombatIdentity.contextual_damage_multiplier("ring_blade", 100.0, false, true) > CombatIdentity.base_damage_multiplier("ring_blade"))
	assert(HeroSignatures.exists("guanyu"))
	assert(HeroSignatures.cast_label("guanyu", 5).contains("大成"))
	assert(HeroSignatures.effect_multiplier("zhouyu", 5, "red_cliffs") > HeroSignatures.effect_multiplier("zhouyu", 5, "yellow_turban"))
	assert(BossPatterns.phase_for_hp("lvbu", 0.4) == 2)
	assert(BossPatterns.next_move("lvbu", 3, 0.4) == "peerless_assault")
	assert(BossPatterns.weakness_window("huangzhong", true) > BossPatterns.weakness_window("huangzhong", false))
	print("ALPHA21_COMBAT_IDENTITY_OK")
	quit(0)
