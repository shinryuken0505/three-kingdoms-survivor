class_name LevelupOfferService
extends RefCounted

## 從既有技能定義建立符合目前主角流派的升級選項。
## 保留舊技能 ID 與卡片欄位，choose_levelup() 可繼續沿用。


static func build_offer(
	player: Dictionary,
	skill_defs: Dictionary,
	skill_levels: Dictionary,
	active_heroes: Array = [],
	seed: int = 0,
	count: int = 3
) -> Array[Dictionary]:
	if count <= 0:
		return []
	var unlocked_tags: Array = _unlocked_tags(player, active_heroes)
	var profile: Dictionary = PlayerBuildProfile.build(player, skill_levels, unlocked_tags)
	var pool: Array[Dictionary] = UpgradeCardCatalog.decorate_pool(skill_defs, skill_levels)
	var compatible: Array[Dictionary] = UpgradePoolFilter.filter_candidates(pool, profile)
	if compatible.is_empty():
		compatible = pool
	_rotate(compatible, seed)
	return _balanced_offer(compatible, profile, count)


static func decorate_existing(
	choices: Array,
	skill_defs: Dictionary,
	profile: Dictionary
) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in choices:
		if not (value is Dictionary):
			continue
		var card: Dictionary = value as Dictionary
		var skill_id: String = UpgradeCardCatalog.infer_id(card, skill_defs)
		var decorated: Dictionary = card.duplicate(true)
		if not skill_id.is_empty():
			decorated = UpgradeCardCatalog.decorate(skill_id, decorated)
		decorated["compatible"] = UpgradePoolFilter.is_compatible(decorated, profile)
		result.append(decorated)
	return result


static func _balanced_offer(pool: Array[Dictionary], profile: Dictionary, count: int) -> Array[Dictionary]:
	var direct: Array[Dictionary] = []
	var shared: Array[Dictionary] = []
	var entry: Array[Dictionary] = []
	for card in pool:
		var category: StringName = StringName(str(card.get("category", &"player_skill")))
		if not (card.get("entry_tags", []) as Array).is_empty():
			entry.append(card)
		elif category in [&"shared", &"passive"]:
			shared.append(card)
		else:
			direct.append(card)
	var result: Array[Dictionary] = []
	while result.size() < mini(2, count) and not direct.is_empty():
		result.append(direct.pop_front())
	while result.size() < count and not shared.is_empty():
		result.append(shared.pop_front())
	while result.size() < count and not direct.is_empty():
		result.append(direct.pop_front())
	while result.size() < count and not entry.is_empty():
		result.append(entry.pop_front())
	while result.size() < count and not pool.is_empty():
		var fallback: Dictionary = pool.pop_front()
		if not _contains_id(result, str(fallback.get("id", ""))):
			result.append(fallback)
	for card in result:
		card["compatible"] = UpgradePoolFilter.is_compatible(card, profile)
	return result


static func _unlocked_tags(player: Dictionary, active_heroes: Array) -> Array:
	var tags: Array = []
	if float(player.get("poison_power", 1.0)) > 1.0 or str(player.get("weapon", "")) == "poison":
		tags.append(&"poison")
	if active_heroes.size() > 0:
		tags.append(&"hero")
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
