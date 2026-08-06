from pathlib import Path

path = Path("scripts/main.gd")
text = path.read_text(encoding="utf-8")

start = text.index("func repair_all_hero_portrait_bindings() -> void:\n")
end = text.index("\n\nfunc hero_portrait(hero_id: String) -> Texture2D:\n", start)

replacement = '''func repair_all_hero_portrait_bindings() -> void:
	# Alpha.35 hotfix：招賢館與角色資訊統一採用經過既有版本驗證的
	# <compact_id>_default.png，不再引用內容可能錯置的批次生成 underscore 圖檔。
	var used_paths: Dictionary = {}
	for hero_value in heroes.keys():
		var hero_id: String = str(hero_value)
		var compact_id: String = canonical_hero_id(hero_id)
		var portrait_path: String = "res://assets/portraits/%s_default.png" % compact_id
		if not ResourceLoader.exists(portrait_path) and not FileAccess.file_exists(portrait_path):
			push_warning("Verified default portrait missing: %s -> %s" % [hero_id, portrait_path])
			portrait_tex.erase(hero_id)
			continue
		if used_paths.has(portrait_path):
			push_warning(
				"Duplicate portrait source: %s and %s -> %s"
				% [str(used_paths[portrait_path]), hero_id, portrait_path]
			)
		used_paths[portrait_path] = hero_id
		portrait_tex[hero_id] = runtime_texture(portrait_path)

	# 重要女性角色固定稽核，避免姓名正確但素材內容被錯批成男性武將。
	var required_sources: Dictionary = {
		"caiwenji": "res://assets/portraits/caiwenji_default.png",
		"diaochan": "res://assets/portraits/diaochan_default.png",
		"sunshangxiang": "res://assets/portraits/sunshangxiang_default.png",
		"daqiao": "res://assets/portraits/daqiao_default.png",
		"lvlingqi": "res://assets/portraits/lvlingqi_default.png",
		"wangyi": "res://assets/portraits/wangyi_default.png",
		"zhenji": "res://assets/portraits/zhenji_default.png"
	}
	for hero_id_value in required_sources.keys():
		var hero_id: String = str(hero_id_value)
		if heroes.has(hero_id):
			var expected_path: String = str(required_sources[hero_id])
			if not ResourceLoader.exists(expected_path) and not FileAccess.file_exists(expected_path):
				push_warning("Required female portrait missing: %s -> %s" % [hero_id, expected_path])
'''

text = text[:start] + replacement + text[end:]
text = text.replace('V2.0.0-alpha.35', 'V2.0.0-alpha.35-hotfix.2', 1)

for wrong_source in [
    '"caiwenji": "res://assets/portraits/cai_wenji.png"',
    '"diaochan": "res://assets/portraits/diao_chan.png"',
    '"sunshangxiang": "res://assets/portraits/sun_shangxiang.png"',
]:
    if wrong_source in text:
        raise SystemExit(f"wrong portrait source remains: {wrong_source}")

safe_resolver = '''func hero_portrait(hero_id: String) -> Texture2D:
	if portrait_tex.has(hero_id) and portrait_tex[hero_id] is Texture2D:
		return portrait_tex[hero_id] as Texture2D'''
if safe_resolver not in text:
    raise SystemExit("safe hero_portrait resolver not found")

path.write_text(text, encoding="utf-8")

report = Path("docs/art/alpha35_portrait_source_hotfix_report.md")
report.write_text(
    """# Alpha.35 Portrait Source Hotfix\n\n"
    "- All recruit and hero-card portraits now resolve through `<canonical_id>_default.png`.\n"
    "- Cai Wenji, Diao Chan and Sun Shangxiang no longer use the incorrect underscore portrait batch.\n"
    "- Da Qiao, Lu Lingqi, Wang Yi and Zhen Ji are included in the required female-source audit.\n"
    "- Missing and duplicate portrait sources emit explicit warnings.\n"
    "- Battlefield sprite fallback remains forbidden.\n\n"
    "Automated checks validate paths and bindings; final visual identity still requires in-game review.\n"
    """,
    encoding="utf-8",
)
