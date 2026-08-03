class_name StatusEffectPresenter
extends RefCounted

## 將狀態 ViewModel 轉為可直接繪製的 HUD 資料。
##
## 圖示尚未匯入時提供字形與色彩備援，避免素材缺失就整塊消失；
## 名稱與說明統一經 TranslationServer 取值，找不到翻譯時退回狀態 ID。

const FALLBACK_GLYPHS: Dictionary = {
	StatusEffectDefs.POISON: "毒",
	StatusEffectDefs.BURN: "炎",
	StatusEffectDefs.SLOW: "緩",
	StatusEffectDefs.STUN: "暈",
	StatusEffectDefs.SMOKE: "煙",
	StatusEffectDefs.SILENCE: "封",
	StatusEffectDefs.BLEED: "血",
	StatusEffectDefs.VULNERABLE: "破",
}

const FALLBACK_COLORS: Dictionary = {
	StatusEffectDefs.POISON: Color8(117, 176, 88),
	StatusEffectDefs.BURN: Color8(224, 112, 66),
	StatusEffectDefs.SLOW: Color8(100, 164, 203),
	StatusEffectDefs.STUN: Color8(229, 197, 72),
	StatusEffectDefs.SMOKE: Color8(126, 126, 136),
	StatusEffectDefs.SILENCE: Color8(150, 108, 180),
	StatusEffectDefs.BLEED: Color8(187, 65, 70),
	StatusEffectDefs.VULNERABLE: Color8(218, 151, 68),
}


static func present(view_models: Array, locale: String = "") -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in view_models:
		var model: Dictionary = value as Dictionary
		var status_id := StringName(model.get("id", &""))
		var item: Dictionary = model.duplicate(true)
		item["name"] = translated_text(StringName(model.get("name_key", &"")), status_id, locale)
		item["description"] = translated_text(StringName(model.get("desc_key", &"")), status_id, locale)
		item["glyph"] = str(FALLBACK_GLYPHS.get(status_id, "?"))
		item["fallback_color"] = FALLBACK_COLORS.get(status_id, Color8(120, 120, 120))
		item["icon_available"] = icon_exists(str(model.get("icon_path", "")))
		item["stack_text"] = stack_text(int(model.get("stacks", 1)))
		item["tooltip"] = tooltip_text(item)
		result.append(item)
	return result


static func translated_text(key: StringName, fallback_id: StringName, locale: String = "") -> String:
	if key.is_empty():
		return humanize_id(fallback_id)
	var translated: String = TranslationServer.translate(String(key), locale)
	if translated == String(key):
		return humanize_id(fallback_id)
	return translated


static func icon_exists(path: String) -> bool:
	if path.is_empty():
		return false
	return ResourceLoader.exists(path) or FileAccess.file_exists(path)


static func stack_text(stacks: int) -> String:
	return "" if stacks <= 1 else "×%d" % stacks


static func tooltip_text(item: Dictionary) -> String:
	var title: String = str(item.get("name", ""))
	var description: String = str(item.get("description", ""))
	var duration: float = maxf(0.0, float(item.get("duration", 0.0)))
	var duration_line: String = "%.1f 秒" % duration
	if description.is_empty() or description == title:
		return "%s｜%s" % [title, duration_line]
	return "%s｜%s｜%s" % [title, description, duration_line]


static func humanize_id(status_id: StringName) -> String:
	var text: String = String(status_id).replace("_", " ").strip_edges()
	return text.capitalize() if not text.is_empty() else "Status"
