class_name GameData
extends RefCounted


static func chapters() -> Array:
	return [
		{
			"id": "yellow_turban_zhuo",
			"index": 0,
			"ready": true,
			"year": "中平元年・184",
			"title": "黃巾之亂",
			"place": "涿郡",
			"objective": "在黃巾軍勢中存活，尋找名將並迎戰人公將軍。",
			"intro": "黃巾四起，涿郡百姓自組鄉勇。你尚未名聞天下，卻已被捲入第一場亂世風暴。",
			"boss_time": 205.0,
			"active_limit": 2,
			"difficulty": 0.92,
			"ground_color": "#434e3e",
			"map_kind": "village",
			"map_shape": "open",
			"boundary_style": "palisade",
			"map_texture": "res://assets/maps/zhuo.png",
			"max_enemies": 34,
			"archer_cap": 3,
			"elite_start": 72.0,
			"camp_time": 72.0,
			"chest_time": 126.0,
			"merchant_time": 78.0,
			"enemy_weights": {"peasant": 0.42, "sword": 0.43, "archer": 0.10, "elite": 0.05},
			"boss":
			{
				"id": "zhangliang",
				"name": "張梁",
				"title": "人公將軍",
				"quote": "「蒼天已死！爾等還不醒悟！」",
				"hp": 1380.0,
				"speed": 64.0,
				"damage": 12.0,
				"radius": 42.0,
				"reward": "yellowwater"
			},
			"hero_pool":
			[
				"liubei",
				"guanyu",
				"zhangfei",
				"huatuo",
				"caocao",
				"sunjian",
				"taishici",
				"zhangjiao"
			]
		},
		{
			"id": "luoyang_turmoil",
			"index": 1,
			"ready": true,
			"year": "中平六年・189",
			"title": "洛陽風雲",
			"place": "帝都動亂",
			"objective": "破壞西涼烽火臺，護送逃離洛陽的百姓。",
			"intro": "帝崩而京師亂，董卓率西涼軍入洛陽。上一章留下的人脈，將改變本章的友軍與追兵。",
			"boss_time": 220.0,
			"active_limit": 2,
			"difficulty": 1.08,
			"ground_color": "#403d34",
			"map_kind": "capital",
			"map_shape": "crossroads",
			"boundary_style": "wall",
			"map_texture": "res://assets/maps/luoyang.png",
			"max_enemies": 40,
			"archer_cap": 4,
			"elite_start": 62.0,
			"camp_time": 70.0,
			"chest_time": 132.0,
			"merchant_time": 74.0,
			"enemy_weights": {"peasant": 0.20, "sword": 0.50, "archer": 0.20, "elite": 0.10},
			"boss":
			{
				"id": "huaxiong",
				"name": "華雄",
				"title": "西涼猛將",
				"quote": "「關東鼠輩，誰敢來試我刀鋒！」",
				"hp": 2150.0,
				"speed": 75.0,
				"damage": 15.0,
				"radius": 46.0,
				"reward": "ironbracer"
			},
			"hero_pool":
			[
				"caocao",
				"sunjian",
				"liubei",
				"guanyu",
				"zhangfei",
				"huatuo",
				"taishici",
				"diaochan",
				"zhenji",
				"lvlingqi",
				"caiwenji"
			]
		},
		{
			"id": "hulao_coalition",
			"index": 2,
			"ready": true,
			"year": "初平元年・190",
			"title": "虎牢關",
			"place": "諸侯會盟",
			"objective": "突破虎牢軍陣，在諸侯與飛將之間決定自己的道路。",
			"intro": "諸侯會盟討董，所有人都宣稱自己代表天下。虎牢關前，你將面對真正名震天下的武將。",
			"boss_time": 232.0,
			"active_limit": 3,
			"difficulty": 1.24,
			"ground_color": "#3c352d",
			"map_kind": "fortress",
			"map_shape": "narrow",
			"boundary_style": "wall",
			"map_texture": "res://assets/maps/hulao.png",
			"max_enemies": 46,
			"archer_cap": 5,
			"elite_start": 52.0,
			"camp_time": 66.0,
			"chest_time": 138.0,
			"merchant_time": 70.0,
			"enemy_weights":
			{"peasant": 0.04, "sword": 0.34, "archer": 0.12, "elite": 0.10, "cavalry": 0.10, "shield": 0.08, "crossbow": 0.08, "drummer": 0.06, "firepot": 0.04, "assassin": 0.04},
			"boss":
			{
				"id": "lvbu",
				"name": "呂布",
				"title": "人中呂布・飛將",
				"quote": "「鼠輩齊上，也省得我一個個追！」",
				"hp": 3560.0,
				"speed": 108.0,
				"damage": 22.0,
				"radius": 48.0,
				"reward": "redhare"
			},
			"hero_pool":
			[
				"liubei",
				"guanyu",
				"zhangfei",
				"caocao",
				"sunjian",
				"taishici",
				"huatuo",
				"diaochan",
				"sunshangxiang",
				"zhenji",
				"lvlingqi",
				"wangyi"
			]
		},
		{
			"id": "xuzhou_flames",
			"index": 3,
			"ready": true,
			"year": "興平元年・194",
			"title": "徐州烽火",
			"place": "下邳風雨",
			"objective": "穿越徐州戰火，護住補給線並擊破陷陣營。",
			"intro": "曹、劉、呂三方在徐州交錯。城門之內是權謀，城門之外是百姓與糧道。你的舊盟友未必仍站在同一邊。",
			"boss_time": 238.0,
			"active_limit": 3,
			"difficulty": 1.38,
			"ground_color": "#494238",
			"map_kind": "xuzhou",
			"map_shape": "courtyard",
			"boundary_style": "palisade",
			"map_texture": "res://assets/maps/xuzhou.png",
			"max_enemies": 50,
			"archer_cap": 5,
			"elite_start": 48.0,
			"camp_time": 62.0,
			"chest_time": 132.0,
			"merchant_time": 66.0,
			"enemy_weights":
			{
				"peasant": 0.03,
				"sword": 0.28,
				"archer": 0.10,
				"elite": 0.12,
				"cavalry": 0.13,
				"shield": 0.10,
				"crossbow": 0.06,
				"drummer": 0.06,
				"firepot": 0.07,
				"assassin": 0.05
			},
			"boss":
			{
				"id": "gaoshun",
				"name": "高順", "rarity":"rare",
				"title": "陷陣營統領",
				"quote": "「陷陣之志，有死無生！」",
				"hp": 3650.0,
				"speed": 80.0,
				"damage": 20.0,
				"radius": 49.0,
				"reward": "formationseal"
			},
			"hero_pool":
			[
				"liubei",
				"guanyu",
				"zhangfei",
				"caocao",
				"huatuo",
				"diaochan",
				"lvlingqi",
				"wangyi",
				"caiwenji",
				"sunshangxiang",
				"taishici"
			]
		},
		{
			"id": "guandu_showdown",
			"index": 4,
			"ready": true,
			"year": "建安五年・200",
			"title": "官渡之戰",
			"place": "河北爭雄",
			"objective": "守住糧道、擊破袁軍車陣，決定北方霸主。",
			"intro": "袁紹兵多糧足，曹操兵少而志決。官渡不是單純的強弱之爭，而是情報、糧草與人心的總決算。",
			"boss_time": 245.0,
			"active_limit": 3,
			"difficulty": 1.52,
			"ground_color": "#4b4938",
			"map_kind": "guandu",
			"map_shape": "supply_corridor",
			"boundary_style": "palisade",
			"map_texture": "res://assets/maps/guandu.png",
			"max_enemies": 54,
			"archer_cap": 6,
			"elite_start": 44.0,
			"camp_time": 60.0,
			"chest_time": 128.0,
			"merchant_time": 64.0,
			"enemy_weights":
			{
				"peasant": 0.02,
				"sword": 0.24,
				"archer": 0.10,
				"elite": 0.14,
				"cavalry": 0.10,
				"shield": 0.14,
				"crossbow": 0.08,
				"drummer": 0.07,
				"firepot": 0.05,
				"assassin": 0.06
			},
			"boss":
			{
				"id": "yuanshao",
				"name": "袁紹",
				"title": "河北盟主",
				"quote": "「四世三公之望，豈容寒門小吏撼動！」",
				"hp": 4300.0,
				"speed": 69.0,
				"damage": 21.0,
				"radius": 52.0,
				"reward": "grainledger"
			},
			"hero_pool":
			[
				"caocao",
				"zhenji",
				"caiwenji",
				"liubei",
				"guanyu",
				"zhangfei",
				"huatuo",
				"taishici"
			]
		},
		{
			"id": "jingzhou_retreat",
			"index": 5,
			"ready": true,
			"year": "建安十二年・207",
			"title": "荊州風雲",
			"place": "新野撤軍",
			"objective": "護送新野百姓撤離，在水網與火計間突破曹軍封鎖。",
			"intro": "北方大局已定，曹軍鋒芒南指。荊州表面安穩，暗地裡卻有降曹、守土與南逃三股力量彼此拉扯。",
			"boss_time": 250.0,
			"active_limit": 3,
			"difficulty": 1.64,
			"ground_color": "#38483d",
			"map_kind": "jingzhou",
			"map_shape": "river_channels",
			"boundary_style": "riverbank",
			"map_texture": "res://assets/maps/jingzhou.png",
			"max_enemies": 56,
			"archer_cap": 6,
			"elite_start": 40.0,
			"camp_time": 58.0,
			"chest_time": 124.0,
			"merchant_time": 62.0,
			"enemy_weights":
			{
				"peasant": 0.01,
				"sword": 0.18,
				"archer": 0.08,
				"elite": 0.10,
				"cavalry": 0.08,
				"shield": 0.10,
				"crossbow": 0.07,
				"drummer": 0.05,
				"firepot": 0.08,
				"assassin": 0.05,
				"spearman": 0.12,
				"tactician": 0.08
			},
			"boss":
			{
				"id": "caoren",
				"name": "曹仁",
				"title": "南征都督",
				"quote": "「曹軍所至，豈容你等從容退走！」",
				"hp": 4860.0,
				"speed": 82.0,
				"damage": 23.0,
				"radius": 52.0,
				"reward": "ironbracer"
			},
			"support_boss":
			{
				"id": "caimao",
				"name": "蔡瑁",
				"kind": "tactician",
				"sprite": "caimao",
				"hp": 1880.0,
				"damage": 18.0
			},
			"hero_pool":
			[
				"liubei",
				"guanyu",
				"zhangfei",
				"caocao",
				"huatuo",
				"caiwenji",
				"diaochan",
				"sunshangxiang",
				"daqiao",
				"taishici",
				"wangyi"
			]
		},
		{
			"id": "changban_escape",
			"index": 6,
			"ready": true,
			"year": "建安十三年・208",
			"title": "長坂坡",
			"place": "當陽追兵",
			"objective": "在曹軍騎兵合圍前護住民眾，穿越長坂橋與追兵軍陣。",
			"intro": "撤軍化為潰退，百姓、軍士與家眷散落長坂。此戰不只在於擊敗追兵，更在於你願意帶走多少人。",
			"boss_time": 258.0,
			"active_limit": 4,
			"difficulty": 1.76,
			"ground_color": "#50473a",
			"map_kind": "changban",
			"map_shape": "long_road",
			"boundary_style": "road",
			"map_texture": "res://assets/maps/changban.png",
			"max_enemies": 58,
			"archer_cap": 7,
			"elite_start": 36.0,
			"camp_time": 56.0,
			"chest_time": 120.0,
			"merchant_time": 60.0,
			"enemy_weights":
			{
				"peasant": 0.01,
				"sword": 0.14,
				"archer": 0.08,
				"elite": 0.12,
				"cavalry": 0.16,
				"shield": 0.08,
				"crossbow": 0.08,
				"drummer": 0.04,
				"firepot": 0.05,
				"assassin": 0.06,
				"spearman": 0.12,
				"tactician": 0.06
			},
			"boss":
			{
				"id": "zhanghe",
				"name": "張郃",
				"title": "巧變名將",
				"quote": "「陣勢已成，你還能護著多少人逃走？」",
				"hp": 5220.0,
				"speed": 101.0,
				"damage": 24.0,
				"radius": 50.0,
				"reward": "dilu"
			},
			"support_boss":
			{
				"id": "xiahouen",
				"name": "夏侯恩",
				"kind": "cavalry",
				"sprite": "xiahouen",
				"hp": 2050.0,
				"damage": 20.0
			},
			"hero_pool":
			[
				"liubei",
				"guanyu",
				"zhangfei",
				"caocao",
				"huatuo",
				"caiwenji",
				"sunshangxiang",
				"daqiao",
				"taishici",
				"lvlingqi",
				"wangyi"
			]
		},
		{
			"id": "red_cliffs",
			"index": 7,
			"ready": true,
			"year": "建安十三年・208",
			"title": "赤壁之戰",
			"place": "長江赤壁",
			"objective": "穿越火船與江面航道，在東風中擊破曹軍水寨。",
			"intro": "曹軍南下，孫劉聯軍背水一戰。江風、火攻與軍心將共同決定赤壁之夜。",
			"boss_time": 245.0,
			"active_limit": 4,
			"difficulty": 1.68,
			"ground_color": "#263b43",
			"map_kind": "river",
			"map_shape": "river_channels",
			"boundary_style": "wall",
			"map_texture": "res://assets/maps/redcliffs.png",
			"max_enemies": 58,
			"archer_cap": 7,
			"elite_start": 42.0,
			"camp_time": 74.0,
			"chest_time": 136.0,
			"merchant_time": 82.0,
			"enemy_weights": {"sword":0.24,"archer":0.16,"crossbow":0.15,"shield":0.12,"firepot":0.18,"tactician":0.15},
			"boss": {"id":"caocao","name":"曹操","title":"魏武揮鞭","quote":"「孤要這長江，也要這天下！」","hp":6900.0,"speed":88.0,"damage":27.0,"radius":52.0,"reward":"copperfan"},
			"support_boss": {"id":"zhangliao","name":"張遼","kind":"cavalry","sprite":"zhangliao","hp":2600.0,"damage":23.0},
			"hero_pool":["zhugeliang","zhouyu","zhaoyun","liubei","sunshangxiang","taishici","daqiao","huatuo"]
		},
		{
			"id": "jingzhou_campaign",
			"index": 8,
			"ready": true,
			"year": "建安十四年・209",
			"title": "荊州攻略",
			"place": "荊南四郡",
			"objective": "突破城寨與伏兵，奪取荊州立足之地。",
			"intro": "赤壁餘燼未熄，各方已爭奪荊州。山道、城門與老將的箭將考驗新生勢力。",
			"boss_time": 252.0,"active_limit":4,"difficulty":1.86,"ground_color":"#3d4933","map_kind":"fortress","map_shape":"courtyard","boundary_style":"wall","map_texture":"res://assets/maps/jingzhou_campaign.png","max_enemies":62,"archer_cap":8,"elite_start":38.0,"camp_time":76.0,"chest_time":140.0,"merchant_time":86.0,
			"enemy_weights":{"sword":0.28,"archer":0.20,"shield":0.16,"spearman":0.18,"tactician":0.10,"elite":0.08},
			"boss":{"id":"huangzhong","name":"黃忠","title":"長沙老將","quote":"「老夫弓刀未老，來將通名！」","hp":7600.0,"speed":86.0,"damage":29.0,"radius":50.0,"reward":"crossbow"},
			"hero_pool":["huangzhong","weiyan","zhugeliang","zhaoyun","guanyu","zhangfei","liubei","huatuo"]
		},
		{
			"id":"hanzhong_campaign","index":9,"ready":true,"year":"建安二十四年・219","title":"漢中之戰","place":"定軍山","objective":"沿山道奪取糧道，擊敗夏侯淵。","intro":"漢中是益州門戶。定軍山前，速度、補給與一次果斷突擊將改變天下三分。","boss_time":258.0,"active_limit":5,"difficulty":2.04,"ground_color":"#514835","map_kind":"mountain","map_shape":"supply_corridor","boundary_style":"palisade","map_texture":"res://assets/maps/hanzhong.png","max_enemies":66,"archer_cap":8,"elite_start":34.0,"camp_time":78.0,"chest_time":142.0,"merchant_time":90.0,
			"enemy_weights":{"sword":0.21,"archer":0.16,"cavalry":0.19,"shield":0.14,"spearman":0.17,"tactician":0.13},
			"boss":{"id":"xiahouyuan","name":"夏侯淵","title":"疾行將軍","quote":"「兵貴神速，今日便斷你歸路！」","hp":8500.0,"speed":116.0,"damage":31.0,"radius":51.0,"reward":"tigerseal"},
			"hero_pool":["huangzhong","fazheng","zhaoyun","zhugeliang","caocao","wangyi","caiwenji","huatuo"]
		},
		{
			"id":"yiling_battle","index":10,"ready":true,"year":"章武二年・222","title":"夷陵之戰","place":"猇亭連營","objective":"逃離蔓延的火線，在連營崩潰前擊敗陸遜。","intro":"復仇之師深入江東，營寨綿延百里。風向一轉，整片戰場都可能化為烈焰。","boss_time":264.0,"active_limit":5,"difficulty":2.22,"ground_color":"#4b382d","map_kind":"forest","map_shape":"long_road","boundary_style":"palisade","map_texture":"res://assets/maps/yiling.png","max_enemies":70,"archer_cap":9,"elite_start":30.0,"camp_time":80.0,"chest_time":146.0,"merchant_time":94.0,
			"enemy_weights":{"sword":0.20,"archer":0.18,"firepot":0.23,"assassin":0.12,"shield":0.12,"tactician":0.15},
			"boss":{"id":"luxun","name":"陸遜","title":"儒將火謀","quote":"「火勢既起，蜀軍已無退路。」","hp":9400.0,"speed":94.0,"damage":33.0,"radius":50.0,"reward":"formationseal"},
			"hero_pool":["luxun","sunshangxiang","zhouyu","taishici","daqiao","zhaoyun","zhugeliang","wangyi"]
		},
		{
			"id":"wuzhang_plains","index":11,"ready":true,"year":"建興十二年・234","title":"五丈原","place":"渭水秋風","objective":"突破魏軍深陣，在星落之前完成最後北伐。","intro":"多年征戰走到五丈原。糧道、星象與宿敵都在此等待，這是亂世人生的最終答卷。","boss_time":276.0,"active_limit":5,"difficulty":2.42,"ground_color":"#3e4036","map_kind":"plains","map_shape":"crossroads","boundary_style":"palisade","map_texture":"res://assets/maps/wuzhang.png","max_enemies":76,"archer_cap":10,"elite_start":26.0,"camp_time":82.0,"chest_time":150.0,"merchant_time":98.0,
			"enemy_weights":{"sword":0.18,"crossbow":0.16,"cavalry":0.16,"shield":0.16,"spearman":0.16,"tactician":0.18},
			"boss":{"id":"simayi","name":"司馬懿","title":"冢虎深謀","quote":"「能忍到最後的人，才配得到天下。」","hp":10800.0,"speed":92.0,"damage":36.0,"radius":54.0,"reward":"artofwar"},
			"support_boss":{"id":"zhanghe","name":"張郃","kind":"elite","sprite":"zhanghe","hp":3400.0,"damage":28.0},
			"hero_pool":["zhugeliang","zhaoyun","jiangwei","simayi","huangzhong","weiyan","caiwenji","huatuo"]
		}
	]


