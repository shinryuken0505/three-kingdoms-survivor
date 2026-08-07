extends Node

var host: Variant = null
var last_chapter_id: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	host = get_tree().current_scene
	if host == null or not is_instance_valid(host):
		return
	var player: Dictionary = host.get("player") as Dictionary
	if player.is_empty():
		return
	var manager: Variant = host.get("chapter_manager")
	var chapter_id: String = ""
	if manager != null and manager.has_method("current_id"):
		chapter_id = str(manager.call("current_id"))
	if chapter_id == "":
		return
	var selected_branch: String = str(player.get("alpha46_selected_branch", ""))
	var scoped_branch: String = str(player.get("alpha47_effect_scope_branch", ""))
	var scoped_chapter: String = str(player.get("alpha47_effect_scope_chapter", ""))
	# Alpha.46 在真正推進章節後才會把 branch_consumed 設為 true；此時把分支效果綁定到剛進入的新章。
	if selected_branch != "" and selected_branch != scoped_branch and bool(player.get("alpha46_branch_consumed", false)):
		player["alpha47_effect_scope_branch"] = selected_branch
		player["alpha47_effect_scope_chapter"] = chapter_id
		scoped_branch = selected_branch
		scoped_chapter = chapter_id
	# 沒有新的分支承接時，上一章的援軍／權重／Boss／商人效果不可跨章永久殘留。
	if scoped_chapter != "" and chapter_id != scoped_chapter and selected_branch == scoped_branch:
		player["alpha46_reinforcement"] = ""
		player["alpha46_hero_weight_bonus"] = {}
		player["alpha46_boss_variant"] = ""
		player["alpha46_merchant_override"] = ""
		player["alpha47_effect_scope_chapter"] = ""
	host.set("player", player)
	last_chapter_id = chapter_id
