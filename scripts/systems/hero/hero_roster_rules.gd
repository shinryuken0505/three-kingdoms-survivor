class_name HeroRosterRules
extends RefCounted

static func active_limit_for_chapter(chapter_number: int) -> int:
	if chapter_number >= 10:
		return 5
	if chapter_number >= 7:
		return 4
	if chapter_number >= 3:
		return 3
	return 2

static func reserve_limit_for_chapter(chapter_number: int) -> int:
	if chapter_number >= 9:
		return 5
	if chapter_number >= 5:
		return 4
	return 3

static func formation_summary(chapter_number: int) -> String:
	return "主戰%d／後備%d／營地不限" % [active_limit_for_chapter(chapter_number), reserve_limit_for_chapter(chapter_number)]
