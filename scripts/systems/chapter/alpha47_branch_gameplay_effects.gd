extends Control

const SpecialTradeRegistry = preload("res://scripts/systems/merchant/special_trade_registry.gd")

var host: Variant = null
var current_chapter_id: String = ""
var reinforcement_spawned_for: String = ""
var weighted_encounter_signature: String = ""
var trade_open: bool = false
var trade_index: int = 0
var trade_used: Dictionary = {}
var branch_notice_shown_for: String = ""

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_unhandled_input(true)
	for error_text in SpecialTradeRegistry.validate():
		push_warning("Alpha47 special trade registry: %s" % error_text)

func _process(_delta: float) -> void:
	host = get_tree().current_scene
	if host == null or not is_instance_valid(host):
		visible = false
		return
	observe_chapter()
	apply_reinforcement()
	apply_recruit_weighting()
	visible = trade_open
	if trade_open:
		queue_redraw()

func observe_chapter() -> void:
	var manager: Variant = host.get("chapter_manager")
	var chapter_id: String = ""
	if manager != null and manager.has_method("current_id"):
		chapter_id = str(manager.call("current_id"))
	if chapter_id == "" and host.has_method("current_chapter"):
		chapter_id = str((host.call("current_chapter") as Dictionary).get("id", ""))
	if chapter_id == current_chapter_id:
		return
	current_chapter_id = chapter_id
	weighted_encounter_signature = ""
	trade_open = false
	trade_index = 0
	if not trade_used.has(chapter_id):
		trade_used[chapter_id] = {}
	show_branch_result_notice()

func branch_player() -> Dictionary:
	return host.get("player") as Dictionary

func show_branch_result_notice() -> void:
	if current_chapter_id == "" or branch_notice_shown_for == current_chapter_id:
		return
	var player: Dictionary = branch_player()
	var reinforcement: String = str(player.get("alpha46_reinforcement", ""))
	var merchant: String = str(player.get("alpha46_merchant_override", ""))
	var pieces: Array[String] = []
	if reinforcement != "":
		pieces.append(reinforcement_label(reinforcement) + "將於本章支援")
	if merchant != "":
		pieces.append("特殊商人：%s" % merchant_label(merchant))
	if not pieces.is_empty() and host.has_method("show_message"):
		host.call("show_message", "前章選擇的影響｜%s" % "・".join(pieces), 3.2)
	branch_notice_shown_for = current_chapter_id

func reinforcement_label(value: String) -> String:
	match value:
		"refugee_guard": return "洛陽護衛"
		"xuzhou_volunteers": return "徐州義勇軍"
		"guandu_scouts": return "官渡斥候"
		_: return value

func merchant_label(value: String) -> String:
	match value:
		"healer": return "醫者"
		"antiquarian": return "古董商"
		"quartermaster": return "軍需官"
		"blacksmith": return "鐵匠"
		"mystery": return "神秘商人"
		_: return value

func apply_reinforcement() -> void:
	if current_chapter_id == "" or reinforcement_spawned_for == current_chapter_id:
		return
	if str(host.get("screen")) != "game":
		return
	var player: Dictionary = branch_player()
	if player.is_empty():
		return
	var reinforcement: String = str(player.get("alpha46_reinforcement", ""))
	if reinforcement == "":
		reinforcement_spawned_for = current_chapter_id
		return
	var center: Vector2 = player.get("pos", Vector2.ZERO) as Vector2
	var allies: Array = host.get("allies") as Array
	var count: int = 3
	var hp: float = 38.0
	var life: float = 24.0
	var damage: float = 12.0
	match reinforcement:
		"refugee_guard":
			count = 3; hp = 42.0; life = 28.0; damage = 10.0
		"xuzhou_volunteers":
			count = 4; hp = 46.0; life = 30.0; damage = 13.0
		"guandu_scouts":
			count = 3; hp = 34.0; life = 26.0; damage = 15.0
	for i in range(count):
		allies.append({
			"pos": center + Vector2.from_angle(float(i) / float(count) * TAU) * 48.0,
			"hp": hp,
			"life": life,
			"damage": damage,
			"hit_cd": 0.0,
			"anim": 0.0,
			"alpha47_reinforcement": reinforcement
		})
	host.set("allies", allies)
	reinforcement_spawned_for = current_chapter_id
	if host.has_method("show_message"):
		host.call("show_message", "%s抵達戰場！" % reinforcement_label(reinforcement), 2.6)

