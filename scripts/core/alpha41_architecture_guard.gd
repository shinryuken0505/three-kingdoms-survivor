extends Node

const ContentRegistryScript = preload("res://scripts/core/content_registry.gd")
const ChapterFlowContractScript = preload("res://scripts/systems/chapter/chapter_flow_contract.gd")

var registry: ContentRegistry
var audit_report: Dictionary = {}
var audited_scene_id: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	registry = ContentRegistryScript.new()

func _process(_delta: float) -> void:
	var host: Node = get_tree().current_scene
	if host == null:
		return
	var scene_id: int = host.get_instance_id()
	if scene_id == audited_scene_id:
		return
	audited_scene_id = scene_id
	call_deferred("audit_host", host)

func audit_host(host: Node) -> void:
	var warnings: PackedStringArray = []
	var required_properties: PackedStringArray = [
		"identities", "heroes", "relic_defs", "merchant_defs", "chapter_manager",
		"active_heroes", "reserve_heroes", "hero_skill_levels", "hero_experience",
	]
	for property_name in required_properties:
		if host.get(property_name) == null:
			warnings.append("missing host property: %s" % property_name)
	var required_methods: PackedStringArray = [
		"current_chapter", "save_checkpoint", "open_hero_config", "show_message",
	]
	for method_name in required_methods:
		if not host.has_method(method_name):
			warnings.append("missing host method: %s" % method_name)
	audit_report = {
		"scene": host.name,
		"warning_count": warnings.size(),
		"warnings": warnings,
		"chapter_phase_contract": ChapterFlowContractScript.phase_name(ChapterFlowContractScript.Phase.INTRO),
		"migration_mode": "adapter_first",
	}
	if not warnings.is_empty():
		push_warning("Alpha41 architecture audit: %s" % "; ".join(warnings))

func validate_content(kind: String, definition: Dictionary) -> PackedStringArray:
	return registry.validate_definition(kind, definition)

func register_content(kind: String, definition: Dictionary) -> bool:
	return registry.register(kind, definition)

func architecture_snapshot() -> Dictionary:
	return audit_report.duplicate(true)
