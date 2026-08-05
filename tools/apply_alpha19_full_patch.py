from __future__ import annotations

from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def write(path: str, content: str) -> None:
    target = ROOT / path
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(content, encoding="utf-8")


def patch_main() -> None:
    path = ROOT / "scripts/main.gd"
    text = path.read_text(encoding="utf-8")
    text = text.replace('const GAME_VERSION: String = "V2.0.0-alpha.17"', 'const GAME_VERSION: String = "V2.0.0-alpha.19"')

    preload_anchor = 'const HeroProgressionRules = preload("res://scripts/systems/hero/hero_progression_rules.gd")\n'
    preload_block = preload_anchor + (
        'const Alpha19BuildRules = preload("res://scripts/systems/build/alpha19_build_rules.gd")\n'
        'const Alpha19HeroMastery = preload("res://scripts/systems/hero/alpha19_hero_mastery.gd")\n'
        'const Alpha19HistoryInfluence = preload("res://scripts/systems/world/alpha19_history_influence.gd")\n'
        'const Alpha19ChapterGimmicks = preload("res://scripts/systems/chapter/alpha19_chapter_gimmicks.gd")\n'
    )
    if 'Alpha19BuildRules' not in text:
        text = text.replace(preload_anchor, preload_block, 1)

    var_anchor = 'var ending_committed: bool = false\n'
    var_block = var_anchor + (
        'var alpha19_build_state: Dictionary = {}\n'
        'var alpha19_mastery_state: Dictionary = {}\n'
        'var alpha19_history_state: Dictionary = {}\n'
        'var alpha19_chapter_state: Dictionary = {}\n'
        'var alpha19_refresh_timer: float = 0.0\n'
    )
    if 'var alpha19_build_state' not in text:
        text = text.replace(var_anchor, var_block, 1)

    if 'alpha19_update(delta)' not in text:
        text = re.sub(
            r'(func _process\(delta: float\) -> void:\n)',
            r'\1\talpha19_update(delta)\n',
            text,
            count=1,
        )

    if 'alpha19_initialize_run()' not in text:
        text = text.replace(
            '\tgenerate_world()\n\thero_spawn_timer = 20.0 if mode == "story" else 12.0',
            '\talpha19_initialize_run()\n\tgenerate_world()\n\thero_spawn_timer = 20.0 if mode == "story" else 12.0',
            1,
        )

    if 'alpha19_apply_chapter_setup()' not in text:
        marker = '\tupdate_bonds()\n\tgenerate_world()\n\n\nfunc begin_next_chapter()'
        replacement = '\tupdate_bonds()\n\talpha19_apply_chapter_setup()\n\tgenerate_world()\n\n\nfunc begin_next_chapter()'
        text = text.replace(marker, replacement, 1)

    damage_old = 'var dmg: float = float(player["damage"]) * (1.0 + skill_level("damage") * 0.15) * (1.0 + relic_stat("damage_bonus"))'
    damage_new = 'var dmg: float = float(player["damage"]) * float(player.get("alpha19_damage_mult", 1.0)) * (1.0 + skill_level("damage") * 0.15) * (1.0 + relic_stat("damage_bonus"))'
    text = text.replace(damage_old, damage_new)

    if 'alpha19_filter_level_choices()' not in text:
        text = text.replace('\tscreen = "levelup"\n', '\talpha19_filter_level_choices()\n\tscreen = "levelup"\n', 1)

    if 'func alpha19_initialize_run()' not in text:
        text += r'''

# Alpha.19: Build、名將大成、史勢與章節特色整合層。
func alpha19_initialize_run() -> void:
	alpha19_build_state = Alpha19BuildRules.evaluate(chosen_identity, str(player.get("weapon", "blade")), skill_levels, relics)
	alpha19_mastery_state.clear()
	alpha19_history_state = Alpha19HistoryInfluence.evaluate(history_flags, history_route_tags, faction_momentum, history_rewrite_rate)
	alpha19_chapter_state = Alpha19ChapterGimmicks.for_chapter(str(current_chapter().get("id", "")))
	alpha19_refresh_timer = 0.0
	player["alpha19_damage_mult"] = 1.0
	alpha19_refresh_progression()


func alpha19_update(delta: float) -> void:
	if player.is_empty() or screen not in ["game", "shop", "tab", "hero_config", "camp_menu"]:
		return
	alpha19_refresh_timer -= delta
	if alpha19_refresh_timer > 0.0:
		return
	alpha19_refresh_timer = 0.35
	alpha19_refresh_progression()


func alpha19_refresh_progression() -> void:
	alpha19_build_state = Alpha19BuildRules.evaluate(chosen_identity, str(player.get("weapon", "blade")), skill_levels, relics)
	alpha19_mastery_state = Alpha19HeroMastery.evaluate(active_heroes, reserve_heroes, hero_bond_levels)
	alpha19_history_state = Alpha19HistoryInfluence.evaluate(history_flags, history_route_tags, faction_momentum, history_rewrite_rate)
	var build_damage: float = float(alpha19_build_state.get("damage_mult", 1.0))
	var mastery_damage: float = float(alpha19_mastery_state.get("damage_mult", 1.0))
	var history_damage: float = float(alpha19_history_state.get("damage_mult", 1.0))
	player["alpha19_damage_mult"] = build_damage * mastery_damage * history_damage
	player["hero_cd_mult"] = clamp(
		float(alpha19_build_state.get("hero_cd_mult", 1.0))
		* float(alpha19_mastery_state.get("hero_cd_mult", 1.0)),
		0.55,
		1.0
	)
	player["control_resist"] = max(float(player.get("control_resist", 0.0)), float(alpha19_mastery_state.get("control_resist", 0.0)))


func alpha19_filter_level_choices() -> void:
	if level_choices.is_empty():
		return
	var filtered: Array = []
	for choice_value in level_choices:
		var choice: Dictionary = choice_value
		var skill_id: String = str(choice.get("id", choice.get("skill", "")))
		if Alpha19BuildRules.skill_allowed(str(player.get("weapon", "blade")), skill_id, skill_levels):
			filtered.append(choice)
	if filtered.size() >= 2:
		level_choices = filtered
	option_index = clampi(option_index, 0, max(0, level_choices.size() - 1))


func alpha19_apply_chapter_setup() -> void:
	alpha19_history_state = Alpha19HistoryInfluence.evaluate(history_flags, history_route_tags, faction_momentum, history_rewrite_rate)
	alpha19_chapter_state = Alpha19ChapterGimmicks.for_chapter(str(current_chapter().get("id", "")))
	merchant_spawn_timer *= float(alpha19_chapter_state.get("merchant_time_mult", 1.0))
	hero_spawn_timer *= float(alpha19_chapter_state.get("hero_time_mult", 1.0))
	var history_merchant: float = float(alpha19_history_state.get("merchant_time_mult", 1.0))
	merchant_spawn_timer *= history_merchant
	var label: String = str(alpha19_chapter_state.get("label", ""))
	if label != "":
		show_message("章節機制｜%s" % label, 3.2)


func alpha19_build_summary() -> String:
	return "%s・%s" % [
		str(alpha19_build_state.get("name", "未定流派")),
		str(alpha19_build_state.get("stage_name", "起步"))
	]
'''

    path.write_text(text, encoding="utf-8")


