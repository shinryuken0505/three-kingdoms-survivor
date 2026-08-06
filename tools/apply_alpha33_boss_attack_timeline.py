from pathlib import Path

path = Path('scripts/main.gd')
text = path.read_text(encoding='utf-8')

text = text.replace(
    'const Alpha32BossHitboxSync = preload("res://scripts/systems/boss/alpha32_boss_hitbox_sync.gd")',
    'const Alpha32BossHitboxSync = preload("res://scripts/systems/boss/alpha32_boss_hitbox_sync.gd")\nconst Alpha33BossAttackTimeline = preload("res://scripts/systems/boss/alpha33_boss_attack_timeline.gd")'
)
text = text.replace('V2.0.0-alpha.32', 'V2.0.0-alpha.33')

state_marker = 'var boss_ability_banner: Dictionary = {}\n'
if state_marker not in text:
    raise SystemExit('boss ability state marker not found')
text = text.replace(state_marker, state_marker + 'var boss_attack_timeline: Dictionary = {}\n', 1)

old_release = '''\tif remaining <= 0.0:\n\t\tboss_ability_banner["warning"] = false\n\t\tvar player_pos: Vector2 = player.get("pos", Vector2.ZERO) as Vector2\n\t\tif Alpha32BossHitboxSync.contains_point(boss, player_pos):\n\t\t\tboss_special_attack()\n\t\telse:\n\t\t\tspawn_ring(player_pos, Color8(110, 196, 142), 38.0, 0.28)\n\t\t\tshow_message("成功閃避 %s" % alpha30_boss_skill_name(), 1.1)'''
new_release = '''\tif remaining <= 0.0:\n\t\tboss_ability_banner["warning"] = false\n\t\tstart_boss_attack_timeline()'''
if old_release not in text:
    raise SystemExit('Alpha.32 release block not found')
text = text.replace(old_release, new_release, 1)

old_update = '''\tupdate_world_events(delta)\n\tupdate_boss(delta)\n\tflush_pending_run_result()'''
new_update = '''\tupdate_world_events(delta)\n\tif boss_attack_timeline.is_empty():\n\t\tupdate_boss(delta)\n\telse:\n\t\tupdate_boss_attack_timeline(delta)\n\tflush_pending_run_result()'''
if old_update not in text:
    raise SystemExit('update_game boss block not found')
text = text.replace(old_update, new_update, 1)

insert_marker = '\n\nfunc request_run_result(victory: bool) -> void:\n'
if insert_marker not in text:
    raise SystemExit('request_run_result marker not found')
