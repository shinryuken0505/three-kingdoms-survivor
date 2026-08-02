class_name HistoryEventData
extends RefCounted


static func events() -> Dictionary:
	return {
		"yellow_turban_zhuo":
		[
			{
				"id": "zhuo_starving_villagers",
				"time": 48.0,
				"title": "黃巾道旁・饑民求糧",
				"text": "亂軍掠過村落，一群饑民守著病弱孩童。遠處黃巾斥候正逼近，你只能迅速作出決定。",
				"options":
				[
					{
						"text": "分出糧錢救濟",
						"detail": "消耗8枚銅錢，獲得民心；本章敵軍生成略為放緩。",
						"effect": "zhuo_relief",
						"cost": 8
					},
					{"text": "徵集壯丁守村", "detail": "立即獲得義勇護衛與少量護盾，但後續敵軍警戒提高。", "effect": "zhuo_militia"},
					{
						"text": "義診安民（劉備／華佗）",
						"detail": "不需花費，回復生命並提高最大生命；留下「仁心濟世」史勢。",
						"effect": "zhuo_mercy",
						"requires_any_heroes": ["liubei", "huatuo"],
						"requires_any_bonds": ["benevolent_blade", "doctor_warrior"]
					}
				]
			},
			{
				"id": "zhuo_oath_wine",
				"time": 122.0,
				"title": "涿郡酒肆・豪傑論世",
				"text": "殘破酒肆中仍留著幾甕濁酒。有人主張趁勢招兵，有人只願護住鄉里，眾人的選擇將決定義軍模樣。",
				"options":
				[
					{"text": "以酒犒軍", "detail": "花費10枚銅錢，所有主動名將立即縮短冷卻。", "effect": "zhuo_wine", "cost": 10},
					{"text": "封存糧酒備荒", "detail": "下一次營地回復效果提高，並獲得少量護盾。", "effect": "zhuo_store"},
					{
						"text": "同心立誓（桃園結義）",
						"detail": "取得義軍旗；本章對張梁的合作傷害提高。",
						"effect": "zhuo_oath",
						"requires_all_bonds": ["taoyuan"]
					}
				]
			}
		],
		"luoyang_turmoil":
		[
			{
				"id": "luoyang_secret_gate",
				"time": 52.0,
				"title": "洛陽暗巷・宮門密道",
				"text": "宮牆後傳來哭聲，一名內侍掌握通往城外的密道，卻也知道董卓軍庫的位置。",
				"options":
				[
					{"text": "護送宮人出城", "detail": "獲得護盾與情報；本章Boss生命略降。", "effect": "luoyang_rescue"},
					{"text": "轉入軍庫取資", "detail": "取得銅錢與遺物線索，但Boss攻擊略為提高。", "effect": "luoyang_treasure"},
					{
						"text": "胡笳引路（蔡文姬／貂蟬）",
						"detail": "安全帶人離城並迷惑追兵；名將技能立即縮短冷卻。",
						"effect": "luoyang_melody",
						"requires_any_heroes": ["caiwenji", "diaochan"],
						"requires_any_bonds": ["wenji_return"]
					}
				]
			},
			{
				"id": "luoyang_deposed_emperor",
				"time": 128.0,
				"title": "洛陽長街・廢帝車駕",
				"text": "被廢黜的車駕在西涼軍監視下穿過長街。民眾低頭不語，是否出手將直接表明你對漢室的態度。",
				"options":
				[
					{"text": "暗中護送車駕", "detail": "降低敵軍傷害，卻提高精英追兵數量。", "effect": "luoyang_guard_emperor"},
					{"text": "趁亂散布西涼軍令", "detail": "敵軍生成放緩，但Boss移速略增。", "effect": "luoyang_false_order"},
					{
						"text": "閉月調虎（貂蟬）",
						"detail": "引開西涼主力並取得一件遺物，華雄開場攻勢延後。",
						"effect": "luoyang_diaochan_decoy",
						"requires_all_heroes": ["diaochan"]
					}
				]
			}
		],
		"hulao_coalition":
		[
			{
				"id": "hulao_glory_dispute",
				"time": 58.0,
				"title": "諸侯帳前・誰先破關",
				"text": "盟軍諸侯爭論誰應率先出陣。主攻可揚名，護住側翼卻能保全更多士卒。",
				"options":
				[
					{"text": "請命擔任先鋒", "detail": "本章攻擊提高，但承受傷害也略增。", "effect": "hulao_vanguard"},
					{"text": "守住盟軍側翼", "detail": "獲得較多護盾，敵方箭矢上限下降。", "effect": "hulao_flank"},
					{
						"text": "三英請戰（桃園結義）",
						"detail": "對呂布的特殊合作強化提升，並削減其開場生命。",
						"effect": "hulao_three_heroes",
						"requires_all_heroes": ["liubei", "guanyu", "zhangfei"],
						"requires_all_bonds": ["taoyuan"]
					}
				]
			},
			{
				"id": "hulao_broken_banner",
				"time": 136.0,
				"title": "關前殘陣・破虜舊旗",
				"text": "盟軍前鋒遺下一面染血軍旗。重新豎旗能振奮軍心，但也會立刻引來虎牢關守軍。",
				"options":
				[
					{"text": "重豎盟軍旗", "detail": "名將冷卻加快，但敵軍數量短暫提高。", "effect": "hulao_raise_banner"},
					{"text": "拆旗製成護具", "detail": "獲得護盾並降低Boss普通攻擊傷害。", "effect": "hulao_banner_armor"},
					{
						"text": "猛虎奪旗（孫堅）",
						"detail": "孫堅率軍奪回旗幟，對呂布的首輪技能造成額外傷害。",
						"effect": "hulao_sunjian_banner",
						"requires_all_heroes": ["sunjian"]
					}
				]
			}
		],
		"xuzhou_flames":
		[
			{
				"id": "xuzhou_refugees",
				"time": 54.0,
				"title": "下邳風雨・百姓與糧車",
				"text": "城門將閉，百姓與軍糧只能先保一方。遠處陷陣營已整隊逼近。",
				"options":
				[
					{"text": "先護送百姓", "detail": "回復生命並獲得民心；本章生成節奏略緩。", "effect": "xuzhou_people"},
					{"text": "先保住軍糧", "detail": "獲得銅錢與攻擊強化，但Boss援軍略多。", "effect": "xuzhou_grain"},
					{
						"text": "仁醫分路（劉備＋華佗）",
						"detail": "同時保住部分百姓與糧車，營地回復效果提升。",
						"effect": "xuzhou_benevolent_route",
						"requires_all_heroes": ["liubei", "huatuo"]
					}
				]
			},
			{
				"id": "xuzhou_halberd_truce",
				"time": 132.0,
				"title": "轅門之外・一戟止兵",
				"text": "兩軍即將混戰，一名使者提出以射戟定和。你可以接受短暫停戰，也可趁對方遲疑先發制人。",
				"options":
				[
					{"text": "接受短暫停戰", "detail": "敵軍生成明顯放緩，但Boss生命維持完整。", "effect": "xuzhou_truce"},
					{"text": "趁勢奪取軍械", "detail": "獲得銅錢與傷害提升，Boss援軍增加。", "effect": "xuzhou_seize_arms"},
					{
						"text": "飛將舊情（貂蟬／呂玲綺）",
						"detail": "使陷陣營遲疑，降低高順速度並延後盾兵援軍。",
						"effect": "xuzhou_lv_family",
						"requires_any_heroes": ["diaochan", "lvlingqi"]
					}
				]
			}
		],
		"guandu_showdown":
		[
			{
				"id": "guandu_wuchao_intel",
				"time": 56.0,
				"title": "官渡密報・烏巢糧屯",
				"text": "一名降卒帶來烏巢糧屯的路線。這可能是扭轉戰局的機會，也可能是袁軍設下的圈套。",
				"options":
				[
					{"text": "冒險奇襲烏巢", "detail": "袁紹開場生命下降，但本章精英出現率提高。", "effect": "guandu_raid"},
					{"text": "固守本軍糧道", "detail": "獲得遺物與護盾，Boss能力維持完整。", "effect": "guandu_supply"},
					{
						"text": "孟德決斷（曹操）",
						"detail": "奇襲成功率大增，袁紹援軍與開場生命大幅下降。",
						"effect": "guandu_caocao",
						"requires_all_heroes": ["caocao"]
					}
				]
			},
			{
				"id": "guandu_xuyou_night",
				"time": 134.0,
				"title": "官渡夜帳・故人投奔",
				"text": "一名熟知袁軍虛實的故人深夜投奔。他的情報價值極高，但也可能是誘敵之計。",
				"options":
				[
					{"text": "收下情報立即出兵", "detail": "Boss生命下降，但敵軍傷害提高。", "effect": "guandu_accept_intel"},
					{"text": "反覆核驗再行動", "detail": "降低敵軍精英數量，失去部分奇襲優勢。", "effect": "guandu_verify_intel"},
					{
						"text": "識人用人（曹操＋蔡文姬）",
						"detail": "辨明情報真偽，降低袁紹援軍並取得額外遺物。",
						"effect": "guandu_trust_talent",
						"requires_all_heroes": ["caocao", "caiwenji"]
					}
				]
			}
		],
		"jingzhou_retreat":
		[
			{
				"id": "jingzhou_burning_fields",
				"time": 58.0,
				"title": "新野郊外・焦土與糧倉",
				"text": "曹軍逼近，新野糧倉來不及全數帶走。留下可能資敵，焚毀卻會讓逃難百姓失去口糧。",
				"options":
				[
					{"text": "分糧給百姓後撤離", "detail": "回復生命並降低本章敵軍生成速度。", "effect": "jingzhou_share_grain"},
					{"text": "設伏後焚毀糧倉", "detail": "Boss生命下降，但火油兵與策士出現率提高。", "effect": "jingzhou_burn_grain"},
					{
						"text": "仁德安民（劉備＋蔡文姬）",
						"detail": "安撫百姓並整編車隊，獲得最大生命與護盾。",
						"effect": "jingzhou_benevolent_convoy",
						"requires_all_heroes": ["liubei", "caiwenji"]
					}
				]
			},
			{
				"id": "jingzhou_river_crossing",
				"time": 142.0,
				"title": "漢水支流・舟橋抉擇",
				"text": "臨時舟橋只能先送一批人過河。遠處蔡瑁水軍已沿岸封鎖，時間越拖越危險。",
				"options":
				[
					{"text": "先送百姓過河", "detail": "降低敵軍傷害，但曹軍精銳提前抵達。", "effect": "jingzhou_people_first"},
					{"text": "先送軍械過河", "detail": "提高攻擊與穿透，Boss速度略升。", "effect": "jingzhou_arms_first"},
					{
						"text": "江東水路（大喬／孫尚香）",
						"detail": "借江東船工開闢支流，削弱蔡瑁並取得遺物。",
						"effect": "jingzhou_wu_route",
						"requires_any_heroes": ["daqiao", "sunshangxiang"]
					}
				]
			}
		],
		"changban_escape":
		[
			{
				"id": "changban_scattered_people",
				"time": 54.0,
				"title": "長坂亂軍・散落家眷",
				"text": "追兵已至，路旁仍有失散家眷與傷兵。回頭救人會拖慢撤離，但置之不理將改變眾人對你的看法。",
				"options":
				[
					{"text": "回頭護送傷兵", "detail": "獲得友軍與護盾，敵軍上限略增。", "effect": "changban_rescue_wounded"},
					{"text": "集中兵力開路", "detail": "提高移速與傷害，但受到傷害增加。", "effect": "changban_breakthrough"},
					{
						"text": "同心護民（桃園結義）",
						"detail": "三路分兵接應，降低騎兵數量並強化營地回復。",
						"effect": "changban_taoyuan_rescue",
						"requires_all_bonds": ["taoyuan"]
					}
				]
			},
			{
				"id": "changban_bridge_standoff",
				"time": 146.0,
				"title": "長坂橋前・斷後之人",
				"text": "橋後煙塵漫天，必須有人留下斷後。守橋能爭取時間，拆橋則可能把尚未過河的人也留在彼岸。",
				"options":
				[
					{"text": "列陣守橋", "detail": "Boss傷害下降，但長槍兵與弩兵增援。", "effect": "changban_hold_bridge"},
					{"text": "拆橋阻敵", "detail": "Boss速度下降，營地回復效果降低。", "effect": "changban_break_bridge"},
					{
						"text": "燕人斷喝（張飛）",
						"detail": "張飛獨守橋頭，張郃與夏侯恩開場生命下降。",
						"effect": "changban_zhangfei_bridge",
						"requires_all_heroes": ["zhangfei"]
					}
				]
			}
		]
	}