def create_modules() -> None:
    write("scripts/systems/build/alpha19_build_rules.gd", r'''class_name Alpha19BuildRules
extends RefCounted

const ARCHETYPES := {
	"melee": {"name":"無雙近戰", "skills":["damage","attack_speed","armor","dash","range"], "weapons":["blade"]},
	"ranged": {"name":"百步弓道", "skills":["projectile","multishot","pierce","crit","attack_speed"], "weapons":["bow","rings"]},
	"poison": {"name":"百毒奇術", "skills":["poison","projectile","multishot","damage"], "weapons":["poison"]},
	"fire": {"name":"烈焰軍略", "skills":["fire","element","zone","hero_cd"], "weapons":[]},
	"summon": {"name":"名將號令", "skills":["hero_cd","hero_damage","bond","summon"], "weapons":[]},
}

static func evaluate(identity_id: String, weapon: String, skill_levels: Dictionary, relics: Array) -> Dictionary:
	var scores: Dictionary = {"melee":0, "ranged":0, "poison":0, "fire":0, "summon":0}
	for archetype in ARCHETYPES:
		var data: Dictionary = ARCHETYPES[archetype]
		if weapon in data.get("weapons", []):
			scores[archetype] = int(scores[archetype]) + 3
		for skill_id in data.get("skills", []):
			scores[archetype] = int(scores[archetype]) + int(skill_levels.get(skill_id, 0))
	if identity_id == "hunter": scores["ranged"] += 2
	elif identity_id == "poisoner": scores["poison"] += 2
	elif identity_id == "swordsman": scores["melee"] += 2
	elif identity_id == "heroine": scores["summon"] += 1
	for relic_id in relics:
		var rid := str(relic_id)
		if rid in ["crossbow", "arrowhead", "redhare"]: scores["ranged"] += 1
		elif rid in ["yellowwater", "poisonmanual"]: scores["poison"] += 1
		elif rid in ["formationseal", "artofwar", "moonbell"]: scores["summon"] += 1
	var primary := "melee"
	for key in scores:
		if int(scores[key]) > int(scores[primary]): primary = key
	var score := int(scores[primary])
	var stage := clampi(1 + score / 4, 1, 5)
	return {
		"id": primary,
		"name": str(ARCHETYPES[primary]["name"]),
		"score": score,
		"stage": stage,
		"stage_name": ["","成形","精進","共鳴","宗師","大成"][stage],
		"damage_mult": 1.0 + float(stage - 1) * 0.065,
		"hero_cd_mult": 1.0 - (0.035 * float(stage - 1) if primary == "summon" else 0.0),
	}

static func skill_allowed(weapon: String, skill_id: String, skill_levels: Dictionary) -> bool:
	if skill_id == "" or int(skill_levels.get(skill_id, 0)) > 0:
		return true
	if weapon == "blade" and skill_id in ["poison", "multishot", "pierce"]:
		return false
	if weapon == "poison" and skill_id in ["range", "armor"]:
		return false
	if weapon in ["bow", "rings"] and skill_id == "poison":
		return false
	return true
''')

    write("scripts/systems/hero/alpha19_hero_mastery.gd", r'''class_name Alpha19HeroMastery
extends RefCounted

const SIGNATURES := {
	"huangzhong":{"lv4":"強弓：暴擊與投射傷害提高。","lv5":"神射：Boss承受的遠程傷害提高。","damage":0.10},
	"zhaoyun":{"lv4":"龍膽：低生命時提高減傷。","lv5":"七進七出：施放後短暫霸體。","resist":0.18},
	"zhugeliang":{"lv4":"借勢：名將冷卻縮短。","lv5":"八陣大成：控場持續時間提高。","cooldown":0.08},
	"guanyu":{"lv4":"武聖：近戰範圍提高。","lv5":"青龍偃月：斬擊可再度爆發。","damage":0.09},
	"zhangfei":{"lv4":"燕人怒吼：震波範圍提高。","lv5":"當陽斷喝：Boss亦會被短暫壓制。","damage":0.08},
	"huatuo":{"lv4":"青囊：治療溢出轉為護盾。","lv5":"懸壺濟世：致命傷保命一次。","resist":0.12},
	"zhouyu":{"lv4":"火勢：燃燒區域擴張。","lv5":"東風：火焰連鎖增傷。","damage":0.10},
	"simayi":{"lv4":"忍勢：保留銅錢提高技能循環。","lv5":"冢虎：延遲技能傷害提高。","cooldown":0.07},
}

static func evaluate(active: Array, reserve: Array, bond_levels: Dictionary) -> Dictionary:
	var damage_mult := 1.0
	var hero_cd_mult := 1.0
	var control_resist := 0.0
	var awakened: Array[String] = []
	for hero_value in active:
		var hero_id := str(hero_value)
		var level := int(bond_levels.get(hero_id, 1))
		if level >= 4:
			damage_mult += 0.025
			hero_cd_mult -= 0.018
		if level >= 5:
			awakened.append(hero_id)
			var sig: Dictionary = SIGNATURES.get(hero_id, {})
			damage_mult += float(sig.get("damage", 0.04))
			hero_cd_mult -= float(sig.get("cooldown", 0.02))
			control_resist += float(sig.get("resist", 0.0))
	for hero_value in reserve:
		if int(bond_levels.get(str(hero_value), 1)) >= 5:
			damage_mult += 0.012
	return {
		"damage_mult": min(1.65, damage_mult),
		"hero_cd_mult": max(0.68, hero_cd_mult),
		"control_resist": min(0.45, control_resist),
		"awakened": awakened,
	}

static func description(hero_id: String, level: int) -> String:
	var sig: Dictionary = SIGNATURES.get(hero_id, {})
	if level >= 5: return str(sig.get("lv5", "大成：專屬能力全面強化。"))
	if level >= 4: return str(sig.get("lv4", "覺醒：專屬能力獲得強化。"))
	return "羈絆尚未覺醒。"
''')

    write("scripts/systems/world/alpha19_history_influence.gd", r'''class_name Alpha19HistoryInfluence
extends RefCounted

static func evaluate(flags: Dictionary, route_tags: Dictionary, momentum: Dictionary, rewrite_rate: float) -> Dictionary:
	var damage_mult := 1.0
	var merchant_time_mult := 1.0
	var reinforcement := "中立"
	if bool(flags.get("protected_civilians", false)) or bool(route_tags.get("benevolent", false)):
		merchant_time_mult *= 0.90
		reinforcement = "民心援助"
	if bool(flags.get("accepted_ruthless_plan", false)) or bool(route_tags.get("ambition", false)):
		damage_mult *= 1.06
		reinforcement = "奇兵突擊"
	var best_faction := ""
	var best_value := -999.0
	for faction in momentum:
		if float(momentum[faction]) > best_value:
			best_value = float(momentum[faction])
			best_faction = str(faction)
	if best_value >= 3.0:
		damage_mult *= 1.025
		reinforcement = "%s援軍" % best_faction
	return {
		"damage_mult": damage_mult * (1.0 + clamp(rewrite_rate, 0.0, 1.0) * 0.04),
		"merchant_time_mult": merchant_time_mult,
		"reinforcement": reinforcement,
		"dominant_faction": best_faction,
	}
''')

    write("scripts/systems/chapter/alpha19_chapter_gimmicks.gd", r'''class_name Alpha19ChapterGimmicks
extends RefCounted

const GIMMICKS := {
	"yellow_turban_zhuo":{"label":"民兵浪潮・黃巾符水", "merchant_time_mult":0.95, "hero_time_mult":0.92},
	"luoyang_turmoil":{"label":"烽火封路・百姓撤離", "merchant_time_mult":1.05, "hero_time_mult":0.96},
	"hulao_coalition":{"label":"虎牢軍陣・飛將追擊", "merchant_time_mult":1.08, "hero_time_mult":1.00},
	"xuzhou_flames":{"label":"糧道危機・陷陣衝鋒", "merchant_time_mult":0.96, "hero_time_mult":1.02},
	"guandu_showdown":{"label":"官渡糧秣・車陣壓境", "merchant_time_mult":1.12, "hero_time_mult":0.98},
	"jingzhou_retreat":{"label":"水網撤軍・百姓護送", "merchant_time_mult":0.94, "hero_time_mult":0.90},
	"chibi_battle":{"label":"東風火線・戰船連鎖", "merchant_time_mult":1.04, "hero_time_mult":0.94},
	"jingzhou_campaign":{"label":"城寨箭雨・老將試煉", "merchant_time_mult":1.06, "hero_time_mult":0.96},
	"hanzhong_campaign":{"label":"山道糧線・神速突襲", "merchant_time_mult":1.10, "hero_time_mult":0.98},
	"yiling_battle":{"label":"連營烈火・風向變化", "merchant_time_mult":1.08, "hero_time_mult":1.00},
	"wuzhang_plains":{"label":"星落五丈・深陣消耗", "merchant_time_mult":1.12, "hero_time_mult":1.04},
}

static func for_chapter(chapter_id: String) -> Dictionary:
	return (GIMMICKS.get(chapter_id, {"label":"亂世變局", "merchant_time_mult":1.0, "hero_time_mult":1.0}) as Dictionary).duplicate(true)
''')


