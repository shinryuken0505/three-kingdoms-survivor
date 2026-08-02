from pathlib import Path

PATH = Path("scripts/main.gd")
text = PATH.read_text(encoding="utf-8")

preload_anchor = 'const BossLootUIScript = preload("res://scripts/ui/boss_loot_ui.gd")\n'
preload_insert = preload_anchor + (
    'const LegacyPlayerStatusAdapter = preload("res://scripts/systems/combat/legacy_player_status_adapter.gd")\n'
    'const StatusEffectManagerScript = preload("res://scripts/systems/combat/status_effect_manager.gd")\n'
    'const StatusEffectRendererScript = preload("res://scripts/ui/components/status_effect_renderer.gd")\n'
    'const StatusEffectIconPainterScript = preload("res://scripts/ui/components/status_effect_icon_painter.gd")\n'
)
if 'LegacyPlayerStatusAdapter = preload' not in text:
    if text.count(preload_anchor) != 1:
        raise SystemExit("preload anchor missing or duplicated")
    text = text.replace(preload_anchor, preload_insert, 1)

old_status_block = '''\tif float(player.get("control_lock", 0.0)) > 0.0:\n\t\tdraw_text("麻痺", HUD_RELIC_RECT.position + Vector2(242, 62), 11, Color8(245, 216, 92), true)\n\telif float(player.get("move_slow", 0.0)) > 0.0:\n\t\tdraw_text("緩速", HUD_RELIC_RECT.position + Vector2(242, 62), 11, Color8(123, 197, 231), true)\n\telif float(player.get("vision_obscure", 0.0)) > 0.0:\n\t\tdraw_text("妖煙", HUD_RELIC_RECT.position + Vector2(242, 62), 11, Color8(194, 137, 211), true)\n'''
new_status_block = '''\t# 舊欄位經 Adapter 轉為統一狀態 ViewModel，HUD 不再只顯示其中一種文字。\n\tdraw_player_status_effects()\n'''
if 'draw_player_status_effects()' not in text:
    if text.count(old_status_block) != 1:
        raise SystemExit("legacy HUD status block missing or duplicated")
    text = text.replace(old_status_block, new_status_block, 1)

function_anchor = '''func draw_panel(\n'''
function_code = '''func draw_player_status_effects() -> void:\n\tif player.is_empty():\n\t\treturn\n\tvar effects: Array = LegacyPlayerStatusAdapter.from_player(player)\n\tif effects.is_empty():\n\t\treturn\n\tvar view_models: Array[Dictionary] = StatusEffectManagerScript.to_view_model(effects)\n\tvar player_screen_position: Vector2 = world_to_screen(player.get("pos", Vector2.ZERO))\n\tfor slot in StatusEffectRendererScript.above_player_layout(player_screen_position, view_models, VIEW):\n\t\tStatusEffectIconPainterScript.draw_slot(self, slot, font)\n\tfor slot in StatusEffectRendererScript.hud_layout(view_models):\n\t\tStatusEffectIconPainterScript.draw_slot(self, slot, font)\n\n\n'''
if 'func draw_player_status_effects() -> void:' not in text:
    if text.count(function_anchor) != 1:
        raise SystemExit("draw_panel anchor missing or duplicated")
    text = text.replace(function_anchor, function_code + function_anchor, 1)

PATH.write_text(text, encoding="utf-8")
print("status HUD integration applied")
