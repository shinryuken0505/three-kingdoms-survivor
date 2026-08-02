from pathlib import Path

path = Path("scripts/main.gd")
text = path.read_text(encoding="utf-8")

preload_anchor = 'const EndingManagerScript = preload("res://scripts/systems/ending/ending_manager.gd")\n'
preloads = (
    preload_anchor
    + 'const EndingUIScript = preload("res://scripts/ui/ending_ui.gd")\n'
    + 'const BossLootUIScript = preload("res://scripts/ui/boss_loot_ui.gd")\n'
)
if 'const EndingUIScript' not in text:
    if preload_anchor not in text:
        raise SystemExit("preload anchor not found")
    text = text.replace(preload_anchor, preloads, 1)


def replace_function(name: str, next_name: str, body: str) -> None:
    global text
    start_token = f"func {name}"
    next_token = f"\n\nfunc {next_name}"
    start = text.find(start_token)
    if start < 0:
        raise SystemExit(f"missing function {name}")
    end = text.find(next_token, start)
    if end < 0:
        raise SystemExit(f"missing next function {next_name}")
    text = text[:start] + body.rstrip() + text[end:]

replace_function(
    "draw_ending_screen() -> void:",
    "draw_boss_loot_screen() -> void:",
    '''func draw_ending_screen() -> void:
	EndingUIScript.draw(self, ending_snapshot)
''',
)

replace_function(
    "draw_boss_loot_screen() -> void:",
    "draw_result_screen() -> void:",
    '''func draw_boss_loot_screen() -> void:
	BossLootUIScript.draw(self, pending_boss_loot)
''',
)

path.write_text(text, encoding="utf-8")
print("ending and boss loot renderers extracted")
