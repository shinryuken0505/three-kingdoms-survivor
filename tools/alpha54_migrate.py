from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def write(path: str, text: str) -> None:
    (ROOT / path).write_text(text, encoding="utf-8")


def replace_once(text: str, old: str, new: str, label: str) -> str:
    if new in text:
        return text
    if old not in text:
        raise SystemExit(f"Alpha54 migration could not find {label}")
    return text.replace(old, new, 1)


# Version synchronization.
project = read("project.godot").replace("V2.0.0-alpha.53", "V2.0.0-alpha.54")
write("project.godot", project)

coordinator = read("scripts/core/alpha48_runtime_coordinator.gd").replace("V2.0.0-alpha.53", "V2.0.0-alpha.54")
write("scripts/core/alpha48_runtime_coordinator.gd", coordinator)

main = read("scripts/main.gd").replace("V2.0.0-alpha.53", "V2.0.0-alpha.54")
main = replace_once(
    main,
    'const StatusEffectService = preload("res://scripts/systems/combat/status_effect_service.gd")\n',
    'const StatusEffectService = preload("res://scripts/systems/combat/status_effect_service.gd")\nconst ElementalSynergyService = preload("res://scripts/systems/combat/elemental_synergy_service.gd")\n',
    "elemental synergy preload",
)

# Armor break now modifies actual physical damage; lightning damage applies Shock.
if "ElementalSynergyService.damage_multiplier(enemies[index], source)" not in main:
    pattern = r'(func damage_enemy\(index: int, damage: float, source: String, crit: bool[^\n]*\) -> int:\n)'
    replacement = (
        r'\1'
        '\tif index >= 0 and index < enemies.size():\n'
        '\t\tdamage *= ElementalSynergyService.damage_multiplier(enemies[index], source)\n'
        '\t\tif ElementalSynergyService.is_lightning_source(source):\n'
        '\t\t\tStatusEffectService.apply_enemy(self, index, "shock", 2.4, 0.22, 1)\n'
    )
    main, count = re.subn(pattern, replacement, main, count=1)
    if count != 1:
        raise SystemExit("Alpha54 migration could not patch damage_enemy")

if "ElementalSynergyService.damage_multiplier(boss, source)" not in main:
    pattern = r'(func damage_boss\(damage: float, source: String, crit: bool[^\n]*\) -> void:\n)'
    replacement = (
        r'\1'
        '\tif not boss.is_empty():\n'
        '\t\tdamage *= ElementalSynergyService.damage_multiplier(boss, source)\n'
        '\t\tif ElementalSynergyService.is_lightning_source(source):\n'
        '\t\t\tStatusEffectService.apply_boss(self, "shock", 2.0, 0.18, 1)\n'
    )
    main, count = re.subn(pattern, replacement, main, count=1)
    if count != 1:
        raise SystemExit("Alpha54 migration could not patch damage_boss")

# Compact enemy status dots: maximum three, so high-density battles stay readable.
status_feedback = '''\t# Alpha.54：敵人異常狀態以最多三個小圓點呈現，避免文字與特效淹沒戰場。\n\tfor status_enemy in enemies:\n\t\tvar status_pos: Vector2 = world_to_screen(status_enemy.get("pos", Vector2.ZERO))\n\t\tif not Rect2(-80, -80, VIEW.x + 160, VIEW.y + 160).has_point(status_pos):\n\t\t\tcontinue\n\t\tvar status_map_value: Variant = status_enemy.get("status_effects", {})\n\t\tif not status_map_value is Dictionary:\n\t\t\tcontinue\n\t\tvar status_map: Dictionary = status_map_value as Dictionary\n\t\tvar status_slot: int = 0\n\t\tfor status_id in StatusEffectService.EFFECT_ORDER:\n\t\t\tif not status_map.has(status_id):\n\t\t\t\tcontinue\n\t\t\tvar status_data: Dictionary = status_map[status_id] as Dictionary\n\t\t\tif float(status_data.get("duration", 0.0)) <= 0.0:\n\t\t\t\tcontinue\n\t\t\tvar dot_pos: Vector2 = status_pos + Vector2(-12.0 + float(status_slot) * 12.0, -31.0 if not bool(status_enemy.get("elite", false)) else -58.0)\n\t\t\tdraw_circle(dot_pos, 4.0, StatusEffectService.effect_color(status_id))\n\t\t\tdraw_circle(dot_pos, 5.5, Color(1, 1, 1, 0.35), false, 1.0)\n\t\t\tstatus_slot += 1\n\t\t\tif status_slot >= 3:\n\t\t\t\tbreak\n'''
if "Alpha.54：敵人異常狀態以最多三個小圓點呈現" not in main:
    marker = "\t# Boss\n\tif not boss.is_empty():"
    if marker not in main:
        raise SystemExit("Alpha54 migration could not find Boss drawing marker")
    main = main.replace(marker, status_feedback + marker, 1)

# Extend project self-test with actual status reaction checks.
self_test_block = '''\t# Alpha.54：異常聯動回歸。\n\tenemies.clear()\n\tspawn_enemy("peasant", player["pos"] + Vector2(72.0, 0.0))\n\tapply_enemy_status(0, "burn", 3.0, 1.2, 1)\n\tapply_enemy_status(0, "poison", 3.0, 1.2, 1)\n\tvar reaction_statuses: Dictionary = enemies[0].get("status_effects", {}) as Dictionary\n\tif not reaction_statuses.has("toxic_blaze"):\n\t\tself_test_fail("Alpha.54 劇毒灼燒未觸發")\n\t\treturn\n\tapply_enemy_status(0, "slow", 2.0, 0.25, 1)\n\tapply_enemy_status(0, "slow", 2.0, 0.25, 1)\n\tapply_enemy_status(0, "slow", 2.0, 0.25, 1)\n\treaction_statuses = enemies[0].get("status_effects", {}) as Dictionary\n\tif not reaction_statuses.has("stun"):\n\t\tself_test_fail("Alpha.54 冰封聯動未觸發")\n\t\treturn\n'''
if "Alpha.54：異常聯動回歸" not in main:
    marker = '\thit_stop_timer = 0.0\n\thit_stop_cooldown = 0.0\n'
    if marker not in main:
        raise SystemExit("Alpha54 migration could not find self-test insertion point")
    main = main.replace(marker, self_test_block + marker, 1)

