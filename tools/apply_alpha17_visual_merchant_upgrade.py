from __future__ import annotations

from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
MAIN = ROOT / "scripts/main.gd"


def replace_once(text: str, old: str, new: str, label: str) -> str:
    if new in text:
        return text
    if old not in text:
        raise SystemExit(f"missing patch target: {label}")
    return text.replace(old, new, 1)


def patch_main() -> None:
    text = MAIN.read_text(encoding="utf-8")

    text = replace_once(
        text,
        'var total_count: int = item_count + 1\n',
        'var total_count: int = item_count + 2\n',
        "shop action count",
    )
    text = replace_once(
        text,
        'var leave_index: int = item_count\n\t# 商品採雙欄；最後的「離開」視為獨立整列。上下移動會優先保持原欄位。',
        'var equipment_index: int = item_count\n\tvar leave_index: int = item_count + 1\n\t# 商品採雙欄；底部提供「裝備整備」與「離開行商」兩個固定操作。',
        "shop footer indexes",
    )
    text = replace_once(
        text,
        'if option_index == leave_index:\n\t\t\toption_index = max(0, item_count - 1)',
        'if option_index >= equipment_index:\n\t\t\toption_index = max(0, item_count - 1)',
        "shop left footer",
    )
    text = replace_once(
        text,
        'if option_index == leave_index:\n\t\t\toption_index = min(1, max(0, item_count - 1))',
        'if option_index == equipment_index:\n\t\t\toption_index = leave_index\n\t\telif option_index == leave_index:\n\t\t\toption_index = equipment_index',
        "shop right footer",
    )
    text = replace_once(
        text,
        'if option_index == leave_index:\n\t\t\tvar last_row_start: int = max(0, item_count - (2 if item_count % 2 == 0 else 1))',
        'if option_index >= equipment_index:\n\t\t\tvar last_row_start: int = max(0, item_count - (2 if item_count % 2 == 0 else 1))',
        "shop up footer",
    )
    text = replace_once(
        text,
        'if option_index == leave_index:\n\t\t\treturn true\n\t\tvar next_index: int = option_index + columns\n\t\toption_index = next_index if next_index < item_count else leave_index',
        'if option_index >= equipment_index:\n\t\t\treturn true\n\t\tvar next_index: int = option_index + columns\n\t\toption_index = next_index if next_index < item_count else equipment_index',
        "shop down footer",
    )
    text = replace_once(
        text,
        '\t\t"shop":\n\t\t\tcount = shop_choices.size() + 1',
        '\t\t"shop":\n\t\t\tcount = shop_choices.size() + 2',
        "shop option count",
    )

    old_choose = '''func choose_shop(index: int) -> void:\n\tif index >= shop_choices.size():\n\t\tscreen = "game"\n\t\tplay_current_battle_bgm()\n\t\treturn\n\tvar item: Dictionary = shop_choices[index]'''
    new_choose = '''func choose_shop(index: int) -> void:\n\tvar item_count: int = shop_choices.size()\n\tif index == item_count:\n\t\tprevious_screen = "shop"\n\t\tscreen = "tab"\n\t\ttab_page = 1\n\t\ttab_index = 0\n\t\ttab_scroll = 0\n\t\tplay_sfx("ui_confirm")\n\t\treturn\n\tif index > item_count:\n\t\tscreen = "game"\n\t\tplay_current_battle_bgm()\n\t\treturn\n\tvar item: Dictionary = shop_choices[index]'''
    text = replace_once(text, old_choose, new_choose, "shop equipment action")

    old_close = '''\tmerchant_visit += 1\n\tmerchant_active = false\n\tmerchant_stock.clear()\n\tmerchant_equipment_stock.clear()\n\tmerchant_spawn_timer = rng.randf_range(65.0, 88.0)\n\tscreen = "game"\n\tplay_current_battle_bgm()\n\tshow_message("%s收拾貨物，前往下一處落腳。" % str(merchant_defs.get(merchant_kind, {}).get("name", "商人")), 2.5)'''
    new_close = '''\tmerchant_visit += 1\n\tvar purchased_id: String = str(item.get("id", ""))\n\tif str(item.get("type", "relic")) == "equipment":\n\t\tmerchant_equipment_stock.erase(purchased_id)\n\telse:\n\t\tmerchant_stock.erase(purchased_id)\n\tshop_choices.remove_at(index)\n\toption_index = clampi(index, 0, shop_choices.size() + 1)\n\tscreen = "shop"\n\tplay_bgm("merchant")\n\tshow_message("交易完成，可繼續選購或前往裝備整備。", 2.4)'''
    text = replace_once(text, old_close, new_close, "merchant multi-buy")

    text = replace_once(
        text,
        '\t\t\t\t\t"life": 0.22,\n\t\t\t\t\t"max_life": 0.22,\n\t\t\t\t\t"color": Color8(244, 211, 126)',
        '\t\t\t\t\t"life": 0.34,\n\t\t\t\t\t"max_life": 0.34,\n\t\t\t\t\t"color": Color8(255, 224, 132)',
        "player slash visibility",
    )
    text = replace_once(
        text,
        '\t\t\t)\n\t\t"bow":',
        '\t\t\t)\n\t\t\tspawn_ring(attack_origin + dir * 24.0, Color8(255, 226, 145), 46.0, 0.24)\n\t\t\tscreen_shake = max(screen_shake, 3.2)\n\t\t"bow":',
        "player slash impact",
    )

    marker = 'func add_damage_number(entry: Dictionary) -> void:\n'
    if 'func emphasize_damage_number(entry: Dictionary)' not in text:
        helper = '''func emphasize_damage_number(entry: Dictionary) -> Dictionary:\n\tvar result: Dictionary = entry.duplicate(true)\n\tvar raw_text: String = str(result.get("text", "0"))\n\tvar numeric_text: String = raw_text.replace("!", "").replace("+", "").replace("-", "")\n\tvar amount: float = float(numeric_text) if numeric_text.is_valid_float() else 0.0\n\tvar critical: bool = raw_text.contains("!")\n\tresult["life"] = max(float(result.get("life", 0.72)), 0.92 if critical else 0.78)\n\tresult["size"] = max(float(result.get("size", 18.0)), 29.0 if critical else (24.0 if amount >= 40.0 else 20.0))\n\tresult["outline"] = max(float(result.get("outline", 2.0)), 4.0 if critical else 3.0)\n\treturn result\n\n\n'''
        text = text.replace(marker, helper + marker, 1)
    text = replace_once(
        text,
        '\tdamage_numbers.append(entry)\n',
        '\tdamage_numbers.append(emphasize_damage_number(entry))\n',
        "damage number emphasis",
    )

    load_marker = '\tfor id in boss_ids:\n\t\tportrait_tex[id] = runtime_texture("res://assets/portraits/%s_default.png" % id)\n\t\tsprite_tex[id] = runtime_texture("res://assets/sprites/%s_default.png" % id)\n'
    load_new = load_marker + '\tapply_character_art_fallbacks()\n'
    text = replace_once(text, load_marker, load_new, "character art fallback call")

    if 'func apply_character_art_fallbacks() -> void:' not in text:
        insertion = '''\n\nfunc apply_character_art_fallbacks() -> void:\n\t# 部分早期立繪檔實際為其他角色的複本。優先使用本輪由小人重製的角色卡，\n\t# 並在缺圖時退回同 ID 小人，避免名稱、Boss 與圖像錯位。\n\tvar fallback_ids: Array[String] = [\n\t\t"huangzhong", "huatuo", "fazheng", "chengong", "simayi", "caocao",\n\t\t"taishici", "luxun", "zhouyu", "sunjian", "xiahouyuan", "xiahouen",\n\t\t"zhangfei", "weiyan", "zhanghe", "jiangwei", "zhangliao", "caoren"\n\t]\n\tfor character_id in fallback_ids:\n\t\tvar remastered_path: String = "res://assets/portraits_remastered/%s_default.png" % character_id\n\t\tvar remastered: Texture2D = runtime_texture(remastered_path)\n\t\tif remastered != null:\n\t\t\tportrait_tex[character_id] = remastered\n\t\telif sprite_tex.has(character_id) and sprite_tex[character_id] != null:\n\t\t\tportrait_tex[character_id] = sprite_tex[character_id]\n\n\n'''
        text = text.replace('\n\nfunc refresh_all_skins() -> void:', insertion + 'func refresh_all_skins() -> void:', 1)

    MAIN.write_text(text, encoding="utf-8")


def main() -> None:
    patch_main()
    print("[PASS] alpha17 visual and merchant patch applied")


if __name__ == "__main__":
    main()
