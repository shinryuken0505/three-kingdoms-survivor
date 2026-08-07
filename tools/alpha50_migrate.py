from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    p = Path(path)
    text = p.read_text(encoding="utf-8")
    if new in text:
        return
    if old not in text:
        raise SystemExit(f"missing version anchor in {path}: {old}")
    p.write_text(text.replace(old, new, 1), encoding="utf-8")


def main() -> None:
    replace_once("project.godot", "V2.0.0-alpha.49", "V2.0.0-alpha.50")
    replace_once("scripts/main.gd", 'const GAME_VERSION: String = "V2.0.0-alpha.49"', 'const GAME_VERSION: String = "V2.0.0-alpha.50"')
    replace_once("scripts/core/alpha48_runtime_coordinator.gd", 'const TARGET_VERSION := "V2.0.0-alpha.49"', 'const TARGET_VERSION := "V2.0.0-alpha.50"')

    service = Path("scripts/systems/player/player_combat_service.gd").read_text(encoding="utf-8")
    required = [
        "MeleeArcHandler.execute",
        "RangedArrowHandler.execute",
        "StrategyOrbHandler.execute",
        '"melee_arc"',
        '"ranged_arrow"',
        '"strategy_orb"',
    ]
    for token in required:
        if token not in service:
            raise SystemExit("missing combat service token: " + token)

    main_text = Path("scripts/main.gd").read_text(encoding="utf-8")
    if "PlayerCombatService.perform_auto_attack" not in main_text:
        raise SystemExit("main combat service entry is missing")
    if "func perform_auto_attack_legacy()" not in main_text:
        raise SystemExit("legacy combat fallback is missing")

    for path in [
        "scripts/systems/player/combat_handlers/melee_arc_handler.gd",
        "scripts/systems/player/combat_handlers/ranged_arrow_handler.gd",
        "scripts/systems/player/combat_handlers/strategy_orb_handler.gd",
    ]:
        if not Path(path).exists():
            raise SystemExit("missing combat handler: " + path)

    print("Alpha.50 combat handler migration checks passed")


if __name__ == "__main__":
    main()
