class_name InputRouter
extends RefCounted

## 鍵盤輸入正規化與 Modal 穿透防護。
##
## 將實體按鍵轉成穩定 action ID，畫面 Controller 不再重複判斷 Enter、Space、
## Esc 與方向鍵。輸入鎖採毫秒時間戳，供開啟 Modal 後阻擋同一按鍵穿透。

const ACTION_NONE: StringName = &"none"
const ACTION_UP: StringName = &"up"
const ACTION_DOWN: StringName = &"down"
const ACTION_LEFT: StringName = &"left"
const ACTION_RIGHT: StringName = &"right"
const ACTION_CONFIRM: StringName = &"confirm"
const ACTION_CANCEL: StringName = &"cancel"
const ACTION_INTERACT: StringName = &"interact"
const ACTION_TAB: StringName = &"tab"
const ACTION_PAUSE: StringName = &"pause"

var _locked_until_ms: int = 0
var _last_confirm_ms: int = -1000
var confirm_repeat_guard_ms: int = 120


func lock_for(duration_ms: int, now_ms: int = Time.get_ticks_msec()) -> void:
	_locked_until_ms = maxi(_locked_until_ms, now_ms + maxi(0, duration_ms))


func unlock() -> void:
	_locked_until_ms = 0


func is_locked(now_ms: int = Time.get_ticks_msec()) -> bool:
	return now_ms < _locked_until_ms


func route(event: InputEvent, now_ms: int = Time.get_ticks_msec()) -> Dictionary:
	if event == null:
		return {"handled": false, "action": ACTION_NONE}
	if is_locked(now_ms):
		return {"handled": true, "blocked": true, "action": ACTION_NONE}
	if event is not InputEventKey:
		return {"handled": false, "action": ACTION_NONE}

	var key_event: InputEventKey = event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return {"handled": false, "action": ACTION_NONE}
	var action: StringName = action_for_key(key_event.keycode)
	if action == ACTION_NONE:
		action = action_for_key(key_event.physical_keycode)
	if action == ACTION_NONE:
		return {"handled": false, "action": ACTION_NONE}

	if action == ACTION_CONFIRM:
		if now_ms - _last_confirm_ms < confirm_repeat_guard_ms:
			return {"handled": true, "blocked": true, "action": ACTION_NONE}
		_last_confirm_ms = now_ms
	return {"handled": true, "blocked": false, "action": action}


static func action_for_key(key: Key) -> StringName:
	match key:
		KEY_UP, KEY_W:
			return ACTION_UP
		KEY_DOWN, KEY_S:
			return ACTION_DOWN
		KEY_LEFT, KEY_A:
			return ACTION_LEFT
		KEY_RIGHT, KEY_D:
			return ACTION_RIGHT
		KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
			return ACTION_CONFIRM
		KEY_ESCAPE:
			return ACTION_CANCEL
		KEY_E:
			return ACTION_INTERACT
		KEY_TAB:
			return ACTION_TAB
		KEY_P:
			return ACTION_PAUSE
		_:
			return ACTION_NONE


static func is_direction(action: StringName) -> bool:
	return action in [ACTION_UP, ACTION_DOWN, ACTION_LEFT, ACTION_RIGHT]
