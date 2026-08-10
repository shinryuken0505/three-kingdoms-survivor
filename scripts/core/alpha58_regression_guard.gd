extends Node

## Alpha.58 runtime regression guard.
## Protects the concrete regressions that repeatedly surfaced during Alpha.57:
## canonical protagonist portraits, heroine ranged identity, basic-attack camera/body stability,
## mixed level-choice safety, and duplicate screen renderers.

const PlayerArchetypeRegistry = preload("res://scripts/systems/player/player_archetype_registry.gd")
const Alpha27ActionProfiles = preload("res://scripts/systems/combat/alpha27_action_profiles.gd")
const Alpha36RosterProgressionHud = preload("res://scripts/systems/hero/alpha36_37_roster_progression_hud.gd")
const MeleeArcHandler = preload("res://scripts/systems/player/combat_handlers/melee_arc_handler.gd")
const RangedArrowHandler = preload("res://scripts/systems/player/combat_handlers/ranged_arrow_handler.gd")
const StrategyOrbHandler = preload("res://scripts/systems/player/combat_handlers/strategy_orb_handler.gd")

const PROTAGONIST_PORTRAITS: Dictionary = {
	"swordsman": "res://assets/portraits/player_swordsman.png",
	"hunter": "res://assets/portraits/player_archer.png",
}

var _main: Node = null
var _failures: Array[String] = []
var _warnings: Array[String] = []


class LevelChoiceHost:
	extends RefCounted
	var level_choices: Array = []
	var option_index: int = 0


class BasicAttackHost:
	extends RefCounted
	var player: Dictionary = {
		"pos": Vector2.ZERO,
		"level": 5,
		"multishot": 0,
		"pierce": 0,
	}
	var zones: Array = []
	var player_shots: Array = []
	var screen_shake: float = 7.25

	func nearest_enemy_position(_origin: Vector2) -> Vector2:
		return Vector2(120.0, 0.0)

	func damage_arc(
		_origin: Vector2,
		_angle: float,
		_radius: float,
		_arc_width: float,
		_damage: float,
		_knockback: float
	) -> void:
		pass

	func spawn_player_projectile(
		kind: String,
		direction: Vector2,
		damage: float,
		speed: float,
		life: float,
		radius: float,
		pierce: int,
		poison: float
	) -> void:
		player_shots.append({
			"kind": kind,
			"angle": direction.angle(),
			"damage": damage,
			"speed": speed,
			"life": life,
			"radius": radius,
			"pierce": pierce,
			"poison": poison,
		})

	func skill_level(_skill_id: String) -> int:
		return 0


func _ready() -> void:
	_main = get_parent()
	call_deferred("_run_checks")


func _run_checks() -> void:
	# PortraitSourceGuard is an Autoload and applies after the main scene has completed load_assets().
	# Wait two frames so this guard validates the final player-visible mapping instead of the transient legacy map.
	await get_tree().process_frame
	await get_tree().process_frame
	_check_protagonist_portraits()
	_check_heroine_archetype()
	_check_basic_attack_pose()
	_check_basic_attack_handlers()
	_check_level_choice_contract()
	_check_duplicate_ui_renderers()
	_report()


func _check_protagonist_portraits() -> void:
	if _main == null:
		_fail("Main scene unavailable for portrait validation.")
		return
	var portrait_value: Variant = _main.get("portrait_tex")
	if not portrait_value is Dictionary:
		_fail("Main portrait_tex is not a Dictionary.")
		return
	var portraits: Dictionary = portrait_value as Dictionary
	var errors_value: Variant = _main.get("asset_errors")
	var asset_errors: Array = errors_value as Array if errors_value is Array else []
	for raw_id in PROTAGONIST_PORTRAITS.keys():
		var identity_id: String = str(raw_id)
		var path: String = str(PROTAGONIST_PORTRAITS[raw_id])
		if not ResourceLoader.exists(path) and not FileAccess.file_exists(path):
			_warn("Canonical portrait file missing: %s -> %s" % [identity_id, path])
		if asset_errors.has(path):
			_warn("Canonical portrait failed to decode; safe fallback retained: %s -> %s" % [identity_id, path])
		if not portraits.has(identity_id) or not portraits[identity_id] is Texture2D:
			_fail("Player-visible portrait missing: %s" % identity_id)
			continue
		var texture: Texture2D = portraits[identity_id] as Texture2D
		if texture.get_width() <= 32 or texture.get_height() <= 32:
			_fail("Player-visible portrait resolved to fallback-sized texture: %s (%dx%d)" % [identity_id, texture.get_width(), texture.get_height()])


