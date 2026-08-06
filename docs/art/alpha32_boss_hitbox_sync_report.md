# Alpha.32 Boss Hitbox Sync

- Boss special release now checks the same locked telegraph profile used by the warning visual.
- Circle, multi-circle, line and sector geometry share one resolver.
- Players outside the displayed shape do not trigger the special attack.
- A small edge tolerance avoids unfair pixel-perfect boundary hits.
- Successful dodges receive a short green ring and message.

Manual QA remains required for every boss and difficulty.
