from pathlib import Path

path = Path('scripts/main.gd')
text = path.read_text(encoding='utf-8')

text = text.replace(
    'const Alpha31TelegraphShapes = preload("res://scripts/systems/boss/alpha31_telegraph_shapes.gd")',
    'const Alpha31TelegraphShapes = preload("res://scripts/systems/boss/alpha31_telegraph_shapes.gd")\nconst Alpha32BossHitboxSync = preload("res://scripts/systems/boss/alpha32_boss_hitbox_sync.gd")'
)
text = text.replace('V2.0.0-alpha.31-hotfix.1', 'V2.0.0-alpha.32')
text = text.replace('V2.0.0-alpha.31', 'V2.0.0-alpha.32')

old = '''\tif remaining <= 0.0:\n\t\tboss_ability_banner["warning"] = false\n\t\tboss_special_attack()'''
new = '''\tif remaining <= 0.0:\n\t\tboss_ability_banner["warning"] = false\n\t\tvar player_pos: Vector2 = player.get("pos", Vector2.ZERO) as Vector2\n\t\tif Alpha32BossHitboxSync.contains_point(boss, player_pos):\n\t\t\tboss_special_attack()\n\t\telse:\n\t\t\tspawn_ring(player_pos, Color8(110, 196, 142), 38.0, 0.28)\n\t\t\tshow_message("成功閃避 %s" % alpha30_boss_skill_name(), 1.1)'''
if old not in text:
    raise SystemExit('Alpha.30 telegraph release block not found')
text = text.replace(old, new, 1)

path.write_text(text, encoding='utf-8')

report = Path('docs/art/alpha32_boss_hitbox_sync_report.md')
report.write_text('''# Alpha.32 Boss Hitbox Sync\n\n- Boss special release now checks the same locked telegraph profile used by the warning visual.\n- Circle, multi-circle, line and sector geometry share one resolver.\n- Players outside the displayed shape do not trigger the special attack.\n- A small edge tolerance avoids unfair pixel-perfect boundary hits.\n- Successful dodges receive a short green ring and message.\n\nManual QA remains required for every boss and difficulty.\n''', encoding='utf-8')
