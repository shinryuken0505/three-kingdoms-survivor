extends Control

const MAX_LEVEL: int = 8
const PROFILE: Dictionary = {
	"guanyu": {"name":"武聖斬威", "cooldown_per_level":0.025, "active_damage":0.055, "reserve_damage":0.012},
	"zhangfei": {"name":"燕人震喝", "cooldown_per_level":0.018, "active_damage":0.040, "reserve_control":0.018},
	"zhaoyun": {"name":"龍膽連突", "cooldown_per_level":0.032, "active_speed":0.018, "reserve_speed":0.008},
	"zhugeliang": {"name":"臥龍術陣", "cooldown_per_level":0.042, "active_damage":0.025, "reserve_cooldown":0.010},
	"huatuo": {"name":"青囊濟世", "cooldown_per_level":0.035, "active_heal":0.045, "reserve_regen":0.010},
	"diaochan": {"name":"閉月惑心", "cooldown_per_level":0.030, "active_damage":0.020, "reserve_control":0.014},
	"sunshangxiang": {"name":"弓腰連射", "cooldown_per_level":0.028, "active_damage":0.040, "reserve_damage":0.009},
	"caocao": {"name":"魏武統御", "cooldown_per_level":0.030, "active_damage":0.032, "reserve_damage":0.015},
	"lvbu": {"name":"無雙亂舞", "cooldown_per_level":0.018, "active_damage":0.065, "reserve_damage":0.008},
	"liubei": {"name":"仁德號令", "cooldown_per_level":0.028, "active_heal":0.025, "reserve_regen":0.008},
	"zhouyu": {"name":"赤焰都督", "cooldown_per_level":0.034, "active_damage":0.045, "reserve_cooldown":0.008},
	"huangzhong": {"name":"百步穿楊", "cooldown_per_level":0.026, "active_damage":0.050, "reserve_damage":0.010},
}

var host: Variant = null
var previous_levels: Dictionary = {}
var previous_cooldowns: Dictionary = {}
var level_notice: Dictionary = {}
var passive_snapshot: Dictionary = {}
var tick_accum: float = 0.0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	host = get_tree().current_scene
	if host == null or not is_instance_valid(host):
		visible = false
		return
	var screen_name: String = str(host.get("screen"))
	visible = screen_name == "game"
	if not level_notice.is_empty():
		level_notice["time"] = max(0.0, float(level_notice.get("time", 0.0)) - delta)
		if float(level_notice.get("time", 0.0)) <= 0.0:
			level_notice.clear()
	if screen_name not in ["game", "hero_config", "tab", "camp_menu"]:
		queue_redraw()
		return
	tick_accum += delta
	apply_active_cooldown_growth(delta)
	if tick_accum >= 0.25:
		tick_accum = 0.0
		detect_level_ups()
		apply_reserve_passives()
	queue_redraw()

func compact_id(hero_id: String) -> String:
	return hero_id.to_lower().replace("_", "").replace("-", "")

func hero_level(hero_id: String) -> int:
	var levels: Dictionary = host.get("hero_skill_levels") as Dictionary
	return clampi(int(levels.get(hero_id, 1)), 1, MAX_LEVEL)

func profile(hero_id: String) -> Dictionary:
	return PROFILE.get(compact_id(hero_id), {"name":"名將精進", "cooldown_per_level":0.022, "active_damage":0.025, "reserve_damage":0.006}) as Dictionary

func apply_active_cooldown_growth(delta: float) -> void:
	var active: Array = host.get("active_heroes") as Array
	var cooldowns: Dictionary = host.get("hero_cooldowns") as Dictionary
	for value in active:
		var hero_id: String = str(value)
		var level: int = hero_level(hero_id)
		if level <= 1:
			continue
		var current: float = max(0.0, float(cooldowns.get(hero_id, 0.0)))
		if current <= 0.0:
			continue
		var p: Dictionary = profile(hero_id)
		var extra_rate: float = clamp(float(p.get("cooldown_per_level", 0.022)) * float(level - 1), 0.0, 0.32)
		cooldowns[hero_id] = max(0.0, current - delta * extra_rate)
	host.set("hero_cooldowns", cooldowns)

func apply_reserve_passives() -> void:
	var reserve: Array = host.get("reserve_heroes") as Array
	var damage_bonus: float = 0.0
	var speed_bonus: float = 0.0
	var cooldown_bonus: float = 0.0
	var regen_bonus: float = 0.0
	var control_bonus: float = 0.0
	for value in reserve:
		var hero_id: String = str(value)
		var level_factor: float = float(max(0, hero_level(hero_id) - 1))
		var p: Dictionary = profile(hero_id)
		damage_bonus += float(p.get("reserve_damage", 0.0)) * level_factor
		speed_bonus += float(p.get("reserve_speed", 0.0)) * level_factor
		cooldown_bonus += float(p.get("reserve_cooldown", 0.0)) * level_factor
		regen_bonus += float(p.get("reserve_regen", 0.0)) * level_factor
		control_bonus += float(p.get("reserve_control", 0.0)) * level_factor
	passive_snapshot = {
		"damage": clamp(damage_bonus, 0.0, 0.30),
		"speed": clamp(speed_bonus, 0.0, 0.18),
		"cooldown": clamp(cooldown_bonus, 0.0, 0.18),
		"regen": clamp(regen_bonus, 0.0, 0.12),
		"control": clamp(control_bonus, 0.0, 0.20),
	}
	var player: Dictionary = host.get("player") as Dictionary
	if player.is_empty():
		return
	player["alpha39_reserve_damage_mult"] = 1.0 + float(passive_snapshot["damage"])
	player["alpha39_reserve_speed_mult"] = 1.0 + float(passive_snapshot["speed"])
	player["alpha39_reserve_cooldown_mult"] = 1.0 - float(passive_snapshot["cooldown"])
	player["alpha39_reserve_regen"] = float(passive_snapshot["regen"])
	player["alpha39_reserve_control"] = float(passive_snapshot["control"])
	host.set("player", player)

