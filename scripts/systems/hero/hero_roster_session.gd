class_name HeroRosterSession
extends RefCounted

## 名將整備畫面的暫存互動狀態。
##
## 這個物件只保存游標、候選名將與彈窗狀態；不持有正式編成資料，
## 因此不應寫入存檔。未來 main.gd 拆分畫面控制器時可直接搬移使用。

var hero_index: int = 0
var origin: StringName = &"game"
var candidate_id: String = ""
var replacement_index: int = 0
var replacement_mode: StringName = HeroRosterManager.ACTIVE
var position_picker_open: bool = false
var position_index: int = 0
var position_candidate_id: String = ""


func reset(next_origin: StringName = &"game") -> void:
	hero_index = 0
	origin = next_origin
	candidate_id = ""
	replacement_index = 0
	replacement_mode = HeroRosterManager.ACTIVE
	position_picker_open = false
	position_index = 0
	position_candidate_id = ""


func normalize(hero_count: int, replacement_count: int = 0) -> void:
	hero_index = _clamp_index(hero_index, hero_count)
	replacement_index = _clamp_index(replacement_index, replacement_count)
	position_index = HeroPositionPickerScreen.normalized_index(position_index)


func open_position_picker(hero_id: String, target_index: int) -> void:
	position_picker_open = true
	position_candidate_id = hero_id
	position_index = HeroPositionPickerScreen.normalized_index(target_index)


func close_position_picker() -> void:
	position_picker_open = false
	position_candidate_id = ""
	position_index = 0


func open_replacement(hero_id: String, mode: StringName) -> void:
	candidate_id = hero_id
	replacement_mode = mode
	replacement_index = 0
	close_position_picker()


func close_replacement() -> void:
	candidate_id = ""
	replacement_index = 0
	replacement_mode = HeroRosterManager.ACTIVE


func has_replacement() -> bool:
	return not candidate_id.is_empty()


func selected_hero_id(order: Array[String]) -> String:
	if order.is_empty():
		return ""
	hero_index = _clamp_index(hero_index, order.size())
	return order[hero_index]


static func _clamp_index(index: int, item_count: int) -> int:
	if item_count <= 0:
		return 0
	return clampi(index, 0, item_count - 1)
