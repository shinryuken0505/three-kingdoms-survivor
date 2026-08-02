from pathlib import Path

path = Path('scripts/main.gd')
text = path.read_text(encoding='utf-8')

start = text.index('func draw_replace_screen() -> void:\n')
end = text.index('\n\nfunc draw_shop_screen() -> void:', start)
replacement = '''func draw_replace_screen() -> void:
\tdraw_overlay_backdrop()
\tvar panel := Rect2(260, 100, 760, 520)
\tdraw_panel(panel, Color(0.035, 0.04, 0.041, 0.98), Color8(220, 188, 112), 2.0)
\tdraw_centered_text("主動欄已滿：請選擇替換名將", panel, 58.0, 28, Color8(239, 215, 159), true)
\tfor i in range(active_heroes.size() + 1):
\t\tvar label: String = "取消，改列後備"
\t\tif i < active_heroes.size():
\t\t\tvar hid: String = str(active_heroes[i])
\t\t\tlabel = "替換 %s Lv.%d" % [heroes[hid]["name"], hero_levels.get(hid, 1)]
\t\tvar r: Rect2 = Rect2(panel.position.x + 80, panel.position.y + 105 + i * 68, 600, 52)
\t\tdraw_panel(r, Color(0.53, 0.36, 0.14, 0.82) if i == option_index else Color(0.045, 0.05, 0.05, 0.85), Color8(220, 188, 112) if i == option_index else Color8(90, 88, 76), 1.5 if i == option_index else 1.0)
\t\tdraw_centered_text(("▶ " if i == option_index else "") + label, r, 34.0, 21, Color8(238, 226, 198), i == option_index)
'''
text = text[:start] + replacement + text[end:]

start = text.index('func draw_config_replace_screen() -> void:\n')
end = text.index('\n\nfunc camp_menu_options() -> Array[String]:', start)
replacement = '''func draw_config_replace_screen() -> void:
\tdraw_overlay_backdrop()
\tvar panel := Rect2(250, 95, 780, 530)
\tdraw_panel(panel, Color(0.035, 0.04, 0.041, 0.985), Color8(220, 188, 112), 2.0)
\tdraw_centered_text("主戰欄已滿：選擇替換名將", panel, 58.0, 29, Color8(239, 215, 159), true)
\tif config_candidate != "" and heroes.has(config_candidate):
\t\tdraw_centered_text("準備上場：%s" % heroes[config_candidate]["name"], panel, 94.0, 19, heroes[config_candidate]["color"], true)
\tfor i in range(active_heroes.size() + 1):
\t\tvar label: String = "取消替換"
\t\tif i < active_heroes.size():
\t\t\tvar hid: String = str(active_heroes[i])
\t\t\tlabel = "替換 %s Lv.%d" % [heroes[hid]["name"], hero_bond_level(hid)]
\t\tvar rect: Rect2 = Rect2(panel.position.x + 85, panel.position.y + 125 + i * 66, 610, 50)
\t\tvar selected := i == config_replace_index
\t\tdraw_panel(rect, Color(0.53, 0.36, 0.14, 0.86) if selected else Color(0.045, 0.05, 0.05, 0.86), Color8(220, 188, 112) if selected else Color8(90, 88, 76), 1.5 if selected else 1.0)
\t\tdraw_centered_text(("▶ " if selected else "") + label, rect, 33.0, 21, Color8(238, 226, 198), selected)
'''
text = text[:start] + replacement + text[end:]
path.write_text(text, encoding='utf-8')