functions = r'''

func start_boss_attack_timeline() -> void:
	if boss.is_empty() or player.is_empty():
		return
	boss_attack_timeline = Alpha33BossAttackTimeline.create(
		boss,
		player.get("pos", Vector2.ZERO) as Vector2,
		alpha30_boss_skill_name()
	)
	var total_lock: float = float(boss_attack_timeline.get("total", 0.7)) + float(boss_attack_timeline.get("recover", 0.4))
	boss["control_lock"] = max(float(boss.get("control_lock", 0.0)), total_lock)
	boss_action_anim = {
		"kind": "boss_timeline",
		"life": total_lock,
		"max_life": total_lock
	}


func boss_timeline_damage(multiplier: float) -> float:
	var base_damage: float = float(boss.get("damage", 18.0))
	return max(1.0, base_damage * multiplier)


func resolve_boss_timeline_event(event: Dictionary) -> void:
	var event_pos: Vector2 = event.get("pos", boss.get("pos", Vector2.ZERO)) as Vector2
	var event_kind: String = str(event.get("kind", "circle"))
	var radius: float = float(event.get("radius", 120.0))
	var color: Color = Color8(236, 84, 65)
	if event_kind == "sector":
		spawn_ring(event_pos, color, radius, 0.30)
		spawn_sparks(event_pos + (event.get("direction", Vector2.RIGHT) as Vector2) * radius * 0.55, Color8(244, 198, 98), 12)
	else:
		spawn_ring(event_pos, color, radius, 0.34)
		spawn_sparks(event_pos, Color8(244, 198, 98), 10)
	play_sfx("boss_warning", 0.94)
	screen_shake = max(screen_shake, 8.0)
	if Alpha33BossAttackTimeline.event_contains(event, player.get("pos", Vector2.ZERO) as Vector2):
		damage_player(boss_timeline_damage(float(event.get("damage_mult", 1.0))), "boss", 0.10)
	else:
		spawn_ring(player.get("pos", Vector2.ZERO) as Vector2, Color8(110, 196, 142), 30.0, 0.24)


func update_boss_attack_timeline(delta: float) -> void:
	if boss_attack_timeline.is_empty():
		return
	if boss.is_empty() or player.is_empty():
		boss_attack_timeline.clear()
		return

	boss_attack_timeline["elapsed"] = float(boss_attack_timeline.get("elapsed", 0.0)) + delta
	var elapsed_time: float = float(boss_attack_timeline["elapsed"])
	var timeline_kind: String = str(boss_attack_timeline.get("kind", "events"))

	if timeline_kind == "charge":
		var total: float = max(0.01, float(boss_attack_timeline.get("total", 0.68)))
		var progress: float = clamp(elapsed_time / total, 0.0, 1.0)
		var eased: float = sin(progress * PI * 0.5)
		var origin: Vector2 = boss_attack_timeline.get("origin", boss.get("pos", Vector2.ZERO)) as Vector2
		var end_pos: Vector2 = boss_attack_timeline.get("end", origin) as Vector2
		boss["pos"] = origin.lerp(end_pos, eased)
		if int(floor(elapsed_time * 24.0)) % 3 == 0:
			spawn_sparks(boss.get("pos", origin) as Vector2, Color8(214, 176, 101), 2)
		if not bool(boss_attack_timeline.get("hit", false)) and Alpha33BossAttackTimeline.charge_contains(
			boss_attack_timeline,
			player.get("pos", Vector2.ZERO) as Vector2
		):
			var boss_pos: Vector2 = boss.get("pos", origin) as Vector2
			var player_pos: Vector2 = player.get("pos", Vector2.ZERO) as Vector2
			if boss_pos.distance_to(player_pos) <= float(boss_attack_timeline.get("width", 82.0)) * 0.72 + float(boss.get("radius", 24.0)):
				boss_attack_timeline["hit"] = true
				damage_player(boss_timeline_damage(1.12), "boss", 0.18)
				screen_shake = max(screen_shake, 10.0)
				spawn_ring(player_pos, Color8(236, 84, 65), 52.0, 0.30)
	else:
		var events: Array = boss_attack_timeline.get("events", []) as Array
		for index in range(events.size()):
			var event: Dictionary = events[index]
			if not bool(event.get("fired", false)) and elapsed_time >= float(event.get("time", 0.0)):
				event["fired"] = true
				events[index] = event
				resolve_boss_timeline_event(event)
		boss_attack_timeline["events"] = events

	if elapsed_time >= float(boss_attack_timeline.get("total", 0.72)):
		var skill_name: String = str(boss_attack_timeline.get("skill_name", "大招"))
		var recovered: float = float(boss_attack_timeline.get("recover", 0.42))
		boss_attack_timeline.clear()
		boss["control_lock"] = max(float(boss.get("control_lock", 0.0)), recovered)
		boss["telegraph_time"] = 0.0
		boss["telegraph_total"] = 0.0
		show_message("%s收招，反擊時機！" % skill_name, 1.25)
		spawn_ring(boss.get("pos", Vector2.ZERO) as Vector2, Color8(235, 199, 116), 58.0, 0.26)
'''
text = text.replace(insert_marker, functions + insert_marker, 1)

path.write_text(text, encoding='utf-8')

report = Path('docs/art/alpha33_boss_attack_timeline_report.md')
report.write_text('''# Alpha.33 Boss Attack Timeline\n\n- Boss specials now use explicit wind-up, impact and recovery timing.\n- Zhang Jiao and Zhang Liang resolve lightning circles sequentially.\n- Gao Shun and Zhang He physically charge along the locked warning line and can hit only once.\n- Hua Xiong uses a timed sector impact; Lu Bu performs a two-stage sweep.\n- Normal boss updates pause while a special timeline is active.\n- Damage, impact visuals, sound and screen shake resolve on the same event frame.\n- Every completed special grants a visible recovery/counter window.\n\nManual gameplay QA remains required for damage balance, collision feel and every boss profile.\n''', encoding='utf-8')
