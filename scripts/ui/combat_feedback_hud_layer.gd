extends Node2D

## Alpha.19 戰場內嵌回饋。
## 僅在既有 HUD 安全區顯示閃避冷卻、護盾包覆與 Boss 大招預警，
## 不新增大型浮動面板，也不接管輸入。

const VIEW_SIZE := Vector2(1280.0, 720.0)
const DASH_RECT := Rect2(94.0, 603.0, 180.0, 12.0)
const BOSS_WARNING_RECT := Rect2(430.0, 157.0, 420.0, 30.0)

var _main: Node = null
var _font: Font = null
var _font_bold: Font = null
var _last_shield: float = 0.0
var _shield_break_flash: float = 0.0


func _ready() -> void:
	_main = get_parent()
	z_index = 108
	set_process(true)


func _process(delta: float) -> void:
	_shield_break_flash = maxf(0.0, _shield_break_flash - delta)
	if _main != null:
		var player_value: Variant = _main.get("player")
		if player_value is Dictionary:
			var player: Dictionary = player_value as Dictionary
			var shield: float = float(player.get("shield", 0.0))
			if _last_shield > 0.0 and shield <= 0.0:
				_shield_break_flash = 0.34
				if _main.has_method("play_sfx"):
					_main.call("play_sfx", "shield_break", 1.0)
			_last_shield = shield
	queue_redraw()


func _draw() -> void:
	if _main == null:
		return
	var screen: String = str(_main.get("screen"))
	if screen != "game" and screen != "boss_intro":
		return
	var player_value: Variant = _main.get("player")
	if not (player_value is Dictionary):
		return
	var player: Dictionary = player_value as Dictionary
	if player.is_empty():
		return
	_resolve_fonts()
	_draw_dash_cooldown(player)
	_draw_player_shield(player)
	_draw_boss_warning()


func _resolve_fonts() -> void:
	if _font != null:
		return
	var font_value: Variant = _main.get("font")
	if font_value is Font:
		_font = font_value as Font
	var bold_value: Variant = _main.get("font_bold")
	if bold_value is Font:
		_font_bold = bold_value as Font
	if _font_bold == null:
		_font_bold = _font


func _draw_dash_cooldown(player: Dictionary) -> void:
	var cooldown: float = maxf(0.1, float(player.get("dash_cd", 5.0)))
	var remaining: float = maxf(0.0, float(player.get("dash_timer", 0.0)))
	var ready_ratio: float = clampf(1.0 - remaining / cooldown, 0.0, 1.0)
	draw_rect(DASH_RECT, Color(0.025, 0.03, 0.035, 0.94), true)
	draw_rect(Rect2(DASH_RECT.position, Vector2(DASH_RECT.size.x * ready_ratio, DASH_RECT.size.y)), Color(0.35, 0.72, 0.78, 0.92), true)
	draw_rect(DASH_RECT, Color(0.68, 0.76, 0.74, 0.90), false, 1.0)
	if _font == null:
		return
	var label: String = "閃避 READY" if remaining <= 0.01 else "閃避 %.1fs" % remaining
	draw_string(_font, DASH_RECT.position + Vector2(0.0, -4.0), label, HORIZONTAL_ALIGNMENT_LEFT, DASH_RECT.size.x, 12, Color(0.88, 0.91, 0.88))


func _draw_player_shield(player: Dictionary) -> void:
	var shield: float = float(player.get("shield", 0.0))
	if shield <= 0.0 and _shield_break_flash <= 0.0:
		return
	var pos_value: Variant = player.get("pos", Vector2.ZERO)
	var world_pos: Vector2 = pos_value if pos_value is Vector2 else Vector2.ZERO
	var screen_pos: Vector2 = world_pos
	if _main.has_method("world_to_screen"):
		var converted: Variant = _main.call("world_to_screen", world_pos)
		if converted is Vector2:
			screen_pos = converted as Vector2
	var pulse: float = 1.0 + sin(Time.get_ticks_msec() * 0.008) * 0.05
	var radius: float = 31.0 * pulse
	var alpha: float = 0.24 + minf(0.36, shield * 0.012)
	if _shield_break_flash > 0.0:
		radius += (0.34 - _shield_break_flash) * 95.0
		alpha = _shield_break_flash / 0.34
	draw_circle(screen_pos, radius, Color(0.28, 0.72, 0.92, alpha), false, 3.0)
	draw_circle(screen_pos, radius - 4.0, Color(0.55, 0.88, 1.0, alpha * 0.55), false, 1.0)
	if shield > 0.0 and _font_bold != null:
		draw_string(_font_bold, screen_pos + Vector2(-28.0, -39.0), "盾 %.0f" % shield, HORIZONTAL_ALIGNMENT_CENTER, 56.0, 12, Color(0.72, 0.92, 1.0))


func _draw_boss_warning() -> void:
	var banner_value: Variant = _main.get("boss_ability_banner")
	if not (banner_value is Dictionary):
		return
	var banner: Dictionary = banner_value as Dictionary
	if banner.is_empty():
		return
	var text: String = str(banner.get("text", ""))
	if text.is_empty():
		return
	var life: float = float(banner.get("life", 0.0))
	var max_life: float = maxf(0.01, float(banner.get("max_life", 1.0)))
	var ratio: float = clampf(life / max_life, 0.0, 1.0)
	draw_rect(BOSS_WARNING_RECT, Color(0.12, 0.025, 0.018, 0.94), true)
	draw_rect(Rect2(BOSS_WARNING_RECT.position, Vector2(BOSS_WARNING_RECT.size.x * ratio, BOSS_WARNING_RECT.size.y)), Color(0.54, 0.10, 0.04, 0.68), true)
	draw_rect(BOSS_WARNING_RECT, Color(0.96, 0.48, 0.22, 0.96), false, 2.0)
	if _font_bold != null:
		draw_string(_font_bold, BOSS_WARNING_RECT.position + Vector2(10.0, 21.0), "危險｜%s" % text, HORIZONTAL_ALIGNMENT_CENTER, BOSS_WARNING_RECT.size.x - 20.0, 15, Color(1.0, 0.88, 0.70))
