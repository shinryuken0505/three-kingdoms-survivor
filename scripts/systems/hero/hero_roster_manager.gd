class_name HeroRosterManager
extends RefCounted

## 名將編成的純規則層。
##
## 本檔不繪圖、不播放音效、不切換畫面，也不依賴翻譯文字。
## 呼叫端傳入陣列，取得標準化結果後自行決定 UI、音效與提示。

const ACTIVE: StringName = &"active"
const RESERVE: StringName = &"reserve"
const CAMP: StringName = &"camp"
const UNKNOWN: StringName = &"unknown"

const MOVED: StringName = &"moved"
const REPLACED: StringName = &"replaced"
const ALREADY_ACTIVE: StringName = &"already_active"
const ALREADY_RESERVE: StringName = &"already_reserve"
const ALREADY_CAMP: StringName = &"already_camp"
const ACTIVE_FULL: StringName = &"active_full"
const RESERVE_FULL: StringName = &"reserve_full"
const INVALID_HERO: StringName = &"invalid_hero"
const INVALID_INDEX: StringName = &"invalid_index"


static func state_of(hid: String, active: Array, reserve: Array, camp: Array) -> StringName:
	if active.has(hid):
		return ACTIVE
	if reserve.has(hid):
		return RESERVE
	if camp.has(hid):
		return CAMP
	return UNKNOWN


static func move(
	hid: String,
	target: StringName,
	active: Array,
	reserve: Array,
	camp: Array,
	active_capacity: int,
	reserve_capacity: int
) -> Dictionary:
	match target:
		ACTIVE:
			return move_to_active(hid, active, reserve, camp, active_capacity)
		RESERVE:
			return move_to_reserve(hid, active, reserve, camp, reserve_capacity)
		CAMP:
			return move_to_camp(hid, active, reserve, camp)
	return _result(false, false, state_of(hid, active, reserve, camp), INVALID_HERO, hid)


static func move_to_reserve(
	hid: String,
	active: Array,
	reserve: Array,
	camp: Array,
	reserve_capacity: int
) -> Dictionary:
	if hid == "":
		return _result(false, false, UNKNOWN, INVALID_HERO, hid)
	if reserve.has(hid):
		return _result(true, false, RESERVE, ALREADY_RESERVE, hid)
	if reserve.size() >= max(0, reserve_capacity):
		return _result(false, false, state_of(hid, active, reserve, camp), RESERVE_FULL, hid)
	_remove_from_all(hid, active, reserve, camp)
	reserve.append(hid)
	return _result(true, true, RESERVE, MOVED, hid)


static func move_to_camp(hid: String, active: Array, reserve: Array, camp: Array) -> Dictionary:
	if hid == "":
		return _result(false, false, UNKNOWN, INVALID_HERO, hid)
	if camp.has(hid):
		return _result(true, false, CAMP, ALREADY_CAMP, hid)
	_remove_from_all(hid, active, reserve, camp)
	camp.append(hid)
	return _result(true, true, CAMP, MOVED, hid)


static func move_to_active(
	hid: String,
	active: Array,
	reserve: Array,
	camp: Array,
	active_capacity: int
) -> Dictionary:
	if hid == "":
		return _result(false, false, UNKNOWN, INVALID_HERO, hid)
	if active.has(hid):
		return _result(true, false, ACTIVE, ALREADY_ACTIVE, hid)
	if active.size() >= max(0, active_capacity):
		return _result(false, false, state_of(hid, active, reserve, camp), ACTIVE_FULL, hid)
	_remove_from_all(hid, active, reserve, camp)
	active.append(hid)
	return _result(true, true, ACTIVE, MOVED, hid)


static func replace_active(
	incoming_id: String,
	replace_index: int,
	active: Array,
	reserve: Array,
	camp: Array,
	reserve_capacity: int
) -> Dictionary:
	if incoming_id == "":
		return _result(false, false, UNKNOWN, INVALID_HERO, incoming_id)
	if replace_index < 0 or replace_index >= active.size():
		return _result(false, false, state_of(incoming_id, active, reserve, camp), INVALID_INDEX, incoming_id)
	var outgoing_id: String = str(active[replace_index])
	_remove_from_all(incoming_id, active, reserve, camp)
	active[replace_index] = incoming_id
	var outgoing_target: StringName = CAMP
	if reserve.size() < max(0, reserve_capacity):
		reserve.append(outgoing_id)
		outgoing_target = RESERVE
	else:
		camp.append(outgoing_id)
	return _result(true, true, ACTIVE, REPLACED, incoming_id, outgoing_id, outgoing_target)


static func replace_reserve(
	incoming_id: String,
	replace_index: int,
	active: Array,
	reserve: Array,
	camp: Array
) -> Dictionary:
	if incoming_id == "":
		return _result(false, false, UNKNOWN, INVALID_HERO, incoming_id)
	if replace_index < 0 or replace_index >= reserve.size():
		return _result(false, false, state_of(incoming_id, active, reserve, camp), INVALID_INDEX, incoming_id)
	var outgoing_id: String = str(reserve[replace_index])
	_remove_from_all(incoming_id, active, reserve, camp)
	reserve[replace_index] = incoming_id
	if not camp.has(outgoing_id):
		camp.append(outgoing_id)
	return _result(true, true, RESERVE, REPLACED, incoming_id, outgoing_id, CAMP)


static func place_in_support(
	hid: String,
	active: Array,
	reserve: Array,
	camp: Array,
	reserve_capacity: int
) -> StringName:
	_remove_from_all(hid, active, reserve, camp)
	if reserve.size() < max(0, reserve_capacity):
		reserve.append(hid)
		return RESERVE
	camp.append(hid)
	return CAMP


static func normalize(active: Array, reserve: Array, camp: Array) -> Dictionary:
	var seen: Dictionary = {}
	var removed_duplicates: Array[String] = []
	for group in [active, reserve, camp]:
		var clean: Array = []
		for value in group:
			var hid: String = str(value)
			if hid == "" or seen.has(hid):
				if hid != "" and not removed_duplicates.has(hid):
					removed_duplicates.append(hid)
				continue
			seen[hid] = true
			clean.append(hid)
		group.assign(clean)
	return {"ok": true, "removed_duplicates": removed_duplicates}


static func validate_roster(active: Array, reserve: Array, camp: Array) -> Dictionary:
	var seen: Dictionary = {}
	var duplicates: Array[String] = []
	var empty_entries: int = 0
	for group in [active, reserve, camp]:
		for value in group:
			var hid: String = str(value)
			if hid == "":
				empty_entries += 1
				continue
			if seen.has(hid) and not duplicates.has(hid):
				duplicates.append(hid)
			seen[hid] = true
	return {
		"ok": duplicates.is_empty() and empty_entries == 0,
		"duplicates": duplicates,
		"empty_entries": empty_entries,
		"total_unique": seen.size(),
	}


static func _remove_from_all(hid: String, active: Array, reserve: Array, camp: Array) -> void:
	active.erase(hid)
	reserve.erase(hid)
	camp.erase(hid)


static func _result(
	ok: bool,
	changed: bool,
	state: StringName,
	reason: StringName,
	hero_id: String,
	replaced_hero_id: String = "",
	replaced_target: StringName = UNKNOWN
) -> Dictionary:
	return {
		"ok": ok,
		"changed": changed,
		"state": state,
		"reason": reason,
		"hero_id": hero_id,
		"replaced_hero_id": replaced_hero_id,
		"replaced_target": replaced_target,
	}
