from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def write(path: str, content: str) -> None:
    target = ROOT / path
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(content.rstrip() + "\n", encoding="utf-8")


def replace_once(text: str, old: str, new: str, label: str) -> str:
    if old not in text:
        raise SystemExit(f"missing patch target ({label})")
    return text.replace(old, new, 1)


def replace_func(text: str, name: str, replacement: str) -> str:
    pattern = rf"(?ms)^func {re.escape(name)}\([^\n]*\)(?: -> [^:]+)?:\n.*?(?=^func |\Z)"
    updated, count = re.subn(pattern, replacement.rstrip() + "\n\n", text, count=1)
    if count != 1:
        raise SystemExit(f"unable to replace function: {name}")
    return updated


ENDING_MANAGER = r'''class_name EndingManager
extends RefCounted

const EndingData = preload("res://scripts/ending_data.gd")
const SNAPSHOT_VERSION: int = 2
const DEFAULT_ENDING_ID: String = "historical_witness"


func validate_context(context: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	for key in ["chapter_id", "chapter_title", "identity", "mode"]:
		if str(context.get(key, "")).strip_edges().is_empty():
			errors.append("missing ending context: %s" % key)
	if not (context.get("stats", {}) is Dictionary):
		errors.append("ending stats must be a Dictionary")
	if not (context.get("equipment", {}) is Dictionary):
		errors.append("ending equipment must be a Dictionary")
	return errors


func build_snapshot(context: Dictionary) -> Dictionary:
	var validation_errors: Array[String] = validate_context(context)
	if not validation_errors.is_empty():
		push_error("Ending context invalid: %s" % "; ".join(validation_errors))
	var ending: Dictionary = select_ending(context)
	return {
		"snapshot_version": SNAPSHOT_VERSION,
		"run_id": str(context.get("run_id", "")),
		"ending_id": str(ending.get("id", DEFAULT_ENDING_ID)),
		"title": str(ending.get("title", "亂世見證者")),
		"narration": str(ending.get("narration", "")),
		"historian_comment": str(ending.get("historian_comment", "")),
		"unlock_rewards": _string_array(ending.get("unlock_rewards", [])),
		"mode": str(context.get("mode", "story")),
		"difficulty": str(context.get("difficulty", "story")),
		"chapter_id": str(context.get("chapter_id", "")),
		"chapter_title": str(context.get("chapter_title", "")),
		"boss_id": str(context.get("boss_id", "")),
		"identity": str(context.get("identity", "")),
		"elapsed": float(context.get("elapsed", 0.0)),
		"stats": _dictionary_copy(context.get("stats", {})),
		"active_heroes": _string_array(context.get("active_heroes", [])),
		"reserve_heroes": _string_array(context.get("reserve_heroes", [])),
		"active_bonds": _string_array(context.get("active_bonds", [])),
		"relics": _string_array(context.get("relics", [])),
		"equipment": _dictionary_copy(context.get("equipment", {})),
		"completed_chapters": _string_array(context.get("completed_chapters", [])),
		"history_log": _string_array(context.get("history_log", [])),
		"route_tags": _dictionary_copy(context.get("route_tags", {})),
		"faction_momentum": _dictionary_copy(context.get("faction_momentum", {})),
		"rewrite_rate": float(context.get("rewrite_rate", 0.0)),
		"created_at_utc": Time.get_datetime_string_from_system(true)
	}


func select_ending(context: Dictionary) -> Dictionary:
	var definitions: Array[Dictionary] = EndingData.definitions()
	var matches: Array[Dictionary] = []
	for definition in definitions:
		if _matches(definition, context):
			matches.append(definition)
	if matches.is_empty():
		return {
			"id": DEFAULT_ENDING_ID,
			"title": "亂世見證者",
			"narration": "你走過亂世，留下屬於自己的足跡。",
			"historian_comment": "其志未必改天命，然其行已入史冊。",
			"unlock_rewards": []
		}
	matches.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ap: int = int(a.get("priority", 0))
		var bp: int = int(b.get("priority", 0))
		if ap != bp:
			return ap > bp
		return str(a.get("id", "")) < str(b.get("id", ""))
	)
	return matches[0].duplicate(true)


func _matches(definition: Dictionary, context: Dictionary) -> bool:
	var requirements: Dictionary = _dictionary_copy(definition.get("requirements", {}))
	if requirements.is_empty():
		return true
	var min_rewrite_rate: float = float(requirements.get("min_rewrite_rate", -1.0))
	if min_rewrite_rate >= 0.0 and float(context.get("rewrite_rate", 0.0)) < min_rewrite_rate:
		return false
	var required_tag: String = str(requirements.get("route_tag", ""))
	if required_tag != "":
		var route_tags: Dictionary = _dictionary_copy(context.get("route_tags", {}))
		if not bool(route_tags.get(required_tag, false)):
			return false
		var momentum: Dictionary = _dictionary_copy(context.get("faction_momentum", {}))
		var momentum_key: String = str({"han": "蜀", "wei": "魏", "wu": "吳"}.get(required_tag, required_tag))
		if int(momentum.get(momentum_key, 0)) < int(requirements.get("min_momentum", 0)):
			return false
	return true


func _dictionary_copy(value: Variant) -> Dictionary:
	return (value as Dictionary).duplicate(true) if value is Dictionary else {}


func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item in value:
			result.append(str(item))
	return result
'''

