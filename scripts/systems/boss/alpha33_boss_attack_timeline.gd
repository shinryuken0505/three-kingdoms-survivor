class_name Alpha33BossAttackTimeline
extends RefCounted

const Alpha31TelegraphShapes = preload("res://scripts/systems/boss/alpha31_telegraph_shapes.gd")


static func create(boss_data: Dictionary, target: Vector2, skill_name: String) -> Dictionary:
	var boss_id: String = str(boss_data.get("id", ""))
	var origin: Vector2 = boss_data.get("telegraph_origin", boss_data.get("pos", target)) as Vector2
	var direction: Vector2 = boss_data.get("telegraph_direction", target - origin) as Vector2
	if direction.length_squared() < 0.001:
		direction = Vector2.RIGHT
	direction = direction.normalized()
	var profile: Dictionary = boss_data.get("telegraph_profile", Alpha31TelegraphShapes.profile_for(boss_id)) as Dictionary
	var shape: String = str(profile.get("shape", "circle"))
	var events: Array = []
	var total: float = 0.72
	var recover: float = 0.42

	match shape:
		"multi_circle":
			var count: int = int(profile.get("count", 4))
			var spread: float = float(profile.get("spread", 128.0))
			var radius: float = float(profile.get("radius", 92.0))
			for index in range(count):
				var angle: float = TAU * float(index) / float(max(1, count))
				events.append({
					"time": 0.12 + float(index) * 0.18,
					"kind": "circle",
					"pos": target + Vector2.from_angle(angle) * spread,
					"radius": radius,
					"damage_mult": 0.58,
					"fired": false
				})
			total = 0.20 + float(max(0, count - 1)) * 0.18 + 0.34
			recover = 0.52
		"line":
			var length: float = float(profile.get("length", 390.0))
			total = 0.68
			recover = 0.55
			return {
				"kind": "charge",
				"boss_id": boss_id,
				"skill_name": skill_name,
				"elapsed": 0.0,
				"total": total,
				"recover": recover,
				"origin": origin,
				"end": origin + direction * length,
				"direction": direction,
				"width": float(profile.get("width", 82.0)),
				"hit": false
			}
		"sector":
			var radius: float = float(profile.get("radius", 235.0))
			var half_angle: float = float(profile.get("half_angle", deg_to_rad(34.0)))
			events.append({
				"time": 0.16,
				"kind": "sector",
				"pos": origin,
				"direction": direction,
				"radius": radius,
				"half_angle": half_angle,
				"damage_mult": 0.92,
				"fired": false
			})
			if boss_id == "lvbu":
				events.append({
					"time": 0.48,
					"kind": "sector",
					"pos": origin,
					"direction": -direction,
					"radius": radius * 1.08,
					"half_angle": min(PI * 0.48, half_angle * 1.18),
					"damage_mult": 1.08,
					"fired": false
				})
				total = 0.96
				recover = 0.72
			else:
				total = 0.64
				recover = 0.56
		_:
			events.append({
				"time": 0.18,
				"kind": "circle",
				"pos": target,
				"radius": float(profile.get("radius", 150.0)),
				"damage_mult": 1.0,
				"fired": false
			})

	return {
		"kind": "events",
		"boss_id": boss_id,
		"skill_name": skill_name,
		"elapsed": 0.0,
		"total": total,
		"recover": recover,
		"events": events
	}


static func event_contains(event: Dictionary, point: Vector2, tolerance: float = 6.0) -> bool:
	var kind: String = str(event.get("kind", "circle"))
	var origin: Vector2 = event.get("pos", Vector2.ZERO) as Vector2
	if kind == "sector":
		var offset: Vector2 = point - origin
		var radius: float = float(event.get("radius", 0.0)) + tolerance
		if offset.length_squared() > radius * radius:
			return false
		if offset.length_squared() < 0.001:
			return true
		var direction: Vector2 = event.get("direction", Vector2.RIGHT) as Vector2
		return abs(direction.normalized().angle_to(offset.normalized())) <= float(event.get("half_angle", 0.0)) + 0.025
	var radius: float = float(event.get("radius", 0.0)) + tolerance
	return point.distance_squared_to(origin) <= radius * radius


static func charge_contains(state: Dictionary, point: Vector2, tolerance: float = 6.0) -> bool:
	var origin: Vector2 = state.get("origin", Vector2.ZERO) as Vector2
	var end: Vector2 = state.get("end", origin) as Vector2
	var segment: Vector2 = end - origin
	var length_squared: float = segment.length_squared()
	if length_squared < 0.001:
		return point.distance_to(origin) <= float(state.get("width", 82.0)) * 0.5 + tolerance
	var ratio: float = clamp((point - origin).dot(segment) / length_squared, 0.0, 1.0)
	var closest: Vector2 = origin + segment * ratio
	return point.distance_to(closest) <= float(state.get("width", 82.0)) * 0.5 + tolerance
