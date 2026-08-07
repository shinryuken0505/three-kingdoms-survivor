from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    p = Path(path)
    text = p.read_text(encoding="utf-8")
    if new in text:
        return
    if old not in text:
        raise SystemExit(f"missing anchor in {path}: {old}")
    p.write_text(text.replace(old, new, 1), encoding="utf-8")


def patch_main() -> None:
    path = Path("scripts/main.gd")
    text = path.read_text(encoding="utf-8")

    preload_anchor = 'const PlayerCombatService = preload("res://scripts/systems/player/player_combat_service.gd")\n'
    passive_preload = 'const PlayerSignaturePassiveService = preload("res://scripts/systems/player/player_signature_passive_service.gd")\n'
    if passive_preload not in text:
        if preload_anchor not in text:
            raise SystemExit("missing PlayerCombatService preload anchor")
        text = text.replace(preload_anchor, preload_anchor + passive_preload, 1)

    damage_anchor = '''\tif source == "fire":
\t\tsource_mult *= equipment_effect("fire_taken_mult", 1.0)
\tvar reduced: float = max('''
    damage_repl = '''\tif source == "fire":
\t\tsource_mult *= equipment_effect("fire_taken_mult", 1.0)
\tsource_mult *= PlayerSignaturePassiveService.incoming_damage_multiplier(self, chosen_identity, source)
\tvar reduced: float = max('''
    if "PlayerSignaturePassiveService.incoming_damage_multiplier" not in text:
        if damage_anchor not in text:
            raise SystemExit("missing damage_player passive anchor")
        text = text.replace(damage_anchor, damage_repl, 1)

    enemy_hit_anchor = '''\t\t\t\tif live_index >= 0 and has_relic("frostjade") and rng.randf() < 0.08:
\t\t\t\t\tenemies[live_index]["slow"] = max(float(enemies[live_index]["slow"]), 2.0)
\t\t\t\tshot["pierce"] = int(shot["pierce"]) - 1'''
    enemy_hit_repl = '''\t\t\t\tif live_index >= 0 and has_relic("frostjade") and rng.randf() < 0.08:
\t\t\t\t\tenemies[live_index]["slow"] = max(float(enemies[live_index]["slow"]), 2.0)
\t\t\t\tif bool(shot.get("alpha51_arcane_orb", false)):
\t\t\t\t\tPlayerSignaturePassiveService.on_projectile_enemy_hit(self, shot, live_index)
\t\t\t\tshot["pierce"] = int(shot["pierce"]) - 1'''
    if "PlayerSignaturePassiveService.on_projectile_enemy_hit" not in text:
        if enemy_hit_anchor not in text:
            raise SystemExit("missing player projectile enemy-hit anchor")
        text = text.replace(enemy_hit_anchor, enemy_hit_repl, 1)

    boss_hit_anchor = '''\t\t\t\tdamage_boss(float(shot["damage"]) * (1.75 if crit else 1.0), str(shot["kind"]), crit)
\t\t\t\tshot["pierce"] = int(shot["pierce"]) - 1'''
    boss_hit_repl = '''\t\t\t\tdamage_boss(float(shot["damage"]) * (1.75 if crit else 1.0), str(shot["kind"]), crit)
\t\t\t\tif bool(shot.get("alpha51_arcane_orb", false)):
\t\t\t\t\tPlayerSignaturePassiveService.on_projectile_boss_hit(self, shot)
\t\t\t\tshot["pierce"] = int(shot["pierce"]) - 1'''
    if "PlayerSignaturePassiveService.on_projectile_boss_hit" not in text:
        if boss_hit_anchor not in text:
            raise SystemExit("missing player projectile boss-hit anchor")
        text = text.replace(boss_hit_anchor, boss_hit_repl, 1)

    path.write_text(text, encoding="utf-8")


def main() -> None:
    replace_once("project.godot", "V2.0.0-alpha.50", "V2.0.0-alpha.51")
    replace_once("scripts/main.gd", 'const GAME_VERSION: String = "V2.0.0-alpha.50"', 'const GAME_VERSION: String = "V2.0.0-alpha.51"')
    replace_once("scripts/core/alpha48_runtime_coordinator.gd", 'const TARGET_VERSION := "V2.0.0-alpha.50"', 'const TARGET_VERSION := "V2.0.0-alpha.51"')
    patch_main()

    main_text = Path("scripts/main.gd").read_text(encoding="utf-8")
    for token in [
        "PlayerSignaturePassiveService.incoming_damage_multiplier",
        "PlayerSignaturePassiveService.on_projectile_enemy_hit",
        "PlayerSignaturePassiveService.on_projectile_boss_hit",
    ]:
        if token not in main_text:
            raise SystemExit("missing main passive integration: " + token)

    passive = Path("scripts/systems/player/player_signature_passive_service.gd").read_text(encoding="utf-8")
    for token in ["blade_guard", "eagle_eye", "arcane_flow", "arcane_burst_profile"]:
        if token not in passive:
            raise SystemExit("missing passive token: " + token)

    melee = Path("scripts/systems/player/combat_handlers/melee_arc_handler.gd").read_text(encoding="utf-8")
    ranged = Path("scripts/systems/player/combat_handlers/ranged_arrow_handler.gd").read_text(encoding="utf-8")
    strategy = Path("scripts/systems/player/combat_handlers/strategy_orb_handler.gd").read_text(encoding="utf-8")
    if "alpha51_blade_chain" not in melee or "blade_wave" not in melee:
        raise SystemExit("swordsman evolution missing")
    if "eagle_eye_damage_multiplier" not in ranged:
        raise SystemExit("archer eagle eye missing")
    if "alpha51_arcane_orb" not in strategy:
        raise SystemExit("strategist arcane flow missing")

    print("Alpha.51 signature passive migration checks passed")


if __name__ == "__main__":
    main()
