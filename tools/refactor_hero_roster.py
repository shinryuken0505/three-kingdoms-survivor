from pathlib import Path
import re

path = Path("scripts/main.gd")
text = path.read_text(encoding="utf-8")

preload_anchor = 'const HeroProgressionRules = preload("res://scripts/systems/hero/hero_progression_rules.gd")\n'
preload_line = 'const HeroRosterManagerScript = preload("res://scripts/systems/hero/hero_roster_manager.gd")\n'
if preload_line not in text:
    if preload_anchor not in text:
        raise SystemExit("hero progression preload anchor missing")
    text = text.replace(preload_anchor, preload_anchor + preload_line, 1)

# 移除歷次 patch 遺留的重複名將編成函式，稍後只插入一份 canonical wrappers。
targets = [
    "assign_hero_to_reserve",
    "assign_hero_to_camp",
    "assign_hero_to_active",
    "cycle_support_assignment",
    "place_hero_in_support",
    "hero_roster_state",
]
for name in targets:
    pattern = re.compile(rf"\nfunc {re.escape(name)}\([^\n]*\).*?(?=\nfunc |\Z)", re.S)
    text, count = pattern.subn("", text)
    print(f"removed {name}: {count}")

anchor = "\nfunc handle_hero_config_key(key: int) -> void:\n"
if anchor not in text:
    raise SystemExit("handle_hero_config_key anchor missing")

canonical = r'''

func hero_roster_state(hid: String) -> String:
	return HeroRosterManagerScript.state_of(hid, active_heroes, reserve_heroes, camp_heroes)


func sync_roster_after_change() -> void:
	update_bonds()
	if hero_config_origin == "intermission":
		save_run_checkpoint()


func assign_hero_to_reserve(hid: String) -> void:
	var result: Dictionary = HeroRosterManagerScript.move_to_reserve(
		hid, active_heroes, reserve_heroes, camp_heroes, reserve_limit()
	)
	match str(result.get("reason", "")):
		"already_reserve":
			show_message("%s已在後備被動欄。" % heroes[hid]["name"], 1.8)
			return
		"reserve_full":
			show_message("後備欄已滿，請先將一名後備武將移回營地。", 2.4)
			play_sfx("ui_error")
			return
	if bool(result.get("changed", false)):
		hero_cooldowns.erase(hid)
		sync_roster_after_change()
		show_message("%s編入後備，開始提供被動與羈絆。" % heroes[hid]["name"], 2.4)
		play_sfx("ui_confirm")


func assign_hero_to_camp(hid: String) -> void:
	var result: Dictionary = HeroRosterManagerScript.move_to_camp(
		hid, active_heroes, reserve_heroes, camp_heroes
	)
	if str(result.get("reason", "")) == "already_camp":
		show_message("%s目前已在營地待命。" % heroes[hid]["name"], 1.8)
		return
	if bool(result.get("changed", false)):
		hero_cooldowns.erase(hid)
		sync_roster_after_change()
		show_message("%s移至營地，不再提供後備被動。" % heroes[hid]["name"], 2.4)
		play_sfx("ui_confirm")


func assign_hero_to_active(hid: String) -> void:
	if active_heroes.has(hid):
		show_message("%s目前已在主戰陣容。" % heroes[hid]["name"], 1.8)
		return
	if active_heroes.size() >= active_limit():
		config_candidate = hid
		config_replace_index = 0
		screen = "config_replace"
		play_sfx("ui_confirm")
		return
	var result: Dictionary = HeroRosterManagerScript.move_to_active(
		hid, active_heroes, reserve_heroes, camp_heroes, active_limit()
	)
	if bool(result.get("changed", false)):
		hero_cooldowns[hid] = hero_cooldown_value(hid)
		sync_roster_after_change()
		show_message("%s調至主戰欄，技能由完整冷卻開始。" % heroes[hid]["name"], 2.5)
		play_sfx("ui_confirm")


func cycle_support_assignment(hid: String) -> void:
	match hero_roster_state(hid):
		"active":
			assign_hero_to_reserve(hid)
		"reserve":
			assign_hero_to_camp(hid)
		_:
			assign_hero_to_reserve(hid)


func place_hero_in_support(hid: String) -> String:
	var destination: String = HeroRosterManagerScript.place_in_support(
		hid, active_heroes, reserve_heroes, camp_heroes, reserve_limit()
	)
	hero_cooldowns.erase(hid)
	return destination
'''

text = text.replace(anchor, canonical + anchor, 1)

# 防止未來再不小心留下同名函式。
for name in targets:
    count = len(re.findall(rf"^func {re.escape(name)}\(", text, re.M))
    if count != 1:
        raise SystemExit(f"expected exactly one {name}, got {count}")

path.write_text(text, encoding="utf-8")
print("hero roster refactor applied")
