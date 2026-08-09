extends Node

## 過濾高頻率的玩家攻擊震動。
## 保留 Boss／重大事件震動，只取消玩家基礎攻擊與名將施放期間的 screen_shake。

func _ready() -> void:
	process_priority = 1000


func _process(_delta: float) -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return

	var should_suppress := false
	var player_anim: Variant = scene.get("player_action_anim")
	if player_anim is Dictionary and not (player_anim as Dictionary).is_empty():
		should_suppress = true

	var hero_flash: Variant = scene.get("hero_cast_flash")
	if hero_flash is Dictionary and not (hero_flash as Dictionary).is_empty():
		should_suppress = true

	if should_suppress:
		scene.set("screen_shake", 0.0)
