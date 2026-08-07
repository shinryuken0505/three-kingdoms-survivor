class_name Alpha48RuntimeCoordinator
extends Node

# Alpha.48: 收斂 Alpha.36~47 的 Autoload 設定。
# 舊 Runtime 仍保留原本 /root/<Name> 節點名稱，避免既有跨模組路徑失效；
# 但 project.godot 只需要維護 GameEvents + 本協調器兩個入口。

const TARGET_VERSION := "V2.0.0-alpha.54"

const MODULE_SPECS: Array[Dictionary] = [
	{"name":"Alpha41ArchitectureGuard", "script":preload("res://scripts/core/alpha41_architecture_guard.gd")},
	{"name":"Alpha42PlayerArchetypes", "script":preload("res://scripts/systems/player/alpha42_player_archetype_runtime.gd")},
	{"name":"Alpha43DataDrivenHeroes", "script":preload("res://scripts/systems/hero/alpha43_data_driven_hero_runtime.gd")},
	{"name":"Alpha44RelicMerchantRegistry", "script":preload("res://scripts/systems/merchant/alpha44_relic_merchant_runtime.gd")},
	{"name":"Alpha45ChapterBranchFlow", "script":preload("res://scripts/systems/chapter/alpha45_chapter_branch_runtime.gd")},
	{"name":"Alpha46BranchResultUI", "script":preload("res://scripts/ui/alpha46_branch_result_ui.gd")},
	{"name":"Alpha47BranchEffectScopeGuard", "script":preload("res://scripts/systems/chapter/alpha47_branch_effect_scope_guard.gd")},
	{"name":"Alpha47BranchGameplayEffects", "script":preload("res://scripts/systems/chapter/alpha47_branch_gameplay_effects.gd")},
	{"name":"Alpha36Alpha37Runtime", "script":preload("res://scripts/systems/hero/alpha36_37_runtime.gd")},
	{"name":"Alpha38FormationProgressionUI", "script":preload("res://scripts/systems/hero/alpha38_formation_progression_ui.gd")},
	{"name":"Alpha39SignatureProgression", "script":preload("res://scripts/systems/hero/alpha39_signature_progression_runtime.gd")},
	{"name":"Alpha40HeroSkillEvolution", "script":preload("res://scripts/systems/hero/alpha40_hero_skill_evolution_runtime.gd")},
]

var module_nodes: Dictionary = {}
var host: Variant = null
var last_run_token := ""
var restored_for_token := ""
var health_warnings: Array[String] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	install_modules()
	call_deferred("run_health_check")

func install_modules() -> void:
	var root := get_tree().root
	for spec in MODULE_SPECS:
		var module_name := str(spec.get("name", ""))
		if module_name == "":
			continue
		var existing := root.get_node_or_null(module_name)
		if existing != null:
			module_nodes[module_name] = existing
			continue
		var script_value: Variant = spec.get("script")
		if script_value == null:
			push_warning("Alpha48 missing script for %s" % module_name)
			continue
		var instance := script_value.new() as Node
		if instance == null:
			push_warning("Alpha48 could not instantiate %s" % module_name)
			continue
		instance.name = module_name
		root.add_child(instance)
		module_nodes[module_name] = instance

func _process(_delta: float) -> void:
	host = get_tree().current_scene
	if host == null or not is_instance_valid(host):
		return
	var player: Dictionary = host.get("player") as Dictionary
	if player.is_empty():
		last_run_token = ""
		restored_for_token = ""
		return
	var token := "%s:%s" % [str(host.get("chosen_identity")), str(player.get("run_seed", player.get("level", 1)))]
	if token != last_run_token:
		last_run_token = token
		restored_for_token = ""
	if restored_for_token != token:
		restore_runtime_snapshot()
		restored_for_token = token
	publish_integration_state()
	persist_runtime_snapshot()

func module(module_name: String) -> Node:
	if module_nodes.has(module_name):
		var node := module_nodes[module_name] as Node
		if node != null and is_instance_valid(node):
			return node
	return get_tree().root.get_node_or_null(module_name) as Node

