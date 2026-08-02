from pathlib import Path

path = Path("scripts/main.gd")
text = path.read_text(encoding="utf-8")


def replace_once(old: str, new: str) -> None:
    global text
    if old not in text:
        raise SystemExit(f"missing patch target:\n{old[:160]}")
    text = text.replace(old, new, 1)

replace_once(
    'const HeroProgressionRules = preload("res://scripts/systems/hero/hero_progression_rules.gd")\nconst GAME_VERSION: String = "V2.0.0-alpha.16"',
    'const HeroProgressionRules = preload("res://scripts/systems/hero/hero_progression_rules.gd")\nconst EndingManagerScript = preload("res://scripts/systems/ending/ending_manager.gd")\nconst GAME_VERSION: String = "V2.0.0-alpha.17"',
)
replace_once(
    'var chapter_manager: Variant = null',
    'var chapter_manager: Variant = null\nvar ending_manager: Variant = null',
)
replace_once(
    'var pending_run_result: int = 0  # 1=勝利，-1=失敗；統一在更新階段安全結算',
    'var pending_run_result: int = 0  # 1=勝利，-1=失敗；統一在更新階段安全結算\nvar ending_snapshot: Dictionary = {}\nvar ending_committed: bool = false',
)
replace_once(
    'chapter_manager = ChapterManagerScript.new()\n\tchapter_manager.configure(GameData.chapters(), GameData.trial_chapter())',
    'chapter_manager = ChapterManagerScript.new()\n\tchapter_manager.configure(GameData.chapters(), GameData.trial_chapter())\n\tending_manager = EndingManagerScript.new()',
)
replace_once(
    'if screen in ["hero_encounter_pick", "hero_encounter", "shop", "game_over", "victory", "boss_loot", "camp_menu"]:',
    'if screen in ["hero_encounter_pick", "hero_encounter", "shop", "game_over", "victory", "ending", "boss_loot", "camp_menu"]:',
)
replace_once(
    '\t\t"game_over", "victory":\n\t\t\tcount = result_options().size()',
    '\t\t"game_over", "victory", "ending":\n\t\t\tcount = result_options().size()',
)
replace_once(
    '\t\t\t"victory":\n\t\t\t\thandle_victory_option(option_index)',
    '\t\t\t"victory", "ending":\n\t\t\t\thandle_victory_option(option_index)',
)
replace_once(
    'func result_options() -> Array[String]:\n\tif screen == "game_over":',
    'func result_options() -> Array[String]:\n\tif screen == "ending":\n\t\treturn ["返回主選單"]\n\tif screen == "game_over":',
)
replace_once(
    '\tpending_boss_loot.clear()\n\tboss_ability_banner.clear()',
    '\tpending_boss_loot.clear()\n\tending_snapshot.clear()\n\tending_committed = false\n\tboss_ability_banner.clear()',
)
replace_once(
    '\tif victory:\n\t\tboss_spawned = false\n\t\tprepare_boss_loot()\n\t\tscreen = "boss_loot"',
    '\tif victory:\n\t\tboss_spawned = false\n\t\tif chosen_mode == "story" and chapter_manager.is_final_chapter():\n\t\t\tfinalize_campaign_ending()\n\t\telse:\n\t\t\tprepare_boss_loot()\n\t\t\tscreen = "boss_loot"',
)
replace_once(
    '\t\t"boss_loot":\n\t\t\tdraw_boss_loot_screen()\n\t\t"game_over", "victory":',
    '\t\t"boss_loot":\n\t\t\tdraw_boss_loot_screen()\n\t\t"ending":\n\t\t\tdraw_ending_screen()\n\t\t"game_over", "victory":',
)

