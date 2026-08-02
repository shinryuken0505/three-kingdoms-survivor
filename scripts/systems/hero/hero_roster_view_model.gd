class_name HeroRosterViewModel
extends RefCounted

## 將編成資料轉成 UI 可直接使用的 view model。
##
## UI renderer 不應自行推導主戰／後備／營地狀態，也不應讀取翻譯後文字判斷流程。

const HeroRosterManagerScript = preload("res://scripts/systems/hero/hero_roster_manager.gd")


static func build(
	hero_defs: Dictionary,
	known_ids: Array,
	active: Array,
	reserve: Array,
	camp: Array,
	selected_index: int,
	active_capacity: int,
	reserve_capacity: int,
	bond_levels: Dictionary,
	skill_levels: Dictionary
) -> Dictionary:
	var ordered_ids: Array[String] = []
	for value in known_ids:
		var hero_id: String = str(value)
		if hero_id != "" and hero_defs.has(hero_id) and not ordered_ids.has(hero_id):
			ordered_ids.append(hero_id)

	var safe_index: int = 0
	if not ordered_ids.is_empty():
		safe_index = clampi(selected_index, 0, ordered_ids.size() - 1)

	var rows: Array[Dictionary] = []
	for hero_id in ordered_ids:
		rows.append(_hero_entry(hero_id, hero_defs, active, reserve, camp, bond_levels, skill_levels))

	var selected: Dictionary = {}
	if not ordered_ids.is_empty():
		selected = _hero_entry(
			ordered_ids[safe_index], hero_defs, active, reserve, camp, bond_levels, skill_levels
		)

	return {
		"selected_index": safe_index,
		"selected": selected,
		"rows": rows,
		"active_slots": _slot_entries(active, active_capacity, hero_defs, bond_levels, skill_levels),
		"reserve_slots": _slot_entries(reserve, reserve_capacity, hero_defs, bond_levels, skill_levels),
		"camp_count": camp.size(),
		"active_count": active.size(),
		"active_capacity": max(0, active_capacity),
		"reserve_count": reserve.size(),
		"reserve_capacity": max(0, reserve_capacity),
	}


static func _slot_entries(
	hero_ids: Array,
	capacity: int,
	hero_defs: Dictionary,
	bond_levels: Dictionary,
	skill_levels: Dictionary
) -> Array[Dictionary]:
	var slots: Array[Dictionary] = []
	for index in range(max(0, capacity)):
		if index < hero_ids.size():
			var hero_id: String = str(hero_ids[index])
			var definition: Dictionary = hero_defs.get(hero_id, {})
			slots.append({
				"empty": false,
				"hero_id": hero_id,
				"name_key": "hero.%s.name" % hero_id,
				"fallback_name": str(definition.get("name", hero_id)),
				"color": definition.get("color", Color.WHITE),
				"bond_level": int(bond_levels.get(hero_id, 1)),
				"skill_level": int(skill_levels.get(hero_id, 1)),
			})
		else:
			slots.append({"empty": true, "hero_id": ""})
	return slots


static func _hero_entry(
	hero_id: String,
	hero_defs: Dictionary,
	active: Array,
	reserve: Array,
	camp: Array,
	bond_levels: Dictionary,
	skill_levels: Dictionary
) -> Dictionary:
	var definition: Dictionary = hero_defs.get(hero_id, {})
	var state: StringName = HeroRosterManagerScript.state_of(hero_id, active, reserve, camp)
	return {
		"hero_id": hero_id,
		"state": state,
		"state_key": "ui.hero_roster.state.%s" % String(state),
		"name_key": "hero.%s.name" % hero_id,
		"title_key": "hero.%s.title" % hero_id,
		"active_key": "hero.%s.active" % hero_id,
		"passive_key": "hero.%s.passive" % hero_id,
		"fallback_name": str(definition.get("name", hero_id)),
		"fallback_title": str(definition.get("title", "")),
		"fallback_active": str(definition.get("active", "")),
		"fallback_passive": str(definition.get("passive", "")),
		"color": definition.get("color", Color.WHITE),
		"bond_level": int(bond_levels.get(hero_id, 1)),
		"skill_level": int(skill_levels.get(hero_id, 1)),
	}
