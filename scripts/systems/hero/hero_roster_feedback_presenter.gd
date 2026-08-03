class_name HeroRosterFeedbackPresenter
extends RefCounted

## 將 HeroRosterFeedback 的穩定 ID 與參數轉成玩家可見文字。
##
## 流程層只傳 hero_id、state 等穩定資料；本層才查詢角色名稱與翻譯文字。
## 找不到角色或翻譯時提供可讀 fallback，不讓 HUD 顯示空字串。


static func message(feedback: Dictionary, hero_defs: Dictionary) -> String:
	var message_id: StringName = StringName(feedback.get("message_id", &""))
	if message_id == &"":
		return ""
	var raw_params: Dictionary = feedback.get("params", {}) as Dictionary
	var values: Dictionary = raw_params.duplicate(true)
	values["hero_name"] = hero_name(str(raw_params.get("hero_id", "")), hero_defs)
	values["replaced_name"] = hero_name(str(raw_params.get("replaced_id", "")), hero_defs)
	values["state_name"] = state_name(StringName(raw_params.get("to", raw_params.get("state", &"unknown"))))
	values["replaced_state_name"] = state_name(StringName(raw_params.get("replaced_to", &"unknown")))
	return LocalizationService.format(message_id, values, fallback_for(message_id, values))


static func hero_name(hero_id: String, hero_defs: Dictionary) -> String:
	if hero_id.is_empty():
		return "—"
	var definition: Dictionary = hero_defs.get(hero_id, {}) as Dictionary
	return str(definition.get("name", hero_id))


static func state_name(state: StringName) -> String:
	var key: StringName = state_key(state)
	return LocalizationService.text(key, fallback_state_name(state))


static func state_key(state: StringName) -> StringName:
	match state:
		HeroRosterManager.ACTIVE:
			return &"ui.hero_roster.state.active"
		HeroRosterManager.RESERVE:
			return &"ui.hero_roster.state.reserve"
		HeroRosterManager.CAMP:
			return &"ui.hero_roster.state.camp"
		_:
			return &"ui.hero_roster.state.unknown"


static func fallback_state_name(state: StringName) -> String:
	match state:
		HeroRosterManager.ACTIVE:
			return "主戰"
		HeroRosterManager.RESERVE:
			return "後備"
		HeroRosterManager.CAMP:
			return "營地"
		_:
			return "未配置"


static func fallback_for(message_id: StringName, values: Dictionary) -> String:
	match message_id:
		&"message.hero_roster.already_assigned":
			return "{hero_name}目前已在{state_name}。"
		&"message.hero_roster.moved":
			return "{hero_name}已調整至{state_name}。"
		&"message.hero_roster.replaced":
			return "{hero_name}編入{state_name}，{replaced_name}轉往{replaced_state_name}。"
		&"message.hero_roster.error":
			return "名將編成未完成，請重新操作。"
	var fallback: String = String(message_id)
	for key in values:
		fallback = fallback.replace("{%s}" % str(key), str(values[key]))
	return fallback
