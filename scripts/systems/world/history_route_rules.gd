class_name HistoryRouteRules
extends RefCounted

# Alpha.14：將歷史抉擇轉為可持續影響後續章節的勢力與改寫資料。
# 數值刻意小幅累積，避免單一選項直接鎖死整輪路線。

static func default_momentum() -> Dictionary:
	return {"蜀": 0, "魏": 0, "吳": 0, "群": 0}

static func impact_for(effect: String) -> Dictionary:
	var impacts: Dictionary = {
		"zhuo_relief": {"蜀": 2, "rewrite": 2, "tag": "people_first"},
		"zhuo_militia": {"群": 2, "rewrite": 1, "tag": "local_militia"},
		"zhuo_mercy": {"蜀": 4, "rewrite": 4, "tag": "benevolent_path"},
		"zhuo_oath": {"蜀": 4, "rewrite": 3, "tag": "taoyuan_oath"},
		"luoyang_rescue": {"蜀": 2, "rewrite": 3, "tag": "protect_han"},
		"luoyang_treasure": {"群": 3, "rewrite": 4, "tag": "seize_opportunity"},
		"luoyang_melody": {"群": 2, "rewrite": 4, "tag": "secret_escape"},
		"luoyang_guard_emperor": {"蜀": 3, "rewrite": 4, "tag": "protect_han"},
		"luoyang_false_order": {"魏": 2, "rewrite": 3, "tag": "stratagem"},
		"luoyang_diaochan_decoy": {"群": 3, "rewrite": 5, "tag": "diaochan_plot"},
		"hulao_vanguard": {"群": 3, "rewrite": 2, "tag": "coalition_vanguard"},
		"hulao_flank": {"蜀": 2, "rewrite": 1, "tag": "protect_allies"},
		"hulao_three_heroes": {"蜀": 5, "rewrite": 5, "tag": "three_heroes"},
		"hulao_sunjian_banner": {"吳": 4, "rewrite": 3, "tag": "jiangdong_tiger"},
		"xuzhou_people": {"蜀": 3, "rewrite": 2, "tag": "people_first"},
		"xuzhou_grain": {"魏": 2, "rewrite": 2, "tag": "military_supply"},
		"xuzhou_benevolent_route": {"蜀": 5, "rewrite": 4, "tag": "benevolent_path"},
		"xuzhou_truce": {"群": 3, "rewrite": 5, "tag": "halberd_truce"},
		"xuzhou_seize_arms": {"群": 3, "rewrite": 4, "tag": "seize_opportunity"},
		"xuzhou_lv_family": {"群": 4, "rewrite": 6, "tag": "flying_general_ties"},
		"guandu_raid": {"魏": 4, "rewrite": 3, "tag": "wuchao_raid"},
		"guandu_supply": {"魏": 2, "rewrite": 1, "tag": "steady_strategy"},
		"guandu_caocao": {"魏": 6, "rewrite": 4, "tag": "caocao_decision"},
		"guandu_accept_intel": {"魏": 3, "rewrite": 3, "tag": "xuyou_intel"},
		"guandu_verify_intel": {"魏": 2, "rewrite": 1, "tag": "steady_strategy"},
		"guandu_trust_talent": {"魏": 5, "rewrite": 4, "tag": "trust_talent"},
		"jingzhou_share_grain": {"蜀": 4, "rewrite": 3, "tag": "people_first"},
		"jingzhou_burn_grain": {"蜀": 2, "rewrite": 4, "tag": "scorched_earth"},
		"jingzhou_benevolent_convoy": {"蜀": 5, "rewrite": 5, "tag": "benevolent_path"},
		"jingzhou_people_first": {"蜀": 4, "rewrite": 4, "tag": "people_first"},
		"jingzhou_arms_first": {"魏": 3, "rewrite": 3, "tag": "military_supply"},
		"jingzhou_wu_route": {"吳": 6, "rewrite": 5, "tag": "jiangdong_route"},
		"changban_rescue_wounded": {"蜀": 3, "rewrite": 3, "tag": "people_first"},
		"changban_breakthrough": {"魏": 2, "rewrite": 3, "tag": "forced_march"},
		"changban_taoyuan_rescue": {"蜀": 6, "rewrite": 5, "tag": "three_heroes"},
		"changban_hold_bridge": {"蜀": 3, "rewrite": 3, "tag": "hold_bridge"},
		"changban_break_bridge": {"群": 2, "rewrite": 4, "tag": "break_history"},
		"changban_zhangfei_bridge": {"蜀": 5, "rewrite": 5, "tag": "zhangfei_bridge"}
	}
	return (impacts.get(effect, {}) as Dictionary).duplicate(true)

static func apply_impact(momentum: Dictionary, rewrite_rate: float, route_tags: Dictionary, effect: String) -> Dictionary:
	var result: Dictionary = {
		"momentum": momentum.duplicate(true),
		"rewrite_rate": rewrite_rate,
		"route_tags": route_tags.duplicate(true)
	}
	var impact: Dictionary = impact_for(effect)
	if impact.is_empty():
		return result
	var updated_momentum: Dictionary = (result.get("momentum", {}) as Dictionary).duplicate(true)
	for faction in ["蜀", "魏", "吳", "群"]:
		if impact.has(faction):
			updated_momentum[faction] = int(updated_momentum.get(faction, 0)) + int(impact[faction])
	result["momentum"] = updated_momentum
	result["rewrite_rate"] = clampf(float(rewrite_rate) + float(impact.get("rewrite", 0)), 0.0, 100.0)
	var tag: String = str(impact.get("tag", ""))
	if tag != "":
		result["route_tags"][tag] = int(result["route_tags"].get(tag, 0)) + 1
	return result

static func dominant_faction(momentum: Dictionary) -> String:
	var best: String = ""
	var best_score: int = -999999
	for faction in ["蜀", "魏", "吳", "群"]:
		var score: int = int(momentum.get(faction, 0))
		if score > best_score:
			best = faction
			best_score = score
	return best

static func rewrite_tier(rewrite_rate: float) -> String:
	if rewrite_rate >= 60.0:
		return "異聞線"
	if rewrite_rate >= 35.0:
		return "分歧線"
	if rewrite_rate >= 15.0:
		return "微改線"
	return "史實線"

static func route_summary(momentum: Dictionary, rewrite_rate: float) -> String:
	var dominant: String = dominant_faction(momentum)
	var faction_names: Dictionary = {"蜀":"蜀漢", "魏":"曹魏", "吳":"東吳", "群":"群雄"}
	var faction_name: String = str(faction_names.get(dominant, "群雄"))
	return "%s傾向｜%s %d%%" % [faction_name, rewrite_tier(rewrite_rate), int(round(rewrite_rate))]
