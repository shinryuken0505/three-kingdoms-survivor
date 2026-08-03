class_name LevelupOfferService
extends RefCounted

## 從既有技能定義建立符合目前主角流派的升級選項。
## 保留舊技能 ID 與卡片欄位，choose_levelup() 可繼續沿用。

const BuildProfileScript = preload("res://scripts/systems/progression/player_build_profile.gd")
const PoolFilterScript = preload("res://scripts/systems/progression/upgrade_pool_filter.gd")
const CardCatalogScript = preload("res://scripts/data/upgrade_card_catalog.gd")
const IdentityPathScript = preload("res://scripts/data/identity_upgrade_path_catalog.gd")
const HeroSpecializationScript = preload("res://scripts/data/hero_specialization_offer_catalog.gd")


static func build_offer(
	player: Dictionary,
	skill_defs: Dictionary,
	skill_levels: Dictionary,
	active_heroes: Array = [],
	seed: int = 0,
	count: int = 3,
	hero_defs: Dictionary = {}
) -> Array[Dictionary]:
	if count <= 0:
		return []
	var unlocked_tags: Array = _unlocked_tags(player, active_heroes)
	var profile: Dictionary = BuildProfileScript.build(player, skill_levels, unlocked_tags)
	var raw_pool: Array[Dictionary] = CardCatalogScript.decorate_pool(skill_defs, skill_levels)
	var path_pool: Array[Dictionary] = IdentityPathScript.decorate_pool(raw_pool, player)
	var specialization_cards: Array[Dictionary] = HeroSpecializationScript.build_cards(
		active_heroes,
		hero_defs,
		path_pool
	)
	var merged_pool: Array[Dictionary] = HeroSpecializationScript.merge_with_pool(
		path_pool,
		specialization_cards
	)
	var compatible: Array[Dictionary] = PoolFilterScript.filter_candidates(merged_pool, profile)
	if compatible.is_empty():
		compatible = merged_pool
	if compatible.is_empty():
		compatible = raw_pool
	_rotate(compatible, seed)
	return _balanced_offer(compatible, profile, count)


static func decorate_existing(
	choices: Array,
	skill_defs: Dictionary,
	profile: Dictionary,
	player: Dictionary = {}
) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in choices:
		if not (value is Dictionary):
			continue
		var card: Dictionary = value as Dictionary
		var skill_id: String = CardCatalogScript.infer_id(card, skill_defs)
		var decorated: Dictionary = card.duplicate(true)
		if not skill_id.is_empty():
			decorated = CardCatalogScript.decorate(skill_id, decorated)
		if not player.is_empty():
			decorated = IdentityPathScript.decorate_card(decorated, player)
		decorated["compatible"] = PoolFilterScript.is_compatible(decorated, profile)
		result.append(decorated)
	return result


static func build_summary(player: Dictionary, skill_levels: Dictionary) -> Dictionary:
	return IdentityPathScript.summary(player, skill_levels)


static func _balanced_offer(pool: Array[Dictionary], profile: Dictionary, count: int) -> Array[Dictionary]:
	var primary: Array[Dictionary] = []
	var specialization: Array[Dictionary] = []
	var secondary: Array[Dictionary] = []
	var shared: Array[Dictionary] = []
	var entry: Array[Dictionary] = []
	for card in pool:
		var tier: String = str(card.get("path_tier", "shared"))
		var category: String = str(card.get("category", "player_skill"))
		if not (card.get("entry_tags", []) as Array).is_empty():
			entry.append(card)
		elif category == "hero_specialization" or tier == "specialization":
			specialization.append(card)
		elif tier == "primary":
			primary.append(card)
		elif tier == "secondary":
			secondary.append(card)
		elif category == "shared" or category == "passive":
			shared.append(card)
		else:
			secondary.append(card)

	var result: Array[Dictionary] = []
	_take_unique(result, primary, mini(1, count))
	_take_unique(result, specialization, mini(2, count))
	_take_unique(result, secondary, mini(2, count))
	_take_unique(result, shared, count)
	_take_unique(result, primary, count)
	_take_unique(result, entry, count)
	_take_unique(result, specialization, count)
	_take_unique(result, pool, count)
	for card in result:
		card["compatible"] = PoolFilterScript.is_compatible(card, profile)
	return result


static func _take_unique(result: Array[Dictionary], source: Array[Dictionary], limit: int) -> void:
	while result.size() < limit and not source.is_empty():
		var card: Dictionary = source.pop_front()
		if not _contains_id(result, str(card.get("id", ""))):
			result.append(card)


static func _unlocked_tags(player: Dictionary, active_heroes: Array) -> Array:
	var tags: Array = []
	var weapon: String = str(player.get("weapon", ""))
	if float(player.get("poison_power", 1.0)) > 1.0 or weapon == "poison":
		tags.append("poison")
	if weapon == "rings":
		tags.append("projectile")
		tags.append("mobility")
	if active_heroes.size() > 0:
		tags.append("hero")
	return tags


static func _rotate(values: Array[Dictionary], seed: int) -> void:
	if values.size() <= 1:
		return
	var offset: int = posmod(seed, values.size())
	for index in range(offset):
		values.append(values.pop_front())


static func _contains_id(cards: Array[Dictionary], skill_id: String) -> bool:
	for card in cards:
		if str(card.get("id", "")) == skill_id:
			return true
	return false
