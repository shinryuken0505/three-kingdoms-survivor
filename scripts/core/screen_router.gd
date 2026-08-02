class_name ScreenRouter
extends RefCounted

## 畫面切換與生命週期協調器。
##
## 目前先提供可獨立測試的基礎層；逐步接入 main.gd 後，畫面不得再自行散落
## previous_screen 與 enter／exit 判斷。Router 不持有 CanvasItem，也不處理實際繪製。

signal screen_changed(previous: StringName, current: StringName, context: Dictionary)

var _current: StringName = ScreenIds.MENU
var _previous: StringName = &""
var _context: Dictionary = {}
var _handlers: Dictionary = {}
var _history: Array[StringName] = []


func register(screen_id: StringName, handler: Variant) -> void:
	if not ScreenIds.all().has(screen_id):
		push_error("ScreenRouter: unknown screen id %s" % screen_id)
		return
	_handlers[screen_id] = handler


func unregister(screen_id: StringName) -> void:
	_handlers.erase(screen_id)


func has_handler(screen_id: StringName) -> bool:
	return _handlers.has(screen_id)


func current() -> StringName:
	return _current


func previous() -> StringName:
	return _previous


func context() -> Dictionary:
	return _context.duplicate(true)


func history() -> Array[StringName]:
	return _history.duplicate()


func start(screen_id: StringName, next_context: Dictionary = {}) -> Dictionary:
	if not ScreenIds.all().has(screen_id):
		return {"ok": false, "reason": "unknown_screen", "screen": screen_id}
	_current = screen_id
	_previous = &""
	_context = next_context.duplicate(true)
	_history.clear()
	_call_handler(_current, "enter", _context)
	return {"ok": true, "current": _current, "previous": _previous}


func go_to(screen_id: StringName, next_context: Dictionary = {}, remember: bool = true) -> Dictionary:
	if not ScreenIds.all().has(screen_id):
		return {"ok": false, "reason": "unknown_screen", "screen": screen_id}
	if screen_id == _current:
		_context = next_context.duplicate(true)
		return {"ok": true, "event": "context_updated", "current": _current}

	var from: StringName = _current
	_call_handler(from, "exit", {})
	if remember and not from.is_empty():
		_history.append(from)
	_previous = from
	_current = screen_id
	_context = next_context.duplicate(true)
	_call_handler(_current, "enter", _context)
	screen_changed.emit(_previous, _current, context())
	return {"ok": true, "event": "changed", "previous": _previous, "current": _current}


func back(fallback: StringName = ScreenIds.GAME, next_context: Dictionary = {}) -> Dictionary:
	var target: StringName = fallback
	if not _history.is_empty():
		target = _history.pop_back()
	return go_to(target, next_context, false)


func is_modal() -> bool:
	return ScreenIds.is_modal(_current)


func handle_input(event: InputEvent) -> Dictionary:
	return _call_handler(_current, "handle_input", event)


func update(delta: float) -> void:
	_call_handler(_current, "update", delta)


func draw(canvas: CanvasItem, view_model: Dictionary = {}) -> void:
	_call_handler(_current, "draw", {"canvas": canvas, "view_model": view_model})


func _call_handler(screen_id: StringName, method_name: StringName, argument: Variant) -> Variant:
	var handler: Variant = _handlers.get(screen_id, null)
	if handler == null or not handler.has_method(method_name):
		return {}
	if method_name == &"exit":
		return handler.call(method_name)
	if method_name == &"draw":
		var payload: Dictionary = argument as Dictionary
		return handler.call(method_name, payload.get("canvas"), payload.get("view_model", {}))
	return handler.call(method_name, argument)
