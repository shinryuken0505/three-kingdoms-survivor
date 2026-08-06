from pathlib import Path

path = Path('scripts/main.gd')
text = path.read_text(encoding='utf-8')

text = text.replace(
    'const Alpha33BossAttackTimeline = preload("res://scripts/systems/boss/alpha33_boss_attack_timeline.gd")',
    'const Alpha33BossAttackTimeline = preload("res://scripts/systems/boss/alpha33_boss_attack_timeline.gd")\nconst Alpha34BossCounterWindow = preload("res://scripts/systems/boss/alpha34_boss_counter_window.gd")'
)
text = text.replace('V2.0.0-alpha.33', 'V2.0.0-alpha.34')

state_marker = 'var boss_attack_timeline: Dictionary = {}\n'
if state_marker not in text:
    raise SystemExit('boss timeline state marker not found')
text = text.replace(
    state_marker,
    state_marker
    + 'var boss_counter_window: float = 0.0\n'
    + 'var boss_counter_was_break: bool = false\n'
    + 'var boss_break_damage: float = 0.0\n'
    + 'var boss_break_immunity: float = 0.0\n'
    + 'var boss_precision_dodge_rewarded: bool = false\n',
    1,
)

update_marker = '\treserve_roar_cd = max(0.0, reserve_roar_cd - delta)\n'
if update_marker not in text:
    raise SystemExit('global timer marker not found')
text = text.replace(
    update_marker,
    update_marker
    + '\tboss_counter_window = max(0.0, boss_counter_window - delta)\n'
    + '\tboss_break_immunity = max(0.0, boss_break_immunity - delta)\n',
    1,
)

start_marker = '''\tboss_attack_timeline = Alpha33BossAttackTimeline.create(
\t\tboss,
\t\tplayer.get("pos", Vector2.ZERO) as Vector2,
\t\talpha30_boss_skill_name()
\t)'''
if start_marker not in text:
    raise SystemExit('timeline create marker not found')
text = text.replace(
    start_marker,
    start_marker
    + '\n\tboss_break_damage = 0.0'
    + '\n\tboss_precision_dodge_rewarded = false'
    + '\n\tboss_counter_window = 0.0'
    + '\n\tboss_counter_was_break = false',
    1,
)

final_marker = '''\tvar final: float = amount * build_damage_multiplier(source) * equipment_effect("damage_mult", 1.0) * float(history_modifiers.get("player_damage_mult", 1.0))'''
if final_marker not in text:
    raise SystemExit('damage_boss final marker not found')
text = text.replace(
    final_marker,
    final_marker
    + '''
\tif boss_counter_window > 0.0:
\t\tfinal *= Alpha34BossCounterWindow.counter_damage_multiplier(boss_counter_was_break)
\t\tspawn_sparks(boss.get("pos", Vector2.ZERO) as Vector2, Color8(247, 220, 130), 3)
\tif not boss_attack_timeline.is_empty() and boss_break_immunity <= 0.0:
\t\tboss_break_damage += final
\t\tvar break_need: float = Alpha34BossCounterWindow.break_threshold(boss, difficulty_id())
\t\tif boss_break_damage >= break_need:
\t\t\ttrigger_boss_break()''',
    1,
)

precision_marker = '''\telse:
\t\tspawn_ring(player.get("pos", Vector2.ZERO) as Vector2, Color8(110, 196, 142), 30.0, 0.24)'''
if precision_marker not in text:
    raise SystemExit('timeline miss marker not found')
text = text.replace(
    precision_marker,
    precision_marker
    + '''
\t\tif float(player.get("dash_active", 0.0)) > 0.0:
\t\t\tgrant_precision_dodge_reward()''',
    1,
)

complete_marker = '''\t\tvar recovered: float = float(boss_attack_timeline.get("recover", 0.42))
\t\tboss_attack_timeline.clear()
\t\tboss["control_lock"] = max(float(boss.get("control_lock", 0.0)), recovered)
\t\tboss["telegraph_time"] = 0.0
\t\tboss["telegraph_total"] = 0.0
\t\tshow_message("%s收招，反擊時機！" % skill_name, 1.25)
\t\tspawn_ring(boss.get("pos", Vector2.ZERO) as Vector2, Color8(235, 199, 116), 58.0, 0.26)'''
if complete_marker not in text:
    raise SystemExit('timeline completion marker not found')
