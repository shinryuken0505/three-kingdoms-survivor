from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
PORTRAITS = ROOT / "assets" / "portraits"
failed = []
count = 0
for path in sorted(PORTRAITS.glob("*.png")):
    image = Image.open(path).convert("RGBA")
    count += 1
    amin, amax = image.getextrema()[3]
    if amin != 255 or amax != 255:
        failed.append(f"{path.name}: alpha={amin}-{amax}")
    if image.size != (256, 320):
        failed.append(f"{path.name}: size={image.size}")
if failed:
    print("PORTRAIT_ALPHA_QA_FAIL")
    for item in failed:
        print(item)
    raise SystemExit(1)
print(f"PORTRAIT_ALPHA_QA_OK portraits={count} opaque=100%")