write("scripts/main.gd", main)

# StatusEffectService: register Shock + reaction display and hook the synergy service.
status = read("scripts/systems/combat/status_effect_service.gd")
status = replace_once(
    status,
    "extends RefCounted\n\n",
    'extends RefCounted\n\nconst ElementalSynergyService = preload("res://scripts/systems/combat/elemental_synergy_service.gd")\n\n',
    "status synergy preload",
)
status = status.replace(
    'const EFFECT_ORDER: Array[String] = ["burn", "poison", "slow", "stun", "confuse", "charm", "armor_break"]',
    'const EFFECT_ORDER: Array[String] = ["toxic_blaze", "burn", "poison", "shock", "slow", "stun", "confuse", "charm", "armor_break"]',
)
status = replace_once(status, '"burn":"燃燒",\n', '"toxic_blaze":"劇毒灼燒",\n\t"burn":"燃燒",\n', "reaction display name")
status = replace_once(status, '"poison":"中毒",\n', '"poison":"中毒",\n\t"shock":"感電",\n', "shock display name")
status = replace_once(status, '"burn": Color8(242, 126, 62),\n', '"toxic_blaze": Color8(227, 105, 91),\n\t"burn": Color8(242, 126, 62),\n', "reaction color")
status = replace_once(status, '"poison": Color8(116, 205, 103),\n', '"poison": Color8(116, 205, 103),\n\t"shock": Color8(126, 197, 245),\n', "shock color")
status = replace_once(status, '"poison":0.62,\n', '"poison":0.62,\n\t\t"shock":0.48,\n', "boss shock resistance")

if "ElementalSynergyService.on_enemy_status_applied(host, index, key)" not in status:
    old = '\tenemies[index] = enemy\n\thost.set("enemies", enemies)\n\treturn true\n\nstatic func tick_enemy'
    new = '\tenemies[index] = enemy\n\thost.set("enemies", enemies)\n\tElementalSynergyService.on_enemy_status_applied(host, index, key)\n\treturn true\n\nstatic func tick_enemy'
    status = replace_once(status, old, new, "enemy application synergy hook")

if "ElementalSynergyService.tick_enemy(host, live_index, delta)" not in status:
    old = '\t\tif live_index < 0:\n\t\t\treturn -1\n\treturn live_index\n\nstatic func boss_resistance'
    new = '\t\tif live_index < 0:\n\t\t\treturn -1\n\treturn ElementalSynergyService.tick_enemy(host, live_index, delta)\n\nstatic func boss_resistance'
    status = replace_once(status, old, new, "enemy reaction tick")

if "ElementalSynergyService.on_boss_status_applied(host, key)" not in status:
    old = '\tboss["status_effects"] = statuses\n\thost.set("boss", boss)\n\treturn true\n\nstatic func tick_boss'
    new = '\tboss["status_effects"] = statuses\n\thost.set("boss", boss)\n\tElementalSynergyService.on_boss_status_applied(host, key)\n\treturn true\n\nstatic func tick_boss'
    status = replace_once(status, old, new, "boss application synergy hook")

if "ElementalSynergyService.tick_boss(host, delta)" not in status:
    old = '\t\tif host.has_method("damage_boss") and not (host.get("boss") as Dictionary).is_empty():\n\t\t\thost.call("damage_boss", float(hit.get("damage", 0.0)), str(hit.get("source", "status")), false)\n\nstatic func boss_stunned'
    new = '\t\tif host.has_method("damage_boss") and not (host.get("boss") as Dictionary).is_empty():\n\t\t\thost.call("damage_boss", float(hit.get("damage", 0.0)), str(hit.get("source", "status")), false)\n\tElementalSynergyService.tick_boss(host, delta)\n\nstatic func boss_stunned'
    status = replace_once(status, old, new, "boss reaction tick")

write("scripts/systems/combat/status_effect_service.gd", status)

# Boss HUD: show resistance info under active status summary.
hud = read("scripts/systems/hero/alpha36_37_roster_progression_hud.gd")
hud = replace_once(
    hud,
    'const StatusEffectService = preload("res://scripts/systems/combat/status_effect_service.gd")\n',
    'const StatusEffectService = preload("res://scripts/systems/combat/status_effect_service.gd")\nconst ElementalSynergyService = preload("res://scripts/systems/combat/elemental_synergy_service.gd")\n',
    "HUD synergy preload",
)
if "boss_resistance_text" not in hud:
    old = '\t\tif boss_status_text != "":\n\t\t\thost.draw_text(boss_status_text, Vector2(350, 137), 11, Color8(226, 198, 153), true, HORIZONTAL_ALIGNMENT_LEFT, 580)\n'
    new = old + '\t\tvar boss_resist_text: String = ElementalSynergyService.boss_resistance_text(str(host.boss.get("id", "")))\n\t\thost.draw_text(boss_resist_text, Vector2(350, 151), 10, Color8(171, 188, 194), false, HORIZONTAL_ALIGNMENT_LEFT, 580)\n'
    hud = replace_once(hud, old, new, "boss resistance HUD")
write("scripts/systems/hero/alpha36_37_roster_progression_hud.gd", hud)

print("Alpha.54 elemental synergy migration applied")
