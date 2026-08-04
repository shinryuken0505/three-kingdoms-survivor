extends Node

const PassiveServiceScript = preload("res://scripts/systems/hero/reserve_passive_service.gd")


func _ready() -> void:
	var result: Dictionary = PassiveServiceScript.aggregate(["huatuo", "liubei", "guanyu", "huatuo"])
	assert((result.get("sources", []) as Array).size() == 3)
	assert(float(result.get("heal_mult", 0.0)) == 0.14)
	assert(float(result.get("damage_mult", 0.0)) == 0.035)
	var capped: Dictionary = PassiveServiceScript.aggregate(["huatuo", "liubei", "caiwenji"])
	assert(float(capped.get("heal_mult", 0.0)) <= 0.22)
	print("reserve_passive_service_test passed")
	get_tree().quit()
