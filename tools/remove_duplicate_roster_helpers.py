from pathlib import Path

path = Path("scripts/main.gd")
text = path.read_text(encoding="utf-8")
marker = "func assign_hero_to_reserve(hid: String) -> void:\n"
first = text.find(marker)
second = text.find(marker, first + len(marker))
if first < 0 or second < 0:
    raise SystemExit("expected duplicate assign_hero_to_reserve blocks")
# Remove the older duplicated roster-helper block and keep the later, newer implementation.
text = text[:first] + text[second:]
path.write_text(text, encoding="utf-8")
print("removed duplicated roster helper block")
