from pathlib import Path

path = Path("scripts/main.gd")
text = path.read_text(encoding="utf-8")

broken = '''\t\t\tif chapter_manager.mark_boss_active():
\t\t\t\tboss_spawned = true
\tboss["telegraph_time"] = 0.0
\tboss["telegraph_total"] = 0.0
\tboss["control_lock"] = 0.0
\t\t\t\tscreen = "game"
\t\t\t\tplay_current_boss_bgm()
'''

fixed = '''\t\t\tif chapter_manager.mark_boss_active():
\t\t\t\tboss_spawned = true
\t\t\t\tboss["telegraph_time"] = 0.0
\t\t\t\tboss["telegraph_total"] = 0.0
\t\t\t\tboss["control_lock"] = 0.0
\t\t\t\tscreen = "game"
\t\t\t\tplay_current_boss_bgm()
'''

if broken not in text:
    raise SystemExit("Alpha.30 malformed _process block not found")

text = text.replace(broken, fixed, 1)
path.write_text(text, encoding="utf-8")
print("Fixed Alpha.30 _process indentation")
