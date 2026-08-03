class_name PlayerBuildProfile
extends RefCounted

## 主角升級池使用的流派快照。
##
## 只根據角色武器、已取得技能與顯式解鎖標籤建立判斷資料，不直接修改玩家資料。

const MELEE: StringName = &"melee"
const RANGED: StringName = &"ranged"
const SHARED: StringName = &"shared"
const HYBRID: StringName = &"hybrid"

const MELEE_WEAPONS: Array[StringName] = [&"sword", &"blade", &"spear", &"halberd", &"staff", &"fist"]
const RANGED_WEAPONS: Array[StringName] = [&"bow", &"crossbow", &"throwing", &"fan", &"orb"]


static func build(player: Dictionary, skill_levels: Dictionary = {}, unlocked_tags: Array = []) -> Dictionary:
	var weapon: StringName = StringName(str(player.get("weapon", "")))
	var combat_type: StringName = classify_weapon(weapon)
	var tags: Dictionary = {}
	_add_tag(tags, SHARED)
	_add_tag(tags, combat_type)
	for value in unlocked_tags:
		_add_tag(tags, StringName(str(value)))
	for skill_id in skill_levels:
		if int(skill_levels.get(skill_id, 0)) <= 0:
			continue
		_add_skill_tags(tags, StringName(str(skill_id)))
	return {
		"weapon": weapon,
		"combat_type": combat_type,
		"tags": tags,
		"skill_levels": skill_levels.duplicate(true),
	}


static func classify_weapon(weapon: StringName) -> StringName:
	if weapon in MELEE_WEAPONS:
		return MELEE
	if weapon in RANGED_WEAPONS:
		return RANGED
	return HYBRID


static func has_tag(profile: Dictionary, tag: StringName) -> bool:
	return bool((profile.get("tags", {}) as Dictionary).get(tag, false))


static func _add_skill_tags(tags: Dictionary, skill_id: StringName) -> void:
	var text: String = String(skill_id)
	if text.contains("poison"):
		_add_tag(tags, &"poison")
	if text.contains("fire") or text.contains("burn"):
		_add_tag(tags, &"fire")
	if text.contains("summon") or text.contains("ally"):
		_add_tag(tags, &"summon")
	if text.contains("control") or text.contains("slow") or text.contains("stun"):
		_add_tag(tags, &"control")
	if text.contains("projectile") or text.contains("arrow") or text.contains("pierce"):
		_add_tag(tags, RANGED)
	if text.contains("slash") or text.contains("melee") or text.contains("contact"):
		_add_tag(tags, MELEE)


static func _add_tag(tags: Dictionary, tag: StringName) -> void:
	if tag != &"":
		tags[tag] = true
