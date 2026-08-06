class_name Alpha31TelegraphShapes
extends RefCounted


static func profile_for(boss_id: String) -> Dictionary:
	match boss_id:
		"zhangjiao", "zhangliang":
			return {"shape": "multi_circle", "radius": 92.0, "count": 4, "spread": 128.0}
		"caoren":
			return {"shape": "circle", "radius": 172.0}
		"gaoshun", "zhanghe":
			return {"shape": "line", "length": 390.0, "width": 82.0}
		"huaxiong":
			return {"shape": "sector", "radius": 235.0, "half_angle": deg_to_rad(34.0)}
		"lvbu":
			return {"shape": "sector", "radius": 280.0, "half_angle": deg_to_rad(48.0)}
		_:
			return {"shape": "circle", "radius": 150.0}


static func append_visuals(zones: Array, boss_data: Dictionary, target: Vector2, duration: float) -> void:
	var boss_id: String = str(boss_data.get("id", ""))
	var origin: Vector2 = boss_data.get("pos", target) as Vector2
	var profile: Dictionary = profile_for(boss_id)
	var shape: String = str(profile.get("shape", "circle"))
	var direction: Vector2 = target - origin
	if direction.length_squared() < 0.001:
		direction = Vector2.RIGHT
	direction = direction.normalized()
	boss_data["telegraph_shape"] = shape
	boss_data["telegraph_origin"] = origin
	boss_data["telegraph_direction"] = direction
	boss_data["telegraph_profile"] = profile.duplicate(true)

	match shape:
		"line":
			zones.append({
				"kind": "telegraph_line",
				"pos": origin,
				"dir": direction,
				"length": float(profile.get("length", 360.0)),
				"width": float(profile.get("width", 76.0)),
				"life": duration,
				"max_life": duration,
				"color": Color8(239, 80, 62)
			})
		"sector":
			zones.append({
				"kind": "telegraph_sector",
				"pos": origin,
				"angle": direction.angle(),
				"radius": float(profile.get("radius", 230.0)),
				"half_angle": float(profile.get("half_angle", deg_to_rad(36.0))),
				"life": duration,
				"max_life": duration,
				"color": Color8(239, 80, 62)
			})
		"multi_circle":
			var count: int = int(profile.get("count", 4))
			var spread: float = float(profile.get("spread", 120.0))
			var radius: float = float(profile.get("radius", 92.0))
			for index in range(count):
				var angle: float = TAU * float(index) / float(max(1, count))
				var offset: Vector2 = Vector2.from_angle(angle) * spread
				zones.append({
					"kind": "telegraph_circle",
					"pos": target + offset,
					"r": radius,
					"delay_ratio": float(index) / float(max(1, count)),
					"life": duration,
					"max_life": duration,
					"color": Color8(239, 80, 62)
				})
		_:
			zones.append({
				"kind": "telegraph_circle",
				"pos": target,
				"r": float(profile.get("radius", 150.0)),
				"life": duration,
				"max_life": duration,
				"color": Color8(239, 80, 62)
			})
