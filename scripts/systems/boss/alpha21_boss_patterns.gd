class_name Alpha21BossPatterns
extends RefCounted

const DEFAULT_PATTERN := {
	"phase_two_hp": 0.50,
	"weakness_window": 1.8,
	"moves": ["sweep", "charge"],
	"ultimate": "war_cry",
	"phase_two": "frenzy",
}

const PATTERNS := {
	"zhangjiao": {"phase_two_hp":0.55,"weakness_window":2.2,"moves":["lightning_mark","yellow_turban_wave"],"ultimate":"heaven_thunder","phase_two":"storm_altar"},
	"lvbu": {"phase_two_hp":0.50,"weakness_window":1.45,"moves":["halberd_sweep","pursuit_dash","red_hare_charge"],"ultimate":"peerless_assault","phase_two":"flying_general"},
	"caocao": {"phase_two_hp":0.52,"weakness_window":1.75,"moves":["crossbow_order","cavalry_pincer"],"ultimate":"tiger_leopard_charge","phase_two":"commanding_aura"},
	"yuanshao": {"phase_two_hp":0.48,"weakness_window":2.0,"moves":["arrow_wall","elite_guard"],"ultimate":"ten_thousand_arrows","phase_two":"noble_rage"},
	"huangzhong": {"phase_two_hp":0.50,"weakness_window":2.35,"moves":["triple_shot","backstep","marked_arrow_rain"],"ultimate":"master_marksman","phase_two":"old_general_focus"},
	"zhouyu": {"phase_two_hp":0.45,"weakness_window":1.9,"moves":["fire_line","flame_zone"],"ultimate":"red_cliffs_inferno","phase_two":"east_wind"},
}

static func pattern(boss_id: String) -> Dictionary:
	return PATTERNS.get(boss_id, DEFAULT_PATTERN).duplicate(true)

static func phase_for_hp(boss_id: String, hp_ratio: float) -> int:
	var data: Dictionary = pattern(boss_id)
	return 2 if hp_ratio <= float(data.get("phase_two_hp", 0.5)) else 1

static func next_move(boss_id: String, sequence_index: int, hp_ratio: float) -> String:
	var data: Dictionary = pattern(boss_id)
	var moves: Array = data.get("moves", [])
	if moves.is_empty():
		return "sweep"
	if phase_for_hp(boss_id, hp_ratio) == 2 and sequence_index % 4 == 3:
		return str(data.get("ultimate", "war_cry"))
	return str(moves[posmod(sequence_index, moves.size())])

static func weakness_window(boss_id: String, interrupted: bool = false) -> float:
	var base: float = float(pattern(boss_id).get("weakness_window", 1.8))
	return base * (1.35 if interrupted else 1.0)

static func phase_label(boss_id: String, hp_ratio: float) -> String:
	var data: Dictionary = pattern(boss_id)
	if phase_for_hp(boss_id, hp_ratio) == 2:
		return str(data.get("phase_two", "frenzy"))
	return "opening"
