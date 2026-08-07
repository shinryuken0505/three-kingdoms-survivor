extends Node

const ChapterBranchRegistry = preload("res://scripts/systems/chapter/chapter_branch_registry.gd")

const PHASES: PackedStringArray = ["intro", "combat", "event", "elite", "boss", "loot", "result", "branch", "formation", "autosave", "complete"]
const NEXT_PHASE: Dictionary = {
	"intro":"combat", "combat":"event", "event":"elite", "elite":"boss", "boss":"loot",
	"loot":"result", "result":"branch", "branch":"formation", "formation":"autosave",
	"autosave":"complete"
}

var host: Variant = null
var state: Dictionary = {}
var last_screen: String = ""
var last_boss_alive: bool = false
var run_token: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for error_text in ChapterBranchRegistry.validate():
		push_warning("Alpha45 branch registry: %s" % error_text)

func _process(_delta: float) -> void:
	host = get_tree().current_scene
	if host == null or not is_instance_valid(host):
		return
	var player: Dictionary = host.get("player") as Dictionary
	if player.is_empty():
		reset_state()
		return
	var token: String = "%s:%s" % [str(host.get("chosen_identity")), str(player.get("run_seed", player.get("level", 1)))]
	if token != run_token:
		reset_state()
		run_token = token
	ensure_state()
	observe_flow()
	guard_boss_and_result()
	publish_to_host()

func reset_state() -> void:
	state = {}
	last_screen = ""
	last_boss_alive = false
	run_token = ""

func current_chapter() -> Dictionary:
	if host != null and host.has_method("current_chapter"):
		return host.call("current_chapter") as Dictionary
	return {}

func ensure_state() -> void:
	if not state.is_empty():
		return
	var chapter: Dictionary = current_chapter()
	state = {
		"chapter_id":str(chapter.get("id", "")),
		"phase":"intro",
		"phase_history":["intro"],
		"available_branches":[],
		"selected_branch":"",
		"resolved_effects":{},
		"boss_committed":false,
		"result_committed":false,
		"autosave_committed":false
	}

func observe_flow() -> void:
	var screen_name: String = str(host.get("screen"))
	if screen_name == last_screen:
		return
	last_screen = screen_name
	match screen_name:
		"chapter_intro": transition_to("intro")
		"game":
			if bool(host.get("boss_spawned")):
				transition_to("boss")
			elif str(state.get("phase", "intro")) in ["intro", "formation", "autosave"]:
				transition_to("combat")
		"boss_loot": transition_to("loot")
		"chapter_clear", "chapter_result": transition_to("result")
		"history_event": transition_to("branch")
		"hero_config":
			if str(host.get("hero_config_origin")) != "game":
				transition_to("formation")
	if str(state.get("phase", "")) == "branch":
		refresh_available_branches()

func transition_to(next_phase: String) -> bool:
	if not PHASES.has(next_phase):
		return false
	var previous: String = str(state.get("phase", "intro"))
	if previous == next_phase:
		return true
	var expected: String = str(NEXT_PHASE.get(previous, ""))
	if expected != next_phase and not _is_safe_skip(previous, next_phase):
		push_warning("Alpha45 rejected chapter transition %s -> %s" % [previous, next_phase])
		return false
	state["phase"] = next_phase
	var manager: Variant = host.get("chapter_manager")
	if manager != null and manager.has_method("set_flow_phase"):
		manager.call("set_flow_phase", next_phase)
	var history: Array = state.get("phase_history", []) as Array
	history.append(next_phase)
	state["phase_history"] = history
	var events: Node = get_node_or_null("/root/GameEvents")
	if events != null and events.has_method("publish"):
		events.call("publish", "chapter_phase_changed", {"previous":previous, "next":next_phase})
	return true

func _is_safe_skip(previous: String, next_phase: String) -> bool:
	var from_index: int = PHASES.find(previous)
	var to_index: int = PHASES.find(next_phase)
	return from_index >= 0 and to_index > from_index and to_index - from_index <= 3

func branch_context() -> Dictionary:
	var heroes: Array = []
	for group_name in ["active_heroes", "reserve_heroes", "camp_heroes"]:
		for hero_value in host.get(group_name) as Array:
			if not heroes.has(str(hero_value)):
				heroes.append(str(hero_value))
	var save_data: Dictionary = host.get("save_data") as Dictionary
	var story_routes: Dictionary = save_data.get("story_routes", {}) as Dictionary
	return {
		"flags":story_routes,
		"heroes":heroes,
		"bosses":host.get("boss_defeat_counts") as Dictionary,
		"relics":host.get("relics") as Array
	}

func refresh_available_branches() -> void:
	state["available_branches"] = ChapterBranchRegistry.available_for(str(state.get("chapter_id", "")), branch_context())

func select_branch(branch_id: String) -> bool:
	var available: Array = state.get("available_branches", []) as Array
	if not available.has(branch_id):
		return false
	var definition: Dictionary = ChapterBranchRegistry.get_definition(branch_id)
	var effects: Dictionary = definition.get("effects", {}) as Dictionary
	state["selected_branch"] = branch_id
	state["resolved_effects"] = effects.duplicate(true)
	var manager: Variant = host.get("chapter_manager")
	if manager != null and manager.has_method("set_branch_result"):
		manager.call("set_branch_result", branch_id, effects)
	apply_branch_effects(effects)
	var events: Node = get_node_or_null("/root/GameEvents")
	if events != null and events.has_method("publish"):
		events.call("publish", "branch_selected", {"branch_id":branch_id})
	transition_to("formation")
	return true

func apply_branch_effects(effects: Dictionary) -> void:
	var save_data: Dictionary = host.get("save_data") as Dictionary
	var story_routes: Dictionary = save_data.get("story_routes", {}) as Dictionary
	for flag_value in effects.get("set_flags", []):
		story_routes[str(flag_value)] = true
	save_data["story_routes"] = story_routes
	host.set("save_data", save_data)
	var merchant_override: String = str(effects.get("merchant_override", ""))
	if merchant_override != "":
		host.set("merchant_kind", merchant_override)
	var player: Dictionary = host.get("player") as Dictionary
	player["alpha45_branch_effects"] = effects.duplicate(true)
	host.set("player", player)

func guard_boss_and_result() -> void:
	var boss: Dictionary = host.get("boss") as Dictionary
	var boss_alive: bool = not boss.is_empty() and float(boss.get("hp", 0.0)) > 0.0
	if last_boss_alive and not boss_alive and bool(host.get("boss_spawned")):
		if bool(state.get("boss_committed", false)):
			host.set("boss_spawned", false)
		else:
			state["boss_committed"] = true
			transition_to("loot")
	last_boss_alive = boss_alive
	if bool(state.get("result_committed", false)) and int(host.get("pending_run_result")) != 0:
		host.set("pending_run_result", 0)
	elif int(host.get("pending_run_result")) != 0:
		state["result_committed"] = true

func request_autosave() -> void:
	if bool(state.get("autosave_committed", false)):
		return
	state["autosave_committed"] = true
	transition_to("autosave")
	if host.has_method("save_checkpoint"):
		host.call_deferred("save_checkpoint", false)
	var events: Node = get_node_or_null("/root/GameEvents")
	if events != null and events.has_method("publish"):
		events.call("publish", "save_requested", {"reason":"chapter_transition"})
	transition_to("complete")

func publish_to_host() -> void:
	var player: Dictionary = host.get("player") as Dictionary
	if player.is_empty():
		return
	player["alpha45_chapter_flow"] = state.duplicate(true)
	host.set("player", player)
