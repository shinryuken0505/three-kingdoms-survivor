extends RefCounted

enum BossState { LOCKED, INTRO, ACTIVE, DEFEATED, RESOLVED }

var story_chapters: Array = []
var trial_definition: Dictionary = {}
var mode: String = "story"
var current_index: int = 0
var boss_state: int = BossState.LOCKED
var completed_chapters: Array[String] = []

func configure(story_defs: Array, trial_def: Dictionary) -> void:
	story_chapters = story_defs.duplicate(true)
	trial_definition = trial_def.duplicate(true)

func start_campaign(new_mode: String) -> void:
	mode = new_mode
	current_index = 0
	completed_chapters.clear()
	reset_current_chapter_state()

func restore_campaign(new_mode: String, restored_index: int, restored_completed: Array, restored_boss_state: int) -> void:
	mode = new_mode
	if mode == "trial":
		current_index = 0
	else:
		current_index = clampi(restored_index, 0, max(0, story_chapters.size() - 1))
	completed_chapters.clear()
	for chapter_id in restored_completed:
		var id: String = str(chapter_id)
		if id != "" and not completed_chapters.has(id):
			completed_chapters.append(id)
	boss_state = clampi(restored_boss_state, BossState.LOCKED, BossState.RESOLVED)

func current_index_value() -> int:
	return current_index

func completed_ids() -> Array[String]:
	return completed_chapters.duplicate()

func reset_current_chapter_state() -> void:
	boss_state = BossState.LOCKED

func current() -> Dictionary:
	if mode == "trial":
		return trial_definition
	if current_index < 0 or current_index >= story_chapters.size():
		return {}
	return story_chapters[current_index]

func current_id() -> String:
	return str(current().get("id", ""))

func current_title() -> String:
	var chapter: Dictionary = current()
	return "%s・%s" % [str(chapter.get("title", "未知章回")), str(chapter.get("place", "未知地點"))]

func active_limit() -> int:
	return int(current().get("active_limit", 2))

func boss_time() -> float:
	return float(current().get("boss_time", 240.0))

func difficulty() -> float:
	return float(current().get("difficulty", 1.0))

func hero_pool() -> Array:
	var chapter: Dictionary = current()
	var pool_value: Variant = chapter.get("hero_pool", [])
	if pool_value is Array:
		return (pool_value as Array).duplicate()
	return []

func boss_definition() -> Dictionary:
	var chapter: Dictionary = current()
	var boss_value: Variant = chapter.get("boss", {})
	if boss_value is Dictionary:
		return (boss_value as Dictionary).duplicate(true)
	return {}

func request_boss_intro(elapsed_seconds: float) -> bool:
	if boss_state != BossState.LOCKED:
		return false
	if elapsed_seconds < boss_time():
		return false
	boss_state = BossState.INTRO
	return true

func mark_boss_active() -> bool:
	if boss_state != BossState.INTRO:
		return false
	boss_state = BossState.ACTIVE
	return true

func mark_boss_defeated() -> bool:
	if boss_state != BossState.ACTIVE and boss_state != BossState.INTRO:
		return false
	boss_state = BossState.DEFEATED
	return true

func resolve_chapter() -> bool:
	if boss_state != BossState.DEFEATED:
		return false
	boss_state = BossState.RESOLVED
	var id: String = current_id()
	if id != "" and not completed_chapters.has(id):
		completed_chapters.append(id)
	return true

func boss_is_locked() -> bool:
	return boss_state == BossState.LOCKED

func boss_is_intro() -> bool:
	return boss_state == BossState.INTRO

func boss_is_active() -> bool:
	return boss_state == BossState.ACTIVE

func boss_is_defeated() -> bool:
	return boss_state == BossState.DEFEATED

func boss_is_resolved() -> bool:
	return boss_state == BossState.RESOLVED

func boss_state_value() -> int:
	return boss_state

func boss_is_visible() -> bool:
	return boss_state == BossState.INTRO or boss_state == BossState.ACTIVE

func boss_is_finished() -> bool:
	return boss_state == BossState.DEFEATED or boss_state == BossState.RESOLVED

func has_next_chapter() -> bool:
	return mode == "story" and current_index + 1 < story_chapters.size()

func is_final_chapter() -> bool:
	return mode == "story" and not story_chapters.is_empty() and current_index == story_chapters.size() - 1

func campaign_is_completed() -> bool:
	return is_final_chapter() and boss_state == BossState.RESOLVED

func next_chapter() -> Dictionary:
	if not has_next_chapter():
		return {}
	return story_chapters[current_index + 1]

func next_chapter_ready() -> bool:
	return bool(next_chapter().get("ready", false))

func find_chapter_index(chapter_id: String) -> int:
	for index in range(story_chapters.size()):
		if str((story_chapters[index] as Dictionary).get("id", "")) == chapter_id:
			return index
	return -1

func advance_to_id(chapter_id: String) -> bool:
	# Alpha.46：歷史分支可指定下一章。仍要求本章已完成，避免戰鬥中任意跳章。
	if mode != "story" or boss_state != BossState.RESOLVED:
		return false
	var target_index: int = find_chapter_index(chapter_id)
	if target_index < 0 or target_index == current_index:
		return false
	current_index = target_index
	reset_current_chapter_state()
	return true

func advance_to_next() -> bool:
	if boss_state != BossState.RESOLVED:
		return false
	if not has_next_chapter():
		return false
	current_index += 1
	reset_current_chapter_state()
	return true

func can_finalize_chapter() -> bool:
	return boss_state == BossState.DEFEATED

func can_finalize_campaign() -> bool:
	return is_final_chapter() and can_finalize_chapter()

func finalize_campaign() -> bool:
	if not can_finalize_campaign():
		return false
	return resolve_chapter()

func boss_state_label() -> String:
	match boss_state:
		BossState.LOCKED:
			return "尚未現身"
		BossState.INTRO:
			return "登場中"
		BossState.ACTIVE:
			return "交戰中"
		BossState.DEFEATED:
			return "已擊敗"
		BossState.RESOLVED:
			return "已結算"
	return "未知"

func debug_snapshot() -> Dictionary:
	return {
		"mode": mode,
		"current_index": current_index,
		"current_id": current_id(),
		"boss_state": boss_state,
		"boss_state_label": boss_state_label(),
		"is_final_chapter": is_final_chapter(),
		"campaign_completed": campaign_is_completed(),
		"completed": completed_chapters.duplicate()
	}
