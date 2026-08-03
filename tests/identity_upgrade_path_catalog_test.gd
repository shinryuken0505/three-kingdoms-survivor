extends RefCounted

const PathCatalogScript = preload("res://scripts/data/identity_upgrade_path_catalog.gd")
const OfferServiceScript = preload("res://scripts/systems/progression/levelup_offer_service.gd")


static func run() -> void:
	_test_blade_path_blocks_ranged_cards()
	_test_bow_path_prioritizes_projectiles()
	_test_poison_path_prioritizes_poison()
	_test_rings_path_prioritizes_multishot()
	_test_summary_tracks_developed_core_skills()


static func _test_blade_path_blocks_ranged_cards() -> void:
	var path: Dictionary = PathCatalogScript.path_for_player({"weapon": "blade"})
	assert("projectile" in (path.get("blocked", []) as Array))
	assert("damage" in (path.get("primary", []) as Array))


static func _test_bow_path_prioritizes_projectiles() -> void:
	var card: Dictionary = PathCatalogScript.decorate_card({"id": "projectile", "priority": 10}, {"weapon": "bow"})
	assert(str(card.get("path_tier", "")) == "primary")
	assert(int(card.get("path_priority", 0)) == 90)


static func _test_poison_path_prioritizes_poison() -> void:
	var card: Dictionary = PathCatalogScript.decorate_card({"id": "poison", "priority": 10}, {"weapon": "poison"})
	assert(str(card.get("path_tier", "")) == "primary")


static func _test_rings_path_prioritizes_multishot() -> void:
	var card: Dictionary = PathCatalogScript.decorate_card({"id": "multishot", "priority": 10}, {"weapon": "rings"})
	assert(str(card.get("path_tier", "")) == "primary")


static func _test_summary_tracks_developed_core_skills() -> void:
	var summary: Dictionary = OfferServiceScript.build_summary(
		{"weapon": "blade"},
		{"damage": 2, "projectile": 1}
	)
	assert(str(summary.get("path_name", "")) == "近戰先鋒")
	assert("damage" in (summary.get("developed", []) as Array))
	assert(not ("projectile" in (summary.get("developed", []) as Array)))
