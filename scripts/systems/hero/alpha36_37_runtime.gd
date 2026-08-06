extends Control

const SAVE_PATH: String = "user://alpha36_37_progress.cfg"
const MAX_HERO_LEVEL: int = 8
const ACTIVE_XP_RATE: float = 1.0
const RESERVE_XP_RATE: float = 0.45

var host: Variant = null
var state: Dictionary = {
	"recruit_visits": 0,
	"recruit_cap": 3,
	"last_encounter": "",
	"known_count": 0,
	"last_kills": 0,
	"last_boss_total": 0,
}
var hero_xp: Dictionary = {}
var loaded_for_run: bool = false

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_progress()

func _process(_delta: float) -> void:
	host = get_tree().current_scene
	if host == null or not is_instance_valid(host):
		visible = false
		return
	var screen_name: String = str(host.get("screen"))
	var player_data: Dictionary = host.get("player") as Dictionary
	visible = screen_name == "game" and not player_data.is_empty()
	if not visible:
		return
	if not loaded_for_run:
		state["recruit_cap"] = clampi(int(state.get("recruit_cap", 2 + randi() % 4)), 2, 5)
		loaded_for_run = true
	apply_roster_limits()
	update_recruitment()
	update_hero_experience()
	queue_redraw()

func current_chapter_number() -> int:
	if host != null and host.has_method("current_chapter"):
		var chapter: Dictionary = host.call("current_chapter") as Dictionary
		return int(chapter.get("index", 0)) + 1
	return 1

func active_limit() -> int:
	return 2 if current_chapter_number() <= 1 else 3

func reserve_limit() -> int:
	return 1 if current_chapter_number() <= 1 else 2

func apply_roster_limits() -> void:
	var active: Array = host.get("active_heroes") as Array
	var reserve: Array = host.get("reserve_heroes") as Array
	var camp: Array = host.get("camp_heroes") as Array
	while active.size() > active_limit():
		var moved: String = str(active.pop_back())
		if reserve.size() < reserve_limit():
			reserve.append(moved)
		elif not camp.has(moved):
			camp.append(moved)
	while reserve.size() > reserve_limit():
		var moved: String = str(reserve.pop_back())
		if not camp.has(moved):
			camp.append(moved)
	host.set("active_heroes", active)
	host.set("reserve_heroes", reserve)
	host.set("camp_heroes", camp)

func update_recruitment() -> void:
	var encounter: String = str(host.get("current_encounter"))
	var previous: String = str(state.get("last_encounter", ""))
	var known: Dictionary = host.get("known_heroes") as Dictionary
	var known_count: int = known.size()
	if previous == "" and encounter != "":
		state["recruit_visits"] = int(state.get("recruit_visits", 0)) + 1
		host.set("hero_spawn_timer", randf_range(105.0, 165.0))
	if previous != "" and encounter == "" and known_count > int(state.get("known_count", 0)):
		if host.has_method("open_hero_config"):
			host.call_deferred("open_hero_config", "game")
	if int(state.get("recruit_visits", 0)) >= clampi(int(state.get("recruit_cap", 3)), 2, 5) and encounter == "":
		host.set("hero_spawn_timer", max(9999.0, float(host.get("hero_spawn_timer"))))
	state["last_encounter"] = encounter
	state["known_count"] = known_count

func update_hero_experience() -> void:
	var run_stats: Dictionary = host.get("run_stats") as Dictionary
	var kills: int = int(run_stats.get("kills", 0))
	var boss_counts: Dictionary = host.get("boss_defeat_counts") as Dictionary
	var boss_total: int = 0
	for value in boss_counts.values():
		boss_total += int(value)
	var kill_delta: int = max(0, kills - int(state.get("last_kills", kills)))
	var boss_delta: int = max(0, boss_total - int(state.get("last_boss_total", boss_total)))
	state["last_kills"] = kills
	state["last_boss_total"] = boss_total
	if kill_delta <= 0 and boss_delta <= 0:
		return
	var gained: int = kill_delta + boss_delta * 35
	var active: Array = host.get("active_heroes") as Array
	var reserve: Array = host.get("reserve_heroes") as Array
	for hero_value in active:
		grant_xp(str(hero_value), int(round(float(gained) * ACTIVE_XP_RATE)))
	for hero_value in reserve:
		grant_xp(str(hero_value), int(round(float(gained) * RESERVE_XP_RATE)))
	save_progress()

