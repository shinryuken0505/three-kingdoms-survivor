class_name HeroRosterMainEffects
extends RefCounted

## 將 HeroRosterMainAdapter 的結果轉成 main.gd 可逐項執行的副作用計畫。
##
## 本檔不直接存檔、不播放音效、不切換畫面，也不讀寫 main.gd 成員；
## 只產生穩定且可測試的命令，讓正式接線時不再於輸入函式散落條件判斷。

const SCREEN_KEEP: StringName = &"keep"
const SCREEN_HERO_CONFIG: StringName = &"hero_config"
const SCREEN_CONFIG_REPLACE: StringName = &"config_replace"
const SCREEN_CLOSE_HERO_CONFIG: StringName = &"close_hero_config"


static func build(adapter_result: Dictionary, origin: StringName) -> Dictionary:
	var applied: Dictionary = adapter_result.get("apply_result", {}) as Dictionary
	var changed: bool = bool(adapter_result.get("roster_changed", false))
	var hero_id: String = str(applied.get("hero_id", ""))
	var replaced_id: String = str(applied.get("replaced_id", ""))
	var destination: StringName = StringName(applied.get("to", &""))
	var cooldown_start: Array[String] = []
	var cooldown_remove: Array[String] = []

	if changed:
		if destination == HeroRosterManager.ACTIVE and not hero_id.is_empty():
			cooldown_start.append(hero_id)
		elif not hero_id.is_empty():
			cooldown_remove.append(hero_id)
		if not replaced_id.is_empty():
			cooldown_remove.append(replaced_id)

	return {
		"handled": bool(adapter_result.get("handled", false)),
		"apply_legacy_state": not (adapter_result.get("legacy_state", {}) as Dictionary).is_empty(),
		"legacy_state": (adapter_result.get("legacy_state", {}) as Dictionary).duplicate(true),
		"screen_command": _normalize_screen_command(StringName(adapter_result.get("screen_command", SCREEN_KEEP))),
		"play_sfx": StringName(adapter_result.get("sfx", &"")),
		"show_message": not str(adapter_result.get("message", "")).is_empty(),
		"message": str(adapter_result.get("message", "")),
		"sync_roster": changed,
		"save_checkpoint": changed and origin == &"intermission",
		"cooldown_start": cooldown_start,
		"cooldown_remove": cooldown_remove,
		"queue_redraw": bool(adapter_result.get("handled", false)),
	}


static func _normalize_screen_command(value: StringName) -> StringName:
	if value in [SCREEN_KEEP, SCREEN_HERO_CONFIG, SCREEN_CONFIG_REPLACE, SCREEN_CLOSE_HERO_CONFIG]:
		return value
	return SCREEN_KEEP
