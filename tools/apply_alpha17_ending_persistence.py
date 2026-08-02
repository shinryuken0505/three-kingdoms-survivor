from pathlib import Path

path = Path("scripts/main.gd")
text = path.read_text(encoding="utf-8")


def replace_once(old: str, new: str) -> None:
    global text
    if old not in text:
        raise SystemExit(f"missing patch target:\n{old[:180]}")
    text = text.replace(old, new, 1)

replace_once(
    '\t"run_save": {},\n\t"settings": {',
    '\t"run_save": {},\n\t"endings": {},\n\t"latest_ending": {},\n\t"settings": {',
)
replace_once(
    '\tif parsed_data.get("run_save", {}) is Dictionary:\n\t\tnormalized["run_save"] = parsed_data.get("run_save", {})\n\tif parsed_data.get("settings", {}) is Dictionary:',
    '\tif parsed_data.get("run_save", {}) is Dictionary:\n\t\tnormalized["run_save"] = parsed_data.get("run_save", {})\n\tif parsed_data.get("endings", {}) is Dictionary:\n\t\tnormalized["endings"] = parsed_data.get("endings", {})\n\tif parsed_data.get("latest_ending", {}) is Dictionary:\n\t\tnormalized["latest_ending"] = parsed_data.get("latest_ending", {})\n\tif parsed_data.get("settings", {}) is Dictionary:',
)
replace_once(
    'func end_run(victory: bool) -> void:\n\tif screen in ["game_over", "victory", "intermission"]:',
    'func end_run(victory: bool) -> void:\n\tif screen in ["game_over", "victory", "ending", "intermission"]:',
)
replace_once(
    '\tending_snapshot = ending_manager.build_snapshot(context)\n\tchapter_manager.resolve_chapter()',
    '\tending_snapshot = ending_manager.build_snapshot(context)\n\tvar ending_id: String = str(ending_snapshot.get("ending_id", "historical_witness"))\n\tif not (save_data.get("endings", {}) is Dictionary):\n\t\tsave_data["endings"] = {}\n\t(save_data["endings"] as Dictionary)[ending_id] = ending_snapshot.duplicate(true)\n\tsave_data["latest_ending"] = ending_snapshot.duplicate(true)\n\tchapter_manager.resolve_chapter()',
)
replace_once(
    'show_boss_ability("赤兔——隨我踏破此陣！", 2.0)\n\n\nfunc end_run',
    'show_boss_ability("敵將猛攻——避開殺陣！", 2.0)\n\n\nfunc end_run',
)
replace_once(
    'draw_text("V1.7.5・戰場可讀性與Boss演出強化版", Vector2(91, 207), 15, Color8(170, 183, 173))',
    'draw_text("V2.0.0 Alpha.17・亂世終卷", Vector2(91, 207), 15, Color8(170, 183, 173))',
)

path.write_text(text, encoding="utf-8")
print("Alpha.17 ending persistence patch applied")
