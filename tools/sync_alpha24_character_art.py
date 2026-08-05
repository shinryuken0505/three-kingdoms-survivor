#!/usr/bin/env python3
"""Compress Alpha.24 portraits and rebuild four-frame pixel sprites from portrait identity."""
from pathlib import Path
from PIL import Image, ImageDraw
import colorsys, hashlib

ROOT = Path(__file__).resolve().parents[1]
PORTRAITS = ROOT / "assets" / "portraits"
SPRITES = ROOT / "assets" / "sprites"
REPORT = ROOT / "docs" / "art" / "alpha24_portrait_pixel_todo.md"

FORMAL = {
"swordsman":"swordsman_default.png","hunter":"hunter_default.png","poisoner":"poisoner_default.png","heroine":"heroine_default.png",
"liubei":"liu_bei.png","guanyu":"guan_yu.png","zhangfei":"zhang_fei.png","zhaoyun":"zhao_yun.png","zhugeliang":"zhuge_liang.png",
"sunjian":"sun_jian.png","caocao":"cao_cao.png","lvbu":"lv_bu.png","simayi":"sima_yi.png","sunshangxiang":"sun_shangxiang.png",
"taishici":"taishi_ci.png","jiangwei":"jiang_wei.png","dongzhuo":"dong_zhuo.png","luxun":"lu_xun.png","diaochan":"diao_chan.png",
"huatuo":"hua_tuo.png","weiyan":"wei_yan.png","huangzhong":"huang_zhong.png","yuanshao":"yuan_shao.png","xiahouyuan":"xiahou_yuan.png",
"daqiao":"da_qiao.png","zhenji":"zhen_ji.png","zhangjiao":"zhang_jiao.png","huaxiong":"hua_xiong.png","zhangliao":"zhang_liao.png",
"wangyi":"wang_yi.png","zhouyu":"zhou_yu.png","fazheng":"fa_zheng.png","zhanghe":"zhang_he.png","caoren":"cao_ren.png",
"chengong":"chen_gong.png","sunce":"sun_ce.png","caimao":"cai_mao.png","lvlingqi":"lv_lingqi.png","gaoshun":"gao_shun.png",
"zhangliang":"zhang_liang.png","xiahouen":"xiahou_en.png","sunquan":"sun_quan.png","guojia":"guo_jia.png","xiahoudun":"xiahou_dun.png",
"caiwenji":"cai_wenji.png","huanggai":"huang_gai.png","zhangbao":"zhang_bao.png","lusu":"lu_su.png","xuhuang":"xu_huang.png","liru":"li_ru.png"
}
ARCH = {"guanyu":"glaive","zhangfei":"spear","zhaoyun":"spear","lvbu":"halberd","huangzhong":"bow","xiahouyuan":"bow","sunshangxiang":"bow","taishici":"bow","xuhuang":"axe","gaoshun":"spear","zhangliao":"spear","zhanghe":"spear","lvlingqi":"halberd","wangyi":"blade","zhugeliang":"fan","simayi":"fan","fazheng":"fan","guojia":"fan","luxun":"fan","zhouyu":"fan","chengong":"scroll","huatuo":"staff","poisoner":"staff","zhangjiao":"staff","zhangbao":"staff","caiwenji":"instrument","daqiao":"fan","zhenji":"fan","diaochan":"fan"}

def choose_source(cid, formal):
    candidates = [PORTRAITS / formal, PORTRAITS / f"{cid}_default.png"]
    return next((p for p in candidates if p.exists()), None)

def palette(im):
    q = im.convert("RGB").resize((96, 144)).quantize(colors=12).convert("RGB")
    ranked=[]
    for count,c in sorted(q.getcolors(96*144) or [], reverse=True):
        r,g,b=c; h,s,v=colorsys.rgb_to_hsv(r/255,g/255,b/255)
        if v < .12 or (r > g*1.15 and g > b*1.15 and r > 90): continue
        ranked.append((count,c))
    base=ranked[0][1] if ranked else (80,90,100)
    dark=tuple(max(15,int(x*.45)) for x in base)
    mid=tuple(max(30,min(220,int(x*.85+25))) for x in base)
    light=tuple(max(90,min(245,int(x*1.25+30))) for x in base)
    return dark,mid,light

