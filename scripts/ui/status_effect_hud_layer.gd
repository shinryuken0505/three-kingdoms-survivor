extends Node2D

## 戰場負面狀態 HUD 接線層。
##
## 作為 Main 的子節點運作，僅讀取父節點既有的 player、screen、font 與
## world_to_screen()。因此不修改戰鬥規則，也不需要在大型 main.gd 中插入繪圖碼。

const HUD_ANCHOR := Rect2(1018.0, 142.0, 244.0, 92.0)
const VIEW_SIZE := Vector2(1280.0, 720.0)
const LEGACY_STATUS_MASK := Rect2(244.0, 57.0, 78.0, 24.0)

var last_plan: Dictionary = {}
var hovered_tooltip: String = ""


func _ready() -> void:
	z_index = 100
	set_process(true)
	set_process_input(true)
	queue_redraw()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	last_plan.clear()
	hovered_tooltip = ""
	var main := get_parent()
	if main == null or not _is_battle_screen(main):
		return
	var player_value: Variant = main.get("player")
	if not (player_value is Dictionary):
		return
	var player: Dictionary = player_value as Dictionary
	if player.is_empty() or not player.has("pos"):
		return
	var hud_font: Font = main.get("font") as Font
	if hud_font == null:
		return
	var player_screen_position: Vector2 = _player_screen_position(main, player)
	if not PlayerStatusAdapter.active_ids(player).is_empty():
		# 過渡期遮住 main.gd 舊版只能顯示單一狀態的文字，避免與新圖示重複。
		draw_rect(LEGACY_STATUS_MASK, Color(0.035, 0.04, 0.045, 0.98), true)
	last_plan = StatusEffectHud.draw(
		self,
		player,
		player_screen_position,
		hud_font,
		VIEW_SIZE,
		HUD_ANCHOR
	)
	_draw_hover_tooltip(hud_font)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		queue_redraw()


func _is_battle_screen(main: Node) -> bool:
	var screen_id: String = str(main.get("screen"))
	return screen_id in ["game", "boss_intro"]


func _player_screen_position(main: Node, player: Dictionary) -> Vector2:
	var world_position: Vector2 = player.get("pos", Vector2.ZERO) as Vector2
	if main.has_method("world_to_screen"):
		var converted: Variant = main.call("world_to_screen", world_position)
		if converted is Vector2:
			return converted as Vector2
	return world_position


func _draw_hover_tooltip(hud_font: Font) -> void:
	if last_plan.is_empty():
		return
	var hovered: Dictionary = StatusEffectHud.hovered_item(last_plan, get_local_mouse_position())
	if hovered.is_empty():
		return
	hovered_tooltip = str(hovered.get("tooltip", ""))
	if hovered_tooltip.is_empty():
		return
	var mouse_position: Vector2 = get_local_mouse_position()
	var width: float = clampf(
		hud_font.get_string_size(hovered_tooltip, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14).x + 24.0,
		180.0,
		430.0
	)
	var rect := Rect2(mouse_position + Vector2(14.0, 16.0), Vector2(width, 38.0))
	rect.position.x = minf(rect.position.x, VIEW_SIZE.x - rect.size.x - 12.0)
	rect.position.y = minf(rect.position.y, VIEW_SIZE.y - rect.size.y - 12.0)
	draw_rect(rect, Color(0.025, 0.03, 0.035, 0.96), true)
	draw_rect(rect, Color(0.78, 0.73, 0.58, 0.92), false, 1.5)
	draw_string(
		hud_font,
		rect.position + Vector2(12.0, 25.0),
		hovered_tooltip,
		HORIZONTAL_ALIGNMENT_LEFT,
		rect.size.x - 24.0,
		14,
		Color(0.96, 0.95, 0.88)
	)
