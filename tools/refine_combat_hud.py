from pathlib import Path

path = Path("scripts/main.gd")
text = path.read_text(encoding="utf-8")


def replace_once(old: str, new: str) -> None:
    global text
    if old not in text:
        raise SystemExit(f"missing patch target: {old[:120]!r}")
    text = text.replace(old, new, 1)

replace_once(
    'const HUD_RELIC_RECT: Rect2 = Rect2(12.0, 12.0, 324.0, 132.0)\nconst HUD_HEADER_RECT: Rect2 = Rect2(360.0, 12.0, 680.0, 72.0)\nconst HUD_BOSS_RECT: Rect2 = Rect2(390.0, 91.0, 620.0, 66.0)\nconst HUD_MINIMAP_RECT: Rect2 = Rect2(1088.0, 12.0, 174.0, 116.0)\nconst HUD_PLAYER_RECT: Rect2 = Rect2(-500.0, -500.0, 1.0, 1.0)\nconst HUD_HERO_RAIL_RECT: Rect2 = Rect2(210.0, 638.0, 840.0, 58.0)\nconst HUD_MESSAGE_Y: float = 594.0',
    'const HUD_RELIC_RECT: Rect2 = Rect2(12.0, 12.0, 324.0, 132.0)\nconst HUD_HEADER_RECT: Rect2 = Rect2(360.0, 12.0, 680.0, 72.0)\nconst HUD_BOSS_RECT: Rect2 = Rect2(390.0, 91.0, 620.0, 66.0)\nconst HUD_MINIMAP_RECT: Rect2 = Rect2(1088.0, 12.0, 174.0, 116.0)\nconst HUD_PLAYER_RECT: Rect2 = Rect2(84.0, 630.0, 202.0, 66.0)\nconst HUD_HERO_RAIL_RECT: Rect2 = Rect2(76.0, 624.0, 1128.0, 76.0)\nconst HUD_MESSAGE_Y: float = 580.0'
)

old_ability = '''\t# Boss大招才使用血條下方的中央警示，與主動名將頭上喊招分流。\n\tif not boss_ability_banner.is_empty() and not boss.is_empty():\n\t\tvar ability_alpha: float = clamp(float(boss_ability_banner.get("life", 0.0)) / max(0.01, float(boss_ability_banner.get("max_life", 1.0))), 0.0, 1.0)\n\t\tvar ability_text: String = str(boss_ability_banner.get("text", "敵將絕技！"))\n\t\tvar ability_rect: Rect2 = Rect2(440, HUD_BOSS_RECT.end.y + 7.0, 520, 35)\n\t\tdraw_panel(ability_rect, Color(0.12, 0.018, 0.018, 0.90 * ability_alpha), Color(0.95, 0.27, 0.18, ability_alpha), 1.6)\n\t\tdraw_centered_text(ability_text, ability_rect, 22.0, 17, Color(1.0, 0.88, 0.72, ability_alpha), true)\n\t\tvar ability_progress: float = 1.0 - ability_alpha\n\t\tvar ability_track: Rect2 = Rect2(ability_rect.position + Vector2(12, ability_rect.size.y - 6), Vector2(ability_rect.size.x - 24, 3))\n\t\tdraw_rect(ability_track, Color(0.25, 0.06, 0.04, 0.9), true)\n\t\tdraw_rect(Rect2(ability_track.position, Vector2(ability_track.size.x * ability_progress, ability_track.size.y)), Color(1.0, 0.42, 0.18, ability_alpha), true)\n'''
new_ability = '''\t# Boss台詞統一依附在血條正下方，避免飄到畫面角落或遮住戰場。\n\tif not boss_ability_banner.is_empty() and not boss.is_empty():\n\t\tvar ability_alpha: float = clamp(float(boss_ability_banner.get("life", 0.0)) / max(0.01, float(boss_ability_banner.get("max_life", 1.0))), 0.0, 1.0)\n\t\tvar ability_text: String = str(boss_ability_banner.get("text", "敵將絕技！"))\n\t\tvar ability_rect: Rect2 = Rect2(HUD_BOSS_RECT.position.x, HUD_BOSS_RECT.end.y + 5.0, HUD_BOSS_RECT.size.x, 42.0)\n\t\tdraw_panel(ability_rect, Color(0.10, 0.012, 0.012, 0.94 * ability_alpha), Color(0.96, 0.30, 0.18, ability_alpha), 1.8)\n\t\tdraw_text("敵將絕技", ability_rect.position + Vector2(14, 17), 11, Color(1.0, 0.62, 0.35, ability_alpha), true)\n\t\tdraw_text(ability_text, ability_rect.position + Vector2(92, 27), 17, Color(1.0, 0.90, 0.74, ability_alpha), true, HORIZONTAL_ALIGNMENT_CENTER, ability_rect.size.x - 116.0)\n\t\tvar ability_progress: float = 1.0 - ability_alpha\n\t\tvar ability_track: Rect2 = Rect2(ability_rect.position + Vector2(14, ability_rect.size.y - 6), Vector2(ability_rect.size.x - 28, 3))\n\t\tdraw_rect(ability_track, Color(0.25, 0.05, 0.035, 0.92), true)\n\t\tdraw_rect(Rect2(ability_track.position, Vector2(ability_track.size.x * ability_progress, ability_track.size.y)), Color(1.0, 0.43, 0.18, ability_alpha), true)\n'''
replace_once(old_ability, new_ability)