static func trial_chapter() -> Dictionary:
	return {
		"id": "flying_general_trial",
		"index": 0,
		"ready": true,
		"year": "演武",
		"title": "演武試煉",
		"place": "飛將挑戰",
		"objective": "在縮短的準備時間內完成配置並挑戰呂布。",
		"intro": "脫離史傳的演武試煉，用來測試名將、遺物與戰鬥配置。",
		"boss_time": 185.0,
		"active_limit": 3,
		"difficulty": 1.28,
		"ground_color": "#3f3933",
		"boss":
		{
			"id": "lvbu",
			"name": "呂布",
			"title": "人中呂布・飛將",
			"quote": "「鼠輩齊上，也省得我一個個追！」",
			"hp": 3560.0,
			"speed": 108.0,
			"damage": 22.0,
			"radius": 48.0
		},
		"hero_pool":
		[
			"diaochan",
			"sunshangxiang",
			"zhenji",
			"lvlingqi",
			"taishici",
			"huatuo",
			"guanyu",
			"zhangfei"
		]
	}


static func identities() -> Dictionary:
	return {
		"swordsman":
		{
			"name": "鄉勇刀客",
			"title": "涿郡鄉勇",
			"portrait": "res://assets/portraits/swordsman_default.png",
			"sprite": "res://assets/sprites/swordsman_default.png",
			"hp": 118.0,
			"speed": 198.0,
			"damage": 18.0,
			"attack_interval": 0.70,
			"weapon": "blade",
			"color": Color8(218, 173, 92),
			"desc": "刀勢穩健，近身範圍大，最適合初次投入亂世。"
		},
		"hunter":
		{
			"name": "北地獵戶",
			"title": "白羽逐風",
			"portrait": "res://assets/portraits/hunter_default.png",
			"sprite": "res://assets/sprites/hunter_default.png",
			"hp": 96.0,
			"speed": 216.0,
			"damage": 15.0,
			"attack_interval": 0.78,
			"weapon": "bow",
			"color": Color8(170, 213, 185),
			"desc": "長弓高射程、可穿透敵陣，擅長標記與遠距清怪。"
		},
		"poisoner":
		{
			"name": "游方毒醫",
			"title": "藥毒同源",
			"portrait": "res://assets/portraits/poisoner_default.png",
			"sprite": "res://assets/sprites/poisoner_default.png",
			"hp": 102.0,
			"speed": 204.0,
			"damage": 12.0,
			"attack_interval": 0.62,
			"weapon": "poison",
			"color": Color8(185, 224, 128),
			"desc": "毒針可疊毒、傳毒與引爆，但需管理自身藥毒值。"
		},
		"heroine":
		{
			"name": "巾幗遊俠",
			"title": "紅袖環刃",
			"portrait": "res://assets/portraits/heroine_default.png",
			"sprite": "res://assets/sprites/heroine_default.png",
			"hp": 104.0,
			"speed": 228.0,
			"damage": 14.0,
			"attack_interval": 0.58,
			"weapon": "rings",
			"color": Color8(232, 174, 190),
			"desc": "雙環連射、閃避靈活，適合穿梭敵陣與快速收割。"
		}
	}


