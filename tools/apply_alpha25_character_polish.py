#!/usr/bin/env python3
"""Alpha.25 character polish: patch runtime checks and rebuild readable pixel identities."""
from pathlib import Path
from PIL import Image, ImageDraw
import importlib.util

ROOT = Path(__file__).resolve().parents[1]
MAIN = ROOT / "scripts" / "main.gd"
SPRITES = ROOT / "assets" / "sprites"
PORTRAITS = ROOT / "assets" / "portraits"
REPORT = ROOT / "docs" / "art" / "alpha25_character_polish_report.md"

spec = importlib.util.spec_from_file_location("alpha24_art", ROOT / "tools" / "sync_alpha24_character_art.py")
alpha24 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(alpha24)

FEMALE = {"heroine","sunshangxiang","diaochan","daqiao","zhenji","wangyi","lvlingqi","caiwenji"}
STRATEGIST = {"zhugeliang","simayi","luxun","zhouyu","fazheng","guojia","chengong","lusu","liru","caimao"}
HEAVY = {"guanyu","zhangfei","lvbu","dongzhuo","huaxiong","gaoshun","caoren","xiahoudun","xuhuang","yuanshao"}
BEARD = {"guanyu","zhangfei","caocao","sunjian","dongzhuo","huaxiong","huangzhong","huanggai","yuanshao","xuhuang"}
CROWN = {"liubei","caocao","sunjian","sunquan","yuanshao","dongzhuo","simayi","zhouyu"}
HELMET = {"guanyu","zhangfei","zhaoyun","lvbu","taishici","jiangwei","weiyan","huangzhong","xiahouyuan","huaxiong","zhangliao","zhanghe","caoren","sunce","lvlingqi","gaoshun","xiahouen","xiahoudun","huanggai","xuhuang"}
ROBE = STRATEGIST | {"huatuo","poisoner","zhangjiao","zhangbao","caiwenji","daqiao","zhenji","diaochan"}


def patch_main() -> list[str]:
    text = MAIN.read_text(encoding="utf-8")
    changes = []
    replacements = [
        ('const GAME_VERSION: String = "V2.0.0-alpha.24"', 'const GAME_VERSION: String = "V2.0.0-alpha.25"'),
        ('screen != "hero_config"\n\t\tor known_hero_order().size() != 3', 'screen != "camp_menu"\n\t\tor known_hero_order().size() != 3'),
        ('self_test_fail("營地回復、護盾或名將整備失效")', 'self_test_fail("營地回復、護盾或營地選單失效")'),
    ]
    for old, new in replacements:
        if old in text:
            text = text.replace(old, new, 1)
            changes.append(new.splitlines()[0])
    MAIN.write_text(text, encoding="utf-8")
    return changes


def rgba(rgb, a=255):
    return tuple(rgb) + (a,)


def box(draw, xy, color):
    draw.rectangle(xy, fill=color)


