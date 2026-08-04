extends Node

## Alpha.20 Boss 階段執行層。
## Boss 血量降至 65% 與 35% 時進入新階段，強化攻擊節奏並產生明確預警。

const CatalogScript = preload("res://scripts/data/chapter_identity_catalog.gd")

var _main: Node = null
var _boss_key: String = ""
var _phase: int = 0


func _ready() -> void:
	_main = get_parent()
	set_process(true)


func _process(_delta: float) -> void:
	if _main == null or str(_main.get("screen")) != "game":
		return
	var boss_value: Variant = _main.get("boss")
	if not (boss_value is Dictionary):
		return
	var boss: Dictionary = boss_value as Dictionary
	if boss.is_empty() or float(boss.get("max_hp", 0.0)) <= 0.0:
		_boss_key = ""
		_phase = 0
		return
	var key: String = "%s:%d" % [str(boss.get("id", "boss")), int(float(boss.get("max_hp", 0.0)))]
	if key != _boss_key:
		_boss_key = key
		_phase = 0
	var ratio: float = float(boss.get("hp", 0.0)) / maxf(1.0, float(boss.get("max_hp", 1.0)))
	if ratio <= 0.35 and _phase < 2:
		_phase = 2
		_apply_phase(boss, 2)
	elif ratio <= 0.65 and _phase < 1:
		_phase = 1
		_apply_phase(boss, 1)


func _apply_phase(boss: Dictionary, phase: int) -> void:
	var chapter_index: int = _current_chapter_index()
	var profile_data: Dictionary = CatalogScript.profile(chapter_index)
	var base_damage_mult: float = float(profile_data.get("boss_phase_damage", 1.10))
	var damage_mult: float = base_damage_mult if phase == 1 else base_damage_mult + 0.08
	boss["damage"] = float(boss.get("damage", 1.0)) * damage_mult
	boss["attack_cd"] = maxf(0.35, float(boss.get("attack_cd", 1.5)) * (0.84 if phase == 1 else 0.74))
	boss["shoot_cd"] = maxf(0.35, float(boss.get("shoot_cd", 1.8)) * (0.86 if phase == 1 else 0.76))
	boss["ability_cd"] = maxf(0.55, float(boss.get("ability_cd", 3.0)) * (0.82 if phase == 1 else 0.70))
	boss["alpha20_phase"] = phase
	_main.set("boss", boss)
	_show_phase_message(phase, str(profile_data.get("name", "戰局")))
	_spawn_phase_warnings(boss, phase)
	_apply_history_consequence(boss, phase)


func _current_chapter_index() -> int:
	var manager: Variant = _main.get("chapter_manager")
	if manager != null and manager.has_method("current_index_value"):
		return maxi(0, int(manager.call("current_index_value")))
	return 0


func _show_phase_message(phase: int, chapter_name: String) -> void:
	if _main.has_method("show_boss_ability"):
		var text: String = "%s・敵將變陣" % chapter_name if phase == 1 else "%s・決死猛攻" % chapter_name
		_main.call("show_boss_ability", text, 2.2)
	elif _main.has_method("show_message"):
		_main.call("show_message", "Boss 進入第%d階段" % (phase + 1), 2.6)


func _spawn_phase_warnings(boss: Dictionary, phase: int) -> void:
	var zones_value: Variant = _main.get("zones")
	if not (zones_value is Array):
		return
	var zones: Array = zones_value as Array
	var pos_value: Variant = boss.get("pos", Vector2.ZERO)
	var center: Vector2 = pos_value if pos_value is Vector2 else Vector2.ZERO
	var count: int = 3 if phase == 1 else 5
	var radius: float = 115.0 if phase == 1 else 145.0
	for index in range(count):
		var angle: float = TAU * float(index) / float(count)
		zones.append({
			"kind": "enemy_warning",
			"pos": center + Vector2.from_angle(angle) * radius,
			"r": 54.0 + float(phase) * 10.0,
			"life": 1.05 + float(index) * 0.08,
			"damage": float(boss.get("damage", 10.0)) * (0.55 if phase == 1 else 0.72),
			"color": Color8(225, 116, 65) if phase == 1 else Color8(235, 75, 62),
		})
	_main.set("zones", zones)


func _apply_history_consequence(boss: Dictionary, phase: int) -> void:
	var flags_value: Variant = _main.get("history_flags")
	if not (flags_value is Dictionary):
		return
	var flags: Dictionary = flags_value as Dictionary
	var player_value: Variant = _main.get("player")
	if not (player_value is Dictionary):
		return
	var player: Dictionary = player_value as Dictionary
	if flags.has("three_heroes_challenge"):
		player["shield"] = float(player.get("shield", 0.0)) + 6.0 + float(phase) * 4.0
	if flags.has("wenji_return"):
		player["control_resist"] = maxf(float(player.get("control_resist", 0.0)), 0.20 + float(phase) * 0.05)
	if flags.has("fire_plan") or flags.has("red_cliff_fire"):
		boss["armor"] = maxf(0.0, float(boss.get("armor", 0.0)) - 0.6 - float(phase) * 0.3)
		_main.set("boss", boss)
	if flags.has("civilian_rescue"):
		player["hp"] = minf(float(player.get("max_hp", 1.0)), float(player.get("hp", 0.0)) + 5.0 + float(phase) * 3.0)
	_main.set("player", player)