ENDING_UI = r'''class_name EndingUI
extends RefCounted


static func draw(host: Node, snapshot: Dictionary) -> void:
	host.draw_rect(Rect2(Vector2.ZERO, host.VIEW), Color8(17, 20, 20), true)
	var root := Rect2(90, 42, 1100, 636)
	host.draw_panel(root, Color(0.025, 0.03, 0.029, 0.99), Color8(206, 169, 91), 2.4)
	host.draw_text("亂世終卷", Vector2(640, 92), 25, Color8(183, 170, 135), true, HORIZONTAL_ALIGNMENT_CENTER, 620)
	host.draw_text(str(snapshot.get("title", "亂世見證者")), Vector2(640, 142), 43, Color8(244, 215, 151), true, HORIZONTAL_ALIGNMENT_CENTER, 900)
	host.draw_wrapped(str(snapshot.get("narration", "")), Rect2(150, 166, 980, 82), 18, Color8(221, 221, 207), 27.0, true)

	var left := Rect2(140, 270, 480, 260)
	var right := Rect2(660, 270, 480, 260)
	host.draw_panel(left, Color(0.04, 0.046, 0.044, 0.96), Color8(116, 103, 72), 1.3)
	host.draw_panel(right, Color(0.04, 0.046, 0.044, 0.96), Color8(116, 103, 72), 1.3)

	var stats: Dictionary = snapshot.get("stats", {}) as Dictionary
	var seconds := int(float(snapshot.get("elapsed", 0.0)))
	var left_lines: Array[String] = [
		"最終章　%s" % str(snapshot.get("chapter_title", "")),
		"遊玩時間　%02d:%02d:%02d" % [seconds / 3600, (seconds / 60) % 60, seconds % 60],
		"擊敗敵軍　%d" % int(stats.get("kills", 0)),
		"造成傷害　%d" % int(stats.get("damage_dealt", 0.0)),
		"承受傷害　%d" % int(stats.get("damage_taken", 0.0))
	]
	for i in range(left_lines.size()):
		host.draw_text(left_lines[i], left.position + Vector2(24, 42 + i * 42), 17, Color8(223, 212, 184), i == 0)

	host.draw_text("同行群英", right.position + Vector2(24, 40), 21, Color8(235, 211, 157), true)
	host.draw_wrapped(
		"主動：%s\n後備：%s" % [host.ending_hero_names(snapshot.get("active_heroes", [])), host.ending_hero_names(snapshot.get("reserve_heroes", []))],
		Rect2(right.position + Vector2(24, 58), Vector2(432, 78)), 16, Color8(207, 214, 204), 24.0
	)
	host.draw_text("最終裝備", right.position + Vector2(24, 158), 19, Color8(235, 211, 157), true)
	host.draw_wrapped(host.ending_equipment_summary(snapshot), Rect2(right.position + Vector2(24, 176), Vector2(432, 58)), 15, Color8(194, 204, 194), 22.0)
	host.draw_wrapped("史官評曰：%s" % str(snapshot.get("historian_comment", "")), Rect2(145, 548, 990, 54), 16, Color8(212, 194, 151), 23.0, true)

	var button := Rect2(485, 612, 310, 50)
	host.draw_panel(button, Color(0.48, 0.34, 0.13, 0.94), Color8(235, 204, 137), 1.8)
	host.draw_centered_text("返回主選單", button, 33.0, 20, Color8(245, 231, 198), true)
'''

