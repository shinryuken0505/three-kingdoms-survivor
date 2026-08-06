from pathlib import Path
import re

MAIN = Path("scripts/main.gd")
REPORT = Path("docs/art/alpha31_portrait_relic_modal_hotfix.md")

text = MAIN.read_text(encoding="utf-8")
original = text

# Keep this as an Alpha.31 hotfix rather than advancing the planned feature version.
text = text.replace('const GAME_VERSION: String = "V2.0.0-alpha.31"',
                    'const GAME_VERSION: String = "V2.0.0-alpha.31-hotfix.1"', 1)

# A relic notice is a blocking modal. Redraw it, but do not advance any battle,
# projectile, cooldown, spawn, boss telegraph, or chapter timers underneath it.
process_anchor = "func _process(delta: float) -> void:\n"
modal_gate = (
    "func _process(delta: float) -> void:\n"
    "\t# Alpha.31 hotfix：遺物說明為阻斷型視窗，顯示期間完整凍結戰鬥流程。\n"
    "\t# 輸入仍由 _unhandled_input 接收，因此玩家可以正常關閉提示。\n"
    "\tif not pending_relic_notice.is_empty():\n"
    "\t\tqueue_redraw()\n"
    "\t\treturn\n"
)
if "Alpha.31 hotfix：遺物說明為阻斷型視窗" not in text:
    if process_anchor not in text:
        raise RuntimeError("Could not find _process() anchor")
    text = text.replace(process_anchor, modal_gate, 1)

# Explicitly repair the two reported portrait mappings after normal asset loading.
# Both compact runtime IDs and formal aliases are covered. Never use a sprite sheet
# as a portrait fallback for these heroes.
hotfix_func = r'''

func apply_alpha31_portrait_reference_hotfix() -> void:
	var fixes: Dictionary = {
		"zhangfei": "res://assets/portraits/zhangfei_default.png",
		"zhang_fei": "res://assets/portraits/zhangfei_default.png",
		"caocao": "res://assets/portraits/caocao_default.png",
		"cao_cao": "res://assets/portraits/caocao_default.png"
	}
	for hero_id in fixes.keys():
		var portrait_path: String = str(fixes[hero_id])
		if not ResourceLoader.exists(portrait_path):
			push_warning("Alpha.31 portrait hotfix missing: %s -> %s" % [hero_id, portrait_path])
			continue
		var portrait: Resource = load(portrait_path)
		if portrait is Texture2D:
			portrait_tex[str(hero_id)] = portrait as Texture2D
		else:
			push_warning("Alpha.31 portrait hotfix is not Texture2D: %s" % portrait_path)


func validate_hero_portrait_references() -> void:
	# 開發期稽核：角色若沒有正式立繪，只記錄警告，不回退使用四格戰場 sprite strip。
	for hero_id in heroes.keys():
		var compact_id: String = str(hero_id)
		if not portrait_tex.has(compact_id) or not (portrait_tex[compact_id] is Texture2D):
			push_warning("Missing hero portrait reference: %s" % compact_id)
'''

if "func apply_alpha31_portrait_reference_hotfix()" not in text:
    # Insert before the first ordinary helper after startup; top-level placement is valid in GDScript.
    first_func = text.find("\nfunc ")
    if first_func < 0:
        raise RuntimeError("Could not find a function insertion point")
    text = text[:first_func] + hotfix_func + text[first_func:]

# Call the correction immediately after the existing asset-loading call. The regex
# tolerates load_assets() or load_all_assets() naming while avoiding a duplicate call.
if "\tapply_alpha31_portrait_reference_hotfix()" not in text:
    match = re.search(r"(?m)^(\t)(load(?:_all)?_assets\(\))\s*$", text)
    if not match:
        raise RuntimeError("Could not find asset loading call in _ready()")
    insertion = match.group(0) + "\n\tapply_alpha31_portrait_reference_hotfix()\n\tvalidate_hero_portrait_references()"
    text = text[:match.start()] + insertion + text[match.end():]

if text == original:
    raise RuntimeError("Hotfix produced no changes")

MAIN.write_text(text, encoding="utf-8")
REPORT.parent.mkdir(parents=True, exist_ok=True)
REPORT.write_text(
    """# Alpha.31 Portrait and Relic Modal Hotfix\n\n"
    "- Corrects Zhang Fei and Cao Cao portrait mappings after normal asset loading.\n"
    "- Covers compact and formal runtime IDs.\n"
    "- Prevents sprite strips from serving as their portrait fallback.\n"
    "- Adds a development-time portrait reference audit for the full hero roster.\n"
    "- Treats the relic notice as a blocking modal in `_process()`.\n"
    "- While the notice is open, enemies, bosses, shots, zones, cooldowns, spawns, and chapter timers do not advance.\n"
    "- Input and redraw remain active so the notice can be closed normally.\n"
    """,
    encoding="utf-8",
)
print("Applied Alpha.31 portrait/relic modal hotfix")
