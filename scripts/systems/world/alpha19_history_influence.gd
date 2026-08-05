class_name Alpha19HistoryInfluence
extends RefCounted

static func evaluate(flags: Dictionary, route_tags: Dictionary, momentum: Dictionary, rewrite_rate: float) -> Dictionary:
	var damage_mult := 1.0
	var merchant_time_mult := 1.0
	var reinforcement := "中立"
	if bool(flags.get("protected_civilians", false)) or bool(route_tags.get("benevolent", false)):
		merchant_time_mult *= 0.90
		reinforcement = "民心援助"
	if bool(flags.get("accepted_ruthless_plan", false)) or bool(route_tags.get("ambition", false)):
		damage_mult *= 1.06
		reinforcement = "奇兵突擊"
	var best_faction := ""
	var best_value := -999.0
	for faction in momentum:
		if float(momentum[faction]) > best_value:
			best_value = float(momentum[faction])
			best_faction = str(faction)
	if best_value >= 3.0:
		damage_mult *= 1.025
		reinforcement = "%s援軍" % best_faction
	return {
		"damage_mult": damage_mult * (1.0 + clamp(rewrite_rate, 0.0, 1.0) * 0.04),
		"merchant_time_mult": merchant_time_mult,
		"reinforcement": reinforcement,
		"dominant_faction": best_faction,
	}
