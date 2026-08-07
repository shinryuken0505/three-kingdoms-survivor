# Alpha.55 Relic × Status Synergy Expansion

Alpha.55 connects the unified Alpha.53 status system and Alpha.54 elemental reactions to relic progression and selected named-hero attacks.

## New relics

- 赤炎符 (`scarlet_flame_talisman`): strengthens burn stacking and detonates at full stacks.
- 五毒囊 (`five_venom_satchel`): poisoned enemies spread poison on death.
- 玄冰玉 (`mystic_ice_jade`): frozen/stunned targets take additional damage.
- 雷公令 (`thunder_command`): increases Shock chain targets.
- 破軍印 (`army_break_seal`): physical attacks gain extra damage against armor-broken targets.
- 陰陽爐 (`yin_yang_furnace`): extends and strengthens Toxic Blaze.

## Named hero status routing

The following named-hero damage sources now route through the unified status API:

- 張角 (`zhangjiao`) → Shock
- 甄姬 (`zhenji`) → Slow/Frost accumulation
- 孫尚香 (`sunshangxiang`) → Burn

The routing is source-based so future skill handlers can remain data-driven and do not need parallel status timers.

## Integration rules

`StatusEffectService` remains the status source of truth. `ElementalSynergyService` owns reactions. `RelicStatusSynergyService` owns relic-specific modifiers and hooks. Main combat only calls these service boundaries.

Alpha.55 keeps legacy relics and hero behavior compatible while new relic definitions are injected into the existing relic pool at startup.
