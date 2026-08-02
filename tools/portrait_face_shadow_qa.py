from PIL import Image
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1]
BAD=(170,95,74)
failed=[]
for f in sorted((ROOT/"assets/portraits").glob("*.png")):
    im=Image.open(f).convert("RGB")
    w,h=im.size
    count=0
    for y in range(int(h*.18),int(h*.62)):
        for x in range(int(w*.24),int(w*.76)):
            r,g,b=im.getpixel((x,y))
            if abs(r-BAD[0])<=10 and abs(g-BAD[1])<=10 and abs(b-BAD[2])<=10:
                count+=1
    if count>80:
        failed.append((f.name,count))
if failed:
    print("PORTRAIT_FACE_SHADOW_QA_FAIL")
    for name,count in failed: print(name,count)
    sys.exit(1)
print("PORTRAIT_FACE_SHADOW_QA_PASS")
