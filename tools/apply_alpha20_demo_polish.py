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
    text = text.replace('const GAME_VERSION: String = "V2.0.0-alpha.19"', 'const GAME_VERSION: String = "V2.0.0-alpha.20"')

    preload_anchor = 'const Alpha19ChapterGimmicks = preload("res://scripts/systems/chapter/alpha19_chapter_gimmicks.gd")\n'
    preload_block = preload_anchor + (
        'const Alpha20DemoDirector = preload("res://scripts/systems/demo/alpha20_demo_director.gd")\n'
        'const Alpha20ChallengeTracker = preload("res://scripts/systems/demo/alpha20_challenge_tracker.gd")\n'
        'const Alpha20DemoProfile = preload("res://scripts/systems/demo/alpha20_demo_profile.gd")\n'
    )
    if 'Alpha20DemoDirector' not in text:
        text = text.replace(preload_anchor, preload_block, 1)

    var_anchor = 'var alpha19_refresh_timer: float = 0.0\n'
    var_block = var_anchor + (
        'var alpha20_director_state: Dictionary = {}\n'
        'var alpha20_challenge_state: Dictionary = {}\n'
        'var alpha20_demo_state: Dictionary = {}\n'
        'var alpha20_tick_timer: float = 0.0\n'
        'var alpha20_hazard_timer: float = 0.0\n'
        'var alpha20_last_kills: int = 0\n'
    )
    if 'var alpha20_director_state' not in text:
        text = text.replace(var_anchor, var_block, 1)

    if 'alpha20_update(delta)' not in text:
        text = re.sub(r'(func _process\(delta: float\) -> void:\n)', r'\1\talpha20_update(delta)\n', text, count=1)

    # Initialize after Alpha.19 has established its state.
    init_anchor = '\talpha19_refresh_progression()\n\n\nfunc alpha19_update'
    if 'alpha20_initialize_run()' not in text and init_anchor in text:
        text = text.replace(init_anchor, '\talpha19_refresh_progression()\n\talpha20_initialize_run()\n\n\nfunc alpha19_update', 1)

    # Apply chapter profile after Alpha.19 chapter setup.
    chapter_anchor = '\tif label != "":\n\t\tshow_message("章節機制｜%s" % label, 3.2)\n'
    if 'alpha20_prepare_chapter()' not in text and chapter_anchor in text:
        text = text.replace(chapter_anchor, chapter_anchor + '\talpha20_prepare_chapter()\n', 1)

    if 'func alpha20_initialize_run()' not in text:
        text += r'''

# Alpha.20: 關卡導演、章節挑戰與 Steam Demo 精修層。
func alpha20_initialize_run() -> void:
	alpha20_demo_state = Alpha20DemoProfile.new_run(chosen_mode, chosen_identity)
	alpha20_director_state.clear()
	alpha20_challenge_state.clear()
	alpha20_tick_timer = 0.0
	alpha20_hazard_timer = 0.0
	alpha20_last_kills = int(run_stats.get("kills", 0))
	alpha20_prepare_chapter()


func alpha20_prepare_chapter() -> void:
	if chapter_manager == null:
		return
	var chapter_id: String = str(current_chapter().get("id", ""))
	alpha20_director_state = Alpha20DemoDirector.profile(chapter_id, chosen_mode)
	alpha20_challenge_state = Alpha20ChallengeTracker.start_chapter(chapter_id, alpha20_director_state)
	alpha20_hazard_timer = float(alpha20_director_state.get("hazard_interval", 24.0))
	alpha20_last_kills = int(run_stats.get("kills", 0))
	spawn_timer *= float(alpha20_director_state.get("opening_spawn_mult", 1.0))
	merchant_spawn_timer *= float(alpha20_director_state.get("merchant_mult", 1.0))
	hero_spawn_timer *= float(alpha20_director_state.get("hero_mult", 1.0))
	var title: String = str(alpha20_director_state.get("title", ""))
	var objective: String = str(alpha20_challenge_state.get("label", ""))
	if title != "":
		show_message("Alpha.20戰場｜%s\n挑戰：%s" % [title, objective], 4.2)


func alpha20_update(delta: float) -> void:
	if player.is_empty() or screen != "game":
		return
	alpha20_tick_timer -= delta
	alpha20_hazard_timer -= delta
	if alpha20_tick_timer <= 0.0:
		alpha20_tick_timer = 0.25
		alpha20_update_challenge()
		alpha20_apply_adaptive_pressure()
	if alpha20_hazard_timer <= 0.0:
		alpha20_hazard_timer = Alpha20DemoDirector.next_hazard_interval(alpha20_director_state, performance_level)
		alpha20_trigger_hazard()


func alpha20_update_challenge() -> void:
	if alpha20_challenge_state.is_empty():
		return
	var current_kills: int = int(run_stats.get("kills", 0))
	var gained_kills: int = max(0, current_kills - alpha20_last_kills)
	alpha20_last_kills = current_kills
	var hp_ratio: float = float(player.get("hp", 0.0)) / max(1.0, float(player.get("max_hp", 1.0)))
	alpha20_challenge_state = Alpha20ChallengeTracker.update(
		alpha20_challenge_state,
		delta_for_alpha20_tick(),
		gained_kills,
		hp_ratio,
		boss_spawned
	)
	if bool(alpha20_challenge_state.get("just_completed", false)):
		alpha20_challenge_state["just_completed"] = false
		var reward: int = int(alpha20_challenge_state.get("reward_coins", 0))
		player["coins"] = int(player.get("coins", 0)) + reward
		player["shield"] = min(float(player.get("max_hp", 1.0)) * 0.35, float(player.get("shield", 0.0)) + float(reward) * 0.45)
		show_message("章節挑戰完成！獲得%d銅錢與護盾。" % reward, 3.4)
		play_sfx("levelup", 1.08)


func delta_for_alpha20_tick() -> float:
	return 0.25


func alpha20_apply_adaptive_pressure() -> void:
	if alpha20_director_state.is_empty():
		return
	var hp_ratio: float = float(player.get("hp", 0.0)) / max(1.0, float(player.get("max_hp", 1.0)))
	var pressure: Dictionary = Alpha20DemoDirector.adaptive_pressure(alpha20_director_state, hp_ratio, performance_level, elapsed)
	player["alpha20_damage_mult"] = float(pressure.get("player_damage_mult", 1.0))
	var base_mult: float = float(player.get("alpha19_damage_mult", 1.0))
	player["alpha19_damage_mult"] = clamp(base_mult * float(player.get("alpha20_damage_mult", 1.0)), 0.85, 2.35)
	if bool(pressure.get("force_wave", false)):
		spawn_timer = min(spawn_timer, 0.08)


func alpha20_trigger_hazard() -> void:
	if alpha20_director_state.is_empty() or boss_spawned:
		return
	var hazard: Dictionary = Alpha20DemoDirector.pick_hazard(alpha20_director_state, rng.randi())
	var hazard_id: String = str(hazard.get("id", "pressure_wave"))
	match hazard_id:
		"arrow_rain":
			spawn_timer = min(spawn_timer, 0.05)
			screen_shake = max(screen_shake, 4.5)
		"fire_wind":
			temporary_speed = max(temporary_speed, 2.5)
			player["shield"] = max(0.0, float(player.get("shield", 0.0)) - 4.0)
		"cavalry_charge":
			spawn_timer = min(spawn_timer, -0.18)
			screen_shake = max(screen_shake, 6.0)
		"fog_of_war":
			temporary_attack_speed = min(temporary_attack_speed, -0.12)
		"supply_window":
			player["coins"] = int(player.get("coins", 0)) + 12
			player["shield"] = float(player.get("shield", 0.0)) + 8.0
		_:
			spawn_timer = min(spawn_timer, 0.12)
	var label: String = str(hazard.get("label", "敵軍壓境"))
	show_message("戰場變化｜%s" % label, 2.8)
	play_sfx("boss_warning", 0.78)


func alpha20_demo_summary() -> String:
	return Alpha20DemoProfile.summary(alpha20_demo_state, alpha20_challenge_state, alpha20_director_state)
'''

    # Main attack damage must include Alpha.20 pressure without permanently compounding Alpha.19 state.
    old = 'var dmg: float = float(player["damage"]) * float(player.get("alpha19_damage_mult", 1.0)) * (1.0 + skill_level("damage") * 0.15) * (1.0 + relic_stat("damage_bonus"))'
    new = 'var dmg: float = float(player["damage"]) * float(player.get("alpha19_damage_mult", 1.0)) * float(player.get("alpha20_damage_mult", 1.0)) * (1.0 + skill_level("damage") * 0.15) * (1.0 + relic_stat("damage_bonus"))'
    text = text.replace(old, new)

    path.write_text(text, encoding="utf-8")


