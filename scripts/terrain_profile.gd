class_name TerrainProfile
extends RefCounted

# V2.0 alpha.2 terrain contract. main.gd currently consumes equivalent dictionaries;
# this class is the migration target for future Resource-based chapter data.
var id: String = "ground"
var speed_multiplier: float = 1.0
var blocks_projectiles: bool = false
var hazard_damage_per_second: float = 0.0
var visual_shape: String = "none"

func _init(data: Dictionary = {}) -> void:
	id = str(data.get("id", id))
	speed_multiplier = float(data.get("speed_multiplier", speed_multiplier))
	blocks_projectiles = bool(data.get("blocks_projectiles", blocks_projectiles))
	hazard_damage_per_second = float(data.get("hazard_damage_per_second", hazard_damage_per_second))
	visual_shape = str(data.get("visual_shape", visual_shape))
