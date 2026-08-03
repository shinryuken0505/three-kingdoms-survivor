class_name ScreenRouteRegistry
extends RefCounted

## 畫面路由註冊表。
##
## 先集中描述每個畫面的繪製方法、輸入方法與是否為覆蓋式視窗，後續主流程
## 可逐步改為查表派送，避免大型 match 在多處同步維護。

const DRAW_METHOD := "draw_method"
const INPUT_METHOD := "input_method"
const MODAL := "modal"
const PAUSES_WORLD := "pauses_world"


static func defaults() -> Dictionary:
	return {
		ScreenIds.MENU: route(&"draw_menu", &"handle_menu_key"),
		ScreenIds.CHARACTER_SELECT: route(&"draw_character_select", &"handle_character_select_key"),
		ScreenIds.GAME: route(&"draw_game", &"handle_game_key"),
		ScreenIds.PAUSE: route(&"draw_pause", &"handle_pause_key", true, true),
		ScreenIds.SETTINGS: route(&"draw_settings", &"handle_settings_key", true, true),
		ScreenIds.SAVE_SELECT: route(&"draw_save_select", &"handle_save_select_key", true, true),
		ScreenIds.CONFIRM: route(&"draw_confirm", &"handle_confirm_key", true, true),
		ScreenIds.CHAPTER_INTRO: route(&"draw_chapter_intro", &"handle_chapter_intro_key"),
		ScreenIds.BOSS_INTRO: route(&"draw_boss_intro", &"handle_boss_intro_key"),
		ScreenIds.LEVEL_UP: route(&"draw_levelup_screen", &"handle_levelup_key", true, true),
		ScreenIds.SHOP: route(&"draw_shop_screen", &"handle_shop_key", true, true),
		ScreenIds.CAMP_MENU: route(&"draw_camp_menu", &"handle_camp_menu_key"),
		ScreenIds.INTERMISSION: route(&"draw_intermission_screen", &"handle_intermission_key"),
		ScreenIds.VICTORY: route(&"draw_victory", &"handle_victory_key"),
		ScreenIds.DEFEAT: route(&"draw_defeat", &"handle_defeat_key"),
		ScreenIds.ENDING: route(&"draw_ending", &"handle_ending_key"),
		ScreenIds.HERO_CANDIDATE: route(&"draw_hero_candidate", &"handle_hero_candidate_key", true, true),
		ScreenIds.HERO_ENCOUNTER: route(&"draw_hero_encounter", &"handle_hero_encounter_key", true, true),
		ScreenIds.REPLACE_HERO: route(&"draw_replace_hero", &"handle_replace_hero_key", true, true),
		ScreenIds.HERO_CONFIG: route(&"draw_hero_config_screen", &"handle_hero_config_key", true, true),
		ScreenIds.HERO_POSITION_PICKER: route(&"draw_hero_position_picker", &"handle_hero_position_picker_key", true, true),
		ScreenIds.CONFIG_REPLACE: route(&"draw_config_replace_screen", &"handle_config_replace_key", true, true),
		ScreenIds.TAB: route(&"draw_tab_screen", &"handle_tab_key", true, true),
		ScreenIds.CODEX: route(&"draw_codex", &"handle_codex_key", true, true),
		ScreenIds.SKIN_SELECT: route(&"draw_skin_select", &"handle_skin_select_key", true, true),
		ScreenIds.HISTORY_EVENT: route(&"draw_history_event", &"handle_history_event_key", true, true),
	}


static func route(
	draw_method: StringName,
	input_method: StringName,
	modal: bool = false,
	pauses_world: bool = false
) -> Dictionary:
	return {
		DRAW_METHOD: draw_method,
		INPUT_METHOD: input_method,
		MODAL: modal,
		PAUSES_WORLD: pauses_world,
	}


static func get_route(screen_id: StringName, routes: Dictionary = {}) -> Dictionary:
	var source: Dictionary = defaults() if routes.is_empty() else routes
	if not source.has(screen_id):
		return {}
	return (source[screen_id] as Dictionary).duplicate(true)


static func validate(routes: Dictionary = {}) -> Array[String]:
	var source: Dictionary = defaults() if routes.is_empty() else routes
	var errors: Array[String] = []
	for screen_id in ScreenIds.all():
		if not source.has(screen_id):
			errors.append("missing route: %s" % String(screen_id))
			continue
		var item: Dictionary = source[screen_id] as Dictionary
		if str(item.get(DRAW_METHOD, "")).is_empty():
			errors.append("missing draw method: %s" % String(screen_id))
		if str(item.get(INPUT_METHOD, "")).is_empty():
			errors.append("missing input method: %s" % String(screen_id))
		if bool(item.get(MODAL, false)) != ScreenIds.is_modal(screen_id):
			errors.append("modal mismatch: %s" % String(screen_id))
	for screen_id in source.keys():
		if not ScreenIds.all().has(screen_id):
			errors.append("unknown screen route: %s" % String(screen_id))
	return errors
