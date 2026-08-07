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
        raise SystemExit(f"Alpha55 migration could not find {label}")
    return text.replace(old, new, 1)


# Version synchronization.
project = read("project.godot").replace("V2.0.0-alpha.54", "V2.0.0-alpha.55")
write("project.godot", project)
coordinator = read("scripts/core/alpha48_runtime_coordinator.gd").replace("V2.0.0-alpha.54", "V2.0.0-alpha.55")
write("scripts/core/alpha48_runtime_coordinator.gd", coordinator)

main = read("scripts/main.gd").replace("V2.0.0-alpha.54", "V2.0.0-alpha.55")
main = replace_once(
    main,
    'const ElementalSynergyService = preload("res://scripts/systems/combat/elemental_synergy_service.gd")\n',
    'const ElementalSynergyService = preload("res://scripts/systems/combat/elemental_synergy_service.gd")\nconst RelicStatusSynergyService = preload("res://scripts/systems/relic/relic_status_synergy_service.gd")\n',
    "relic synergy preload",
)
main = replace_once(
    main,
    '\trelic_defs = GameData.relics()\n',
    '\trelic_defs = RelicStatusSynergyService.install_definitions(GameData.relics())\n',
    "relic definition install",
)

# Damage multipliers and named-hero status routing.
if "RelicStatusSynergyService.damage_multiplier(self, e, source)" not in main:
    marker = '\tvar uid: int = int(e.get("uid", -1))\n'
    insert = marker + '\tamount *= RelicStatusSynergyService.damage_multiplier(self, e, source)\n\tRelicStatusSynergyService.apply_named_hero_status(self, "enemy", index, source)\n\te = enemies[index]\n'
    main = replace_once(main, marker, insert, "enemy damage relic hook")

if "RelicStatusSynergyService.damage_multiplier(self, boss, source)" not in main:
    marker = '\tif bool(boss_phase_state.get("transitioning", false)):\n\t\treturn\n'
    insert = marker + '\tamount *= RelicStatusSynergyService.damage_multiplier(self, boss, source)\n\tRelicStatusSynergyService.apply_named_hero_status(self, "boss", -1, source)\n'
    main = replace_once(main, marker, insert, "boss damage relic hook")

# Poison-on-death relic hook uses the pre-removal enemy snapshot.
if "RelicStatusSynergyService.on_enemy_killed(self, e)" not in main:
    marker = '\tvar was_support_boss: bool = bool(e.get("boss_support", false))\n'
    insert = marker + '\tRelicStatusSynergyService.on_enemy_killed(self, e)\n'
    main = replace_once(main, marker, insert, "enemy kill relic hook")

# Runtime tick handles delayed flame detonation safely through damage_enemy().
if "RelicStatusSynergyService.tick_enemy(self, cursor, delta)" not in main:
    old = (
        '\t\tvar status_index: int = StatusEffectService.tick_enemy(self, cursor, delta)\n'
        '\t\tif status_index < 0:\n'
        '\t\t\tcursor -= 1\n'
        '\t\t\tcontinue\n'
        '\t\tcursor = status_index\n'
        '\t\te = enemies[cursor]\n'
    )
    new = (
        '\t\tvar status_index: int = StatusEffectService.tick_enemy(self, cursor, delta)\n'
        '\t\tif status_index < 0:\n'
        '\t\t\tcursor -= 1\n'
        '\t\t\tcontinue\n'
        '\t\tcursor = status_index\n'
        '\t\tvar relic_status_index: int = RelicStatusSynergyService.tick_enemy(self, cursor, delta)\n'
        '\t\tif relic_status_index < 0:\n'
        '\t\t\tcursor -= 1\n'
        '\t\t\tcontinue\n'
        '\t\tcursor = relic_status_index\n'
        '\t\te = enemies[cursor]\n'
    )
    main = replace_once(main, old, new, "enemy relic tick")

write("scripts/main.gd", main)

# Thunder Command extends Alpha.54 chain target count without creating another chain system.
synergy = read("scripts/systems/combat/elemental_synergy_service.gd")
synergy = replace_once(
    synergy,
    'class_name ElementalSynergyService\nextends RefCounted\n',
    'class_name ElementalSynergyService\nextends RefCounted\n\nconst RelicStatusSynergyService = preload("res://scripts/systems/relic/relic_status_synergy_service.gd")\n',
    "elemental relic preload",
)
synergy = replace_once(
    synergy,
    '\tvar hit_count: int = min(2, candidates.size())\n',
    '\tvar chain_limit: int = 2 + RelicStatusSynergyService.shock_chain_bonus(host)\n\tvar hit_count: int = min(chain_limit, candidates.size())\n',
    "thunder command chain bonus",
)
write("scripts/systems/combat/elemental_synergy_service.gd", synergy)

# Direct StatusEffectService users (older hero/runtime code) also reach relic hooks exactly once.
status = read("scripts/systems/combat/status_effect_service.gd")
status = replace_once(
    status,
    'const ElementalSynergyService = preload("res://scripts/systems/combat/elemental_synergy_service.gd")\n',
    'const ElementalSynergyService = preload("res://scripts/systems/combat/elemental_synergy_service.gd")\nconst RelicStatusSynergyService = preload("res://scripts/systems/relic/relic_status_synergy_service.gd")\n',
    "status relic preload",
)
status = replace_once(
    status,
    '\tElementalSynergyService.on_enemy_status_applied(host, index, key)\n\treturn true\n',
    '\tElementalSynergyService.on_enemy_status_applied(host, index, key)\n\tRelicStatusSynergyService.on_enemy_status_applied(host, index, key)\n\treturn true\n',
    "enemy status relic hook",
)
status = replace_once(
    status,
    '\tElementalSynergyService.on_boss_status_applied(host, key)\n\treturn true\n',
    '\tElementalSynergyService.on_boss_status_applied(host, key)\n\tRelicStatusSynergyService.on_boss_status_applied(host, key)\n\treturn true\n',
    "boss status relic hook",
)
write("scripts/systems/combat/status_effect_service.gd", status)

print("Alpha.55 relic/status synergy migration applied")
