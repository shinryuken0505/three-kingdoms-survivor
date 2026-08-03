class_name PlayerStatusAdapter
extends RefCounted

## 將 main.gd 既有 player Dictionary 狀態欄位轉成統一狀態效果資料。
##
## 目前不改寫戰鬥規則，只讀取既有倒數欄位，讓 HUD 可以先接上；
## 後續逐步把實際效果搬入 StatusEffectManager 時，畫面層不需要再次修改。

const LEGACY_FIELD_MAP: Dictionary = {
	"move_slow": StatusEffectDefs.SLOW,
	"control_lock": StatusEffectDefs.STUN,
	"vision_obscure": StatusEffectDefs.SMOKE,
	"silence": StatusEffectDefs.SILENCE,
	"burning": StatusEffectDefs.BURN,
	"bleeding": StatusEffectDefs.BLEED,
	"vulnerable": StatusEffectDefs.VULNERABLE,
}


static func from_player(player: Dictionary) -> Array:
	var effects: Array = []
	for field_value in LEGACY_FIELD_MAP.keys():
		var field: String = str(field_value)
		var duration: float = maxf(0.0, float(player.get(field, 0.0)))
		if duration <= 0.0:
			continue
		var status_id: StringName = StringName(LEGACY_FIELD_MAP[field])
		var stacks: int = _legacy_stacks(player, status_id)
		var result: Dictionary = StatusEffectManager.apply(
			effects,
			status_id,
			duration,
			stacks,
			&"legacy_player"
		)
		if bool(result.get("ok", false)):
			effects = (result.get("effects", []) as Array).duplicate(true)

	# 新系統可直接存放 player["status_effects"]；與舊欄位合併時以較長倒數為準。
	var native_effects: Array = player.get("status_effects", []) as Array
	for value in native_effects:
		var effect: Dictionary = value as Dictionary
		var status_id := StringName(effect.get("id", &""))
		if status_id.is_empty() or not StatusEffectDefs.is_known(status_id):
			continue
		var result: Dictionary = StatusEffectManager.apply(
			effects,
			status_id,
			maxf(0.0, float(effect.get("duration", 0.0))),
			maxi(1, int(effect.get("stacks", 1))),
			StringName(effect.get("source_id", &"native_player"))
		)
		if bool(result.get("ok", false)):
			effects = (result.get("effects", []) as Array).duplicate(true)
	return StatusEffectManager.sort_for_display(effects)


static func view_models(player: Dictionary) -> Array[Dictionary]:
	return StatusEffectManager.to_view_model(from_player(player))


static func active_ids(player: Dictionary) -> Array[StringName]:
	var ids: Array[StringName] = []
	for effect in from_player(player):
		ids.append(StringName((effect as Dictionary).get("id", &"")))
	return ids


static func _legacy_stacks(player: Dictionary, status_id: StringName) -> int:
	match status_id:
		StatusEffectDefs.BLEED:
			return maxi(1, int(player.get("bleed_stacks", 1)))
		StatusEffectDefs.POISON:
			return maxi(1, int(player.get("poison_stacks", 1)))
	return 1