func required_xp(level: int) -> int:
	return 24 + max(0, level - 1) * 18

func hero_level(hero_id: String) -> int:
	var levels: Dictionary = host.get("hero_skill_levels") as Dictionary
	return clampi(int(levels.get(hero_id, 1)), 1, MAX_HERO_LEVEL)

func grant_xp(hero_id: String, amount: int) -> void:
	if hero_id == "" or amount <= 0:
		return
	if host.has_method("initialize_hero_progress"):
		host.call("initialize_hero_progress", hero_id)
	var levels: Dictionary = host.get("hero_skill_levels") as Dictionary
	var level: int = hero_level(hero_id)
	var xp: int = int(hero_xp.get(hero_id, 0)) + amount
	while level < MAX_HERO_LEVEL and xp >= required_xp(level):
		xp -= required_xp(level)
		level += 1
		levels[hero_id] = level
		var cooldowns: Dictionary = host.get("hero_cooldowns") as Dictionary
		cooldowns[hero_id] = 0.0
		host.set("hero_cooldowns", cooldowns)
		var heroes: Dictionary = host.get("heroes") as Dictionary
		var hero_name: String = str((heroes.get(hero_id, {}) as Dictionary).get("name", hero_id))
		if host.has_method("show_message"):
			host.call("show_message", "%s成長至 Lv.%d" % [hero_name, level], 2.4)
	host.set("hero_skill_levels", levels)
	hero_xp[hero_id] = 0 if level >= MAX_HERO_LEVEL else xp

func save_progress() -> void:
	var config := ConfigFile.new()
	config.set_value("progress", "hero_xp", hero_xp)
	config.set_value("progress", "state", state)
	config.save(SAVE_PATH)

func load_progress() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		state["recruit_cap"] = 2 + randi() % 4
		return
	hero_xp = (config.get_value("progress", "hero_xp", {}) as Dictionary).duplicate(true)
	state = (config.get_value("progress", "state", state) as Dictionary).duplicate(true)

