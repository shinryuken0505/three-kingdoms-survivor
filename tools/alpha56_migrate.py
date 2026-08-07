from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def write(path: str, text: str) -> None:
    (ROOT / path).write_text(text, encoding="utf-8")


def replace_once(text: str, old: str, new: str, label: str) -> str:
    if new in text:
        return text
    if old not in text:
        raise SystemExit(f"Alpha56 migration could not find {label}")
    return text.replace(old, new, 1)


# Version synchronization.
for path in ["project.godot", "scripts/main.gd", "scripts/core/alpha48_runtime_coordinator.gd"]:
    text = read(path).replace("V2.0.0-alpha.55", "V2.0.0-alpha.56")
    write(path, text)

# Main runtime consumes hero elemental metadata and routing.
main = read("scripts/main.gd")
main = replace_once(
    main,
    'const RelicStatusSynergyService = preload("res://scripts/systems/relic/relic_status_synergy_service.gd")\n',
    'const RelicStatusSynergyService = preload("res://scripts/systems/relic/relic_status_synergy_service.gd")\nconst HeroElementalBuildService = preload("res://scripts/systems/hero/hero_elemental_build_service.gd")\n',
    "hero elemental preload",
)
main = replace_once(
    main,
    '\theroes = GameData.heroes()\n',
    '\theroes = HeroElementalBuildService.install_runtime_tags(GameData.heroes())\n',
    "runtime hero tags",
)
main = main.replace(
    'RelicStatusSynergyService.apply_named_hero_status(self, "enemy", index, source)',
    'HeroElementalBuildService.apply_named_hero_status(self, "enemy", index, source)'
)
main = main.replace(
    'RelicStatusSynergyService.apply_named_hero_status(self, "boss", -1, source)',
    'HeroElementalBuildService.apply_named_hero_status(self, "boss", -1, source)'
)
write("scripts/main.gd", main)

# Registry becomes the discoverable metadata source for build-aware systems.
registry = read("scripts/systems/hero/hero_content_registry.gd")
profiles = {
    "zhouyu": ('"element":"fire","status_tags":["burn"],"synergy_tags":["area","reaction"],'),
    "zhangjiao": ('"element":"lightning","status_tags":["shock"],"synergy_tags":["chain","reaction"],'),
    "zhenji": ('"element":"frost","status_tags":["slow","stun"],"synergy_tags":["freeze","control"],'),
    "sunshangxiang": ('"element":"fire","status_tags":["burn"],"synergy_tags":["ranged","multihit"],'),
    "huatuo": ('"element":"support","status_tags":["cleanse","heal"],"synergy_tags":["recovery","shield"],'),
    "zhugeliang": ('"element":"strategy","status_tags":["slow","stun"],"synergy_tags":["control","reaction_support"],'),
    "diaochan": ('"element":"control","status_tags":["charm","confuse"],"synergy_tags":["control","debuff"],'),
}
for hero_id, insertion in profiles.items():
    line_prefix = f'\t"{hero_id}": {{'
    for line in registry.splitlines():
        if line.startswith(line_prefix):
            if '"element":' not in line:
                updated = line.replace('"portrait":', insertion + '"portrait":', 1)
                registry = registry.replace(line, updated, 1)
            break
    else:
        raise SystemExit(f"Alpha56 registry hero missing: {hero_id}")
write("scripts/systems/hero/hero_content_registry.gd", registry)

# Skill handler registry includes Zhou Yu's elemental evolution handler.
handler = read("scripts/systems/hero/hero_skill_handler_registry.gd")
handler = replace_once(
    handler,
    '\t"bow_waist_volley":"sunshangxiang",\n',
    '\t"bow_waist_volley":"sunshangxiang",\n\t"red_cliff_flame":"zhouyu",\n',
    "zhouyu handler",
)
write("scripts/systems/hero/hero_skill_handler_registry.gd", handler)

