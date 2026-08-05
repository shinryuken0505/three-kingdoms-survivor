class_name Alpha23RouteResolver
extends RefCounted

const ROUTES := ["benevolence", "ambition", "loyalty", "survival"]

static func new_state() -> Dictionary:
	return {
		"scores": {
			"benevolence": 0,
			"ambition": 0,
			"loyalty": 0,
			"survival": 0
		},
		"dominant": "balanced",
		"choices": [],
		"flags": {},
		"chapter_variants": {}
	}

static func apply_choice(state: Dictionary, choice_id: String, effects: Dictionary) -> Dictionary:
	var next: Dictionary = state.duplicate(true)
	if next.is_empty():
		next = new_state()
	var scores: Dictionary = next.get("scores", {}).duplicate(true)
	for route_id in ROUTES:
		scores[route_id] = int(scores.get(route_id, 0)) + int(effects.get(route_id, 0))
	next["scores"] = scores
	var choices: Array = next.get("choices", []).duplicate()
	choices.append(choice_id)
	next["choices"] = choices
	var flags: Dictionary = next.get("flags", {}).duplicate(true)
	for flag_value in effects.get("flags", []):
		flags[str(flag_value)] = true
	next["flags"] = flags
	next["dominant"] = dominant_route(scores)
	return next

static func dominant_route(scores: Dictionary) -> String:
	var best_id := "balanced"
	var best_score := 0
	var tied := false
	for route_id in ROUTES:
		var score := int(scores.get(route_id, 0))
		if score > best_score:
			best_id = route_id
			best_score = score
			tied = false
		elif score == best_score and score > 0:
			tied = true
	return "balanced" if tied or best_score <= 0 else best_id

static func chapter_variant(chapter_id: String, state: Dictionary) -> Dictionary:
	var dominant := str(state.get("dominant", "balanced"))
	var flags: Dictionary = state.get("flags", {})
	var result := {
		"chapter_id": chapter_id,
		"route": dominant,
		"ally": "",
		"ambush": false,
		"boss_modifier": "standard",
		"label": "史勢未定"
	}
	match chapter_id:
		"xuzhou":
			if dominant == "benevolence":
				result.merge({"ally":"civilian_militia", "label":"百姓相助"}, true)
			elif dominant == "ambition":
				result.merge({"ambush":true, "boss_modifier":"enraged", "label":"強奪徐州"}, true)
		"guandu":
			if bool(flags.get("protected_supplies", false)):
				result.merge({"ally":"supply_guard", "label":"糧道無虞"}, true)
			elif dominant == "survival":
				result.merge({"ambush":true, "label":"暗渡官渡"}, true)
		"changban":
			if dominant == "benevolence":
				result.merge({"ally":"zhao_yun", "boss_modifier":"delayed", "label":"回身救民"}, true)
			elif dominant == "survival":
				result.merge({"boss_modifier":"pursuit", "label":"棄民突圍"}, true)
		"red_cliffs":
			if dominant == "loyalty":
				result.merge({"ally":"allied_fleet", "boss_modifier":"fire_vulnerable", "label":"孫劉同盟"}, true)
			elif dominant == "ambition":
				result.merge({"ambush":true, "boss_modifier":"double_cross", "label":"借火奪勢"}, true)
		"yiling":
			if dominant == "loyalty":
				result.merge({"boss_modifier":"vengeance", "label":"為義復仇"}, true)
			elif dominant == "benevolence":
				result.merge({"ally":"peace_envoy", "boss_modifier":"hesitant", "label":"止戈之議"}, true)
		"wuzhang":
			result["label"] = ending_route_label(dominant)
	return result

static func ending_route_label(route_id: String) -> String:
	match route_id:
		"benevolence": return "仁者之世"
		"ambition": return "霸王之途"
		"loyalty": return "漢室孤忠"
		"survival": return "亂世餘生"
		_: return "無名史頁"
