from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAIN = ROOT / "scripts/main.gd"
PROJECT = ROOT / "project.godot"


def replace_once(text: str, old: str, new: str) -> str:
    if new in text:
        return text
    if old not in text:
        raise SystemExit(f"missing patch anchor: {old[:100]}")
    return text.replace(old, new, 1)


def patch_main() -> None:
    text = MAIN.read_text(encoding="utf-8")
    text = text.replace('const GAME_VERSION: String = "V2.0.0-alpha.23"', 'const GAME_VERSION: String = "V2.0.0-alpha.24"')
    text = text.replace('V2.0.0 Alpha.23・史路分歧', 'V2.0.0 Alpha.24・Demo封版')

    preload_anchor = 'const Alpha23EndingRoutes = preload("res://scripts/systems/ending/alpha23_ending_routes.gd")\n'
    preload_block = preload_anchor + 'const Alpha24SteamDemo = preload("res://scripts/systems/demo/alpha24_steam_demo.gd")\n'
    if 'const Alpha24SteamDemo' not in text:
        text = replace_once(text, preload_anchor, preload_block)

    var_anchor = 'var alpha23_pending_ending: Dictionary = {}\n'
    var_block = var_anchor + (
        'var alpha24_demo_state: Dictionary = {}\n'
        'var alpha24_quality_profile: Dictionary = {}\n'
        'var alpha24_frame_sample_timer: float = 0.0\n'
    )
    if 'var alpha24_demo_state' not in text:
        text = replace_once(text, var_anchor, var_block)

    init_anchor = 'func alpha23_initialize_story() -> void:\n'
    if '\talpha24_initialize_demo()\n' not in text:
        text = replace_once(text, init_anchor, init_anchor + '\talpha24_initialize_demo()\n')

    process_anchor = 'func _process(delta: float) -> void:\n'
    if '\talpha24_update_release_guard(delta)\n' not in text:
        text = replace_once(text, process_anchor, process_anchor + '\talpha24_update_release_guard(delta)\n')

    if 'func alpha24_initialize_demo()' not in text:
        text += r'''

# Alpha.24：Steam Demo 封版、教學、效能降載與完成提示。
func alpha24_initialize_demo() -> void:
	var stored: Variant = save_data.get("alpha24_demo", {})
	alpha24_demo_state = Alpha24SteamDemo.normalize(stored)
	alpha24_quality_profile = Alpha24SteamDemo.quality_profile(str(alpha24_demo_state.get("quality", "high")))
	alpha24_frame_sample_timer = 0.0


func alpha24_tutorial_event(event_id: String, amount: float = 1.0) -> void:
	var before: int = int(alpha24_demo_state.get("tutorial_index", 0))
	alpha24_demo_state = Alpha24SteamDemo.advance_tutorial(alpha24_demo_state, event_id, amount)
	var after: int = int(alpha24_demo_state.get("tutorial_index", 0))
	if after > before:
		var next_step: Dictionary = Alpha24SteamDemo.current_tutorial(alpha24_demo_state)
		if next_step.is_empty():
			show_message("新手教學完成！亂世之路由你開創。", 3.5)
		else:
			show_message("教學｜%s" % str(next_step.get("label", "")), 3.2)
	alpha24_commit_demo_state()


func alpha24_current_tutorial_label() -> String:
	var step: Dictionary = Alpha24SteamDemo.current_tutorial(alpha24_demo_state)
	return str(step.get("label", ""))


func alpha24_story_chapter_allowed(chapter_number: int) -> bool:
	return Alpha24SteamDemo.demo_chapter_allowed(chosen_mode, chapter_number)


func alpha24_complete_demo() -> String:
	alpha24_demo_state["demo_completed"] = true
	alpha24_commit_demo_state()
	var route_name: String = Alpha23RouteResolver.route_label(str(alpha23_route_state.get("dominant", "")))
	var ending_title: String = str(alpha23_pending_ending.get("title", ""))
	return Alpha24SteamDemo.completion_message(route_name, ending_title)


func alpha24_update_release_guard(delta: float) -> void:
	alpha24_frame_sample_timer -= delta
	if alpha24_frame_sample_timer > 0.0:
		return
	alpha24_frame_sample_timer = 1.0
	var frame_ms: float = frame_time_ema * 1000.0
	var current_quality: String = str(alpha24_demo_state.get("quality", "high"))
	var next_quality: String = Alpha24SteamDemo.quality_for_frame_time(frame_ms, current_quality)
	if next_quality != current_quality:
		alpha24_demo_state["quality"] = next_quality
		alpha24_quality_profile = Alpha24SteamDemo.quality_profile(next_quality)
		alpha24_commit_demo_state()
	alpha24_apply_quality_caps()


func alpha24_apply_quality_caps() -> void:
	var enemy_cap: int = int(alpha24_quality_profile.get("enemy_cap", MAX_PICKUPS))
	var particle_cap: int = int(alpha24_quality_profile.get("particle_cap", MAX_PARTICLES))
	var shot_cap: int = int(alpha24_quality_profile.get("shot_cap", MAX_PLAYER_SHOTS))
	var number_cap: int = int(alpha24_quality_profile.get("damage_number_cap", MAX_DAMAGE_NUMBERS))
	if enemies.size() > enemy_cap:
		enemies.resize(enemy_cap)
	if particles.size() > particle_cap:
		particles.resize(particle_cap)
	if player_shots.size() > shot_cap:
		player_shots.resize(shot_cap)
	if damage_numbers.size() > number_cap:
		damage_numbers.resize(number_cap)


func alpha24_commit_demo_state() -> void:
	save_data["alpha24_demo"] = alpha24_demo_state.duplicate(true)


func alpha24_release_readiness() -> Dictionary:
	return Alpha24SteamDemo.release_readiness(
		GAME_VERSION,
		SAVE_FORMAT_VERSION >= 4,
		bool(alpha24_demo_state.get("tutorial_done", false)),
		startup_checks.filter(func(value: String) -> bool: return value.find("ERROR") >= 0).size(),
		asset_errors.size()
	)
'''

    save_anchor = '\t"story_routes": {},\n'
    if '"alpha24_demo"' not in text:
        text = replace_once(text, save_anchor, save_anchor + '\t"alpha24_demo": {},\n')

    MAIN.write_text(text, encoding="utf-8")


def patch_project() -> None:
    text = PROJECT.read_text(encoding="utf-8")
    text = text.replace('三國人生錄：亂世倖存 V2.0.0-alpha.23', '三國人生錄：亂世倖存 V2.0.0-alpha.24')
    PROJECT.write_text(text, encoding="utf-8")


if __name__ == "__main__":
    patch_main()
    patch_project()
    print("Alpha.24 Steam Demo patch applied")
