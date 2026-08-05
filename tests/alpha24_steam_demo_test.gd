extends SceneTree

const Demo = preload("res://scripts/systems/demo/alpha24_steam_demo.gd")

func _init() -> void:
	var state: Dictionary = Demo.new_state()
	assert(str(Demo.current_tutorial(state).get("id", "")) == "move")
	state = Demo.advance_tutorial(state, "move", 4.0)
	assert(str(Demo.current_tutorial(state).get("id", "")) == "attack")
	state = Demo.advance_tutorial(state, "attack")
	state = Demo.advance_tutorial(state, "dash")
	state = Demo.advance_tutorial(state, "levelup")
	state = Demo.advance_tutorial(state, "hero")
	assert(bool(state.get("tutorial_done", false)))
	assert(Demo.demo_chapter_allowed("story", 7))
	assert(not Demo.demo_chapter_allowed("story", 8))
	assert(Demo.demo_chapter_allowed("survival", 99))
	assert(Demo.quality_for_frame_time(30.0, "high") == "low")
	assert(Demo.quality_for_frame_time(22.0, "high") == "medium")
	var ready: Dictionary = Demo.release_readiness("V2.0.0-alpha.24", true, true, 0, 0)
	assert(bool(ready.get("ready", false)))
	print("ALPHA24_STEAM_DEMO_OK")
	quit()
