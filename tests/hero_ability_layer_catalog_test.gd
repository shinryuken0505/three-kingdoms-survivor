extends RefCounted

const Catalog = preload("res://scripts/data/hero_ability_layer_catalog.gd")


static func run() -> void:
	var melee: Dictionary = Catalog.build("guanyu", {
		"name": "關羽",
		"combat_role": "melee",
		"active": "青龍偃月",
		"passive": "武聖之威",
		"legendary": "武聖",
		"identity": "破甲斬陣",
	})
	assert((melee.get("specialization", {}) as Dictionary).get("source") == &"active")
	assert((melee.get("reserve_passive", {}) as Dictionary).get("source") == &"reserve")
	assert(bool((melee.get("legacy_art", {}) as Dictionary).get("locked", false)))
	assert(((melee.get("specialization", {}) as Dictionary).get("build_tags", []) as Array).has(&"melee"))

	var ranged: Dictionary = Catalog.build("taishici", {
		"name": "太史慈",
		"combat_role": "ranged",
	})
	assert(((ranged.get("specialization", {}) as Dictionary).get("build_tags", []) as Array).has(&"ranged"))
