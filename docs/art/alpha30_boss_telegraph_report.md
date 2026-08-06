# Alpha.30 Boss Telegraph & Effects Report

## Implemented
- Version raised to `V2.0.0-alpha.30`.
- Boss special attacks now enter a readable wind-up phase instead of firing instantly.
- Added per-boss skill names and tuned warning durations.
- Added red ground warning rings, HUD banner state, warning sound, and release shake.
- Boss movement/attack processing pauses during the warning window so the telegraph remains readable.
- First pass covers Zhang Jiao, Hua Xiong, Lu Bu, Cao Ren, Zhang He, and Gao Shun, with a safe fallback for other bosses.

## Timing
- Standard special: about 0.68 seconds.
- Charge/melee specialists: about 0.78 seconds.
- Zhang Jiao: about 0.95 seconds.
- Lu Bu: about 1.05 seconds.

## Acceptance checks
- A special attack cannot execute on the same frame its cooldown expires.
- Warning banner and red area appear before damage is released.
- The special executes once when the timer reaches zero.
- Existing boss cooldown assignment remains active after the telegraph begins.