func _draw() -> void:
	if not visible or host == null:
		return
	var fallback_font: Font = ThemeDB.fallback_font
	# 完整遮蔽舊上方與下方HUD，再重新繪製整合版。
	draw_rect(Rect2(0, 0, 1280, 160), Color(0.015, 0.02, 0.023, 0.97), true)
	draw_rect(Rect2(0, 606, 1280, 114), Color(0.015, 0.02, 0.023, 0.97), true)
	var chapter: Dictionary = host.call("current_chapter") as Dictionary if host.has_method("current_chapter") else {}
	var chapter_name: String = str(chapter.get("name", chapter.get("title", "戰場")))
	draw_panel_box(Rect2(300, 12, 680, 48), Color8(126, 112, 78))
	draw_label(fallback_font, "第%d關｜%s" % [current_chapter_number(), chapter_name], Vector2(320, 43), 18, Color8(236, 220, 176))
	var elapsed: float = float(host.get("elapsed"))
	draw_label(fallback_font, "%02d:%02d" % [int(elapsed) / 60, int(elapsed) % 60], Vector2(888, 43), 16, Color8(196, 204, 202))
	var boss_spawned: bool = bool(host.get("boss_spawned"))
	var boss: Dictionary = host.get("boss") as Dictionary
	if boss_spawned and not boss.is_empty():
		draw_panel_box(Rect2(350, 72, 580, 50), Color8(178, 67, 58))
		var boss_hp: float = float(boss.get("hp", 0.0))
		var boss_max: float = max(1.0, float(boss.get("max_hp", 1.0)))
		var ratio: float = clamp(boss_hp / boss_max, 0.0, 1.0)
		draw_label(fallback_font, str(boss.get("name", "Boss")), Vector2(366, 94), 14, Color8(245, 220, 198))
		draw_rect(Rect2(366, 102, 548, 9), Color8(49, 29, 31), true)
		draw_rect(Rect2(366, 102, 548 * ratio, 9), Color8(190, 55, 49), true)
	draw_panel_box(Rect2(52, 614, 1176, 88), Color8(105, 109, 102))
	var player: Dictionary = host.get("player") as Dictionary
	var identities: Dictionary = host.get("identities") as Dictionary
	var identity_id: String = str(host.get("chosen_identity"))
	var identity_name: String = str((identities.get(identity_id, {}) as Dictionary).get("name", identity_id))
	draw_label(fallback_font, "%s Lv.%d" % [identity_name, int(player.get("level", 1))], Vector2(68, 638), 15, Color8(236, 220, 176))
	var hp_ratio: float = clamp(float(player.get("hp", 0.0)) / max(1.0, float(player.get("max_hp", 1.0))), 0.0, 1.0)
	draw_rect(Rect2(68, 647, 184, 9), Color8(52, 37, 34), true)
	draw_rect(Rect2(68, 647, 184 * hp_ratio, 9), Color8(185, 58, 54), true)
	var xp_ratio: float = clamp(float(player.get("xp", 0.0)) / max(1.0, float(player.get("xp_need", player.get("next_xp", 100.0)))), 0.0, 1.0)
	draw_rect(Rect2(68, 662, 184, 6), Color8(37, 43, 46), true)
	draw_rect(Rect2(68, 662, 184 * xp_ratio, 6), Color8(76, 151, 196), true)
	var dash_left: float = max(0.0, float(player.get("dash_timer", 0.0)))
	draw_label(fallback_font, "閃避 %s" % ("可用" if dash_left <= 0.0 else "%.1fs" % dash_left), Vector2(270, 654), 13, Color8(111, 215, 225) if dash_left <= 0.0 else Color8(190, 177, 143))
	var active: Array = host.get("active_heroes") as Array
	var heroes: Dictionary = host.get("heroes") as Dictionary
	var cooldowns: Dictionary = host.get("hero_cooldowns") as Dictionary
	for slot in range(active_limit()):
		var x: float = 390.0 + float(slot) * 148.0
		draw_rect(Rect2(x, 626, 136, 58), Color(0.04, 0.05, 0.055, 0.96), true)
		draw_rect(Rect2(x, 626, 136, 58), Color8(105, 109, 102), false, 1.0)
		if slot < active.size():
			var hero_id: String = str(active[slot])
			var hero_name: String = str((heroes.get(hero_id, {}) as Dictionary).get("name", hero_id))
			var level: int = hero_level(hero_id)
			var cooldown: float = max(0.0, float(cooldowns.get(hero_id, 0.0)))
			draw_label(fallback_font, "%d %s Lv.%d" % [slot + 1, hero_name, level], Vector2(x + 8, 647), 12, Color8(230, 222, 199))
			draw_label(fallback_font, "技能 %s" % ("可用" if cooldown <= 0.0 else "%.1fs" % cooldown), Vector2(x + 8, 665), 10, Color8(123, 207, 180) if cooldown <= 0.0 else Color8(178, 169, 148))
			var hero_ratio: float = 1.0 if level >= MAX_HERO_LEVEL else clamp(float(hero_xp.get(hero_id, 0)) / float(required_xp(level)), 0.0, 1.0)
			draw_rect(Rect2(x + 8, 674, 120, 4), Color8(42, 46, 47), true)
			draw_rect(Rect2(x + 8, 674, 120 * hero_ratio, 4), Color8(193, 151, 73), true)
		else:
			draw_label(fallback_font, "主將空位", Vector2(x + 34, 660), 12, Color8(126, 132, 130))
	var relics: Array = host.get("relics") as Array
	draw_label(fallback_font, "銅錢 %d" % int(player.get("coins", 0)), Vector2(1040, 648), 13, Color8(236, 199, 99))
	draw_label(fallback_font, "遺物 × %d" % relics.size(), Vector2(1040, 672), 13, Color8(183, 198, 201))

func draw_panel_box(rect: Rect2, border: Color) -> void:
	draw_rect(rect, Color(0.025, 0.03, 0.035, 0.96), true)
	draw_rect(rect, border, false, 1.4)

func draw_label(font: Font, text: String, position: Vector2, size: int, color: Color) -> void:
	draw_string(font, position, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