static func heroes() -> Dictionary:
	return {
		"liubei":
		{
			"balance_tier": "S",
			"combat_role": "command",
			"cooldown_mult": 0.92,
			"identity": "仁德號召：泛用召喚與團隊續航。",
			"legendary": "昭烈之志：羈絆Lv5時義勇兵獲得護盾並延長存在時間。",
			"name": "劉備",
			"title": "仁德之主",
			"shout": "仁義所在，眾志成城！",
			"faction": "蜀",
			"portrait": "res://assets/portraits/liubei_default.png",
			"sprite": "res://assets/sprites/liubei_default.png",
			"cooldown": 12.0,
			"color": Color8(216, 192, 122),
			"active": "義勇同心：召喚三名義勇兵衝鋒，替玩家擋箭並牽制敵群。",
			"passive": "仁者聚眾：拾取範圍提高，回復品出現率小幅增加。",
			"signal": "草鞋、編席與百姓低聲議論仁義之名。"
		},
		"guanyu":
		{
			"balance_tier": "S",
			"combat_role": "melee",
			"cooldown_mult": 0.88,
			"identity": "武聖斬陣：高傷、破甲、對Boss穩定。",
			"legendary": "武聖：羈絆Lv5時青龍刀氣必定暴擊並縮短擊殺菁英後冷卻。",
			"name": "關羽",
			"title": "美髯公",
			"shout": "青龍偃月，破陣！",
			"faction": "蜀",
			"portrait": "res://assets/portraits/guanyu_default.png",
			"sprite": "res://assets/sprites/guanyu_default.png",
			"cooldown": 10.5,
			"color": Color8(67, 132, 94),
			"active": "青龍偃月：揮出巨大月牙刀氣，重創並破甲整片敵群。",
			"passive": "義薄雲天：對精英與Boss的傷害小幅提高。",
			"signal": "青布、長髯與沉重刀痕留在地面。"
		},
		"zhangfei":
		{
			"balance_tier": "S",
			"combat_role": "control",
			"cooldown_mult": 0.90,
			"identity": "萬軍控場：大範圍暈眩與擊退。",
			"legendary": "當陽斷喝：羈絆Lv5時震波追加第二圈。",
			"name": "張飛",
			"title": "燕人猛士",
			"shout": "燕人張翼德在此！",
			"faction": "蜀",
			"portrait": "res://assets/portraits/zhangfei_default.png",
			"sprite": "res://assets/sprites/zhangfei_default.png",
			"cooldown": 11.0,
			"color": Color8(211, 106, 69),
			"active": "燕人怒喝：大範圍震擊、暈眩並擊退附近所有敵人。",
			"passive": "當陽餘威：玩家被包圍時，定期觸發小型震退。",
			"signal": "酒罈碎片、丈八蛇矛痕與如雷怒吼。"
		},
		"huatuo":
		{
			"balance_tier": "B",
			"combat_role": "survival",
			"cooldown_mult": 1.00,
			"identity": "特殊生存核心：治療溢出轉護盾。",
			"legendary": "懸壺濟世：羈絆Lv5時治療會清除一個負面狀態。",
			"name": "華佗",
			"title": "青囊神醫",
			"shout": "青囊濟世，護佑生民！",
			"faction": "群",
			"portrait": "res://assets/portraits/huatuo_default.png",
			"sprite": "res://assets/sprites/huatuo_default.png",
			"cooldown": 14.0,
			"color": Color8(216, 229, 207),
			"active": "青囊濟世：治療、轉化溢出護盾，並以藥風推開周圍敵人。",
			"passive": "辨草識藥：回復品效果與掉落率略微提高。",
			"signal": "藥草香、布包與整齊的銀針。"
		},
		"caocao":
		{
			"balance_tier": "S",
			"combat_role": "command",
			"cooldown_mult": 0.92,
			"identity": "全隊循環核心：攻速與名將冷卻。",
			"legendary": "魏武揮鞭：羈絆Lv5時軍令額外召喚虎衛。",
			"name": "曹操",
			"title": "治世能臣",
			"shout": "天下英雄，盡入吾彀中！",
			"faction": "魏",
			"portrait": "res://assets/portraits/caocao_default.png",
			"sprite": "res://assets/sprites/caocao_default.png",
			"cooldown": 12.5,
			"color": Color8(156, 168, 192),
			"active": "唯才是舉：斬擊周圍敵人並發布軍令，短暫提高攻速與名將循環。",
			"passive": "亂世識才：升級時偶爾多看見一個選項。",
			"signal": "整齊馬蹄、黑羽令旗與敏銳的觀察視線。"
		},
		"sunjian":
		{
			"balance_tier": "A",
			"combat_role": "charge",
			"cooldown_mult": 0.96,
			"identity": "直線破陣與火場壓迫。",
			"legendary": "江東猛虎：羈絆Lv5時衝鋒終點追加猛虎震擊。",
			"name": "孫堅",
			"title": "江東猛虎",
			"shout": "江東猛虎，破陣！",
			"faction": "吳",
			"portrait": "res://assets/portraits/sunjian_default.png",
			"sprite": "res://assets/sprites/sunjian_default.png",
			"cooldown": 11.5,
			"color": Color8(215, 163, 75),
			"active": "猛虎破陣：鎖定敵群衝鋒，沿路撞飛敵人並在終點震擊。",
			"passive": "破虜先鋒：連續擊敗敵人後短暫提高移速。",
			"signal": "虎紋旗、折斷長槍與凌厲衝陣痕跡。"
		},
		"taishici":
		{
			"balance_tier": "A",
			"combat_role": "ranged",
			"cooldown_mult": 0.96,
			"identity": "穿透神射與遠程標記。",
			"legendary": "東萊神射：羈絆Lv5時箭矢命中Boss會分裂。",
			"name": "太史慈",
			"title": "東萊神射",
			"shout": "大丈夫當帶三尺之劍！",
			"faction": "吳",
			"portrait": "res://assets/portraits/taishici_default.png",
			"sprite": "res://assets/sprites/taishici_default.png",
			"cooldown": 10.8,
			"color": Color8(217, 224, 232),
			"active": "神射貫日：射出五支寬箭，自動微調方向並穿透敵陣。",
			"passive": "百步穿楊：遠距命中可標記敵人，使投射物追加少量傷害。",
			"signal": "白羽箭、遠射箭靶與清脆弓弦聲。"
		},
		"zhangjiao":
		{
			"balance_tier": "A",
			"combat_role": "ailment",
			"cooldown_mult": 0.97,
			"identity": "異常狀態與連鎖傳染核心。",
			"legendary": "黃天雷令：羈絆Lv5時雷擊會引爆中毒。",
			"name": "張角",
			"title": "大賢良師",
			"shout": "蒼天已死，黃天當立！",
			"faction": "黃巾",
			"portrait": "res://assets/portraits/zhangjiao_default.png",
			"sprite": "res://assets/sprites/zhangjiao_default.png",
			"cooldown": 13.0,
			"color": Color8(231, 212, 89),
			"active": "太平雷法：雷擊三處敵群並留下符水，減速、傳播異常狀態。",
			"passive": "眾疾相感：中毒敵人死亡時，有機會將毒傳給附近敵人。",
			"signal": "黃符、符水與遠處群眾低誦太平道。"
		},
		"diaochan":
		{
			"balance_tier": "B",
			"combat_role": "control",
			"cooldown_mult": 1.00,
			"identity": "特殊魅惑與事件提示。",
			"legendary": "閉月連環：羈絆Lv5時魅惑敵人死亡會返還冷卻。",
			"name": "貂蟬",
			"title": "閉月舞姬",
			"shout": "月影流光，亂其心神！",
			"faction": "群",
			"portrait": "res://assets/portraits/diaochan_default.png",
			"sprite": "res://assets/sprites/diaochan_default.png",
			"cooldown": 12.0,
			"color": Color8(235, 185, 204),
			"active": "閉月流光：舞袖牽引敵群，造成魅惑與連續光刃傷害。",
			"passive": "玲瓏心計：歷史事件的危險選項會出現模糊提示。",
			"signal": "月白絲帶、鈴聲與不知從何而來的舞步。"
		},
		"sunshangxiang":
		{
			"balance_tier": "A",
			"combat_role": "ranged",
			"cooldown_mult": 0.96,
			"identity": "移動射擊與閃避穿透。",
			"legendary": "弓腰烈火：羈絆Lv5時最後一箭必定引爆。",
			"name": "孫尚香",
			"title": "弓腰姬",
			"shout": "弓腰姬在此，退開！",
			"faction": "吳",
			"portrait": "res://assets/portraits/sunshangxiang_default.png",
			"sprite": "res://assets/sprites/sunshangxiang_default.png",
			"cooldown": 10.2,
			"color": Color8(236, 183, 108),
			"active": "弓腰連珠：移動射出十二支火箭，最後一箭爆裂。",
			"passive": "英姿颯爽：閃避後的下一次投射攻擊獲得額外穿透。",
			"signal": "朱紅短弓、女兵足跡與箭袋上的江東紋樣。"
		},
		"zhenji":
		{
			"balance_tier": "B",
			"combat_role": "control",
			"cooldown_mult": 1.00,
			"identity": "特殊冰控與受控增傷。",
			"legendary": "洛神凌波：羈絆Lv5時凍結敵人會生成護盾。",
			"name": "甄姬",
			"title": "洛水清音",
			"shout": "洛水凝霜，封！",
			"faction": "魏",
			"portrait": "res://assets/portraits/zhenji_default.png",
			"sprite": "res://assets/sprites/zhenji_default.png",
			"cooldown": 12.8,
			"color": Color8(205, 218, 242),
			"active": "洛水凝霜：擴散寒霧與冰環，減速並凍結敵群。",
			"passive": "清商餘韻：受控制敵人受到的傷害略微增加。",
			"signal": "寒玉、琴弦與水面般的淡藍光痕。"
		},
		"lvlingqi":
		{
			"balance_tier": "A",
			"combat_role": "mobility",
			"cooldown_mult": 0.95,
			"identity": "高速穿陣與低血爆發。",
			"legendary": "飛將血脈：羈絆Lv5時低血量技能追加一次折返。",
			"name": "呂玲綺",
			"title": "飛將之女",
			"shout": "飛將之血，絕不退讓！",
			"faction": "群",
			"portrait": "res://assets/portraits/lvlingqi_default.png",
			"sprite": "res://assets/sprites/lvlingqi_default.png",
			"cooldown": 10.0,
			"color": Color8(218, 161, 225),
			"active": "紫電連戟：高速穿梭敵陣，留下四道交錯戟光。",
			"passive": "飛將血脈：低生命時提高移速與擊退抗性。",
			"signal": "紫纓、細長戟痕與比騎兵更快的腳步。"
		},
		"wangyi":
		{
			"balance_tier": "B",
			"combat_role": "revenge",
			"cooldown_mult": 1.00,
			"identity": "低血逆境與回旋刃雙擊。",
			"legendary": "烈女雪恨：羈絆Lv5時低血量施放立即重置一次閃避。",
			"name": "王異",
			"title": "西涼烈女",
			"shout": "此刃只為雪恨！",
			"faction": "魏",
			"portrait": "res://assets/portraits/wangyi_default.png",
			"sprite": "res://assets/sprites/wangyi_default.png",
			"cooldown": 10.6,
			"color": Color8(197, 116, 126),
			"active": "烈刃雪恨：向四方投出短刃，命中後返回並造成第二次傷害。",
			"passive": "堅志不屈：生命低於一半時，提高護甲與暴擊率。",
			"signal": "斷裂短刃、染血披帛與冷冽的西涼風。"
		},
		"caiwenji":
		{
			"balance_tier": "B",
			"combat_role": "support",
			"cooldown_mult": 1.00,
			"identity": "特殊音波推退與章間經濟。",
			"legendary": "胡笳歸漢：羈絆Lv5時音波額外回復銅錢與護盾。",
			"name": "蔡文姬",
			"title": "胡笳才女",
			"shout": "胡笳一曲，安魂止戈！",
			"faction": "魏",
			"portrait": "res://assets/portraits/caiwenji_default.png",
			"sprite": "res://assets/sprites/caiwenji_default.png",
			"cooldown": 13.2,
			"color": Color8(192, 210, 187),
			"active": "胡笳清音：奏出三重音波，推退敵軍並回復少量生命。",
			"passive": "歸漢文心：章間保留的銅錢與回復品效益略微提高。",
			"signal": "胡笳聲、殘卷與北地歸來的車轍。"
		},
		"daqiao":
		{
			"balance_tier": "B",
			"combat_role": "utility",
			"cooldown_mult": 1.00,
			"identity": "特殊清彈幕、護盾與風刃。",
			"legendary": "流風國色：羈絆Lv5時清除投射物會轉化為花刃。",
			"name": "大喬",
			"title": "江東國色",
			"shout": "江風護陣，流花返刃！",
			"faction": "吳",
			"portrait": "res://assets/portraits/daqiao_default.png",
			"sprite": "res://assets/sprites/daqiao_default.png",
			"cooldown": 12.4,
			"color": Color8(229, 164, 174),
			"active": "流風花扇：展開花風屏障，抵消敵箭並向外反射風刃。",
			"passive": "江東柔風：商人與營地整備後獲得短暫移速加成。",
			"signal": "桃色羽扇、江風與輕柔卻堅定的步聲。"
		},
		"zhaoyun":{"name":"趙雲","title":"常山虎將","shout":"常山趙子龍在此！","faction":"蜀","portrait":"res://assets/portraits/zhaoyun_default.png","sprite":"res://assets/sprites/zhaoyun_default.png","cooldown":10.0,"color":Color8(210,224,236),"active":"七進七出：高速穿透敵陣，期間獲得霸體並留下槍芒。","passive":"一身是膽：生命越低，移速與傷害減免越高。","signal":"白袍、銀槍與護送百姓留下的足跡。"},
		"zhugeliang":{"name":"諸葛亮","title":"臥龍軍師","shout":"東風既至，火計可成！","faction":"蜀","portrait":"res://assets/portraits/zhugeliang_default.png","sprite":"res://assets/sprites/zhugeliang_default.png","cooldown":13.5,"color":Color8(168,199,218),"active":"八陣圖：展開陣法減速敵軍並持續造成策略傷害。","passive":"神機妙算：名將技能循環與事件判斷略微強化。","signal":"羽扇、木輪車轍與遠處若隱若現的茅廬。"},
		"zhouyu":{"name":"周瑜","title":"江東都督","shout":"東風借我，烈焰焚江！","faction":"吳","portrait":"res://assets/portraits/zhouyu_default.png","sprite":"res://assets/sprites/zhouyu_default.png","cooldown":11.8,"color":Color8(216,126,104),"active":"赤壁火計：沿風向引燃多道火線，火焰彼此連鎖。","passive":"雅量統軍：範圍技能與火焰效果略微提高。","signal":"都督令旗、琴音與江面飄來的焦木氣味。"},
		"huangzhong":{"name":"黃忠","title":"定軍老將","shout":"老將尚能開弓！","faction":"蜀","portrait":"res://assets/portraits/huangzhong_default.png","sprite":"res://assets/sprites/huangzhong_default.png","cooldown":10.6,"color":Color8(221,190,104),"active":"百步穿楊：鎖定最強敵人射出貫穿重箭。","passive":"老當益壯：戰鬥時間越久，暴擊率逐步提高。","signal":"沉重弓弦、黃羽箭與穩健腳步。"},
		"weiyan":{"name":"魏延","title":"奇襲猛將","shout":"誰敢擋我奇兵！","faction":"蜀","portrait":"res://assets/portraits/weiyan_default.png","sprite":"res://assets/sprites/weiyan_default.png","cooldown":10.4,"color":Color8(178,91,78),"active":"子午奇襲：從敵群側後方突入並造成連續斬擊。","passive":"險路先登：靠近戰場邊緣時提高傷害與移速。","signal":"偏離大道的足跡與突然中斷的哨聲。"},
		"fazheng":{"name":"法正","title":"蜀漢謀主","shout":"敵勢已破，乘隙而入！","faction":"蜀","portrait":"res://assets/portraits/fazheng_default.png","sprite":"res://assets/sprites/fazheng_default.png","cooldown":12.6,"color":Color8(132,157,112),"active":"定軍奇謀：標記精英與Boss弱點，提高其承受傷害。","passive":"睚眥明斷：危險事件的高收益選項更容易出現。","signal":"山勢草圖、密令與被刻意遮掩的營火。"},
		"luxun":{"name":"陸遜","title":"江東儒將","shout":"火借風勢，破敵千里！","faction":"吳","portrait":"res://assets/portraits/luxun_default.png","sprite":"res://assets/sprites/luxun_default.png","cooldown":12.2,"color":Color8(219,145,91),"active":"火燒連營：點燃多個區域，火區會沿敵群擴散。","passive":"後發制人：閃避後短暫提高技能傷害。","signal":"整齊火把、竹簡與克制沉穩的軍令。"},
		"simayi":{"name":"司馬懿","title":"冢虎","shout":"且看誰能笑到最後。","faction":"魏","portrait":"res://assets/portraits/simayi_default.png","sprite":"res://assets/sprites/simayi_default.png","cooldown":13.0,"color":Color8(118,120,150),"active":"冢虎伏勢：召出暗影軍陣，延遲後吞噬範圍內敵軍。","passive":"深藏不露：保留銅錢越多，技能冷卻略微縮短。","signal":"黑羽扇、未拆封的軍令與沉默過久的營帳。"},
		"jiangwei":{"name":"姜維","title":"天水麒麟兒","shout":"承丞相之志，再出祁山！","faction":"蜀","portrait":"res://assets/portraits/jiangwei_default.png","sprite":"res://assets/sprites/jiangwei_default.png","cooldown":10.8,"color":Color8(114,173,190),"active":"麒麟槍陣：連續突刺後召出扇形槍陣。","passive":"承志北伐：每完成一章，小幅提高名將傷害。","signal":"天水槍法、蜀軍令牌與反覆修改的北伐圖。"}
	}


