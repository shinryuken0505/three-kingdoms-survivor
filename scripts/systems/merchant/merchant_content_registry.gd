class_name MerchantContentRegistry
extends RefCounted

const MERCHANTS: Dictionary = {
	"peddler": {
		"id": "peddler", "name": "流動行商", "price_mult": 1.00,
		"relic_count": 2, "equipment_count": 1, "min_chapter": 1,
		"allowed_types": ["relic", "equipment", "heal"],
		"tags": ["general"],
	},
	"blacksmith": {
		"id": "blacksmith", "name": "軍中鐵匠", "price_mult": 1.08,
		"relic_count": 0, "equipment_count": 4, "min_chapter": 1,
		"allowed_types": ["equipment", "upgrade"],
		"tags": ["weapon", "armor"],
	},
	"antiquarian": {
		"id": "antiquarian", "name": "古董商", "price_mult": 1.20,
		"relic_count": 3, "equipment_count": 2, "min_chapter": 2,
		"allowed_types": ["relic", "equipment", "special_trade"],
		"tags": ["rare", "historical"],
	},
	"mystic": {
		"id": "mystic", "name": "神秘商人", "price_mult": 1.35,
		"relic_count": 3, "equipment_count": 2, "min_chapter": 3,
		"allowed_types": ["relic", "equipment", "special_trade"],
		"tags": ["legendary", "branch"],
	},
}

const RUN_RULES: Dictionary = {
	"min_visits": 2,
	"max_visits": 5,
	"min_interval": 88.0,
	"max_interval": 138.0,
	"base_refresh_cost": 55,
	"refresh_growth": 1.32,
	"chapter_price_growth": 0.10,
	"duplicate_item_retry": 8,
}

static func normalize_id(value: String) -> String:
	return value.strip_edges().to_lower().replace("-", "_").replace(" ", "_")

static func get_definition(merchant_id: String) -> Dictionary:
	var normalized: String = normalize_id(merchant_id)
	return (MERCHANTS.get(normalized, MERCHANTS["peddler"]) as Dictionary).duplicate(true)

static func eligible_merchants(chapter_number: int, context: Dictionary = {}) -> Array[String]:
	var result: Array[String] = []
	for merchant_id in MERCHANTS.keys():
		var definition: Dictionary = MERCHANTS[merchant_id] as Dictionary
		if chapter_number < int(definition.get("min_chapter", 1)):
			continue
		var required_flag: String = str(definition.get("required_flag", ""))
		if required_flag != "" and not bool(context.get(required_flag, false)):
			continue
		result.append(str(merchant_id))
	return result

static func price_multiplier(merchant_id: String, chapter_number: int, discount_mult: float = 1.0) -> float:
	var definition: Dictionary = get_definition(merchant_id)
	var chapter_growth: float = 1.0 + max(0, chapter_number - 1) * float(RUN_RULES["chapter_price_growth"])
	return max(0.25, float(definition.get("price_mult", 1.0)) * chapter_growth * discount_mult)

static func refresh_cost(refresh_count: int) -> int:
	return int(round(float(RUN_RULES["base_refresh_cost"]) * pow(float(RUN_RULES["refresh_growth"]), max(0, refresh_count))))

static func validate() -> Array[String]:
	var errors: Array[String] = []
	for merchant_id in MERCHANTS.keys():
		var definition: Dictionary = MERCHANTS[merchant_id] as Dictionary
		for field in ["id", "name", "price_mult", "allowed_types"]:
			if not definition.has(field):
				errors.append("商人 %s 缺少欄位：%s" % [merchant_id, field])
		if normalize_id(str(definition.get("id", ""))) != str(merchant_id):
			errors.append("商人 ID 不一致：%s" % merchant_id)
	return errors
