class_name HeroProgressionRules
extends RefCounted

const MAX_SKILL_LEVEL: int = 8
const MAX_BOND_LEVEL: int = 5

static func chapter_skill_floor(chapter_number: int) -> int:
	if chapter_number >= 9: return 5
	if chapter_number >= 7: return 4
	if chapter_number >= 5: return 3
	if chapter_number >= 3: return 2
	return 1

static func initial_skill_level(chapter_number: int, active_levels: Array[int]) -> int:
	var floor_level: int = chapter_skill_floor(chapter_number)
	if active_levels.is_empty():
		return floor_level
	var total: int = 0
	for value in active_levels:
		total += value
	var catch_up: int = maxi(1, int(round(float(total) / float(active_levels.size()))) - 1)
	return clampi(maxi(floor_level, catch_up), 1, 6)

static func initial_bond_level(chapter_number: int) -> int:
	if chapter_number >= 10: return 4
	if chapter_number >= 7: return 3
	if chapter_number >= 5: return 2
	return 1

static func upgrade_description(_hero_id: String, target_level: int, skill_upgrade: bool) -> String:
	if skill_upgrade:
		match target_level:
			3: return "招式範圍、控制或持續效果獲得第一次質變。"
			5: return "主動技能完成第一次進化，追加專屬效果。"
			7: return "解鎖第二種特殊效果，強化流派搭配。"
			8: return "技能達到完全體，威力、範圍與演出同步提升。"
		return "提升技能威力並縮短部分冷卻時間。"
	match target_level:
		3: return "主戰技能獲得角色特色強化。"
		4: return "後備被動進化，隊伍支援能力提升。"
		5: return "完成覺醒，解鎖專屬連攜或高階被動。"
	return "提升被動效果與羈絆加成。"
