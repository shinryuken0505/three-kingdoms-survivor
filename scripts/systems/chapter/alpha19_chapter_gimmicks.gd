class_name Alpha19ChapterGimmicks
extends RefCounted

const GIMMICKS := {
	"yellow_turban_zhuo":{"label":"民兵浪潮・黃巾符水", "merchant_time_mult":0.95, "hero_time_mult":0.92},
	"luoyang_turmoil":{"label":"烽火封路・百姓撤離", "merchant_time_mult":1.05, "hero_time_mult":0.96},
	"hulao_coalition":{"label":"虎牢軍陣・飛將追擊", "merchant_time_mult":1.08, "hero_time_mult":1.00},
	"xuzhou_flames":{"label":"糧道危機・陷陣衝鋒", "merchant_time_mult":0.96, "hero_time_mult":1.02},
	"guandu_showdown":{"label":"官渡糧秣・車陣壓境", "merchant_time_mult":1.12, "hero_time_mult":0.98},
	"jingzhou_retreat":{"label":"水網撤軍・百姓護送", "merchant_time_mult":0.94, "hero_time_mult":0.90},
	"chibi_battle":{"label":"東風火線・戰船連鎖", "merchant_time_mult":1.04, "hero_time_mult":0.94},
	"jingzhou_campaign":{"label":"城寨箭雨・老將試煉", "merchant_time_mult":1.06, "hero_time_mult":0.96},
	"hanzhong_campaign":{"label":"山道糧線・神速突襲", "merchant_time_mult":1.10, "hero_time_mult":0.98},
	"yiling_battle":{"label":"連營烈火・風向變化", "merchant_time_mult":1.08, "hero_time_mult":1.00},
	"wuzhang_plains":{"label":"星落五丈・深陣消耗", "merchant_time_mult":1.12, "hero_time_mult":1.04},
}

static func for_chapter(chapter_id: String) -> Dictionary:
	return (GIMMICKS.get(chapter_id, {"label":"亂世變局", "merchant_time_mult":1.0, "hero_time_mult":1.0}) as Dictionary).duplicate(true)
