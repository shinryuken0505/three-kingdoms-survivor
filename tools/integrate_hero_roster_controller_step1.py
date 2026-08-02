from pathlib import Path

path = Path("scripts/main.gd")
text = path.read_text(encoding="utf-8")

preload_anchor = 'const HeroRosterManagerScript = preload("res://scripts/systems/hero/hero_roster_manager.gd")\n'
preload_line = 'const HeroRosterControllerScript = preload("res://scripts/systems/hero/hero_roster_controller.gd")\n'
if preload_line not in text:
    if preload_anchor not in text:
        raise SystemExit("HeroRosterManager preload anchor not found")
    text = text.replace(preload_anchor, preload_anchor + preload_line, 1)

old = '''\telif is_confirm_key(key):
\t\thero_position_candidate = order[hero_config_index]
\t\tvar current_state: String = hero_roster_state(hero_position_candidate)
\t\thero_position_index = 0 if current_state == "active" else (1 if current_state == "reserve" else 2)
\t\thero_position_picker_open = true
\t\tqueue_redraw()
\t\tplay_sfx("ui_confirm")
'''
new = '''\telif is_confirm_key(key):
\t\tvar hero_id: String = order[hero_config_index]
\t\tvar decision: Dictionary = HeroRosterControllerScript.open_picker_for(
\t\t\thero_id,
\t\t\thero_roster_state(hero_id)
\t\t)
\t\thero_position_candidate = str(decision.get("hero_id", hero_id))
\t\thero_position_index = int(decision.get("target_index", 2))
\t\thero_position_picker_open = true
\t\tqueue_redraw()
\t\tplay_sfx("ui_confirm")
'''

if old not in text:
    raise SystemExit("Expected hero-config confirm block not found; refusing unsafe patch")
if text.count(old) != 1:
    raise SystemExit(f"Expected exactly one confirm block, found {text.count(old)}")
text = text.replace(old, new, 1)

if text.count("HeroRosterControllerScript.open_picker_for(") != 1:
    raise SystemExit("Controller integration validation failed")

path.write_text(text, encoding="utf-8")
print("Integrated HeroRosterController.open_picker_for into main.gd")
