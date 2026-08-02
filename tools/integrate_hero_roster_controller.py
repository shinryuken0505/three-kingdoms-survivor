from pathlib import Path
import re

PATH = Path("scripts/main.gd")
text = PATH.read_text(encoding="utf-8")

PRELOAD = 'const HeroRosterControllerScript = preload("res://scripts/systems/hero/hero_roster_controller.gd")\n'
ANCHOR = 'const HeroRosterManagerScript = preload("res://scripts/systems/hero/hero_roster_manager.gd")\n'
if PRELOAD not in text:
    if ANCHOR not in text:
        raise SystemExit("HeroRosterManager preload anchor not found")
    text = text.replace(ANCHOR, ANCHOR + PRELOAD, 1)


def replace_function(source: str, name: str, replacement: str) -> str:
    pattern = re.compile(
        rf"^func {re.escape(name)}\([^\n]*\) -> [^:]+:\n.*?(?=^func [A-Za-z0-9_]+\(|\Z)",
        re.MULTILINE | re.DOTALL,
    )
    matches = list(pattern.finditer(source))
    if len(matches) != 1:
        raise SystemExit(f"Expected exactly one {name}, found {len(matches)}")
    return source[: matches[0].start()] + replacement.rstrip() + "\n\n" + source[matches[0].end() :]


handle_config = '''func handle_hero_config_key(key: int) -> void:
\tvar order: Array[String] = known_hero_order()
\tif order.is_empty():
\t\tclose_hero_config()
\t\treturn
\thero_config_index = clampi(hero_config_index, 0, order.size() - 1)
\tif hero_position_picker_open:
\t\thandle_hero_position_picker_key(key)
\t\treturn
\tif is_up_key(key) or is_left_key(key):
\t\thero_config_index = HeroRosterControllerScript.wrap_cursor(hero_config_index, -1, order.size())
\t\tplay_sfx("ui_move")
\telif is_down_key(key) or is_right_key(key):
\t\thero_config_index = HeroRosterControllerScript.wrap_cursor(hero_config_index, 1, order.size())
\t\tplay_sfx("ui_move")
\telif key == KEY_ESCAPE or key == KEY_TAB:
\t\tclose_hero_config()
\telif is_confirm_key(key):
\t\tvar hid: String = order[hero_config_index]
\t\tvar decision: Dictionary = HeroRosterControllerScript.open_picker_for(
\t\t\thid,
\t\t\thero_roster_state(hid)
\t\t)
\t\thero_position_candidate = str(decision.get("hero_id", hid))
\t\thero_position_index = int(decision.get("target_index", 2))
\t\thero_position_picker_open = true
\t\tplay_sfx("ui_confirm")
\t\tqueue_redraw()
'''

handle_picker = '''func handle_hero_position_picker_key(key: int) -> void:
\tif key == KEY_ESCAPE or key == KEY_TAB:
\t\thero_position_picker_open = false
\t\tplay_sfx("ui_cancel")
\t\tqueue_redraw()
\t\treturn
\tif is_up_key(key) or is_left_key(key):
\t\thero_position_index = HeroRosterControllerScript.wrap_cursor(hero_position_index, -1, 4)
\t\tplay_sfx("ui_move")
\t\tqueue_redraw()
\t\treturn
\tif is_down_key(key) or is_right_key(key):
\t\thero_position_index = HeroRosterControllerScript.wrap_cursor(hero_position_index, 1, 4)
\t\tplay_sfx("ui_move")
\t\tqueue_redraw()
\t\treturn
\tif not is_confirm_key(key):
\t\treturn
\tif hero_position_index == 3:
\t\thero_position_picker_open = false
\t\tplay_sfx("ui_cancel")
\t\tqueue_redraw()
\t\treturn

\tvar hid: String = hero_position_candidate
\tif hid == "" or not heroes.has(hid):
\t\thero_position_picker_open = false
\t\tqueue_redraw()
\t\treturn

\tvar decision: Dictionary = HeroRosterControllerScript.resolve_target(
\t\thid,
\t\thero_position_index,
\t\tactive_heroes,
\t\treserve_heroes,
\t\tcamp_heroes,
\t\tactive_limit(),
\t\treserve_limit()
\t)
\tvar action: StringName = decision.get("action", HeroRosterControllerScript.ACTION_NONE)
\tmatch action:
\t\tHeroRosterControllerScript.ACTION_ALREADY_ASSIGNED:
\t\t\tvar state_id: String = str(decision.get("state", "camp"))
\t\t\tvar state_label: String = "主戰" if state_id == "active" else ("後備" if state_id == "reserve" else "營地")
\t\t\tshow_message("%s目前已在%s。" % [heroes[hid]["name"], state_label], 2.0)
\t\t\thero_position_picker_open = false
\t\t\tplay_sfx("ui_error")
\t\tHeroRosterControllerScript.ACTION_OPEN_REPLACEMENT:
\t\t\tconfig_candidate = hid
\t\t\tconfig_replace_mode = str(decision.get("mode", "active"))
\t\t\tconfig_replace_index = 0
\t\t\thero_position_picker_open = false
\t\t\tscreen = "config_replace"
\t\t\tplay_sfx("ui_confirm")
\t\tHeroRosterControllerScript.ACTION_MOVE_HERO:
\t\t\tmatch str(decision.get("to", "camp")):
\t\t\t\t"active":
\t\t\t\t\tassign_hero_to_active(hid)
\t\t\t\t"reserve":
\t\t\t\t\tassign_hero_to_reserve(hid)
\t\t\t\t_:
\t\t\t\t\tassign_hero_to_camp(hid)
\t\t\thero_position_picker_open = false
\t\t_:
\t\t\thero_position_picker_open = false
\tqueue_redraw()
'''

text = replace_function(text, "handle_hero_config_key", handle_config)
text = replace_function(text, "handle_hero_position_picker_key", handle_picker)

# Guard against duplicate functions introduced by generated patches.
for fn in ["handle_hero_config_key", "handle_hero_position_picker_key"]:
    count = len(re.findall(rf"^func {fn}\(", text, re.MULTILINE))
    if count != 1:
        raise SystemExit(f"Post-patch validation failed for {fn}: {count}")

PATH.write_text(text, encoding="utf-8")
print("Integrated HeroRosterController into main.gd input flow")
