class_name EndingData
extends RefCounted


static func definitions() -> Array[Dictionary]:
	return [
		{
			"id": "historical_witness",
			"title": "亂世見證者",
			"priority": 0,
			"requirements": {},
			"narration": "你走過黃巾、虎牢、官渡與赤壁，直到五丈原秋風止息。天下仍未真正安定，但你的名字已留在這段亂世之中。",
			"historian_comment": "史官曰：其人未必稱王，卻以一生見證群雄興替，亦足留名青史。",
			"unlock_rewards": ["ending_codex", "new_game_plus"]
		},
		{
			"id": "han_restoration",
			"title": "漢室中興",
			"priority": 80,
			"requirements": {"route_tag": "han", "min_momentum": 6},
			"narration": "你扶持漢室舊臣，保全百姓與義軍。星落五丈原後，未竟之志由你接續，天下重新看見漢旗。",
			"historian_comment": "史官曰：亂世中能守其義者少，能以義成事者更少。",
			"unlock_rewards": ["title_han_restorer", "new_game_plus"]
		},
		{
			"id": "wei_unification",
			"title": "魏武餘烈",
			"priority": 80,
			"requirements": {"route_tag": "wei", "min_momentum": 6},
			"narration": "你以法度、軍略與用人平定群雄，讓北方秩序延續至天下。",
			"historian_comment": "史官曰：治世須德，亂世亦須決斷。其功過，後人自有公論。",
			"unlock_rewards": ["title_northern_unifier", "new_game_plus"]
		},
		{
			"id": "wu_ascendant",
			"title": "江東長歌",
			"priority": 80,
			"requirements": {"route_tag": "wu", "min_momentum": 6},
			"narration": "你守住長江，也讓江東不再只是割據一隅。水師與民心成為重寫天下的力量。",
			"historian_comment": "史官曰：據江而守易，乘勢而興難。此人兼得其二。",
			"unlock_rewards": ["title_lord_of_jiangdong", "new_game_plus"]
		},
		{
			"id": "history_rewritten",
			"title": "改命之人",
			"priority": 100,
			"requirements": {"min_rewrite_rate": 0.65},
			"narration": "你沒有照著史書走。該死之人活了下來，原本的敵人成為盟友，而天下也因此走向從未存在過的未來。",
			"historian_comment": "史官曰：此後史書分作兩頁，一頁記天下，一頁只記此人。",
			"unlock_rewards": ["title_fate_breaker", "new_game_plus", "alternate_history_codex"]
		}
	]
