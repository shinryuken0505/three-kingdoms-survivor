class_name HeroRosterMainState
extends RefCounted

## main.gd 舊欄位的集中讀寫工具。
##
## GDScript 無法直接以 Dictionary 修改呼叫端成員，因此此檔提供穩定欄位清單、
## 差異比較與驗證，讓 main.gd 接線時只需逐欄套用，不再散落硬編碼 key。

const LEGACY_KEYS: Array[StringName] = [
	&"hero_config_index",
	&"hero_config_origin",
	&"config_candidate",
	&"config_replace_index",
	&"config_replace_mode",
	&"hero_position_picker_open",
	&"hero_position_index",
	&"hero_position_candidate",
]


static func snapshot(
	hero_config_index: int,
	hero_config_origin: String,
	config_candidate: String,
	config_replace_index: int,
	config_replace_mode: String,
	hero_position_picker_open: bool,
	hero_position_index: int,
	hero_position_candidate: String
) -> Dictionary:
	return {
		"hero_config_index": hero_config_index,
		"hero_config_origin": hero_config_origin,
		"config_candidate": config_candidate,
		"config_replace_index": config_replace_index,
		"config_replace_mode": config_replace_mode,
		"hero_position_picker_open": hero_position_picker_open,
		"hero_position_index": hero_position_index,
		"hero_position_candidate": hero_position_candidate,
	}


static func normalize(state: Dictionary) -> Dictionary:
	var session: HeroRosterSession = HeroRosterLegacyBridge.session_from_legacy(state)
	return HeroRosterLegacyBridge.legacy_from_session(session)


static func changed_keys(before: Dictionary, after: Dictionary) -> Array[StringName]:
	var changed: Array[StringName] = []
	for key in LEGACY_KEYS:
		if before.get(String(key)) != after.get(String(key)):
			changed.append(key)
	return changed


static func validate(state: Dictionary) -> Dictionary:
	var missing: Array[StringName] = []
	for key in LEGACY_KEYS:
		if not state.has(String(key)):
			missing.append(key)
	return {
		"ok": missing.is_empty(),
		"missing": missing,
		"normalized": normalize(state),
	}
