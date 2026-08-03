class_name HeroRosterLegacyBridge
extends RefCounted

## 將 main.gd 既有的名將整備暫存欄位與 HeroRosterSession 互相同步。
##
## 過渡期間只集中欄位映射，不處理輸入、規則、音效、畫面切換或存檔。
## 待 main.gd 完全改用 Session 後即可移除此橋接層。


static func session_from_legacy(state: Dictionary) -> HeroRosterSession:
	var session := HeroRosterSession.new()
	session.hero_index = int(state.get("hero_config_index", 0))
	session.origin = StringName(state.get("hero_config_origin", &"game"))
	session.candidate_id = str(state.get("config_candidate", ""))
	session.replacement_index = int(state.get("config_replace_index", 0))
	session.replacement_mode = StringName(state.get("config_replace_mode", HeroRosterManager.ACTIVE))
	session.position_picker_open = bool(state.get("hero_position_picker_open", false))
	session.position_index = int(state.get("hero_position_index", 0))
	session.position_candidate_id = str(state.get("hero_position_candidate", ""))
	return session


static func legacy_from_session(session: HeroRosterSession) -> Dictionary:
	if session == null:
		return default_legacy_state()
	return {
		"hero_config_index": session.hero_index,
		"hero_config_origin": str(session.origin),
		"config_candidate": session.candidate_id,
		"config_replace_index": session.replacement_index,
		"config_replace_mode": str(session.replacement_mode),
		"hero_position_picker_open": session.position_picker_open,
		"hero_position_index": session.position_index,
		"hero_position_candidate": session.position_candidate_id,
	}


static func apply_to_legacy(target: Dictionary, session: HeroRosterSession) -> Dictionary:
	var values: Dictionary = legacy_from_session(session)
	for key in values:
		target[key] = values[key]
	return target


static func default_legacy_state() -> Dictionary:
	return {
		"hero_config_index": 0,
		"hero_config_origin": "game",
		"config_candidate": "",
		"config_replace_index": 0,
		"config_replace_mode": str(HeroRosterManager.ACTIVE),
		"hero_position_picker_open": false,
		"hero_position_index": 0,
		"hero_position_candidate": "",
	}