func apply_recruit_weighting() -> void:
	var candidates: Array = host.get("encounter_candidates") as Array
	if candidates.is_empty():
		weighted_encounter_signature = ""
		return
	var signature: String = "%s:%s" % [current_chapter_id, str(candidates)]
	if signature == weighted_encounter_signature:
		return
	weighted_encounter_signature = signature
	var player: Dictionary = branch_player()
	var weights: Dictionary = player.get("alpha46_hero_weight_bonus", {}) as Dictionary
	if weights.is_empty():
		return
	var manager: Variant = host.get("chapter_manager")
	var pool: Array = []
	if manager != null and manager.has_method("hero_pool"):
		pool = manager.call("hero_pool") as Array
	var known: Dictionary = host.get("known_heroes") as Dictionary
	var weighted_options: Array[String] = []
	for hero_value in weights.keys():
		var hero_id: String = str(hero_value)
		if not pool.is_empty() and not pool.has(hero_id):
			continue
		if known.has(hero_id):
			continue
		if candidates.has(hero_id):
			continue
		var bonus: float = max(1.0, float(weights.get(hero_id, 1.0)))
		var chance: float = clamp((bonus - 1.0) * 1.45, 0.08, 0.48)
		if randf() <= chance:
			weighted_options.append(hero_id)
	if weighted_options.is_empty():
		return
	var chosen: String = weighted_options[randi() % weighted_options.size()]
	if candidates.size() >= 2:
		candidates[candidates.size() - 1] = chosen
	else:
		candidates.append(chosen)
	host.set("encounter_candidates", candidates)
	if str(host.get("current_encounter")) == "" and not candidates.is_empty():
		host.set("current_encounter", str(candidates[0]))

func current_trades() -> Array[Dictionary]:
	if host == null:
		return []
	var merchant_id: String = str(host.get("merchant_kind"))
	var chapter_number: int = 1
	if host.has_method("current_chapter"):
		chapter_number = int((host.call("current_chapter") as Dictionary).get("index", 0)) + 1
	return SpecialTradeRegistry.trades_for(merchant_id, chapter_number)

func _unhandled_input(event: InputEvent) -> void:
	if host == null:
		return
	if str(host.get("screen")) == "shop" and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_T:
		var trades: Array[Dictionary] = current_trades()
		if trades.is_empty():
			return
		trade_open = not trade_open
		trade_index = clampi(trade_index, 0, max(0, trades.size() - 1))
		get_viewport().set_input_as_handled()
		queue_redraw()
		return
	if not trade_open:
		return
	var trades: Array[Dictionary] = current_trades()
	if trades.is_empty():
		trade_open = false
		return
	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_left"):
		trade_index = wrapi(trade_index - 1, 0, trades.size())
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right"):
		trade_index = wrapi(trade_index + 1, 0, trades.size())
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		execute_trade(trades[trade_index])
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		trade_open = false
		get_viewport().set_input_as_handled()

func trade_key(trade_id: String) -> String:
	return "%s:%s" % [current_chapter_id, trade_id]

func trade_is_used(definition: Dictionary) -> bool:
	if not bool(definition.get("once_per_chapter", false)):
		return false
	return bool((trade_used.get(current_chapter_id, {}) as Dictionary).get(str(definition.get("id", "")), false))

func trade_context() -> Dictionary:
	var player: Dictionary = branch_player()
	return {
		"coins": int(player.get("coins", 0)),
		"relic_count": (host.get("relics") as Array).size(),
		"max_hp": float(player.get("max_hp", 1.0))
	}

