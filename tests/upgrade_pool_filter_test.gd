extends RefCounted


static func run() -> Array[String]:
	var errors: Array[String] = []
	_test_melee_profile(errors)
	_test_ranged_profile(errors)
	_test_shared_cards(errors)
	_test_special_entry(errors)
	_test_offer_shape(errors)
	return errors


static func _test_melee_profile(errors: Array[String]) -> void:
	var profile: Dictionary = PlayerBuildProfile.build({"weapon": "sword"})
	_assert(PlayerBuildProfile.has_tag(profile, &"melee"), "sword should create melee profile", errors)
	_assert(not PlayerBuildProfile.has_tag(profile, &"ranged"), "sword should not create ranged profile", errors)
	var ranged_card := {"category": &"player_skill", "build_tags": [&"ranged"]}
	_assert(not UpgradePoolFilter.is_compatible(ranged_card, profile), "pure ranged card must be filtered for melee", errors)


static func _test_ranged_profile(errors: Array[String]) -> void:
	var profile: Dictionary = PlayerBuildProfile.build({"weapon": "bow"})
	_assert(PlayerBuildProfile.has_tag(profile, &"ranged"), "bow should create ranged profile", errors)
	var melee_card := {"category": &"player_skill", "build_tags": [&"melee"]}
	_assert(not UpgradePoolFilter.is_compatible(melee_card, profile), "pure melee card must be filtered for ranged", errors)


static func _test_shared_cards(errors: Array[String]) -> void:
	var profile: Dictionary = PlayerBuildProfile.build({"weapon": "bow"})
	var armor_card := {"category": &"passive", "build_tags": [&"shared"]}
	_assert(UpgradePoolFilter.is_compatible(armor_card, profile), "shared passive should remain available", errors)
	var blocked_card := {"category": &"passive", "blocked_tags": [&"ranged"]}
	_assert(not UpgradePoolFilter.is_compatible(blocked_card, profile), "blocked shared card should be removed", errors)


static func _test_special_entry(errors: Array[String]) -> void:
	var profile: Dictionary = PlayerBuildProfile.build({"weapon": "sword"})
	var poison_upgrade := {"category": &"player_skill", "required_tags": [&"poison"], "build_tags": [&"poison"]}
	_assert(not UpgradePoolFilter.is_compatible(poison_upgrade, profile), "locked poison upgrade should not appear", errors)
	var poison_entry := {"category": &"player_skill", "build_tags": [&"poison"], "entry_tags": [&"poison"]}
	_assert(UpgradePoolFilter.is_compatible(poison_entry, profile), "explicit poison entry may open a new route", errors)
	var opened: Dictionary = PlayerBuildProfile.build({"weapon": "sword"}, {"poison_cloud": 1})
	_assert(UpgradePoolFilter.is_compatible(poison_upgrade, opened), "poison upgrades should appear after route is opened", errors)


static func _test_offer_shape(errors: Array[String]) -> void:
	var profile: Dictionary = PlayerBuildProfile.build({"weapon": "sword"})
	var cards: Array = [
		{"id": "slash_1", "category": &"player_skill", "build_tags": [&"melee"]},
		{"id": "slash_2", "category": &"player_skill", "build_tags": [&"melee"]},
		{"id": "armor", "category": &"passive"},
		{"id": "poison_entry", "category": &"player_skill", "build_tags": [&"poison"], "entry_tags": [&"poison"]},
	]
	var offer: Array[Dictionary] = UpgradePoolFilter.build_offer(cards, profile, 3)
	_assert(offer.size() == 3, "offer should contain three cards when enough candidates exist", errors)
	_assert(str(offer[0].get("id")) == "slash_1" and str(offer[1].get("id")) == "slash_2", "first two cards should reinforce current build", errors)


static func _assert(condition: bool, message: String, errors: Array[String]) -> void:
	if not condition:
		errors.append(message)