static func merchant_types() -> Dictionary:
	# V2 alpha.5：第一階段商人重製。不同商人改變商品池與價格，而非只換標題。
	return {
		"peddler": {"name":"行商貨棧", "subtitle":"平價補給與一般貨物", "greeting":"路遠貨輕，喜歡就帶走。", "relic_count":3, "equipment_count":2, "price_mult":1.00, "min_rarity_rank":0, "sells_heal":true},
		"blacksmith": {"name":"流浪鐵匠", "subtitle":"武器與甲冑較多", "greeting":"好兵器，也得遇上配得起它的人。", "relic_count":1, "equipment_count":4, "price_mult":1.06, "min_rarity_rank":0, "sells_heal":false},
		"mysterious": {"name":"神秘商人", "subtitle":"高階珍品，價格不菲", "greeting":"有些東西，錯過便不會再見。", "relic_count":2, "equipment_count":3, "price_mult":1.35, "min_rarity_rank":2, "sells_heal":false},
		"quartermaster": {"name":"軍需官", "subtitle":"軍旗、護具與戰術用品", "greeting":"軍令如山，補給也不能少。", "relic_count":3, "equipment_count":3, "price_mult":0.96, "min_rarity_rank":0, "sells_heal":true},
		"antiquarian": {"name":"古董商", "subtitle":"敵將名物與戰場舊藏", "greeting":"這些舊物，可都沾過名將的血。", "relic_count":2, "equipment_count":3, "price_mult":1.20, "min_rarity_rank":1, "sells_heal":false}
	}


