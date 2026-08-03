class_name StatusEffectHud
extends RefCounted

## 主角負面狀態 HUD 的可直接接線入口。
##
## 此元件整合 PlayerStatusAdapter、Presenter、Layout 與 IconPainter，讓 main.gd
## 後續只需傳入 CanvasItem、player Dictionary 與主角螢幕座標即可繪製。
## 不修改 player 狀態，也不接管戰鬥倒數。

const DEFAULT_HUD_ANCHOR := Rect2(1018.0, 142.0, 244.0, 92.0)


static func build(
	player: Dictionary,
	player_screen_position: Vector2,
	view_size: Vector2 = Vector2(1280.0, 720.0),
	hud_anchor: Rect2 = DEFAULT_HUD_ANCHOR,
	locale: String = ""
) -> Dictionary:
	var view_models: Array[Dictionary] = PlayerStatusAdapter.view_models(player)
	var presented: Array[Dictionary] = StatusEffectPresenter.present(view_models, locale)
	return {
		"items": presented,
		"above_player": StatusEffectRenderer.above_player_layout(
			player_screen_position,
			presented,
			view_size
		),
		"hud": StatusEffectRenderer.hud_layout(presented, hud_anchor),
		"summary": accessibility_summary(presented),
	}


static func draw(
	canvas: CanvasItem,
	player: Dictionary,
	player_screen_position: Vector2,
	font: Font,
	view_size: Vector2 = Vector2(1280.0, 720.0),
	hud_anchor: Rect2 = DEFAULT_HUD_ANCHOR,
	locale: String = ""
) -> Dictionary:
	var plan: Dictionary = build(player, player_screen_position, view_size, hud_anchor, locale)
	for slot_value in plan.get("above_player", []) as Array:
		StatusEffectIconPainter.draw_slot(canvas, slot_value as Dictionary, font)
	for slot_value in plan.get("hud", []) as Array:
		StatusEffectIconPainter.draw_slot(canvas, slot_value as Dictionary, font)
	return plan


static func hovered_item(plan: Dictionary, mouse_position: Vector2) -> Dictionary:
	var items: Array = plan.get("items", []) as Array
	for group_name in ["hud", "above_player"]:
		for slot_value in plan.get(group_name, []) as Array:
			var slot: Dictionary = slot_value as Dictionary
			var rect: Rect2 = slot.get("rect", Rect2()) as Rect2
			if rect.has_point(mouse_position):
				var index: int = int(slot.get("index", -1))
				if index >= 0 and index < items.size():
					return (items[index] as Dictionary).duplicate(true)
	return {}


static func accessibility_summary(items: Array) -> String:
	var parts: Array[String] = []
	for value in items:
		var item: Dictionary = value as Dictionary
		var name: String = str(item.get("name", ""))
		var duration: float = maxf(0.0, float(item.get("duration", 0.0)))
		var stacks: int = maxi(1, int(item.get("stacks", 1)))
		var text: String = "%s %.1f秒" % [name, duration]
		if stacks > 1:
			text += "，%d層" % stacks
		parts.append(text)
	return "；".join(parts)