def create_modules() -> None:
    write("scripts/systems/demo/alpha20_demo_director.gd", r'''class_name Alpha20DemoDirector
extends RefCounted

const DEFAULT_PROFILE := {
	"title":"亂世交鋒",
	"opening_spawn_mult":0.92,
	"merchant_mult":1.0,
	"hero_mult":1.0,
	"hazard_interval":26.0,
	"hazards":[{"id":"pressure_wave","label":"敵軍壓境"}],
	"objective":{"type":"kills","target":45,"label":"擊破45名敵軍","reward_coins":28},
}

const CHAPTERS := {
	"yellow_turban":{"title":"黃巾民潮","opening_spawn_mult":0.72,"hazard_interval":24.0,"hazards":[{"id":"pressure_wave","label":"黃巾人潮"},{"id":"supply_window","label":"鄉勇送來補給"}],"objective":{"type":"kills","target":55,"label":"擊破55名黃巾軍","reward_coins":30}},
	"luoyang":{"title":"洛陽烽煙","opening_spawn_mult":0.84,"hazard_interval":23.0,"hazards":[{"id":"fire_wind","label":"烽火蔓延"},{"id":"fog_of_war","label":"濃煙遮蔽視野"}],"objective":{"type":"survive","target":95,"label":"在烽煙中支撐95秒","reward_coins":34}},
	"hulao":{"title":"虎牢鐵騎","opening_spawn_mult":0.68,"hazard_interval":20.0,"hazards":[{"id":"cavalry_charge","label":"西涼鐵騎衝鋒"},{"id":"arrow_rain","label":"關上箭雨"}],"objective":{"type":"healthy","target":80,"label":"維持35%以上生命80秒","reward_coins":38}},
	"xuzhou":{"title":"徐州斷糧","opening_spawn_mult":0.82,"merchant_mult":1.12,"hazard_interval":24.0,"hazards":[{"id":"cavalry_charge","label":"陷陣突擊"},{"id":"supply_window","label":"截獲糧車"}],"objective":{"type":"kills","target":70,"label":"擊破70名追兵","reward_coins":40}},
	"guandu":{"title":"官渡糧戰","opening_spawn_mult":0.76,"hazard_interval":21.0,"hazards":[{"id":"arrow_rain","label":"袁軍弩陣齊射"},{"id":"supply_window","label":"烏巢糧秣暴露"}],"objective":{"type":"survive","target":120,"label":"守住官渡陣線120秒","reward_coins":44}},
	"changban":{"title":"長坂護民","opening_spawn_mult":0.88,"hero_mult":0.82,"hazard_interval":22.0,"hazards":[{"id":"cavalry_charge","label":"曹軍追騎逼近"},{"id":"supply_window","label":"百姓送來乾糧"}],"objective":{"type":"healthy","target":95,"label":"維持30%以上生命95秒","reward_coins":46}},
	"red_cliffs":{"title":"赤壁火海","opening_spawn_mult":0.78,"hazard_interval":18.0,"hazards":[{"id":"fire_wind","label":"東風催動烈火"},{"id":"arrow_rain","label":"戰船箭雨"}],"objective":{"type":"kills","target":90,"label":"火海中擊破90名敵軍","reward_coins":50}},
	"jingzhou":{"title":"荊州箭城","opening_spawn_mult":0.74,"hazard_interval":19.0,"hazards":[{"id":"arrow_rain","label":"城頭連弩"},{"id":"fog_of_war","label":"江霧籠罩"}],"objective":{"type":"healthy","target":105,"label":"維持25%以上生命105秒","reward_coins":52}},
	"hanzhong":{"title":"漢中山道","opening_spawn_mult":0.70,"hazard_interval":19.0,"hazards":[{"id":"cavalry_charge","label":"神速奇襲"},{"id":"arrow_rain","label":"山崖伏弩"}],"objective":{"type":"kills","target":105,"label":"擊破105名山道守軍","reward_coins":56}},
	"yiling":{"title":"夷陵連營","opening_spawn_mult":0.72,"hazard_interval":17.0,"hazards":[{"id":"fire_wind","label":"連營火勢失控"},{"id":"fog_of_war","label":"烈煙蔽日"}],"objective":{"type":"survive","target":145,"label":"撐過連營火勢145秒","reward_coins":60}},
	"wuzhang":{"title":"五丈星落","opening_spawn_mult":0.66,"hazard_interval":16.0,"hazards":[{"id":"fog_of_war","label":"秋霧深陣"},{"id":"cavalry_charge","label":"魏軍精騎輪攻"},{"id":"arrow_rain","label":"連弩封鎖"}],"objective":{"type":"healthy","target":120,"label":"維持20%以上生命120秒","reward_coins":66}},
}

static func profile(chapter_id: String, mode: String) -> Dictionary:
	var out: Dictionary = DEFAULT_PROFILE.duplicate(true)
	if CHAPTERS.has(chapter_id):
		for key in CHAPTERS[chapter_id]: out[key] = CHAPTERS[chapter_id][key]
	if mode != "story":
		out["hazard_interval"] = float(out.get("hazard_interval", 26.0)) * 0.84
		out["opening_spawn_mult"] = float(out.get("opening_spawn_mult", 1.0)) * 0.90
	return out

static func next_hazard_interval(profile_data: Dictionary, performance_level: int) -> float:
	var base := float(profile_data.get("hazard_interval", 26.0))
	return clamp(base + float(max(0, performance_level)) * 4.0, 13.0, 36.0)

static func pick_hazard(profile_data: Dictionary, seed_value: int) -> Dictionary:
	var hazards: Array = profile_data.get("hazards", [])
	if hazards.is_empty(): return {"id":"pressure_wave","label":"敵軍壓境"}
	return hazards[abs(seed_value) % hazards.size()]

static func adaptive_pressure(profile_data: Dictionary, hp_ratio: float, performance_level: int, elapsed: float) -> Dictionary:
	var damage_mult := 1.0
	var force_wave := false
	if hp_ratio < 0.28:
		damage_mult = 1.08
	elif hp_ratio > 0.82 and elapsed > 70.0 and performance_level <= 0:
		damage_mult = 0.98
		force_wave = true
	return {"player_damage_mult":damage_mult,"force_wave":force_wave}
''')

    write("scripts/systems/demo/alpha20_challenge_tracker.gd", r'''class_name Alpha20ChallengeTracker
extends RefCounted

static func start_chapter(chapter_id: String, director_profile: Dictionary) -> Dictionary:
	var objective: Dictionary = director_profile.get("objective", {})
	return {
		"chapter_id":chapter_id,
		"type":str(objective.get("type", "kills")),
		"target":float(objective.get("target", 45)),
		"label":str(objective.get("label", "擊破45名敵軍")),
		"reward_coins":int(objective.get("reward_coins", 28)),
		"progress":0.0,
		"completed":false,
		"just_completed":false,
	}

static func update(state: Dictionary, delta: float, gained_kills: int, hp_ratio: float, boss_active: bool) -> Dictionary:
	var out := state.duplicate(true)
	if bool(out.get("completed", false)): return out
	match str(out.get("type", "kills")):
		"kills": out["progress"] = float(out.get("progress", 0.0)) + float(gained_kills)
		"survive": out["progress"] = float(out.get("progress", 0.0)) + delta
		"healthy":
			if hp_ratio >= 0.35 or boss_active:
				out["progress"] = float(out.get("progress", 0.0)) + delta
	if float(out.get("progress", 0.0)) >= float(out.get("target", 1.0)):
		out["completed"] = true
		out["just_completed"] = true
	return out

static func progress_text(state: Dictionary) -> String:
	return "%s（%d/%d）" % [str(state.get("label", "章節挑戰")), int(state.get("progress", 0.0)), int(state.get("target", 1.0))]
''')

    write("scripts/systems/demo/alpha20_demo_profile.gd", r'''class_name Alpha20DemoProfile
extends RefCounted

const DEMO_CHAPTER_LIMIT := 7

static func new_run(mode: String, identity_id: String) -> Dictionary:
	return {"version":"alpha.20","mode":mode,"identity":identity_id,"chapters_seen":[],"tutorial_complete":false,"demo_chapter_limit":DEMO_CHAPTER_LIMIT}

static func chapter_available(chapter_index: int, mode: String) -> bool:
	if mode != "story": return true
	return chapter_index < DEMO_CHAPTER_LIMIT

static func summary(demo_state: Dictionary, challenge_state: Dictionary, director_state: Dictionary) -> String:
	var completion := "完成" if bool(challenge_state.get("completed", false)) else "進行中"
	return "Alpha.20｜%s｜章節挑戰%s" % [str(director_state.get("title", "亂世交鋒")), completion]
''')

    write("tests/alpha20_demo_polish_test.gd", r'''extends SceneTree

func _init() -> void:
	var profile := Alpha20DemoDirector.profile("red_cliffs", "story")
	assert(str(profile.get("title", "")) == "赤壁火海")
	assert((profile.get("hazards", []) as Array).size() >= 2)
	var challenge := Alpha20ChallengeTracker.start_chapter("red_cliffs", profile)
	challenge = Alpha20ChallengeTracker.update(challenge, 0.25, 95, 1.0, false)
	assert(bool(challenge.get("completed", false)))
	var low_hp := Alpha20DemoDirector.adaptive_pressure(profile, 0.20, 0, 90.0)
	assert(float(low_hp.get("player_damage_mult", 1.0)) > 1.0)
	assert(Alpha20DemoProfile.chapter_available(5, "story"))
	assert(not Alpha20DemoProfile.chapter_available(8, "story"))
	print("ALPHA20_DEMO_POLISH_TEST_OK")
	quit(0)
''')

    write("docs/ALPHA20_DEMO_POLISH.md", """# V2.0.0 Alpha.20 — Demo Polish\n\nAlpha.20 focuses on chapter differentiation, adaptive encounter pacing, chapter challenges, and a Steam-demo-ready progression profile.\n\n## Runtime systems\n\n- Per-chapter battlefield director with distinct hazards and pacing.\n- Adaptive pressure that helps endangered players and accelerates dominant runs.\n- Chapter objectives with immediate coin and shield rewards.\n- Story demo chapter availability profile.\n- Full compatibility with Alpha.19 builds, mastery, history influence, merchant flow, saves, and Ending.\n""")


def main() -> None:
    patch_main()
    create_modules()
    print("Alpha.20 demo polish patch applied")


if __name__ == "__main__":
    main()
