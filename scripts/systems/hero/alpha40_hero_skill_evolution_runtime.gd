extends Node

const HeroContentRegistry = preload("res://scripts/systems/hero/hero_content_registry.gd")
const HeroSkillHandlerRegistry = preload("res://scripts/systems/hero/hero_skill_handler_registry.gd")
const HeroElementalBuildService = preload("res://scripts/systems/hero/hero_elemental_build_service.gd")

const MAX_LEVEL: int = 8
const LEVEL_3: int = 3
const LEVEL_5: int = 5
const LEVEL_8: int = 8

var host: Variant = null
var previous_cooldowns: Dictionary = {}
var evolution_notice: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	host = get_tree().current_scene
	if host == null or not is_instance_valid(host):
		return
	if str(host.get("screen")) != "game":
		return
	if not evolution_notice.is_empty():
		evolution_notice["time"] = max(0.0, float(evolution_notice.get("time", 0.0)) - delta)
		if float(evolution_notice.get("time", 0.0)) <= 0.0:
			evolution_notice.clear()
	observe_hero_casts()

func compact_id(hero_id: String) -> String:
	return hero_id.to_lower().replace("_", "").replace("-", "")

func hero_level(hero_id: String) -> int:
	var levels: Dictionary = host.get("hero_skill_levels") as Dictionary
	return clampi(int(levels.get(hero_id, 1)), 1, MAX_LEVEL)

func observe_hero_casts() -> void:
	var active: Array = host.get("active_heroes") as Array
	var cooldowns: Dictionary = host.get("hero_cooldowns") as Dictionary
	for value in active:
		var hero_id: String = str(value)
		var current: float = max(0.0, float(cooldowns.get(hero_id, 0.0)))
		var previous: float = max(0.0, float(previous_cooldowns.get(hero_id, 0.0)))
		# 冷卻從可用跳成正數，代表原技能剛施放完成。
		if previous <= 0.01 and current > 0.05:
			apply_skill_evolution(hero_id, hero_level(hero_id))
		previous_cooldowns[hero_id] = current
	var stale: Array = []
	for key in previous_cooldowns.keys():
		if not active.has(key):
			stale.append(key)
	for key in stale:
		previous_cooldowns.erase(key)

func player_position() -> Vector2:
	var player: Dictionary = host.get("player") as Dictionary
	return player.get("pos", player.get("position", Vector2.ZERO)) as Vector2

func enemy_position(enemy: Dictionary) -> Vector2:
	return enemy.get("pos", enemy.get("position", Vector2.ZERO)) as Vector2

func damage_enemy(enemy: Dictionary, amount: float) -> Dictionary:
	if amount <= 0.0:
		return enemy
	enemy["hp"] = float(enemy.get("hp", 0.0)) - amount
	return enemy

func add_ring(center: Vector2, radius: float, color: Color) -> void:
	var particles: Array = host.get("particles") as Array
	particles.append({"pos":center, "vel":Vector2.ZERO, "life":0.42, "max_life":0.42, "radius":radius, "color":color, "kind":"ring"})
	host.set("particles", particles)

func apply_skill_evolution(hero_id: String, level: int) -> void:
	if level < LEVEL_3:
		return
	var hero_def: Dictionary = HeroContentRegistry.get_hero(hero_id)
	var active_skill: String = str(hero_def.get("active_skill", ""))
	var handler: String = HeroSkillHandlerRegistry.handler_for(active_skill)
	match handler:
		"zhangfei": evolve_zhang_fei(hero_id, level)
		"guanyu": evolve_guan_yu(hero_id, level)
		"zhaoyun": evolve_zhao_yun(hero_id, level)
		"zhugeliang": evolve_zhuge_liang(hero_id, level)
		"huatuo": evolve_hua_tuo(hero_id, level)
		"sunshangxiang": evolve_sun_shang_xiang(hero_id, level)
		"zhouyu": evolve_zhou_yu(hero_id, level)
		"diaochan": evolve_diao_chan(hero_id, level)
		"lvbu": evolve_lv_bu(hero_id, level)
		_: evolve_general(hero_id, level)

func evolve_zhang_fei(hero_id: String, level: int) -> void:
	var radius: float = 118.0 + float(level - LEVEL_3) * 12.0
	var damage: float = 16.0 + float(level) * 5.0
	apply_area_damage(radius, damage, 160.0 + float(level) * 12.0)
	add_ring(player_position(), radius, Color(0.93, 0.57, 0.18, 0.82))
	if level >= LEVEL_5:
		apply_area_damage(radius + 46.0, damage * 0.62, 100.0)
		add_ring(player_position(), radius + 46.0, Color(0.95, 0.72, 0.28, 0.68))
	if level >= LEVEL_8:
		apply_control(radius + 52.0, 1.1, "stun")
	show_evolution(hero_id, level, "雙重震喝" if level >= LEVEL_5 else "震喝擴張")