ENDING_MANAGER_TEST = r'''extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	var manager := EndingManager.new()
	var invalid := manager.validate_context({})
	check(not invalid.is_empty(), "empty ending context should be rejected")
	var context := {
		"run_id": "test-run",
		"mode": "story",
		"difficulty": "story",
		"chapter_id": "final",
		"chapter_title": "最終章",
		"boss_id": "final_boss",
		"identity": "swordsman",
		"stats": {},
		"equipment": {},
		"completed_chapters": ["a", "b"],
		"route_tags": {},
		"faction_momentum": {},
	}
	check(manager.validate_context(context).is_empty(), "valid ending context should pass")
	var snapshot := manager.build_snapshot(context)
	check(int(snapshot.get("snapshot_version", 0)) == EndingManager.SNAPSHOT_VERSION, "snapshot version should be current")
	check(str(snapshot.get("run_id", "")) == "test-run", "run id should persist")
	check(str(snapshot.get("boss_id", "")) == "final_boss", "boss id should persist")
	check((snapshot.get("completed_chapters", []) as Array).size() == 2, "completed chapters should persist")
	finish()


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func finish() -> void:
	if failures.is_empty():
		print("[PASS] ending_manager_test")
		quit(0)
		return
	for failure in failures:
		push_error("[FAIL] %s" % failure)
	quit(1)
'''

CHECKER = r'''from pathlib import Path

root = Path(__file__).resolve().parents[1]
main = (root / "scripts/main.gd").read_text(encoding="utf-8")
chapter = (root / "scripts/chapter_manager.gd").read_text(encoding="utf-8")
manager = (root / "scripts/systems/ending/ending_manager.gd").read_text(encoding="utf-8")
routes = (root / "scripts/core/screen_route_registry.gd").read_text(encoding="utf-8")

checks = {
    "final boss loot before ending": 'prepare_boss_loot()\n\t\tscreen = "boss_loot"' in main,
    "finalization after loot": 'chapter_manager.is_final_chapter()' in main and 'finalize_campaign_ending()' in main,
    "transactional ending save": 'var previous_save_data: Dictionary = save_data.duplicate(true)' in main,
    "save failure retains checkpoint": 'save_data = previous_save_data' in main,
    "chapter finalization API": 'func can_finalize_campaign()' in chapter,
    "snapshot schema": 'const SNAPSHOT_VERSION: int = 2' in manager,
    "ending draw route alias": 'func draw_ending()' in main,
    "ending input route alias": 'func handle_ending_key(' in main,
    "registry ending route": 'ScreenIds.ENDING: route(&"draw_ending", &"handle_ending_key")' in routes,
}
failed = [name for name, ok in checks.items() if not ok]
if failed:
    raise SystemExit("ending flow checks failed: " + ", ".join(failed))
print("[PASS] ending flow hardening checks")
'''

