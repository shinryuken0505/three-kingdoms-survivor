extends Control

const ChapterBranchRegistry = preload("res://scripts/systems/chapter/chapter_branch_registry.gd")

var host: Variant = null
var flow: Node = null
var selected_index: int = 0
var applied_branch: String = ""
var previous_screen: String = ""
var transition_lock: bool = false

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_unhandled_input(true)
	visible = false

func _process(_delta: float) -> void:
	host = get_tree().current_scene
	flow = get_node_or_null("/root/Alpha45ChapterBranchFlow")
	if host == null or flow == null or not is_instance_valid(host):
		visible = false
		return
	var state: Dictionary = flow.get("state") as Dictionary
	var phase: String = str(state.get("phase", ""))
	if phase == "branch":
		if (state.get("available_branches", []) as Array).is_empty() and flow.has_method("refresh_available_branches"):
			flow.call("refresh_available_branches")
			state = flow.get("state") as Dictionary
		var choices: Array = state.get("available_branches", []) as Array
		selected_index = clampi(selected_index, 0, max(0, choices.size() - 1))
		visible = not choices.is_empty()
		queue_redraw()
	else:
		visible = false
	observe_formation_completion(phase)
	apply_pending_branch_runtime_effects()
	previous_screen = str(host.get("screen"))

func branch_choices() -> Array:
	if flow == null:
		return []
	return ((flow.get("state") as Dictionary).get("available_branches", []) as Array)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	var choices: Array = branch_choices()
	if choices.is_empty():
		return
	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_left"):
		selected_index = wrapi(selected_index - 1, 0, choices.size())
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right"):
		selected_index = wrapi(selected_index + 1, 0, choices.size())
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		confirm_selected()
		get_viewport().set_input_as_handled()

func confirm_selected() -> void:
	var choices: Array = branch_choices()
	if choices.is_empty() or selected_index < 0 or selected_index >= choices.size():
		return
	var branch_id: String = str(choices[selected_index])
	if not flow.has_method("select_branch") or not bool(flow.call("select_branch", branch_id)):
		return
	applied_branch = branch_id
	var definition: Dictionary = ChapterBranchRegistry.get_definition(branch_id)
	var effects: Dictionary = definition.get("effects", {}) as Dictionary
	apply_branch_payload(branch_id, effects)
	# 分支完成後固定先進武將整備，再由狀態機自動存檔。
	host.set("hero_config_origin", "chapter_branch")
	if host.has_method("open_hero_config"):
		host.call("open_hero_config")
	else:
		host.set("screen", "hero_config")
	visible = false

func apply_branch_payload(branch_id: String, effects: Dictionary) -> void:
	var player: Dictionary = host.get("player") as Dictionary
	player["alpha46_selected_branch"] = branch_id
	player["alpha46_next_chapter"] = str(effects.get("next_chapter", ""))
	player["alpha46_reinforcement"] = str(effects.get("reinforcement", ""))
	player["alpha46_boss_variant"] = str(effects.get("boss_variant", ""))
	player["alpha46_hero_weight_bonus"] = (effects.get("hero_weight_bonus", {}) as Dictionary).duplicate(true)
	player["alpha46_merchant_override"] = str(effects.get("merchant_override", ""))
	player["alpha46_branch_consumed"] = false
	host.set("player", player)
	var merchant_override: String = str(effects.get("merchant_override", ""))
	if merchant_override != "":
		host.set("merchant_kind", merchant_override)
	if host.has_method("show_message"):
		host.call("show_message", "歷史路線已確定｜%s" % str(ChapterBranchRegistry.get_definition(branch_id).get("name", branch_id)), 2.2)

func observe_formation_completion(phase: String) -> void:
	if flow == null or transition_lock:
		return
	var screen_name: String = str(host.get("screen"))
	if phase == "formation" and previous_screen == "hero_config" and screen_name != "hero_config":
		transition_lock = true
		if flow.has_method("request_autosave"):
			flow.call("request_autosave")
		call_deferred("finish_chapter_transition")

func finish_chapter_transition() -> void:
	if host == null:
		transition_lock = false
		return
	var player: Dictionary = host.get("player") as Dictionary
	var target_id: String = str(player.get("alpha46_next_chapter", ""))
	var manager: Variant = host.get("chapter_manager")
	var advanced: bool = false
	if manager != null and target_id != "" and manager.has_method("advance_to_id"):
		advanced = bool(manager.call("advance_to_id", target_id))
	if not advanced and manager != null and manager.has_method("advance_to_next"):
		advanced = bool(manager.call("advance_to_next"))
	if advanced:
		player["alpha46_branch_consumed"] = true
		host.set("player", player)
		if host.has_method("start_chapter_intro"):
			host.call("start_chapter_intro")
		else:
			host.set("screen", "chapter_intro")
	transition_lock = false

