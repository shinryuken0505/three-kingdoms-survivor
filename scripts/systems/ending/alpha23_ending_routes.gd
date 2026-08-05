class_name Alpha23EndingRoutes
extends RefCounted

const ENDINGS := {
	"benevolent_guardian": {
		"title":"仁者守世",
		"route":"benevolence",
		"description":"你沒有稱帝，卻讓無數百姓在亂世中記住了你的名字。",
		"priority":80
	},
	"ambitious_overlord": {
		"title":"亂世霸王",
		"route":"ambition",
		"description":"你以勝利壓服群雄，史書從此以你的年代重新起筆。",
		"priority":90
	},
	"loyal_last_light": {
		"title":"漢室孤光",
		"route":"loyalty",
		"description":"天下終究改姓，但你守到最後的忠義成為後世傳說。",
		"priority":85
	},
	"survivor_beyond_history": {
		"title":"史外餘生",
		"route":"survival",
		"description":"你看盡英雄成敗，最後帶著自己的故事離開史冊。",
		"priority":70
	},
	"balanced_wanderer": {
		"title":"無名遊俠",
		"route":"balanced",
		"description":"你未投向任何旗幟，也沒有讓任何旗幟完全定義你。",
		"priority":50
	},
	"people_emperor": {
		"title":"民心所歸",
		"route":"benevolence",
		"description":"仁義與實力同時抵達巔峰，百姓推舉你建立新的天下。",
		"priority":120
	},
	"unifier": {
		"title":"天下歸一",
		"route":"ambition",
		"description":"所有對手都已倒下，九州只剩你的一面旗幟。",
		"priority":125
	}
}

static func resolve(route_state: Dictionary, run_summary: Dictionary) -> Dictionary:
	var route_id := str(route_state.get("dominant", "balanced"))
	var completed := bool(run_summary.get("completed", false))
	var bosses := int(run_summary.get("bosses", run_summary.get("boss_kills", 0)))
	var saved_civilians := int(run_summary.get("saved_civilians", 0))
	var candidate_id := "balanced_wanderer"
	if completed and route_id == "benevolence" and saved_civilians >= 3:
		candidate_id = "people_emperor"
	elif completed and route_id == "ambition" and bosses >= 8:
		candidate_id = "unifier"
	elif route_id == "benevolence":
		candidate_id = "benevolent_guardian"
	elif route_id == "ambition":
		candidate_id = "ambitious_overlord"
	elif route_id == "loyalty":
		candidate_id = "loyal_last_light"
	elif route_id == "survival":
		candidate_id = "survivor_beyond_history"
	var result: Dictionary = ENDINGS[candidate_id].duplicate(true)
	result["id"] = candidate_id
	result["route_scores"] = route_state.get("scores", {}).duplicate(true)
	result["completed"] = completed
	return result

static func all_endings() -> Array:
	var result: Array = []
	for ending_id in ENDINGS:
		var item: Dictionary = ENDINGS[ending_id].duplicate(true)
		item["id"] = ending_id
		result.append(item)
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("priority", 0)) > int(b.get("priority", 0)))
	return result
