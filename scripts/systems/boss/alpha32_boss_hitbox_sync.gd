class_name Alpha32BossHitboxSync
extends RefCounted


static func contains_point(boss_data: Dictionary, point: Vector2, edge_tolerance: float = 6.0) -> bool:
	var profile: Dictionary = boss_data.get("telegraph_profile", {}) as Dictionary
	if profile.is_empty():
		return false
	var shape: String = str(boss_data.get("telegraph_shape", profile.get("shape", "circle")))
	var origin: Vector2 = boss_data.get("telegraph_origin", boss_data.get("pos", Vector2.ZERO)) as Vector2
	var target: Vector2 = boss_data.get("telegraph_target", origin) as Vector2
	var direction: Vector2 = boss_data.get("telegraph_direction", Vector2.RIGHT) as Vector2
	if direction.length_squared() < 0.001:
		direction = Vector2.RIGHT
	direction = direction.normalized()

	match shape:
		"line":
			return _inside_line(point, origin, direction, float(profile.get("length", 360.0)), float(profile.get("width", 76.0)) + edge_tolerance * 2.0)
		"sector":
			return _inside_sector(point, origin, direction, float(profile.get("radius", 230.0)) + edge_tolerance, float(profile.get("half_angle", deg_to_rad(36.0))))
		"multi_circle":
			return _inside_multi_circle(point, target, profile, edge_tolerance)
		_:
			return point.distance_to(target) <= float(profile.get("radius", 150.0)) + edge_tolerance


static func _inside_line(point: Vector2, origin: Vector2, direction: Vector2, length: float, width: float) -> bool:
	var local: Vector2 = point - origin
	var forward: float = local.dot(direction)
	if forward < 0.0 or forward > length:
		return false
	var side: Vector2 = Vector2(-direction.y, direction.x)
	return abs(local.dot(side)) <= width * 0.5


static func _inside_sector(point: Vector2, origin: Vector2, direction: Vector2, radius: float, half_angle: float) -> bool:
	var offset: Vector2 = point - origin
	if offset.length() > radius:
		return false
	if offset.length_squared() < 0.001:
		return true
	return abs(wrapf(offset.angle() - direction.angle(), -PI, PI)) <= half_angle


static func _inside_multi_circle(point: Vector2, target: Vector2, profile: Dictionary, tolerance: float) -> bool:
	var count: int = int(profile.get("count", 4))
	var spread: float = float(profile.get("spread", 120.0))
	var radius: float = float(profile.get("radius", 92.0)) + tolerance
	for index in range(count):
		var angle: float = TAU * float(index) / float(max(1, count))
		var center: Vector2 = target + Vector2.from_angle(angle) * spread
		if point.distance_to(center) <= radius:
			return true
	return false
