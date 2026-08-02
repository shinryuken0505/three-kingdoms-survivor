from pathlib import Path
s=Path('scripts/main.gd').read_text(encoding='utf-8')
checks={
 'terrain effect helper':'func terrain_effect_at(world_pos: Vector2)',
 'terrain speed applied':'speed *= terrain_speed_multiplier(player["pos"])',
 'terrain overlay':'draw_interactive_terrain_overlay(chapter, off)',
 'portrait remaster':'func draw_remaster_portrait(character_id: String',
 'boss remaster':'draw_remaster_portrait(bid, pr, 1.0)',
 'hero candidate remaster':'draw_remaster_portrait(hid, Rect2(rect.position + Vector2(18, 18)',
}
missing=[name for name, token in checks.items() if token not in s]
if missing:
    raise SystemExit('ALPHA3_QA_FAIL: '+', '.join(missing))
print('V2_ALPHA3_QA_OK')
