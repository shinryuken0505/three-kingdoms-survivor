extends Node

const RelicContentRegistry = preload("res://scripts/systems/relic/relic_content_registry.gd")
const MerchantContentRegistry = preload("res://scripts/systems/merchant/merchant_content_registry.gd")

var host: Variant = null
var normalized_once: bool = false
var previous_relics: Array = []
var previous_merchant_active: bool = false
var merchant_open_count: int = 0
var run_token: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for error_text in MerchantContentRegistry.validate():
		push_warning("Alpha44 merchant registry: %s" % error_text)

func _process(_delta: float) -> void:
	host = get_tree().current_scene
	if host == null or not is_instance_valid(host):
		return
	var player: Dictionary = host.get("player") as Dictionary
	if player.is_empty():
		reset_runtime()
		return
	var current_token: String = "%s:%s" % [str(host.get("chosen_identity")), str(player.get("run_seed", player.get("level", 1)))]
	if current_token != run_token:
		reset_runtime()
		run_token = current_token
	if not normalized_once:
		normalize_content()
		normalized_once = true
	observe_relic_changes()
	observe_merchant_state()
	publish_rules_to_host()

func reset_runtime() -> void:
	normalized_once = false
	previous_relics.clear()
	previous_merchant_active = false
	merchant_open_count = 0
	run_token = ""

func normalize_content() -> void:
	var legacy_relics: Dictionary = host.get("relic_defs") as Dictionary
	if not legacy_relics.is_empty():
		var normalized: Dictionary = RelicContentRegistry.build_from_legacy(legacy_relics)
		for error_text in RelicContentRegistry.validate(normalized):
			push_warning("Alpha44 relic registry: %s" % error_text)
		host.set("relic_defs", normalized)
	var legacy_merchants: Dictionary = host.get("merchant_defs") as Dictionary
	for merchant_id in MerchantContentRegistry.MERCHANTS.keys():
		var current: Dictionary = legacy_merchants.get(merchant_id, {}) as Dictionary
		var registry_def: Dictionary = MerchantContentRegistry.get_definition(str(merchant_id))
		for key in registry_def.keys():
			if not current.has(key):
				current[key] = registry_def[key]
		legacy_merchants[merchant_id] = current
	host.set("merchant_defs", legacy_merchants)

func publish_rules_to_host() -> void:
	var player: Dictionary = host.get("player") as Dictionary
	if player.is_empty():
		return
	player["alpha44_merchant_rules"] = MerchantContentRegistry.RUN_RULES.duplicate(true)
	player["alpha44_merchant_visits"] = merchant_open_count
	player["alpha44_refresh_cost"] = MerchantContentRegistry.refresh_cost(int(host.get("merchant_visit")))
	host.set("player", player)

func observe_relic_changes() -> void:
	var current_relics: Array = (host.get("relics") as Array).duplicate()
	if previous_relics.is_empty():
		previous_relics = current_relics
		return
	for relic_value in current_relics:
		var relic_id: String = RelicContentRegistry.normalize_id(str(relic_value))
		if previous_relics.has(relic_value):
			continue
		var definition: Dictionary = (host.get("relic_defs") as Dictionary).get(relic_id, {}) as Dictionary
		emit_relic_event("on_acquired", relic_id, {"definition": definition})
	previous_relics = current_relics

func observe_merchant_state() -> void:
	var active: bool = bool(host.get("merchant_active"))
	if active and not previous_merchant_active:
		merchant_open_count += 1
		var merchant_id: String = MerchantContentRegistry.normalize_id(str(host.get("merchant_kind")))
		var definition: Dictionary = MerchantContentRegistry.get_definition(merchant_id)
		var events: Node = get_node_or_null("/root/GameEvents")
		if events != null and events.has_signal("merchant_opened"):
			events.emit_signal("merchant_opened", merchant_id, definition)
	if not active and previous_merchant_active:
		# 商人離場後統一使用集中間隔，避免短時間連續生成。
		var min_interval: float = float(MerchantContentRegistry.RUN_RULES["min_interval"])
		var max_interval: float = float(MerchantContentRegistry.RUN_RULES["max_interval"])
		host.set("merchant_spawn_timer", randf_range(min_interval, max_interval))
	previous_merchant_active = active

func emit_relic_event(hook: String, relic_id: String, context: Dictionary = {}) -> void:
	var payload: Dictionary = context.duplicate(true)
	payload["hook"] = hook
	payload["relic_id"] = relic_id
	var events: Node = get_node_or_null("/root/GameEvents")
	if events != null and events.has_signal("relic_acquired") and hook == "on_acquired":
		events.emit_signal("relic_acquired", relic_id, payload)

func merchant_price_multiplier(chapter_number: int, discount_mult: float = 1.0) -> float:
	if host == null:
		return 1.0
	return MerchantContentRegistry.price_multiplier(str(host.get("merchant_kind")), chapter_number, discount_mult)

func relic_definition(relic_id: String) -> Dictionary:
	if host == null:
		return {}
	var normalized: String = RelicContentRegistry.normalize_id(relic_id)
	return ((host.get("relic_defs") as Dictionary).get(normalized, {}) as Dictionary).duplicate(true)
