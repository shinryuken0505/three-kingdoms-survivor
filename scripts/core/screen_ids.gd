class_name ScreenIds
extends RefCounted

## 畫面狀態唯一來源。
##
## 新增畫面時先在此宣告，再於主流程註冊輸入與繪製。
## 禁止在功能模組中散落裸字串，避免拼字錯誤造成有輸入、無畫面的假卡死。

const MENU: StringName = &"menu"
const CHARACTER_SELECT: StringName = &"character_select"
const GAME: StringName = &"game"
const PAUSE: StringName = &"pause"
const SETTINGS: StringName = &"settings"
const SAVE_SELECT: StringName = &"save_select"
const CONFIRM: StringName = &"confirm"

const CHAPTER_INTRO: StringName = &"chapter_intro"
const BOSS_INTRO: StringName = &"boss_intro"
const LEVEL_UP: StringName = &"levelup"
const SHOP: StringName = &"shop"
const CAMP_MENU: StringName = &"camp_menu"
const INTERMISSION: StringName = &"intermission"
const VICTORY: StringName = &"victory"
const DEFEAT: StringName = &"defeat"
const ENDING: StringName = &"ending"

const HERO_CANDIDATE: StringName = &"hero_candidate"
const HERO_ENCOUNTER: StringName = &"hero_encounter"
const REPLACE_HERO: StringName = &"replace_hero"
const HERO_CONFIG: StringName = &"hero_config"
const HERO_POSITION_PICKER: StringName = &"hero_position_picker"
const CONFIG_REPLACE: StringName = &"config_replace"

const TAB: StringName = &"tab"
const CODEX: StringName = &"codex"
const SKIN_SELECT: StringName = &"skin_select"
const HISTORY_EVENT: StringName = &"history_event"


static func is_modal(screen_id: StringName) -> bool:
	return screen_id in [
		LEVEL_UP,
		SHOP,
		HERO_CANDIDATE,
		HERO_ENCOUNTER,
		REPLACE_HERO,
		HERO_CONFIG,
		HERO_POSITION_PICKER,
		CONFIG_REPLACE,
		TAB,
		CODEX,
		SKIN_SELECT,
		HISTORY_EVENT,
		PAUSE,
		SETTINGS,
		SAVE_SELECT,
		CONFIRM,
	]


static func all() -> Array[StringName]:
	return [
		MENU, CHARACTER_SELECT, GAME, PAUSE, SETTINGS, SAVE_SELECT, CONFIRM,
		CHAPTER_INTRO, BOSS_INTRO, LEVEL_UP, SHOP, CAMP_MENU, INTERMISSION,
		VICTORY, DEFEAT, ENDING, HERO_CANDIDATE, HERO_ENCOUNTER,
		REPLACE_HERO, HERO_CONFIG, HERO_POSITION_PICKER, CONFIG_REPLACE,
		TAB, CODEX, SKIN_SELECT, HISTORY_EVENT,
	]
