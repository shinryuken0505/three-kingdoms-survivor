# Alpha.24 Premium Portrait Manifest

Target branch: `feature/alpha24-steam-demo`

## Art direction
- Premium semi-realistic Three Kingdoms portrait painting.
- Dark parchment and bronze presentation, cinematic face lighting, readable silhouette.
- Historical base first; fantasy effects are restrained and role-specific.
- Every character is generated and reviewed individually. Do not crop characters out of group sheets for production use.
- No embedded text in production portraits. Names and titles are rendered by Godot UI.

## Production outputs per character
- `full`: 1024x1536 master portrait.
- `card`: 768x1024 recruit/card crop.
- `square`: 512x512 codex and HUD crop.
- `bust`: 640x720 dialogue and result crop.

## Safe composition
- Head center between 22% and 34% of canvas height.
- Keep 8% horizontal margin around body and weapon.
- Face, hands and signature weapon must not overlap UI title areas.
- Only one character in each file.

## S-tier first production batch

### Protagonists
| id | Traditional Chinese | title | palette | signature |
|---|---|---|---|---|
| swordsman | 破陣刀客 | 近戰・破陣斬將 | iron, dark red, burnt brown | broad Han dao, worn lamellar armor |
| hunter | 百步弓手 | 遠程・百步穿楊 | ink green, leather brown | Han longbow, quiver, focused gaze |
| poisoner | 百蠱毒師 | 詭術・毒蠱控場 | deep violet, toxic green, brass | herbs, talismans, poison vial |
| heroine | 迴刃女俠 | 靈巧・迴刃制敵 | dark red, black, silver | ring blades, agile stance |

### Heroes
| id | Traditional Chinese | title | palette | signature |
|---|---|---|---|---|
| liubei | 劉備 | 仁德之主 | jade green, ivory, muted gold | restrained twin swords, benevolent lord |
| guanyu | 關羽 | 義絕武聖 | deep green, bronze, crimson accent | guandao, long beard, calm authority |
| zhangfei | 張飛 | 燕人猛將 | black iron, dark red | serpent spear, explosive presence |
| zhaoyun | 趙雲 | 常勝虎將 | silver, cool blue | long spear, clean heroic silhouette |
| zhugeliang | 諸葛亮 | 臥龍軍師 | ivory, ink blue, pale gold | feather fan, subtle formation diagram |
| sunjian | 孫堅 | 江東猛虎 | bronze gold, dark red, black iron | mature warlord, tiger motif, ancient saber |
| caocao | 曹操 | 亂世梟雄 | black, crimson, antique gold | charismatic ruler, sword and command scroll |
| lvbu | 呂布 | 人中呂布 | black, blood red, gold | halberd, red hare motif, overwhelming presence |

## Integration paths
Production assets should be committed under:

```text
assets/portraits_premium/protagonists/<id>_full.png
assets/portraits_premium/protagonists/<id>_card.png
assets/portraits_premium/protagonists/<id>_square.png
assets/portraits_premium/protagonists/<id>_bust.png
assets/portraits_premium/heroes/<id>_full.png
assets/portraits_premium/heroes/<id>_card.png
assets/portraits_premium/heroes/<id>_square.png
assets/portraits_premium/heroes/<id>_bust.png
```

## Review gates
1. Correct historical identity and signature weapon.
2. Correct age and temperament.
3. One person only; no duplicate sprite-like figures.
4. Face and weapon survive all four crops.
5. No generated lettering or watermark.
6. Godot import succeeds and transparent edges are clean.
7. Recruit card, codex, hero configuration, boss HUD and ending screens use the same source identity.
