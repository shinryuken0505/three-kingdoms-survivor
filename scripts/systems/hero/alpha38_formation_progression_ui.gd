extends Control

const MAX_LEVEL: int = 8
const ACTIVE_CAP_CH1: int = 2
const ACTIVE_CAP_CH2: int = 3
const RESERVE_CAP_CH1: int = 1
const RESERVE_CAP_CH2: int = 2

var host: Variant = null
var selected_index: int = 0
var selected_group: int = 0 # 0=主將 1=後備 2=營地
var status_message: String = ""
var status_timer: float = 0.0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_unhandled_input(true)

func _process(delta: float) -> void:
	host = get_tree().current_scene
	if host == null or not is_instance_valid(host):
		visible = false
		return
	var screen_name: String = str(host.get("screen"))
	visible = screen_name == "hero_config"
	if status_timer > 0.0:
		status_timer -= delta
	queue_redraw()

func chapter_number() -> int:
	if host != null and host.has_method("current_chapter"):
		var chapter: Dictionary = host.call("current_chapter") as Dictionary
		return int(chapter.get("index", 0)) + 1
	return 1

func active_cap() -> int:
	return ACTIVE_CAP_CH1 if chapter_number() <= 1 else ACTIVE_CAP_CH2

func reserve_cap() -> int:
	return RESERVE_CAP_CH1 if chapter_number() <= 1 else RESERVE_CAP_CH2

func group_array(group: int) -> Array:
	match group:
		0: return host.get("active_heroes") as Array
		1: return host.get("reserve_heroes") as Array
		_: return host.get("camp_heroes") as Array

func save_groups(active: Array, reserve: Array, camp: Array) -> void:
	# 去除重複，避免同一名將同時存在於多個位置。
	var seen: Dictionary = {}
	var clean_active: Array = []
	var clean_reserve: Array = []
	var clean_camp: Array = []
	for value in active:
		var hid: String = str(value)
		if hid != "" and not seen.has(hid) and clean_active.size() < active_cap():
			seen[hid] = true
			clean_active.append(hid)
	for value in reserve:
		var hid: String = str(value)
		if hid != "" and not seen.has(hid) and clean_reserve.size() < reserve_cap():
			seen[hid] = true
			clean_reserve.append(hid)
	for value in camp:
		var hid: String = str(value)
		if hid != "" and not seen.has(hid):
			seen[hid] = true
			clean_camp.append(hid)
	host.set("active_heroes", clean_active)
	host.set("reserve_heroes", clean_reserve)
	host.set("camp_heroes", clean_camp)
	if host.has_method("refresh_active_bonds"):
		host.call("refresh_active_bonds")
	if host.has_method("save_checkpoint"):
		host.call_deferred("save_checkpoint", false)

func move_selected(direction: int) -> void:
	var source: Array = group_array(selected_group).duplicate()
	if source.is_empty():
		show_status("目前欄位沒有名將")
		return
	selected_index = clampi(selected_index, 0, source.size() - 1)
	var hid: String = str(source[selected_index])
	var active: Array = (host.get("active_heroes") as Array).duplicate()
	var reserve: Array = (host.get("reserve_heroes") as Array).duplicate()
	var camp: Array = (host.get("camp_heroes") as Array).duplicate()
	var target_group: int = clampi(selected_group + direction, 0, 2)
	if target_group == selected_group:
		return
	var target: Array = active if target_group == 0 else reserve if target_group == 1 else camp
	var cap: int = active_cap() if target_group == 0 else reserve_cap() if target_group == 1 else 999
	if target.size() >= cap:
		show_status("目標欄位已滿，請先移出一位名將")
		return
	active.erase(hid)
	reserve.erase(hid)
	camp.erase(hid)
	target.append(hid)
	save_groups(active, reserve, camp)
	selected_group = target_group
	selected_index = max(0, target.size() - 1)
	show_status("%s已移至%s" % [hero_name(hid), group_name(target_group)])

func swap_selected(step: int) -> void:
	var active: Array = (host.get("active_heroes") as Array).duplicate()
	var reserve: Array = (host.get("reserve_heroes") as Array).duplicate()
	var camp: Array = (host.get("camp_heroes") as Array).duplicate()
	var target: Array = active if selected_group == 0 else reserve if selected_group == 1 else camp
	if target.size() <= 1:
		return
	selected_index = clampi(selected_index, 0, target.size() - 1)
	var next_index: int = wrapi(selected_index + step, 0, target.size())
	var tmp: Variant = target[selected_index]
	target[selected_index] = target[next_index]
	target[next_index] = tmp
	selected_index = next_index
	save_groups(active, reserve, camp)

func hero_name(hero_id: String) -> String:
	var heroes: Dictionary = host.get("heroes") as Dictionary
	return str(heroes.get(hero_id, {}).get("name", hero_id))

func hero_level(hero_id: String) -> int:
	var levels: Dictionary = host.get("hero_skill_levels") as Dictionary
	return clampi(int(levels.get(hero_id, 1)), 1, MAX_LEVEL)

func hero_xp(hero_id: String) -> int:
	var runtime: Node = get_node_or_null("/root/Alpha36Alpha37Runtime")
	if runtime != null:
		var xp_dict: Dictionary = runtime.get("hero_xp") as Dictionary
		return int(xp_dict.get(hero_id, 0))
	return 0

func required_xp(level: int) -> int:
	return 24 + max(0, level - 1) * 18

