class_name StatusEffectDefs
extends RefCounted

## 戰鬥狀態效果的集中定義。
##
## 此檔只描述顯示與通用堆疊規則；實際傷害、移動速度或控制效果
## 仍由戰鬥系統依狀態 ID 套用，避免 UI 與玩法規則互相依賴。

const POISON: StringName = &"poison"
const BURN: StringName = &"burn"
const SLOW: StringName = &"slow"
const STUN: StringName = &"stun"
const SMOKE: StringName = &"smoke"
const SILENCE: StringName = &"silence"
const BLEED: StringName = &"bleed"
const VULNERABLE: StringName = &"vulnerable"

const STACK_REFRESH: StringName = &"refresh"
const STACK_ADD: StringName = &"add"
const STACK_REPLACE: StringName = &"replace"


static func all() -> Dictionary:
	return {
		POISON: _definition(POISON, "res://assets/icons/status/poison.png", 90, STACK_ADD, 9),
		BURN: _definition(BURN, "res://assets/icons/status/burn.png", 85, STACK_REFRESH, 1),
		STUN: _definition(STUN, "res://assets/icons/status/stun.png", 100, STACK_REFRESH, 1),
		SMOKE: _definition(SMOKE, "res://assets/icons/status/smoke.png", 72, STACK_REFRESH, 1),
		SILENCE: _definition(SILENCE, "res://assets/icons/status/silence.png", 95, STACK_REFRESH, 1),
		SLOW: _definition(SLOW, "res://assets/icons/status/slow.png", 70, STACK_REFRESH, 1),
		BLEED: _definition(BLEED, "res://assets/icons/status/bleed.png", 80, STACK_ADD, 9),
		VULNERABLE: _definition(VULNERABLE, "res://assets/icons/status/vulnerable.png", 75, STACK_REFRESH, 1),
	}


static func get_definition(status_id: StringName) -> Dictionary:
	return (all().get(status_id, {}) as Dictionary).duplicate(true)


static func is_known(status_id: StringName) -> bool:
	return all().has(status_id)


static func _definition(
	status_id: StringName,
	icon_path: String,
	priority: int,
	stack_policy: StringName,
	max_stacks: int
) -> Dictionary:
	return {
		"id": status_id,
		"name_key": StringName("status.%s.name" % status_id),
		"desc_key": StringName("status.%s.desc" % status_id),
		"icon_path": icon_path,
		"priority": priority,
		"stack_policy": stack_policy,
		"max_stacks": max_stacks,
		"is_negative": true,
	}