def refined_sprite(cid: str, portrait: Image.Image) -> Image.Image:
    dark, mid, light = alpha24.palette(portrait)
    out = Image.new("RGBA", (192, 48), (0, 0, 0, 0))
    skin = (218, 164, 120, 255) if cid not in FEMALE else (232, 181, 144, 255)
    outline = (15, 16, 20, 255)
    gold = (202, 157, 68, 255)
    hair = (27, 20, 19, 255)
    weapon = alpha24.ARCH.get(cid, "blade")
    heavy = cid in HEAVY
    robe = cid in ROBE
    female = cid in FEMALE

    for frame, bob in enumerate((0, 1, 0, -1)):
        ox = frame * 48
        d = ImageDraw.Draw(out)
        # shadow/feet: alternating stride makes four frames readable
        stride = (-1, 1, 1, -1)[frame]
        box(d, (ox+13+stride, 39+bob, ox+21+stride, 44+bob), outline)
        box(d, (ox+27-stride, 39+bob, ox+35-stride, 44+bob), outline)
        leg_color = rgba(dark)
        box(d, (ox+15+stride, 31+bob, ox+21+stride, 41+bob), leg_color)
        box(d, (ox+27-stride, 31+bob, ox+33-stride, 41+bob), leg_color)

        # body silhouette: robes are narrower, heavy generals broader
        left = ox + (8 if heavy else 11)
        right = ox + (39 if heavy else 36)
        if robe:
            d.polygon([(ox+15,18+bob),(ox+32,18+bob),(ox+37,38+bob),(ox+10,38+bob)], fill=outline)
            d.polygon([(ox+17,20+bob),(ox+30,20+bob),(ox+34,36+bob),(ox+13,36+bob)], fill=rgba(mid))
            box(d, (ox+17, 29+bob, ox+30, 32+bob), rgba(dark))
        else:
            box(d, (left,18+bob,right,35+bob), outline)
            box(d, (left+2,20+bob,right-2,33+bob), rgba(mid))
            box(d, (ox+16,22+bob,ox+31,27+bob), rgba(light))
            if heavy:
                box(d, (ox+10,19+bob,ox+15,29+bob), rgba(dark))
                box(d, (ox+33,19+bob,ox+38,29+bob), rgba(dark))
        box(d, (ox+19,31+bob,ox+28,34+bob), gold)

        # head and face
        box(d, (ox+16,6+bob,ox+31,20+bob), outline)
        box(d, (ox+18,8+bob,ox+29,18+bob), skin)
        if female:
            box(d, (ox+15,6+bob,ox+18,25+bob), hair)
            box(d, (ox+29,6+bob,ox+32,25+bob), hair)
            box(d, (ox+18,4+bob,ox+29,8+bob), hair)
        elif cid in HELMET:
            box(d, (ox+15,4+bob,ox+32,10+bob), outline)
            box(d, (ox+17,5+bob,ox+30,8+bob), rgba(dark))
            box(d, (ox+22,1+bob,ox+25,5+bob), gold)
        elif cid in CROWN:
            box(d, (ox+17,4+bob,ox+30,8+bob), hair)
            box(d, (ox+20,1+bob,ox+27,5+bob), gold)
        else:
            box(d, (ox+17,4+bob,ox+30,9+bob), hair)
        box(d, (ox+20,12+bob,ox+21,13+bob), (15,15,16,255))
        box(d, (ox+26,12+bob,ox+27,13+bob), (15,15,16,255))
        if cid in BEARD:
            if cid == "guanyu":
                d.polygon([(ox+20,17+bob),(ox+28,17+bob),(ox+27,31+bob),(ox+23,35+bob),(ox+20,29+bob)], fill=hair)
            else:
                box(d, (ox+20,17+bob,ox+28,21+bob), hair)

        # class marker for quick battlefield recognition
        if cid in STRATEGIST:
            box(d, (ox+12,21+bob,ox+14,31+bob), gold)
        elif cid in FEMALE:
            box(d, (ox+12,22+bob,ox+14,26+bob), rgba(light))
            box(d, (ox+34,22+bob,ox+36,26+bob), rgba(light))

        # signature weapon, kept outside body to avoid silhouette overlap
        if weapon in ("spear", "halberd"):
            d.line((ox+41,8+bob,ox+41,43+bob), fill=outline, width=3)
            d.polygon([(ox+41,3+bob),(ox+36,11+bob),(ox+46,11+bob)], fill=rgba(light))
            if weapon == "halberd":
                d.polygon([(ox+40,10+bob),(ox+47,14+bob),(ox+41,18+bob)], fill=gold)
        elif weapon == "bow":
            d.arc((ox+34,7+bob,ox+47,42+bob), -90, 90, fill=gold, width=2)
            d.line((ox+41,8+bob,ox+41,41+bob), fill=rgba(light), width=1)
        elif weapon == "fan":
            d.polygon([(ox+36,21+bob),(ox+46,13+bob),(ox+44,29+bob)], fill=rgba(light))
            d.line((ox+36,21+bob,ox+45,29+bob), fill=gold, width=2)
        elif weapon == "instrument":
            box(d, (ox+37,12+bob,ox+45,35+bob), outline)
            box(d, (ox+39,14+bob,ox+43,33+bob), rgba(dark))
            d.line((ox+40,15+bob,ox+40,32+bob), fill=gold, width=1)
        elif weapon == "staff":
            d.line((ox+41,7+bob,ox+41,43+bob), fill=gold, width=3)
            d.ellipse((ox+37,4+bob,ox+45,12+bob), outline=rgba(light), width=2)
        elif weapon == "axe":
            d.line((ox+40,11+bob,ox+40,43+bob), fill=outline, width=3)
            d.polygon([(ox+39,8+bob),(ox+47,11+bob),(ox+45,20+bob),(ox+39,18+bob)], fill=rgba(light))
        elif weapon == "scroll":
            box(d, (ox+36,18+bob,ox+46,30+bob), (194,164,110,255))
            box(d, (ox+37,18+bob,ox+45,20+bob), gold)
        else:
            d.line((ox+38,12+bob,ox+46,40+bob), fill=outline, width=4)
            d.line((ox+38,12+bob,ox+46,40+bob), fill=rgba(light), width=2)
    return out


def rebuild_sprites() -> tuple[list[str], list[str]]:
    SPRITES.mkdir(parents=True, exist_ok=True)
    updated, missing = [], []
    for cid in alpha24.FORMAL:
        portrait_path = PORTRAITS / f"{cid}_default.png"
        if not portrait_path.exists():
            missing.append(cid)
            continue
        portrait = Image.open(portrait_path).convert("RGB")
        refined_sprite(cid, portrait).save(SPRITES / f"{cid}_default.png", "PNG", optimize=True, compress_level=9)
        updated.append(cid)
    return updated, missing


def write_report(updated: list[str], missing: list[str], patches: list[str]) -> None:
    REPORT.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        "# Alpha.25 角色美術與戰場辨識精修",
        "",
        f"- 像素角色精修：{len(updated)} 位",
        f"- 缺少執行用立繪：{len(missing)} 位",
        "- 四幀尺寸：192×48",
        "- 已加入：角色主色、職業輪廓、武器、頭冠／頭盔、鬍鬚、女性髮型與重甲差異。",
        "",
        "## 程式修正",
    ]
    lines += [f"- [x] `{p}`" for p in patches] or ["- [ ] 未偵測到可套用的程式修正。"]
    lines += ["", "## 缺少素材"]
    lines += [f"- [ ] `{cid}` 缺少 `assets/portraits/{cid}_default.png`" for cid in missing] or ["- [x] 50 位角色均有執行用立繪。"]
    lines += [
        "",
        "## 人工驗收代辦",
        "- [ ] 招賢館逐一核對姓名、立繪與角色 ID。",
        "- [ ] 戰場檢查武器朝向、四幀步伐及碰撞中心。",
        "- [ ] 女性／文官／醫者確認遠距離辨識度。",
        "- [ ] 關羽長鬚、呂布方天戟、諸葛亮羽扇等標誌性特徵進行第二輪手工精修。",
        "- [ ] 特殊皮膚與 DLC 外觀另行重製。",
        "",
        "## 已精修角色",
    ]
    lines += [f"- [x] `{cid}`" for cid in updated]
    REPORT.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main():
    patches = patch_main()
    updated, missing = rebuild_sprites()
    write_report(updated, missing, patches)
    print(f"alpha25 updated={len(updated)} missing={len(missing)} patches={len(patches)}")


if __name__ == "__main__":
    main()