def create_tests() -> None:
    write("tests/alpha19_rules_test.gd", r'''extends SceneTree

const BuildRules = preload("res://scripts/systems/build/alpha19_build_rules.gd")
const HeroMastery = preload("res://scripts/systems/hero/alpha19_hero_mastery.gd")
const HistoryInfluence = preload("res://scripts/systems/world/alpha19_history_influence.gd")
const ChapterGimmicks = preload("res://scripts/systems/chapter/alpha19_chapter_gimmicks.gd")

func _init() -> void:
	var failures: Array[String] = []
	var melee := BuildRules.evaluate("swordsman", "blade", {"damage":3,"armor":2}, [])
	if str(melee.get("id", "")) != "melee": failures.append("blade build did not resolve to melee")
	if BuildRules.skill_allowed("blade", "poison", {}): failures.append("blade incorrectly allowed new poison branch")
	var mastery := HeroMastery.evaluate(["huangzhong","zhugeliang"], [], {"huangzhong":5,"zhugeliang":4})
	if float(mastery.get("damage_mult", 1.0)) <= 1.0: failures.append("mastery damage bonus missing")
	if not (mastery.get("awakened", []) as Array).has("huangzhong"): failures.append("level 5 awakening missing")
	var history := HistoryInfluence.evaluate({"protected_civilians":true}, {}, {"蜀":4.0}, 0.3)
	if float(history.get("merchant_time_mult", 1.0)) >= 1.0: failures.append("benevolent merchant support missing")
	var gimmick := ChapterGimmicks.for_chapter("yiling_battle")
	if not str(gimmick.get("label", "")).contains("烈火"): failures.append("Yiling gimmick missing")
	if failures.is_empty():
		print("ALPHA19_RULES_TEST_OK")
		quit(0)
	else:
		for failure in failures: push_error(failure)
		quit(1)
''')

    write("tools/check_alpha19_full.py", r'''from pathlib import Path

root = Path(__file__).resolve().parents[1]
main = (root / "scripts/main.gd").read_text(encoding="utf-8")
required = [
    'V2.0.0-alpha.19', 'Alpha19BuildRules', 'Alpha19HeroMastery',
    'Alpha19HistoryInfluence', 'Alpha19ChapterGimmicks',
    'func alpha19_initialize_run()', 'func alpha19_filter_level_choices()',
    'alpha19_damage_mult', 'alpha19_apply_chapter_setup()'
]
for token in required:
    assert token in main, f"missing Alpha.19 integration token: {token}"
for path in [
    "scripts/systems/build/alpha19_build_rules.gd",
    "scripts/systems/hero/alpha19_hero_mastery.gd",
    "scripts/systems/world/alpha19_history_influence.gd",
    "scripts/systems/chapter/alpha19_chapter_gimmicks.gd",
    "tests/alpha19_rules_test.gd",
]:
    assert (root / path).exists(), f"missing {path}"
print("ALPHA19_FULL_STRUCTURE_OK")
''')

    write("docs/ALPHA19_FULL_EDITION.md", r'''# V2.0.0 Alpha.19 — 名將大成與流派分化整版

## 核心內容

- 五大 Build：近戰、弓道、毒術、火計、名將號令。
- 武器初始流派限制：未取得對應能力前，不再出現完全無關的升級方向。
- 羈絆 Lv.4 覺醒、Lv.5 大成；上場與後備名將均提供不同程度的加成。
- 黃忠、趙雲、諸葛亮、關羽、張飛、華佗、周瑜、司馬懿具專屬大成規則。
- 歷史選擇影響傷害、商人出現速度、援軍敘事與勢力傾向。
- 主要章節加入專屬機制標籤及節奏修正。
- 版本升級為 V2.0.0-alpha.19。

## 測試重點

1. 不同初始武器升級選項是否維持合理流派。
2. 名將羈絆 Lv.4／Lv.5 後，傷害與冷卻是否立即更新。
3. 仁德／野心等歷史選擇是否改變行商及援軍效果。
4. 章節開始時是否顯示專屬機制提示。
5. 連續章節、存檔、Ending 與 Alpha.17 既有流程不可退化。
''')


def main() -> None:
    create_modules()
    create_tests()
    patch_main()
    print("Alpha.19 full edition patch applied")


if __name__ == "__main__":
    main()
