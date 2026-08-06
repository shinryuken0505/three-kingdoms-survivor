class_name SpecialTradeRegistry
extends RefCounted

const TRADES: Dictionary = {
	"healer_supply": {"merchant":"healer","name":"傷兵救濟","cost":{"coins":90},"reward":{"heal_ratio":0.35},"once_per_chapter":true},
	"antiquarian_exchange": {"merchant":"antiquarian","name":"舊物換珍藏","cost":{"relic_count":1},"reward":{"rare_relic":1},"once_per_chapter":true},
	"quartermaster_restock": {"merchant":"quartermaster","name":"軍需補給","cost":{"coins":145},"reward":{"equipment_reroll":1},"once_per_chapter":false},
	"blacksmith_reforge": {"merchant":"blacksmith","name":"重鑄裝備","cost":{"coins":180},"reward":{"equipment_upgrade":1},"once_per_chapter":true},
	"mystery_oath": {"merchant":"mystery","name":"以物易命","cost":{"max_hp_ratio":0.10},"reward":{"legendary_offer":1},"once_per_chapter":true}
}

static func trades_for(merchant_id: String, chapter_number: int = 1) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for trade_value in TRADES.keys():
		var trade_id: String = str(trade_value)
		var definition: Dictionary = TRADES[trade_id] as Dictionary
		if str(definition.get("merchant", "")) != merchant_id:
			continue
		if chapter_number < int(definition.get("chapter_min", 1)):
			continue
		var copy: Dictionary = definition.duplicate(true)
		copy["id"] = trade_id
		result.append(copy)
	return result

static func can_afford(definition: Dictionary, context: Dictionary) -> bool:
	var cost: Dictionary = definition.get("cost", {}) as Dictionary
	if int(cost.get("coins", 0)) > int(context.get("coins", 0)):
		return false
	if int(cost.get("relic_count", 0)) > int(context.get("relic_count", 0)):
		return false
	return true

static func validate() -> Array[String]:
	var errors: Array[String] = []
	for trade_value in TRADES.keys():
		var trade_id: String = str(trade_value)
		var definition: Dictionary = TRADES[trade_id] as Dictionary
		for key in ["merchant", "name", "cost", "reward"]:
			if not definition.has(key):
				errors.append("%s missing %s" % [trade_id, key])
	return errors
