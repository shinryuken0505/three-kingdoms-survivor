from pathlib import Path

path = Path("scripts/main.gd")
text = path.read_text(encoding="utf-8")
start = text.index("func hero_role(hid: String) -> String:\n")
end = text.index("\n\nfunc spawn_hero_signature_effect", start)
replacement = '''func hero_role(hid: String) -> String:
	var roles: Dictionary = {
		"liubei": "援軍・護衛",
		"guanyu": "重斬・破陣",
		"zhangfei": "震退・控場",
		"zhaoyun": "穿陣・直線清場",
		"huangzhong": "重箭・遠程狙擊",
		"huatuo": "治療・護盾",
		"caocao": "軍令・加速",
		"sunjian": "突進・清線",
		"taishici": "神射・貫穿",
		"zhangjiao": "雷法・傳毒",
		"diaochan": "魅惑・牽引",
		"sunshangxiang": "連射・火箭",
		"zhenji": "冰霜・控場",
		"lvlingqi": "突擊・爆發",
		"wangyi": "回刃・暴擊",
		"caiwenji": "治療・音波",
		"daqiao": "屏障・反射"
	}
	return str(roles.get(hid, "名將之力"))
'''
text = text[:start] + replacement + text[end:]
path.write_text(text, encoding="utf-8")
print("hero_role dictionary repaired")