func evolve_guan_yu(hero_id: String, level: int) -> void:
	var enemies: Array = host.get("enemies") as Array
	var center: Vector2 = player_position()
	var radius: float = 155.0 + float(level) * 9.0
	for index in range(enemies.size()):
		var enemy: Dictionary = enemies[index] as Dictionary
		if enemy_position(enemy).distance_to(center) > radius:
			continue
		var max_hp: float = max(1.0, float(enemy.get("max_hp", enemy.get("hp", 1.0))))
		var hp: float = float(enemy.get("hp", 0.0))
		var threshold: float = 0.12 if level < LEVEL_8 else 0.20
		var damage: float = 22.0 + float(level) * 7.0
		if level >= LEVEL_5 and hp / max_hp <= threshold:
			damage = max(damage, hp + 1.0)
		enemies[index] = damage_enemy(enemy, damage)
	host.set("enemies", enemies)
	add_ring(center, radius, Color(0.82, 0.93, 0.72, 0.75))
	show_evolution(hero_id, level, "武聖斬殺" if level >= LEVEL_5 else "青龍增幅")

func evolve_zhao_yun(hero_id: String, level: int) -> void:
	var enemies: Array = host.get("enemies") as Array
	var center: Vector2 = player_position()
	var hits: int = 2 if level < LEVEL_5 else 3
	if level >= LEVEL_8:
		hits = 5
	for hit in range(hits):
		var nearest_index: int = -1
		var nearest_distance: float = 420.0
		for index in range(enemies.size()):
			var enemy: Dictionary = enemies[index] as Dictionary
			var distance: float = enemy_position(enemy).distance_to(center)
			if distance < nearest_distance and float(enemy.get("hp", 0.0)) > 0.0:
				nearest_distance = distance
				nearest_index = index
		if nearest_index < 0:
			break
		var target: Dictionary = enemies[nearest_index] as Dictionary
		enemies[nearest_index] = damage_enemy(target, 13.0 + float(level) * 4.0)
	host.set("enemies", enemies)
	add_ring(center, 84.0 + float(level) * 4.0, Color(0.58, 0.83, 1.0, 0.78))
	show_evolution(hero_id, level, "回身五連刺" if level >= LEVEL_8 else "龍膽連突")

func evolve_zhuge_liang(hero_id: String, level: int) -> void:
	var radius: float = 150.0 + float(level) * 11.0
	apply_area_damage(radius, 10.0 + float(level) * 3.2, 0.0)
	apply_control(radius, 1.0 + float(level) * 0.12, "slow")
	if level >= LEVEL_5:
		apply_control(radius + 42.0, 0.65 + float(level) * 0.08, "slow")
	if level >= LEVEL_8:
		apply_control(radius, 0.8, "stun")
	add_ring(player_position(), radius, Color(0.46, 0.66, 0.96, 0.78))
	show_evolution(hero_id, level, "八陣連鎖" if level >= LEVEL_8 else "術陣擴張")

func evolve_hua_tuo(hero_id: String, level: int) -> void:
	var player: Dictionary = host.get("player") as Dictionary
	var max_hp: float = max(1.0, float(player.get("max_hp", 1.0)))
	var heal: float = max_hp * (0.035 + float(level) * 0.008)
	player["hp"] = min(max_hp, float(player.get("hp", 0.0)) + heal)
	if level >= LEVEL_5:
		player["shield"] = float(player.get("shield", 0.0)) + max_hp * 0.06
	if level >= LEVEL_8:
		player["alpha40_damage_reduction"] = 0.18
		player["alpha40_damage_reduction_time"] = 3.0
	host.set("player", player)
	HeroElementalBuildService.cleanse_player(host, level)
	add_ring(player_position(), 110.0, Color(0.47, 0.95, 0.66, 0.80))
	show_evolution(hero_id, level, "青囊護體" if level >= LEVEL_5 else "青囊回春")

