extends Node

const HeroRegistry = preload("res://scripts/systems/hero/hero_content_registry.gd")

var host: Variant = null
var audit_report: Dictionary = {}
var injected: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	host = get_tree().current_scene
	if host == null or not is_instance_valid(host):
		return
	if injected:
		return
	var heroes_value: Variant = host.get("heroes")
	if not (heroes_value is Dictionary):
		return
	inject_registry_metadata()
	audit_report = HeroRegistry.audit_assets()
	report_audit()
	injected = true

func inject_registry_metadata() -> void:
	var current: Dictionary = (host.get("heroes") as Dictionary).duplicate(true)
	for registry_id in HeroRegistry.HEROES.keys():
		var data: Dictionary = HeroRegistry.get_hero(str(registry_id))
		var existing_key: String = find_existing_key(current, str(registry_id))
		if existing_key == "":
			current[str(registry_id)] = data
			continue
		var merged: Dictionary = current[existing_key] as Dictionary
		for field in ["id", "faction", "active_skill", "reserve_passive", "growth_profile", "portrait", "sprite"]:
			merged[field] = data[field]
		if str(merged.get("name", "")) == "":
			merged["name"] = data["name"]
		current[existing_key] = merged
	host.set("heroes", current)
	canonicalize_roster()

func find_existing_key(collection: Dictionary, registry_id: String) -> String:
	for key in collection.keys():
		if HeroRegistry.canonical_id(str(key)) == registry_id:
			return str(key)
	return ""

func canonicalize_array(values: Array) -> Array:
	var result: Array = []
	var seen: Dictionary = {}
	for value in values:
		var hero_id: String = HeroRegistry.canonical_id(str(value))
		if hero_id == "" or seen.has(hero_id):
			continue
		seen[hero_id] = true
		result.append(hero_id)
	return result

func canonicalize_roster() -> void:
	for property_name in ["active_heroes", "reserve_heroes", "camp_heroes"]:
		var value: Variant = host.get(property_name)
		if value is Array:
			host.set(property_name, canonicalize_array(value as Array))
	var known_value: Variant = host.get("known_heroes")
	if known_value is Dictionary:
		var canonical_known: Dictionary = {}
		for key in (known_value as Dictionary).keys():
			canonical_known[HeroRegistry.canonical_id(str(key))] = (known_value as Dictionary)[key]
		host.set("known_heroes", canonical_known)

func report_audit() -> void:
	var missing: Array = audit_report.get("missing", []) as Array
	var duplicates: Dictionary = audit_report.get("duplicate_portraits", {}) as Dictionary
	for message in missing:
		push_warning("Alpha.43名將素材檢查｜%s" % str(message))
	for portrait_path in duplicates.keys():
		push_warning("Alpha.43立繪重複｜%s：%s" % [portrait_path, str(duplicates[portrait_path])])
	var game_events: Node = get_node_or_null("/root/GameEvents")
	if game_events != null and game_events.has_signal("hero_registered"):
		for hero_id in HeroRegistry.HEROES.keys():
			game_events.emit_signal("hero_registered", HeroRegistry.get_hero(str(hero_id)))

func get_hero(value: String) -> Dictionary:
	return HeroRegistry.get_hero(value)

func canonical_id(value: String) -> String:
	return HeroRegistry.canonical_id(value)
