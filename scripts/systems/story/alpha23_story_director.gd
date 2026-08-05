class_name Alpha23StoryDirector
extends RefCounted

const CHAPTER_STORIES := {
	"yellow_turban": {
		"opening": ["蒼天已死，黃巾遍野。", "你踏入亂世的第一步，將決定往後眾人如何看待你。"],
		"closing": ["黃巾雖退，天下卻再也回不到從前。"]
	},
	"luoyang": {
		"opening": ["洛陽烽煙四起，朝堂與街巷同樣危險。"],
		"closing": ["帝都化為灰燼，群雄開始各自盤算未來。"]
	},
	"hulao": {
		"opening": ["虎牢關前，諸侯並立，卻無人真正同心。"],
		"closing": ["關門已破，真正的爭雄才剛開始。"]
	},
	"xuzhou": {
		"opening": ["徐州百姓夾在軍勢之間，每一個選擇都有人付出代價。"],
		"closing": ["你留下的，不只是勝敗，還有百姓口中的名字。"]
	},
	"guandu": {
		"opening": ["官渡糧道決定北方歸屬，忠義與權謀在此交鋒。"],
		"closing": ["北方局勢已定，你的立場也逐漸無法隱藏。"]
	},
	"changban": {
		"opening": ["長坂坡上，追兵與百姓同時逼近你的選擇。"],
		"closing": ["有人記得你的武勇，也有人記得你是否回頭。"]
	},
	"red_cliffs": {
		"opening": ["東風將起，赤壁火光會照出所有人的野心。"],
		"closing": ["江火熄滅後，天下三分的輪廓已然浮現。"]
	},
	"jingzhou": {
		"opening": ["荊州是四戰之地，也是承諾最容易被撕碎的地方。"],
		"closing": ["城池易主，舊盟與新仇一同留下。"]
	},
	"hanzhong": {
		"opening": ["漢中山道險峻，誰掌此地，誰便握住入蜀咽喉。"],
		"closing": ["山河仍在，英雄的選擇卻已無法回頭。"]
	},
	"yiling": {
		"opening": ["夷陵連營延綿百里，復仇與天下大勢正面衝撞。"],
		"closing": ["烈火燒盡的不只是營帳，還有多年的盟誓。"]
	},
	"wuzhang": {
		"opening": ["五丈原秋風蕭瑟，所有選擇終將在此結算。"],
		"closing": ["星落原野，而你的名字將被後世如何書寫？"]
	}
}

static func chapter_scene(chapter_id: String, phase: String, route_state: Dictionary = {}) -> Dictionary:
	var data: Dictionary = CHAPTER_STORIES.get(chapter_id, {
		"opening": ["亂世又翻開新的一頁。"],
		"closing": ["戰火暫歇，但命運仍未停下。"]
	}).duplicate(true)
	var lines: Array = data.get(phase, []).duplicate()
	var dominant: String = str(route_state.get("dominant", "balanced"))
	if phase == "opening" and dominant != "balanced":
		lines.append(route_hint(dominant))
	return {
		"chapter_id": chapter_id,
		"phase": phase,
		"lines": lines,
		"speaker": "史官",
		"route": dominant
	}

static func route_hint(route_id: String) -> String:
	match route_id:
		"benevolence": return "你的仁義之名已傳入軍民耳中。"
		"ambition": return "眾人開始畏懼你的野心與決斷。"
		"loyalty": return "你對漢室與舊義的堅持，正牽動群雄態度。"
		"survival": return "你始終把活下去放在第一位，也因此更難被看透。"
		_: return "你的道路仍未定型。"
