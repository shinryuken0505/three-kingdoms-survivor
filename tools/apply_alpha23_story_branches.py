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
    text = text.replace('const GAME_VERSION: String = "V2.0.0-alpha.22"', 'const GAME_VERSION: String = "V2.0.0-alpha.23"')
    text = text.replace('V2.0.0 Alpha.22・亂世傳承', 'V2.0.0 Alpha.23・史路分歧')

    preload_anchor = 'const Alpha22Achievements = preload("res://scripts/systems/meta/alpha22_achievements.gd")\n'
    preload_block = preload_anchor + (
        'const Alpha23StoryDirector = preload("res://scripts/systems/story/alpha23_story_director.gd")\n'
        'const Alpha23RouteResolver = preload("res://scripts/systems/story/alpha23_route_resolver.gd")\n'
        'const Alpha23EndingRoutes = preload("res://scripts/systems/ending/alpha23_ending_routes.gd")\n'
    )
    if 'Alpha23StoryDirector' not in text:
        text = replace_once(text, preload_anchor, preload_block)

    var_anchor = 'var alpha22_last_rewards: Array[String] = []\n'
    var_block = var_anchor + (
        'var alpha23_route_state: Dictionary = {}\n'
        'var alpha23_story_scene: Dictionary = {}\n'
        'var alpha23_chapter_variant: Dictionary = {}\n'
        'var alpha23_pending_ending: Dictionary = {}\n'
    )
    if 'var alpha23_route_state' not in text:
        text = replace_once(text, var_anchor, var_block)

    save_anchor = '\t"achievements": {},\n'
    save_block = save_anchor + '\t"story_routes": {},\n'
    if '"story_routes"' not in text:
        text = replace_once(text, save_anchor, save_block)

    init_anchor = '\talpha22_initialize_profile()\n'
    if 'alpha23_initialize_story()' not in text:
        text = replace_once(text, init_anchor, init_anchor + '\talpha23_initialize_story()\n')

    if 'func alpha23_initialize_story()' not in text:
        text += r'''

# Alpha.23：章節故事、歷史路線、關卡變體與多結局。
func alpha23_initialize_story() -> void:
	var raw: Variant = save_data.get("story_routes", {})
	alpha23_route_state = raw.duplicate(true) if raw is Dictionary and not raw.is_empty() else Alpha23RouteResolver.new_state()
	alpha23_story_scene.clear()
	alpha23_chapter_variant.clear()
	alpha23_pending_ending.clear()


func alpha23_apply_history_choice(choice_id: String, effects: Dictionary) -> Dictionary:
	alpha23_route_state = Alpha23RouteResolver.apply_choice(alpha23_route_state, choice_id, effects)
	save_data["story_routes"] = alpha23_route_state.duplicate(true)
	return alpha23_route_state.duplicate(true)


func alpha23_prepare_chapter_story(phase: String = "opening") -> Dictionary:
	var chapter_id: String = ""
	if chapter_manager != null:
		chapter_id = str(current_chapter().get("id", ""))
	alpha23_story_scene = Alpha23StoryDirector.chapter_scene(chapter_id, phase, alpha23_route_state)
	alpha23_chapter_variant = Alpha23RouteResolver.chapter_variant(chapter_id, alpha23_route_state)
	return alpha23_story_scene.duplicate(true)


func alpha23_current_chapter_variant() -> Dictionary:
	if alpha23_chapter_variant.is_empty():
		alpha23_prepare_chapter_story("opening")
	return alpha23_chapter_variant.duplicate(true)


func alpha23_resolve_ending(run_summary: Dictionary) -> Dictionary:
	alpha23_pending_ending = Alpha23EndingRoutes.resolve(alpha23_route_state, run_summary)
	var ending_id: String = str(alpha23_pending_ending.get("id", ""))
	if ending_id != "":
		alpha22_discover("endings", ending_id, {
			"name": str(alpha23_pending_ending.get("title", ending_id)),
			"route": str(alpha23_pending_ending.get("route", "balanced"))
		})
	return alpha23_pending_ending.duplicate(true)


func alpha23_route_summary() -> String:
	var dominant: String = str(alpha23_route_state.get("dominant", "balanced"))
	var variant_label: String = str(alpha23_chapter_variant.get("label", "史勢未定"))
	return "%s｜%s" % [Alpha23RouteResolver.ending_route_label(dominant), variant_label]
'''

    MAIN.write_text(text, encoding="utf-8")


def patch_project() -> None:
    text = PROJECT.read_text(encoding="utf-8")
    text = text.replace('三國人生錄：亂世倖存 V2.0.0-alpha.22', '三國人生錄：亂世倖存 V2.0.0-alpha.23')
    PROJECT.write_text(text, encoding="utf-8")


if __name__ == "__main__":
    patch_main()
    patch_project()
    print("Alpha.23 story branches patch applied")