rail_start = text.index('\t# 中下：主動名將採低高度技能列，保留戰場視野。\n')
rail_end = text.index('\n\t# 主動名將施放時改為角色頭上的小型喊招', rail_start)
new_rail = r'''	# 下方軍陣列：主角、主戰名將與全部後備被動名將集中呈現。
	draw_panel(HUD_HERO_RAIL_RECT, Color(0.014, 0.020, 0.021, 0.88), Color(0.45, 0.39, 0.27, 0.75), 1.2)

	# 主角狀態卡。
	var player_card: Rect2 = Rect2(HUD_HERO_RAIL_RECT.position + Vector2(8, 7), Vector2(198, 62))
	draw_panel(player_card, Color(0.055, 0.047, 0.034, 0.96), identities[chosen_identity]["color"], 1.5)
	var player_portrait: Rect2 = Rect2(player_card.position + Vector2(5, 5), Vector2(44, 52))
	draw_texture_contain(portrait_tex[chosen_identity], player_portrait)
	draw_text("主角｜%s Lv.%d" % [identities[chosen_identity]["name"], int(player["level"])], player_card.position + Vector2(56, 19), 12, Color8(241, 222, 175), true, HORIZONTAL_ALIGNMENT_LEFT, 134)
	var player_hp_track: Rect2 = Rect2(player_card.position + Vector2(56, 25), Vector2(128, 7))
	draw_rect(player_hp_track, Color8(55, 37, 34), true)
	draw_rect(Rect2(player_hp_track.position, Vector2(player_hp_track.size.x * hp_ratio_hud, player_hp_track.size.y)), Color8(190, 61, 55), true)
	draw_text("HP %d/%d　盾 %d" % [int(player["hp"]), int(player["max_hp"]), int(player["shield"])], player_card.position + Vector2(56, 44), 10, Color8(207, 213, 202))
	draw_text("閃避 %s" % ("READY" if dodge_left_hud <= 0.0 else "%.1fs" % dodge_left_hud), player_card.position + Vector2(56, 57), 9, Color8(126, 218, 225) if dodge_left_hud <= 0.0 else Color8(205, 178, 126), true)

	# 主戰技能卡。
	var active_origin_x: float = player_card.end.x + 8.0
	var active_area_w: float = 560.0
	var slot_count: int = max(1, active_limit())
	var active_gap: float = 5.0
	var active_card_w: float = (active_area_w - active_gap * float(slot_count - 1)) / float(slot_count)
	for i in range(slot_count):
		var card: Rect2 = Rect2(active_origin_x + i * (active_card_w + active_gap), HUD_HERO_RAIL_RECT.position.y + 7.0, active_card_w, 62.0)
		if i < active_heroes.size():
			var hero_id: String = str(active_heroes[i])
			draw_panel(card, Color(0.045, 0.052, 0.055, 0.96), heroes[hero_id]["color"], 1.4)
			draw_texture_contain(portrait_tex[hero_id], Rect2(card.position + Vector2(4, 5), Vector2(40, 50)))
			var text_x: float = card.position.x + 48.0
			var text_w: float = max(42.0, card.size.x - 53.0)
			draw_text("%d｜%s" % [i + 1, heroes[hero_id]["name"]], Vector2(text_x, card.position.y + 18), 11, Color8(239, 224, 187), true, HORIZONTAL_ALIGNMENT_LEFT, text_w)
			var cooldown: float = float(hero_cooldowns.get(hero_id, 0.0))
			var cd_ratio: float = clamp(cooldown / max(0.01, hero_cooldown_value(hero_id)), 0.0, 1.0)
			var track: Rect2 = Rect2(text_x, card.position.y + 27, text_w - 3.0, 6)
			draw_rect(track, Color8(47, 52, 51), true)
			draw_rect(Rect2(track.position, Vector2(track.size.x * (1.0 - cd_ratio), track.size.y)), Color8(117, 190, 132) if cooldown <= 0.0 else Color8(194, 151, 79), true)
			draw_text("可施放" if cooldown <= 0.0 else "%.1fs" % cooldown, Vector2(text_x, card.position.y + 48), 9, Color8(150, 220, 160) if cooldown <= 0.0 else Color8(205, 181, 133), false, HORIZONTAL_ALIGNMENT_LEFT, text_w)
		else:
			draw_panel(card, Color(0.035, 0.041, 0.043, 0.82), Color8(73, 78, 74), 1.0)
			draw_centered_text("主戰空位", card, 38.0, 10, Color8(117, 123, 117))

	# 後備被動名將列。所有已編入後備者都納入，超過可視寬度時壓縮尺寸。
	var reserve_origin_x: float = active_origin_x + active_area_w + 10.0
	var reserve_area: Rect2 = Rect2(reserve_origin_x, HUD_HERO_RAIL_RECT.position.y + 6.0, HUD_HERO_RAIL_RECT.end.x - reserve_origin_x - 8.0, 64.0)
	draw_text("後備被動 %d/%d" % [reserve_heroes.size(), reserve_limit()], reserve_area.position + Vector2(2, 12), 9, Color8(186, 194, 181), true)
	var reserve_count: int = reserve_heroes.size()
	if reserve_count == 0:
		draw_text("尚無後備名將", reserve_area.position + Vector2(2, 39), 10, Color8(112, 120, 113))
	else:
		var reserve_gap: float = 3.0
		var reserve_icon_w: float = clamp((reserve_area.size.x - reserve_gap * float(max(0, reserve_count - 1))) / float(reserve_count), 28.0, 47.0)
		for i in range(reserve_count):
			var reserve_id: String = str(reserve_heroes[i])
			var reserve_card: Rect2 = Rect2(reserve_area.position.x + i * (reserve_icon_w + reserve_gap), reserve_area.position.y + 17.0, reserve_icon_w, 44.0)
			draw_panel(reserve_card, Color(0.032, 0.039, 0.040, 0.94), Color(heroes[reserve_id]["color"], 0.72), 1.0)
			draw_texture_contain(portrait_tex[reserve_id], Rect2(reserve_card.position + Vector2(3, 3), Vector2(reserve_card.size.x - 6, 28)))
			var short_name: String = str(heroes[reserve_id]["name"])
			draw_text(short_name, reserve_card.position + Vector2(1, 40), 8, Color8(206, 211, 199), true, HORIZONTAL_ALIGNMENT_CENTER, reserve_card.size.x - 2)
'''
text = text[:rail_start] + new_rail + text[rail_end:]

path.write_text(text, encoding="utf-8")
print("combat HUD refined")
