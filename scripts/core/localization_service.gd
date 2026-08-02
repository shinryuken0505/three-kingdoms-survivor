class_name LocalizationService
extends RefCounted

## 專案文字本地化的單一入口。
##
## 程式識別字與翻譯 key 使用英文；文件與必要註解使用繁體中文。
## UI 不應直接依賴中文文字做流程判斷，應依賴穩定 ID。

const DEFAULT_LOCALE: String = "zh_TW"
const SUPPORTED_LOCALES: PackedStringArray = PackedStringArray([
	"zh_TW",
	"zh_CN",
	"en",
	"ja",
])


static func normalize_locale(locale: String) -> String:
	var value: String = locale.replace("-", "_")
	if value.begins_with("zh_Hant") or value.begins_with("zh_TW") or value.begins_with("zh_HK"):
		return "zh_TW"
	if value.begins_with("zh_Hans") or value.begins_with("zh_CN") or value.begins_with("zh_SG"):
		return "zh_CN"
	if value.begins_with("ja"):
		return "ja"
	if value.begins_with("en"):
		return "en"
	return DEFAULT_LOCALE


static func set_locale(locale: String) -> String:
	var normalized: String = normalize_locale(locale)
	TranslationServer.set_locale(normalized)
	return normalized


static func current_locale() -> String:
	return normalize_locale(TranslationServer.get_locale())


static func text(key: StringName, fallback: String = "") -> String:
	var translated: String = tr(key)
	if translated == String(key):
		return fallback if fallback != "" else String(key)
	return translated


static func format(key: StringName, values: Dictionary, fallback: String = "") -> String:
	var result: String = text(key, fallback)
	for value_key in values:
		result = result.replace("{%s}" % str(value_key), str(values[value_key]))
	return result


static func locale_display_name(locale: String) -> String:
	match normalize_locale(locale):
		"zh_TW":
			return "繁體中文"
		"zh_CN":
			return "简体中文"
		"en":
			return "English"
		"ja":
			return "日本語"
	return locale
