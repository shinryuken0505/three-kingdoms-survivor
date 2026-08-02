from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
main=(ROOT/'scripts/main.gd').read_text(encoding='utf-8-sig')
needle='"boss_loot":\n\t\t\tdraw_boss_loot_screen()'
if needle not in main:
    raise SystemExit('V1715_FAIL: boss_loot draw branch missing')
for ident in ['swordsman','hunter','poisoner','heroine']:
    p=ROOT/'assets'/'portraits'/f'{ident}_default.png'
    with Image.open(p).convert('RGBA') as im:
        if im.size != (256,320):
            raise SystemExit(f'V1715_FAIL: {ident} size {im.size}')
        # Check both central and right cheek regions for opaque near-black slabs.
        for name,box in [('center',(100,112,156,190)),('right_face',(132,108,178,190))]:
            pix=list(im.crop(box).getdata())
            opaque=[x for x in pix if x[3]>200]
            dark=[x for x in opaque if max(x[:3])<42]
            ratio=len(dark)/max(1,len(opaque))
            if ratio>0.10:
                raise SystemExit(f'V1715_FAIL: {ident} {name} dark ratio {ratio:.3f}')
print('V1715_REGRESSION_OK')