write("scripts/systems/ending/ending_manager.gd", ENDING_MANAGER)
write("scripts/ui/ending_ui.gd", ENDING_UI)
write("tests/ending_manager_test.gd", ENDING_MANAGER_TEST)
write("tools/check_ending_flow_hardening.py", CHECKER)

chapter_path = ROOT / "scripts/chapter_manager.gd"
chapter = chapter_path.read_text(encoding="utf-8")
if "func can_finalize_campaign()" not in chapter:
    marker = "\n\nfunc boss_state_label() -> String:\n"
    addition = r'''

func can_finalize_chapter() -> bool:
	return boss_state == BossState.DEFEATED


func can_finalize_campaign() -> bool:
	return is_final_chapter() and can_finalize_chapter()


func finalize_campaign() -> bool:
	if not can_finalize_campaign():
		return false
	return resolve_chapter()
'''
    chapter = replace_once(chapter, marker, addition + marker, "chapter finalization API")
chapter_path.write_text(chapter, encoding="utf-8")

main_path = ROOT / "scripts/main.gd"
main = main_path.read_text(encoding="utf-8")

# Final chapter must use the same loot claim path as every other chapter.
main = replace_once(
    main,
    '\tif victory:\n\t\tboss_spawned = false\n\t\tif chosen_mode == "story" and chapter_manager.is_final_chapter():\n\t\t\tfinalize_campaign_ending()\n\t\telse:\n\t\t\tprepare_boss_loot()\n\t\t\tscreen = "boss_loot"',
    '\tif victory:\n\t\tboss_spawned = false\n\t\tprepare_boss_loot()\n\t\tscreen = "boss_loot"',
    "final boss loot path",
)

finalize_chapter = r'''func finalize_chapter_victory() -> void:
	if chosen_mode == "story" and chapter_manager.is_final_chapter():
		finalize_campaign_ending()
		return
	if not chapter_manager.resolve_chapter():
		push_error("Chapter victory could not be resolved")
		return
	screen = "victory"
	var definition: Dictionary = chapter_manager.boss_definition()
	game_over_reason = "擊敗%s，%s戰局暫告一段落。" % [str(definition.get("name", "敵將")), chapter_manager.current_title()]
	chapter_clear_snapshot = {
		"chapter_id": chapter_manager.current_id(),
		"chapter_title": chapter_manager.current_title(),
		"reward_relic": chapter_reward_relic
	}
	if chapter_manager.has_next_chapter():
		save_run_checkpoint()
	else:
		clear_run_checkpoint()
	option_index = 0
'''
main = replace_func(main, "finalize_chapter_victory", finalize_chapter)

