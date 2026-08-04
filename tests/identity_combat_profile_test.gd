extends Node

const ProfileScript = preload("res://scripts/systems/combat/identity_combat_profile.gd")


func _ready() -> void:
	_test_profiles_exist()
	_test_core_levels_differ()
	_test_threshold_bonuses()
	print("identity_combat_profile_test passed")
	get_tree().quit()


func _test_profiles_exist() -> void:
	for weapon in ["blade", "bow", "poison", "rings"]:
		var profile: Dictionary = ProfileScript.for_player({"weapon": weapon})
		assert(not profile.is_empty())
		assert(not (profile.get("tags", []) as Array).is_empty())


func _test_core_levels_differ() -> void:
	var levels: Dictionary = {
		"damage": 2,
		"attack_speed": 1,
		"crit": 2,
		"armor": 3,
		"dash": 1,
		"projectile": 4,
		"pierce": 2,
		"multishot": 2,
		"poison": 5,
		"heal": 2,
		"move_speed": 1,
	}
	assert(ProfileScript.core_level("blade", levels) == 9)
	assert(ProfileScript.core_level("bow", levels) == 11)
	assert(ProfileScript.core_level("poison", levels) == 11)
	assert(ProfileScript.core_level("rings", levels) == 10)


func _test_threshold_bonuses() -> void:
	assert(ProfileScript.threshold_bonus(1, [2, 5]) == 0)
	assert(ProfileScript.threshold_bonus(3, [2, 5]) == 1)
	assert(ProfileScript.threshold_bonus(7, [2, 5]) == 2)
