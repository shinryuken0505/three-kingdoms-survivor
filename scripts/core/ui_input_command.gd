class_name UIInputCommand
extends RefCounted

## 將鍵盤事件標準化為介面命令。
##
## 畫面控制器只需處理 up/down/left/right/confirm/cancel/tab 等穩定命令，
## 避免每個畫面重複判斷 Enter、Space、方向鍵與快捷鍵。

const NONE: StringName = &"none"
const UP: StringName = &"up"
const DOWN: StringName = &"down"
const LEFT: StringName = &"left"
const RIGHT: StringName = &"right"
const CONFIRM: StringName = &"confirm"
const CANCEL: StringName = &"cancel"
const TAB: StringName = &"tab"
const PAUSE: StringName = &"pause"
const DELETE: StringName = &"delete"


static func from_event(event: InputEvent) -> StringName:
	if not (event is InputEventKey):
		return NONE
	var key_event: InputEventKey = event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return NONE
	return from_keycode(key_event.keycode)


static func from_keycode(keycode: Key) -> StringName:
	match keycode:
		KEY_UP, KEY_W:
			return UP
		KEY_DOWN, KEY_S:
			return DOWN
		KEY_LEFT, KEY_A:
			return LEFT
		KEY_RIGHT, KEY_D:
			return RIGHT
		KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
			return CONFIRM
		KEY_ESCAPE, KEY_BACKSPACE:
			return CANCEL
		KEY_TAB:
			return TAB
		KEY_P:
			return PAUSE
		KEY_DELETE:
			return DELETE
		_:
			return NONE


static func is_navigation(command: StringName) -> bool:
	return command in [UP, DOWN, LEFT, RIGHT]


static func axis(command: StringName) -> Vector2i:
	match command:
		UP:
			return Vector2i.UP
		DOWN:
			return Vector2i.DOWN
		LEFT:
			return Vector2i.LEFT
		RIGHT:
			return Vector2i.RIGHT
		_:
			return Vector2i.ZERO


static func should_consume(command: StringName) -> bool:
	return command != NONE
