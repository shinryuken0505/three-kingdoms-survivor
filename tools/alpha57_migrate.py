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
        raise SystemExit(f"Alpha57 migration could not find {label}")
    return text.replace(old, new, 1)


# Version synchronization.
for path in ["project.godot", "scripts/main.gd", "scripts/core/alpha48_runtime_coordinator.gd"]:
    text = read(path).replace("V2.0.0-alpha.56", "V2.0.0-alpha.57")
    write(path, text)

# Zhang Jiao becomes a complete runtime hero, not only a pool/bond ID.
game_data = read("scripts/game_data.gd")
heroes_start = game_data.find("static func heroes() -> Dictionary:")
if heroes_start < 0:
    raise SystemExit("Alpha57 could not find GameData heroes()")
hero_block_end = game_data.find("\n\nstatic func ", heroes_start + 1)
if hero_block_end < 0:
    hero_block_end = len(game_data)
hero_block = game_data[heroes_start:hero_block_end]
if '\n\t\t"zhangjiao":\n\t\t{' not in hero_block:
    marker = '\n\t\t"huatuo":\n\t\t{'
    entry = '''
		"zhangjiao":
		{
			"balance_tier": "A",
			"combat_role": "elemental",
			"cooldown_mult": 0.94,
			"identity": "太平雷法：感電、雷鏈與異常傳播。",
			"legendary": "黃天雷動：羈絆Lv5時雷擊額外連鎖並延長感電。",
			"name": "張角",
			"title": "天公將軍",
			"shout": "蒼天已死，黃天當立！",
			"faction": "群",
			"portrait": "res://assets/portraits/zhangjiao_default.png",
			"sprite": "res://assets/sprites/zhangjiao_default.png",
			"cooldown": 11.8,
			"color": Color8(196, 165, 76),
			"active": "太平雷法：召下雷霆打擊敵群，附加感電並向附近敵人連鎖。",
			"passive": "黃天餘勢：後備時強化感電與異常傳播的持續壓力。",
			"signal": "黃巾符紙、雷痕與低沉誦咒聲。"
		},
'''
    absolute_marker = game_data.find(marker, heroes_start, hero_block_end)
    if absolute_marker < 0:
        raise SystemExit("Alpha57 could not insert Zhang Jiao into GameData")
    game_data = game_data[:absolute_marker] + "\n" + entry + game_data[absolute_marker:]
write("scripts/game_data.gd", game_data)

# Canonical registry entry uses verified default portrait/sprite assets.
registry = read("scripts/systems/hero/hero_content_registry.gd")
if '\t"zhangjiao": {' not in registry:
    marker = '\t"huatuo": {'
    entry = '\t"zhangjiao": {"id":"zhangjiao","name":"張角","faction":"other","active_skill":"great_peace_thunder","reserve_passive":"strategy_support","growth_profile":"strategist","element":"lightning","status_tags":["shock"],"synergy_tags":["chain","reaction"],"portrait":"res://assets/portraits/zhangjiao_default.png","sprite":"res://assets/sprites/zhangjiao_default.png"},\n'
    registry = replace_once(registry, marker, entry + marker, "Zhang Jiao registry entry")
if '"zhang_jiao":"zhangjiao"' not in registry:
    registry = replace_once(
        registry,
        '"liu_bei":"liubei", "guan_yu":"guanyu", "zhang_fei":"zhangfei",',
        '"liu_bei":"liubei", "guan_yu":"guanyu", "zhang_fei":"zhangfei", "zhang_jiao":"zhangjiao",',
        "Zhang Jiao registry alias",
    )
write("scripts/systems/hero/hero_content_registry.gd", registry)

# Recruitment uses mild build affinity on top of existing history/branch weights.
main = read("scripts/main.gd")
main = replace_once(
    main,
    'const HeroElementalBuildService = preload("res://scripts/systems/hero/hero_elemental_build_service.gd")\n',
    'const HeroElementalBuildService = preload("res://scripts/systems/hero/hero_elemental_build_service.gd")\nconst HeroRecruitmentAffinityService = preload("res://scripts/systems/hero/hero_recruitment_affinity_service.gd")\n',
    "recruitment affinity preload",
)
main = replace_once(
    main,
    '\t\tfor i in range(legendary_hero_weight(hid)):\n\t\t\tweighted.append(hid)\n',
    '\t\tvar recruit_weight: int = HeroRecruitmentAffinityService.adjusted_weight(self, hid, legendary_hero_weight(hid))\n\t\tfor i in range(recruit_weight):\n\t\t\tweighted.append(hid)\n',
    "weighted recruitment hook",
)

# Candidate cards expose readable tactical identity, never numeric hidden weights.
main = replace_once(
    main,
    '\t\tvar rect := Rect2(start_x + i * (card_w + gap), 165, card_w, 330)\n',
    '\t\tvar rect := Rect2(start_x + i * (card_w + gap), 165, card_w, 350)\n',
    "candidate card height",
)
main = replace_once(
    main,
    '\t\tdraw_remaster_portrait(hid, Rect2(rect.position + Vector2(16, 14), Vector2(rect.size.x - 32, 190)), 0.52)\n\t\tdraw_centered_text(str(heroes[hid]["name"]), rect, 235.0, 26, heroes[hid]["color"], true)\n\t\tdraw_centered_text(str(heroes[hid]["title"]), rect, 264.0, 14, Color8(222, 211, 178))\n\t\tdraw_wrapped("主動：%s\\n後備：%s" % [heroes[hid]["active"], heroes[hid]["passive"]], Rect2(rect.position + Vector2(16, 278), Vector2(rect.size.x - 32, 40)), 11, Color8(205, 211, 202), 17.0)\n',
    '\t\tdraw_remaster_portrait(hid, Rect2(rect.position + Vector2(16, 14), Vector2(rect.size.x - 32, 170)), 0.52)\n\t\tdraw_centered_text(str(heroes[hid]["name"]), rect, 214.0, 25, heroes[hid]["color"], true)\n\t\tdraw_centered_text(str(heroes[hid]["title"]), rect, 242.0, 14, Color8(222, 211, 178))\n\t\tvar tactical_tag: String = HeroRecruitmentAffinityService.element_label(hid)\n\t\tvar affinity_hint: String = HeroRecruitmentAffinityService.affinity_hint(self, hid)\n\t\tvar synergy_hint: String = HeroRecruitmentAffinityService.synergy_description(hid)\n\t\tdraw_centered_text(tactical_tag, rect, 263.0, 12, Color8(196, 207, 191), true)\n\t\tif affinity_hint != "":\n\t\t\tdraw_centered_text(affinity_hint, rect, 282.0, 11, Color8(238, 199, 112), true)\n\t\telif synergy_hint != "":\n\t\t\tdraw_centered_text(synergy_hint, rect, 282.0, 10, Color8(166, 190, 177))\n\t\tdraw_wrapped("主動：%s\\n後備：%s" % [heroes[hid]["active"], heroes[hid]["passive"]], Rect2(rect.position + Vector2(16, 300), Vector2(rect.size.x - 32, 42)), 10, Color8(205, 211, 202), 15.0)\n',
    "candidate tactical metadata",
)
write("scripts/main.gd", main)

print("Alpha.57 build-aware recruitment migration applied")
