class_name MerchantPricingService
extends RefCounted

const MerchantContentRegistry = preload("res://scripts/systems/merchant/merchant_content_registry.gd")

const RELIC_BASE: Dictionary = {"common":42, "rare":125, "epic":285, "legendary":620, "mythic":980}
const EQUIPMENT_BASE: Dictionary = {"common":80, "rare":180, "epic":360, "legendary":680, "mythic":980}

static func price_multiplier(merchant_id: String, chapter_number: int, discount_mult: float = 1.0) -> float:
	return MerchantContentRegistry.price_multiplier(merchant_id, chapter_number, discount_mult)

static func relic_price(merchant_id: String, rarity: String, chapter_number: int, discount_mult: float = 1.0) -> int:
	var base: int = int(RELIC_BASE.get(rarity, 42))
	return max(1, int(round(float(base) * price_multiplier(merchant_id, chapter_number, discount_mult))))

static func equipment_price(merchant_id: String, rarity: String, chapter_number: int, equipment_discount_mult: float = 1.0) -> int:
	var base: int = int(EQUIPMENT_BASE.get(rarity, 80))
	return max(1, int(round(float(base) * price_multiplier(merchant_id, chapter_number, equipment_discount_mult))))

static func heal_price(merchant_id: String, chapter_number: int, discount_mult: float = 1.0) -> int:
	return max(1, int(round(18.0 * price_multiplier(merchant_id, chapter_number, discount_mult))))

static func refresh_cost(refresh_count: int) -> int:
	return MerchantContentRegistry.refresh_cost(refresh_count)

static func validate() -> Array[String]:
	var errors: Array[String] = MerchantContentRegistry.validate()
	for rarity in ["common", "rare", "epic", "legendary", "mythic"]:
		if not RELIC_BASE.has(rarity) or not EQUIPMENT_BASE.has(rarity):
			errors.append("missing price tier: %s" % rarity)
	return errors
