extends RefCounted


static func run() -> void:
	_test_melee_excludes_projectile_cards()
	_test_ranged_keeps_projectile_cards()
	_test_poisoner_opens_poison_route()
	_test_maxed_skills_are_removed()
	_test_offer_has_unique_ids()


static func _test_melee_excludes_projectile_cards() -> void:
	var defs: Dictionary = _skill_defs()
	var offer: Array[Dictionary] = LevelupOfferService.build_offer(
		{"weapon": "blade"}, defs, {}, [], 0, 8
	)
	var ids: Array[String] = _ids(offer)
	assert(not ids.has("projectile"))
	assert(not ids.has("pierce"))
	assert(not ids.has("multishot"))
	assert(ids.has("damage"))


static func _test_ranged_keeps_projectile_cards() -> void:
	var offer: Array[Dictionary] = LevelupOfferService.build_offer(
		{"weapon": "bow"}, _skill_defs(), {}, [], 0, 8
	)
	var ids: Array[String] = _ids(offer)
	assert(ids.has("projectile") or ids.has("pierce") or ids.has("multishot"))


static func _test_poisoner_opens_poison_route() -> void:
	var offer: Array[Dictionary] = LevelupOfferService.build_offer(
		{"weapon": "poison", "poison_power": 1.0}, _skill_defs(), {}, [], 2, 8
	)
	assert(_ids(offer).has("poison"))


static func _test_maxed_skills_are_removed() -> void:
	var offer: Array[Dictionary] = LevelupOfferService.build_offer(
		{"weapon": "blade"}, _skill_defs(), {"damage": 5}, [], 0, 8
	)
	assert(not _ids(offer).has("damage"))


static func _test_offer_has_unique_ids() -> void:
	var offer: Array[Dictionary] = LevelupOfferService.build_offer(
		{"weapon": "bow"}, _skill_defs(), {}, [], 7, 3
	)
	var ids: Array[String] = _ids(offer)
	var unique: Dictionary = {}
	for skill_id in ids:
		unique[skill_id] = true
	assert(ids.size() == unique.size())


static func _skill_defs() -> Dictionary:
	return {
		"damage": {"name": "damage", "max": 5},
		"attack_speed": {"name": "speed", "max": 5},
		"move_speed": {"name": "move", "max": 4},
		"max_hp": {"name": "hp", "max": 4},
		"armor": {"name": "armor", "max": 4},
		"crit": {"name": "crit", "max": 5},
		"magnet": {"name": "magnet", "max": 4},
		"dash": {"name": "dash", "max": 4},
		"hero_cd": {"name": "hero", "max": 5},
		"projectile": {"name": "projectile", "max": 5},
		"pierce": {"name": "pierce", "max": 3},
		"poison": {"name": "poison", "max": 5},
		"multishot": {"name": "multishot", "max": 3},
		"heal": {"name": "heal", "max": 4},
	}


static func _ids(cards: Array[Dictionary]) -> Array[String]:
	var result: Array[String] = []
	for card in cards:
		result.append(str(card.get("id", "")))
	return result