func execute_trade(definition: Dictionary) -> void:
	if trade_is_used(definition):
		if host.has_method("show_message"):
			host.call("show_message", "本章已完成過這項特殊交易。", 1.8)
		return
	if not SpecialTradeRegistry.can_afford(definition, trade_context()):
		if host.has_method("show_message"):
			host.call("show_message", "目前無法支付這項交易的代價。", 1.8)
		return
	var player: Dictionary = branch_player()
	var cost: Dictionary = definition.get("cost", {}) as Dictionary
	player["coins"] = int(player.get("coins", 0)) - int(cost.get("coins", 0))
	if float(cost.get("max_hp_ratio", 0.0)) > 0.0:
		var loss: float = float(player.get("max_hp", 1.0)) * float(cost.get("max_hp_ratio", 0.0))
		player["max_hp"] = max(20.0, float(player.get("max_hp", 1.0)) - loss)
		player["hp"] = min(float(player.get("hp", 1.0)), float(player["max_hp"]))
	if int(cost.get("relic_count", 0)) > 0:
		var relics: Array = host.get("relics") as Array
		for _i in range(min(int(cost.get("relic_count", 0)), relics.size())):
			relics.remove_at(relics.size() - 1)
		host.set("relics", relics)
	host.set("player", player)
	apply_trade_reward(definition.get("reward", {}) as Dictionary)
	if bool(definition.get("once_per_chapter", false)):
		var used: Dictionary = trade_used.get(current_chapter_id, {}) as Dictionary
		used[str(definition.get("id", ""))] = true
		trade_used[current_chapter_id] = used
	if host.has_method("show_message"):
		host.call("show_message", "特殊交易完成｜%s" % str(definition.get("name", "交易")), 2.2)
	trade_open = false

func apply_trade_reward(reward: Dictionary) -> void:
	var player: Dictionary = branch_player()
	if float(reward.get("heal_ratio", 0.0)) > 0.0:
		player["hp"] = min(float(player.get("max_hp", 1.0)), float(player.get("hp", 0.0)) + float(player.get("max_hp", 1.0)) * float(reward.get("heal_ratio", 0.0)))
		host.set("player", player)
	if int(reward.get("rare_relic", 0)) > 0:
		grant_random_relic_by_rarity(["rare", "epic"])
	if int(reward.get("equipment_reroll", 0)) > 0:
		reroll_equipment_stock()
	if int(reward.get("equipment_upgrade", 0)) > 0:
		upgrade_equipped_item()
	if int(reward.get("legendary_offer", 0)) > 0:
		add_legendary_offer()
	if host.has_method("open_shop"):
		host.call_deferred("open_shop")

func grant_random_relic_by_rarity(rarities: Array[String]) -> void:
	var defs: Dictionary = host.get("relic_defs") as Dictionary
	var owned: Array = host.get("relics") as Array
	var options: Array[String] = []
	for value in defs.keys():
		var rid: String = str(value)
		var definition: Dictionary = defs[rid] as Dictionary
		if rarities.has(str(definition.get("rarity", "common"))) and not owned.has(rid):
			options.append(rid)
	if options.is_empty():
		return
	var rid: String = options[randi() % options.size()]
	if host.has_method("grant_relic"):
		host.call("grant_relic", rid, "特殊交易", false)

func reroll_equipment_stock() -> void:
	var defs: Dictionary = host.get("equipment_defs") as Dictionary
	var keys: Array = defs.keys()
	keys.shuffle()
	var stock: Array = []
	for value in keys:
		stock.append(str(value))
		if stock.size() >= 3:
			break
	host.set("merchant_equipment_stock", stock)

