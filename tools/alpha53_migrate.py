from pathlib import Path


def replace_once(path: str, old: str, new: str, marker: str | None = None) -> None:
    p = Path(path)
    text = p.read_text(encoding="utf-8")
    if marker and marker in text:
        return
    if new in text:
        return
    if old not in text:
        raise SystemExit(f"missing Alpha.53 anchor in {path}: {old[:100]!r}")
    p.write_text(text.replace(old, new, 1), encoding="utf-8")


def replace_version(path: str) -> None:
    p = Path(path)
    text = p.read_text(encoding="utf-8")
    if "V2.0.0-alpha.53" in text:
        return
    if "V2.0.0-alpha.52" not in text:
        raise SystemExit(f"missing Alpha.52 version anchor in {path}")
    p.write_text(text.replace("V2.0.0-alpha.52", "V2.0.0-alpha.53"), encoding="utf-8")


def main() -> None:
    replace_version("project.godot")
    replace_version("scripts/main.gd")
    replace_version("scripts/core/alpha48_runtime_coordinator.gd")

    replace_once(
        "scripts/main.gd",
        'const PlayerSignaturePassiveService = preload("res://scripts/systems/player/player_signature_passive_service.gd")',
        'const PlayerSignaturePassiveService = preload("res://scripts/systems/player/player_signature_passive_service.gd")\nconst StatusEffectService = preload("res://scripts/systems/combat/status_effect_service.gd")',
        'const StatusEffectService = preload("res://scripts/systems/combat/status_effect_service.gd")',
    )

    replace_once(
        "scripts/main.gd",
        '\t\t\t"poison": 0.0,\n\t\t\t"poison_time": 0.0,\n\t\t\t"poison_tick": 0.0,\n\t\t\t"slow": 0.0,\n\t\t\t"stun": 0.0,\n\t\t\t"charm": 0.0,\n\t\t\t"marked": 0.0,\n\t\t\t"armor_break": 0.0,',
        '\t\t\t"poison": 0.0,\n\t\t\t"poison_time": 0.0,\n\t\t\t"poison_tick": 0.0,\n\t\t\t"burn": 0.0,\n\t\t\t"burn_time": 0.0,\n\t\t\t"burn_tick": 0.0,\n\t\t\t"burn_stacks": 0,\n\t\t\t"slow": 0.0,\n\t\t\t"stun": 0.0,\n\t\t\t"confuse": 0.0,\n\t\t\t"charm": 0.0,\n\t\t\t"marked": 0.0,\n\t\t\t"armor_break": 0.0,\n\t\t\t"status_effects": {},',
        '"status_effects": {},',
    )

    old_enemy_tick = '''\t\te["contact_cd"] = max(0.0, float(e["contact_cd"]) - delta)\n\t\te["shoot_cd"] = max(0.0, float(e["shoot_cd"]) - delta)\n\t\te["ability_cd"] = max(0.0, float(e.get("ability_cd", 0.0)) - delta)\n\t\te["telegraph"] = max(0.0, float(e["telegraph"]) - delta)\n\t\te["slow"] = max(0.0, float(e["slow"]) - delta)\n\t\te["stun"] = max(0.0, float(e["stun"]) - delta)\n\t\te["charm"] = max(0.0, float(e["charm"]) - delta)\n\t\te["marked"] = max(0.0, float(e["marked"]) - delta)\n\t\te["armor_break"] = max(0.0, float(e["armor_break"]) - delta)\n\t\tif float(e["poison_time"]) > 0.0:\n\t\t\te["poison_time"] = float(e["poison_time"]) - delta\n\t\t\te["poison_tick"] = float(e["poison_tick"]) - delta\n\t\t\tif float(e["poison_tick"]) <= 0.0:\n\t\t\t\te["poison_tick"] = 0.65\n\t\t\t\tvar pdmg: float = (2.8 + float(e["poison"]) * 1.35) * float(player["poison_power"])\n\t\t\t\tvar live_index: int = damage_enemy(cursor, pdmg, "poison", false)\n\t\t\t\tif live_index < 0:\n\t\t\t\t\tcursor -= 1\n\t\t\t\t\tcontinue\n\t\t\t\tcursor = live_index\n\t\t\t\te = enemies[cursor]'''
    new_enemy_tick = '''\t\te["contact_cd"] = max(0.0, float(e["contact_cd"]) - delta)\n\t\te["shoot_cd"] = max(0.0, float(e["shoot_cd"]) - delta)\n\t\te["ability_cd"] = max(0.0, float(e.get("ability_cd", 0.0)) - delta)\n\t\te["telegraph"] = max(0.0, float(e["telegraph"]) - delta)\n\t\te["marked"] = max(0.0, float(e["marked"]) - delta)\n\t\tvar status_index: int = StatusEffectService.tick_enemy(self, cursor, delta)\n\t\tif status_index < 0:\n\t\t\tcursor -= 1\n\t\t\tcontinue\n\t\tcursor = status_index\n\t\te = enemies[cursor]'''
    replace_once(
        "scripts/main.gd",
        old_enemy_tick,
        new_enemy_tick,
        "var status_index: int = StatusEffectService.tick_enemy(self, cursor, delta)",
    )

    replace_once(
        "scripts/main.gd",
        '''func update_boss(delta: float) -> void:\n\t# Boss生成只能由章節狀態機從LOCKED切到INTRO一次。\n\t# 任何結算、死亡、選單或已擊敗狀態都不允許重新生成。\n\tif screen != "game":\n\t\treturn\n\tif chapter_manager.request_boss_intro(elapsed):''',
        '''func update_boss(delta: float) -> void:\n\t# Boss生成只能由章節狀態機從LOCKED切到INTRO一次。\n\t# 任何結算、死亡、選單或已擊敗狀態都不允許重新生成。\n\tif screen != "game":\n\t\treturn\n\tif not boss.is_empty():\n\t\tStatusEffectService.tick_boss(self, delta)\n\t\tif boss.is_empty():\n\t\t\treturn\n\t\tif StatusEffectService.boss_stunned(boss):\n\t\t\treturn\n\tif chapter_manager.request_boss_intro(elapsed):''',
        "StatusEffectService.tick_boss(self, delta)",
    )

    replace_once(
        "scripts/main.gd",
        '''func apply_poison(index: int, amount: float) -> void:\n\tif index < 0 or index >= enemies.size():\n\t\treturn\n\tenemies[index]["poison"] = min(8.0, float(enemies[index]["poison"]) + amount)\n\tenemies[index]["poison_time"] = max(float(enemies[index]["poison_time"]), 5.2)\n\tenemies[index]["poison_tick"] = min(float(enemies[index]["poison_tick"]), 0.2)''',
        '''func apply_poison(index: int, amount: float) -> void:\n\tStatusEffectService.apply_enemy(self, index, "poison", 5.2, max(0.15, amount), max(1, int(ceil(amount))))\n\n\nfunc apply_enemy_status(index: int, effect_id: String, duration: float, potency: float = 1.0, stacks: int = 1) -> bool:\n\treturn StatusEffectService.apply_enemy(self, index, effect_id, duration, potency, stacks)\n\n\nfunc apply_boss_status(effect_id: String, duration: float, potency: float = 1.0, stacks: int = 1) -> bool:\n\treturn StatusEffectService.apply_boss(self, effect_id, duration, potency, stacks)''',
        "func apply_enemy_status(index: int, effect_id: String",
    )

    replace_once(
        "scripts/systems/hero/alpha36_37_roster_progression_hud.gd",
        "class_name Alpha36RosterProgressionHud\nextends RefCounted",
        'class_name Alpha36RosterProgressionHud\nextends RefCounted\n\nconst StatusEffectService = preload("res://scripts/systems/combat/status_effect_service.gd")',
        'const StatusEffectService = preload("res://scripts/systems/combat/status_effect_service.gd")',
    )
    replace_once(
        "scripts/systems/hero/alpha36_37_roster_progression_hud.gd",
        '\t\thost.draw_rect(Rect2(boss_bar.position, Vector2(boss_bar.size.x * boss_ratio, boss_bar.size.y)), Color8(190, 55, 49), true)',
        '\t\thost.draw_rect(Rect2(boss_bar.position, Vector2(boss_bar.size.x * boss_ratio, boss_bar.size.y)), Color8(190, 55, 49), true)\n\t\tvar boss_status_text: String = StatusEffectService.status_summary(host.boss, 4)\n\t\tif boss_status_text != "":\n\t\t\thost.draw_text(boss_status_text, Vector2(350, 137), 11, Color8(226, 198, 153), true, HORIZONTAL_ALIGNMENT_LEFT, 580)',
        "var boss_status_text: String = StatusEffectService.status_summary(host.boss, 4)",
    )

    required = {
        "project.godot": ["V2.0.0-alpha.53"],
        "scripts/main.gd": [
            "V2.0.0-alpha.53",
            "StatusEffectService.tick_enemy(self, cursor, delta)",
            "StatusEffectService.tick_boss(self, delta)",
            "func apply_enemy_status(index: int, effect_id: String",
        ],
        "scripts/systems/hero/alpha36_37_roster_progression_hud.gd": [
            "StatusEffectService.status_summary(host.boss, 4)",
        ],
    }
    for path, tokens in required.items():
        text = Path(path).read_text(encoding="utf-8")
        for token in tokens:
            if token not in text:
                raise SystemExit(f"Alpha.53 integration missing in {path}: {token}")
    print("Alpha.53 status effect migration checks passed")


if __name__ == "__main__":
    main()