static func equipment() -> Dictionary:
	# V1.1：主角簡易裝備。圖示暫沿用既有遺物素材，後續可替換為專屬美術。
	return {
		"iron_blade": {"name":"環首刀","slot":"weapon","rarity":"common","source":"行商／鐵匠","recommended_hero":"刀客","set_id":"han_armory","story":"漢軍常備環首刀，樸實卻可靠。","unique_effect":"穩定提高基礎斬擊。","icon":"res://assets/relics/returningblade.png","desc":"攻擊傷害提高8%。","effects":{"damage_mult":1.08}},
		"serpent_spear": {"name":"丈八蛇矛","slot":"weapon","rarity":"epic","source":"張飛專屬掉落","recommended_hero":"張飛","set_id":"peach_oath","story":"燕人張飛所使長矛，勢如怒雷。","unique_effect":"擴張震波與擊退。","icon":"res://assets/relics/ironbracer.png","desc":"近戰範圍提高22%，擊退提高15%。","effects":{"melee_range_mult":1.22,"knock_mult":1.15},"bosses":["zhangfei"]},
		"green_dragon": {"name":"青龍偃月刀","slot":"weapon","rarity":"legendary","source":"關羽專屬掉落","recommended_hero":"關羽","set_id":"peach_oath","story":"偃月如青龍翻江，重在一擊定勝。","unique_effect":"大幅擴張近戰斬擊。","icon":"res://assets/relics/returningblade.png","desc":"傷害提高18%，每次近戰斬擊範圍大幅提高。","effects":{"damage_mult":1.18,"melee_range_mult":1.30},"bosses":["guanyu"]},
		"sky_halberd": {"name":"方天畫戟","slot":"weapon","rarity":"mythic","source":"呂布專屬掉落","recommended_hero":"呂布","set_id":"flying_general","story":"飛將所持重戟，非勇力絕倫者不可駕馭。","unique_effect":"以攻速換取極大範圍與威力。","icon":"res://assets/relics/ironbracer.png","desc":"傷害提高25%，攻速降低8%，攻擊範圍提高35%。","effects":{"damage_mult":1.25,"attack_speed_mult":0.92,"melee_range_mult":1.35},"bosses":["lvbu"]},
		"leather_armor": {"name":"精製皮甲","slot":"body","rarity":"common","icon":"res://assets/relics/ironbracer.png","desc":"受到傷害降低6%。","effects":{"damage_taken_mult":0.94}},
		"silver_lion": {"name":"白銀獅子鎧","slot":"body","rarity":"epic","icon":"res://assets/relics/ironbracer.png","desc":"受到傷害降低14%。","effects":{"damage_taken_mult":0.86}},
		"vine_armor": {"name":"藤甲","slot":"body","rarity":"rare","icon":"res://assets/relics/warbanner.png","desc":"箭矢傷害降低25%，火焰傷害提高15%。","effects":{"arrow_taken_mult":0.75,"fire_taken_mult":1.15}},
		"red_hare": {"name":"赤兔馬","slot":"treasure","rarity":"legendary","source":"呂布專屬掉落","recommended_hero":"呂布／關羽","set_id":"flying_general","story":"日行千里的赤色神駒。","unique_effect":"強化移動與閃避循環。","icon":"res://assets/relics/redhare.png","desc":"移速提高16%，閃避冷卻縮短12%。","effects":{"speed_mult":1.16,"dash_cd_mult":0.88},"bosses":["lvbu"]},
		"art_of_war_book": {"name":"孫子兵法","slot":"treasure","rarity":"epic","icon":"res://assets/relics/artofwar.png","desc":"經驗獲得提高15%，商店價格降低8%。","effects":{"xp_mult":1.15,"shop_price_mult":0.92}},
		"imperial_seal": {"name":"傳國玉璽","slot":"treasure","rarity":"mythic","source":"神秘商人／特殊事件","recommended_hero":"統帥型名將","set_id":"imperial","story":"受命於天，既壽永昌。","unique_effect":"加速名將循環並提供商業特權。","icon":"res://assets/relics/jade.png","desc":"名將冷卻縮短12%，每章首次商店刷新免費。","effects":{"hero_cd_mult":0.88,"free_refresh":1}},
		"qingnang_book": {"name":"青囊書","slot":"treasure","rarity":"rare","source":"華佗事件／古董商","recommended_hero":"華佗","set_id":"healer","story":"記載外科與養生之術的醫書。","unique_effect":"顯著強化所有治療。","icon":"res://assets/relics/qingnang.png","desc":"治療效果提高22%。","effects":{"heal_mult":1.22}},
		"tiger_tally": {"name":"魏武虎符","slot":"treasure","rarity":"legendary","source":"曹操專屬掉落","recommended_hero":"曹操","set_id":"wei_command","story":"調動精兵的軍令信物。","unique_effect":"名將技能循環加快，召喚傷害提高。","icon":"res://assets/relics/tigerseal.png","desc":"名將冷卻縮短10%，召喚傷害提高18%。","effects":{"hero_cd_mult":0.90,"summon_damage_mult":1.18},"bosses":["caocao"]},
		"fire_strategy": {"name":"火攻兵書","slot":"treasure","rarity":"epic","source":"周瑜／陸遜專屬掉落","recommended_hero":"周瑜／陸遜","set_id":"wu_fire","story":"記錄風勢、舟陣與連營火攻之法。","unique_effect":"火焰效果更猛烈。","icon":"res://assets/relics/artofwar.png","desc":"火焰傷害提高24%，範圍提高10%。","effects":{"fire_damage_mult":1.24,"area_mult":1.10},"bosses":["zhouyu","luxun"]},
		"yellow_heaven_scroll": {"name":"太平要術","slot":"treasure","rarity":"mythic","source":"張角專屬掉落","recommended_hero":"張角","set_id":"yellow_heaven","story":"黃天之道的異術殘卷。","unique_effect":"策略與毒系傷害同步強化。","icon":"res://assets/relics/poisonbag.png","desc":"毒與策略傷害提高22%。","effects":{"poison_damage_mult":1.22,"strategy_damage_mult":1.22},"bosses":["zhangjiao"]},
		"xiliang_armor": {"name":"西涼重鎧","slot":"body","rarity":"legendary","source":"董卓／西涼Boss掉落","recommended_hero":"重裝近戰","set_id":"xiliang","story":"西涼軍以厚鐵與獸皮打造的重鎧。","unique_effect":"大幅減傷，但稍降移速。","icon":"res://assets/relics/ironbracer.png","desc":"受到傷害降低20%，移速降低5%。","effects":{"damage_taken_mult":0.80,"speed_mult":0.95},"bosses":["dongzhuo"]},
		"swift_ring": {"name":"疾風指環","slot":"accessory","rarity":"rare","source":"精英／行商","icon":"res://assets/relics/dilu.png","desc":"攻速提高8%，閃避冷卻縮短6%。","effects":{"attack_speed_mult":1.08,"dash_cd_mult":0.94}},
		"soul_bead": {"name":"鎮魂珠","slot":"accessory","rarity":"epic","source":"術士精英／古董商","icon":"res://assets/relics/moonbell.png","desc":"受到傷害降低5%，控制抗性提高。","effects":{"damage_taken_mult":0.95,"control_duration_mult":0.78}},
		"army_pendant": {"name":"破軍墜","slot":"accessory","rarity":"epic","source":"Boss／神秘商人","icon":"res://assets/relics/tigerseal.png","desc":"對精英與Boss造成的傷害提高15%。","effects":{"elite_damage_mult":1.15,"boss_damage_mult":1.15}},
		"azure_jade": {"name":"青龍玉","slot":"jade","rarity":"legendary","source":"虎牢關後高階掉落","icon":"res://assets/relics/jade.png","desc":"近戰傷害提高18%，斬擊範圍提高12%。","effects":{"melee_damage_mult":1.18,"melee_range_mult":1.12}},
		"vermilion_jade": {"name":"朱雀玉","slot":"jade","rarity":"legendary","source":"赤壁相關Boss／事件","icon":"res://assets/relics/frostjade.png","desc":"火焰傷害提高25%，範圍提高10%。","effects":{"fire_damage_mult":1.25,"area_mult":1.10}},
		"black_jade": {"name":"玄武玉","slot":"jade","rarity":"legendary","source":"高階古董商／Boss","icon":"res://assets/relics/ironbracer.png","desc":"護盾效率提高20%，受到傷害降低8%。","effects":{"shield_mult":1.20,"damage_taken_mult":0.92}}
	}