func publish_integration_state() -> void:
	var player: Dictionary = host.get("player") as Dictionary
	if player.is_empty():
		return
	player["alpha48_integration"] = {
		"version":TARGET_VERSION,
		"module_count":module_nodes.size(),
		"warnings":health_warnings.duplicate(),
		"autoload_consolidated":true,
	}
	host.set("player", player)

func runtime_snapshot() -> Dictionary:
	var player: Dictionary = host.get("player") as Dictionary
	var result := {
		"version":TARGET_VERSION,
		"branch":{},
		"special_trades":{},
		"reforged_equipment":{},
	}
	for key in [
		"alpha46_selected_branch", "alpha46_next_chapter", "alpha46_reinforcement",
		"alpha46_boss_variant", "alpha46_hero_weight_bonus", "alpha46_merchant_override",
		"alpha46_branch_consumed"
	]:
		if player.has(key):
			(result["branch"] as Dictionary)[key] = player[key]
	var alpha47 := module("Alpha47BranchGameplayEffects")
	if alpha47 != null:
		var used: Variant = alpha47.get("trade_used")
		if used is Dictionary:
			result["special_trades"] = (used as Dictionary).duplicate(true)
	var equipment_defs: Dictionary = host.get("equipment_defs") as Dictionary
	for eid_value in equipment_defs.keys():
		var eid := str(eid_value)
		var definition: Dictionary = equipment_defs[eid] as Dictionary
		if int(definition.get("alpha47_reforged", 0)) <= 0:
			continue
		(result["reforged_equipment"] as Dictionary)[eid] = {
			"count":int(definition.get("alpha47_reforged", 0)),
			"effects":(definition.get("effects", {}) as Dictionary).duplicate(true),
		}
	return result

func persist_runtime_snapshot() -> void:
	var save_data: Dictionary = host.get("save_data") as Dictionary
	if save_data.is_empty():
		return
	var run_save: Dictionary = save_data.get("run_save", {}) as Dictionary
	run_save["alpha48_integration"] = runtime_snapshot()
	save_data["run_save"] = run_save
	host.set("save_data", save_data)

func restore_runtime_snapshot() -> void:
	var save_data: Dictionary = host.get("save_data") as Dictionary
	var run_save: Dictionary = save_data.get("run_save", {}) as Dictionary
	var snapshot: Dictionary = run_save.get("alpha48_integration", {}) as Dictionary
	if snapshot.is_empty():
		return
	var player: Dictionary = host.get("player") as Dictionary
	var branch: Dictionary = snapshot.get("branch", {}) as Dictionary
	for key in branch.keys():
		player[key] = branch[key]
	host.set("player", player)
	var alpha47 := module("Alpha47BranchGameplayEffects")
	var trades: Dictionary = snapshot.get("special_trades", {}) as Dictionary
	if alpha47 != null and not trades.is_empty():
		alpha47.set("trade_used", trades.duplicate(true))
	var equipment_defs: Dictionary = host.get("equipment_defs") as Dictionary
	var reforged: Dictionary = snapshot.get("reforged_equipment", {}) as Dictionary
	for eid_value in reforged.keys():
		var eid := str(eid_value)
		if not equipment_defs.has(eid):
			continue
		var definition: Dictionary = equipment_defs[eid] as Dictionary
		var data: Dictionary = reforged[eid] as Dictionary
		definition["alpha47_reforged"] = int(data.get("count", 0))
		definition["effects"] = (data.get("effects", definition.get("effects", {})) as Dictionary).duplicate(true)
		equipment_defs[eid] = definition
	host.set("equipment_defs", equipment_defs)

func run_health_check() -> void:
	health_warnings.clear()
	for spec in MODULE_SPECS:
		var module_name := str(spec.get("name", ""))
		if module(module_name) == null:
			health_warnings.append("missing runtime: %s" % module_name)
	var current_scene := get_tree().current_scene
	if current_scene != null:
		for required_property in ["player", "save_data", "chapter_manager", "relic_defs", "equipment_defs", "merchant_defs"]:
			if current_scene.get(required_property) == null:
				health_warnings.append("main scene missing property: %s" % required_property)
	if not health_warnings.is_empty():
		for warning in health_warnings:
			push_warning("Alpha48 integration: %s" % warning)