# Alpha40 control evolves through the unified StatusEffectService wrapper.
evo = read("scripts/systems/hero/alpha40_hero_skill_evolution_runtime.gd")
evo = replace_once(
    evo,
    'const HeroSkillHandlerRegistry = preload("res://scripts/systems/hero/hero_skill_handler_registry.gd")\n',
    'const HeroSkillHandlerRegistry = preload("res://scripts/systems/hero/hero_skill_handler_registry.gd")\nconst HeroElementalBuildService = preload("res://scripts/systems/hero/hero_elemental_build_service.gd")\n',
    "alpha40 hero elemental preload",
)
evo = replace_once(
    evo,
    '\t\t"sunshangxiang": evolve_sun_shang_xiang(hero_id, level)\n',
    '\t\t"sunshangxiang": evolve_sun_shang_xiang(hero_id, level)\n\t\t"zhouyu": evolve_zhou_yu(hero_id, level)\n',
    "zhouyu evolution dispatch",
)
if "func evolve_zhou_yu" not in evo:
    marker = 'func evolve_diao_chan(hero_id: String, level: int) -> void:\n'
    zhouyu = '''func evolve_zhou_yu(hero_id: String, level: int) -> void:\n\tvar radius: float = 158.0 + float(level) * 12.0\n\tapply_area_damage(radius, 12.0 + float(level) * 4.2, 0.0)\n\tapply_control(radius, 2.8 + float(level) * 0.15, "burn")\n\tif level >= LEVEL_5:\n\t\tapply_control(radius + 42.0, 2.4, "burn")\n\tif level >= LEVEL_8:\n\t\tapply_control(radius, 2.2, "armor_break")\n\tadd_ring(player_position(), radius, Color(1.0, 0.38, 0.16, 0.78))\n\tshow_evolution(hero_id, level, "赤壁燎原" if level >= LEVEL_8 else "烈焰擴張")\n\n'''
    if marker not in evo:
        raise SystemExit("Alpha56 could not insert Zhou Yu evolution")
    evo = evo.replace(marker, zhouyu + marker, 1)

# Hua Tuo now cleanses debuffs when his evolution effect fires.
old_heal = '\tif level >= LEVEL_8:\n\t\tplayer["alpha40_damage_reduction"] = 0.18\n\t\tplayer["alpha40_damage_reduction_time"] = 3.0\n\thost.set("player", player)\n'
new_heal = '\tif level >= LEVEL_8:\n\t\tplayer["alpha40_damage_reduction"] = 0.18\n\t\tplayer["alpha40_damage_reduction_time"] = 3.0\n\thost.set("player", player)\n\tHeroElementalBuildService.cleanse_player(host, level)\n'
evo = replace_once(evo, old_heal, new_heal, "Hua Tuo cleanse")

start = evo.find('func apply_control(radius: float, duration: float, kind: String) -> void:\n')
end = evo.find('\nfunc show_evolution', start)
if start < 0 or end < 0:
    raise SystemExit("Alpha56 could not find apply_control")
new_control = '''func apply_control(radius: float, duration: float, kind: String) -> void:\n\tvar enemies: Array = host.get("enemies") as Array\n\tvar center: Vector2 = player_position()\n\tfor index in range(enemies.size()):\n\t\tvar enemy: Dictionary = enemies[index] as Dictionary\n\t\tif enemy_position(enemy).distance_to(center) > radius:\n\t\t\tcontinue\n\t\tif host.has_method("apply_enemy_status"):\n\t\t\tvar potency: float = 1.0\n\t\t\tif kind == "slow": potency = 0.30\n\t\t\telif kind == "burn": potency = 0.90\n\t\t\telif kind == "armor_break": potency = 0.16\n\t\t\thost.call("apply_enemy_status", index, kind, duration, potency, 1)\n\n'''
evo = evo[:start] + new_control + evo[end+1:]
write("scripts/systems/hero/alpha40_hero_skill_evolution_runtime.gd", evo)

print("Alpha.56 elemental hero build migration applied")
