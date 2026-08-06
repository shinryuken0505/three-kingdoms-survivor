from pathlib import Path
import re

main_path = Path('scripts/main.gd')
text = main_path.read_text(encoding='utf-8')

text = text.replace(
    'const Alpha33BossAttackTimeline = preload("res://scripts/systems/boss/alpha33_boss_attack_timeline.gd")',
    'const Alpha33BossAttackTimeline = preload("res://scripts/systems/boss/alpha33_boss_attack_timeline.gd")\nconst Alpha35BossPhaseEnrage = preload("res://scripts/systems/boss/alpha35_boss_phase_enrage.gd")'
)
text = text.replace('V2.0.0-alpha.34', 'V2.0.0-alpha.35')

state_marker = 'var boss_attack_timeline: Dictionary = {}\n'
if 'var boss_phase_state: Dictionary = {}' not in text:
    text = text.replace(state_marker, state_marker + 'var boss_phase_state: Dictionary = {}\n', 1)

# Replace the narrow Alpha.31 hotfix with a full portrait resolver. Prefer high-resolution
# underscored portrait files and never fall back to battle sprite strips.
start = text.find('func apply_alpha31_portrait_reference_hotfix() -> void:')
end = text.find('\nfunc _ready() -> void:', start)
if start < 0 or end < 0:
    raise SystemExit('portrait hotfix block not found')

portrait_files = []
for path in sorted(Path('assets/portraits').glob('*.png')):
    stem = path.stem
    if stem.endswith('_default'):
        continue
    compact = stem.replace('_', '').lower()
    portrait_files.append((compact, 'res://' + path.as_posix()))
# Explicitly prefer the large formal portrait naming scheme when duplicate compact IDs exist.
portrait_map = {}
for compact, path in portrait_files:
    portrait_map[compact] = path
entries = '\n'.join(f'\t\t"{key}": "{value}",' for key, value in sorted(portrait_map.items()))

portrait_functions = f'''func canonical_hero_id(hero_id: String) -> String:
\treturn hero_id.to_lower().replace("_", "").replace("-", "")


func repair_all_hero_portrait_bindings() -> void:
\tvar formal_portraits: Dictionary = {{
{entries}
\t}}
\tfor hero_value in heroes.keys():
\t\tvar hero_id: String = str(hero_value)
\t\tvar compact_id: String = canonical_hero_id(hero_id)
\t\tif not formal_portraits.has(compact_id):
\t\t\tpush_warning("No formal portrait file mapped for hero: %s" % hero_id)
\t\t\tportrait_tex.erase(hero_id)
\t\t\tcontinue
\t\tvar portrait_path: String = str(formal_portraits[compact_id])
\t\tif not ResourceLoader.exists(portrait_path) and not FileAccess.file_exists(portrait_path):
\t\t\tpush_warning("Formal portrait missing: %s -> %s" % [hero_id, portrait_path])
\t\t\tportrait_tex.erase(hero_id)
\t\t\tcontinue
\t\tportrait_tex[hero_id] = runtime_texture(portrait_path)


func hero_portrait(hero_id: String) -> Texture2D:
\tif portrait_tex.has(hero_id) and portrait_tex[hero_id] is Texture2D:
\t\treturn portrait_tex[hero_id] as Texture2D
\tpush_warning("Hero portrait unavailable; sprite fallback forbidden: %s" % hero_id)
\treturn runtime_texture("res://assets/portraits/placeholder.png")


func validate_hero_portrait_references() -> void:
\tfor hero_value in heroes.keys():
\t\tvar hero_id: String = str(hero_value)
\t\tif not portrait_tex.has(hero_id) or not (portrait_tex[hero_id] is Texture2D):
\t\t\tpush_warning("Missing formal hero portrait reference: %s" % hero_id)

'''
text = text[:start] + portrait_functions + text[end:]
text = text.replace('\tapply_alpha31_portrait_reference_hotfix()\n', '\trepair_all_hero_portrait_bindings()\n', 1)

# Replace direct hero portrait lookups in UI drawing with the guarded formal resolver.
text = re.sub(r'portrait_tex\[([a-zA-Z_][a-zA-Z0-9_]*)\]', r'hero_portrait(str(\1))', text)
# Restore assignment sites altered by the broad UI replacement.
text = text.replace('hero_portrait(str(id)) = runtime_texture(str(identities[id]["portrait"]))', 'portrait_tex[id] = runtime_texture(str(identities[id]["portrait"]))')
text = text.replace('hero_portrait(str(id)) = runtime_texture(str(heroes[id]["portrait"]))', 'portrait_tex[id] = runtime_texture(str(heroes[id]["portrait"]))')
text = text.replace('hero_portrait(str(id)) = runtime_texture("res://assets/portraits/%s_default.png" % id)', 'portrait_tex[id] = runtime_texture("res://assets/portraits/%s_default.png" % id)')
text = text.replace('hero_portrait(str(hero_id)) = runtime_texture(portrait_path)', 'portrait_tex[hero_id] = runtime_texture(portrait_path)')

# Phase state functions.
insert_marker = '\n\nfunc request_run_result(victory: bool) -> void:\n'
if insert_marker not in text:
    raise SystemExit('request_run_result marker missing')
