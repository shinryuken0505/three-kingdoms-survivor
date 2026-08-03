extends RefCounted

const CatalogScript = preload("res://scripts/data/hero_specialization_offer_catalog.gd")


static func run() -> void:
	var pool: Array[Dictionary] = [
		{"id": "damage", "name": "百戰磨鋒", "desc": "提高傷害", "priority": 90},
		{"id": "projectile", "name": "勁矢穿雲", "desc": "提高投射傷害", "priority": 96},
	]
	var heroes: Dictionary = {
		"guanyu": {"name": "關羽", "combat_role": "melee", "active": "青龍偃月"},
		"taishici": {"name": "太史慈", "combat_role": "ranged", "active": "神射貫日"},
	}
	var melee_cards: Array[Dictionary] = CatalogScript.build_cards(["guanyu"], heroes, pool)
	assert(melee_cards.size() == 1)
	assert(str(melee_cards[0].get("id", "")) == "damage")
	assert(str(melee_cards[0].get("category", "")) == "hero_specialization")
	assert(str(melee_cards[0].get("source_hero_id", "")) == "guanyu")

	var ranged_cards: Array[Dictionary] = CatalogScript.build_cards(["taishici"], heroes, pool)
	assert(ranged_cards.size() == 1)
	assert(str(ranged_cards[0].get("id", "")) == "projectile")

	var merged: Array[Dictionary] = CatalogScript.merge_with_pool(pool, melee_cards)
	assert(merged.size() == pool.size())
	var damage_count: int = 0
	for card in merged:
		if str(card.get("id", "")) == "damage":
			damage_count += 1
	assert(damage_count == 1)
