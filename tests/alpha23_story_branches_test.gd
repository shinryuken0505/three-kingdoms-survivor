extends SceneTree

const Story = preload("res://scripts/systems/story/alpha23_story_director.gd")
const Routes = preload("res://scripts/systems/story/alpha23_route_resolver.gd")
const Endings = preload("res://scripts/systems/ending/alpha23_ending_routes.gd")

func _init() -> void:
	var state: Dictionary = Routes.new_state()
	state = Routes.apply_choice(state, "save_villagers", {"benevolence":3, "flags":["protected_supplies"]})
	assert(str(state.get("dominant", "")) == "benevolence")
	assert(bool(state.get("flags", {}).get("protected_supplies", false)))

	var scene: Dictionary = Story.chapter_scene("changban", "opening", state)
	assert(scene.get("lines", []).size() >= 2)
	assert(str(scene.get("route", "")) == "benevolence")

	var variant: Dictionary = Routes.chapter_variant("changban", state)
	assert(str(variant.get("ally", "")) == "zhao_yun")
	assert(str(variant.get("label", "")) == "回身救民")

	var ending: Dictionary = Endings.resolve(state, {
		"completed":true,
		"bosses":6,
		"saved_civilians":4
	})
	assert(str(ending.get("id", "")) == "people_emperor")
	assert(str(ending.get("title", "")) == "民心所歸")

	var ambition: Dictionary = Routes.new_state()
	ambition = Routes.apply_choice(ambition, "seize_power", {"ambition":5})
	var ambition_ending: Dictionary = Endings.resolve(ambition, {"completed":true, "bosses":9})
	assert(str(ambition_ending.get("id", "")) == "unifier")

	print("ALPHA23_STORY_BRANCHES_OK")
	quit(0)