func apply_pending_branch_runtime_effects() -> void:
	if host == null:
		return
	var player: Dictionary = host.get("player") as Dictionary
	if player.is_empty() or bool(player.get("alpha46_branch_consumed", false)):
		return
	# 將分支資料提供給既有系統：商人可立即覆寫；名將權重與援軍/Boss變體保存在主角狀態供後續生成流程讀取。
	var merchant_override: String = str(player.get("alpha46_merchant_override", ""))
	if merchant_override != "" and not bool(host.get("merchant_active")):
		host.set("merchant_kind", merchant_override)
	var boss_variant: String = str(player.get("alpha46_boss_variant", ""))
	if boss_variant != "":
		var boss: Dictionary = host.get("boss") as Dictionary
		if not boss.is_empty() and not bool(boss.get("alpha46_variant_applied", false)):
			match boss_variant:
				"alliance_aftermath":
					boss["max_hp"] = float(boss.get("max_hp", boss.get("hp", 1.0))) * 1.08
					boss["hp"] = min(float(boss.get("hp", 1.0)) * 1.08, float(boss["max_hp"]))
					boss["damage"] = float(boss.get("damage", 10.0)) * 1.06
			boss["alpha46_variant_applied"] = true
			host.set("boss", boss)

func _draw() -> void:
	if not visible:
		return
	var choices: Array = branch_choices()
	draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color(0.012, 0.016, 0.020, 0.965), true)
	draw_rect(Rect2(92, 62, 1096, 596), Color(0.035, 0.040, 0.041, 0.98), true)
	draw_rect(Rect2(92, 62, 1096, 596), Color8(161, 132, 75), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(124, 112), "史勢演變｜選擇下一段道路", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color8(239, 219, 174))
	draw_string(ThemeDB.fallback_font, Vector2(124, 142), "你的行動與同行名將會讓部分道路出現，但遊戲不揭露隱藏機率與內部權重。", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color8(181, 190, 187))
	var card_h: float = 188.0
	var gap: float = 24.0
	var count: int = max(1, choices.size())
	var total_h: float = float(count) * card_h + float(max(0, count - 1)) * gap
	var start_y: float = 170.0 + max(0.0, (430.0 - total_h) * 0.5)
	for index in range(choices.size()):
		var branch_id: String = str(choices[index])
		var definition: Dictionary = ChapterBranchRegistry.get_definition(branch_id)
		var card: Rect2 = Rect2(150, start_y + float(index) * (card_h + gap), 980, card_h)
		var selected: bool = index == selected_index
		draw_rect(card, Color(0.055, 0.061, 0.060, 0.98), true)
		draw_rect(card, Color8(230, 183, 82) if selected else Color8(92, 99, 96), false, 3.0 if selected else 1.0)
		draw_string(ThemeDB.fallback_font, card.position + Vector2(24, 38), str(definition.get("name", branch_id)), HORIZONTAL_ALIGNMENT_LEFT, 430, 22, Color8(241, 226, 191))
		draw_string(ThemeDB.fallback_font, card.position + Vector2(24, 72), str(definition.get("description", "")), HORIZONTAL_ALIGNMENT_LEFT, 910, 15, Color8(193, 202, 198))
		var summary: Array[String] = ChapterBranchRegistry.effect_summary(branch_id)
		for line_index in range(summary.size()):
			draw_string(ThemeDB.fallback_font, card.position + Vector2(32, 112 + line_index * 23), "• %s" % summary[line_index], HORIZONTAL_ALIGNMENT_LEFT, 880, 13, Color8(163, 191, 181))
		if selected:
			draw_string(ThemeDB.fallback_font, card.position + Vector2(790, 42), "Enter 決定", HORIZONTAL_ALIGNMENT_LEFT, 150, 14, Color8(245, 198, 92))
	draw_string(ThemeDB.fallback_font, Vector2(640, 635), "↑↓／←→ 選擇　Enter 確認", HORIZONTAL_ALIGNMENT_CENTER, 500, 14, Color8(180, 187, 181))
