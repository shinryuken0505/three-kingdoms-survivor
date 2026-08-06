class_name GameEventBus
extends Node

signal player_registered(player_id: String)
signal hero_recruited(hero_id: String)
signal hero_leveled_up(hero_id: String, level: int)
signal relic_acquired(relic_id: String, level: int)
signal merchant_opened(merchant_id: String)
signal boss_defeated(boss_id: String)
signal chapter_phase_changed(previous_phase: String, next_phase: String)
signal chapter_completed(chapter_id: String)
signal branch_selected(branch_id: String)
signal save_requested(reason: String)

const ALLOWED_EVENTS: PackedStringArray = [
	"player_registered",
	"hero_recruited",
	"hero_leveled_up",
	"relic_acquired",
	"merchant_opened",
	"boss_defeated",
	"chapter_phase_changed",
	"chapter_completed",
	"branch_selected",
	"save_requested",
]

var event_history: Array[Dictionary] = []
const MAX_HISTORY: int = 80

func publish(event_name: String, payload: Dictionary = {}) -> void:
	if not ALLOWED_EVENTS.has(event_name):
		push_warning("Unknown game event: %s" % event_name)
		return
	event_history.append({"event": event_name, "payload": payload.duplicate(true), "time_ms": Time.get_ticks_msec()})
	if event_history.size() > MAX_HISTORY:
		event_history.pop_front()
	match event_name:
		"player_registered": player_registered.emit(str(payload.get("player_id", "")))
		"hero_recruited": hero_recruited.emit(str(payload.get("hero_id", "")))
		"hero_leveled_up": hero_leveled_up.emit(str(payload.get("hero_id", "")), int(payload.get("level", 1)))
		"relic_acquired": relic_acquired.emit(str(payload.get("relic_id", "")), int(payload.get("level", 1)))
		"merchant_opened": merchant_opened.emit(str(payload.get("merchant_id", "")))
		"boss_defeated": boss_defeated.emit(str(payload.get("boss_id", "")))
		"chapter_phase_changed": chapter_phase_changed.emit(str(payload.get("previous", "")), str(payload.get("next", "")))
		"chapter_completed": chapter_completed.emit(str(payload.get("chapter_id", "")))
		"branch_selected": branch_selected.emit(str(payload.get("branch_id", "")))
		"save_requested": save_requested.emit(str(payload.get("reason", "manual")))

func clear_history() -> void:
	event_history.clear()