ending_functions = r'''

func finalize_campaign_ending() -> void:
	if ending_committed:
		return
	ending_committed = true
	if not chapter_manager.boss_is_defeated():
		ending_committed = false
		return
	var definition: Dictionary = chapter_manager.boss_definition()
	var context: Dictionary = {
		"chapter_id": chapter_manager.current_id(),
		"chapter_title": chapter_manager.current_title(),
		"identity": chosen_identity,
		"elapsed": elapsed,
		"stats": run_stats.duplicate(true),
		"active_heroes": active_heroes.duplicate(),
		"reserve_heroes": reserve_heroes.duplicate(),
		"active_bonds": active_bonds.duplicate(),
		"relics": relics.duplicate(),
		"equipment": equipped.duplicate(true),
		"history_log": history_log.duplicate(),
		"route_tags": history_route_tags.duplicate(true),
		"faction_momentum": faction_momentum.duplicate(true),
		"rewrite_rate": history_rewrite_rate
	}
	ending_snapshot = ending_manager.build_snapshot(context)
	chapter_manager.resolve_chapter()
	game_over_reason = "擊敗%s，亂世旅程寫下最終一頁。" % str(definition.get("name", "最終敵將"))
	pending_boss_loot.clear()
	chapter_reward_relic = ""
	clear_run_checkpoint()
	option_index = 0
	screen = "ending"
	play_bgm("victory", 1.2)
	play_sfx("equipment_drop", 0.85)


func ending_hero_names(ids: Variant) -> String:
	var names: Array[String] = []
	if ids is Array:
		for value in ids:
			var hid: String = str(value)
			names.append(str(heroes.get(hid, {}).get("name", hid)))
	return "、".join(names) if not names.is_empty() else "無"


func ending_equipment_summary() -> String:
	var parts: Array[String] = []
	var equipment: Dictionary = ending_snapshot.get("equipment", {}) as Dictionary
	for slot in ["weapon", "body", "treasure", "accessory", "jade"]:
		var eid: String = str(equipment.get(slot, ""))
		if eid != "" and equipment_defs.has(eid):
			parts.append(str(equipment_defs[eid].get("name", eid)))
	return "、".join(parts) if not parts.is_empty() else "未裝備"


func draw_ending_screen() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color8(17, 20, 20), true)
	var root: Rect2 = Rect2(90, 42, 1100, 636)
	draw_panel(root, Color(0.025, 0.03, 0.029, 0.99), Color8(206, 169, 91), 2.4)
	draw_text("亂世終卷", Vector2(640, 92), 25, Color8(183, 170, 135), true, HORIZONTAL_ALIGNMENT_CENTER, 620)
	draw_text(str(ending_snapshot.get("title", "亂世見證者")), Vector2(640, 142), 43, Color8(244, 215, 151), true, HORIZONTAL_ALIGNMENT_CENTER, 900)
	draw_wrapped(str(ending_snapshot.get("narration", "")), Rect2(150, 166, 980, 82), 18, Color8(221, 221, 207), 27.0, true)
	var left: Rect2 = Rect2(140, 270, 480, 260)
	var right: Rect2 = Rect2(660, 270, 480, 260)
	draw_panel(left, Color(0.04, 0.046, 0.044, 0.96), Color8(116, 103, 72), 1.3)
	draw_panel(right, Color(0.04, 0.046, 0.044, 0.96), Color8(116, 103, 72), 1.3)
	var stats: Dictionary = ending_snapshot.get("stats", {}) as Dictionary
	var seconds: int = int(float(ending_snapshot.get("elapsed", 0.0)))
	var left_lines: Array[String] = [
		"最終章　%s" % str(ending_snapshot.get("chapter_title", "")),
		"遊玩時間　%02d:%02d:%02d" % [seconds / 3600, (seconds / 60) % 60, seconds % 60],
		"擊敗敵軍　%d" % int(stats.get("kills", 0)),
		"造成傷害　%d" % int(stats.get("damage_dealt", 0.0)),
		"承受傷害　%d" % int(stats.get("damage_taken", 0.0))
	]
	for i in range(left_lines.size()):
		draw_text(left_lines[i], left.position + Vector2(24, 42 + i * 42), 17, Color8(223, 212, 184), i == 0)
	draw_text("同行群英", right.position + Vector2(24, 40), 21, Color8(235, 211, 157), true)
	draw_wrapped("主動：%s\n後備：%s" % [ending_hero_names(ending_snapshot.get("active_heroes", [])), ending_hero_names(ending_snapshot.get("reserve_heroes", []))], Rect2(right.position + Vector2(24, 58), Vector2(432, 78)), 16, Color8(207, 214, 204), 24.0)
	draw_text("最終裝備", right.position + Vector2(24, 158), 19, Color8(235, 211, 157), true)
	draw_wrapped(ending_equipment_summary(), Rect2(right.position + Vector2(24, 176), Vector2(432, 58)), 15, Color8(194, 204, 194), 22.0)
	draw_wrapped("史官評曰：%s" % str(ending_snapshot.get("historian_comment", "")), Rect2(145, 548, 990, 54), 16, Color8(212, 194, 151), 23.0, true)
	var button: Rect2 = Rect2(485, 612, 310, 50)
	draw_panel(button, Color(0.48, 0.34, 0.13, 0.94), Color8(235, 204, 137), 1.8)
	draw_centered_text("返回主選單", button, 33.0, 20, Color8(245, 231, 198), true)
'''

replace_once('\n\nfunc draw_boss_loot_screen() -> void:', ending_functions + '\n\nfunc draw_boss_loot_screen() -> void:')

path.write_text(text, encoding="utf-8")
print("Alpha.17 ending patch applied")
