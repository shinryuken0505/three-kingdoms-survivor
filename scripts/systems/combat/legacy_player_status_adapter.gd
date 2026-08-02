class_name LegacyPlayerStatusAdapter
extends RefCounted

## 將 main.gd 現有的倒數欄位轉為統一狀態效果 ViewModel。
##
## 過渡期間只讀取 legacy player Dictionary，不修改戰鬥數值；待所有來源都改用
## StatusEffectManager.apply() 後即可移除此 Adapter。

const LEGACY_FIELDS: Dictionary = {
	&"slow": "move_slow",
	&"stun": "control_lock",
	&"smoke": "vision_obscure",
}


static func effects_from_player(player: Dictionary) -> Array:
	var effects: Array = []
	for status_id_value in LEGACY_FIELDS:
		var status_id: StringName = StringName(status_id_value)
		var field_name: String = str(LEGACY_FIELDS[status_id])
		var duration: float = maxf(0.0, float(player.get(field_name, 0.0)))
		if duration <= 0.0:
			continue
		var applied: Dictionary = StatusEffectManager.apply(
			effects,
			status_id,
			duration,
			1,
			&"legacy_player_state"
		)
		if bool(applied.get("ok", false)):
			effects = applied.get("effects", []) as Array
	return StatusEffectManager.sort_for_display(effects)


static func view_models_from_player(player: Dictionary) -> Array[Dictionary]:
	return StatusEffectManager.to_view_model(effects_from_player(player))


static func has_visible_status(player: Dictionary) -> bool:
	for field_name_value in LEGACY_FIELDS.values():
		if float(player.get(str(field_name_value), 0.0)) > 0.0:
			return true
	return false
