extends SceneTree


func _init() -> void:
	_test_legacy_fields()
	_test_native_merge()
	_test_priority_order()
	print("[player-status-adapter-test] OK")
	quit()


func _test_legacy_fields() -> void:
	var player := {
		"move_slow": 2.5,
		"control_lock": 0.8,
		"vision_obscure": 0.0,
	}
	var effects: Array = PlayerStatusAdapter.from_player(player)
	_assert(effects.size() == 2, "應轉換兩個有效舊狀態")
	_assert(PlayerStatusAdapter.active_ids(player).has(StatusEffectDefs.STUN), "應包含暈眩")
	_assert(PlayerStatusAdapter.active_ids(player).has(StatusEffectDefs.SLOW), "應包含緩速")


func _test_native_merge() -> void:
	var player := {
		"move_slow": 1.0,
		"status_effects": [
			{"id": StatusEffectDefs.SLOW, "duration": 3.0, "stacks": 1},
			{"id": StatusEffectDefs.BLEED, "duration": 4.0, "stacks": 3},
		]
	}
	var effects: Array = PlayerStatusAdapter.from_player(player)
	_assert(effects.size() == 2, "相同狀態應合併而非重複")
	var slow_index: int = StatusEffectManager.find_index(effects, StatusEffectDefs.SLOW)
	_assert(slow_index >= 0, "應保留緩速")
	_assert(is_equal_approx(float((effects[slow_index] as Dictionary).get("duration", 0.0)), 3.0), "應採較長倒數")
	var bleed_index: int = StatusEffectManager.find_index(effects, StatusEffectDefs.BLEED)
	_assert(int((effects[bleed_index] as Dictionary).get("stacks", 1)) == 3, "應保留流血層數")


func _test_priority_order() -> void:
	var player := {"move_slow": 2.0, "control_lock": 1.0, "burning": 4.0}
	var ids: Array[StringName] = PlayerStatusAdapter.active_ids(player)
	_assert(ids[0] == StatusEffectDefs.STUN, "高優先暈眩應排第一")
	_assert(ids[1] == StatusEffectDefs.BURN, "燃燒應排在緩速前")
	_assert(ids[2] == StatusEffectDefs.SLOW, "緩速應排最後")


func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("[player-status-adapter-test] %s" % message)
		quit(1)