static func relics() -> Dictionary:
	return {
		"bole_eye":
		{
			"name": "伯樂之眼", "rarity":"epic",
			"icon": "res://assets/relics/jade.png",
			"tags": ["招賢", "銅錢"],
			"desc": "每章第一次刷新招賢館名單不消耗銅錢。"
		},
		"qingnang":
		{
			"name": "青囊殘卷", "rarity":"rare",
			"icon": "res://assets/relics/qingnang.png",
			"tags": ["治療", "護盾"],
			"desc": "治療溢出時，溢出量的70%轉化為護盾。"
		},
		"arrowhead":
		{
			"name": "白羽箭簇", "rarity":"common",
			"icon": "res://assets/relics/arrowhead.png",
			"tags": ["投射物", "穿透"],
			"desc": "所有玩家投射物額外穿透1名敵人。"
		},
		"warbanner":
		{
			"name": "義軍旗", "rarity":"rare",
			"icon": "res://assets/relics/warbanner.png",
			"tags": ["名將", "冷卻"],
			"desc": "名將主動技能冷卻縮短10%。"
		},
		"ironbracer":
		{
			"name": "玄鐵護腕", "rarity":"common",
			"icon": "res://assets/relics/ironbracer.png",
			"tags": ["防禦"],
			"desc": "受到的普通傷害降低1點，最低仍為1點。"
		},
		"poisonbag":
		{
			"name": "五毒香囊",
			"icon": "res://assets/relics/poisonbag.png",
			"tags": ["毒", "範圍"],
			"desc": "中毒敵人死亡時留下短暫毒霧。"
		},
		"dilu":
		{
			"name": "的盧馬鞍",
			"icon": "res://assets/relics/dilu.png",
			"tags": ["移動", "閃避"],
			"desc": "移速提高6%，閃避冷卻縮短12%。"
		},
		"tigerseal":
		{
			"name": "殘缺虎符",
			"icon": "res://assets/relics/tigerseal.png",
			"tags": ["Boss", "名將"],
			"desc": "對Boss傷害提高12%，Boss登場時所有名將立即準備完成。"
		},
		"artofwar":
		{
			"name": "孫子兵法",
			"icon": "res://assets/relics/artofwar.png",
			"tags": ["升級", "策略"],
			"desc": "每次升級多顯示1個能力選項。"
		},
		"jade":
		{
			"name": "玉璽殘角",
			"icon": "res://assets/relics/jade.png",
			"tags": ["銅錢", "商人"],
			"desc": "拾取銅錢時額外獲得1枚，商人物品略微降價。"
		},
		"frostjade":
		{
			"name": "寒玉佩",
			"icon": "res://assets/relics/frostjade.png",
			"tags": ["控制", "冰霜"],
			"desc": "玩家攻擊有8%機率使敵人減速2秒。"
		},
		"crossbow":
		{
			"name": "連弩機括",
			"icon": "res://assets/relics/crossbow.png",
			"tags": ["攻速", "投射物"],
			"desc": "攻擊速度提高12%，但單次基礎傷害降低3%。"
		},
		"redhare":
		{
			"name": "赤兔馬蹄", "rarity":"epic",
			"icon": "res://assets/relics/redhare.png",
			"tags": ["閃避", "火焰"],
			"desc": "閃避路徑留下火痕，對接觸敵人造成傷害。"
		},
		"yellowwater":
		{
			"name": "黃巾符水", "rarity":"rare",
			"icon": "res://assets/relics/yellowwater.png",
			"tags": ["求生", "一次性"],
			"desc": "每章首次生命低於25%時，回復20生命並擊退敵人。"
		},
		"copperfan":
		{
			"name": "銅雀羽扇", "rarity":"epic",
			"icon": "res://assets/relics/copperfan.png",
			"tags": ["魅惑", "範圍"],
			"desc": "牽引、暈眩與凍結類效果持續時間提高18%。"
		},
		"moonbell":
		{
			"name": "月下銀鈴", "rarity":"rare",
			"icon": "res://assets/relics/moonbell.png",
			"tags": ["女性名將", "冷卻"],
			"desc": "女性名將的主動技能冷卻縮短12%。"
		},
		"formationseal":
		{
			"name": "陷陣軍印", "rarity":"epic",
			"icon": "res://assets/relics/formationseal.png",
			"tags": ["防禦", "名將"],
			"desc": "受到傷害時，所有主動名將冷卻縮短1.4秒；2秒內最多觸發一次。"
		},
		"grainledger":
		{
			"name": "烏巢糧簿", "rarity":"rare",
			"icon": "res://assets/relics/grainledger.png",
			"tags": ["銅錢", "經驗"],
			"desc": "每章前60秒，銅錢與經驗拾取量提高20%。"
		},
		"returningblade":
		{
			"name": "歸刃穗", "rarity":"epic",
			"icon": "res://assets/relics/returningblade.png",
			"tags": ["投射物", "暴擊"],
			"desc": "穿透或返回型投射物命中第二名敵人時，暴擊率提高15%。"
		},
		"swiftboots": {"name":"神行戰靴", "rarity":"common", "icon":"res://assets/relics/dilu.png", "tags":["移動","風險"], "desc":"移速提高10%，但最大生命降低8%。"},
		"bloodjade": {"name":"血紋古玉", "rarity":"rare", "icon":"res://assets/relics/jade.png", "tags":["暴擊","風險"], "desc":"暴擊率提高12%，受到的傷害提高6%。"},
		"veterandrum": {"name":"老卒戰鼓", "rarity":"rare", "icon":"res://assets/relics/warbanner.png", "tags":["擊殺","攻速"], "desc":"連續擊殺時逐步提高攻速，停止擊殺後消退。"},
		"smoketalisman": {"name":"煙遁符", "rarity":"common", "icon":"res://assets/relics/yellowwater.png", "tags":["閃避","控制"], "desc":"閃避結束時留下短暫煙霧，使附近敵人減速。"},
		"merchantseal": {"name":"行商信印", "rarity":"rare", "icon":"res://assets/relics/grainledger.png", "tags":["商人","刷新"], "desc":"行商每次多販售一件遺物，價格小幅提高。"},
		"brokenhalberd": {"name":"斷戟殘鋒", "rarity":"rare", "icon":"res://assets/relics/ironbracer.png", "tags":["近戰","範圍"], "desc":"近戰斬擊範圍提高18%，但攻擊間隔略微增加。"},
		"tacticianmap": {"name":"軍略殘圖", "rarity":"epic", "icon":"res://assets/relics/artofwar.png", "tags":["名將","策略"], "desc":"首次進入Boss戰時，隨機一名名將立即施放主動技能。"},
		"phoenixpin": {"name":"鳳羽金簪", "rarity":"epic", "icon":"res://assets/relics/moonbell.png", "tags":["女性名將","護盾"], "desc":"女性名將施放主動技能後，獲得少量護盾。"},
		"dragon_scale": {"name":"蒼龍逆鱗", "rarity":"epic", "icon":"res://assets/relics/qingnang.png", "tags":["防禦","近戰"], "desc":"每級降低4%受到傷害；Lv.3時近戰命中精英會獲得短暫護盾。", "damage_reduction":0.04},
		"thunder_token": {"name":"雷公令", "rarity":"epic", "icon":"res://assets/relics/yellowwater.png", "tags":["雷","控制"], "desc":"每級提高6%傷害；Lv.3時暴擊會對附近敵人彈射雷光。", "damage_bonus":0.06},
		"wolf_tally": {"name":"蒼狼兵符", "rarity":"rare", "icon":"res://assets/relics/tigerseal.png", "tags":["精英","追擊"], "desc":"每級提高5%攻擊與3%移速，擊敗精英後短暫加速。", "damage_bonus":0.05, "speed_bonus":0.03},
		"mirror_disc": {"name":"照膽銅鑑", "rarity":"rare", "icon":"res://assets/relics/copperfan.png", "tags":["控制抗性","護盾"], "desc":"控制持續時間降低；Lv.3時受控後立即獲得護盾。"},
		"wine_gourd": {"name":"杜康酒葫", "rarity":"rare", "icon":"res://assets/relics/poisonbag.png", "tags":["擊殺","回復"], "desc":"每級提高4%傷害，連續擊殺時小幅回復生命。", "damage_bonus":0.04},
		"scholar_scroll": {"name":"名士手札", "rarity":"common", "icon":"res://assets/relics/artofwar.png", "tags":["經驗","升級"], "desc":"每級提高4%攻擊速度；Lv.3時升級選項更容易出現未滿技能。", "attack_speed_bonus":0.04},
		"night_pearl": {"name":"滄海明珠", "rarity":"rare", "icon":"res://assets/relics/jade.png", "tags":["銅錢","拾取"], "desc":"每級提高3%移速與拾取效率，章末額外獲得銅錢。", "speed_bonus":0.03},
		"storm_drum": {"name":"霹靂戰鼓", "rarity":"epic", "icon":"res://assets/relics/warbanner.png", "tags":["攻速","名將"], "desc":"每級提高6%攻速；Lv.3時精英出現會縮短名將冷卻。", "attack_speed_bonus":0.06},
		"black_tortoise": {"name":"玄武甲片", "rarity":"epic", "icon":"res://assets/relics/ironbracer.png", "tags":["防禦","護盾"], "desc":"每級降低5%受到傷害，但移速略降。", "damage_reduction":0.05, "speed_bonus":-0.01},
		"phoenix_ember": {"name":"鳳凰餘燼", "rarity":"legendary", "icon":"res://assets/relics/moonbell.png", "tags":["火焰","重生"], "desc":"每級提高8%傷害；Lv.3時每章可免死一次並留下火海。", "damage_bonus":0.08},
		"seven_star_bead": {"name":"七星連珠", "rarity":"legendary", "icon":"res://assets/relics/moonbell.png", "tags":["技能","連攜"], "desc":"每級提高5%攻速與4%傷害；Lv.3時每第四次名將技能不進入完整冷卻。", "attack_speed_bonus":0.05, "damage_bonus":0.04},
		"imperial_edict": {"name":"漢室密詔", "rarity":"legendary", "icon":"res://assets/relics/warbanner.png", "tags":["名將","羈絆"], "desc":"每級提高5%傷害；Lv.3時後備名將被動效果提升。", "damage_bonus":0.05},
	}


