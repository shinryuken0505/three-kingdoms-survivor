extends SceneTree

## 執行方式：
## godot --headless --path . --script res://tests/core_routing_test.gd

var failures: Array[String] = []


class FakeScreen:
	extends RefCounted
	var entered: Array[Dictionary] = []
	var exit_count: int = 0
	var updates: Array[float] = []

	func enter(context: Dictionary) -> void:
		entered.append(context.duplicate(true))

	func exit() -> void:
		exit_count += 1

	func handle_input(_event: InputEvent) -> Dictionary:
		return {"handled": true, "source": "fake"}

	func update(delta: float) -> void:
		updates.append(delta)


func _init() -> void:
	test_screen_router()
	test_input_mapping()
	test_input_lock_and_confirm_guard()
	if failures.is_empty():
		print("[PASS] core_routing_test")
		quit(0)
		return
	for failure in failures:
		push_error("[FAIL] %s" % failure)
	quit(1)


func test_screen_router() -> void:
	var router := ScreenRouter.new()
	var menu := FakeScreen.new()
	var game := FakeScreen.new()
	var modal := FakeScreen.new()
	router.register(ScreenIds.MENU, menu)
	router.register(ScreenIds.GAME, game)
	router.register(ScreenIds.HERO_CONFIG, modal)

	var started: Dictionary = router.start(ScreenIds.MENU, {"fresh": true})
	check(bool(started.get("ok", false)), "router should start known screen")
	check(menu.entered.size() == 1, "start should enter initial handler")

	var moved: Dictionary = router.go_to(ScreenIds.GAME, {"chapter": 1})
	check(bool(moved.get("ok", false)), "router should move to game")
	check(menu.exit_count == 1, "transition should exit previous handler")
	check(game.entered.size() == 1, "transition should enter next handler")
	check(router.previous() == ScreenIds.MENU, "router should remember previous screen")

	router.go_to(ScreenIds.HERO_CONFIG, {"origin": "camp"})
	check(router.is_modal(), "hero config should be classified as modal")
	var returned: Dictionary = router.back(ScreenIds.GAME)
	check(bool(returned.get("ok", false)), "router back should succeed")
	check(router.current() == ScreenIds.GAME, "router back should restore game")
	check(modal.exit_count == 1, "router back should exit modal")

	var unknown: Dictionary = router.go_to(&"not_a_screen")
	check(not bool(unknown.get("ok", true)), "unknown screen should be rejected")


func test_input_mapping() -> void:
	check(InputRouter.action_for_key(KEY_UP) == InputRouter.ACTION_UP, "up key should map to up")
	check(InputRouter.action_for_key(KEY_W) == InputRouter.ACTION_UP, "W should map to up")
	check(InputRouter.action_for_key(KEY_SPACE) == InputRouter.ACTION_CONFIRM, "Space should confirm")
	check(InputRouter.action_for_key(KEY_ENTER) == InputRouter.ACTION_CONFIRM, "Enter should confirm")
	check(InputRouter.action_for_key(KEY_ESCAPE) == InputRouter.ACTION_CANCEL, "Esc should cancel")
	check(InputRouter.action_for_key(KEY_E) == InputRouter.ACTION_INTERACT, "E should interact")
	check(InputRouter.is_direction(InputRouter.ACTION_LEFT), "left should be directional")
	check(not InputRouter.is_direction(InputRouter.ACTION_CONFIRM), "confirm should not be directional")


func test_input_lock_and_confirm_guard() -> void:
	var router := InputRouter.new()
	var event := InputEventKey.new()
	event.pressed = true
	event.keycode = KEY_SPACE

	router.lock_for(200, 1000)
	var blocked: Dictionary = router.route(event, 1100)
	check(bool(blocked.get("blocked", false)), "locked router should block input")

	var accepted: Dictionary = router.route(event, 1250)
	check(accepted.get("action") == InputRouter.ACTION_CONFIRM, "confirm should pass after lock")
	var repeated: Dictionary = router.route(event, 1300)
	check(bool(repeated.get("blocked", false)), "rapid confirm should be guarded")
	var accepted_again: Dictionary = router.route(event, 1400)
	check(accepted_again.get("action") == InputRouter.ACTION_CONFIRM, "confirm should pass after guard window")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
