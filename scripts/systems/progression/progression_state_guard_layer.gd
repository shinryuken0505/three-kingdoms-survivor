extends Node

## Alpha.18 主角成長資料校正層。
## 讀檔或技能資料變更後，移除無效技能並將等級限制在合法範圍內。

var _main: Node = null
var _last_signature: String = ""


func _ready() -> void:
	_main = get_parent()
	set_process(true)


func _process(_delta: float) -> void:
	if _main == null:
		return
	var skill_defs_value: Variant = _main.get("skill_defs")
	var skill_levels_value: Variant = _main.get("skill_levels")
	if not (skill_defs_value is Dictionary) or not (skill_levels_value is Dictionary):
		return
	var skill_defs: Dictionary = skill_defs_value as Dictionary
	var skill_levels: Dictionary = skill_levels_value as Dictionary
	var signature: String = _signature(skill_levels)
	if signature == _last_signature:
		return
	var changed: bool = _normalize(skill_defs, skill_levels)
	_last_signature = _signature(skill_levels)
	if changed:
		_main.set("skill_levels", skill_levels)
		if _main.has_method("queue_redraw"):
			_main.call("queue_redraw")


func _normalize(skill_defs: Dictionary, skill_levels: Dictionary) -> bool:
	var changed: bool = false
	var invalid_ids: Array[String] = []
	for value in skill_levels.keys():
		var skill_id: String = str(value)
		if not skill_defs.has(skill_id):
			invalid_ids.append(skill_id)
			continue
		var definition: Dictionary = skill_defs.get(skill_id, {}) as Dictionary
		var max_level: int = maxi(0, int(definition.get("max", 1)))
		var old_level: int = int(skill_levels.get(skill_id, 0))
		var safe_level: int = clampi(old_level, 0, max_level)
		if safe_level != old_level:
			skill_levels[skill_id] = safe_level
			changed = true
	for skill_id in invalid_ids:
		skill_levels.erase(skill_id)
		changed = true
	return changed


func _signature(skill_levels: Dictionary) -> String:
	var keys: Array[String] = []
	for value in skill_levels.keys():
		keys.append(str(value))
	keys.sort()
	var parts: Array[String] = []
	for skill_id in keys:
		parts.append("%s:%d" % [skill_id, int(skill_levels.get(skill_id, 0))])
	return "|".join(parts)