static func skills() -> Dictionary:
	return {
		"damage": {"name": "百戰磨鋒", "desc": "所有玩家攻擊傷害提高15%。", "max": 5},
		"attack_speed": {"name": "疾如風", "desc": "攻擊速度提高12%。", "max": 5},
		"move_speed": {"name": "輕身步", "desc": "移動速度提高7%。", "max": 4},
		"max_hp": {"name": "強筋健骨", "desc": "最大生命提高15，並立即回復15。", "max": 4},
		"armor": {"name": "札甲加固", "desc": "受到的普通傷害降低1點。", "max": 4},
		"crit": {"name": "洞察破綻", "desc": "暴擊率提高5%。", "max": 5},
		"magnet": {"name": "眼觀六路", "desc": "拾取範圍提高45。", "max": 4},
		"dash": {"name": "踏雪無痕", "desc": "閃避冷卻縮短12%。", "max": 4},
		"hero_cd": {"name": "將星共鳴", "desc": "名將主動技能冷卻縮短8%。", "max": 5},
		"projectile": {"name": "勁矢穿雲", "desc": "投射物傷害提高12%，尺寸略增。", "max": 5},
		"pierce": {"name": "貫陣之勢", "desc": "投射物額外穿透1名敵人。", "max": 3},
		"poison": {"name": "百毒入經", "desc": "中毒傷害與傳播效率提高18%。", "max": 5},
		"multishot": {"name": "分光並進", "desc": "弓箭、毒針與環刃多射出1枚。", "max": 3},
		"heal": {"name": "調息養元", "desc": "回復效果提高18%，並小幅提高掉藥率。", "max": 4}
	}


