class_name MerchantProductRegistry
extends RefCounted

static func build_catalog(relic_defs: Dictionary, equipment_defs: Dictionary) -> Dictionary:
	var catalog: Dictionary = {}
	for relic_id in relic_defs.keys():
		var definition: Dictionary = relic_defs[relic_id] as Dictionary
		catalog["relic:%s" % relic_id] = {
			"id": str(relic_id),
			"type": "relic",
			"name": str(definition.get("name", relic_id)),
			"rarity": str(definition.get("rarity", "common")),
			"base_price": int(definition.get("base_price", default_price(str(definition.get("rarity", "common"))))),
			"chapter_min": int(definition.get("chapter_min", 1)),
			"merchant_tags": definition.get("merchant_tags", ["general", "rare"]),
		}
	for equipment_id in equipment_defs.keys():
		var definition: Dictionary = equipment_defs[equipment_id] as Dictionary
		catalog["equipment:%s" % equipment_id] = {
			"id": str(equipment_id),
			"type": "equipment",
			"name": str(definition.get("name", equipment_id)),
			"rarity": str(definition.get("rarity", "common")),
			"base_price": int(definition.get("base_price", default_price(str(definition.get("rarity", "common"))))),
			"chapter_min": int(definition.get("chapter_min", 1)),
			"merchant_tags": definition.get("merchant_tags", tags_for_equipment(definition)),
		}
	return catalog

static func default_price(rarity: String) -> int:
	match rarity:
		"rare": return 145
		"epic": return 260
		"legendary": return 440
		"mythic": return 680
		_: return 85

static func tags_for_equipment(definition: Dictionary) -> Array[String]:
	var slot: String = str(definition.get("slot", ""))
	if slot in ["weapon", "body"]:
		return ["general", "weapon", "armor"]
	return ["general", "rare", "historical"]

static func eligible_products(catalog: Dictionary, merchant: Dictionary, chapter_number: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var allowed_types: Array = merchant.get("allowed_types", []) as Array
	var merchant_tags: Array = merchant.get("tags", []) as Array
	for key in catalog.keys():
		var product: Dictionary = catalog[key] as Dictionary
		if not allowed_types.has(str(product.get("type", ""))):
			continue
		if chapter_number < int(product.get("chapter_min", 1)):
			continue
		var product_tags: Array = product.get("merchant_tags", []) as Array
		var tag_match: bool = merchant_tags.is_empty()
		for tag in merchant_tags:
			if product_tags.has(tag):
				tag_match = true
				break
		if tag_match:
			result.append(product.duplicate(true))
	return result

static func validate(catalog: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var seen_pairs: Dictionary = {}
	for catalog_key in catalog.keys():
		var product: Dictionary = catalog[catalog_key] as Dictionary
		for field in ["id", "type", "name", "base_price"]:
			if not product.has(field):
				errors.append("商品 %s 缺少欄位：%s" % [catalog_key, field])
		var pair: String = "%s:%s" % [str(product.get("type", "")), str(product.get("id", ""))]
		if seen_pairs.has(pair):
			errors.append("商品重複：%s" % pair)
		seen_pairs[pair] = true
		if int(product.get("base_price", 0)) <= 0:
			errors.append("商品價格無效：%s" % pair)
	return errors
