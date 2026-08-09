class_name Alpha36RosterProgressionHud
extends RefCounted

const StatusEffectService = preload("res://scripts/systems/combat/status_effect_service.gd")
const ElementalSynergyService = preload("res://scripts/systems/combat/elemental_synergy_service.gd")

const MAX_RECRUIT_VISITS: int = 5
const ACTIVE_XP_RATE: float = 1.0
const RESERVE_XP_RATE: float = 0.45
const MAX_HERO_LEVEL: int = 8

static func new_state() -> Dictionary:
	return {
		"recruit_visits": 0,
		"recruit_cap": 2 + (randi() % 4),
		"last_encounter": "",
		"known_count": 0,
		"last_kills": 0,
		"last_boss_total": 0,
		"config_opened_for_visit": false,
	}

static func active_cap(host: Variant) -> int:
	var chapter_number: int = int(host.current_chapter().get("index", 0)) + 1
	return 2 if chapter_number <= 1 else 3

static func reserve_cap(host: Variant) -> int:
	var chapter_number: int = int(host.current_chapter().get("index", 0)) + 1
	return 1 if chapter_number <= 1 else 2

static func apply_roster_caps(host: Variant) -> void:
	var active_limit: int = active_cap(host)
	var reserve_limit: int = reserve_cap(host)
	while host.active_heroes.size() > active_limit:
		var moved_active: String = str(host.active_heroes.pop_back())
		if host.reserve_heroes.size() < reserve_limit:
			host.reserve_heroes.append(moved_active)
		elif not host.camp_heroes.has(moved_active):
			host.camp_heroes.append(moved_active)
	while host.reserve_heroes.size() > reserve_limit:
		var moved_reserve: String = str(host.reserve_heroes.pop_back())
		if not host.camp_heroes.has(moved_reserve):
			host.camp_heroes.append(moved_reserve)

static func can_spawn_recruit(host: Variant, state: Dictionary) -> bool:
	var cap: int = clampi(int(state.get("recruit_cap", 3)), 2, MAX_RECRUIT_VISITS)
	if int(state.get("recruit_visits", 0)) >= cap:
		return false
	if str(host.current_encounter) != "":
		return false
	return true

static func register_recruit_visit(host: Variant, state: Dictionary) -> void:
	state["recruit_visits"] = int(state.get("recruit_visits", 0)) + 1
	state["config_opened_for_visit"] = false
	host.hero_spawn_timer = randf_range(105.0, 165.0)

static func diversify_level_choices(host: Variant) -> void:
	if host.level_choices.size() <= 1:
		return
	var unique: Array = []
	var seen: Dictionary = {}
	for choice_value in host.level_choices:
		if not choice_value is Dictionary:
			push_warning("Skipping invalid level choice type in diversify_level_choices: %s" % typeof(choice_value))
			continue
		var choice: Dictionary = (choice_value as Dictionary).duplicate(true)
		var skill_id: String = str(choice.get("id", choice.get("skill", "")))
		if skill_id == "" or seen.has(skill_id):
			continue
		seen[skill_id] = true
		unique.append(choice)
	if unique.is_empty():
		return
	unique.shuffle()
	if unique.size() > 4:
		unique.resize(4)
	host.level_choices = unique
	host.option_index = clampi(host.option_index, 0, max(0, host.level_choices.size() - 1))

static func tick(host: Variant, state: Dictionary) -> void:
	if host.player.is_empty():
		return
	apply_roster_caps(host)
	var current_known: int = host.known_heroes.size()
	var current_encounter: String = str(host.current_encounter)
	var previous_encounter: String = str(state.get("last_encounter", ""))
	if previous_encounter != "" and current_encounter == "" and current_known > int(state.get("known_count", 0)):
		if not bool(state.get("config_opened_for_visit", false)) and host.has_method("open_hero_config"):
			state["config_opened_for_visit"] = true
			host.call_deferred("open_hero_config", "game")
	state["last_encounter"] = current_encounter
	state["known_count"] = current_known
	award_combat_experience(host, state)

static func award_combat_experience(host: Variant, state: Dictionary) -> void:
	var kills: int = int(host.run_stats.get("kills", 0))
	var boss_total: int = 0
	for value in host.boss_defeat_counts.values():
		boss_total += int(value)
	var kill_delta: int = max(0, kills - int(state.get("last_kills", kills)))
	var boss_delta: int = max(0, boss_total - int(state.get("last_boss_total", boss_total)))
	state["last_kills"] = kills
	state["last_boss_total"] = boss_total
	if kill_delta <= 0 and boss_delta <= 0:
		return
	var base_xp: int = kill_delta + boss_delta * 35
	for hero_value in host.active_heroes:
		grant_hero_xp(host, str(hero_value), int(round(float(base_xp) * ACTIVE_XP_RATE)))
	for hero_value in host.reserve_heroes:
		grant_hero_xp(host, str(hero_value), int(round(float(base_xp) * RESERVE_XP_RATE)))

static func required_xp(level: int) -> int:
	return 24 + max(0, level - 1) * 18

static func grant_hero_xp(host: Variant, hero_id: String, amount: int) -> void:
	if hero_id == "" or amount <= 0:
		return
	host.initialize_hero_progress(hero_id)
	var level: int = host.hero_skill_level(hero_id)
	if level >= MAX_HERO_LEVEL:
		host.hero_experience[hero_id] = 0
		return
	var xp: int = int(host.hero_experience.get(hero_id, 0)) + amount
	while level < MAX_HERO_LEVEL and xp >= required_xp(level):
		xp -= required_xp(level)
		level += 1
		host.hero_skill_levels[hero_id] = level
		host.hero_cooldowns[hero_id] = 0.0
		var hero_name: String = str(host.heroes.get(hero_id, {}).get("name", hero_id))
		host.show_message("%s成長至 Lv.%d" % [hero_name, level], 2.4)
	host.hero_experience[hero_id] = xp

static func draw_integrated_hud(host: Variant) -> void:
	var chapter: Dictionary = host.current_chapter()
	var chapter_name: String = str(chapter.get("name", chapter.get("title", "戰場")))
	var chapter_number: int = int(chapter.get("index", 0)) + 1
	var header: Rect2 = Rect2(300.0, 12.0, 680.0, 52.0)
	host.draw_panel(header, Color(0.025, 0.03, 0.035, 0.92), Color8(126, 112, 78), 1.4)
	host.draw_text("第%d關｜%s" % [chapter_number, chapter_name], header.position + Vector2(18, 32), 18, Color8(236, 220, 176), true)
	var elapsed_text: String = "%02d:%02d" % [int(host.elapsed) / 60, int(host.elapsed) % 60]
	host.draw_text(elapsed_text, header.position + Vector2(574, 32), 16, Color8(196, 204, 202), true, HORIZONTAL_ALIGNMENT_RIGHT, 88)
	if host.boss_spawned and not host.boss.is_empty():
		var boss_rect: Rect2 = Rect2(350.0, 72.0, 580.0, 50.0)
		host.draw_panel(boss_rect, Color(0.08, 0.025, 0.028, 0.94), Color8(178, 67, 58), 1.5)