finalize_ending = r'''func finalize_campaign_ending() -> bool:
	if ending_committed:
		return true
	if not chapter_manager.can_finalize_campaign():
		push_error("Campaign ending requested before final boss defeat")
		return false
	ending_committed = true
	var definition: Dictionary = chapter_manager.boss_definition()
	var run_save: Dictionary = save_data.get("run_save", {}) as Dictionary
	var run_id: String = str(run_save.get("run_id", ""))
	if run_id.is_empty():
		run_id = "%s:%s:%s" % [chosen_mode, chosen_identity, str(run_save.get("saved_at", save_data.get("last_saved_at", "unknown")))]
	var context: Dictionary = {
		"run_id": run_id,
		"mode": chosen_mode,
		"difficulty": difficulty_id(),
		"chapter_id": chapter_manager.current_id(),
		"chapter_title": chapter_manager.current_title(),
		"boss_id": str(definition.get("id", "")),
		"identity": chosen_identity,
		"elapsed": elapsed,
		"stats": run_stats.duplicate(true),
		"active_heroes": active_heroes.duplicate(),
		"reserve_heroes": reserve_heroes.duplicate(),
		"active_bonds": active_bonds.duplicate(),
		"relics": relics.duplicate(),
		"equipment": equipped.duplicate(true),
		"completed_chapters": chapter_manager.completed_ids(),
		"history_log": history_log.duplicate(),
		"route_tags": history_route_tags.duplicate(true),
		"faction_momentum": faction_momentum.duplicate(true),
		"rewrite_rate": history_rewrite_rate
	}
	var validation_errors: Array[String] = ending_manager.validate_context(context)
	if not validation_errors.is_empty():
		ending_committed = false
		push_error("Ending context rejected: %s" % "; ".join(validation_errors))
		return false
	ending_snapshot = ending_manager.build_snapshot(context)
	var previous_save_data: Dictionary = save_data.duplicate(true)
	if not (save_data.get("endings", {}) is Dictionary):
		save_data["endings"] = {}
	var ending_id: String = str(ending_snapshot.get("ending_id", "historical_witness"))
	(save_data["endings"] as Dictionary)[ending_id] = ending_snapshot.duplicate(true)
	save_data["latest_ending"] = ending_snapshot.duplicate(true)
	save_data["run_save"] = {}
	if not save_game_meta():
		save_data = previous_save_data
		ending_committed = false
		ending_snapshot["historian_comment"] = str(ending_snapshot.get("historian_comment", "")) + "（結局紀錄寫入失敗；章間進度仍保留。）"
		screen = "ending"
		option_index = 0
		return false
	if not chapter_manager.finalize_campaign():
		push_error("Ending saved but chapter manager could not finalize campaign")
	game_over_reason = "擊敗%s，亂世旅程寫下最終一頁。" % str(definition.get("name", "最終敵將"))
	pending_boss_loot.clear()
	chapter_reward_relic = ""
	option_index = 0
	screen = "ending"
	play_bgm("victory", 1.2)
	play_sfx("equipment_drop", 0.85)
	return true
'''
main = replace_func(main, "finalize_campaign_ending", finalize_ending)

# UI must render only from the immutable snapshot.
main = re.sub(
    r'func ending_equipment_summary\(\) -> String:\n',
    'func ending_equipment_summary(snapshot: Dictionary = ending_snapshot) -> String:\n',
    main,
    count=1,
)
main = main.replace(
    '\tvar equipment: Dictionary = ending_snapshot.get("equipment", {}) as Dictionary',
    '\tvar equipment: Dictionary = snapshot.get("equipment", {}) as Dictionary',
    1,
)

if "func draw_ending() -> void:" not in main:
    alias_block = r'''

func draw_ending() -> void:
	draw_ending_screen()


func handle_ending_key(key: int) -> void:
	if is_confirm_key(key) or key == KEY_ESCAPE:
		option_index = 0
		handle_victory_option(0)
'''
    main = replace_once(main, "\nfunc draw_boss_loot_screen() -> void:", alias_block + "\n\nfunc draw_boss_loot_screen() -> void:", "ending route aliases")

main_path.write_text(main, encoding="utf-8")

# Extend the existing integration smoke test with the concrete route contract.
smoke_path = ROOT / "tests/alpha17_integration_smoke_test.gd"
smoke = smoke_path.read_text(encoding="utf-8")
if "ending route draw method should exist" not in smoke:
    old = '\t\tcheck(root.has_node("StatusEffectHudLayer"), "main scene should mount StatusEffectHudLayer")\n\t\troot.free()'
    new = '\t\tcheck(root.has_node("StatusEffectHudLayer"), "main scene should mount StatusEffectHudLayer")\n\t\tcheck(root.has_method("draw_ending"), "ending route draw method should exist")\n\t\tcheck(root.has_method("handle_ending_key"), "ending route input method should exist")\n\t\troot.free()'
    smoke = replace_once(smoke, old, new, "ending smoke route")
smoke_path.write_text(smoke, encoding="utf-8")

print("Alpha.17 ending flow hardening patch applied")
