from pathlib import Path

path = Path("scripts/main.gd")
text = path.read_text(encoding="utf-8")
old = '''\t\t\t\t\tif i < enemies.size():
\t\t\t\t\t\tvar diff: Vector2 = enemies[i]["pos"] - center
\t\t\t\t\t\tif diff.length() <= wave_radius and abs(wrapf(diff.angle() - dir.angle(), -PI, PI)) <= 0.78:
\t\t\t\t\t\tvar live_index: int = damage_enemy(i, 8.0 + lv * 2.2, "caiwenji", false)
\t\t\t\t\t\tif live_index >= 0:
\t\t\t\t\t\t\tenemies[live_index]["knock"] += (
'''
new = '''\t\t\t\t\tif i < enemies.size():
\t\t\t\t\t\tvar diff: Vector2 = enemies[i]["pos"] - center
\t\t\t\t\t\tif diff.length() <= wave_radius and abs(wrapf(diff.angle() - dir.angle(), -PI, PI)) <= 0.78:
\t\t\t\t\t\t\tvar live_index: int = damage_enemy(i, 8.0 + lv * 2.2, "caiwenji", false)
\t\t\t\t\t\t\tif live_index >= 0:
\t\t\t\t\t\t\t\tenemies[live_index]["knock"] += (
'''
if old not in text:
    raise SystemExit("target block not found")
text = text.replace(old, new, 1)
path.write_text(text, encoding="utf-8")
print("Cai Wenji indentation repaired")