def rect(d,box,c): d.rectangle(box,fill=c)
def sprite(cid,pal):
    dark,mid,light=pal; out=Image.new("RGBA",(192,48),(0,0,0,0)); seed=int(hashlib.sha1(cid.encode()).hexdigest()[:8],16)
    skin=(205+seed%20,145+(seed>>4)%25,105+(seed>>8)%25,255); outline=(18,18,22,255); gold=(188,143,62,255); hair=(25,18,16,255); kind=ARCH.get(cid,"blade")
    for f,bob in enumerate((0,1,0,-1)):
        x=f*48; d=ImageDraw.Draw(out)
        rect(d,(x+14,31+bob,x+20,43+bob),outline); rect(d,(x+27,31+bob,x+33,43+bob),outline)
        rect(d,(x+15,31+bob,x+20,41+bob),dark+(255,)); rect(d,(x+27,31+bob,x+32,41+bob),dark+(255,))
        rect(d,(x+10,18+bob,x+37,35+bob),outline); rect(d,(x+12,19+bob,x+35,33+bob),mid+(255,)); rect(d,(x+15,21+bob,x+32,29+bob),dark+(255,)); rect(d,(x+17,22+bob,x+30,25+bob),light+(255,))
        rect(d,(x+8,20+bob,x+14,27+bob),outline); rect(d,(x+33,20+bob,x+39,27+bob),outline); rect(d,(x+9,21+bob,x+13,25+bob),gold); rect(d,(x+34,21+bob,x+38,25+bob),gold)
        rect(d,(x+16,6+bob,x+31,20+bob),outline); rect(d,(x+18,8+bob,x+29,18+bob),skin)
        if kind in ("fan","scroll","instrument","staff"): rect(d,(x+17,3+bob,x+30,8+bob),outline); rect(d,(x+20,1+bob,x+27,5+bob),dark+(255,))
        else: rect(d,(x+17,4+bob,x+30,9+bob),hair); rect(d,(x+21,1+bob,x+27,5+bob),hair)
        rect(d,(x+20,12+bob,x+21,13+bob),(20,20,20,255)); rect(d,(x+26,12+bob,x+27,13+bob),(20,20,20,255)); rect(d,(x+12,30+bob,x+35,33+bob),outline); rect(d,(x+21,30+bob,x+26,33+bob),gold)
        if kind in ("spear","halberd"): d.line((x+40,10+bob,x+40,42+bob),fill=outline,width=3); d.polygon([(x+40,6+bob),(x+36,13+bob),(x+44,13+bob)],fill=light+(255,))
        elif kind=="bow": d.arc((x+35,8+bob,x+47,40+bob),-90,90,fill=gold,width=2); d.line((x+41,9+bob,x+41,39+bob),fill=light+(255,),width=1)
        elif kind=="fan": d.polygon([(x+37,20+bob),(x+46,14+bob),(x+44,27+bob)],fill=light+(255,)); d.line((x+37,20+bob,x+45,28+bob),fill=gold,width=2)
        elif kind=="instrument": rect(d,(x+37,12+bob,x+44,35+bob),dark+(255,)); d.line((x+39,14+bob,x+39,33+bob),fill=gold,width=1)
        elif kind=="staff": d.line((x+41,8+bob,x+41,42+bob),fill=gold,width=3); d.ellipse((x+37,5+bob,x+45,13+bob),outline=light+(255,),width=2)
        elif kind=="axe": d.line((x+40,11+bob,x+40,42+bob),fill=outline,width=3); d.polygon([(x+39,9+bob),(x+47,12+bob),(x+44,20+bob),(x+39,18+bob)],fill=light+(255,))
        elif kind=="scroll": rect(d,(x+36,18+bob,x+45,29+bob),(184,158,108,255))
        else: d.line((x+39,13+bob,x+45,39+bob),fill=outline,width=4); d.line((x+39,13+bob,x+45,39+bob),fill=light+(255,),width=2)
    return out

def main():
    SPRITES.mkdir(parents=True,exist_ok=True); REPORT.parent.mkdir(parents=True,exist_ok=True)
    updated=[]; missing=[]
    for cid,formal in FORMAL.items():
        src=choose_source(cid,formal)
        if src is None: missing.append((cid,formal)); continue
        im=Image.open(src).convert("RGB"); before=(im.width,im.height,src.stat().st_size)
        im.thumbnail((640,960),Image.Resampling.LANCZOS)
        target=PORTRAITS/f"{cid}_default.png"; im.save(target,"PNG",optimize=True,compress_level=9)
        sprite(cid,palette(im)).save(SPRITES/f"{cid}_default.png","PNG",optimize=True,compress_level=9)
        updated.append((cid,formal,before,(im.width,im.height,target.stat().st_size)))
    lines=["# Alpha.24 立繪與像素小人同步檢查","",f"- 成功同步：{len(updated)} 位",f"- 尚缺新版立繪：{len(missing)} 位","- 執行用立繪已統一壓縮至最大 640×960。","- 像素小人已依立繪主色與武器定位重製為 192×48 四幀圖。","","## 未更新立繪／代辦"]
    lines += [f"- [ ] `{cid}`：缺少 `assets/portraits/{formal}`" for cid,formal in missing] or ["- [x] 本清單角色皆已找到新版立繪並同步。"]
    lines += ["","## 人工驗收代辦","- [ ] 招賢館逐一確認姓名與立繪對應。","- [ ] 戰場逐一確認像素角色武器方向、步行四幀與碰撞中心。","- [ ] 女性、文官與特殊皮膚進行第二輪手工像素精修。","- [ ] DLC／特殊造型另行重製。","","## 同步結果"]
    lines += [f"- `{cid}`：`{formal}` → `{cid}_default.png`；{a[0]}×{a[1]} / {a[2]//1024}KB → {b[0]}×{b[1]} / {b[2]//1024}KB" for cid,formal,a,b in updated]
    REPORT.write_text("\n".join(lines)+"\n",encoding="utf-8")
    print(f"updated={len(updated)} missing={len(missing)}")
if __name__ == "__main__": main()
