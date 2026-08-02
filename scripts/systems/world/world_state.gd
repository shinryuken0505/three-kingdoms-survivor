class_name WorldState
extends RefCounted

# V2.0 世界演化資料容器。Alpha 1 先建立穩定契約，後續再逐步從 main.gd 接線。
var momentum: Dictionary = {"蜀": 0, "魏": 0, "吳": 0, "群": 0}
var flags: Dictionary = {}
var omen_id: String = "balanced_chaos"

func reset() -> void:
	momentum = {"蜀": 0, "魏": 0, "吳": 0, "群": 0}
	flags.clear()
	omen_id = "balanced_chaos"

func apply_faction_shift(faction: String, amount: int) -> void:
	if not momentum.has(faction):
		return
	momentum[faction] = int(momentum[faction]) + amount

func dominant_faction() -> String:
	var best := ""
	var score := -999999
	for faction in momentum:
		if int(momentum[faction]) > score:
			best = str(faction)
			score = int(momentum[faction])
	return best

func serialize() -> Dictionary:
	return {"momentum": momentum.duplicate(true), "flags": flags.duplicate(true), "omen_id": omen_id}

func restore(data: Dictionary) -> void:
	momentum = (data.get("momentum", momentum) as Dictionary).duplicate(true)
	flags = (data.get("flags", {}) as Dictionary).duplicate(true)
	omen_id = str(data.get("omen_id", "balanced_chaos"))
