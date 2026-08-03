extends SceneTree


func _init() -> void:
	_test_fallback_presentation()
	_test_stack_text()
	_test_tooltip()
	print("[status-effect-presenter-test] OK")
	quit()


func _test_fallback_presentation() -> void:
	var models: Array = [{
		"id": StatusEffectDefs.POISON,
		"name_key": &"missing.status.poison.name",
		"desc_key": &"missing.status.poison.desc",
		"icon_path": "res://assets/icons/status/not_found.png",
		"duration": 2.5,
		"stacks": 2,
	}]
	var presented: Array[Dictionary] = StatusEffectPresenter.present(models)
	_assert(presented.size() == 1, "應輸出一筆顯示資料")
	var item: Dictionary = presented[0]
	_assert(str(item.get("glyph", "")) == "毒", "缺少圖示時應提供毒字備援")
	_assert(not bool(item.get("icon_available", true)), "不存在的圖示應標記為不可用")
	_assert(str(item.get("name", "")) == "Poison", "缺少翻譯時應使用可讀 ID")


func _test_stack_text() -> void:
	_assert(StatusEffectPresenter.stack_text(1) == "", "單層不顯示層數")
	_assert(StatusEffectPresenter.stack_text(4) == "×4", "多層應顯示倍率")


func _test_tooltip() -> void:
	var text: String = StatusEffectPresenter.tooltip_text({
		"name": "流血",
		"description": "持續受到傷害",
		"duration": 3.25,
	})
	_assert(text.contains("流血"), "提示應包含名稱")
	_assert(text.contains("3.2 秒"), "提示應包含格式化倒數")


func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("[status-effect-presenter-test] %s" % message)
		quit(1)
