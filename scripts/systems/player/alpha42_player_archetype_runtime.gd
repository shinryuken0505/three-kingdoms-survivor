extends Node

const PlayerArchetypeRegistry = preload("res://scripts/systems/player/player_archetype_registry.gd")

var host: Variant = null
var applied_run_token: String = ""
var last_identity: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for error_text in PlayerArchetypeRegistry.validate():
		push_warning("Alpha42 archetype registry: %s" % error_text)

func _process(_delta: float) -> void:
	host = get_tree().current_scene
	if host == null or not is_instance_valid(host):
		return
	inject_identity_definitions()
	var player_data: Dictionary = host.get("player") as Dictionary
	if player_data.is_empty():
		applied_run_token = ""
		return
	var chosen: String = PlayerArchetypeRegistry.canonical_id(str(host.get("chosen_identity")))
	if chosen == "":
		chosen = "swordsman"
	if str(host.get("chosen_identity")) != chosen:
		host.set("chosen_identity", chosen)
	var token: String = "%s:%s" % [chosen, str(player_data.get("run_seed", player_data.get("level", 1)))]
	if token != applied_run_token or chosen != last_identity:
		apply_archetype(chosen, player_data)
		applied_run_token = token
		last_identity = chosen

func inject_identity_definitions() -> void:
	var identities: Dictionary = host.get("identities") as Dictionary
	if identities.is_empty():
		return
	for archetype_value in PlayerArchetypeRegistry.DEFINITIONS.keys():
		var archetype_id: String = str(archetype_value)
		var definition: Dictionary = PlayerArchetypeRegistry.get_definition(archetype_id)
		var legacy_id: String = str(definition.get("legacy_base", "swordsman"))
		var existing: Dictionary = (identities.get(archetype_id, identities.get(legacy_id, identities.get("swordsman", {}))) as Dictionary).duplicate(true)
		var stats: Dictionary = definition.get("base_stats", {}) as Dictionary
		existing["name"] = str(definition.get("name", existing.get("name", archetype_id)))
		existing["title"] = str(definition.get("title", existing.get("title", "")))
		existing["desc"] = str(definition.get("description", existing.get("desc", "")))
		existing["description"] = existing["desc"]
		existing["weapon"] = str(definition.get("weapon", existing.get("weapon", "blade")))
		existing["attack_mode"] = str(definition.get("attack_mode", "melee_arc"))
		existing["passive"] = str(definition.get("passive", ""))
		existing["hp"] = float(stats.get("max_hp", existing.get("hp", 100.0)))
		existing["speed"] = float(stats.get("speed", existing.get("speed", 200.0)))
		existing["damage"] = float(existing.get("damage", 10.0)) * float(stats.get("damage_mult", 1.0))
		existing["attack_interval"] = float(existing.get("attack_interval", 0.75)) / max(0.25, float(stats.get("attack_speed_mult", 1.0)))
		var portrait_path: String = str(definition.get("portrait", ""))
		if portrait_path != "" and (ResourceLoader.exists(portrait_path) or FileAccess.file_exists(portrait_path)):
			existing["portrait"] = portrait_path
		var sprite_path: String = str(definition.get("sprite", ""))
		if sprite_path != "" and (ResourceLoader.exists(sprite_path) or FileAccess.file_exists(sprite_path)):
			existing["sprite"] = sprite_path
		existing["alpha42_definition"] = definition.duplicate(true)
		identities[archetype_id] = existing
	host.set("identities", identities)

func apply_archetype(archetype_id: String, player_data: Dictionary) -> void:
	var canonical: String = PlayerArchetypeRegistry.canonical_id(archetype_id)
	var definition: Dictionary = PlayerArchetypeRegistry.get_definition(canonical)
	var stats: Dictionary = definition.get("base_stats", {}) as Dictionary
	var previous_id: String = str(player_data.get("alpha42_archetype", ""))
	if previous_id == "":
		player_data["max_hp"] = float(stats.get("max_hp", player_data.get("max_hp", 100.0)))
		player_data["hp"] = min(float(player_data.get("hp", player_data["max_hp"])), float(player_data["max_hp"]))
	player_data["alpha42_archetype"] = canonical
	player_data["weapon"] = str(definition.get("weapon", player_data.get("weapon", "blade")))
	player_data["attack_mode"] = str(definition.get("attack_mode", "melee_arc"))
	player_data["alpha42_damage_mult"] = float(stats.get("damage_mult", 1.0))
	player_data["alpha42_attack_speed_mult"] = float(stats.get("attack_speed_mult", 1.0))
	player_data["alpha42_dash_cd_mult"] = float(stats.get("dash_cd_mult", 1.0))
	player_data["alpha42_speed_base"] = float(stats.get("speed", player_data.get("speed", 200.0)))
	player_data["alpha42_passive"] = str(definition.get("passive", ""))
	player_data["alpha42_upgrade_weights"] = (definition.get("upgrade_weights", {}) as Dictionary).duplicate(true)
	host.set("player", player_data)
	ensure_starting_skills(definition)
	if host.has_method("show_message") and previous_id != canonical:
		host.call("show_message", "%s｜%s" % [str(definition.get("name", "主角")), str(definition.get("title", ""))], 2.4)
	var events: Node = get_node_or_null("/root/GameEvents")
	if events != null and events.has_signal("player_registered"):
		events.emit_signal("player_registered", canonical, definition)

func ensure_starting_skills(definition: Dictionary) -> void:
	var skill_levels: Dictionary = host.get("skill_levels") as Dictionary
	for skill_value in definition.get("starting_skills", []):
		var skill_id: String = str(skill_value)
		if skill_id != "" and not skill_levels.has(skill_id):
			skill_levels[skill_id] = 1
	host.set("skill_levels", skill_levels)
