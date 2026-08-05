from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
path = ROOT / "scripts/main.gd"
text = path.read_text(encoding="utf-8")

old = '''\tfor choice_value in level_choices:\n\t\tvar choice: Dictionary = choice_value\n\t\tvar skill_id: String = str(choice.get("id", choice.get("skill", "")))\n\t\tif Alpha19BuildRules.skill_allowed(str(player.get("weapon", "blade")), skill_id, skill_levels):\n\t\t\tfiltered.append(choice)\n'''

new = '''\tfor choice_value in level_choices:\n\t\tvar skill_id: String = ""\n\t\tif choice_value is Dictionary:\n\t\t\tvar choice: Dictionary = choice_value\n\t\t\tskill_id = str(choice.get("id", choice.get("skill", "")))\n\t\telif choice_value is String or choice_value is StringName:\n\t\t\tskill_id = str(choice_value)\n\t\telse:\n\t\t\t# 未知格式不應讓升級畫面當機；保留選項交由原流程處理。\n\t\t\tfiltered.append(choice_value)\n\t\t\tcontinue\n\t\tif Alpha19BuildRules.skill_allowed(str(player.get("weapon", "blade")), skill_id, skill_levels):\n\t\t\tfiltered.append(choice_value)\n'''

if old not in text:
    if "var choice: Dictionary = choice_value" in text:
        raise SystemExit("level-choice block changed; manual inspection required")
    print("Alpha.20 level-choice type fix already applied")
else:
    text = text.replace(old, new, 1)
    path.write_text(text, encoding="utf-8")
    print("Alpha.20 level-choice type fix applied")