func detect_level_ups() -> void:
	var levels: Dictionary = host.get("hero_skill_levels") as Dictionary
	for hero_value in levels.keys():
		var hero_id: String = str(hero_value)
		var level: int = clampi(int(levels[hero_id]), 1, MAX_LEVEL)
		var previous: int = int(previous_levels.get(hero_id, level))
		if level > previous:
			show_level_notice(hero_id, level)
		previous_levels[hero_id] = level

func show_level_notice(hero_id: String, level: int) -> void:
	var heroes: Dictionary = host.get("heroes") as Dictionary
	var hero_name: String = str(heroes.get(hero_id, {}).get("name", hero_id))
	level_notice = {
		"hero_id":hero_id,
		"name":hero_name,
		"level":level,
		"signature":str(profile(hero_id).get("name", "名將精進")),
		"time":3.0,
	}
	if host.has_method("play_sfx"):
		host.call("play_sfx", "levelup")

func portrait(hero_id: String) -> Texture2D:
	var portraits: Dictionary = host.get("portrait_tex") as Dictionary
	if portraits.has(hero_id) and portraits[hero_id] is Texture2D:
		return portraits[hero_id] as Texture2D
	return null

func _draw() -> void:
	if not visible or host == null:
		return
	var active: Array = host.get("active_heroes") as Array
	var cooldowns: Dictionary = host.get("hero_cooldowns") as Dictionary
	var slot_count: int = min(3, active.size())
	var card_w: float = 118.0
	var gap: float = 12.0
	var total_w: float = float(slot_count) * card_w + float(max(0, slot_count - 1)) * gap
	var start_x: float = 640.0 - total_w * 0.5
	for index in range(slot_count):
		var hero_id: String = str(active[index])
		var rect: Rect2 = Rect2(start_x + float(index) * (card_w + gap), 619.0, card_w, 66.0)
		var tex: Texture2D = portrait(hero_id)
		if tex != null:
			draw_texture_rect(tex, Rect2(rect.position + Vector2(4, 4), Vector2(48, 48)), false)
		var cooldown: float = max(0.0, float(cooldowns.get(hero_id, 0.0)))
		if cooldown > 0.0:
			draw_rect(Rect2(rect.position + Vector2(4, 4), Vector2(48, 48)), Color(0.02, 0.025, 0.03, 0.68), true)
			draw_string(ThemeDB.fallback_font, rect.position + Vector2(7, 35), "%.1f" % cooldown, HORIZONTAL_ALIGNMENT_CENTER, 42, 14, Color.WHITE)
		else:
			draw_rect(Rect2(rect.position + Vector2(3, 3), Vector2(50, 50)), Color(0.90, 0.73, 0.26, 0.82), false, 2.0)
		var heroes: Dictionary = host.get("heroes") as Dictionary
		var hero_name: String = str(heroes.get(hero_id, {}).get("name", hero_id))
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(56, 22), hero_name, HORIZONTAL_ALIGNMENT_LEFT, 58, 12, Color8(238, 225, 196))
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(56, 41), "Lv.%d" % hero_level(hero_id), HORIZONTAL_ALIGNMENT_LEFT, 58, 11, Color8(205, 169, 83))
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(56, 57), str(profile(hero_id).get("name", "精進")), HORIZONTAL_ALIGNMENT_LEFT, 58, 9, Color8(157, 190, 184))
	if not level_notice.is_empty():
		var alpha: float = clamp(float(level_notice.get("time", 0.0)), 0.0, 1.0)
		var panel: Rect2 = Rect2(420, 174, 440, 104)
		draw_rect(panel, Color(0.035, 0.03, 0.018, 0.94 * alpha), true)
		draw_rect(panel, Color(0.94, 0.72, 0.25, alpha), false, 2.0)
		draw_string(ThemeDB.fallback_font, Vector2(640, 207), "名將成長", HORIZONTAL_ALIGNMENT_CENTER, 420, 18, Color(1.0, 0.86, 0.48, alpha))
		draw_string(ThemeDB.fallback_font, Vector2(640, 235), "%s　Lv.%d" % [str(level_notice.get("name", "名將")), int(level_notice.get("level", 1))], HORIZONTAL_ALIGNMENT_CENTER, 420, 22, Color(1.0, 0.96, 0.84, alpha))
		draw_string(ThemeDB.fallback_font, Vector2(640, 259), str(level_notice.get("signature", "專屬能力提升")), HORIZONTAL_ALIGNMENT_CENTER, 420, 13, Color(0.72, 0.86, 0.82, alpha))