phase_functions = r'''

func reset_alpha35_boss_phase() -> void:
	boss_phase_state = {
		"boss_id": str(boss.get("id", "")),
		"phase": 1,
		"transitioning": false,
		"timer": 0.0,
		"applied": false
	}


func update_alpha35_boss_phase(delta: float) -> void:
	if boss.is_empty():
		boss_phase_state.clear()
		return
	var boss_id: String = str(boss.get("id", ""))
	if boss_phase_state.is_empty() or str(boss_phase_state.get("boss_id", "")) != boss_id:
		reset_alpha35_boss_phase()
	if bool(boss_phase_state.get("transitioning", false)):
		boss_phase_state["timer"] = max(0.0, float(boss_phase_state.get("timer", 0.0)) - delta)
		if float(boss_phase_state["timer"]) <= 0.0:
			boss_phase_state["transitioning"] = false
			boss_phase_state["phase"] = 2
			boss_phase_state["applied"] = true
			boss["speed"] = float(boss.get("speed", 70.0)) * Alpha35BossPhaseEnrage.enrage_speed_mult(boss_id)
			boss["damage"] = float(boss.get("damage", 16.0)) * Alpha35BossPhaseEnrage.enrage_damage_mult(boss_id)
			boss["special_cd"] = min(float(boss.get("special_cd", 4.0)), 1.4)
			boss["control_lock"] = max(float(boss.get("control_lock", 0.0)), 0.55)
			show_message("%s進入狂暴階段！" % str(boss.get("name", "敵將")), 2.2)
			spawn_ring(boss.get("pos", Vector2.ZERO) as Vector2, Color8(238, 77, 58), 128.0, 0.72)
			play_sfx("boss_intro", 1.08)
			screen_shake = max(screen_shake, 14.0)
		return
	if int(boss_phase_state.get("phase", 1)) >= 2:
		return
	var max_hp: float = max(1.0, float(boss.get("max_hp", boss.get("hp", 1.0))))
	var hp_ratio: float = float(boss.get("hp", max_hp)) / max_hp
	if hp_ratio <= Alpha35BossPhaseEnrage.transition_threshold(boss_id):
		boss_phase_state["transitioning"] = true
		boss_phase_state["timer"] = Alpha35BossPhaseEnrage.transition_duration(boss_id)
		boss_attack_timeline.clear()
		boss["telegraph_time"] = 0.0
		boss["telegraph_total"] = 0.0
		boss["control_lock"] = float(boss_phase_state["timer"])
		show_message("%s：真正的戰鬥現在才開始！" % str(boss.get("name", "敵將")), 2.0)
		spawn_ring(boss.get("pos", Vector2.ZERO) as Vector2, Color8(245, 183, 73), 105.0, 0.55)
		play_sfx("boss_warning", 0.86)


func alpha35_phase_label() -> String:
	if boss_phase_state.is_empty():
		return ""
	return Alpha35BossPhaseEnrage.phase_label(boss_phase_state)
'''
text = text.replace(insert_marker, phase_functions + insert_marker, 1)

# Update phase before boss/timeline updates.
old_update = '\tupdate_world_events(delta)\n\tif boss_attack_timeline.is_empty():'
new_update = '\tupdate_world_events(delta)\n\tupdate_alpha35_boss_phase(delta)\n\tif bool(boss_phase_state.get("transitioning", false)):\n\t\tflush_pending_run_result()\n\t\treturn\n\tif boss_attack_timeline.is_empty():'
if old_update not in text:
    raise SystemExit('boss update marker missing')
text = text.replace(old_update, new_update, 1)

# Transition is invulnerable and phase two raises the break threshold.
damage_marker = 'func damage_boss(amount: float, source: String, crit: bool) -> void:\n\tif boss.is_empty() or float(boss.get("hp", 0.0)) <= 0.0:\n\t\treturn\n'
if damage_marker not in text:
    raise SystemExit('damage_boss marker missing')
text = text.replace(damage_marker, damage_marker + '\tif bool(boss_phase_state.get("transitioning", false)):\n\t\treturn\n', 1)
text = text.replace('Alpha34BossCounterWindow.break_threshold(boss, difficulty_id())', 'Alpha34BossCounterWindow.break_threshold(boss, difficulty_id()) * Alpha35BossPhaseEnrage.break_threshold_mult(boss_phase_state)')

# Shorter phase-two special cooldown while preserving telegraphs.
text = text.replace(
    'boss["special_cd"] = max(0.0, float(boss["special_cd"]) - delta)',
    'var alpha35_special_delta: float = delta / Alpha35BossPhaseEnrage.special_cooldown_mult(str(boss.get("id", ""))) if int(boss_phase_state.get("phase", 1)) >= 2 else delta\n\tboss["special_cd"] = max(0.0, float(boss["special_cd"]) - alpha35_special_delta)',
    1
)

main_path.write_text(text, encoding='utf-8')

report = Path('docs/art/alpha35_phase_portrait_report.md')
report.write_text('''# Alpha.35 Phase Enrage and Portrait Audit\n\n- Replaced the narrow Zhang Fei/Cao Cao portrait hotfix with a full roster resolver.\n- Formal high-resolution portraits in assets/portraits are preferred by canonical compact hero ID.\n- Recruit and hero-card rendering no longer falls back to battle sprite strips.\n- Missing portraits produce explicit warnings and a placeholder rather than misleading sprites.\n- Bosses now transition to Phase 2 at profile-specific HP thresholds.\n- Transition cancels active timelines, grants temporary invulnerability and blocks break attempts.\n- Phase 2 changes speed, damage, special cadence and break threshold.\n- Manual visual and gameplay QA remains required.\n''', encoding='utf-8')
