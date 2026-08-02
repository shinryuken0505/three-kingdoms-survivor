from pathlib import Path

path = Path('scripts/main.gd')
text = path.read_text(encoding='utf-8')

text = text.replace(
    'draw_text("章回告捷" if victory else "亂世夢斷", Vector2(640, 105), 43, Color8(237, 205, 132) if victory else Color8(209, 98, 76), true, HORIZONTAL_ALIGNMENT_CENTER, 720)',
    'draw_centered_text("章回告捷" if victory else "亂世夢斷", Rect2(root.position.x + 40, root.position.y + 22, root.size.x - 80, 62), 48.0, 43, Color8(237, 205, 132) if victory else Color8(209, 98, 76), true)'
)

text = text.replace(
    'draw_text("%s　Lv.%d" % [str(relic_defs[chapter_reward_relic]["name"]), relic_level(chapter_reward_relic)], reward_rect.position + Vector2(147, 205), 20, Color8(239, 214, 155), true, HORIZONTAL_ALIGNMENT_CENTER, 250)',
    'draw_centered_text("%s　Lv.%d" % [str(relic_defs[chapter_reward_relic]["name"]), relic_level(chapter_reward_relic)], Rect2(reward_rect.position + Vector2(18, 186), Vector2(reward_rect.size.x - 36, 38)), 27.0, 20, Color8(239, 214, 155), true)'
)

text = text.replace(
    'draw_wrapped(str(relic_defs[chapter_reward_relic].get("desc", "")), Rect2(reward_rect.position + Vector2(24, 218), Vector2(247, 48)), 12, Color8(190, 198, 190), 17.0, true)',
    'draw_wrapped(str(relic_defs[chapter_reward_relic].get("desc", "")), Rect2(reward_rect.position + Vector2(24, 224), Vector2(reward_rect.size.x - 48, 42)), 12, Color8(190, 198, 190), 17.0, true)'
)

# Keep the next-chapter hint inside the result panel instead of anchoring from screen center.
old = 'draw_text("下一章：%s｜內容已可進入" % chapter_manager.next_title(), Vector2(640, 650), 14, Color8(168, 174, 168), false, HORIZONTAL_ALIGNMENT_RIGHT, 580)'
new = 'draw_text("下一章：%s｜內容已可進入" % chapter_manager.next_title(), Vector2(root.end.x - 34, root.end.y - 18), 14, Color8(168, 174, 168), false, HORIZONTAL_ALIGNMENT_RIGHT, root.size.x - 68)'
text = text.replace(old, new)

path.write_text(text, encoding='utf-8')
