# V2.0.0-alpha.3 Scope

## Delivered
- Deterministic terrain effects derived from chapter data and world coordinates.
- Shallow-water and field movement modifiers, dash immunity to terrain slow.
- Shape-based visual telegraphs for interactive terrain.
- `TerrainProfile` migration contract.
- Unified remastered portrait presentation for chapter, hero and boss screens.

## Intentionally deferred
- Physics-based projectile blocking by terrain.
- Damage-over-time application for environmental fire.
- New hand-painted portrait source art.
- Sprite-sheet replacement for pixel combat characters.

## Runtime test gates
1. No selection modal may lose Space/Enter/mouse input.
2. Terrain visual and collision/effect coordinates must remain aligned while camera moves.
3. Boss/hero portrait frames must fit 1280x720.
4. Save/load must preserve chapter and world flags.
