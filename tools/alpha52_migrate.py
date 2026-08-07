from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    p = Path(path)
    text = p.read_text(encoding="utf-8")
    if new in text:
        return
    # Migration 可能在同一 feature branch 被重跑；舊 anchor 已被先前 bot commit 消耗時直接略過。
    if old not in text:
        return
    p.write_text(text.replace(old, new, 1), encoding="utf-8")


def main() -> None:
    replace_once("project.godot", "V2.0.0-alpha.51", "V2.0.0-alpha.52")
    replace_once("scripts/main.gd", 'const GAME_VERSION: String = "V2.0.0-alpha.51"', 'const GAME_VERSION: String = "V2.0.0-alpha.52"')
    replace_once("scripts/core/alpha48_runtime_coordinator.gd", 'const TARGET_VERSION := "V2.0.0-alpha.51"', 'const TARGET_VERSION := "V2.0.0-alpha.52"')
    replace_once("scripts/main.gd", "\tskill_defs = GameData.skills()", "\tskill_defs = PlayerUpgradeService.install_signature_definitions(GameData.skills())")
    replace_once("scripts/main.gd", 'func identity_order() -> Array:\n\treturn ["swordsman", "hunter", "poisoner", "heroine"]', 'func identity_order() -> Array:\n\treturn ["swordsman", "archer", "strategist"]')
    replace_once("scripts/main.gd", 'if identity_id == "hunter":\n\t\tplayer["pierce"] = 1\n\t\tskill_levels["projectile"] = 1\n\telif identity_id == "poisoner":', 'if identity_id in ["hunter", "archer"]:\n\t\tplayer["pierce"] = 1\n\t\tskill_levels["projectile"] = 1\n\telif identity_id in ["poisoner", "strategist"]:')
    replace_once("scripts/main.gd", 'var r: Rect2 = Rect2(48 + i * 303, 122, 278, 500)', 'var r: Rect2 = Rect2(48 + i * 401, 122, 376, 500)')
    replace_once("scripts/main.gd", 'var pr: Rect2 = Rect2(r.position + Vector2(22, 22), Vector2(234, 260))', 'var pr: Rect2 = Rect2(r.position + Vector2(22, 22), Vector2(332, 240))')
    replace_once("scripts/main.gd", 'draw_text(data["name"], r.position + Vector2(22, 320), 27, data["color"], true)', 'draw_text(data["name"], r.position + Vector2(22, 300), 27, data.get("color", Color8(222, 203, 150)), true)')
    replace_once("scripts/main.gd", 'r.position + Vector2(22, 354),', 'r.position + Vector2(22, 336),')
    replace_once("scripts/main.gd", 'Rect2(r.position + Vector2(22, 370), Vector2(234, 94)),', 'Rect2(r.position + Vector2(22, 355), Vector2(332, 66)),')
    replace_once("scripts/main.gd", '\t\tdraw_text(\n\t\t\t"武器：%s" % weapon_display_name(str(data["weapon"])),\n\t\t\tr.position + Vector2(22, 476),', '\t\tdraw_text("專屬：%s" % PlayerUpgradeService.passive_name(id), r.position + Vector2(22, 438), 15, Color8(169, 213, 185), true, HORIZONTAL_ALIGNMENT_LEFT, 332)\n\t\tdraw_text(\n\t\t\t"武器：%s" % weapon_display_name(str(data["weapon"])),\n\t\t\tr.position + Vector2(22, 476),')
    replace_once("scripts/main.gd", 'draw_text("流派共鳴：%s｜%s（%d）" % [build_now["name"], build_resonance_stage_name(build_resonance_stage(int(build_now["score"]))), build_now["score"]], Vector2(100, 425), 19, build_now["color"], true)', 'draw_text("戰術共鳴：%s｜%s（%d）" % [build_now["name"], build_resonance_stage_name(build_resonance_stage(int(build_now["score"]))), build_now["score"]], Vector2(100, 425), 19, build_now["color"], true)\n\tdraw_text("主角專屬：%s" % PlayerUpgradeService.passive_name(chosen_identity), Vector2(100, 468), 17, Color8(176, 218, 188), true)\n\tdraw_wrapped("專屬進化：%s" % PlayerUpgradeService.signature_summary(chosen_identity, skill_levels), Rect2(100, 492, 1020, 54), 16, Color8(205, 211, 202), 23.0)')
    replace_once("scripts/main.gd", 'func weapon_display_name(id: String) -> String:\n\tmatch id:', 'func identity_visual_id(id: String) -> String:\n\tif id == "archer" and (not portrait_tex.has(id) or not sprite_tex.has(id)):\n\t\treturn "hunter"\n\tif id == "strategist" and (not portrait_tex.has(id) or not sprite_tex.has(id)):\n\t\treturn "poisoner"\n\treturn id\n\n\nfunc weapon_display_name(id: String) -> String:\n\tmatch id:')
    replace_once("scripts/main.gd", '\t\t"rings":\n\t\t\treturn "紅袖環刃"', '\t\t"rings":\n\t\t\treturn "紅袖環刃"\n\t\t"talisman":\n\t\t\treturn "符籙法器"')
    replace_once("scripts/main.gd", 'draw_texture_contain(hero_portrait(str(id)), pr)', 'draw_texture_contain(hero_portrait(identity_visual_id(id)), pr)')
    replace_once("scripts/main.gd", 'draw_sprite_pose(sprite_tex[chosen_identity], pp + player_offset, PLAYER_SPRITE_SCALE, int(elapsed * 8.0) % 4, pm, player_rotation, player_stretch)', 'draw_sprite_pose(sprite_tex[identity_visual_id(chosen_identity)], pp + player_offset, PLAYER_SPRITE_SCALE, int(elapsed * 8.0) % 4, pm, player_rotation, player_stretch)')
    replace_once("scripts/main.gd", 'draw_wrapped(build_bonus_description(), Rect2(100, 448, 1020, 46), 16, Color8(196, 207, 193), 22.0)', 'draw_wrapped(build_bonus_description(), Rect2(100, 446, 1020, 40), 15, Color8(196, 207, 193), 20.0)')
    replace_once("scripts/main.gd", 'Vector2(100, 468), 17,', 'Vector2(100, 490), 17,')
    replace_once("scripts/main.gd", 'Rect2(100, 492, 1020, 54), 16,', 'Rect2(100, 514, 1020, 38), 15,')
    replace_once("scripts/main.gd", 'Vector2(100, 505), 18,', 'Vector2(100, 566), 17,')
    replace_once("scripts/main.gd", 'draw_text("戰績", Vector2(100, 545), 23,', 'draw_text("戰績", Vector2(100, 596), 20,')
    replace_once("scripts/main.gd", 'Vector2(100, 585),\n\t\t18,', 'Vector2(100, 624),\n\t\t15,')
    replace_once("scripts/main.gd", 'chosen_identity == "hunter"', 'chosen_identity in ["hunter", "archer"]')
    replace_once("scripts/main.gd", 'chosen_identity == "poisoner" or reserve_heroes.has("zhangjiao")', 'chosen_identity in ["poisoner", "strategist"] or reserve_heroes.has("zhangjiao")')
    replace_once("scripts/main.gd", '\telif chosen_identity == "poisoner":\n\t\tscores["poison"] += 2', '\telif chosen_identity in ["poisoner", "strategist"]:\n\t\tscores["poison"] += 2')

    main_text = Path("scripts/main.gd").read_text(encoding="utf-8")
    required = [
        'V2.0.0-alpha.52',
        'return ["swordsman", "archer", "strategist"]',
        "PlayerUpgradeService.install_signature_definitions",
        "PlayerUpgradeService.passive_name(id)",
        "PlayerUpgradeService.signature_summary(chosen_identity, skill_levels)",
        "戰術共鳴",
        "func identity_visual_id",
        'return "符籙法器"',
        'sprite_tex[identity_visual_id(chosen_identity)]',
        'chosen_identity in ["poisoner", "strategist"]',
    ]
    for token in required:
        if token not in main_text:
            raise SystemExit("missing Alpha.52 main integration token: " + token)
    print("Alpha.52 protagonist upgrade migration checks passed")


if __name__ == "__main__":
    main()
