extends RefCounted

const CatalogScript = preload("res://scripts/data/chapter_identity_catalog.gd")


static func run() -> Array[String]:
	var errors: Array[String] = []
	var seen_ids: Dictionary = {}
	for chapter_index in range(8):
		var profile_data: Dictionary = CatalogScript.profile(chapter_index)
		var chapter_id: String = str(profile_data.get("id", ""))
		if chapter_id.is_empty():
			errors.append("Chapter %d has no id" % chapter_index)
		if seen_ids.has(chapter_id):
			errors.append("Duplicate chapter id: %s" % chapter_id)
		seen_ids[chapter_id] = true
		if str(profile_data.get("name", "")).is_empty():
			errors.append("Chapter %d has no display name" % chapter_index)
		if CatalogScript.event_ratio(profile_data, 0) <= 0.0:
			errors.append("Chapter %d has no first battle event" % chapter_index)
		if CatalogScript.event_ratio(profile_data, 1) <= CatalogScript.event_ratio(profile_data, 0):
			errors.append("Chapter %d event order is invalid" % chapter_index)
		if float(profile_data.get("boss_phase_damage", 1.0)) < 1.0:
			errors.append("Chapter %d boss phase damage is invalid" % chapter_index)
	return errors
