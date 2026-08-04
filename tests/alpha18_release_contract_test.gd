extends RefCounted

const OfferServiceScript = preload("res://scripts/systems/progression/levelup_offer_service.gd")


static func run() -> void:
	_test_levelup_offer_contract()
	_test_specialization_limit()


static func _test_levelup_offer_contract() -> void:
	var player := {"weapon": "blade", "level": 5}
	var skill_defs := {
		"damage": {"id": "damage", "name": "傷害", "max": 5},
		"attack_speed": {"id": "attack_speed", "name": "攻速", "max": 5},
		"max_hp": {"id": "max_hp", "name": "生命", "max": 5},
		"projectile": {"id": "projectile", "name": "投射", "max": 5},
	}
	var offer: Array[Dictionary] = OfferServiceScript.build_offer(
		player,
		skill_defs,
		{},
		[],
		7,
		3,
		{}
	)
	assert(not offer.is_empty())
	for card in offer:
		assert(card is Dictionary)
		assert(skill_defs.has(str(card.get("id", ""))))
		assert(str(card.get("id", "")) != "projectile")


static func _test_specialization_limit() -> void:
	var player := {"weapon": "bow", "level": 8}
	var skill_defs := {
		"damage": {"id": "damage", "name": "傷害", "max": 5},
		"attack_speed": {"id": "attack_speed", "name": "攻速", "max": 5},
		"projectile": {"id": "projectile", "name": "投射", "max": 5},
		"pierce": {"id": "pierce", "name": "穿透", "max": 5},
		"multishot": {"id": "multishot", "name": "多射", "max": 5},
	}
	var heroes := {
		"huangzhong": {"name": "黃忠", "combat_role": "ranged"},
		"zhaoyun": {"name": "趙雲", "combat_role": "mobility"},
	}
	var offer: Array[Dictionary] = OfferServiceScript.build_offer(
		player,
		skill_defs,
		{},
		["huangzhong", "zhaoyun"],
		11,
		3,
		heroes
	)
	var specialization_count := 0
	for card in offer:
		if str(card.get("category", "")) == "hero_specialization":
			specialization_count += 1
	assert(specialization_count <= 1)
