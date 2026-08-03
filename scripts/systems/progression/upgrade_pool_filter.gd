class_name UpgradePoolFilter
extends RefCounted

## 依主角目前近戰／遠戰與已開啟流派，過濾升級候選。
##
## 候選卡可使用：category、build_tags、required_tags、blocked_tags、entry_tags。
## entry_tags 代表「流派入口卡」，即使尚未解鎖該標籤仍可出現，但 UI 應清楚標示。

const CATEGORY_SHARED: StringName = &"shared"
const CATEGORY_PLAYER: StringName = &"player_skill"
const CATEGORY_PASSIVE: StringName = &"passive"
const CATEGORY_HERO_SPECIALIZATION: StringName = &"hero_specialization"
const CATEGORY_LEGACY_ART: StringName = &"legacy_art"


static func filter_candidates(candidates: Array, profile: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in candidates:
		if not (value is Dictionary):
			continue
		var card: Dictionary = value as Dictionary
		if is_compatible(card, profile):
			result.append(card.duplicate(true))
	return result


static func is_compatible(card: Dictionary, profile: Dictionary) -> bool:
	var category: StringName = StringName(str(card.get("category", CATEGORY_PLAYER)))
	if category in [CATEGORY_SHARED, CATEGORY_PASSIVE]:
		return not _has_blocked_tag(card, profile)
	if _has_blocked_tag(card, profile):
		return false
	if not _required_tags_met(card, profile):
		return false
	var build_tags: Array = card.get("build_tags", []) as Array
	if build_tags.is_empty():
		return true
	for value in build_tags:
		if PlayerBuildProfile.has_tag(profile, StringName(str(value))):
			return true
	return _is_entry_card(card)


static func build_offer(candidates: Array, profile: Dictionary, count: int = 3) -> Array[Dictionary]:
	var compatible: Array[Dictionary] = filter_candidates(candidates, profile)
	if compatible.is_empty() or count <= 0:
		return []
	var direct: Array[Dictionary] = []
	var support: Array[Dictionary] = []
	var entry: Array[Dictionary] = []
	for card in compatible:
		if _is_entry_card(card):
			entry.append(card)
		elif StringName(str(card.get("category", CATEGORY_PLAYER))) in [CATEGORY_SHARED, CATEGORY_PASSIVE]:
			support.append(card)
		else:
			direct.append(card)
	var offer: Array[Dictionary] = []
	while offer.size() < mini(2, count) and not direct.is_empty():
		offer.append(direct.pop_front())
	while offer.size() < count and not support.is_empty():
		offer.append(support.pop_front())
	while offer.size() < count and not direct.is_empty():
		offer.append(direct.pop_front())
	while offer.size() < count and not entry.is_empty():
		offer.append(entry.pop_front())
	return offer


static func _required_tags_met(card: Dictionary, profile: Dictionary) -> bool:
	for value in card.get("required_tags", []) as Array:
		if not PlayerBuildProfile.has_tag(profile, StringName(str(value))):
			return false
	return true


static func _has_blocked_tag(card: Dictionary, profile: Dictionary) -> bool:
	for value in card.get("blocked_tags", []) as Array:
		if PlayerBuildProfile.has_tag(profile, StringName(str(value))):
			return true
	return false


static func _is_entry_card(card: Dictionary) -> bool:
	return not (card.get("entry_tags", []) as Array).is_empty()
