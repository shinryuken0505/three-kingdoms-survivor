class_name PlayerCombatService
extends RefCounted

const PlayerArchetypeRegistry = preload("res://scripts/systems/player/player_archetype_registry.gd")

static func attack_mode(archetype_id: String) -> String:
	return str(PlayerArchetypeRegistry.get_definition(archetype_id).get("attack_mode", "melee_arc"))

static func weapon_for(archetype_id: String, fallback: String = "blade") -> String:
	return str(PlayerArchetypeRegistry.get_definition(archetype_id).get("weapon", fallback))

static func perform_auto_attack(host: Object, archetype_id: String, legacy_attack: Callable) -> bool:
	if host == null or not legacy_attack.is_valid():
		return false
	var player_value: Variant = host.get("player")
	if not player_value is Dictionary:
		return false
	var player: Dictionary = player_value as Dictionary
	var mode: String = attack_mode(archetype_id)
	player["attack_mode"] = mode
	player["weapon"] = weapon_for(archetype_id, str(player.get("weapon", "blade")))
	player["alpha49_attack_mode"] = mode
	host.set("player", player)
	# 現有成熟的命中、投射物、遺物與音效流程先保留；Alpha.49 將入口改由 Service 決定。
	legacy_attack.call()
	return true

static func validate() -> Array[String]:
	var errors: Array[String] = []
	for archetype_id in PlayerArchetypeRegistry.DEFINITIONS.keys():
		var definition: Dictionary = PlayerArchetypeRegistry.DEFINITIONS[archetype_id] as Dictionary
		if str(definition.get("attack_mode", "")) == "":
			errors.append("%s missing attack_mode" % archetype_id)
		if str(definition.get("weapon", "")) == "":
			errors.append("%s missing weapon" % archetype_id)
	return errors
