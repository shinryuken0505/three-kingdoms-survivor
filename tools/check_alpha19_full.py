from pathlib import Path

root = Path(__file__).resolve().parents[1]
main = (root / "scripts/main.gd").read_text(encoding="utf-8")
required = [
    'V2.0.0-alpha.19', 'Alpha19BuildRules', 'Alpha19HeroMastery',
    'Alpha19HistoryInfluence', 'Alpha19ChapterGimmicks',
    'func alpha19_initialize_run()', 'func alpha19_filter_level_choices()',
    'alpha19_damage_mult', 'alpha19_apply_chapter_setup()'
]
for token in required:
    assert token in main, f"missing Alpha.19 integration token: {token}"
for path in [
    "scripts/systems/build/alpha19_build_rules.gd",
    "scripts/systems/hero/alpha19_hero_mastery.gd",
    "scripts/systems/world/alpha19_history_influence.gd",
    "scripts/systems/chapter/alpha19_chapter_gimmicks.gd",
    "tests/alpha19_rules_test.gd",
]:
    assert (root / path).exists(), f"missing {path}"
print("ALPHA19_FULL_STRUCTURE_OK")
