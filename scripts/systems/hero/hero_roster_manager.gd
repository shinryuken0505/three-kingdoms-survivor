extends RefCounted

# 名將編成資料操作集中於此，避免 main.gd 同時維護多套主戰／後備／營地邏輯。

static func state_of(hid: String, active: Array, reserve: Array, camp: Array) -> String:
	if active.has(hid):
		return "active"
	if reserve.has(hid):
		return "reserve"
	if camp.has(hid):
		return "camp"
	return "unknown"


static func move_to_reserve(
	hid: String,
	active: Array,
	reserve: Array,
	camp: Array,
	reserve_capacity: int
) -> Dictionary:
	if reserve.has(hid):
		return {"ok": true, "changed": false, "state": "reserve", "reason": "already_reserve"}
	if reserve.size() >= reserve_capacity:
		return {"ok": false, "changed": false, "state": state_of(hid, active, reserve, camp), "reason": "reserve_full"}
	active.erase(hid)
	camp.erase(hid)
	reserve.append(hid)
	return {"ok": true, "changed": true, "state": "reserve", "reason": "moved"}


static func move_to_camp(hid: String, active: Array, reserve: Array, camp: Array) -> Dictionary:
	if camp.has(hid):
		return {"ok": true, "changed": false, "state": "camp", "reason": "already_camp"}
	active.erase(hid)
	reserve.erase(hid)
	camp.append(hid)
	return {"ok": true, "changed": true, "state": "camp", "reason": "moved"}


static func move_to_active(
	hid: String,
	active: Array,
	reserve: Array,
	camp: Array,
	active_capacity: int
) -> Dictionary:
	if active.has(hid):
		return {"ok": true, "changed": false, "state": "active", "reason": "already_active"}
	if active.size() >= active_capacity:
		return {"ok": false, "changed": false, "state": state_of(hid, active, reserve, camp), "reason": "active_full"}
	reserve.erase(hid)
	camp.erase(hid)
	active.append(hid)
	return {"ok": true, "changed": true, "state": "active", "reason": "moved"}


static func place_in_support(
	hid: String,
	active: Array,
	reserve: Array,
	camp: Array,
	reserve_capacity: int
) -> String:
	active.erase(hid)
	reserve.erase(hid)
	camp.erase(hid)
	if reserve.size() < reserve_capacity:
		reserve.append(hid)
		return "reserve"
	camp.append(hid)
	return "camp"


static func validate_roster(active: Array, reserve: Array, camp: Array) -> Dictionary:
	var seen: Dictionary = {}
	var duplicates: Array[String] = []
	for group in [active, reserve, camp]:
		for value in group:
			var hid: String = str(value)
			if seen.has(hid) and not duplicates.has(hid):
				duplicates.append(hid)
			seen[hid] = true
	return {"ok": duplicates.is_empty(), "duplicates": duplicates}