func _check_heroine_archetype() -> void:
	if PlayerArchetypeRegistry.canonical_id("heroine") != "heroine":
		_fail("heroine must not alias to another archetype.")
		return
	var definition: Dictionary = PlayerArchetypeRegistry.get_definition("heroine")
	if str(definition.get("weapon", "")) != "rings":
		_fail("heroine weapon regressed; expected rings.")
	if str(definition.get("attack_mode", "")) != "legacy_rings":
		_fail("heroine attack mode regressed; expected legacy_rings ranged path.")
	if str(definition.get("legacy_base", "")) != "heroine":
		_fail("heroine legacy base regressed; must remain heroine.")


func _check_basic_attack_pose() -> void:
	for kind in ["blade", "bow", "poison", "rings"]:
		for progress in [0.15, 0.50, 0.85]:
			var pose: Dictionary = Alpha27ActionProfiles.player_pose(kind, progress)
			if abs(float(pose.get("lunge", 0.0))) > 0.001:
				_fail("Basic attack body lunge returned for %s." % kind)
			if abs(float(pose.get("rotation", 0.0))) > 0.001:
				_fail("Basic attack body rotation returned for %s." % kind)
			var stretch_value: Variant = pose.get("stretch", Vector2.ONE)
			if not stretch_value is Vector2 or (stretch_value as Vector2).distance_to(Vector2.ONE) > 0.001:
				_fail("Basic attack body stretch returned for %s." % kind)


func _check_basic_attack_handlers() -> void:
	var melee_host := BasicAttackHost.new()
	var melee_shake: float = melee_host.screen_shake
	if not MeleeArcHandler.execute(melee_host, 10.0):
		_fail("Melee basic-attack handler failed regression probe.")
	elif not is_equal_approx(melee_host.screen_shake, melee_shake):
		_fail("Melee basic attack changed screen_shake.")

	var arrow_host := BasicAttackHost.new()
	var arrow_shake: float = arrow_host.screen_shake
	if not RangedArrowHandler.execute(arrow_host, 10.0):
		_fail("Arrow basic-attack handler failed regression probe.")
	elif not is_equal_approx(arrow_host.screen_shake, arrow_shake):
		_fail("Arrow basic attack changed screen_shake.")

	var strategy_host := BasicAttackHost.new()
	var strategy_shake: float = strategy_host.screen_shake
	if not StrategyOrbHandler.execute(strategy_host, 10.0):
		_fail("Strategy basic-attack handler failed regression probe.")
	elif not is_equal_approx(strategy_host.screen_shake, strategy_shake):
		_fail("Strategy basic attack changed screen_shake.")


func _check_level_choice_contract() -> void:
	var host := LevelChoiceHost.new()
	host.level_choices = [
		{"id": "slash"},
		"legacy-invalid-choice",
		null,
		{"skill": "projectile"},
		{"id": "slash"},
	]
	Alpha36RosterProgressionHud.diversify_level_choices(host)
	if host.level_choices.size() != 2:
		_fail("Level-choice sanitizer failed mixed/duplicate probe; expected 2 valid unique choices, got %d." % host.level_choices.size())
		return
	var ids: Dictionary = {}
	for value in host.level_choices:
		if not value is Dictionary:
			_fail("Level-choice sanitizer returned a non-Dictionary value.")
			return
		var choice: Dictionary = value as Dictionary
		var skill_id: String = str(choice.get("id", choice.get("skill", "")))
		ids[skill_id] = true
	if not ids.has("slash") or not ids.has("projectile"):
		_fail("Level-choice sanitizer lost valid choices during mixed-type probe.")


func _check_duplicate_ui_renderers() -> void:
	if _main == null:
		return
	for node_name in ["IntermissionVisualLayer", "RecruitmentRosterVisualLayer"]:
		if _main.has_node(NodePath(node_name)):
			_fail("Duplicate UI renderer returned to main scene: %s" % node_name)


func _fail(message: String) -> void:
	if not _failures.has(message):
		_failures.append(message)


func _warn(message: String) -> void:
	if not _warnings.has(message):
		_warnings.append(message)


func _report() -> void:
	for message in _warnings:
		push_warning("Alpha.58 regression warning: %s" % message)
	if _failures.is_empty():
		print("Alpha.58 Regression Guard: PASS (%d warning(s))." % _warnings.size())
		return
	for message in _failures:
		push_error("Alpha.58 regression failure: %s" % message)
	push_error("Alpha.58 Regression Guard: FAILED with %d issue(s)." % _failures.size())
