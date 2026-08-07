# Alpha.57 Build-aware Recruitment

Alpha.57 connects the elemental/status metadata introduced in Alpha.56 to recruitment without exposing numeric internal weights to players.

## Zhang Jiao completeness

Zhang Jiao is now a formal runtime hero and registry entry using verified default assets:
- `res://assets/portraits/zhangjiao_default.png`
- `res://assets/sprites/zhangjiao_default.png`

His canonical registry identity is lightning/shock/chain/reaction. The alias `zhang_jiao` resolves to `zhangjiao`.

## Recruitment affinity

`HeroRecruitmentAffinityService` reads:
- currently owned elemental/status relics,
- active general elemental/status tags,
- reserve general elemental/status tags.

It adds only a small hidden bonus on top of existing historical, faction, branch, cooldown and legendary availability rules. It never guarantees a matching general.

## Player-facing information

Recruitment cards may show simple tactical labels such as `[火] 火焰`, `[雷] 雷電`, `[冰] 冰霜`, `[輔] 輔助`, and natural hints such as `與目前戰術搭配良好`.

Numeric weights and internal scoring are intentionally not shown.

## Extension rule

New generals should define `element`, `status_tags`, and `synergy_tags` in `HeroContentRegistry`. New relic-driven affinity should be added to the service tag map instead of adding hero-specific branches to `main.gd`.
