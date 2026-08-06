class_name ChapterFlowContract
extends RefCounted

enum Phase {
	INTRO,
	COMBAT,
	MID_EVENT,
	ELITE,
	BOSS,
	LOOT,
	RESULT,
	BRANCH,
	FORMATION,
	AUTOSAVE,
	COMPLETE,
}

const PHASE_NAMES: Dictionary = {
	Phase.INTRO: "intro",
	Phase.COMBAT: "combat",
	Phase.MID_EVENT: "mid_event",
	Phase.ELITE: "elite",
	Phase.BOSS: "boss",
	Phase.LOOT: "loot",
	Phase.RESULT: "result",
	Phase.BRANCH: "branch",
	Phase.FORMATION: "formation",
	Phase.AUTOSAVE: "autosave",
	Phase.COMPLETE: "complete",
}

const ALLOWED_TRANSITIONS: Dictionary = {
	Phase.INTRO: [Phase.COMBAT],
	Phase.COMBAT: [Phase.MID_EVENT, Phase.ELITE, Phase.BOSS],
	Phase.MID_EVENT: [Phase.COMBAT, Phase.ELITE, Phase.BOSS],
	Phase.ELITE: [Phase.COMBAT, Phase.BOSS],
	Phase.BOSS: [Phase.LOOT],
	Phase.LOOT: [Phase.RESULT],
	Phase.RESULT: [Phase.BRANCH, Phase.FORMATION],
	Phase.BRANCH: [Phase.FORMATION],
	Phase.FORMATION: [Phase.AUTOSAVE],
	Phase.AUTOSAVE: [Phase.COMPLETE],
	Phase.COMPLETE: [Phase.INTRO],
}

static func can_transition(previous_phase: int, next_phase: int) -> bool:
	return next_phase in (ALLOWED_TRANSITIONS.get(previous_phase, []) as Array)

static func phase_name(phase: int) -> String:
	return str(PHASE_NAMES.get(phase, "unknown"))

static func new_state(chapter_id: String) -> Dictionary:
	return {
		"chapter_id": chapter_id,
		"phase": Phase.INTRO,
		"selected_branch": "",
		"flags": {},
		"boss_variant": "",
		"reinforcements": [],
	}

static func branch_definition(branch_id: String, requirements: Array = [], set_flags: Array = [], next_chapter: String = "") -> Dictionary:
	return {
		"id": branch_id,
		"requirements": requirements.duplicate(true),
		"set_flags": set_flags.duplicate(true),
		"next_chapter": next_chapter,
		"boss_variant": "",
		"reinforcements": [],
	}