func speciality(hero_id: String) -> String:
	var key: String = hero_id.to_lower().replace("_", "")
	match key:
		"guanyu": return "斬擊傷害與斬殺能力逐級提升"
		"zhangfei": return "震波範圍、擊退與暈眩逐級提升"
		"zhaoyun": return "突進速度、穿透與連擊逐級提升"
		"zhugeliang": return "術法範圍、控制與冷卻逐級提升"
		"huatuo": return "治療量、治療頻率與回復品質逐級提升"
		"diaochan": return "魅惑範圍、緩速與減益時間逐級提升"
		"sunshangxiang": return "遠程連射、穿透與暴擊逐級提升"
		"caocao": return "統御增傷、冷卻與後備加成逐級提升"
		"lvbu": return "橫掃範圍、爆發傷害與霸體逐級提升"
		_: return "專屬技能威力、冷卻與支援效果逐級成長"

func group_name(group: int) -> String:
	return ["主將", "後備", "營地"][clampi(group, 0, 2)]

func show_status(text: String) -> void:
	status_message = text
	status_timer = 2.2

func _unhandled_input(event: InputEvent) -> void:
	if not visible or host == null:
		return
	if event.is_action_pressed("ui_cancel"):
		if host.has_method("close_hero_config"):
			host.call("close_hero_config")
		else:
			host.set("screen", str(host.get("hero_config_origin")))
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_up"):
		selected_group = wrapi(selected_group - 1, 0, 3)
		selected_index = 0
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_down"):
		selected_group = wrapi(selected_group + 1, 0, 3)
		selected_index = 0
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_left"):
		swap_selected(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right"):
		swap_selected(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		move_selected(1 if selected_group < 2 else -1)
		get_viewport().set_input_as_handled()

func _draw() -> void:
	if not visible or host == null:
		return
	# 完整覆蓋舊整備畫面，所有欄位依1280×720安全區重新配置。
	draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color(0.018, 0.022, 0.026, 0.985), true)
	draw_rect(Rect2(30, 24, 1220, 672), Color(0.035, 0.043, 0.047, 0.98), true)
	draw_rect(Rect2(30, 24, 1220, 672), Color8(123, 109, 75), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(58, 62), "武將整備｜第%d關" % chapter_number(), HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color8(239, 220, 174))
	draw_string(ThemeDB.fallback_font, Vector2(58, 88), "主將參戰取得完整經驗；後備取得部分經驗。Enter移動、左右調整順序、Esc返回。", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color8(181, 190, 187))
	var sections: Array = [
		{"title":"主將 %d/%d" % [(host.get("active_heroes") as Array).size(), active_cap()], "items":host.get("active_heroes") as Array, "y":112.0},
		{"title":"後備 %d/%d" % [(host.get("reserve_heroes") as Array).size(), reserve_cap()], "items":host.get("reserve_heroes") as Array, "y":296.0},
		{"title":"營地名將", "items":host.get("camp_heroes") as Array, "y":480.0},
	]
	for group in range(sections.size()):
		var section: Dictionary = sections[group]
		var y: float = float(section["y"])
		var items: Array = section["items"] as Array
		var selected_group_now: bool = group == selected_group
		draw_rect(Rect2(52, y, 1176, 154), Color(0.022, 0.029, 0.032, 0.96), true)
		draw_rect(Rect2(52, y, 1176, 154), Color8(201, 157, 73) if selected_group_now else Color8(82, 91, 89), false, 2.0 if selected_group_now else 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(68, y + 27), str(section["title"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color8(232, 214, 176))
		if items.is_empty():
			draw_string(ThemeDB.fallback_font, Vector2(88, y + 88), "尚無名將", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color8(116, 124, 122))
		for index in range(items.size()):
			var hid: String = str(items[index])
			var card_x: float = 68.0 + float(index) * 222.0
			if card_x + 206.0 > 1214.0:
				break
			var card: Rect2 = Rect2(card_x, y + 40, 206, 98)
			var selected: bool = selected_group_now and index == selected_index
			draw_rect(card, Color(0.055, 0.062, 0.064, 0.98), true)
			draw_rect(card, Color8(236, 188, 84) if selected else Color8(97, 105, 102), false, 2.0 if selected else 1.0)
			var level: int = hero_level(hid)
			var xp: int = hero_xp(hid)
			var need: int = required_xp(level)
			draw_string(ThemeDB.fallback_font, card.position + Vector2(12, 25), "%s　Lv.%d" % [hero_name(hid), level], HORIZONTAL_ALIGNMENT_LEFT, 180, 16, Color8(238, 225, 196))
			draw_string(ThemeDB.fallback_font, card.position + Vector2(12, 47), speciality(hid), HORIZONTAL_ALIGNMENT_LEFT, 182, 11, Color8(171, 187, 181))
			var bar: Rect2 = Rect2(card.position + Vector2(12, 66), Vector2(182, 7))
			draw_rect(bar, Color8(38, 44, 45), true)
			var ratio: float = 1.0 if level >= MAX_LEVEL else clamp(float(xp) / float(max(1, need)), 0.0, 1.0)
			draw_rect(Rect2(bar.position, Vector2(bar.size.x * ratio, bar.size.y)), Color8(198, 151, 66), true)
			draw_string(ThemeDB.fallback_font, card.position + Vector2(12, 91), "MAX" if level >= MAX_LEVEL else "經驗 %d/%d" % [xp, need], HORIZONTAL_ALIGNMENT_LEFT, 182, 11, Color8(190, 194, 185))
	if status_timer > 0.0 and status_message != "":
		draw_string(ThemeDB.fallback_font, Vector2(640, 682), status_message, HORIZONTAL_ALIGNMENT_CENTER, 600, 16, Color8(241, 202, 101))
