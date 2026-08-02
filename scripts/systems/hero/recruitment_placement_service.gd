class_name RecruitmentPlacementService
extends RefCounted

## 招賢館與名將整備共用的加入位置決策。
##
## 本服務不直接操作 UI、音效或存檔。招募畫面選定名將後，先呼叫
## `begin()` 取得位置選擇狀態，再將玩家選擇交給 HeroRosterController。

const ACTION_OPEN_POSITION_PICKER: StringName = &"open_position_picker"
const ACTION_CANCEL_RECRUITMENT: StringName = &"cancel_recruitment"


static func begin(hero_id: String, active: Array, reserve: Array, camp: Array) -> Dictionary:
	var current_state: String = HeroRosterManager.state_of(hero_id, active, reserve, camp)
	return {
		"action": ACTION_OPEN_POSITION_PICKER,
		"hero_id": hero_id,
		"current_state": current_state,
		"picker": HeroRosterController.open_picker_for(hero_id, current_state),
		"source": "recruitment",
	}


static func resolve_target(
	hero_id: String,
	target_index: int,
	active: Array,
	reserve: Array,
	camp: Array,
	active_capacity: int,
	reserve_capacity: int
) -> Dictionary:
	var decision: Dictionary = HeroRosterController.resolve_target(
		hero_id,
		target_index,
		active,
		reserve,
		camp,
		active_capacity,
		reserve_capacity
	)
	decision["source"] = "recruitment"
	return decision


static func cancel(hero_id: String) -> Dictionary:
	return {
		"action": ACTION_CANCEL_RECRUITMENT,
		"hero_id": hero_id,
		"source": "recruitment",
	}


static func initialization_payload(hero_id: String) -> Dictionary:
	# 呼叫端依此初始化新名將資料，避免招賢館各自漏掉圖鑑、技能或冷卻。
	return {
		"hero_id": hero_id,
		"ensure_known": true,
		"ensure_skill_level": true,
		"ensure_bond_level": true,
		"reset_cooldown": true,
	}