func evolve_sun_shang_xiang(hero_id: String, level: int) -> void:
	var enemies: Array = host.get("enemies") as Array
	var center: Vector2 = player_position()
	var candidates: Array = []
	for index in range(enemies.size()):
		var enemy: Dictionary = enemies[index] as Dictionary
		candidates.append({"index":index, "distance":enemy_position(enemy).distance_to(center)})
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["distance"]) < float(b["distance"]))
	var target_count: int = 2 if level < LEVEL_5 else 4
	if level >= LEVEL_8:
		target_count = 6
	for order in range(min(target_count, candidates.size())):
		var enemy_index: int = int((candidates[order] as Dictionary)["index"])
		var enemy: Dictionary = enemies[enemy_index] as Dictionary
		enemies[enemy_index] = damage_enemy(enemy, 12.0 + float(level) * 4.5)
	host.set("enemies", enemies)
	add_ring(center, 92.0, Color(1.0, 0.56, 0.74, 0.76))
	show_evolution(hero_id, level, "穿雲六連射" if level >= LEVEL_8 else "弓腰連射")

func evolve_zhou_yu(hero_id: String, level: int) -> void:
	var radius: float = 158.0 + float(level) * 12.0
	apply_area_damage(radius, 12.0 + float(level) * 4.2, 0.0)
	apply_control(radius, 2.8 + float(level) * 0.15, "burn")
	if level >= LEVEL_5:
		apply_control(radius + 42.0, 2.4, "burn")
	if level >= LEVEL_8:
		apply_control(radius, 2.2, "armor_break")
	add_ring(player_position(), radius, Color(1.0, 0.38, 0.16, 0.78))
	show_evolution(hero_id, level, "赤壁燎原" if level >= LEVEL_8 else "烈焰擴張")

func evolve_diao_chan(hero_id: String, level: int) -> void:
	var radius: float = 145.0 + float(level) * 10.0
	apply_control(radius, 1.0 + float(level) * 0.14, "slow")
	if level >= LEVEL_5:
		apply_control(radius, 0.8, "confuse")
	if level >= LEVEL_8:
		apply_area_damage(radius, 18.0 + float(level) * 3.0, 0.0)
	add_ring(player_position(), radius, Color(0.94, 0.54, 0.92, 0.72))
	show_evolution(hero_id, level, "閉月惑心" if level >= LEVEL_5 else "魅影擴散")

func evolve_lv_bu(hero_id: String, level: int) -> void:
	var radius: float = 138.0 + float(level) * 12.0
	apply_area_damage(radius, 28.0 + float(level) * 8.0, 135.0)
	if level >= LEVEL_5:
		apply_area_damage(radius + 55.0, 17.0 + float(level) * 5.0, 80.0)
	if level >= LEVEL_8:
		apply_control(radius + 55.0, 0.75, "stun")
	add_ring(player_position(), radius, Color(0.95, 0.25, 0.20, 0.80))
	show_evolution(hero_id, level, "無雙亂舞" if level >= LEVEL_5 else "方天橫掃")

func evolve_general(hero_id: String, level: int) -> void:
	apply_area_damage(105.0 + float(level) * 8.0, 10.0 + float(level) * 3.0, 40.0)
	show_evolution(hero_id, level, "專屬技能精進")

func apply_area_damage(radius: float, damage: float, knockback: float) -> void:
	var enemies: Array = host.get("enemies") as Array
	var center: Vector2 = player_position()
	for index in range(enemies.size()):
		var enemy: Dictionary = enemies[index] as Dictionary
		var pos: Vector2 = enemy_position(enemy)
		if pos.distance_to(center) > radius:
			continue
		enemy = damage_enemy(enemy, damage)
		if knockback > 0.0:
			var direction: Vector2 = center.direction_to(pos)
			enemy["vel"] = direction * knockback
		enemies[index] = enemy
	host.set("enemies", enemies)

func apply_control(radius: float, duration: float, kind: String) -> void:
	var enemies: Array = host.get("enemies") as Array
	var center: Vector2 = player_position()
	for index in range(enemies.size()):
		var enemy: Dictionary = enemies[index] as Dictionary
		if enemy_position(enemy).distance_to(center) > radius:
			continue
		if host.has_method("apply_enemy_status"):
			var potency: float = 1.0
			if kind == "slow": potency = 0.30
			elif kind == "burn": potency = 0.90
			elif kind == "armor_break": potency = 0.16
			host.call("apply_enemy_status", index, kind, duration, potency, 1)

func show_evolution(hero_id: String, level: int, effect_name: String) -> void:
	var heroes: Dictionary = host.get("heroes") as Dictionary
	var hero_name: String = str(heroes.get(hero_id, {}).get("name", hero_id))
	evolution_notice = {"name":hero_name, "level":level, "effect":effect_name, "time":1.4}
	if host.has_method("show_message"):
		host.call("show_message", "%s｜%s" % [hero_name, effect_name], 1.4)
