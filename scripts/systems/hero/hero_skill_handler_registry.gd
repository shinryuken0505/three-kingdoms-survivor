class_name HeroSkillHandlerRegistry
extends RefCounted

const HANDLERS: Dictionary = {
	"thunder_roar":"zhangfei",
	"green_dragon_slash":"guanyu",
	"dragon_dash":"zhaoyun",
	"eight_trigrams":"zhugeliang",
	"qingnang_heal":"huatuo",
	"bow_waist_volley":"sunshangxiang",
	"red_cliff_flame":"zhouyu",
	"closed_moon_charm":"diaochan",
	"peerless_rampage":"lvbu",
}

static func handler_for(active_skill_id: String) -> String:
	return str(HANDLERS.get(active_skill_id, "general"))

static func validate(hero_definitions: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	for hero_id in hero_definitions.keys():
		var definition: Dictionary = hero_definitions[hero_id] as Dictionary
		var skill_id: String = str(definition.get("active_skill", ""))
		if skill_id == "":
			errors.append("%s missing active_skill" % hero_id)
	return errors