static func bonds() -> Dictionary:
	return {
		"taoyuan":
		{
			"name": "桃園結義",
			"members": ["liubei", "guanyu", "zhangfei"],
			"hint": "三位涿郡豪傑並肩上陣。",
			"desc": "三人主動技能彼此縮短冷卻；依序施放後觸發義勇合擊。",
			"type": "active_all"
		},
		"white_dragon":
		{
			"name": "白羽青龍",
			"members": ["guanyu", "taishici"],
			"hint": "青龍刀光與白羽神箭同在前線。",
			"desc": "標記敵人被關羽刀氣命中時擴大斬擊；破甲敵人被箭矢命中時增加穿透。",
			"type": "active_all"
		},
		"tiger_archer":
		{
			"name": "破虜神射",
			"members": ["sunjian", "taishici"],
			"hint": "江東猛虎與東萊神射共同上陣。",
			"desc": "孫堅擊退敵群後，太史慈下一輪箭矢優先追擊並縮短孫堅冷卻。",
			"type": "active_all"
		},
		"benevolent_blade":
		{
			"name": "仁者與義士",
			"members": ["liubei", "guanyu"],
			"hint": "仁者在前，義士守於後援。",
			"desc": "劉備召喚的義勇兵首次命中精英時，附加關羽破甲。",
			"type": "active_reserve",
			"active": "liubei",
			"reserve": "guanyu"
		},
		"benevolent_roar":
		{
			"name": "仁者與猛士",
			"members": ["liubei", "zhangfei"],
			"hint": "仁者在前，燕人猛士留作後援。",
			"desc": "義勇兵受到包圍時，有冷卻地觸發小型震退。",
			"type": "active_reserve",
			"active": "liubei",
			"reserve": "zhangfei"
		},
		"doctor_warrior":
		{
			"name": "猛將名醫",
			"members": ["guanyu", "huatuo"],
			"hint": "猛將衝陣，名醫守於後方。",
			"desc": "猛將技能一次擊敗多名敵人時，提高下一個回復品品質。",
			"type": "active_reserve",
			"active_any": ["guanyu", "zhangfei"],
			"reserve": "huatuo"
		},
		"medicine_poison":
		{
			"name": "藥毒相生",
			"members": ["huatuo", "zhangjiao"],
			"hint": "神醫與太平道皆留在後方。",
			"desc": "中毒敵人掉落回復品時，藥品同時降低少量藥毒值。",
			"type": "reserve_all"
		},
		"closed_moon":
		{
			"name": "閉月洛神",
			"members": ["diaochan", "zhenji"],
			"hint": "月下舞姿與洛水清音同時上陣。",
			"desc": "魅惑與凍結可互相延長，受控制敵人承受更多傷害。",
			"type": "active_all"
		},
		"bow_princess":
		{
			"name": "弓腰白羽",
			"members": ["sunshangxiang", "taishici"],
			"hint": "弓腰姬在前，白羽神射留作後援。",
			"desc": "孫尚香閃避後的連珠箭獲得額外穿透與標記效果。",
			"type": "active_reserve",
			"active": "sunshangxiang",
			"reserve": "taishici"
		},
		"heroines":
		{
			"name": "巾幗並肩",
			"members": ["diaochan", "sunshangxiang", "lvlingqi"],
			"hint": "三位巾幗名將共同上陣。",
			"desc": "女性名將依序施放技能後，觸發一次巾幗合擊並獲得短暫閃避。",
			"type": "active_all"
		},
		"wenji_return":
		{
			"name": "文姬歸漢",
			"members": ["caocao", "caiwenji"],
			"hint": "曹操在前，胡笳才女留於後援。",
			"desc": "曹操發布軍令時，額外回復少量生命並延長攻速增益。",
			"type": "active_reserve",
			"active": "caocao",
			"reserve": "caiwenji"
		},
		"jiangdong_grace":
		{
			"name": "江東雙姝",
			"members": ["sunshangxiang", "daqiao"],
			"hint": "弓腰姬與江東國色共同上陣。",
			"desc": "火箭穿過花風屏障時，轉為更寬的燃燒風刃。",
			"type": "active_all"
		},
		"western_resolve":
		{
			"name": "西涼烈志",
			"members": ["wangyi", "lvlingqi"],
			"hint": "兩位西涼巾幗並肩破陣。",
			"desc": "其中一人施放技能後，另一人的主動技能冷卻縮短1.5秒。",
			"type": "active_all"
		}
	}


static func skins() -> Dictionary:
	return {
		"guanyu":
		[
			{
				"id": "default",
				"name": "青龍武聖",
				"portrait": "res://assets/portraits/guanyu_default.png",
				"sprite": "res://assets/sprites/guanyu_default.png",
				"owned": true,
				"tag": "預設"
			},
			{
				"id": "young",
				"name": "涿郡義勇",
				"portrait": "res://assets/portraits/guanyu_young.png",
				"sprite": "res://assets/sprites/guanyu_young.png",
				"owned": true,
				"tag": "免費示範造型"
			}
		],
		"diaochan":
		[
			{
				"id": "default",
				"name": "月白舞姬",
				"portrait": "res://assets/portraits/diaochan_default.png",
				"sprite": "res://assets/sprites/diaochan_default.png",
				"owned": true,
				"tag": "預設"
			},
			{
				"id": "red",
				"name": "紅綾舞姬",
				"portrait": "res://assets/portraits/diaochan_red.png",
				"sprite": "res://assets/sprites/diaochan_red.png",
				"owned": true,
				"tag": "免費示範造型"
			}
		],
		"sunshangxiang":
		[
			{
				"id": "default",
				"name": "預設造型",
				"portrait": "res://assets/portraits/sunshangxiang_default.png",
				"sprite": "res://assets/sprites/sunshangxiang_default.png",
				"owned": true,
				"tag": "預設・DLC欄位已預留"
			}
		],
		"zhenji":
		[
			{
				"id": "default",
				"name": "預設造型",
				"portrait": "res://assets/portraits/zhenji_default.png",
				"sprite": "res://assets/sprites/zhenji_default.png",
				"owned": true,
				"tag": "預設・DLC欄位已預留"
			}
		],
		"lvlingqi":
		[
			{
				"id": "default",
				"name": "預設造型",
				"portrait": "res://assets/portraits/lvlingqi_default.png",
				"sprite": "res://assets/sprites/lvlingqi_default.png",
				"owned": true,
				"tag": "預設・DLC欄位已預留"
			}
		],
		"wangyi":
		[
			{
				"id": "default",
				"name": "預設造型",
				"portrait": "res://assets/portraits/wangyi_default.png",
				"sprite": "res://assets/sprites/wangyi_default.png",
				"owned": true,
				"tag": "預設・DLC欄位已預留"
			}
		],
		"caiwenji":
		[
			{
				"id": "default",
				"name": "預設造型",
				"portrait": "res://assets/portraits/caiwenji_default.png",
				"sprite": "res://assets/sprites/caiwenji_default.png",
				"owned": true,
				"tag": "預設・DLC欄位已預留"
			}
		],
		"daqiao":
		[
			{
				"id": "default",
				"name": "預設造型",
				"portrait": "res://assets/portraits/daqiao_default.png",
				"sprite": "res://assets/sprites/daqiao_default.png",
				"owned": true,
				"tag": "預設・DLC欄位已預留"
			}
		],
		"zhaoyun":[{"id":"default","name":"常山白袍","portrait":"res://assets/portraits/zhaoyun_default.png","sprite":"res://assets/sprites/zhaoyun_default.png","owned":true,"tag":"預設・DLC欄位已預留"}],
		"zhugeliang":[{"id":"default","name":"臥龍羽扇","portrait":"res://assets/portraits/zhugeliang_default.png","sprite":"res://assets/sprites/zhugeliang_default.png","owned":true,"tag":"預設・DLC欄位已預留"}],
		"zhouyu":[{"id":"default","name":"江東都督","portrait":"res://assets/portraits/zhouyu_default.png","sprite":"res://assets/sprites/zhouyu_default.png","owned":true,"tag":"預設・DLC欄位已預留"}],
		"huangzhong":[{"id":"default","name":"定軍老將","portrait":"res://assets/portraits/huangzhong_default.png","sprite":"res://assets/sprites/huangzhong_default.png","owned":true,"tag":"預設・DLC欄位已預留"}],
		"weiyan":[{"id":"default","name":"奇襲猛將","portrait":"res://assets/portraits/weiyan_default.png","sprite":"res://assets/sprites/weiyan_default.png","owned":true,"tag":"預設・DLC欄位已預留"}],
		"fazheng":[{"id":"default","name":"蜀漢謀主","portrait":"res://assets/portraits/fazheng_default.png","sprite":"res://assets/sprites/fazheng_default.png","owned":true,"tag":"預設・DLC欄位已預留"}],
		"luxun":[{"id":"default","name":"儒將火謀","portrait":"res://assets/portraits/luxun_default.png","sprite":"res://assets/sprites/luxun_default.png","owned":true,"tag":"預設・DLC欄位已預留"}],
		"simayi":[{"id":"default","name":"冢虎深謀","portrait":"res://assets/portraits/simayi_default.png","sprite":"res://assets/sprites/simayi_default.png","owned":true,"tag":"預設・DLC欄位已預留"}],
		"jiangwei":[{"id":"default","name":"麒麟兒","portrait":"res://assets/portraits/jiangwei_default.png","sprite":"res://assets/sprites/jiangwei_default.png","owned":true,"tag":"預設・DLC欄位已預留"}]
	}
