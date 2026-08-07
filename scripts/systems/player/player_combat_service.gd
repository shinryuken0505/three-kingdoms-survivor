class_name PlayerCombatService
extends RefCounted

const PlayerArchetypeRegistry = preload("res://scripts/systems/player/player_archetype_registry.gd")
const MeleeArcHandler = preload("res://scripts/systems/player/combat_handlers/melee_arc_handler.gd")
const RangedArrowHandler = preload("res://scripts/systems/player/combat_handlers/ranged_arrow_handler.gd")
const StrategyOrbHandler = preload("res://scripts/systems/player/combat_handlers/strategy_orb_handler.gd")

static func attack_mode(archetype_id: String) -> String:
	return str(PlayerArchetypeRegistry.get_definition(archetype_id).get("attack_mode", "melee_arc"))

static func weapon_for(archetype_id: String, fallback: String = "blade") -> String:
	return str(PlayerArchetypeRegistry.get_definition(archetype_id).get("weapon", fallback))

static func base_damage(host: Object) -> float:
	var player_value: Variant = host.get("player")
	if not player_value is Dictionary:
		return 0.0
	var player: Dictionary = player_value as Dictionary
	var damage: float = float(player.get("damage", 1.0))
	damage *= float(player.get("alpha19_damage_mult", 1.0))
	damage *= float(player.get("alpha20_damage_mult", 1.0))
	if host.has_method("alpha21_identity_damage_multiplier"):
		damage *= float(host.call("alpha21_identity_damage_multiplier"))
	if host.has_method("skill_level"):
		damage *= 1.0 + int(host.call("skill_level", "damage")) * 0.15
	if host.has_method("relic_stat"):
		damage *= 1.0 + float(host.call("relic_stat", "damage_bonus"))
	return damage

static func perform_auto_attack(host: Object, archetype_id: String, legacy_attack: Callable) -> bool:
	if host == null:
		return false
	var player_value: Variant = host.get("player")
	if not player_value is Dictionary:
		return false
	var player: Dictionary = player_value as Dictionary
	var mode: String = attack_mode(archetype_id)
	player["attack_mode"] = mode
	player["weapon"] = weapon_for(archetype_id, str(player.get("weapon", "blade")))
	player["alpha50_attack_mode"] = mode
	host.set("player", player)
	var damage: float = base_damage(host)
	var handled: bool = false
	match mode:
		"melee_arc":
			handled = MeleeArcHandler.execute(host, damage)
		"ranged_arrow":
			handled = RangedArrowHandler.execute(host, damage)
		"strategy_orb":
			handled = StrategyOrbHandler.execute(host, damage)
		_:
			handled = false
	if handled:
		return true
	if legacy_attack.is_valid():
		legacy_attack.call()
		return true
	return false

static func validate() -> Array[String]:
	var errors: Array[String] = []
	var supported_modes: Array[String] = ["melee_arc", "ranged_arrow", "strategy_orb"]
	for archetype_id in PlayerArchetypeRegistry.DEFINITIONS.keys():
		var definition: Dictionary = PlayerArchetypeRegistry.DEFINITIONS[archetype_id] as Dictionary
		var mode: String = str(definition.get("attack_mode", ""))
		if mode == "":
			errors.append("%s missing attack_mode" % archetype_id)
		elif not supported_modes.has(mode):
			errors.append("%s unsupported attack_mode: %s" % [archetype_id, mode])
		if str(definition.get("weapon", "")) == "":
			errors.append("%s missing weapon" % archetype_id)
	return errors