text = text.replace(
    complete_marker,
    '''\t\tvar recovered: float = float(boss_attack_timeline.get("recover", 0.42))
\t\tboss_attack_timeline.clear()
\t\tboss_counter_was_break = false
\t\tboss_counter_window = Alpha34BossCounterWindow.counter_duration(str(boss.get("id", "")), false)
\t\tboss["control_lock"] = max(float(boss.get("control_lock", 0.0)), max(recovered, boss_counter_window))
\t\tboss["telegraph_time"] = 0.0
\t\tboss["telegraph_total"] = 0.0
\t\tshow_message("%s收招，弱點暴露！" % skill_name, 1.35)
\t\tspawn_ring(boss.get("pos", Vector2.ZERO) as Vector2, Color8(247, 220, 130), 68.0, 0.42)''',
    1,
)

insert_marker = '\n\nfunc request_run_result(victory: bool) -> void:\n'
if insert_marker not in text:
    raise SystemExit('function insert marker not found')
functions = r'''

func trigger_boss_break() -> void:
	if boss.is_empty() or boss_attack_timeline.is_empty() or boss_break_immunity > 0.0:
		return
	boss_attack_timeline.clear()
	boss_break_damage = 0.0
	boss_break_immunity = Alpha34BossCounterWindow.break_immunity_duration()
	boss_counter_was_break = true
	boss_counter_window = Alpha34BossCounterWindow.counter_duration(str(boss.get("id", "")), true)
	boss["control_lock"] = max(float(boss.get("control_lock", 0.0)), boss_counter_window)
	boss["telegraph_time"] = 0.0
	boss["telegraph_total"] = 0.0
	boss_ability_banner.clear()
	boss_action_anim = {"kind":"boss_break", "life":boss_counter_window, "max_life":boss_counter_window}
	show_message("破招！Boss弱點大開！", 1.65)
	play_sfx("crit", 0.82)
	screen_shake = max(screen_shake, 12.0)
	spawn_ring(boss.get("pos", Vector2.ZERO) as Vector2, Color8(255, 229, 133), 92.0, 0.58)
	spawn_sparks(boss.get("pos", Vector2.ZERO) as Vector2, Color8(255, 238, 168), 18)


func grant_precision_dodge_reward() -> void:
	if boss_precision_dodge_rewarded:
		return
	boss_precision_dodge_rewarded = true
	temporary_speed = max(temporary_speed, 2.0)
	temporary_attack_speed = max(temporary_attack_speed, 2.0)
	for hid in active_heroes:
		hero_cooldowns[hid] = max(0.0, float(hero_cooldowns.get(hid, 0.0)) - 0.8)
	show_message("精準閃避！攻速與移速提升", 1.35)
	play_sfx("dash", 1.08)
	spawn_ring(player.get("pos", Vector2.ZERO) as Vector2, Color8(116, 216, 178), 46.0, 0.34)
'''
text = text.replace(insert_marker, functions + insert_marker, 1)

path.write_text(text, encoding='utf-8')

report = Path('docs/art/alpha34_boss_counter_window_report.md')
report.write_text('''# Alpha.34 Boss Counter Window\n\n- Boss recovery now opens a timed weak-point window with bonus player damage.\n- Heavy bosses expose longer windows; fast bosses recover sooner.\n- Damage dealt during a boss special fills a difficulty-scaled break gauge.\n- Reaching the threshold cancels the remaining attack timeline and creates an extended counter window.\n- Break immunity prevents permanent interruption loops.\n- Dodging a timeline impact while dash invulnerability is active grants a once-per-special precision dodge reward.\n- Precision dodge briefly improves movement/attack speed and reduces active hero cooldowns.\n\nManual QA remains required for break thresholds, feedback readability and difficulty balance.\n''', encoding='utf-8')