func upgrade_equipped_item() -> void:
	var equipped: Dictionary = host.get("equipped") as Dictionary
	var defs: Dictionary = host.get("equipment_defs") as Dictionary
	for slot in ["weapon", "body", "treasure", "accessory", "jade"]:
		var eid: String = str(equipped.get(slot, ""))
		if eid == "" or not defs.has(eid):
			continue
		var definition: Dictionary = defs[eid] as Dictionary
		var effects: Dictionary = definition.get("effects", {}) as Dictionary
		for key in effects.keys():
			if effects[key] is float or effects[key] is int:
				var value: float = float(effects[key])
				if value >= 1.0:
					effects[key] = 1.0 + (value - 1.0) * 1.18
				else:
					effects[key] = max(0.5, value * 0.96)
		definition["effects"] = effects
		definition["alpha47_reforged"] = int(definition.get("alpha47_reforged", 0)) + 1
		defs[eid] = definition
		host.set("equipment_defs", defs)
		return

func add_legendary_offer() -> void:
	var defs: Dictionary = host.get("relic_defs") as Dictionary
	var stock: Array = host.get("merchant_stock") as Array
	var options: Array[String] = []
	for value in defs.keys():
		var rid: String = str(value)
		var rarity: String = str((defs[rid] as Dictionary).get("rarity", "common"))
		if rarity in ["legendary", "mythic"] and not stock.has(rid):
			options.append(rid)
	if options.is_empty():
		return
	stock.append(options[randi() % options.size()])
	host.set("merchant_stock", stock)

func _draw() -> void:
	if host == null or str(host.get("screen")) != "shop":
		return
	if not trade_open:
		draw_rect(Rect2(930, 650, 240, 36), Color(0.03, 0.035, 0.034, 0.92), true)
		draw_string(ThemeDB.fallback_font, Vector2(946, 674), "T　特殊交易", HORIZONTAL_ALIGNMENT_LEFT, 200, 14, Color8(229, 197, 121))
		return
	var trades: Array[Dictionary] = current_trades()
	draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color(0.0, 0.0, 0.0, 0.72), true)
	var panel: Rect2 = Rect2(300, 170, 680, 380)
	draw_rect(panel, Color(0.035, 0.040, 0.039, 0.99), true)
	draw_rect(panel, Color8(191, 151, 76), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(336, 216), "%s｜特殊交易" % merchant_label(str(host.get("merchant_kind"))), HORIZONTAL_ALIGNMENT_LEFT, 560, 25, Color8(239, 216, 167))
	for i in range(trades.size()):
		var trade: Dictionary = trades[i]
		var rect: Rect2 = Rect2(340, 246 + i * 82, 600, 64)
		var selected: bool = i == trade_index
		draw_rect(rect, Color(0.10, 0.083, 0.045, 0.96) if selected else Color(0.055, 0.060, 0.058, 0.96), true)
		draw_rect(rect, Color8(231, 188, 91) if selected else Color8(92, 100, 96), false, 2.0 if selected else 1.0)
		var cost: Dictionary = trade.get("cost", {}) as Dictionary
		var cost_text: Array[String] = []
		if int(cost.get("coins", 0)) > 0: cost_text.append("%d銅錢" % int(cost["coins"]))
		if int(cost.get("relic_count", 0)) > 0: cost_text.append("%d件遺物" % int(cost["relic_count"]))
		if float(cost.get("max_hp_ratio", 0.0)) > 0.0: cost_text.append("%d%%生命上限" % int(float(cost["max_hp_ratio"]) * 100.0))
		var used_text: String = "（本章已使用）" if trade_is_used(trade) else ""
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(18, 27), "%s %s" % [str(trade.get("name", "交易")), used_text], HORIZONTAL_ALIGNMENT_LEFT, 330, 17, Color8(235, 221, 190))
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(360, 27), "代價：%s" % "＋".join(cost_text), HORIZONTAL_ALIGNMENT_LEFT, 220, 14, Color8(205, 174, 116))
	draw_string(ThemeDB.fallback_font, Vector2(640, 526), "方向鍵選擇　Enter 交易　Esc 返回", HORIZONTAL_ALIGNMENT_CENTER, 520, 14, Color8(180, 188, 182))
