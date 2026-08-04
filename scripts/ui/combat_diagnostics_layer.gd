extends Node2D

## Alpha.19 F3 戰鬥診斷層。
## 僅在 debug_overlay 開啟且戰鬥中顯示，不影響正式 UI。

var _main: Node = null
var _font: Font = null


func _ready() -> void:
	_main = get_parent()
	_font = SystemFont.new()
	(_font as SystemFont).font_names = PackedStringArray(["Microsoft JhengHei", "Noto Sans CJK TC", "Arial"])
	z_index = 220
	set_process(true)


func _process(_delta: float) -> void:
	visible = _main != null and bool(_main.get("debug_overlay")) and str(_main.get("screen")) == "game"
	if visible:
		queue_redraw()


func _draw() -> void:
	if _main == null or not visible:
		return
	var player_value: Variant = _main.get("player")
	if not (player_value is Dictionary):
		return
	var player: Dictionary = player_value as Dictionary
	var rect: Rect2 = Rect2(12.0, 248.0, 344.0, 214.0)
	draw_rect(rect, Color(0.02, 0.025, 0.03, 0.90), true)
	draw_rect(rect, Color(0.45, 0.72, 0.78, 0.92), false, 1.5)
	_draw_line("Alpha.19 戰鬥診斷", rect.position + Vector2(12.0, 24.0), 15, Color(0.80, 0.93, 0.96))
	var identity: Dictionary = player.get("alpha19_identity_state", {}) as Dictionary
	var reserve: Dictionary = player.get("alpha19_reserve_passive_state", {}) as Dictionary
	var active: Dictionary = player.get("alpha19_active_specialization_state", {}) as Dictionary
	var y: float = rect.position.y + 49.0
	y = _metric("總傷害", float(player.get("damage", 0.0)), y)
	y = _metric("投射倍率", float(player.get("projectile_mult", 1.0)), y)
	y = _metric("毒傷倍率", float(player.get("poison_power", 1.0)), y)
	y = _metric("名將冷卻倍率", float(player.get("hero_cd_mult", 1.0)), y)
	y = _metric("暴擊率", float(player.get("crit", 0.0)) * 100.0, y, "%")
	y = _state_line("身份加成", identity, y)
	y = _state_line("主戰專精", active, y)
	y = _state_line("後備被動", reserve, y)
	var chapter_index: int = _current_chapter_index()
	_draw_line("章節威脅：第 %d 章" % (chapter_index + 1), Vector2(rect.position.x + 12.0, y), 12, Color(0.80, 0.75, 0.61))


func _metric(label: String, value: float, y: float, suffix: String = "") -> float:
	_draw_line("%s：%.2f%s" % [label, value, suffix], Vector2(24.0, y), 12, Color(0.86, 0.87, 0.84))
	return y + 20.0


func _state_line(label: String, state: Dictionary, y: float) -> float:
	var summary: String = "無"
	if not state.is_empty():
		var parts: Array[String] = []
		for key in ["damage_mult", "projectile_mult", "poison_mult", "heal_mult"]:
			if state.has(key) and absf(float(state[key]) - 1.0) > 0.001:
				parts.append("%s %.2f" % [str(key), float(state[key])])
		if not parts.is_empty():
			summary = "／".join(parts)
	_draw_line("%s：%s" % [label, summary], Vector2(24.0, y), 11, Color(0.70, 0.80, 0.82))
	return y + 18.0


func _current_chapter_index() -> int:
	var manager: Variant = _main.get("chapter_manager")
	if manager != null and manager.has_method("current_index_value"):
		return int(manager.call("current_index_value"))
	return 0


func _draw_line(text: String, position: Vector2, size: int, color: Color) -> void:
	draw_string(_font, position, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
