extends Node

## 升級卡池正式接線層。
##
## 進入 levelup 畫面後，以既有 skill_defs 與 skill_levels 重新建立三張相容選項。
## 不接管輸入、不修改 choose_levelup()，因此原本 Space／Enter／滑鼠流程保持不變。

const OfferServiceScript = preload("res://scripts/systems/progression/levelup_offer_service.gd")

var _main: Node = null
var _last_screen: String = ""
var _processed_level: int = -1
var _processed_pending: int = -1


func _ready() -> void:
	_main = get_parent()
	set_process(true)


func _process(_delta: float) -> void:
	if _main == null:
		return
	var current_screen: String = str(_main.get("screen"))
	if current_screen != "levelup":
		_last_screen = current_screen
		return
	var player_value: Variant = _main.get("player")
	if not (player_value is Dictionary):
		return
	var player: Dictionary = player_value as Dictionary
	var level: int = int(player.get("level", 0))
	var pending: int = int(_main.get("pending_levelups"))
	var choices: Array = _main.get("level_choices") as Array
	if choices.is_empty():
		return
	if _last_screen == "levelup" and level == _processed_level and pending == _processed_pending:
		return
	_apply_offer(player, level, pending)
	_last_screen = "levelup"
	_processed_level = level
	_processed_pending = pending


func _apply_offer(player: Dictionary, level: int, pending: int) -> void:
	var skill_defs: Dictionary = _main.get("skill_defs") as Dictionary
	var skill_levels: Dictionary = _main.get("skill_levels") as Dictionary
	var active_heroes: Array = _main.get("active_heroes") as Array
	var hero_defs: Dictionary = {}
	var heroes_value: Variant = _main.get("heroes")
	if heroes_value is Dictionary:
		hero_defs = heroes_value as Dictionary
	var seed: int = level * 31 + pending * 17 + int(_main.get("elapsed"))
	var offer: Array[Dictionary] = OfferServiceScript.build_offer(
		player,
		skill_defs,
		skill_levels,
		active_heroes,
		seed,
		3,
		hero_defs
	)
	if offer.is_empty():
		return
	_main.set("level_choices", offer)
	var option_index: int = clampi(int(_main.get("option_index")), 0, offer.size() - 1)
	_main.set("option_index", option_index)
	_main.call("queue_redraw")
