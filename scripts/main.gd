extends Node2D

# AI/工程師接手前請先閱讀：res://AI_START_HERE.md 與 res://docs/ai_handoff/ARCHITECTURE.md

const GameData = preload("res://scripts/game_data.gd")
const ChapterManagerScript = preload("res://scripts/chapter_manager.gd")
const HistoryEventData = preload("res://scripts/history_event_data.gd")
const HistoryRouteRules = preload("res://scripts/systems/world/history_route_rules.gd")
const HeroProgressionRules = preload("res://scripts/systems/hero/hero_progression_rules.gd")
const PlayerCombatService = preload("res://scripts/systems/player/player_combat_service.gd")
const PlayerSignaturePassiveService = preload("res://scripts/systems/player/player_signature_passive_service.gd")
const StatusEffectService = preload("res://scripts/systems/combat/status_effect_service.gd")
const ElementalSynergyService = preload("res://scripts/systems/combat/elemental_synergy_service.gd")
const RelicStatusSynergyService = preload("res://scripts/systems/relic/relic_status_synergy_service.gd")
const HeroElementalBuildService = preload("res://scripts/systems/hero/hero_elemental_build_service.gd")
const HeroRecruitmentAffinityService = preload("res://scripts/systems/hero/hero_recruitment_affinity_service.gd")
const PlayerUpgradeService = preload("res://scripts/systems/player/player_upgrade_service.gd")
const MerchantPricingService = preload("res://scripts/systems/merchant/merchant_pricing_service.gd")
const Alpha19BuildRules = preload("res://scripts/systems/build/alpha19_build_rules.gd")
const Alpha19HeroMastery = preload("res://scripts/systems/hero/alpha19_hero_mastery.gd")
const Alpha19HistoryInfluence = preload("res://scripts/systems/world/alpha19_history_influence.gd")
const Alpha19ChapterGimmicks = preload("res://scripts/systems/chapter/alpha19_chapter_gimmicks.gd")
const Alpha20DemoDirector = preload("res://scripts/systems/demo/alpha20_demo_director.gd")
const Alpha20ChallengeTracker = preload("res://scripts/systems/demo/alpha20_challenge_tracker.gd")
const Alpha20DemoProfile = preload("res://scripts/systems/demo/alpha20_demo_profile.gd")
const Alpha21CombatIdentity = preload("res://scripts/systems/combat/alpha21_combat_identity.gd")
const Alpha21HeroSignatures = preload("res://scripts/systems/hero/alpha21_hero_signatures.gd")
const Alpha21BossPatterns = preload("res://scripts/systems/boss/alpha21_boss_patterns.gd")
const Alpha22MetaProgression = preload("res://scripts/systems/meta/alpha22_meta_progression.gd")
const Alpha22Codex = preload("res://scripts/systems/meta/alpha22_codex.gd")
const Alpha22Achievements = preload("res://scripts/systems/meta/alpha22_achievements.gd")
const Alpha23StoryDirector = preload("res://scripts/systems/story/alpha23_story_director.gd")
const Alpha23RouteResolver = preload("res://scripts/systems/story/alpha23_route_resolver.gd")
const Alpha23EndingRoutes = preload("res://scripts/systems/ending/alpha23_ending_routes.gd")
const Alpha24SteamDemo = preload("res://scripts/systems/demo/alpha24_steam_demo.gd")
const Alpha27ActionProfiles = preload("res://scripts/systems/combat/alpha27_action_profiles.gd")
const Alpha31TelegraphShapes = preload("res://scripts/systems/boss/alpha31_telegraph_shapes.gd")
const Alpha32BossHitboxSync = preload("res://scripts/systems/boss/alpha32_boss_hitbox_sync.gd")
const Alpha33BossAttackTimeline = preload("res://scripts/systems/boss/alpha33_boss_attack_timeline.gd")
const Alpha35BossPhaseEnrage = preload("res://scripts/systems/boss/alpha35_boss_phase_enrage.gd")
const Alpha36RosterProgressionHud = preload("res://scripts/systems/hero/alpha36_37_roster_progression_hud.gd")
const Alpha34BossCounterWindow = preload("res://scripts/systems/boss/alpha34_boss_counter_window.gd")
const HeroRosterManagerScript = preload("res://scripts/systems/hero/hero_roster_manager.gd")
const HeroRosterControllerScript = preload("res://scripts/systems/hero/hero_roster_controller.gd")
const EndingManagerScript = preload("res://scripts/systems/ending/ending_manager.gd")
const EndingUIScript = preload("res://scripts/ui/ending_ui.gd")
const BossLootUIScript = preload("res://scripts/ui/boss_loot_ui.gd")
const RelicNoticeUIScript = preload("res://scripts/ui/relic_notice_ui.gd")
const GAME_VERSION: String = "V2.0.0-alpha.57"
const VIEW: Vector2 = Vector2(1280.0, 720.0)
const CENTER: Vector2 = Vector2(640.0, 360.0)
const WORLD: Rect2 = Rect2(0.0, 0.0, 3200.0, 2200.0)
const MAX_NEW_RELICS_PER_CHAPTER: int = 3
const MAX_RELIC_LEVEL: int = 3
const SAVE_PATH: String = "user://demo6_save.json"
const SAVE_TEMP_PATH: String = "user://demo6_save.tmp"
const SAVE_BACKUP_PATH: String = "user://demo6_save.backup.json"
const SAVE_FORMAT_VERSION: int = 5
const MAX_PICKUPS: int = 110
const MAX_PARTICLES: int = 190
const MAX_DAMAGE_NUMBERS: int = 72
const MAX_ZONES: int = 70
const MAX_PLAYER_SHOTS: int = 180
const MAX_ALLIES: int = 18
const ENEMY_GRID_SIZE: float = 180.0
const CHECKPOINT_VERSION: int = 5
const PLAYER_SPRITE_SCALE: float = 1.68
const ENEMY_SPRITE_SCALE: float = 1.34
const ELITE_SPRITE_SCALE: float = 1.70
const BOSS_SPRITE_SCALE: float = 2.72
const ENCOUNTER_SPRITE_SCALE: float = 1.62

# HUD固定安全區。所有位置以1280×720虛擬畫布計算，再由Godot等比縮放。
const HUD_RELIC_RECT: Rect2 = Rect2(12.0, 12.0, 324.0, 132.0)
const HUD_HEADER_RECT: Rect2 = Rect2(360.0, 12.0, 680.0, 72.0)
const HUD_BOSS_RECT: Rect2 = Rect2(390.0, 91.0, 620.0, 66.0)
const HUD_MINIMAP_RECT: Rect2 = Rect2(1088.0, 12.0, 174.0, 116.0)
const HUD_PLAYER_RECT: Rect2 = Rect2(84.0, 630.0, 202.0, 66.0)
const HUD_HERO_RAIL_RECT: Rect2 = Rect2(76.0, 624.0, 1128.0, 76.0)
const HUD_MESSAGE_Y: float = 580.0

var identities: Dictionary
var heroes: Dictionary
var relic_defs: Dictionary
var equipment_defs: Dictionary
var merchant_defs: Dictionary
var skill_defs: Dictionary
var bond_defs: Dictionary
var skin_defs: Dictionary
var history_event_defs: Dictionary
var chapter_manager: Variant = null
var ending_manager: Variant = null

var font: SystemFont
var font_bold: SystemFont
var menu_bg: Texture2D
var portrait_tex: Dictionary = {}
var sprite_tex: Dictionary = {}
var relic_tex: Dictionary = {}
var equipment_tex: Dictionary = {}
var map_tex: Dictionary = {}
var prop_tex: Dictionary = {}
var texture_cache: Dictionary = {}
var asset_errors: Array[String] = []
var startup_checks: Array[String] = []
var self_test_mode: bool = false
var debug_overlay: bool = false
var audio_enabled: bool = true

var screen: String = "menu"
var previous_screen: String = "game"
var menu_index: int = 0
var select_index: int = 0
var option_index: int = 0
var tab_page: int = 0
var tab_index: int = 0
var tab_scroll: int = 0
var codex_index: int = 0
var codex_page: int = 0
var skin_hero_index: int = 0
var skin_variant_index: int = 0
var settings_index: int = 0
var save_screen_index: int = 0
var confirm_index: int = 0
var chosen_mode: String = "story"
var chosen_identity: String = "swordsman"

var save_data: Dictionary = {
	"format_version": SAVE_FORMAT_VERSION,
	"last_saved_at": "",
	"unlocked_bonds": {},
	"selected_skins": {},
	"run_save": {},
	"endings": {},
	"latest_ending": {},
	"meta_progression": {},
	"codex": {},
	"achievements": {},
	"story_routes": {},
	"settings": {
		"bgm": 0.70,
		"sfx": 0.80,
		"effects": 0.82,
		"difficulty": "story",
		"shake": true,
		"damage_numbers": true,
		"fullscreen": false
	}
}

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var player: Dictionary = {}
var enemies: Array = []
var player_shots: Array = []
var enemy_shots: Array = []
var pickups: Array = []
var particles: Array = []
var zones: Array = []
var allies: Array = []
var decorations: Array = []
var obstacles: Array = []
var damage_numbers: Array = []

var elapsed: float = 0.0
var spawn_timer: float = 0.0
var hero_spawn_timer: float = 24.0
var merchant_spawn_timer: float = 105.0
var merchant_active: bool = false
var merchant_pos: Vector2 = Vector2.ZERO
var merchant_stock: Array = []
var merchant_equipment_stock: Array = []
var merchant_visit: int = 0
var merchant_kind: String = "peddler"
var boss_defeat_counts: Dictionary = {}
var current_encounter: String = ""
var encounter_candidates: Array[String] = []
var encounter_pick_index: int = 0
var recruit_refresh_count: int = 0
var recruit_free_refresh_used: bool = false
var modal_input_lock_until_ms: int = 0
var last_confirm_ms: int = -1000
var encounter_pos: Vector2 = Vector2.ZERO
var encounter_cooldowns: Dictionary = {}
var replace_candidate: String = ""
var replace_index: int = 0
var level_choices: Array = []
var shop_choices: Array = []
var active_heroes: Array = []
var reserve_heroes: Array = []
var camp_heroes: Array = []
var hero_levels: Dictionary = {} # 舊存檔相容：同步保存羈絆等級
var hero_skill_levels: Dictionary = {}
var hero_experience: Dictionary = {}
var hero_bond_levels: Dictionary = {}
var departed_heroes: Dictionary = {}
var hero_star_points: int = 0
var hero_orders: int = 0
var hero_cooldowns: Dictionary = {}
var known_heroes: Dictionary = {}
var active_bonds: Array = []
var bond_combo_progress: Dictionary = {}
var relics: Array = []
var relic_levels: Dictionary = {}
var equipment_inventory: Array = []
var equipped: Dictionary = {"weapon":"", "body":"", "treasure":"", "accessory":"", "jade":""}
var pending_boss_loot: Dictionary = {}
var pending_relic_notice: Dictionary = {}
var skill_levels: Dictionary = {}
var run_stats: Dictionary = {}
var boss: Dictionary = {}
var boss_spawned: bool = false
var boss_intro_timer: float = 0.0
var boss_intro_duration: float = 3.0
var chapter_intro_return_screen: String = "game"
var chapter_intro_page: int = 0
var history_event_phase: String = "choice"
var history_result_title: String = ""
var history_result_detail: String = ""
var game_message: String = ""
var game_message_timer: float = 0.0
var checkpoint_notice: String = ""
var checkpoint_notice_timer: float = 0.0
var screen_shake: float = 0.0
var hit_stop_timer: float = 0.0
var hit_stop_cooldown: float = 0.0
var frame_stats_timer: float = 0.0
var frame_peak_accum: float = 0.0
var frame_peak_last_ms: float = 0.0
var frame_spikes_accum: int = 0
var frame_spikes_last: int = 0
var hit_stop_triggers_accum: int = 0
var hit_stop_triggers_last: int = 0
var hero_cast_flash: Dictionary = {}
# V1.7.3 輕量戰鬥動作：使用程式化位移、縮放、旋轉，不增加大量貼圖負擔。
var player_action_anim: Dictionary = {}
var boss_action_anim: Dictionary = {}
var boss_ability_banner: Dictionary = {}
var boss_attack_timeline: Dictionary = {}
var boss_phase_state: Dictionary = {}
var boss_counter_window: float = 0.0
var boss_counter_was_break: bool = false
var boss_break_damage: float = 0.0
var boss_break_immunity: float = 0.0
var boss_precision_dodge_rewarded: bool = false
var yellow_water_used: bool = false
var survival_used: bool = false
var temporary_attack_speed: float = 0.0
var temporary_speed: float = 0.0
var reserve_roar_cd: float = 0.0
var pending_levelups: int = 0
var game_over_reason: String = ""
var auto_hero_cast_delay: float = 0.0
var chapter_clear_snapshot: Dictionary = {}
var pending_run_result: int = 0  # 1=勝利，-1=失敗；統一在更新階段安全結算
var ending_snapshot: Dictionary = {}
var ending_committed: bool = false
var alpha19_build_state: Dictionary = {}
var alpha19_mastery_state: Dictionary = {}
var alpha19_history_state: Dictionary = {}
var alpha19_chapter_state: Dictionary = {}
var alpha19_refresh_timer: float = 0.0
var alpha20_director_state: Dictionary = {}
var alpha20_challenge_state: Dictionary = {}
var alpha20_demo_state: Dictionary = {}
var alpha20_tick_timer: float = 0.0
var alpha20_hazard_timer: float = 0.0
var alpha20_last_kills: int = 0
var alpha21_identity_state: Dictionary = {}
var alpha21_boss_sequence: int = 0
var alpha21_boss_phase: int = 1
var alpha22_meta_state: Dictionary = {}
var alpha22_codex_state: Dictionary = {}
var alpha22_achievement_state: Dictionary = {}
var alpha22_last_rewards: Array[String] = []
var alpha23_route_state: Dictionary = {}
var alpha23_story_scene: Dictionary = {}
var alpha23_chapter_variant: Dictionary = {}
var alpha23_pending_ending: Dictionary = {}
var alpha24_demo_state: Dictionary = {}
var alpha24_quality_profile: Dictionary = {}
var alpha36_37_state: Dictionary = Alpha36RosterProgressionHud.new_state()
var alpha24_frame_sample_timer: float = 0.0

# 章節安全點／寶箱／遺物循環
var camp_active: bool = false
var camp_pos: Vector2 = Vector2.ZERO
var camp_spawned: bool = false
var chest_active: bool = false
var chest_pos: Vector2 = Vector2.ZERO
var chest_spawned: bool = false
var chapter_elite_relic_given: bool = false
var chapter_boss_relic_given: bool = false
var chapter_reward_relic: String = ""
var chapter_natural_relics: int = 0

# 名將整備：只允許商人、營地與章間使用
var hero_config_index: int = 0
var hero_config_origin: String = "game"
var config_candidate: String = ""
var config_replace_index: int = 0
var hero_position_picker_open: bool = false
var hero_position_index: int = 0
var hero_position_candidate: String = ""
var config_replace_mode: String = "active" # active／reserve
var camp_menu_index: int = 0

var bgm_player: AudioStreamPlayer
var bgm_player_alt: AudioStreamPlayer
var bgm_active_slot: int = 0
var bgm_fade_tween: Tween
var sfx_players: Array = []
var bgm_name: String = ""
var audio_streams: Dictionary = {}
var sfx_last_play_ms: Dictionary = {}
var combat_motif_step: int = 0
var sfx_min_gap_ms: Dictionary = {
	"hit": 42,
	"arrow": 75,
	"slash": 55,
	"pickup": 45,
	"poison": 65,
	"hurt": 110,
	"dash": 120,
	"ui_move": 55
}
var sfx_priority: Dictionary = {
	"boss_warning": 100, "hurt": 90, "shield_break": 85, "crit": 80,
	"boss_intro": 78, "levelup": 75, "equipment_drop": 72, "hero": 68,
	"ui_error": 64, "ui_confirm": 55, "ui_cancel": 54, "heal": 52,
	"slash": 38, "arrow": 36, "hit": 28, "enemy_down": 24,
	"pickup": 18, "coin": 16, "ui_move": 12, "poison": 30, "fire": 30, "dash": 46
}
var sfx_bus: Dictionary = {
	"ui_confirm": "UI", "ui_move": "UI", "ui_cancel": "UI", "ui_error": "UI",
	"boss_intro": "Voice", "boss_warning": "Voice", "hero": "Voice"
}
var sfx_base_db: Dictionary = {
	"boss_warning": 1.5, "hurt": 0.5, "crit": 0.0, "shield_break": 0.0,
	"enemy_down": -5.0, "pickup": -4.5, "coin": -5.5, "ui_move": -6.0,
	"slash": -2.0, "arrow": -2.5, "hit": -4.0, "fire": -3.0
}

# 效能防護與歷史奇遇
var performance_cleanup_timer: float = 0.5
var performance_pressure: String = "穩定"
var performance_level: int = 0
var frame_time_ema: float = 1.0 / 60.0
var low_fps_timer: float = 0.0
var recovery_timer: float = 0.0
var frame_serial: int = 0
var enemy_spatial_grid: Dictionary = {}
var enemy_uid_index: Dictionary = {}
var history_event_cursor: Dictionary = {}
var history_event_active: bool = false
var history_event_pos: Vector2 = Vector2.ZERO
var current_history_event: Dictionary = {}
var history_event_options: Array = []
var history_event_index: int = 0
var history_event_done: Dictionary = {}
var history_flags: Dictionary = {}
var history_log: Array[String] = []
var history_modifiers: Dictionary = {}
var faction_momentum: Dictionary = HistoryRouteRules.default_momentum()
var history_rewrite_rate: float = 0.0
var history_route_tags: Dictionary = {}



func canonical_hero_id(hero_id: String) -> String:
	return hero_id.to_lower().replace("_", "").replace("-", "")


func repair_all_hero_portrait_bindings() -> void:
	var formal_portraits: Dictionary = {
		"caimao": "res://assets/portraits/cai_mao.png",
		"caiwenji": "res://assets/portraits/cai_wenji.png",
		"caocao": "res://assets/portraits/cao_cao.png",
		"caoren": "res://assets/portraits/cao_ren.png",
		"chengong": "res://assets/portraits/chen_gong.png",
		"daqiao": "res://assets/portraits/da_qiao.png",
		"diaochan": "res://assets/portraits/diao_chan.png",
		"diaochanred": "res://assets/portraits/diaochan_red.png",
		"dongzhuo": "res://assets/portraits/dong_zhuo.png",
		"fazheng": "res://assets/portraits/fa_zheng.png",
		"gaoshun": "res://assets/portraits/gao_shun.png",
		"guanyu": "res://assets/portraits/guan_yu.png",
		"guanyuyoung": "res://assets/portraits/guanyu_young.png",
		"guojia": "res://assets/portraits/guo_jia.png",
		"huanggai": "res://assets/portraits/huang_gai.png",
		"huangzhong": "res://assets/portraits/huang_zhong.png",
		"huatuo": "res://assets/portraits/hua_tuo.png",
		"huaxiong": "res://assets/portraits/hua_xiong.png",
		"jiangwei": "res://assets/portraits/jiang_wei.png",
		"liru": "res://assets/portraits/li_ru.png",
		"liubei": "res://assets/portraits/liu_bei.png",
		"lusu": "res://assets/portraits/lu_su.png",
		"luxun": "res://assets/portraits/lu_xun.png",
		"lvbu": "res://assets/portraits/lv_bu.png",
		"lvlingqi": "res://assets/portraits/lv_lingqi.png",
		"simayi": "res://assets/portraits/sima_yi.png",
		"sunce": "res://assets/portraits/sun_ce.png",
		"sunjian": "res://assets/portraits/sun_jian.png",
		"sunquan": "res://assets/portraits/sun_quan.png",
		"sunshangxiang": "res://assets/portraits/sun_shangxiang.png",
		"taishici": "res://assets/portraits/taishi_ci.png",
		"wangyi": "res://assets/portraits/wang_yi.png",
		"weiyan": "res://assets/portraits/wei_yan.png",
		"xiahoudun": "res://assets/portraits/xiahou_dun.png",
		"xiahouen": "res://assets/portraits/xiahou_en.png",
		"xiahouyuan": "res://assets/portraits/xiahou_yuan.png",
		"xuhuang": "res://assets/portraits/xu_huang.png",
		"yuanshao": "res://assets/portraits/yuan_shao.png",
		"zhangbao": "res://assets/portraits/zhang_bao.png",
		"zhangfei": "res://assets/portraits/zhang_fei.png",
		"zhanghe": "res://assets/portraits/zhang_he.png",
		"zhangjiao": "res://assets/portraits/zhang_jiao.png",
		"zhangliang": "res://assets/portraits/zhang_liang.png",
		"zhangliao": "res://assets/portraits/zhang_liao.png",
		"zhaoyun": "res://assets/portraits/zhao_yun.png",
		"zhenji": "res://assets/portraits/zhen_ji.png",
		"zhouyu": "res://assets/portraits/zhou_yu.png",
		"zhugeliang": "res://assets/portraits/zhuge_liang.png",
	}
	for hero_value in heroes.keys():
		var hero_id: String = str(hero_value)
		var compact_id: String = canonical_hero_id(hero_id)
		if not formal_portraits.has(compact_id):
			push_warning("No formal portrait file mapped for hero: %s" % hero_id)
			portrait_tex.erase(hero_id)
			continue
		var portrait_path: String = str(formal_portraits[compact_id])
		if not ResourceLoader.exists(portrait_path) and not FileAccess.file_exists(portrait_path):
			push_warning("Formal portrait missing: %s -> %s" % [hero_id, portrait_path])
			portrait_tex.erase(hero_id)
			continue
		portrait_tex[hero_id] = runtime_texture(portrait_path)


func hero_portrait(hero_id: String) -> Texture2D:
	if portrait_tex.has(hero_id) and portrait_tex[hero_id] is Texture2D:
		return portrait_tex[hero_id] as Texture2D
	push_warning("Hero portrait unavailable; sprite fallback forbidden: %s" % hero_id)
	return runtime_texture("res://assets/portraits/placeholder.png")


func validate_hero_portrait_references() -> void:
	for hero_value in heroes.keys():
		var hero_id: String = str(hero_value)
		if not portrait_tex.has(hero_id) or not (portrait_tex[hero_id] is Texture2D):
			push_warning("Missing formal hero portrait reference: %s" % hero_id)


func _ready() -> void:
	self_test_mode = OS.get_cmdline_user_args().has("--self-test")
	audio_enabled = not self_test_mode
	rng.randomize()
	identities = GameData.identities()
	heroes = HeroElementalBuildService.install_runtime_tags(GameData.heroes())
	alpha36_37_state = Alpha36RosterProgressionHud.new_state()
	relic_defs = RelicStatusSynergyService.install_definitions(GameData.relics())
	equipment_defs = GameData.equipment()
	merchant_defs = GameData.merchant_types()
	skill_defs = PlayerUpgradeService.install_signature_definitions(GameData.skills())
	bond_defs = GameData.bonds()
	skin_defs = GameData.skins()
	history_event_defs = HistoryEventData.events()
	chapter_manager = ChapterManagerScript.new()
	chapter_manager.configure(GameData.chapters(), GameData.trial_chapter())
	ending_manager = EndingManagerScript.new()
	setup_fonts()
	load_assets()
	repair_all_hero_portrait_bindings()
	validate_hero_portrait_references()
	load_save()
	refresh_all_skins()
	setup_audio()
	apply_settings()
	if self_test_mode:
		call_deferred("run_self_test")
	else:
		play_bgm("menu")
	queue_redraw()


func setup_fonts() -> void:
	font = SystemFont.new()
	font.font_names = PackedStringArray(
		["Microsoft JhengHei", "Noto Sans CJK TC", "PingFang TC", "Arial"]
	)
	font.font_weight = 450
	font_bold = SystemFont.new()
	font_bold.font_names = font.font_names
	font_bold.font_weight = 700


func runtime_texture(path: String) -> Texture2D:
	if texture_cache.has(path):
		return texture_cache[path] as Texture2D
	# 先直接讀取專案中的原始PNG，避免首次啟動尚未完成Godot匯入時只剩色塊。
	var disk_path: String = ProjectSettings.globalize_path(path)
	var image: Image = Image.load_from_file(disk_path)
	if image != null and not image.is_empty() and image.get_width() > 0 and image.get_height() > 0:
		var texture: ImageTexture = ImageTexture.create_from_image(image)
		texture_cache[path] = texture
		return texture
	# 匯出版本的素材位於PCK內，改由ResourceLoader讀取。
	var imported: Resource = ResourceLoader.load(
		path, "Texture2D", ResourceLoader.CACHE_MODE_IGNORE
	)
	if (
		imported is Texture2D
		and (imported as Texture2D).get_width() > 0
		and (imported as Texture2D).get_height() > 0
	):
		texture_cache[path] = imported
		return imported as Texture2D
	if not asset_errors.has(path):
		asset_errors.append(path)
	var fallback_image: Image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	fallback_image.fill(Color(0.18, 0.02, 0.18, 1.0))
	for y in range(32):
		for x in range(32):
			if (int(x / 8) + int(y / 8)) % 2 == 0:
				fallback_image.set_pixel(x, y, Color(0.95, 0.15, 0.75, 1.0))
	var fallback: ImageTexture = ImageTexture.create_from_image(fallback_image)
	texture_cache[path] = fallback
	return fallback


func runtime_wav(path: String) -> AudioStream:
	var disk_path: String = ProjectSettings.globalize_path(path)
	var stream: AudioStreamWAV = AudioStreamWAV.load_from_file(disk_path)
	if stream != null:
		return stream
	var imported: Resource = ResourceLoader.load(
		path, "AudioStream", ResourceLoader.CACHE_MODE_IGNORE
	)
	if imported is AudioStream:
		return imported as AudioStream
	if not asset_errors.has(path):
		asset_errors.append(path)
	return null


func load_assets() -> void:
	asset_errors.clear()
	startup_checks.clear()
	texture_cache.clear()
	portrait_tex.clear()
	sprite_tex.clear()
	relic_tex.clear()
	equipment_tex.clear()
	map_tex.clear()
	prop_tex.clear()
	menu_bg = runtime_texture("res://assets/menu_background.png")
	for id in identities:
		var identity_portrait_path: String = str(identities[id]["portrait"])
		var identity_remastered_path: String = "res://assets/portraits_remastered/%s_default.png" % str(id)
		if ResourceLoader.exists(identity_remastered_path):
			identity_portrait_path = identity_remastered_path
		portrait_tex[id] = runtime_texture(identity_portrait_path)
		sprite_tex[id] = runtime_texture(str(identities[id]["sprite"]))
	for id in heroes:
		var hero_portrait_path: String = str(heroes[id]["portrait"])
		var hero_remastered_path: String = "res://assets/portraits_remastered/%s_default.png" % str(id)
		if ResourceLoader.exists(hero_remastered_path):
			hero_portrait_path = hero_remastered_path
		portrait_tex[id] = runtime_texture(hero_portrait_path)
		sprite_tex[id] = runtime_texture(str(heroes[id]["sprite"]))
	var boss_ids: Array[String] = []
	for chapter_value in GameData.chapters():
		var chapter: Dictionary = chapter_value
		var boss_def: Dictionary = chapter.get("boss", {})
		var boss_id: String = str(boss_def.get("id", ""))
		if boss_id != "" and not boss_ids.has(boss_id):
			boss_ids.append(boss_id)
		var support_def: Dictionary = chapter.get("support_boss", {})
		var support_id: String = str(support_def.get("id", ""))
		if support_id != "" and not boss_ids.has(support_id):
			boss_ids.append(support_id)
	var trial_boss: String = str(GameData.trial_chapter().get("boss", {}).get("id", ""))
	if trial_boss != "" and not boss_ids.has(trial_boss):
		boss_ids.append(trial_boss)
	for id in boss_ids:
		var boss_portrait_path: String = "res://assets/portraits/%s_default.png" % id
		var boss_remastered_path: String = "res://assets/portraits_remastered/%s_default.png" % id
		if ResourceLoader.exists(boss_remastered_path):
			boss_portrait_path = boss_remastered_path
		portrait_tex[id] = runtime_texture(boss_portrait_path)
		sprite_tex[id] = runtime_texture("res://assets/sprites/%s_default.png" % id)
	apply_character_art_fallbacks()
	for id in [
		"enemy_peasant",
		"enemy_sword",
		"enemy_archer",
		"enemy_elite",
		"enemy_cavalry",
		"enemy_shield",
		"enemy_crossbow",
		"enemy_drummer",
		"enemy_firepot",
		"enemy_assassin",
		"enemy_spearman",
		"enemy_tactician",
		"ally_militia"
	]:
		sprite_tex[id] = runtime_texture("res://assets/sprites/%s_default.png" % id)
	for id in relic_defs:
		var relic_def: Dictionary = relic_defs[id]
		var relic_icon_path: String = str(relic_def.get("icon", ""))
		if relic_icon_path == "":
			push_warning("Relic icon missing: %s" % str(id))
			relic_icon_path = "res://assets/portraits/placeholder.png"
		relic_tex[id] = runtime_texture(relic_icon_path)
	for id in equipment_defs:
		equipment_tex[id] = runtime_texture(str(equipment_defs[id]["icon"]))
	for chapter_value in GameData.chapters():
		var map_chapter: Dictionary = chapter_value
		var map_path: String = str(map_chapter.get("map_texture", ""))
		if map_path != "":
			map_tex[str(map_chapter.get("id", ""))] = runtime_texture(map_path)
	for prop_id in [
		"camp",
		"merchant",
		"chest",
		"barricade",
		"tent",
		"cart",
		"grain_cart",
		"tower",
		"drum",
		"wall",
		"house",
		"haystack",
		"palisade"
	]:
		prop_tex[prop_id] = runtime_texture("res://assets/props/%s.png" % prop_id)
	startup_checks.append("肖像 %d" % portrait_tex.size())
	startup_checks.append("像素角色 %d" % sprite_tex.size())
	startup_checks.append("遺物圖示 %d" % relic_tex.size())
	startup_checks.append("裝備圖示 %d" % equipment_tex.size())
	startup_checks.append("章節地圖 %d" % map_tex.size())
	startup_checks.append("戰場物件 %d" % prop_tex.size())
	print(
		"Demo6 texture assets loaded: portraits=",
		portrait_tex.size(),
		", sprites=",
		sprite_tex.size(),
		", relics=",
		relic_tex.size()
	)
	if not asset_errors.is_empty():
		push_warning("Demo6 asset fallback used for: %s" % str(asset_errors))


func setup_audio() -> void:
	bgm_player = AudioStreamPlayer.new()
	bgm_player_alt = AudioStreamPlayer.new()
	bgm_player.bus = &"Music"
	bgm_player_alt.bus = &"Music"
	add_child(bgm_player)
	add_child(bgm_player_alt)
	for i in range(14):
		var p: AudioStreamPlayer = AudioStreamPlayer.new()
		p.bus = &"SFX"
		p.set_meta("priority", -1)
		p.set_meta("started_ms", 0)
		add_child(p)
		sfx_players.append(p)
	for n in [
		"bgm_menu",
		"bgm_battle",
		"bgm_chapter1",
		"bgm_chapter2",
		"bgm_chapter3",
		"bgm_chapter4",
		"bgm_chapter5",
		"bgm_chapter6",
		"bgm_chapter7",
		"bgm_chapter12",
		"bgm_chapter11",
		"bgm_chapter10",
		"bgm_chapter9",
		"bgm_chapter8",
		"bgm_boss",
		"bgm_boss_lvbu",
		"bgm_intro",
		"bgm_event",
		"bgm_merchant",
		"bgm_intermission",
		"bgm_victory",
		"bgm_defeat",
		"ui_confirm",
		"ui_move",
		"hit",
		"hurt",
		"arrow",
		"slash",
		"pickup",
		"levelup",
		"hero",
		"boss_intro",
		"heal",
		"poison",
		"dash",
		"crit",
		"shield_break",
		"enemy_down",
		"boss_warning",
		"equipment_drop",
		"coin",
		"ui_cancel",
		"ui_error",
		"fire"
	]:
		audio_streams[n] = runtime_wav("res://assets/audio/%s.wav" % n)


func play_bgm(name: String, fade_time: float = 0.65) -> void:
	if not audio_enabled or bgm_player == null or bgm_player_alt == null:
		return
	var key: String = "bgm_%s" % name
	if not audio_streams.has(key) or audio_streams[key] == null:
		return
	var current: AudioStreamPlayer = bgm_player if bgm_active_slot == 0 else bgm_player_alt
	var incoming: AudioStreamPlayer = bgm_player_alt if bgm_active_slot == 0 else bgm_player
	if bgm_name == name and current.playing:
		return
	var stream: AudioStream = audio_streams[key] as AudioStream
	if stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	var target_db: float = linear_to_db(max(0.001, float(save_data["settings"].get("bgm", 0.70))))
	incoming.stop()
	incoming.stream = stream
	incoming.volume_db = -45.0
	incoming.play()
	if bgm_fade_tween != null and bgm_fade_tween.is_valid():
		bgm_fade_tween.kill()
	bgm_fade_tween = create_tween().set_parallel(true)
	bgm_fade_tween.tween_property(incoming, "volume_db", target_db, max(0.05, fade_time))
	if current.playing:
		bgm_fade_tween.tween_property(current, "volume_db", -45.0, max(0.05, fade_time))
		bgm_fade_tween.chain().tween_callback(current.stop)
	bgm_active_slot = 1 - bgm_active_slot
	bgm_name = name


func current_battle_bgm() -> String:
	if chosen_mode == "trial":
		return "battle"
	return "chapter%d" % clampi(int(current_chapter().get("index", 0)) + 1, 1, 12)


func current_boss_bgm() -> String:
	var boss_id: String = str(chapter_manager.boss_definition().get("id", ""))
	return "boss_lvbu" if boss_id == "lvbu" else "boss"


func play_current_battle_bgm() -> void:
	play_bgm(current_battle_bgm())


func play_current_boss_bgm() -> void:
	play_bgm(current_boss_bgm())


func play_sfx(name: String, pitch := 1.0, volume_offset_db: float = 0.0) -> void:
	if not audio_enabled or not audio_streams.has(name) or audio_streams[name] == null:
		return
	var now_ms: int = Time.get_ticks_msec()
	var min_gap: int = int(sfx_min_gap_ms.get(name, 0))
	if now_ms - int(sfx_last_play_ms.get(name, -100000)) < min_gap:
		return
	sfx_last_play_ms[name] = now_ms
	var chosen: AudioStreamPlayer = null
	for p_value in sfx_players:
		var p: AudioStreamPlayer = p_value as AudioStreamPlayer
		if not p.playing:
			chosen = p
			break
	var incoming_priority: int = int(sfx_priority.get(name, 32))
	if chosen == null:
		var weakest_priority: int = 100000
		var oldest_ms: int = 1000000000
		for p_value in sfx_players:
			var p: AudioStreamPlayer = p_value as AudioStreamPlayer
			var priority: int = int(p.get_meta("priority", 0))
			var started_ms: int = int(p.get_meta("started_ms", now_ms))
			if priority < weakest_priority or (priority == weakest_priority and started_ms < oldest_ms):
				weakest_priority = priority
				oldest_ms = started_ms
				chosen = p
		if chosen == null or incoming_priority < weakest_priority:
			return
		chosen.stop()
	chosen.stream = audio_streams[name]
	chosen.bus = StringName(str(sfx_bus.get(name, "SFX")))
	chosen.pitch_scale = clampf(pitch, 0.55, 1.65)
	var base_linear: float = max(0.001, float(save_data["settings"].get("sfx", 0.80)))
	chosen.volume_db = linear_to_db(base_linear) + float(sfx_base_db.get(name, 0.0)) + volume_offset_db
	chosen.set_meta("priority", incoming_priority)
	chosen.set_meta("started_ms", now_ms)
	chosen.play()


func play_combat_motif(name: String, base_pitch: float = 1.0) -> void:
	# 以五聲音階輪替命中音高。聲音仍短促，避免旋律掩蓋戰鬥資訊。
	var motif: Array[float] = [1.0, 1.122, 1.260, 1.498, 1.260, 1.122]
	var pitch: float = base_pitch * motif[combat_motif_step % motif.size()]
	combat_motif_step = (combat_motif_step + 1) % motif.size()
	play_sfx(name, pitch)


func apply_settings() -> void:
	var st: Dictionary = save_data["settings"]
	var music_db: float = linear_to_db(max(0.001, float(st["bgm"])))
	if bgm_player and bgm_player.playing:
		bgm_player.volume_db = music_db
	if bgm_player_alt and bgm_player_alt.playing:
		bgm_player_alt.volume_db = music_db
	if not self_test_mode:
		DisplayServer.window_set_mode(
			(
				DisplayServer.WINDOW_MODE_FULLSCREEN
				if bool(st["fullscreen"])
				else DisplayServer.WINDOW_MODE_WINDOWED
			)
		)


func read_save_document(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return {}
	return (parsed as Dictionary).duplicate(true)


func normalize_save_document(parsed_data: Dictionary) -> Dictionary:
	var normalized: Dictionary = save_data.duplicate(true)
	normalized["format_version"] = int(parsed_data.get("format_version", 1))
	normalized["last_saved_at"] = str(parsed_data.get("last_saved_at", ""))
	if parsed_data.get("unlocked_bonds", {}) is Dictionary:
		normalized["unlocked_bonds"] = parsed_data.get("unlocked_bonds", {})
	if parsed_data.get("selected_skins", {}) is Dictionary:
		normalized["selected_skins"] = parsed_data.get("selected_skins", {})
	if parsed_data.get("run_save", {}) is Dictionary:
		normalized["run_save"] = parsed_data.get("run_save", {})
	if parsed_data.get("endings", {}) is Dictionary:
		normalized["endings"] = parsed_data.get("endings", {})
	if parsed_data.get("latest_ending", {}) is Dictionary:
		normalized["latest_ending"] = parsed_data.get("latest_ending", {})
	if parsed_data.get("settings", {}) is Dictionary:
		for key in parsed_data.get("settings", {}) as Dictionary:
			if normalized["settings"].has(key):
				normalized["settings"][key] = parsed_data["settings"][key]
	normalized["settings"]["bgm"] = clamp(float(normalized["settings"]["bgm"]), 0.0, 1.0)
	normalized["settings"]["sfx"] = clamp(float(normalized["settings"]["sfx"]), 0.0, 1.0)
	normalized["settings"]["effects"] = clamp(float(normalized["settings"].get("effects", 0.82)), 0.35, 1.0)
	var saved_difficulty: String = str(normalized["settings"].get("difficulty", "story"))
	if saved_difficulty not in ["easy", "story", "hard"]:
		saved_difficulty = "story"
	normalized["settings"]["difficulty"] = saved_difficulty
	normalized["settings"]["shake"] = bool(normalized["settings"].get("shake", true))
	normalized["settings"]["damage_numbers"] = bool(normalized["settings"].get("damage_numbers", true))
	normalized["settings"]["fullscreen"] = bool(normalized["settings"].get("fullscreen", false))
	normalized["format_version"] = SAVE_FORMAT_VERSION
	return normalized


func load_save() -> void:
	var parsed_data: Dictionary = read_save_document(SAVE_PATH)
	if parsed_data.is_empty():
		var backup_data: Dictionary = read_save_document(SAVE_BACKUP_PATH)
		if backup_data.is_empty():
			if FileAccess.file_exists(SAVE_PATH):
				push_warning("主存檔損壞且無可用備份，已使用預設資料。")
			return
		parsed_data = backup_data
		push_warning("主存檔無法讀取，已自動使用備份存檔。")
		if not self_test_mode:
			DirAccess.copy_absolute(
				ProjectSettings.globalize_path(SAVE_BACKUP_PATH),
				ProjectSettings.globalize_path(SAVE_PATH)
			)
	save_data = normalize_save_document(parsed_data)


func save_game_meta() -> bool:
	# Headless 自測只驗證記憶體與 JSON 往返，不碰玩家的正式存檔。
	if self_test_mode:
		return true
	save_data["format_version"] = SAVE_FORMAT_VERSION
	save_data["last_saved_at"] = Time.get_datetime_string_from_system(false, true)
	var serialized: String = JSON.stringify(save_data, "  ")
	var verify: Variant = JSON.parse_string(serialized)
	if not (verify is Dictionary):
		push_warning("存檔序列化驗證失敗。")
		return false
	var temp_file: FileAccess = FileAccess.open(SAVE_TEMP_PATH, FileAccess.WRITE)
	if temp_file == null:
		push_warning("無法建立暫存檔：%s" % SAVE_TEMP_PATH)
		return false
	temp_file.store_string(serialized)
	temp_file.flush()
	temp_file.close()
	var temp_check: Dictionary = read_save_document(SAVE_TEMP_PATH)
	if temp_check.is_empty():
		push_warning("暫存檔驗證失敗，保留原存檔。")
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_TEMP_PATH))
		return false
	var save_abs: String = ProjectSettings.globalize_path(SAVE_PATH)
	var temp_abs: String = ProjectSettings.globalize_path(SAVE_TEMP_PATH)
	var backup_abs: String = ProjectSettings.globalize_path(SAVE_BACKUP_PATH)
	if FileAccess.file_exists(SAVE_PATH):
		if FileAccess.file_exists(SAVE_BACKUP_PATH):
			DirAccess.remove_absolute(backup_abs)
		var backup_error: Error = DirAccess.copy_absolute(save_abs, backup_abs)
		if backup_error != OK:
			push_warning("無法建立存檔備份，已取消本次寫入。")
			DirAccess.remove_absolute(temp_abs)
			return false
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(save_abs)
	var rename_error: Error = DirAccess.rename_absolute(temp_abs, save_abs)
	if rename_error != OK:
		push_warning("無法替換正式存檔，嘗試還原備份。")
		if FileAccess.file_exists(SAVE_BACKUP_PATH):
			DirAccess.copy_absolute(backup_abs, save_abs)
		return false
	return true


func checkpoint_player_state() -> Dictionary:
	if player.is_empty():
		return {}
	var keys: Array[String] = [
		"hp",
		"max_hp",
		"shield",
		"speed",
		"base_speed",
		"damage",
		"attack_interval",
		"weapon",
		"dash_cd",
		"level",
		"xp",
		"xp_need",
		"coins",
		"armor",
		"crit",
		"magnet",
		"pierce",
		"multishot",
		"poison_power",
		"heal_power",
		"hero_cd_mult",
		"projectile_mult"
	]
	var result: Dictionary = {}
	for key in keys:
		if player.has(key):
			result[key] = player[key]
	return result


func save_run_checkpoint() -> bool:
	if chosen_mode != "story" or player.is_empty():
		return false
	var checkpoint: Dictionary = {
		"version": CHECKPOINT_VERSION,
		"mode": chosen_mode,
		"identity": chosen_identity,
		"chapter_index": chapter_manager.current_index_value(),
		"completed": chapter_manager.completed_ids(),
		"boss_state": chapter_manager.boss_state_value(),
		"player": checkpoint_player_state(),
		"active_heroes": active_heroes.duplicate(),
		"reserve_heroes": reserve_heroes.duplicate(),
		"camp_heroes": camp_heroes.duplicate(),
		"hero_levels": hero_levels.duplicate(true),
		"hero_skill_levels": hero_skill_levels.duplicate(true),
		"hero_experience": hero_experience.duplicate(true),
		"alpha36_37_state": alpha36_37_state.duplicate(true),
		"hero_bond_levels": hero_bond_levels.duplicate(true),
		"departed_heroes": departed_heroes.duplicate(true),
		"hero_star_points": hero_star_points,
		"hero_orders": hero_orders,
		"known_heroes": known_heroes.duplicate(true),
		"relics": relics.duplicate(),
		"relic_levels": relic_levels.duplicate(true),
		"equipment_inventory": equipment_inventory.duplicate(),
		"boss_defeat_counts": boss_defeat_counts.duplicate(true),
		"equipped": equipped.duplicate(true),
		"skills": skill_levels.duplicate(true),
		"history_flags": history_flags.duplicate(true),
		"history_log": history_log.duplicate(),
		"history_done": history_event_done.duplicate(true),
		"history_cursor": history_event_cursor.duplicate(true),
		"history_modifiers": history_modifiers.duplicate(true),
		"faction_momentum": faction_momentum.duplicate(true),
		"history_rewrite_rate": history_rewrite_rate,
		"history_route_tags": history_route_tags.duplicate(true),
		"run_stats": run_stats.duplicate(true),
		"elapsed_seconds": float(elapsed),
		"game_version": GAME_VERSION,
		"saved_at": Time.get_datetime_string_from_system(false, true)
	}
	if checkpoint.get("player", {}) is Dictionary:
		if (checkpoint.get("player", {}) as Dictionary).is_empty():
			return false
	save_data["run_save"] = checkpoint
	var saved: bool = save_game_meta()
	if saved and not self_test_mode:
		checkpoint_notice = "章間旅程已保存"
		checkpoint_notice_timer = 3.0
	return saved


func clear_run_checkpoint() -> void:
	save_data["run_save"] = {}
	if save_game_meta() and not self_test_mode:
		# 刪除進度後同步覆寫備份，避免主檔損壞時復活已刪除的旅程。
		var save_abs: String = ProjectSettings.globalize_path(SAVE_PATH)
		var backup_abs: String = ProjectSettings.globalize_path(SAVE_BACKUP_PATH)
		if FileAccess.file_exists(SAVE_BACKUP_PATH):
			DirAccess.remove_absolute(backup_abs)
		DirAccess.copy_absolute(save_abs, backup_abs)


func continue_run_from_checkpoint() -> void:
	if not has_run_checkpoint():
		return
	var checkpoint: Dictionary = (save_data["run_save"] as Dictionary).duplicate(true)
	var identity_id: String = str(checkpoint.get("identity", "swordsman"))
	if not identities.has(identity_id):
		clear_run_checkpoint()
		show_message("章間存檔內容不相容，已清除。", 2.6)
		return
	start_run("story", identity_id)
	chosen_mode = str(checkpoint.get("mode", "story"))
	chosen_identity = identity_id
	chapter_manager.restore_campaign(
		chosen_mode,
		int(checkpoint.get("chapter_index", 0)),
		checkpoint.get("completed", []) as Array,
		int(checkpoint.get("boss_state", 4))
	)
	var saved_player: Dictionary = checkpoint.get("player", {}) as Dictionary
	for key in saved_player:
		player[key] = saved_player[key]
	active_heroes = (checkpoint.get("active_heroes", []) as Array).duplicate()
	reserve_heroes = (checkpoint.get("reserve_heroes", []) as Array).duplicate()
	camp_heroes = (checkpoint.get("camp_heroes", []) as Array).duplicate()
	hero_levels = (checkpoint.get("hero_levels", {}) as Dictionary).duplicate(true)
	hero_bond_levels = (checkpoint.get("hero_bond_levels", hero_levels) as Dictionary).duplicate(true)
	hero_skill_levels = (checkpoint.get("hero_skill_levels", {}) as Dictionary).duplicate(true)
	hero_experience = (checkpoint.get("hero_experience", {}) as Dictionary).duplicate(true)
	alpha36_37_state = (checkpoint.get("alpha36_37_state", Alpha36RosterProgressionHud.new_state()) as Dictionary).duplicate(true)
	departed_heroes = (checkpoint.get("departed_heroes", {}) as Dictionary).duplicate(true)
	hero_star_points = int(checkpoint.get("hero_star_points", 0))
	hero_orders = int(checkpoint.get("hero_orders", 0))
	for hid_value in known_hero_order():
		var hid: String = str(hid_value)
		if not hero_bond_levels.has(hid):
			hero_bond_levels[hid] = int(hero_levels.get(hid, 1))
		if not hero_skill_levels.has(hid):
			hero_skill_levels[hid] = initial_hero_skill_level(hid)
		hero_levels[hid] = int(hero_bond_levels.get(hid, 1))
	known_heroes = (checkpoint.get("known_heroes", {}) as Dictionary).duplicate(true)
	relics = (checkpoint.get("relics", []) as Array).duplicate()
	relic_levels = (checkpoint.get("relic_levels", {}) as Dictionary).duplicate(true)
	for rid in relics:
		if not relic_levels.has(str(rid)):
			relic_levels[str(rid)] = 1
	equipment_inventory = (checkpoint.get("equipment_inventory", []) as Array).duplicate()
	boss_defeat_counts = (checkpoint.get("boss_defeat_counts", {}) as Dictionary).duplicate(true)
	equipped = (checkpoint.get("equipped", {"weapon":"", "body":"", "treasure":"", "accessory":"", "jade":""}) as Dictionary).duplicate(true)
	skill_levels = (checkpoint.get("skills", {}) as Dictionary).duplicate(true)
	history_flags = (checkpoint.get("history_flags", {}) as Dictionary).duplicate(true)
	history_log.clear()
	for line in checkpoint.get("history_log", []) as Array:
		history_log.append(str(line))
	history_event_done = (checkpoint.get("history_done", {}) as Dictionary).duplicate(true)
	history_event_cursor = (checkpoint.get("history_cursor", {}) as Dictionary).duplicate(true)
	history_modifiers = (
		checkpoint.get("history_modifiers", default_history_modifiers()) as Dictionary
	).duplicate(true)
	faction_momentum = (checkpoint.get("faction_momentum", HistoryRouteRules.default_momentum()) as Dictionary).duplicate(true)
	history_rewrite_rate = float(checkpoint.get("history_rewrite_rate", 0.0))
	history_route_tags = (checkpoint.get("history_route_tags", {}) as Dictionary).duplicate(true)
	run_stats = (checkpoint.get("run_stats", {}) as Dictionary).duplicate(true)
	for hid in active_heroes:
		hero_cooldowns[str(hid)] = 0.0
	update_bonds()
	screen = "intermission"
	option_index = 0
	game_over_reason = "已載入章間存檔，可整備名將後繼續下一章。"
	play_bgm("menu")
	show_message("章間旅程已恢復。", 2.6)


func _process(delta: float) -> void:
	# Alpha.31 hotfix：遺物說明為阻斷型視窗，顯示期間完整凍結戰鬥流程。
	# 輸入仍由 _unhandled_input 接收，因此玩家可以正常關閉提示。
	if not pending_relic_notice.is_empty():
		queue_redraw()
		return
	Alpha36RosterProgressionHud.tick(self, alpha36_37_state)
	alpha24_update_release_guard(delta)
	alpha20_update(delta)
	alpha19_update(delta)
	if screen == "game":
		frame_serial += 1
		update_frame_metrics(delta)
		hit_stop_cooldown = max(0.0, hit_stop_cooldown - delta)
		if hit_stop_timer > 0.0:
			hit_stop_timer = max(0.0, hit_stop_timer - delta)
		else:
			update_game(delta)
	elif screen == "boss_intro":
		boss_intro_timer -= delta
		if boss_intro_timer <= 0.0:
			if chapter_manager.mark_boss_active():
				boss_spawned = true
				boss["telegraph_time"] = 0.0
				boss["telegraph_total"] = 0.0
				boss["control_lock"] = 0.0
				screen = "game"
				play_current_boss_bgm()
			else:
				# 狀態已被取消或結算時，不可強制回到戰鬥。
				screen = "victory" if chapter_manager.boss_is_resolved() else "menu"
	if game_message_timer > 0.0:
		game_message_timer -= delta
	if checkpoint_notice_timer > 0.0:
		checkpoint_notice_timer = max(0.0, checkpoint_notice_timer - delta)
	queue_redraw()


func _input(event: InputEvent) -> void:
	# V2.0 Alpha：統一由第一層接收鍵盤／滑鼠，並用 ui_accept + keycode + physical_keycode
	# 三重辨識確認鍵。加上短暫防連按，避免開啟彈窗的同一顆 Space 被再次吞掉或重複觸發。
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			handle_modal_mouse_click(mouse_event.position)
		return
	if not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	var key: int = int(key_event.keycode)
	if key == 0:
		key = int(key_event.physical_keycode)
	if key == 0 and key_event.unicode == 32:
		key = KEY_SPACE
	var confirm: bool = key_event.is_action_pressed("ui_accept") or is_confirm_key(key)
	if not pending_relic_notice.is_empty():
		if confirm or key == KEY_ESCAPE:
			pending_relic_notice.clear()
			play_sfx("ui_confirm")
			queue_redraw()
			get_viewport().set_input_as_handled()
		return
	# 升級畫面使用獨立輸入路徑：直接處理原始 Space／Enter，避免被其他 Modal
	# 的確認鍵轉換、焦點或 ui_accept 映射攔截。
	if screen == "levelup":
		var now_ms: int = Time.get_ticks_msec()
		if confirm:
			if now_ms < modal_input_lock_until_ms or now_ms - last_confirm_ms < 120:
				return
			last_confirm_ms = now_ms
			choose_levelup(option_index)
			queue_redraw()
			get_viewport().set_input_as_handled()
			return
		handle_option_screen_key(key)
		queue_redraw()
		get_viewport().set_input_as_handled()
		return
	# 主動名將替換畫面使用獨立導覽，直接辨識 Godot 的 ui_up／ui_down，
	# 避免 Windows 鍵盤配置只回報 action、未回報預期 keycode 時無法移動。
	if screen == "replace_hero":
		var now_ms: int = Time.get_ticks_msec()
		var move_up: bool = key_event.is_action_pressed("ui_up") or is_up_key(key) or is_left_key(key)
		var move_down: bool = key_event.is_action_pressed("ui_down") or is_down_key(key) or is_right_key(key)
		var count: int = active_heroes.size() + 1
		if move_up:
			option_index = wrapi(option_index - 1, 0, count)
			play_sfx("ui_move")
		elif move_down:
			option_index = wrapi(option_index + 1, 0, count)
			play_sfx("ui_move")
		elif confirm:
			if now_ms < modal_input_lock_until_ms or now_ms - last_confirm_ms < 120:
				return
			last_confirm_ms = now_ms
			play_sfx("ui_confirm")
			choose_replacement(option_index)
		elif key == KEY_ESCAPE:
			screen = "hero_encounter"
			option_index = 0
		queue_redraw()
		get_viewport().set_input_as_handled()
		return

	# 章間整備採獨立的橫向選單輸入。直接讀取 ui_left／ui_right，
	# 避免部分 Windows 鍵盤配置只回報 action 而 keycode 為 0，造成左右無反應。
	if screen == "intermission":
		var now_ms: int = Time.get_ticks_msec()
		var count: int = intermission_options().size()
		var move_left: bool = key_event.is_action_pressed("ui_left") or is_left_key(key) or is_up_key(key)
		var move_right: bool = key_event.is_action_pressed("ui_right") or is_right_key(key) or is_down_key(key)
		if move_left:
			option_index = wrapi(option_index - 1, 0, count)
			play_sfx("ui_move")
		elif move_right:
			option_index = wrapi(option_index + 1, 0, count)
			play_sfx("ui_move")
		elif confirm:
			if now_ms < modal_input_lock_until_ms or now_ms - last_confirm_ms < 120:
				return
			last_confirm_ms = now_ms
			handle_option_screen_key(KEY_ENTER)
		elif key == KEY_ESCAPE:
			return_to_menu()
		queue_redraw()
		get_viewport().set_input_as_handled()
		return

	# 其他 Modal 選單共用完整方向／確認流程；戰鬥畫面保留原始 Space／Shift 給閃避。
	# 舊版只在 confirm 時呼叫 handle_option_screen_key()，造成雙名將候選等畫面
	# 的左右／上下鍵完全沒有被處理。
	if screen in ["hero_encounter_pick", "hero_encounter", "shop", "game_over", "victory", "ending", "boss_loot", "camp_menu"]:
		var now_ms: int = Time.get_ticks_msec()
		if confirm and now_ms < modal_input_lock_until_ms:
			return
		if confirm and now_ms - last_confirm_ms < 120:
			return
		if confirm:
			last_confirm_ms = now_ms
			handle_option_screen_key(KEY_ENTER)
		else:
			handle_option_screen_key(key)
		queue_redraw()
		get_viewport().set_input_as_handled()
		return
	if screen == "game":
		handle_game_key(key)
	elif screen == "menu":
		handle_menu_key(key)
	elif screen == "character_select":
		handle_character_select_key(key)
	elif screen == "history_event":
		handle_history_event_key(key)
	elif screen == "chapter_intro":
		handle_chapter_intro_key(key)
	elif screen == "hero_config":
		handle_hero_config_key(key)
	elif screen == "config_replace":
		handle_config_replace_key(key)
	elif screen == "tab":
		handle_tab_key(key)
	elif screen == "codex":
		handle_codex_key(key)
	elif screen == "skins":
		handle_skins_key(key)
	elif screen == "settings":
		handle_settings_key(key)
	elif screen == "load_save":
		handle_load_save_key(key)
	elif screen in ["confirm_new_game", "confirm_delete_save"]:
		handle_confirm_screen_key(key)


func _unhandled_key_input(event: InputEvent) -> void:
	# Windows／特定鍵盤配置下，Space 偶爾會被 GUI 焦點先吃掉。
	# 僅針對升級畫面提供第二層保險，其他畫面不重複處理。
	if screen != "levelup" or not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	var key: int = int(key_event.keycode)
	if key == 0:
		key = int(key_event.physical_keycode)
	if key == 0 and key_event.unicode == 32:
		key = KEY_SPACE
	if not (key_event.is_action_pressed("ui_accept") or is_confirm_key(key)):
		return
	var now_ms: int = Time.get_ticks_msec()
	if now_ms < modal_input_lock_until_ms or now_ms - last_confirm_ms < 120:
		return
	last_confirm_ms = now_ms
	choose_levelup(option_index)
	queue_redraw()
	get_viewport().set_input_as_handled()


func handle_modal_mouse_click(pos: Vector2) -> void:
	if Time.get_ticks_msec() < modal_input_lock_until_ms:
		return
	if screen == "levelup":
		for i in range(level_choices.size()):
			var col: int = i % 3
			var row: int = int(i / 3)
			var rect := Rect2(198 + col * 300, 188 + row * 230, 286, 220)
			if rect.has_point(pos):
				option_index = i
				choose_levelup(i)
				return
	elif screen == "hero_encounter_pick":
		for i in range(encounter_candidates.size()):
			var rect := Rect2(150 + i * 500, 175, 460, 360)
			if rect.has_point(pos):
				choose_hero_candidate(i)
				return
	elif screen == "replace_hero":
		for i in range(active_heroes.size() + 1):
			var rect := Rect2(340, 205 + i * 68, 600, 52)
			if rect.has_point(pos):
				option_index = i
				choose_replacement(i)
				return


func is_confirm_key(key: int) -> bool:
	return key in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]


func is_up_key(key: int) -> bool:
	return key in [KEY_UP, KEY_W]


func is_down_key(key: int) -> bool:
	return key in [KEY_DOWN, KEY_S]


func is_left_key(key: int) -> bool:
	return key in [KEY_LEFT, KEY_A]


func is_right_key(key: int) -> bool:
	return key in [KEY_RIGHT, KEY_D]


func has_run_checkpoint() -> bool:
	return save_data.get("run_save", {}) is Dictionary and not (save_data.get("run_save", {}) as Dictionary).is_empty()


func menu_options() -> Array:
	var options: Array[String] = []
	if has_run_checkpoint():
		options.append("繼續遊戲")
		options.append("讀取存檔")
	options.append("史傳模式・黃巾之亂")
	options.append("演武試煉")
	options.append("亂世圖鑑")
	options.append("武將造型")
	options.append("設定")
	if has_run_checkpoint():
		options.append("刪除存檔")
	options.append("離開")
	return options


func identity_order() -> Array:
	return ["swordsman", "hunter", "poisoner", "heroine"]


func handle_menu_key(key: int) -> void:
	var options: Array = menu_options()
	if is_up_key(key):
		menu_index = wrapi(menu_index - 1, 0, options.size())
		play_sfx("ui_move")
	elif is_down_key(key):
		menu_index = wrapi(menu_index + 1, 0, options.size())
		play_sfx("ui_move")
	elif is_confirm_key(key):
		play_sfx("ui_confirm")
		var selected: String = str(options[menu_index])
		match selected:
			"繼續遊戲":
				continue_run_from_checkpoint()
			"讀取存檔":
				screen = "load_save"
				save_screen_index = 0
			"史傳模式・黃巾之亂":
				chosen_mode = "story"
				if has_run_checkpoint():
					screen = "confirm_new_game"
					confirm_index = 1
				else:
					screen = "character_select"
					select_index = 0
			"演武試煉":
				chosen_mode = "trial"
				screen = "character_select"
				select_index = 0
			"亂世圖鑑":
				screen = "codex"
				codex_page = 0
				codex_index = 0
			"武將造型":
				screen = "skins"
				skin_hero_index = 0
				skin_variant_index = 0
			"設定":
				screen = "settings"
				settings_index = 0
			"刪除存檔":
				screen = "confirm_delete_save"
				confirm_index = 1
			"離開":
				get_tree().quit()


func handle_load_save_key(key: int) -> void:
	if is_up_key(key) or is_left_key(key) or is_down_key(key) or is_right_key(key):
		save_screen_index = 1 - save_screen_index
		play_sfx("ui_move")
	elif is_confirm_key(key):
		play_sfx("ui_confirm")
		if save_screen_index == 0 and has_run_checkpoint():
			continue_run_from_checkpoint()
		else:
			screen = "menu"
	elif key == KEY_ESCAPE:
		screen = "menu"


func handle_confirm_screen_key(key: int) -> void:
	if is_up_key(key) or is_left_key(key) or is_down_key(key) or is_right_key(key):
		confirm_index = 1 - confirm_index
		play_sfx("ui_move")
	elif key == KEY_ESCAPE:
		screen = "menu"
	elif is_confirm_key(key):
		play_sfx("ui_confirm")
		if confirm_index == 1:
			screen = "menu"
			return
		if screen == "confirm_delete_save":
			clear_run_checkpoint()
			menu_index = 0
			screen = "menu"
			show_message("存檔已刪除，永久解鎖與設定仍保留。", 2.6)
		else:
			clear_run_checkpoint()
			screen = "character_select"
			select_index = 0


func handle_character_select_key(key: int) -> void:
	var order: Array = identity_order()
	if is_left_key(key) or is_up_key(key):
		select_index = wrapi(select_index - 1, 0, order.size())
		play_sfx("ui_move")
	elif is_right_key(key) or is_down_key(key):
		select_index = wrapi(select_index + 1, 0, order.size())
		play_sfx("ui_move")
	elif is_confirm_key(key):
		chosen_identity = order[select_index]
		play_sfx("ui_confirm")
		clear_run_checkpoint()
		start_run(chosen_mode, chosen_identity)
	elif key == KEY_ESCAPE:
		screen = "menu"
		play_sfx("ui_move")


func handle_game_key(key: int) -> void:
	if key in [KEY_TAB, KEY_I]:
		previous_screen = "game"
		screen = "tab"
		tab_page = 0
		tab_index = 0
		play_sfx("ui_confirm")
	elif key in [KEY_SPACE, KEY_SHIFT]:
		try_dash()
	elif key == KEY_E:
		try_interact()
	elif key in [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5]:
		var idx: int = int(key - KEY_1)
		if idx >= 0 and idx < active_heroes.size():
			try_trigger_hero(active_heroes[idx], true)
	elif key == KEY_F3:
		debug_overlay = not debug_overlay
		show_message("除錯資訊：%s" % ("開啟" if debug_overlay else "關閉"), 1.5)
	elif key == KEY_ESCAPE:
		previous_screen = "game"
		screen = "tab"
		tab_page = 3
		tab_index = 0


func show_boss_ability(text: String, duration: float = 1.8) -> void:
	boss_ability_banner = {"text": text, "life": duration, "max_life": duration}
	play_sfx("boss_intro", 1.04)
	play_sfx("boss_warning", 0.92)


func result_options() -> Array[String]:
	if screen == "ending":
		return ["返回主選單"]
	if screen == "game_over":
		return ["重新挑戰", "返回主選單"]
	if screen == "victory" and chosen_mode == "story" and chapter_manager.has_next_chapter():
		return ["查看下一章", "返回主選單"]
	if screen == "victory":
		return ["返回主選單"]
	return ["重新挑戰", "返回主選單"]


func intermission_options() -> Array[String]:
	if chapter_manager.next_chapter_ready():
		return ["名將整備", "裝備整備", "儲存章節進度", "進入下一章", "返回主選單"]
	return ["名將整備", "裝備整備", "儲存章節進度", "返回主選單"]


func handle_shop_navigation(key: int) -> bool:
	var item_count: int = shop_choices.size()
	var total_count: int = item_count + 2
	if total_count <= 0:
		return false
	var columns: int = 2
	var equipment_index: int = item_count
	var leave_index: int = item_count + 1
	# 商品採雙欄；底部提供「裝備整備」與「離開行商」兩個固定操作。
	if is_left_key(key):
		if option_index >= equipment_index:
			option_index = max(0, item_count - 1)
		else:
			option_index = max(0, option_index - 1)
		play_sfx("ui_move")
		return true
	if is_right_key(key):
		if option_index == equipment_index:
			option_index = leave_index
		elif option_index == leave_index:
			option_index = equipment_index
		else:
			option_index = min(item_count - 1, option_index + 1)
		play_sfx("ui_move")
		return true
	if is_up_key(key):
		if option_index >= equipment_index:
			var last_row_start: int = max(0, item_count - (2 if item_count % 2 == 0 else 1))
			option_index = last_row_start
		else:
			option_index = max(0, option_index - columns)
		play_sfx("ui_move")
		return true
	if is_down_key(key):
		if option_index >= equipment_index:
			return true
		var next_index: int = option_index + columns
		option_index = next_index if next_index < item_count else equipment_index
		play_sfx("ui_move")
		return true
	return false

func handle_option_screen_key(key: int) -> void:
	var count: int = 1
	match screen:
		"levelup":
			count = level_choices.size()
		"hero_encounter_pick":
			count = encounter_candidates.size() + 2
		"hero_encounter":
			count = 3
		"shop":
			count = shop_choices.size() + 2
		"replace_hero":
			count = active_heroes.size() + 1
		"game_over", "victory", "ending":
			count = result_options().size()
		"intermission":
			count = intermission_options().size()
		"boss_loot":
			count = 1
		"camp_menu":
			count = camp_menu_options().size()
	if screen == "shop" and handle_shop_navigation(key):
		return
	if screen == "levelup" and count > 3:
		var columns: int = 3
		if is_left_key(key):
			option_index = wrapi(option_index - 1, 0, count)
			play_sfx("ui_move")
		elif is_right_key(key):
			option_index = wrapi(option_index + 1, 0, count)
			play_sfx("ui_move")
		elif is_up_key(key):
			option_index = wrapi(option_index - columns, 0, count)
			play_sfx("ui_move")
		elif is_down_key(key):
			option_index = wrapi(option_index + columns, 0, count)
			play_sfx("ui_move")
	elif is_up_key(key) or is_left_key(key):
		option_index = wrapi(option_index - 1, 0, count)
		play_sfx("ui_move")
	elif is_down_key(key) or is_right_key(key):
		option_index = wrapi(option_index + 1, 0, count)
		play_sfx("ui_move")
	elif is_confirm_key(key):
		play_sfx("ui_confirm")
		if screen == "boss_loot":
			accept_boss_loot()
			return
		match screen:
			"levelup":
				choose_levelup(option_index)
			"hero_encounter_pick":
				choose_hero_candidate(option_index)
			"hero_encounter":
				choose_hero_encounter(option_index)
			"shop":
				choose_shop(option_index)
			"replace_hero":
				choose_replacement(option_index)
			"camp_menu":
				choose_camp_menu(option_index)
			"game_over":
				if option_index == 0:
					restart_current_chapter()
				else:
					return_to_menu()
			"victory", "ending":
				handle_victory_option(option_index)
			"intermission":
				var options: Array[String] = intermission_options()
				var selected: String = options[option_index]
				if selected == "名將整備":
					open_hero_config("intermission")
				elif selected == "裝備整備":
					previous_screen = "intermission"
					screen = "tab"
					tab_page = 1
					tab_index = 0
					tab_scroll = 0
				elif selected == "儲存章節進度":
					if save_run_checkpoint():
						show_message("章節進度已手動保存。", 2.4)
					else:
						show_message("目前無法建立章節存檔。", 2.4)
				elif selected == "進入下一章":
					begin_next_chapter()
				else:
					return_to_menu()
	elif key == KEY_ESCAPE:
		if screen in ["hero_encounter", "shop", "replace_hero"]:
			screen = "game"
		elif screen == "intermission":
			return_to_menu()


func handle_victory_option(index: int) -> void:
	var options: Array[String] = result_options()
	if index < 0 or index >= options.size():
		return
	var selected: String = options[index]
	match selected:
		"查看下一章":
			open_chapter_intermission()
		_:
			return_to_menu()


func open_chapter_intermission() -> void:
	if not chapter_manager.has_next_chapter():
		return_to_menu()
	option_index = 0
	screen = "intermission"
	play_bgm("intermission")


func restart_current_chapter() -> void:
	# 重玩本章保留本局已建立的技能、名將、遺物與銅錢，
	# 只重置當前章節的敵人、事件、Boss與臨時戰鬥狀態。
	chapter_manager.reset_current_chapter_state()
	reset_chapter_runtime()
	screen = "game"
	option_index = 0
	play_current_battle_bgm()
	show_message("重新挑戰%s" % chapter_manager.current_title(), 3.0)


func reset_chapter_runtime() -> void:
	enemies.clear()
	player_shots.clear()
	enemy_shots.clear()
	pickups.clear()
	particles.clear()
	zones.clear()
	allies.clear()
	decorations.clear()
	obstacles.clear()
	damage_numbers.clear()
	enemy_spatial_grid.clear()
	enemy_uid_index.clear()
	sfx_last_play_ms.clear()
	performance_level = 0
	frame_time_ema = 1.0 / 60.0
	frame_stats_timer = 0.0
	frame_peak_accum = 0.0
	frame_peak_last_ms = 0.0
	frame_spikes_accum = 0
	frame_spikes_last = 0
	# Alpha.54：異常聯動回歸。
	enemies.clear()
	spawn_enemy("peasant", player["pos"] + Vector2(72.0, 0.0))
	apply_enemy_status(0, "burn", 3.0, 1.2, 1)
	apply_enemy_status(0, "poison", 3.0, 1.2, 1)
	var reaction_statuses: Dictionary = enemies[0].get("status_effects", {}) as Dictionary
	if not reaction_statuses.has("toxic_blaze"):
		self_test_fail("Alpha.54 劇毒灼燒未觸發")
		return
	apply_enemy_status(0, "slow", 2.0, 0.25, 1)
	apply_enemy_status(0, "slow", 2.0, 0.25, 1)
	apply_enemy_status(0, "slow", 2.0, 0.25, 1)
	reaction_statuses = enemies[0].get("status_effects", {}) as Dictionary
	if not reaction_statuses.has("stun"):
		self_test_fail("Alpha.54 冰封聯動未觸發")
		return
	hit_stop_timer = 0.0
	hit_stop_cooldown = 0.0
	hit_stop_triggers_accum = 0
	hit_stop_triggers_last = 0
	combat_motif_step = 0
	low_fps_timer = 0.0
	recovery_timer = 0.0
	performance_pressure = "穩定"
	current_encounter = ""
	replace_candidate = ""
	replace_index = 0
	encounter_cooldowns.clear()
	merchant_active = false
	merchant_stock.clear()
	camp_active = false
	camp_pos = Vector2.ZERO
	camp_spawned = false
	chest_active = false
	chest_pos = Vector2.ZERO
	chest_spawned = false
	chapter_elite_relic_given = false
	chapter_boss_relic_given = false
	chapter_reward_relic = ""
	chapter_natural_relics = 0
	recruit_refresh_count = 0
	recruit_free_refresh_used = false
	history_event_active = false
	history_event_pos = Vector2.ZERO
	current_history_event.clear()
	history_event_options.clear()
	history_event_index = 0
	level_choices.clear()
	shop_choices.clear()
	pending_levelups = 0
	bond_combo_progress.clear()
	temporary_attack_speed = 0.0
	temporary_speed = 0.0
	reserve_roar_cd = 0.0
	auto_hero_cast_delay = 0.0
	pending_run_result = 0
	boss.clear()
	boss_spawned = false
	boss_intro_timer = 0.0
	boss_ability_banner.clear()
	player_action_anim.clear()
	boss_action_anim.clear()
	elapsed = 0.0
	spawn_timer = 0.0
	hero_spawn_timer = 22.0
	merchant_spawn_timer = float(current_chapter().get("merchant_time", 92.0))
	game_message = ""
	game_message_timer = 0.0
	yellow_water_used = false
	survival_used = false
	player["pos"] = Vector2(WORLD.size.x * 0.5, WORLD.size.y * 0.5)
	player["hp"] = player["max_hp"]
	player["shield"] = 0.0
	player["invuln"] = 0.0
	player["toxicity"] = 0.0
	player["attack_timer"] = 0.25
	player["dash_timer"] = 0.0
	player["dash_active"] = 0.0
	player["facing"] = Vector2.RIGHT
	player["attack_speed_buff"] = 0.0
	player["kill_speed_buff"] = 0.0
	player["formation_relic_cd"] = 0.0
	for hid in active_heroes:
		hero_cooldowns[hid] = 0.0
	update_bonds()
	alpha19_apply_chapter_setup()
	generate_world()


func begin_next_chapter() -> void:
	if not chapter_manager.next_chapter_ready():
		return
	if not chapter_manager.advance_to_next():
		return_to_menu()
		return
	reset_chapter_runtime()
	chapter_intro_return_screen = "game"
	chapter_intro_page = 0
	screen = "chapter_intro"
	option_index = 0
	play_bgm("intro")
	show_message("進入%s" % chapter_manager.current_title(), 3.5)


func known_hero_order() -> Array[String]:
	var order: Array[String] = []
	for hid in active_heroes:
		var active_id: String = str(hid)
		if not order.has(active_id):
			order.append(active_id)
	for hid in reserve_heroes:
		var reserve_id: String = str(hid)
		if not order.has(reserve_id):
			order.append(reserve_id)
	for hid in camp_heroes:
		var camp_id: String = str(hid)
		if not order.has(camp_id):
			order.append(camp_id)
	for hid in known_heroes.keys():
		var known_id: String = str(hid)
		if not order.has(known_id):
			order.append(known_id)
	return order


func open_hero_config(origin: String) -> void:
	if known_hero_order().is_empty():
		show_message("尚未結識任何名將。", 2.0)
		return
	hero_config_origin = origin
	hero_config_index = 0
	config_candidate = ""
	config_replace_index = 0
	screen = "hero_config"
	play_sfx("ui_confirm")


func close_hero_config() -> void:
	config_candidate = ""
	var completed_safe_setup: bool = hero_config_origin in ["merchant", "camp", "intermission"]
	if hero_config_origin == "intermission":
		screen = "intermission"
	elif hero_config_origin == "merchant":
		screen = "shop"
	else:
		screen = "game"
	if completed_safe_setup and reserve_heroes.has("daqiao") and not player.is_empty():
		temporary_speed = max(temporary_speed, 5.0)
		show_message("大喬後援：整備後移動速度暫時提高", 2.4)
	if hero_config_origin == "intermission":
		save_run_checkpoint()
	play_sfx("ui_move")


func assign_hero_roster(hid: String, target: String) -> void:
	if not heroes.has(hid):
		return
	match target:
		"active":
			if active_heroes.has(hid):
				show_message("%s已在主戰欄。" % heroes[hid]["name"], 1.8)
				return
			if active_heroes.size() >= active_limit():
				config_candidate = hid
				config_replace_index = 0
				screen = "config_replace"
				return
			reserve_heroes.erase(hid)
			camp_heroes.erase(hid)
			active_heroes.append(hid)
			hero_cooldowns[hid] = hero_cooldown_value(hid)
			show_message("%s編入主戰，技能由完整冷卻開始。" % heroes[hid]["name"], 2.4)
		"reserve":
			if reserve_heroes.has(hid):
				show_message("%s已在後備欄，持續提供被動與羈絆。" % heroes[hid]["name"], 1.9)
				return
			if reserve_heroes.size() >= reserve_limit():
				show_message("後備欄已滿（%d／%d），請先將其他名將移至營地。" % [reserve_heroes.size(), reserve_limit()], 2.5)
				play_sfx("ui_error")
				return
			active_heroes.erase(hid)
			camp_heroes.erase(hid)
			hero_cooldowns.erase(hid)
			reserve_heroes.append(hid)
			show_message("%s編入後備，開始提供被動與羈絆。" % heroes[hid]["name"], 2.4)
		"camp":
			if camp_heroes.has(hid):
				show_message("%s已在營地待命。" % heroes[hid]["name"], 1.8)
				return
			active_heroes.erase(hid)
			reserve_heroes.erase(hid)
			hero_cooldowns.erase(hid)
			camp_heroes.append(hid)
			show_message("%s移至營地，不再提供後備被動。" % heroes[hid]["name"], 2.4)
	update_bonds()
	play_sfx("ui_confirm")
	if hero_config_origin == "intermission":
		save_run_checkpoint()



func hero_roster_state(hid: String) -> String:
	return HeroRosterManagerScript.state_of(hid, active_heroes, reserve_heroes, camp_heroes)


func sync_roster_after_change() -> void:
	update_bonds()
	if hero_config_origin == "intermission":
		save_run_checkpoint()


func assign_hero_to_reserve(hid: String) -> void:
	var result: Dictionary = HeroRosterManagerScript.move_to_reserve(
		hid, active_heroes, reserve_heroes, camp_heroes, reserve_limit()
	)
	match str(result.get("reason", "")):
		"already_reserve":
			show_message("%s已在後備被動欄。" % heroes[hid]["name"], 1.8)
			return
		"reserve_full":
			show_message("後備欄已滿，請先將一名後備武將移回營地。", 2.4)
			play_sfx("ui_error")
			return
	if bool(result.get("changed", false)):
		hero_cooldowns.erase(hid)
		sync_roster_after_change()
		show_message("%s編入後備，開始提供被動與羈絆。" % heroes[hid]["name"], 2.4)
		play_sfx("ui_confirm")


func assign_hero_to_camp(hid: String) -> void:
	var result: Dictionary = HeroRosterManagerScript.move_to_camp(
		hid, active_heroes, reserve_heroes, camp_heroes
	)
	if str(result.get("reason", "")) == "already_camp":
		show_message("%s目前已在營地待命。" % heroes[hid]["name"], 1.8)
		return
	if bool(result.get("changed", false)):
		hero_cooldowns.erase(hid)
		sync_roster_after_change()
		show_message("%s移至營地，不再提供後備被動。" % heroes[hid]["name"], 2.4)
		play_sfx("ui_confirm")


func assign_hero_to_active(hid: String) -> void:
	if active_heroes.has(hid):
		show_message("%s目前已在主戰陣容。" % heroes[hid]["name"], 1.8)
		return
	if active_heroes.size() >= active_limit():
		config_candidate = hid
		config_replace_index = 0
		screen = "config_replace"
		play_sfx("ui_confirm")
		return
	var result: Dictionary = HeroRosterManagerScript.move_to_active(
		hid, active_heroes, reserve_heroes, camp_heroes, active_limit()
	)
	if bool(result.get("changed", false)):
		hero_cooldowns[hid] = hero_cooldown_value(hid)
		sync_roster_after_change()
		show_message("%s調至主戰欄，技能由完整冷卻開始。" % heroes[hid]["name"], 2.5)
		play_sfx("ui_confirm")


func cycle_support_assignment(hid: String) -> void:
	match hero_roster_state(hid):
		"active":
			assign_hero_to_reserve(hid)
		"reserve":
			assign_hero_to_camp(hid)
		_:
			assign_hero_to_reserve(hid)


func place_hero_in_support(hid: String) -> String:
	var destination: String = HeroRosterManagerScript.place_in_support(
		hid, active_heroes, reserve_heroes, camp_heroes, reserve_limit()
	)
	hero_cooldowns.erase(hid)
	return destination

func handle_hero_config_key(key: int) -> void:
	var order: Array[String] = known_hero_order()
	if order.is_empty():
		close_hero_config()
		return
	hero_config_index = clampi(hero_config_index, 0, order.size() - 1)
	if hero_position_picker_open:
		handle_hero_position_picker_key(key)
		return
	if is_up_key(key) or is_left_key(key):
		hero_config_index = HeroRosterControllerScript.wrap_cursor(hero_config_index, -1, order.size())
		play_sfx("ui_move")
	elif is_down_key(key) or is_right_key(key):
		hero_config_index = HeroRosterControllerScript.wrap_cursor(hero_config_index, 1, order.size())
		play_sfx("ui_move")
	elif key == KEY_ESCAPE or key == KEY_TAB:
		close_hero_config()
	elif is_confirm_key(key):
		var hid: String = order[hero_config_index]
		var decision: Dictionary = HeroRosterControllerScript.open_picker_for(
			hid,
			hero_roster_state(hid)
		)
		hero_position_candidate = str(decision.get("hero_id", hid))
		hero_position_index = int(decision.get("target_index", 2))
		hero_position_picker_open = true
		play_sfx("ui_confirm")
		queue_redraw()

func handle_hero_position_picker_key(key: int) -> void:
	if key == KEY_ESCAPE or key == KEY_TAB:
		hero_position_picker_open = false
		play_sfx("ui_cancel")
		queue_redraw()
		return
	if is_up_key(key) or is_left_key(key):
		hero_position_index = HeroRosterControllerScript.wrap_cursor(hero_position_index, -1, 4)
		play_sfx("ui_move")
		queue_redraw()
		return
	if is_down_key(key) or is_right_key(key):
		hero_position_index = HeroRosterControllerScript.wrap_cursor(hero_position_index, 1, 4)
		play_sfx("ui_move")
		queue_redraw()
		return
	if not is_confirm_key(key):
		return
	if hero_position_index == 3:
		hero_position_picker_open = false
		play_sfx("ui_cancel")
		queue_redraw()
		return

	var hid: String = hero_position_candidate
	if hid == "" or not heroes.has(hid):
		hero_position_picker_open = false
		queue_redraw()
		return

	var decision: Dictionary = HeroRosterControllerScript.resolve_target(
		hid,
		hero_position_index,
		active_heroes,
		reserve_heroes,
		camp_heroes,
		active_limit(),
		reserve_limit()
	)
	var action: StringName = decision.get("action", HeroRosterControllerScript.ACTION_NONE)
	match action:
		HeroRosterControllerScript.ACTION_ALREADY_ASSIGNED:
			var state_id: String = str(decision.get("state", "camp"))
			var state_label: String = "主戰" if state_id == "active" else ("後備" if state_id == "reserve" else "營地")
			show_message("%s目前已在%s。" % [heroes[hid]["name"], state_label], 2.0)
			hero_position_picker_open = false
			play_sfx("ui_error")
		HeroRosterControllerScript.ACTION_OPEN_REPLACEMENT:
			config_candidate = hid
			config_replace_mode = str(decision.get("mode", "active"))
			config_replace_index = 0
			hero_position_picker_open = false
			screen = "config_replace"
			play_sfx("ui_confirm")
		HeroRosterControllerScript.ACTION_MOVE_HERO:
			match str(decision.get("to", "camp")):
				"active":
					assign_hero_to_active(hid)
				"reserve":
					assign_hero_to_reserve(hid)
				_:
					assign_hero_to_camp(hid)
			hero_position_picker_open = false
		_:
			hero_position_picker_open = false
	queue_redraw()

func handle_config_replace_key(key: int) -> void:
	var pool: Array = active_heroes if config_replace_mode == "active" else reserve_heroes
	config_replace_index = clampi(config_replace_index, 0, pool.size())
	if is_up_key(key) or is_left_key(key):
		config_replace_index = wrapi(config_replace_index - 1, 0, pool.size() + 1)
		play_sfx("ui_move")
	elif is_down_key(key) or is_right_key(key):
		config_replace_index = wrapi(config_replace_index + 1, 0, pool.size() + 1)
		play_sfx("ui_move")
	elif key == KEY_ESCAPE or key == KEY_TAB:
		config_candidate = ""
		screen = "hero_config"
		play_sfx("ui_cancel")
	elif is_confirm_key(key):
		if config_replace_index >= pool.size():
			config_candidate = ""
			screen = "hero_config"
			play_sfx("ui_cancel")
			return
		var old_id: String = str(pool[config_replace_index])
		var new_id: String = config_candidate
		if config_replace_mode == "active":
			active_heroes[config_replace_index] = new_id
			reserve_heroes.erase(new_id)
			camp_heroes.erase(new_id)
			place_hero_in_support(old_id)
			hero_cooldowns.erase(old_id)
			hero_cooldowns[new_id] = hero_cooldown_value(new_id)
			show_message("%s編入主戰，%s轉入後援。" % [heroes[new_id]["name"], heroes[old_id]["name"]], 2.6)
		else:
			reserve_heroes[config_replace_index] = new_id
			active_heroes.erase(new_id)
			hero_cooldowns.erase(new_id)
			camp_heroes.erase(new_id)
			if not camp_heroes.has(old_id):
				camp_heroes.append(old_id)
			show_message("%s編入後備，%s返回營地。" % [heroes[new_id]["name"], heroes[old_id]["name"]], 2.6)
		update_bonds()
		play_sfx("ui_confirm")
		config_candidate = ""
		screen = "hero_config"
		if hero_config_origin == "intermission":
			save_run_checkpoint()

func handle_tab_key(key: int) -> void:
	if key in [KEY_TAB, KEY_I, KEY_ESCAPE]:
		var returning_to_intermission: bool = previous_screen == "intermission"
		var returning_to_camp: bool = previous_screen == "camp_menu"
		screen = previous_screen
		if returning_to_intermission:
			save_run_checkpoint()
			show_message("章間裝備配置已保存。", 2.0)
		elif returning_to_camp:
			save_run_checkpoint()
			show_message("紮營整備已保存。", 2.0)
		play_sfx("ui_move")
		return
	if is_left_key(key):
		tab_page = wrapi(tab_page - 1, 0, 5)
		tab_index = 0
		tab_scroll = 0
		play_sfx("ui_move")
	elif is_right_key(key):
		tab_page = wrapi(tab_page + 1, 0, 5)
		tab_index = 0
		tab_scroll = 0
		play_sfx("ui_move")
	elif is_up_key(key):
		tab_index = max(0, tab_index - 1)
		tab_scroll = max(0, tab_scroll - 1)
		play_sfx("ui_move")
	elif is_down_key(key):
		tab_index += 1
		tab_scroll += 1
		play_sfx("ui_move")
	elif is_confirm_key(key) and tab_page == 1:
		equip_selected_inventory_item()

func codex_pages() -> Array[String]:
	return ["羈絆", "名將", "裝備", "遺物", "章回"]


func codex_ids() -> Array:
	match codex_page:
		0: return bond_defs.keys()
		1: return heroes.keys()
		2: return equipment_defs.keys()
		3: return relic_defs.keys()
		_: return GameData.chapters()


func handle_codex_key(key: int) -> void:
	if is_left_key(key):
		codex_page = wrapi(codex_page - 1, 0, codex_pages().size())
		codex_index = 0
		play_sfx("ui_move")
	elif is_right_key(key):
		codex_page = wrapi(codex_page + 1, 0, codex_pages().size())
		codex_index = 0
		play_sfx("ui_move")
	else:
		var ids: Array = codex_ids()
		if is_up_key(key) and not ids.is_empty():
			codex_index = wrapi(codex_index - 1, 0, ids.size())
			play_sfx("ui_move")
		elif is_down_key(key) and not ids.is_empty():
			codex_index = wrapi(codex_index + 1, 0, ids.size())
			play_sfx("ui_move")
		elif key == KEY_ESCAPE or is_confirm_key(key):
			screen = "menu"
			play_sfx("ui_confirm")


func handle_skins_key(key: int) -> void:
	var hlist: Array = skin_defs.keys()
	if is_left_key(key):
		skin_hero_index = wrapi(skin_hero_index - 1, 0, hlist.size())
		skin_variant_index = 0
		play_sfx("ui_move")
	elif is_right_key(key):
		skin_hero_index = wrapi(skin_hero_index + 1, 0, hlist.size())
		skin_variant_index = 0
		play_sfx("ui_move")
	elif is_up_key(key):
		var hid: String = hlist[skin_hero_index]
		skin_variant_index = wrapi(skin_variant_index - 1, 0, skin_defs[hid].size())
		play_sfx("ui_move")
	elif is_down_key(key):
		var hid: String = hlist[skin_hero_index]
		skin_variant_index = wrapi(skin_variant_index + 1, 0, skin_defs[hid].size())
		play_sfx("ui_move")
	elif is_confirm_key(key):
		var hid: String = hlist[skin_hero_index]
		var skin: Dictionary = skin_defs[hid][skin_variant_index]
		if bool(skin["owned"]):
			save_data["selected_skins"][hid] = skin["id"]
			save_game_meta()
			refresh_skin_asset(hid)
			play_sfx("ui_confirm")
	elif key == KEY_ESCAPE:
		screen = "menu"


func handle_settings_key(key: int) -> void:
	if is_up_key(key):
		settings_index = wrapi(settings_index - 1, 0, 8)
		play_sfx("ui_move")
	elif is_down_key(key):
		settings_index = wrapi(settings_index + 1, 0, 8)
		play_sfx("ui_move")
	elif is_left_key(key) or is_right_key(key) or is_confirm_key(key):
		var dir: float = -1.0 if is_left_key(key) else 1.0
		match settings_index:
			0:
				save_data["settings"]["bgm"] = clamp(float(save_data["settings"]["bgm"]) + dir * 0.1, 0.0, 1.0)
			1:
				save_data["settings"]["sfx"] = clamp(float(save_data["settings"]["sfx"]) + dir * 0.1, 0.0, 1.0)
			2:
				save_data["settings"]["effects"] = clamp(float(save_data["settings"].get("effects", 0.82)) + dir * 0.1, 0.35, 1.0)
			3:
				var modes: Array[String] = ["easy", "story", "hard"]
				var current: int = modes.find(difficulty_id())
				var step: int = -1 if is_left_key(key) else 1
				save_data["settings"]["difficulty"] = modes[wrapi(current + step, 0, modes.size())]
			4:
				save_data["settings"]["shake"] = not bool(save_data["settings"].get("shake", true))
			5:
				save_data["settings"]["damage_numbers"] = not bool(save_data["settings"].get("damage_numbers", true))
			6:
				save_data["settings"]["fullscreen"] = not bool(save_data["settings"]["fullscreen"])
			7:
				screen = "menu"
		apply_settings()
		save_game_meta()
		play_sfx("ui_confirm")
	elif key == KEY_ESCAPE:
		screen = "menu"
		save_game_meta()


func refresh_skin_asset(hero_id: String) -> void:
	if not skin_defs.has(hero_id):
		return
	var sid: String = str(save_data["selected_skins"].get(hero_id, "default"))
	for skin in skin_defs[hero_id]:
		if str(skin["id"]) == sid:
			portrait_tex[hero_id] = runtime_texture(str(skin["portrait"]))
			sprite_tex[hero_id] = runtime_texture(str(skin["sprite"]))
			return


func return_to_menu() -> void:
	reset_run_data()
	screen = "menu"
	menu_index = 0
	play_bgm("menu")


func reset_run_data() -> void:
	player = {}
	enemies.clear()
	player_shots.clear()
	enemy_shots.clear()
	pickups.clear()
	particles.clear()
	zones.clear()
	allies.clear()
	decorations.clear()
	obstacles.clear()
	damage_numbers.clear()
	enemy_spatial_grid.clear()
	enemy_uid_index.clear()
	sfx_last_play_ms.clear()
	performance_level = 0
	frame_time_ema = 1.0 / 60.0
	frame_stats_timer = 0.0
	frame_peak_accum = 0.0
	frame_peak_last_ms = 0.0
	frame_spikes_accum = 0
	frame_spikes_last = 0
	hit_stop_timer = 0.0
	hit_stop_cooldown = 0.0
	hit_stop_triggers_accum = 0
	hit_stop_triggers_last = 0
	combat_motif_step = 0
	low_fps_timer = 0.0
	recovery_timer = 0.0
	performance_pressure = "穩定"
	active_heroes.clear()
	reserve_heroes.clear()
	camp_heroes.clear()
	hero_levels.clear()
	hero_skill_levels.clear()
	hero_experience.clear()
	alpha36_37_state = Alpha36RosterProgressionHud.new_state()
	hero_bond_levels.clear()
	departed_heroes.clear()
	hero_star_points = 0
	hero_orders = 0
	hero_cooldowns.clear()
	known_heroes.clear()
	active_bonds.clear()
	bond_combo_progress.clear()
	relics.clear()
	relic_levels.clear()
	equipment_inventory.clear()
	equipped = {"weapon":"", "body":"", "treasure":"", "accessory":"", "jade":""}
	pending_boss_loot.clear()
	ending_snapshot.clear()
	ending_committed = false
	boss_ability_banner.clear()
	skill_levels.clear()
	encounter_cooldowns.clear()
	current_encounter = ""
	replace_candidate = ""
	merchant_active = false
	merchant_stock.clear()
	camp_active = false
	camp_pos = Vector2.ZERO
	camp_spawned = false
	chest_active = false
	chest_pos = Vector2.ZERO
	chest_spawned = false
	chapter_elite_relic_given = false
	chapter_boss_relic_given = false
	chapter_reward_relic = ""
	chapter_natural_relics = 0
	recruit_refresh_count = 0
	recruit_free_refresh_used = false
	history_event_active = false
	history_event_pos = Vector2.ZERO
	current_history_event.clear()
	history_event_options.clear()
	history_event_index = 0
	history_event_done.clear()
	history_event_cursor.clear()
	history_flags.clear()
	history_log.clear()
	history_modifiers = default_history_modifiers()
	faction_momentum = HistoryRouteRules.default_momentum()
	history_rewrite_rate = 0.0
	history_route_tags.clear()
	performance_cleanup_timer = 0.5
	performance_pressure = "穩定"
	boss.clear()
	boss_spawned = false
	boss_intro_timer = 0.0
	boss_ability_banner.clear()
	elapsed = 0.0
	spawn_timer = 0.0
	hero_spawn_timer = 24.0
	merchant_spawn_timer = 105.0
	merchant_visit = 0
	game_message = ""
	game_message_timer = 0.0
	screen_shake = 0.0
	yellow_water_used = false
	survival_used = false
	temporary_attack_speed = 0.0
	temporary_speed = 0.0
	reserve_roar_cd = 0.0
	pending_levelups = 0
	game_over_reason = ""
	auto_hero_cast_delay = 0.0
	chapter_clear_snapshot.clear()
	pending_run_result = 0
	merchant_pos = Vector2.ZERO
	encounter_pos = Vector2.ZERO
	level_choices.clear()
	shop_choices.clear()
	option_index = 0
	replace_index = 0
	hero_config_index = 0
	hero_config_origin = "game"
	config_candidate = ""
	config_replace_index = 0
	if chapter_manager != null:
		chapter_manager.start_campaign("story")


func start_run(mode: String, identity_id: String) -> void:
	reset_run_data()
	chosen_mode = mode
	chosen_identity = identity_id
	chapter_manager.start_campaign(mode)
	var idata: Dictionary = identities[identity_id]
	player = {
		"pos": Vector2(WORLD.size.x * 0.5, WORLD.size.y * 0.5),
		"hp": float(idata["hp"]),
		"max_hp": float(idata["hp"]),
		"shield": 0.0,
		"speed": float(idata["speed"]),
		"base_speed": float(idata["speed"]),
		"damage": float(idata["damage"]),
		"attack_interval": float(idata["attack_interval"]),
		"attack_timer": 0.15,
		"weapon": idata["weapon"],
		"invuln": 0.0,
		"flash": 0.0,
		"dash_cd": 5.0,
		"dash_timer": 0.0,
		"dash_active": 0.0,
		"dash_dir": Vector2.RIGHT,
		"facing": Vector2.RIGHT,
		"level": 1,
		"xp": 0.0,
		"xp_need": 18.0,
		"coins": 28,
		"armor": 0.0,
		"crit": 0.05,
		"magnet": 115.0,
		"pierce": 0,
		"multishot": 0,
		"poison_power": 1.0,
		"heal_power": 1.0,
		"hero_cd_mult": 1.0,
		"projectile_mult": 1.0,
		"toxicity": 0.0,
		"attack_speed_buff": 0.0,
		"kill_speed_buff": 0.0,
		"move_slow": 0.0,
		"control_lock": 0.0,
		"control_resist": 0.0,
		"vision_obscure": 0.0,
		"survival_cd": 0.0,
		"formation_relic_cd": 0.0
	}
	if identity_id in ["hunter", "archer"]:
		player["pierce"] = 1
		skill_levels["projectile"] = 1
	elif identity_id in ["poisoner", "strategist"]:
		skill_levels["poison"] = 1
	elif identity_id == "heroine":
		player["crit"] = 0.10
		player["dash_cd"] = 3.8
	else:
		player["armor"] = 1.0
	alpha19_initialize_run()
	generate_world()
	hero_spawn_timer = 20.0 if mode == "story" else 12.0
	merchant_spawn_timer = float(
		current_chapter().get("merchant_time", 92.0 if mode == "story" else 72.0)
	)
	if mode == "trial":
		relics.append("moonbell")
	else:
		relics.append("yellowwater")
	run_stats = {
		"kills": 0,
		"damage_dealt": 0.0,
		"damage_taken": 0.0,
		"hero_uses": {},
		"relic_triggers": {},
		"arrows_taken": 0,
		"contact_taken": 0,
		"boss_damage": 0.0,
		"start_identity": identity_id
	}
	refresh_all_skins()
	update_bonds()
	chapter_intro_return_screen = "game"
	chapter_intro_page = 0
	screen = "chapter_intro"
	game_message = "WASD／方向鍵移動　Space閃避　E互動　Tab能力總覽　F3診斷"
	game_message_timer = 7.0
	play_bgm("intro")


func apply_character_art_fallbacks() -> void:
	# 部分早期立繪檔實際為其他角色的複本。優先使用本輪由小人重製的角色卡，
	# 並在缺圖時退回同 ID 小人，避免名稱、Boss 與圖像錯位。
	var fallback_ids: Array[String] = [
		"huangzhong", "huatuo", "fazheng", "chengong", "simayi", "caocao",
		"taishici", "luxun", "zhouyu", "sunjian", "xiahouyuan", "xiahouen",
		"zhangfei", "weiyan", "zhanghe", "jiangwei", "zhangliao", "caoren"
	]
	for character_id in fallback_ids:
		var remastered_path: String = "res://assets/portraits_remastered/%s_default.png" % character_id
		if ResourceLoader.exists(remastered_path):
			portrait_tex[str(character_id)] = runtime_texture(remastered_path)
		elif not portrait_tex.has(character_id) and sprite_tex.has(character_id) and sprite_tex[character_id] != null:
			portrait_tex[str(character_id)] = sprite_tex[character_id]


func refresh_all_skins() -> void:
	for hid in skin_defs:
		refresh_skin_asset(hid)


func generate_world() -> void:
	decorations.clear()
	obstacles.clear()
	var chapter: Dictionary = current_chapter()
	var map_kind: String = str(chapter.get("map_kind", "village"))
	var decoration_count: int = 95
	var obstacle_count: int = 13
	if map_kind == "capital":
		decoration_count = 72
		obstacle_count = 17
	elif map_kind == "fortress":
		decoration_count = 58
		obstacle_count = 20
	elif map_kind == "xuzhou":
		decoration_count = 64
		obstacle_count = 18
	elif map_kind == "guandu":
		decoration_count = 52
		obstacle_count = 22
	elif map_kind == "jingzhou":
		decoration_count = 70
		obstacle_count = 18
	elif map_kind == "changban":
		decoration_count = 46
		obstacle_count = 15
	for i in range(decoration_count):
		decorations.append(
			{
				"pos":
				Vector2(
					rng.randf_range(40.0, WORLD.size.x - 40.0),
					rng.randf_range(40.0, WORLD.size.y - 40.0)
				),
				"kind": rng.randi_range(0, 4),
				"size": rng.randf_range(0.7, 1.4)
			}
		)
	var map_shape: String = str(chapter.get("map_shape", "open"))
	for i in range(obstacle_count):
		var pos: Vector2 = shaped_obstacle_position(map_shape, i, obstacle_count)
		if pos.distance_to(Vector2(WORLD.size.x * 0.5, WORLD.size.y * 0.5)) < 280.0:
			pos += Vector2(330.0, 0.0)
		var size: Vector2 = Vector2(rng.randf_range(75.0, 130.0), rng.randf_range(55.0, 95.0))
		if map_kind == "capital":
			size = Vector2(rng.randf_range(88.0, 150.0), rng.randf_range(62.0, 105.0))
		elif map_kind == "fortress":
			size = Vector2(rng.randf_range(105.0, 175.0), rng.randf_range(55.0, 80.0))
		elif map_kind == "xuzhou":
			size = Vector2(rng.randf_range(85.0, 150.0), rng.randf_range(48.0, 88.0))
		elif map_kind == "guandu":
			size = Vector2(rng.randf_range(100.0, 180.0), rng.randf_range(62.0, 110.0))
		elif map_kind == "jingzhou":
			size = Vector2(rng.randf_range(82.0, 145.0), rng.randf_range(48.0, 82.0))
		elif map_kind == "changban":
			size = Vector2(rng.randf_range(70.0, 128.0), rng.randf_range(46.0, 76.0))
		var obstacle_asset: String = themed_obstacle_asset(map_kind, i)
		obstacles.append(
			{"pos": pos, "size": size, "kind": rng.randi_range(0, 2), "asset": obstacle_asset}
		)


func shaped_obstacle_position(shape: String, index: int, total: int) -> Vector2:
	var center: Vector2 = WORLD.size * 0.5
	var pos: Vector2 = Vector2(
		rng.randf_range(180.0, WORLD.size.x - 180.0),
		rng.randf_range(150.0, WORLD.size.y - 150.0)
	)
	match shape:
		"crossroads":
			# 建物退到街道外側，保留中央十字通路。
			if index % 2 == 0:
				pos.y = center.y + (-1.0 if index % 4 == 0 else 1.0) * rng.randf_range(300.0, 560.0)
			else:
				pos.x = center.x + (-1.0 if index % 4 == 1 else 1.0) * rng.randf_range(390.0, 720.0)
		"narrow":
			# 狹道兩側形成關牆，中線保持可通行。
			pos.y = center.y + (-1.0 if index % 2 == 0 else 1.0) * rng.randf_range(300.0, 430.0)
		"courtyard":
			var side: int = index % 4
			if side < 2:
				pos.y = center.y + (-1.0 if side == 0 else 1.0) * rng.randf_range(330.0, 470.0)
			else:
				pos.x = center.x + (-1.0 if side == 2 else 1.0) * rng.randf_range(470.0, 650.0)
		"supply_corridor":
			pos.y = center.y + (-1.0 if index % 2 == 0 else 1.0) * rng.randf_range(250.0, 390.0)
			pos.x = 240.0 + fmod(float(index) * 257.0, WORLD.size.x - 480.0)
		"river_channels":
			# 河岸障礙呈帶狀，中央保留數個渡口。
			pos.y = center.y + (-1.0 if index % 2 == 0 else 1.0) * rng.randf_range(235.0, 355.0)
			pos.x = 220.0 + fmod(float(index) * 233.0, WORLD.size.x - 440.0)
		"long_road":
			pos.y = center.y + (-1.0 if index % 2 == 0 else 1.0) * rng.randf_range(255.0, 370.0)
			pos.x = 220.0 + fmod(float(index) * 271.0, WORLD.size.x - 440.0)
		_:
			pass
	return Vector2(
		clamp(pos.x, 150.0, WORLD.size.x - 150.0),
		clamp(pos.y, 130.0, WORLD.size.y - 130.0)
	)


func themed_obstacle_asset(map_kind: String, index: int) -> String:
	var pools: Dictionary = {
		"village": ["haystack", "cart", "palisade"],
		"capital": ["wall", "cart", "house"],
		"fortress": ["barricade", "tower", "drum"],
		"xuzhou": ["house", "cart", "tent"],
		"guandu": ["grain_cart", "tent", "palisade"],
		"jingzhou": ["house", "cart", "haystack", "palisade"],
		"changban": ["cart", "barricade", "tent", "palisade"]
	}
	var pool: Array = pools.get(map_kind, ["barricade", "cart", "tent"])
	return str(pool[index % pool.size()])


func update_game(delta: float) -> void:
	if player.is_empty():
		return
	elapsed += delta
	screen_shake = max(0.0, screen_shake - delta * 22.0)
	player["invuln"] = max(0.0, float(player["invuln"]) - delta)
	player["flash"] = max(0.0, float(player["flash"]) - delta)
	player["dash_timer"] = max(0.0, float(player["dash_timer"]) - delta)
	player["dash_active"] = max(0.0, float(player["dash_active"]) - delta)
	player["survival_cd"] = max(0.0, float(player["survival_cd"]) - delta)
	player["attack_speed_buff"] = max(0.0, float(player["attack_speed_buff"]) - delta)
	player["kill_speed_buff"] = max(0.0, float(player["kill_speed_buff"]) - delta)
	player["move_slow"] = max(0.0, float(player.get("move_slow", 0.0)) - delta)
	player["control_lock"] = max(0.0, float(player.get("control_lock", 0.0)) - delta)
	player["control_resist"] = max(0.0, float(player.get("control_resist", 0.0)) - delta)
	player["vision_obscure"] = max(0.0, float(player.get("vision_obscure", 0.0)) - delta)
	player["formation_relic_cd"] = max(0.0, float(player.get("formation_relic_cd", 0.0)) - delta)
	temporary_attack_speed = max(0.0, temporary_attack_speed - delta)
	temporary_speed = max(0.0, temporary_speed - delta)
	reserve_roar_cd = max(0.0, reserve_roar_cd - delta)
	boss_counter_window = max(0.0, boss_counter_window - delta)
	boss_break_immunity = max(0.0, boss_break_immunity - delta)
	update_performance_guard(delta)
	if not hero_cast_flash.is_empty():
		hero_cast_flash["life"] = max(0.0, float(hero_cast_flash.get("life", 0.0)) - delta)
		if float(hero_cast_flash["life"]) <= 0.0:
			hero_cast_flash.clear()
	if not player_action_anim.is_empty():
		player_action_anim["life"] = max(0.0, float(player_action_anim.get("life", 0.0)) - delta)
		if float(player_action_anim["life"]) <= 0.0:
			player_action_anim.clear()
	if not boss_action_anim.is_empty():
		boss_action_anim["life"] = max(0.0, float(boss_action_anim.get("life", 0.0)) - delta)
		if float(boss_action_anim["life"]) <= 0.0:
			boss_action_anim.clear()
	if not boss_ability_banner.is_empty():
		boss_ability_banner["life"] = max(0.0, float(boss_ability_banner.get("life", 0.0)) - delta)
		if float(boss_ability_banner["life"]) <= 0.0:
			boss_ability_banner.clear()
	for h in encounter_cooldowns.keys():
		encounter_cooldowns[h] = max(0.0, float(encounter_cooldowns[h]) - delta)

	update_player(delta)
	if flush_pending_run_result():
		return
	update_spawning(delta)
	update_enemies(delta)
	rebuild_enemy_spatial_index()
	if flush_pending_run_result():
		return
	update_player_shots(delta)
	if flush_pending_run_result():
		return
	update_enemy_shots(delta)
	if flush_pending_run_result():
		return
	update_pickups(delta)
	update_zones(delta)
	if flush_pending_run_result():
		return
	update_allies(delta)
	if flush_pending_run_result():
		return
	update_particles(delta)
	update_hero_cooldowns(delta)
	if flush_pending_run_result():
		return
	update_world_events(delta)
	update_alpha35_boss_phase(delta)
	if bool(boss_phase_state.get("transitioning", false)):
		flush_pending_run_result()
		return
	if boss_attack_timeline.is_empty():
		update_boss(delta)
	else:
		update_boss_attack_timeline(delta)
	flush_pending_run_result()


func start_boss_attack_timeline() -> void:
	if boss.is_empty() or player.is_empty():
		return
	boss_attack_timeline = Alpha33BossAttackTimeline.create(
		boss,
		player.get("pos", Vector2.ZERO) as Vector2,
		alpha30_boss_skill_name()
	)
	boss_break_damage = 0.0
	boss_precision_dodge_rewarded = false
	boss_counter_window = 0.0
	boss_counter_was_break = false
	var total_lock: float = float(boss_attack_timeline.get("total", 0.7)) + float(boss_attack_timeline.get("recover", 0.4))
	boss["control_lock"] = max(float(boss.get("control_lock", 0.0)), total_lock)
	boss_action_anim = {
		"kind": "boss_timeline",
		"life": total_lock,
		"max_life": total_lock
	}


func boss_timeline_damage(multiplier: float) -> float:
	var base_damage: float = float(boss.get("damage", 18.0))
	return max(1.0, base_damage * multiplier)


func resolve_boss_timeline_event(event: Dictionary) -> void:
	var event_pos: Vector2 = event.get("pos", boss.get("pos", Vector2.ZERO)) as Vector2
	var event_kind: String = str(event.get("kind", "circle"))
	var radius: float = float(event.get("radius", 120.0))
	var color: Color = Color8(236, 84, 65)
	if event_kind == "sector":
		spawn_ring(event_pos, color, radius, 0.30)
		spawn_sparks(event_pos + (event.get("direction", Vector2.RIGHT) as Vector2) * radius * 0.55, Color8(244, 198, 98), 12)
	else:
		spawn_ring(event_pos, color, radius, 0.34)
		spawn_sparks(event_pos, Color8(244, 198, 98), 10)
	play_sfx("boss_warning", 0.94)
	screen_shake = max(screen_shake, 8.0)
	if Alpha33BossAttackTimeline.event_contains(event, player.get("pos", Vector2.ZERO) as Vector2):
		damage_player(boss_timeline_damage(float(event.get("damage_mult", 1.0))), "boss", 0.10)
	else:
		spawn_ring(player.get("pos", Vector2.ZERO) as Vector2, Color8(110, 196, 142), 30.0, 0.24)
		if float(player.get("dash_active", 0.0)) > 0.0:
			grant_precision_dodge_reward()


func update_boss_attack_timeline(delta: float) -> void:
	if boss_attack_timeline.is_empty():
		return
	if boss.is_empty() or player.is_empty():
		boss_attack_timeline.clear()
		return

	boss_attack_timeline["elapsed"] = float(boss_attack_timeline.get("elapsed", 0.0)) + delta
	var elapsed_time: float = float(boss_attack_timeline["elapsed"])
	var timeline_kind: String = str(boss_attack_timeline.get("kind", "events"))

	if timeline_kind == "charge":
		var total: float = max(0.01, float(boss_attack_timeline.get("total", 0.68)))
		var progress: float = clamp(elapsed_time / total, 0.0, 1.0)
		var eased: float = sin(progress * PI * 0.5)
		var origin: Vector2 = boss_attack_timeline.get("origin", boss.get("pos", Vector2.ZERO)) as Vector2
		var end_pos: Vector2 = boss_attack_timeline.get("end", origin) as Vector2
		boss["pos"] = origin.lerp(end_pos, eased)
		if int(floor(elapsed_time * 24.0)) % 3 == 0:
			spawn_sparks(boss.get("pos", origin) as Vector2, Color8(214, 176, 101), 2)
		if not bool(boss_attack_timeline.get("hit", false)) and Alpha33BossAttackTimeline.charge_contains(
			boss_attack_timeline,
			player.get("pos", Vector2.ZERO) as Vector2
		):
			var boss_pos: Vector2 = boss.get("pos", origin) as Vector2
			var player_pos: Vector2 = player.get("pos", Vector2.ZERO) as Vector2
			if boss_pos.distance_to(player_pos) <= float(boss_attack_timeline.get("width", 82.0)) * 0.72 + float(boss.get("radius", 24.0)):
				boss_attack_timeline["hit"] = true
				damage_player(boss_timeline_damage(1.12), "boss", 0.18)
				screen_shake = max(screen_shake, 10.0)
				spawn_ring(player_pos, Color8(236, 84, 65), 52.0, 0.30)
	else:
		var events: Array = boss_attack_timeline.get("events", []) as Array
		for index in range(events.size()):
			var event: Dictionary = events[index]
			if not bool(event.get("fired", false)) and elapsed_time >= float(event.get("time", 0.0)):
				event["fired"] = true
				events[index] = event
				resolve_boss_timeline_event(event)
		boss_attack_timeline["events"] = events

	if elapsed_time >= float(boss_attack_timeline.get("total", 0.72)):
		var skill_name: String = str(boss_attack_timeline.get("skill_name", "大招"))
		var recovered: float = float(boss_attack_timeline.get("recover", 0.42))
		boss_attack_timeline.clear()
		boss_counter_was_break = false
		boss_counter_window = Alpha34BossCounterWindow.counter_duration(str(boss.get("id", "")), false)
		boss["control_lock"] = max(float(boss.get("control_lock", 0.0)), max(recovered, boss_counter_window))
		boss["telegraph_time"] = 0.0
		boss["telegraph_total"] = 0.0
		show_message("%s收招，弱點暴露！" % skill_name, 1.35)
		spawn_ring(boss.get("pos", Vector2.ZERO) as Vector2, Color8(247, 220, 130), 68.0, 0.42)


func trigger_boss_break() -> void:
	if boss.is_empty() or boss_attack_timeline.is_empty() or boss_break_immunity > 0.0:
		return
	boss_attack_timeline.clear()
	boss_break_damage = 0.0
	boss_break_immunity = Alpha34BossCounterWindow.break_immunity_duration()
	boss_counter_was_break = true
	boss_counter_window = Alpha34BossCounterWindow.counter_duration(str(boss.get("id", "")), true)
	boss["control_lock"] = max(float(boss.get("control_lock", 0.0)), boss_counter_window)
	boss["telegraph_time"] = 0.0
	boss["telegraph_total"] = 0.0
	boss_ability_banner.clear()
	boss_action_anim = {"kind":"boss_break", "life":boss_counter_window, "max_life":boss_counter_window}
	show_message("破招！Boss弱點大開！", 1.65)
	play_sfx("crit", 0.82)
	screen_shake = max(screen_shake, 12.0)
	spawn_ring(boss.get("pos", Vector2.ZERO) as Vector2, Color8(255, 229, 133), 92.0, 0.58)
	spawn_sparks(boss.get("pos", Vector2.ZERO) as Vector2, Color8(255, 238, 168), 18)


func grant_precision_dodge_reward() -> void:
	if boss_precision_dodge_rewarded:
		return
	boss_precision_dodge_rewarded = true
	temporary_speed = max(temporary_speed, 2.0)
	temporary_attack_speed = max(temporary_attack_speed, 2.0)
	for hid in active_heroes:
		hero_cooldowns[hid] = max(0.0, float(hero_cooldowns.get(hid, 0.0)) - 0.8)
	show_message("精準閃避！攻速與移速提升", 1.35)
	play_sfx("dash", 1.08)
	spawn_ring(player.get("pos", Vector2.ZERO) as Vector2, Color8(116, 216, 178), 46.0, 0.34)


func reset_alpha35_boss_phase() -> void:
	boss_phase_state = {
		"boss_id": str(boss.get("id", "")),
		"phase": 1,
		"transitioning": false,
		"timer": 0.0,
		"applied": false
	}


func update_alpha35_boss_phase(delta: float) -> void:
	if boss.is_empty():
		boss_phase_state.clear()
		return
	var boss_id: String = str(boss.get("id", ""))
	if boss_phase_state.is_empty() or str(boss_phase_state.get("boss_id", "")) != boss_id:
		reset_alpha35_boss_phase()
	if bool(boss_phase_state.get("transitioning", false)):
		boss_phase_state["timer"] = max(0.0, float(boss_phase_state.get("timer", 0.0)) - delta)
		if float(boss_phase_state["timer"]) <= 0.0:
			boss_phase_state["transitioning"] = false
			boss_phase_state["phase"] = 2
			boss_phase_state["applied"] = true
			boss["speed"] = float(boss.get("speed", 70.0)) * Alpha35BossPhaseEnrage.enrage_speed_mult(boss_id)
			boss["damage"] = float(boss.get("damage", 16.0)) * Alpha35BossPhaseEnrage.enrage_damage_mult(boss_id)
			boss["special_cd"] = min(float(boss.get("special_cd", 4.0)), 1.4)
			boss["control_lock"] = max(float(boss.get("control_lock", 0.0)), 0.55)
			show_message("%s進入狂暴階段！" % str(boss.get("name", "敵將")), 2.2)
			spawn_ring(boss.get("pos", Vector2.ZERO) as Vector2, Color8(238, 77, 58), 128.0, 0.72)
			play_sfx("boss_intro", 1.08)
			screen_shake = max(screen_shake, 14.0)
		return
	if int(boss_phase_state.get("phase", 1)) >= 2:
		return
	var max_hp: float = max(1.0, float(boss.get("max_hp", boss.get("hp", 1.0))))
	var hp_ratio: float = float(boss.get("hp", max_hp)) / max_hp
	if hp_ratio <= Alpha35BossPhaseEnrage.transition_threshold(boss_id):
		boss_phase_state["transitioning"] = true
		boss_phase_state["timer"] = Alpha35BossPhaseEnrage.transition_duration(boss_id)
		boss_attack_timeline.clear()
		boss["telegraph_time"] = 0.0
		boss["telegraph_total"] = 0.0
		boss["control_lock"] = float(boss_phase_state["timer"])
		show_message("%s：真正的戰鬥現在才開始！" % str(boss.get("name", "敵將")), 2.0)
		spawn_ring(boss.get("pos", Vector2.ZERO) as Vector2, Color8(245, 183, 73), 105.0, 0.55)
		play_sfx("boss_warning", 0.86)


func alpha35_phase_label() -> String:
	if boss_phase_state.is_empty():
		return ""
	return Alpha35BossPhaseEnrage.phase_label(boss_phase_state)


func request_run_result(victory: bool) -> void:
	if pending_run_result != 0 or screen != "game":
		return
	pending_run_result = 1 if victory else -1


func flush_pending_run_result() -> bool:
	if pending_run_result == 0:
		return false
	var result: int = pending_run_result
	pending_run_result = 0
	end_run(result > 0)
	return true


func reserve_limit() -> int:
	var chapter_number: int = chapter_manager.current_index_value() + 1
	if chapter_number >= 9:
		return 5
	if chapter_number >= 5:
		return 4
	return 3


func active_limit() -> int:
	if (
		hero_config_origin == "intermission"
		and screen in ["hero_config", "config_replace"]
		and chapter_manager.has_next_chapter()
	):
		return int(
			chapter_manager.next_chapter().get("active_limit", chapter_manager.active_limit())
		)
	return chapter_manager.active_limit()


func boss_time() -> float:
	return chapter_manager.boss_time()


func current_chapter() -> Dictionary:
	return chapter_manager.current()


func difficulty_id() -> String:
	return str(save_data["settings"].get("difficulty", "story"))


func difficulty_name() -> String:
	match difficulty_id():
		"easy":
			return "義勇"
		"hard":
			return "亂世"
	return "史傳"


func difficulty_enemy_mult() -> float:
	match difficulty_id():
		"easy":
			return 0.88
		"hard":
			return 1.14
	return 1.0


func difficulty_incoming_mult() -> float:
	match difficulty_id():
		"easy":
			return 0.80
		"hard":
			return 1.15
	return 1.0


func difficulty_reward_mult() -> float:
	match difficulty_id():
		"easy":
			return 1.12
		"hard":
			return 1.06
	return 1.0


func effect_density() -> float:
	return clamp(float(save_data["settings"].get("effects", 0.82)), 0.35, 1.0)


func chapter_difficulty() -> float:
	return chapter_manager.difficulty() * difficulty_enemy_mult()


func fast_remove_at(values: Array, index: int) -> Variant:
	if index < 0 or index >= values.size():
		return null
	var removed: Variant = values[index]
	var last: int = values.size() - 1
	if index != last:
		values[index] = values[last]
	values.pop_back()
	return removed


func enemy_cell(pos: Vector2) -> Vector2i:
	return Vector2i(floori(pos.x / ENEMY_GRID_SIZE), floori(pos.y / ENEMY_GRID_SIZE))


func rebuild_enemy_spatial_index() -> void:
	enemy_spatial_grid.clear()
	enemy_uid_index.clear()
	for i in range(enemies.size()):
		var enemy: Dictionary = enemies[i]
		var uid: int = int(enemy.get("uid", -1))
		enemy_uid_index[uid] = i
		var cell: Vector2i = enemy_cell(enemy["pos"])
		if not enemy_spatial_grid.has(cell):
			enemy_spatial_grid[cell] = []
		(enemy_spatial_grid[cell] as Array).append(uid)


func nearby_enemy_uids(pos: Vector2) -> Array:
	var result: Array = []
	var center_cell: Vector2i = enemy_cell(pos)
	for y in range(-1, 2):
		for x in range(-1, 2):
			var cell: Vector2i = center_cell + Vector2i(x, y)
			if enemy_spatial_grid.has(cell):
				result.append_array(enemy_spatial_grid[cell] as Array)
	return result


func terrain_effect_at(world_pos: Vector2) -> Dictionary:
	# V2.0 alpha.2：資料化的互動地形判定。只依章節與世界座標計算，不消耗 RNG。
	var chapter: Dictionary = current_chapter()
	var shape: String = str(chapter.get("map_shape", "open"))
	var map_kind: String = str(chapter.get("map_kind", "village"))
	var center: Vector2 = WORLD.size * 0.5
	var effect: Dictionary = {"kind": "ground", "speed_mult": 1.0, "danger": false}
	if shape == "river_channels":
		for band in [-1.0, 1.0]:
			if abs(world_pos.y - (center.y + band * 260.0)) <= 54.0:
				effect = {"kind": "shallow_water", "speed_mult": 0.72, "danger": false}
	elif map_kind in ["village", "guandu", "jingzhou"]:
		var cell := Vector2i(int(floor(world_pos.x / 128.0)), int(floor(world_pos.y / 128.0)))
		var code: int = abs(cell.x * 92821 + cell.y * 68917 + int(str(chapter.get("id", "")).hash()))
		if code % 5 == 0:
			effect = {"kind": "field", "speed_mult": 0.88, "danger": false}
	if str(chapter.get("id", "")) in ["luoyang", "redcliffs", "yiling"]:
		var fire_code: int = abs(int(world_pos.x / 180.0) * 317 + int(world_pos.y / 180.0) * 911)
		if fire_code % 17 == 0 and world_pos.distance_to(center) > 240.0:
			effect = {"kind": "embers", "speed_mult": 0.92, "danger": true}
	return effect


func terrain_speed_multiplier(world_pos: Vector2) -> float:
	if float(player.get("dash_active", 0.0)) > 0.0:
		return 1.0
	return float(terrain_effect_at(world_pos).get("speed_mult", 1.0))


func update_player(delta: float) -> void:
	var move: Vector2 = Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		move.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		move.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		move.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		move.y += 1.0
	move = move.normalized()
	if float(player.get("control_lock", 0.0)) > 0.0 and float(player.get("dash_active", 0.0)) <= 0.0:
		move = Vector2.ZERO
	if move.length_squared() > 0.01 and float(player["dash_active"]) <= 0.0:
		player["facing"] = move
	var speed: float = float(player["speed"]) * equipment_effect("speed_mult", 1.0) * (1.0 + relic_stat("speed_bonus"))
	speed *= terrain_speed_multiplier(player["pos"])
	if float(player.get("move_slow", 0.0)) > 0.0 and float(player.get("dash_active", 0.0)) <= 0.0:
		speed *= 0.68
	if float(player["kill_speed_buff"]) > 0.0:
		speed *= 1.16
	if temporary_speed > 0.0:
		speed *= 1.12
	if has_relic("dilu"):
		speed *= 1.0 + 0.06 * relic_level("dilu")
	if float(player["dash_active"]) > 0.0:
		move = player["dash_dir"]
		speed *= 3.6
		if has_relic("redhare") and rng.randf() < delta * 16.0:
			zones.append(
				{
					"kind": "fire",
					"pos": player["pos"],
					"r": 28.0,
					"life": 1.5,
					"tick": 0.0,
					"damage": player["damage"] * 0.32
				}
			)
	var next_pos: Vector2 = player["pos"] + move * speed * delta
	next_pos.x = clamp(next_pos.x, 28.0, WORLD.size.x - 28.0)
	next_pos.y = clamp(next_pos.y, 28.0, WORLD.size.y - 28.0)
	player["pos"] = next_pos
	resolve_player_obstacles()
	player["attack_timer"] = float(player["attack_timer"]) - delta
	if player["attack_timer"] <= 0.0 and combat_target_available():
		perform_auto_attack()
		var interval: float = float(player["attack_interval"]) / equipment_effect("attack_speed_mult", 1.0)
		interval /= build_attack_speed_multiplier()
		interval /= 1.0 + relic_stat("attack_speed_bonus")
		interval /= 1.0 + skill_level("attack_speed") * 0.12
		if has_relic("crossbow"):
			interval /= 1.0 + 0.12 * relic_level("crossbow")
		if float(player["attack_speed_buff"]) > 0.0 or temporary_attack_speed > 0.0:
			interval /= 1.25
		player["attack_timer"] = max(0.18, interval)


func resolve_player_obstacles() -> void:
	var pos: Vector2 = player["pos"]
	for ob in obstacles:
		var r: Rect2 = Rect2(ob["pos"] - ob["size"] * 0.5, ob["size"])
		if r.grow(14.0).has_point(pos):
			var c: Vector2 = ob["pos"]
			var diff: Vector2 = pos - c
			if (
				abs(diff.x / max(1.0, float(ob["size"].x)))
				> abs(diff.y / max(1.0, float(ob["size"].y)))
			):
				pos.x = c.x + sign(diff.x) * (float(ob["size"].x) * 0.5 + 15.0)
			else:
				pos.y = c.y + sign(diff.y) * (float(ob["size"].y) * 0.5 + 15.0)
	player["pos"] = pos


func try_dash() -> void:
	if player.is_empty() or float(player["dash_timer"]) > 0.0:
		play_sfx("ui_move", 0.72)
		return
	var move: Vector2 = Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		move.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		move.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		move.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		move.y += 1.0
	if move.length() < 0.1:
		move = player.get("facing", Vector2.RIGHT)
	player["dash_dir"] = move.normalized()
	player["dash_active"] = 0.20
	player["invuln"] = max(float(player["invuln"]), 0.42)
	var cd: float = float(player["dash_cd"]) * pow(0.88, skill_level("dash"))
	if has_relic("dilu"):
		cd *= max(0.68, 1.0 - 0.12 * relic_level("dilu"))
	player["dash_timer"] = max(0.72, cd)
	play_sfx("dash")
	spawn_ring(player["pos"], Color8(196, 221, 224), 25.0, 0.28)
	if not boss.is_empty() and str(boss.get("id", "")) == "lvbu" and chapter_manager.boss_is_active() and float(boss.get("dodge_cd", 0.0)) <= 0.0 and player["pos"].distance_to(boss["pos"]) < 560.0:
		var to_player: Vector2 = (player["pos"] - boss["pos"]).normalized()
		var side_sign: float = -1.0 if rng.randf() < 0.5 else 1.0
		boss["sidestep_dir"] = to_player.rotated(side_sign * PI * 0.5)
		boss["sidestep_time"] = 0.27
		boss["dodge_cd"] = 3.5

func perform_auto_attack() -> void:
	if not PlayerCombatService.perform_auto_attack(self, chosen_identity, Callable(self, "perform_auto_attack_legacy")):
		perform_auto_attack_legacy()


func perform_auto_attack_legacy() -> void:
	var target: Vector2 = nearest_enemy_position(player["pos"])
	if target.x > 1.0e19:
		return
	var dir: Vector2 = (target - player["pos"]).normalized()
	player["facing"] = dir
	var weapon_kind: String = str(player["weapon"])
	var action_profile: Dictionary = Alpha27ActionProfiles.player_profile(weapon_kind)
	var action_duration: float = float(action_profile.get("duration", 0.46))
	player_action_anim = {
		"kind": weapon_kind,
		"life": action_duration,
		"max_life": action_duration,
		"angle": dir.angle(),
		"windup": float(action_profile.get("windup", 0.25)),
		"active": float(action_profile.get("active", 0.40)),
		"recover": float(action_profile.get("recover", 0.35))
	}
	var dmg: float = float(player["damage"]) * float(player.get("alpha19_damage_mult", 1.0)) * float(player.get("alpha20_damage_mult", 1.0)) * alpha21_identity_damage_multiplier() * (1.0 + skill_level("damage") * 0.15) * (1.0 + relic_stat("damage_bonus"))
	match weapon_kind:
		"blade":
			play_combat_motif("slash", rng.randf_range(0.92, 1.02))
			var attack_origin: Vector2 = player["pos"] + dir * 34.0
			damage_arc(attack_origin, dir.angle(), 122.0, 1.52, dmg * 1.12, 58.0)
			zones.append(
				{
					"kind": "slash_visual",
					"pos": attack_origin + dir * 14.0,
					"angle": dir.angle(),
					"r": 122.0,
					"life": 0.34,
					"max_life": 0.34,
					"color": Color8(255, 224, 132)
				}
			)
			spawn_ring(attack_origin + dir * 24.0, Color8(255, 226, 145), 46.0, 0.24)
		"bow":
			play_combat_motif("arrow", rng.randf_range(0.94, 1.02))
			var count: int = 1 + int(player["multishot"])
			for i in range(count):
				var spread: float = (float(i) - (count - 1) * 0.5) * 0.12
				spawn_player_projectile(
					"arrow",
					dir.rotated(spread),
					dmg * 1.22,
					510.0,
					1.7,
					7.0,
					int(player["pierce"]) + 1,
					0.0
				)
		"poison":
			play_combat_motif("poison", rng.randf_range(0.90, 0.98))
			var count: int = 1 + int(player["multishot"])
			for i in range(count):
				var spread: float = (float(i) - (count - 1) * 0.5) * 0.15
				spawn_player_projectile(
					"needle",
					dir.rotated(spread),
					dmg * 0.78,
					470.0,
					1.55,
					6.0,
					int(player["pierce"]),
					1.0 + skill_level("poison") * 0.25
				)
			player["toxicity"] = min(100.0, float(player["toxicity"]) + 0.8)
		"rings":
			play_combat_motif("slash", rng.randf_range(1.02, 1.10))
			var count: int = 2 + int(player["multishot"])
			for i in range(count):
				var spread: float = (float(i) - (count - 1) * 0.5) * 0.19
				spawn_player_projectile(
					"ring",
					dir.rotated(spread),
					dmg * 0.82,
					430.0,
					1.45,
					11.0,
					int(player["pierce"]) + 1,
					0.0
				)


func spawn_player_projectile(
	kind: String,
	dir: Vector2,
	damage: float,
	speed: float,
	life: float,
	radius: float,
	pierce: int,
	poison: float
) -> void:
	var real_damage: float = damage
	if (
		kind
		in [
			"arrow",
			"needle",
			"ring",
			"hero_arrow",
			"fire_arrow",
			"glaive",
			"blade_wave",
			"return_blade",
			"wind_blade"
		]
	):
		real_damage *= float(player.get("projectile_mult", 1.0))
	if has_relic("crossbow"):
		real_damage *= 0.97
	var real_pierce: int = pierce
	if has_relic("arrowhead"):
		real_pierce += 1
	player_shots.append(
		{
			"kind": kind,
			"pos": player["pos"],
			"vel": dir.normalized() * speed,
			"damage": real_damage,
			"life": life,
			"radius": radius * (1.0 + skill_level("projectile") * 0.04),
			"pierce": real_pierce,
			"poison": poison,
			"hit_ids": [],
			"angle": dir.angle()
		}
	)


func combat_target_available() -> bool:
	return not enemies.is_empty() or (not boss.is_empty() and float(boss.get("hp", 0.0)) > 0.0)


func nearest_enemy_position(from: Vector2) -> Vector2:
	var best: Vector2 = Vector2(1.0e20, 1.0e20)
	var dist: float = INF
	var candidate_uids: Array = nearby_enemy_uids(from)
	if candidate_uids.is_empty():
		for enemy_value in enemies:
			var fallback_enemy: Dictionary = enemy_value as Dictionary
			var fallback_distance: float = from.distance_squared_to(fallback_enemy["pos"])
			if fallback_distance < dist:
				dist = fallback_distance
				best = fallback_enemy["pos"]
	else:
		for uid_value in candidate_uids:
			var uid: int = int(uid_value)
			var index: int = int(enemy_uid_index.get(uid, -1))
			if index < 0 or index >= enemies.size():
				continue
			var enemy: Dictionary = enemies[index]
			var distance: float = from.distance_squared_to(enemy["pos"])
			if distance < dist:
				dist = distance
				best = enemy["pos"]
	if not boss.is_empty() and float(boss.get("hp", 0.0)) > 0.0:
		var boss_distance: float = from.distance_squared_to(boss["pos"])
		if boss_distance < dist:
			best = boss["pos"]
	return best


func update_spawning(delta: float) -> void:
	var chapter: Dictionary = current_chapter()
	var max_enemies: int = (
		int(chapter.get("max_enemies", 42)) + int(history_modifiers.get("max_enemies_delta", 0))
	)
	if chosen_mode == "trial":
		max_enemies = 54
	max_enemies = max(22, max_enemies - performance_level * 8)
	if boss_spawned and not boss.is_empty():
		max_enemies = min(max_enemies, 30)
	spawn_timer -= delta
	if spawn_timer > 0.0:
		return
	if enemies.size() >= max_enemies:
		spawn_timer = 0.45
		return
	var intensity: float = clamp(elapsed / boss_time(), 0.0, 1.0)
	var batch: int = 1
	if elapsed > 68.0:
		batch += 1
	if elapsed > 150.0 and rng.randf() < 0.38:
		batch += 1
	for i in range(batch):
		if enemies.size() < max_enemies:
			spawn_enemy(select_enemy_type(intensity), random_spawn_position())
	var base: float = (1.12 - intensity * 0.43) / max(1.0, chapter_difficulty() * 0.90)
	base *= float(history_modifiers.get("spawn_interval_mult", 1.0))
	if elapsed < 55.0:
		base += 0.38
	spawn_timer = max(0.42, base)


func select_enemy_type(intensity: float) -> String:
	var chapter: Dictionary = current_chapter()
	var weights: Dictionary = chapter.get(
		"enemy_weights", {"peasant": 0.28, "sword": 0.50, "archer": 0.15, "elite": 0.07}
	)
	if elapsed < 38.0:
		return "peasant" if rng.randf() < 0.68 else "sword"
	var archer_count: int = 0
	for enemy_value in enemies:
		var enemy: Dictionary = enemy_value
		if str(enemy.get("kind", "")) == "archer":
			archer_count += 1
	var available: Dictionary = weights.duplicate()
	if archer_count >= int(chapter.get("archer_cap", 4)):
		available["archer"] = 0.0
	if elapsed < float(chapter.get("elite_start", 80.0)):
		available["elite"] = 0.0
	available["elite"] = float(available.get("elite", 0.0)) * (0.55 + intensity * 0.75)
	# 法術兵從第三章才開始出現；前兩章保留基礎兵種學習曲線。
	var chapter_index: int = int(chapter.get("index", 0))
	if chapter_index >= 2:
		var caster_scale: float = clamp(0.035 + float(chapter_index - 2) * 0.012 + intensity * 0.025, 0.035, 0.12)
		available["caster_slow"] = caster_scale
		if chapter_index >= 3:
			available["caster_bind"] = caster_scale * 0.72
		if chapter_index >= 4:
			available["caster_smoke"] = caster_scale * 0.62
	var order: Array[String] = ["peasant", "sword", "archer", "elite", "cavalry", "shield", "crossbow", "drummer", "firepot", "assassin", "spearman", "tactician", "caster_slow", "caster_bind", "caster_smoke"]
	var total: float = 0.0
	for kind in order:
		total += max(0.0, float(available.get(kind, 0.0)))
	if total <= 0.0:
		return "sword"
	var roll: float = rng.randf() * total
	var cumulative: float = 0.0
	for kind in order:
		cumulative += max(0.0, float(available.get(kind, 0.0)))
		if roll <= cumulative:
			return kind
	return "sword"


func random_spawn_position() -> Vector2:
	var shape: String = str(current_chapter().get("map_shape", "open"))
	var radius: float = rng.randf_range(650.0, 880.0)
	var pos: Vector2 = player["pos"]
	match shape:
		"crossroads":
			# 洛陽十字街：敵軍主要沿水平／垂直街道壓入。
			if rng.randf() < 0.5:
				pos += Vector2(radius * (-1.0 if rng.randf() < 0.5 else 1.0), rng.randf_range(-145.0, 145.0))
			else:
				pos += Vector2(rng.randf_range(-145.0, 145.0), radius * (-1.0 if rng.randf() < 0.5 else 1.0))
		"narrow":
			# 虎牢狹道：以前後兩端為主，減少四面包圍。
			pos += Vector2(radius * (-1.0 if rng.randf() < 0.5 else 1.0), rng.randf_range(-210.0, 210.0))
		"courtyard":
			# 徐州庭院：由四個門角與側門進場。
			var corner: Vector2 = [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)][rng.randi_range(0, 3)]
			pos += Vector2(corner.x * radius * 0.78, corner.y * radius * 0.62)
		"supply_corridor":
			# 官渡補給線：沿東西向長廊推進。
			pos += Vector2(radius * (-1.0 if rng.randf() < 0.5 else 1.0), rng.randf_range(-260.0, 260.0))
		"river_channels":
			# 荊州水道：以南北岸與支流缺口進場。
			if rng.randf() < 0.62:
				pos += Vector2(rng.randf_range(-330.0, 330.0), radius * (-1.0 if rng.randf() < 0.5 else 1.0))
			else:
				pos += Vector2(radius * (-1.0 if rng.randf() < 0.5 else 1.0), rng.randf_range(-120.0, 120.0))
		"long_road":
			# 長坂追兵：大多由道路後方與前方少量截擊。
			var side: float = -1.0 if rng.randf() < 0.72 else 1.0
			pos += Vector2(side * radius, rng.randf_range(-175.0, 175.0))
		_:
			pos += Vector2.from_angle(rng.randf_range(0.0, TAU)) * radius
	pos.x = clamp(pos.x, 25.0, WORLD.size.x - 25.0)
	pos.y = clamp(pos.y, 25.0, WORLD.size.y - 25.0)
	return pos


func spawn_enemy(kind: String, pos: Vector2) -> void:
	var scale: float = (
		(1.0 + elapsed / boss_time() * (0.42 if chosen_mode == "story" else 0.52))
		* chapter_difficulty()
	)
	var data: Dictionary = {}
	match kind:
		"peasant":
			data = {
				"hp": 34.0, "speed": 60.0, "damage": 7.0, "radius": 15.0, "sprite": "enemy_peasant"
			}
		"sword":
			data = {
				"hp": 58.0, "speed": 75.0, "damage": 9.0, "radius": 16.0, "sprite": "enemy_sword"
			}
		"archer":
			data = {
				"hp": 43.0, "speed": 47.0, "damage": 7.0, "radius": 15.0, "sprite": "enemy_archer"
			}
		"elite":
			data = {
				"hp": 245.0,
				"speed": 65.0,
				"damage": 18.0,
				"radius": 23.0,
				"sprite": "enemy_elite",
				"armor": 1.5,
				"elite_name": "黃巾渠帥"
			}
		"cavalry":
			data = {
				"hp": 108.0,
				"speed": 112.0,
				"damage": 12.0,
				"radius": 19.0,
				"sprite": "enemy_cavalry",
				"armor": 0.0
			}
		"shield":
			data = {
				"hp": 155.0,
				"speed": 48.0,
				"damage": 10.0,
				"radius": 21.0,
				"sprite": "enemy_shield",
				"armor": 3.0
			}

		"crossbow":
			data = {"hp": 68.0, "speed": 42.0, "damage": 15.0, "radius": 16.0, "sprite": "enemy_crossbow"}
		"drummer":
			data = {"hp": 92.0, "speed": 48.0, "damage": 7.0, "radius": 18.0, "sprite": "enemy_drummer", "armor": 1.0}
		"firepot":
			data = {"hp": 76.0, "speed": 50.0, "damage": 12.0, "radius": 17.0, "sprite": "enemy_firepot"}
		"assassin":
			data = {"hp": 62.0, "speed": 118.0, "damage": 13.0, "radius": 15.0, "sprite": "enemy_assassin"}
		"spearman":
			data = {"hp": 105.0, "speed": 67.0, "damage": 15.0, "radius": 18.0, "sprite": "enemy_spearman", "armor": 1.0}
		"tactician":
			data = {"hp": 104.0, "speed": 47.0, "damage": 16.0, "radius": 18.0, "sprite": "enemy_tactician", "armor": 1.0, "elite_name": "軍陣參謀"}
		"caster_slow":
			data = {"hp": 72.0, "speed": 43.0, "damage": 13.0, "radius": 17.0, "sprite": "enemy_tactician", "armor": 0.0, "elite_name": "寒霧術士"}
		"caster_bind":
			data = {"hp": 78.0, "speed": 42.0, "damage": 15.0, "radius": 17.0, "sprite": "enemy_tactician", "armor": 0.5, "elite_name": "雷咒方士"}
		"caster_smoke":
			data = {"hp": 82.0, "speed": 41.0, "damage": 14.0, "radius": 18.0, "sprite": "enemy_firepot", "armor": 0.5, "elite_name": "妖煙祭酒"}
	var uid: int = rng.randi()
	enemies.append(
		{
			"uid": uid,
			"kind": kind,
			"pos": pos,
			"hp": float(data["hp"]) * scale * float(history_modifiers.get("enemy_hp_mult", 1.0)),
			"max_hp":
			float(data["hp"]) * scale * float(history_modifiers.get("enemy_hp_mult", 1.0)),
			"speed":
			(
				float(data["speed"])
				* (1.0 + elapsed / boss_time() * 0.08)
				* lerp(1.0, chapter_difficulty(), 0.28)
			),
			"damage":
			(
				float(data["damage"])
				* lerp(1.0, chapter_difficulty(), 0.45)
				* float(history_modifiers.get("enemy_damage_mult", 1.0))
			),
			"radius": float(data["radius"]),
			"sprite": data["sprite"],
			"anim": rng.randf_range(0.0, 1.0),
			"contact_cd": 0.0,
			"shoot_cd": rng.randf_range(1.6, 3.0),
			"ability_cd": rng.randf_range(2.6, 4.4),
			"telegraph": 0.0,
			"poison": 0.0,
			"poison_time": 0.0,
			"poison_tick": 0.0,
			"burn": 0.0,
			"burn_time": 0.0,
			"burn_tick": 0.0,
			"burn_stacks": 0,
			"slow": 0.0,
			"stun": 0.0,
			"confuse": 0.0,
			"charm": 0.0,
			"marked": 0.0,
			"armor_break": 0.0,
			"status_effects": {},
			"knock": Vector2.ZERO,
			"elite": kind in ["elite", "shield", "drummer", "tactician"],
			"elite_name": str(data.get("elite_name", "精英敵將")),
			"armor": float(data.get("armor", 0.0)),
			"last_hit": "",
			"ai_phase": abs(uid) % 4
		}
	)


func enemy_index_by_uid(uid: int) -> int:
	for i in range(enemies.size()):
		if int(enemies[i].get("uid", -1)) == uid:
			return i
	return -1


func update_enemies(delta: float) -> void:
	# 遠距敵兵採分幀更新；近戰、預警、異常狀態仍維持逐幀反應。
	var processed: Dictionary = {}
	var cursor: int = enemies.size() - 1
	while cursor >= 0:
		if cursor >= enemies.size():
			cursor = enemies.size() - 1
			continue
		var e: Dictionary = enemies[cursor]
		var uid: int = int(e.get("uid", -1))
		if processed.has(uid):
			cursor -= 1
			continue
		processed[uid] = true
		e["anim"] = float(e["anim"]) + delta * 7.0
		e["contact_cd"] = max(0.0, float(e["contact_cd"]) - delta)
		e["shoot_cd"] = max(0.0, float(e["shoot_cd"]) - delta)
		e["ability_cd"] = max(0.0, float(e.get("ability_cd", 0.0)) - delta)
		e["telegraph"] = max(0.0, float(e["telegraph"]) - delta)
		e["marked"] = max(0.0, float(e["marked"]) - delta)
		var status_index: int = StatusEffectService.tick_enemy(self, cursor, delta)
		if status_index < 0:
			cursor -= 1
			continue
		cursor = status_index
		var relic_status_index: int = RelicStatusSynergyService.tick_enemy(self, cursor, delta)
		if relic_status_index < 0:
			cursor -= 1
			continue
		cursor = relic_status_index
		e = enemies[cursor]
		if float(e["hp"]) <= 0.0:
			kill_enemy(cursor)
			cursor -= 1
			continue

		var distance_sq: float = e["pos"].distance_squared_to(player["pos"])
		var stride: int = 1
		if distance_sq > 940.0 * 940.0:
			stride = 3
		elif distance_sq > 620.0 * 620.0:
			stride = 2
		if str(e["kind"]) in ["archer", "crossbow", "firepot", "assassin", "drummer", "spearman", "tactician", "caster_slow", "caster_bind", "caster_smoke"] and (float(e["telegraph"]) > 0.0 or distance_sq < 600.0 * 600.0):
			stride = 1
		if float(e["charm"]) > 0.0 or float(e["stun"]) > 0.0:
			stride = 1
		if performance_level >= 2 and distance_sq > 720.0 * 720.0:
			stride = max(stride, 4)
		var phase: int = int(e.get("ai_phase", 0))
		var run_ai: bool = ((frame_serial + phase) % stride) == 0
		if run_ai and float(e["stun"]) <= 0.0:
			var step_delta: float = delta * float(stride)
			var target_pos: Vector2 = player["pos"]
			if float(e["charm"]) > 0.0:
				target_pos = nearest_other_enemy_pos(cursor)
			var dir: Vector2 = (target_pos - e["pos"]).normalized()
			var speed: float = float(e["speed"])
			if e["kind"] == "cavalry" and distance_sq < 330.0 * 330.0:
				speed *= 1.22
			if float(e["slow"]) > 0.0:
				speed *= 0.55
			if e["kind"] in ["caster_slow", "caster_bind", "caster_smoke"]:
				speed *= 0.82
			if e["kind"] == "drummer" and float(e.get("ability_cd", 0.0)) <= 0.0:
				e["ability_cd"] = 4.4
				for other_index in range(enemies.size()):
					if other_index != cursor and enemies[other_index]["pos"].distance_squared_to(e["pos"]) < 230.0 * 230.0:
						enemies[other_index]["speed"] = min(float(enemies[other_index]["speed"]) * 1.06, 185.0)
				spawn_ring(e["pos"], Color8(217, 160, 71), 120.0, 0.42)
			if e["kind"] == "assassin" and distance_sq < 310.0 * 310.0 and float(e.get("ability_cd", 0.0)) <= 0.0:
				e["ability_cd"] = 3.2
				e["knock"] += dir * 620.0
			if e["kind"] == "firepot" and float(e.get("ability_cd", 0.0)) <= 0.0 and distance_sq < 520.0 * 520.0:
				e["ability_cd"] = 4.8
				zones.append({"kind":"enemy_warning", "pos":player["pos"] + Vector2.from_angle(rng.randf_range(0.0, TAU))*45.0, "r":74.0, "life":0.92, "damage":float(e["damage"]), "color":Color8(234, 119, 52)})
			# 精英怪具備局部壓迫技能，但強度仍低於章末 Boss。
			if bool(e.get("elite", false)) and e["kind"] == "elite" and float(e.get("ability_cd", 0.0)) <= 0.0 and distance_sq < 260.0 * 260.0:
				e["ability_cd"] = 6.2
				zones.append({"kind":"enemy_warning", "pos":e["pos"] + dir * 52.0, "r":62.0, "life":0.72, "damage":float(e["damage"]) * 1.45, "shield_pierce":0.08, "color":Color8(224, 158, 62)})
				spawn_ring(e["pos"], Color8(226, 170, 72), 78.0, 0.35)
			if e["kind"] in ["caster_slow", "caster_bind", "caster_smoke"]:
				var caster_dist: float = sqrt(distance_sq)
				if caster_dist < 165.0:
					dir = -dir
				elif caster_dist > 455.0:
					dir = dir
				else:
					dir = Vector2(-dir.y, dir.x) * (1.0 if int(e.get("ai_phase", 0)) % 2 == 0 else -1.0)
				if float(e.get("ability_cd", 0.0)) <= 0.0 and caster_dist < 560.0:
					var control_kind: String = "slow" if e["kind"] == "caster_slow" else ("bind" if e["kind"] == "caster_bind" else "smoke")
					var cast_color: Color = Color8(104, 177, 218) if control_kind == "slow" else (Color8(225, 202, 76) if control_kind == "bind" else Color8(126, 91, 153))
					e["ability_cd"] = 5.4 if control_kind == "slow" else (6.8 if control_kind == "bind" else 7.5)
					e["telegraph"] = 0.85
					zones.append({"kind":"enemy_control_warning", "control":control_kind, "pos":player["pos"] + Vector2.from_angle(rng.randf_range(0.0, TAU)) * 24.0, "r":68.0 if control_kind != "smoke" else 92.0, "life":0.95, "max_life":0.95, "damage":float(e["damage"]) * (0.72 if control_kind == "slow" else 0.82), "shield_pierce":0.18 if control_kind != "smoke" else 0.24, "color":cast_color})
					spawn_ring(e["pos"], cast_color, 55.0, 0.40)
			if e["kind"] == "spearman":
				var spear_dist: float = sqrt(distance_sq)
				if spear_dist < 82.0:
					dir = -dir
				elif spear_dist < 132.0:
					dir = Vector2.ZERO
				if float(e.get("ability_cd", 0.0)) <= 0.0 and spear_dist < 180.0:
					e["ability_cd"] = 2.7
					zones.append({"kind":"enemy_warning", "pos":e["pos"] + (player["pos"] - e["pos"]).normalized() * 76.0, "r":46.0, "life":0.56, "damage":float(e["damage"]) * 1.18, "color":Color8(184, 198, 213)})
			if e["kind"] == "tactician" and float(e.get("ability_cd", 0.0)) <= 0.0 and distance_sq < 620.0 * 620.0:
				e["ability_cd"] = 5.0
				for other_index in range(enemies.size()):
					if other_index != cursor and enemies[other_index]["pos"].distance_squared_to(e["pos"]) < 250.0 * 250.0:
						enemies[other_index]["armor"] = min(5.0, float(enemies[other_index].get("armor", 0.0)) + 0.35)
				zones.append({"kind":"enemy_warning", "pos":player["pos"] + Vector2.from_angle(rng.randf_range(0.0, TAU)) * 30.0, "r":86.0, "life":1.05, "damage":float(e["damage"]) * 1.05, "color":Color8(116, 153, 190)})
				spawn_ring(e["pos"], Color8(112, 153, 190), 130.0, 0.48)
			if e["kind"] in ["archer", "crossbow"] and float(e["charm"]) <= 0.0:
				var dist: float = sqrt(distance_sq)
				if dist < 270.0:
					dir = -dir
				elif dist < 390.0:
					dir = Vector2.ZERO
				if float(e["shoot_cd"]) <= 0.0 and float(e["telegraph"]) <= 0.0:
					e["telegraph"] = 0.75 if e["kind"] == "crossbow" else 0.52
					e["shoot_cd"] = (4.0 if e["kind"] == "crossbow" else 3.25) if chosen_mode == "story" else 2.65
				elif float(e["telegraph"]) > 0.0 and float(e["telegraph"]) < 0.08:
					shoot_enemy_arrow(e)
					e["telegraph"] = 0.0
			e["pos"] += dir * speed * step_delta + e["knock"] * step_delta
			e["knock"] = e["knock"].move_toward(Vector2.ZERO, 720.0 * step_delta)
			resolve_enemy_obstacles(e)
		if float(e["charm"]) > 0.0 and run_ai:
			charmed_enemy_collision(uid, e)
		else:
			var hit_dist: float = float(e["radius"]) + 15.0
			if distance_sq < hit_dist * hit_dist and float(e["contact_cd"]) <= 0.0:
				e["contact_cd"] = 0.82
				damage_player(float(e["damage"]), "contact")
		var final_index: int = cursor
		if final_index >= enemies.size() or int(enemies[final_index].get("uid", -1)) != uid:
			final_index = enemy_index_by_uid(uid)
		if final_index >= 0:
			enemies[final_index] = e
		cursor = min(cursor - 1, enemies.size() - 1)


func nearest_other_enemy_pos(index: int) -> Vector2:
	var from: Vector2 = enemies[index]["pos"]
	var best: Vector2 = player["pos"]
	var bd: float = INF
	for j in range(enemies.size()):
		if j == index:
			continue
		var d: float = from.distance_squared_to(enemies[j]["pos"])
		if d < bd:
			bd = d
			best = enemies[j]["pos"]
	return best


func charmed_enemy_collision(source_uid: int, e: Dictionary) -> void:
	var source_index: int = enemy_index_by_uid(source_uid)
	if source_index < 0:
		return
	for target_index in range(enemies.size() - 1, -1, -1):
		if target_index == source_index:
			continue
		if (
			e["pos"].distance_to(enemies[target_index]["pos"])
			< float(e["radius"]) + float(enemies[target_index]["radius"])
		):
			damage_enemy(target_index, float(e["damage"]) * 1.2, "charm", false)
			e["charm"] = 0.0
			break


func resolve_enemy_obstacles(e: Dictionary) -> void:
	for ob in obstacles:
		var r: Rect2 = Rect2(ob["pos"] - ob["size"] * 0.5, ob["size"])
		if r.grow(float(e["radius"]) * 0.5).has_point(e["pos"]):
			var diff: Vector2 = e["pos"] - ob["pos"]
			e["pos"] += diff.normalized() * 18.0


func shoot_enemy_arrow(e: Dictionary) -> void:
	var limit: int = (
		(12 if chosen_mode == "story" else 24)
		+ int(history_modifiers.get("enemy_arrow_cap_delta", 0))
	)
	limit = max(5, limit)
	if enemy_shots.size() >= limit:
		return
	var dir: Vector2 = (player["pos"] - e["pos"]).normalized()
	var heavy: bool = str(e.get("kind", "")) == "crossbow"
	enemy_shots.append(
		{
			"kind": "bolt" if heavy else "arrow",
			"pos": e["pos"],
			"vel": dir * (255.0 if heavy else (176.0 if chosen_mode == "story" else 195.0)),
			"damage": float(e["damage"]) * (1.12 if heavy else 1.0),
			"life": 4.0,
			"radius": 7.0
		}
	)
	play_sfx("arrow", 0.75)


func update_player_shots(delta: float) -> void:
	# 使用空間格只檢查鄰近敵人，避免投射物數量增加後形成 O(彈數×敵數)。
	for i in range(player_shots.size() - 1, -1, -1):
		var shot: Dictionary = player_shots[i]
		shot["pos"] += shot["vel"] * delta
		shot["life"] = float(shot["life"]) - delta
		var remove: bool = (
			float(shot["life"]) <= 0.0 or not WORLD.grow(160.0).has_point(shot["pos"])
		)
		if not remove:
			var candidates: Array = nearby_enemy_uids(shot["pos"])
			for uid_value in candidates:
				var uid: int = int(uid_value)
				if shot["hit_ids"].has(uid):
					continue
				var enemy_index: int = int(enemy_uid_index.get(uid, -1))
				if enemy_index < 0 or enemy_index >= enemies.size():
					continue
				var enemy: Dictionary = enemies[enemy_index]
				var hit_radius: float = float(shot["radius"]) + float(enemy["radius"])
				if shot["pos"].distance_squared_to(enemy["pos"]) > hit_radius * hit_radius:
					continue
				shot["hit_ids"].append(uid)
				var bonus_crit: float = (
					0.15 if has_relic("returningblade") and shot["hit_ids"].size() > 1 else 0.0
				)
				var crit: bool = rng.randf() < float(player["crit"]) + bonus_crit
				var damage: float = float(shot["damage"]) * (1.75 if crit else 1.0)
				if float(enemy["marked"]) > 0.0:
					damage *= 1.12
				if float(enemy["armor_break"]) > 0.0:
					damage *= 1.18
				var live_index: int = damage_enemy(enemy_index, damage, str(shot["kind"]), crit)
				if live_index >= 0 and float(shot["poison"]) > 0.0:
					apply_poison(live_index, float(shot["poison"]))
				if live_index >= 0 and has_relic("frostjade") and rng.randf() < 0.08:
					enemies[live_index]["slow"] = max(float(enemies[live_index]["slow"]), 2.0)
				if bool(shot.get("alpha51_arcane_orb", false)):
					PlayerSignaturePassiveService.on_projectile_enemy_hit(self, shot, live_index)
				shot["pierce"] = int(shot["pierce"]) - 1
				if int(shot["pierce"]) < 0:
					remove = true
					break
		if not remove and not boss.is_empty() and float(boss.get("hp", 0.0)) > 0.0:
			var boss_hit_radius: float = float(shot["radius"]) + float(boss["radius"])
			if (
				shot["pos"].distance_squared_to(boss["pos"]) < boss_hit_radius * boss_hit_radius
				and not shot["hit_ids"].has(-999)
			):
				shot["hit_ids"].append(-999)
				var crit: bool = rng.randf() < float(player["crit"])
				damage_boss(float(shot["damage"]) * (1.75 if crit else 1.0), str(shot["kind"]), crit)
				if bool(shot.get("alpha51_arcane_orb", false)):
					PlayerSignaturePassiveService.on_projectile_boss_hit(self, shot)
				shot["pierce"] = int(shot["pierce"]) - 1
				if int(shot["pierce"]) < 0:
					remove = true
		if remove:
			fast_remove_at(player_shots, i)
		else:
			player_shots[i] = shot


func update_enemy_shots(delta: float) -> void:
	for i in range(enemy_shots.size() - 1, -1, -1):
		var s: Dictionary = enemy_shots[i]
		s["pos"] += s["vel"] * delta
		s["life"] = float(s["life"]) - delta
		var remove: bool = float(s["life"]) <= 0.0
		for a in allies:
			if not remove and s["pos"].distance_to(a["pos"]) < 18.0:
				a["hp"] = float(a["hp"]) - float(s["damage"])
				remove = true
				spawn_sparks(s["pos"], Color8(222, 198, 129), 5)
				break
		if not remove and projectile_hits_obstacle(s["pos"]):
			remove = true
		if not remove and s["pos"].distance_to(player["pos"]) < float(s["radius"]) + 13.0:
			damage_player(float(s["damage"]), "arrow", float(s.get("shield_pierce", 0.0)))
			remove = true
		if remove:
			fast_remove_at(enemy_shots, i)
		else:
			enemy_shots[i] = s


func projectile_hits_obstacle(pos: Vector2) -> bool:
	for ob in obstacles:
		if Rect2(ob["pos"] - ob["size"] * 0.5, ob["size"]).has_point(pos):
			return true
	return false


func damage_player(amount: float, source: String, shield_pierce: float = 0.0) -> void:
	if float(player["invuln"]) > 0.0 or float(player["dash_active"]) > 0.0:
		return
	var source_mult: float = 1.0
	if source == "arrow":
		source_mult *= equipment_effect("arrow_taken_mult", 1.0)
	if source == "fire":
		source_mult *= equipment_effect("fire_taken_mult", 1.0)
	source_mult *= PlayerSignaturePassiveService.incoming_damage_multiplier(self, chosen_identity, source)
	var reduced: float = max(
		1.0,
		(
			amount
			* source_mult
			* equipment_effect("damage_taken_mult", 1.0)
			* float(history_modifiers.get("incoming_damage_mult", 1.0))
			* difficulty_incoming_mult()
			* build_incoming_damage_multiplier()
			* max(0.55, 1.0 - relic_stat("damage_reduction"))
			- float(player["armor"])
			- float(relic_level("ironbracer"))
		)
	)
	# 部分Boss招式可穿透護盾，但仍保留閃避與無敵幀作為反制手段。
	var pierce_ratio: float = clamp(shield_pierce, 0.0, 0.75)
	var hp_damage: float = reduced * pierce_ratio
	var shieldable_damage: float = reduced - hp_damage
	var shield: float = float(player["shield"])
	if shield > 0.0 and shieldable_damage > 0.0:
		var absorbed: float = min(shield, shieldable_damage)
		player["shield"] = shield - absorbed
		shieldable_damage -= absorbed
	hp_damage += shieldable_damage
	var reduced_after_shield: float = hp_damage
	if reduced_after_shield > 0.0:
		player["hp"] = float(player["hp"]) - reduced_after_shield
		if has_relic("formationseal") and float(player.get("formation_relic_cd", 0.0)) <= 0.0:
			player["formation_relic_cd"] = 2.0
			for hero_id in active_heroes:
				hero_cooldowns[hero_id] = max(0.0, float(hero_cooldowns.get(hero_id, 0.0)) - 1.4)
			trigger_relic("formationseal", "受創後軍勢重整")
		run_stats["damage_taken"] = float(run_stats["damage_taken"]) + reduced_after_shield
		if source == "arrow":
			run_stats["arrows_taken"] = int(run_stats["arrows_taken"]) + 1
		if source == "contact":
			run_stats["contact_taken"] = int(run_stats["contact_taken"]) + 1
	player["invuln"] = 0.50
	player["flash"] = 0.18
	if bool(save_data["settings"].get("shake", true)):
		screen_shake = max(screen_shake, 7.0 if reduced_after_shield > 0.0 else 3.0)
	play_sfx("hurt", rng.randf_range(0.92, 1.06))
	spawn_sparks(player["pos"], Color8(235, 105, 86), 10)
	if reduced_after_shield > 0.0:
		add_damage_number(
			{
				"pos": player["pos"] + Vector2(0, -26),
				"text": "-%d" % int(ceil(reduced_after_shield)),
				"life": 0.75,
				"color": Color8(255, 120, 100)
			}
		)
	else:
		add_damage_number(
			{
				"pos": player["pos"] + Vector2(0, -26),
				"text": "格擋",
				"life": 0.60,
				"color": Color8(117, 192, 231)
			}
		)
	if (
		reduced_after_shield > 0.0
		and float(player["hp"]) <= float(player["max_hp"]) * 0.30
		and not survival_used
	):
		survival_used = true
		player["shield"] = float(player["shield"]) + 18.0
		for e in enemies:
			var away: Vector2 = (e["pos"] - player["pos"]).normalized()
			if e["pos"].distance_to(player["pos"]) < 190.0:
				e["knock"] += away * 420.0
		spawn_ring(player["pos"], Color8(242, 212, 128), 190.0, 0.55)
		show_message("求生意志：震退敵軍並獲得護盾", 3.0)
	if (
		reduced_after_shield > 0.0
		and float(player["hp"]) <= float(player["max_hp"]) * 0.25
		and has_relic("yellowwater")
		and not yellow_water_used
	):
		yellow_water_used = true
		heal_player(20.0)
		for e in enemies:
			if e["pos"].distance_to(player["pos"]) < 230.0:
				e["knock"] += (e["pos"] - player["pos"]).normalized() * 360.0
		trigger_relic("yellowwater", "符水護命")
	if float(player["hp"]) <= 0.0:
		request_run_result(false)


func heal_player(amount: float) -> void:
	var value: float = amount * float(player["heal_power"]) * equipment_effect("heal_mult", 1.0)
	var missing: float = float(player["max_hp"]) - float(player["hp"])
	var healed: float = min(missing, value)
	player["hp"] = float(player["hp"]) + healed
	var overflow: float = value - healed
	if overflow > 0.0 and has_relic("qingnang"):
		player["shield"] = min(80.0, float(player["shield"]) + overflow * min(1.0, 0.55 + 0.15 * relic_level("qingnang")))
		trigger_relic("qingnang", "溢出治療轉為護盾")
	play_sfx("heal")
	spawn_ring(player["pos"], Color8(134, 221, 154), 82.0, 0.45)


func damage_numbers_enabled() -> bool:
	return bool(save_data["settings"].get("damage_numbers", true))


func build_resonance_stage(score: int = -1) -> int:
	var current_score: int = score
	if current_score < 0:
		current_score = int(dominant_build()["score"])
	if current_score >= 13:
		return 3
	if current_score >= 9:
		return 2
	if current_score >= 5:
		return 1
	return 0


func build_resonance_stage_name(stage: int = -1) -> String:
	var current_stage: int = stage if stage >= 0 else build_resonance_stage()
	return ["未成形", "初鳴", "共振", "大成"][clampi(current_stage, 0, 3)]


func build_attack_speed_multiplier() -> float:
	var build: Dictionary = dominant_build()
	var stage: int = build_resonance_stage(int(build["score"]))
	if stage < 2:
		return 1.0
	match str(build["id"]):
		"blade": return 1.08 if stage == 2 else 1.14
		"arrow": return 1.10 if stage == 2 else 1.18
		_: return 1.0


func build_incoming_damage_multiplier() -> float:
	var build: Dictionary = dominant_build()
	var stage: int = build_resonance_stage(int(build["score"]))
	if str(build["id"]) != "survival" or stage < 2:
		return 1.0
	return 0.90 if stage == 2 else 0.82


func build_hero_cooldown_multiplier() -> float:
	var build: Dictionary = dominant_build()
	var stage: int = build_resonance_stage(int(build["score"]))
	if str(build["id"]) != "command" or stage < 2:
		return 1.0
	return 0.90 if stage == 2 else 0.80


func build_bonus_description() -> String:
	var build: Dictionary = dominant_build()
	var stage: int = build_resonance_stage(int(build["score"]))
	if stage == 0:
		return "尚未形成共鳴；將同流派技能、遺物、裝備與名將集中搭配。"
	var base: String = "核心傷害提升"
	match str(build["id"]):
		"blade": base = "近戰核心傷害提升；共振後提高攻擊速度。"
		"arrow": base = "箭矢核心傷害提升；共振後提高連射速度。"
		"poison": base = "毒傷核心傷害提升；大成時傷害增幅上限提高。"
		"command": base = "名將核心傷害提升；共振後縮短名將冷卻。"
		"survival": base = "防守循環成形；共振後降低承受傷害。"
		"element": base = "火、雷、霜核心傷害提升；大成時傷害增幅上限提高。"
	return "%s（%s）" % [base, build_resonance_stage_name(stage)]


func emphasize_damage_number(entry: Dictionary) -> Dictionary:
	var result: Dictionary = entry.duplicate(true)
	var raw_text: String = str(result.get("text", "0"))
	var numeric_text: String = raw_text.replace("!", "").replace("+", "").replace("-", "")
	var amount: float = float(numeric_text) if numeric_text.is_valid_float() else 0.0
	var critical: bool = raw_text.contains("!")
	result["life"] = max(float(result.get("life", 0.72)), 0.92 if critical else 0.78)
	result["size"] = max(float(result.get("size", 18.0)), 29.0 if critical else (24.0 if amount >= 40.0 else 20.0))
	result["outline"] = max(float(result.get("outline", 2.0)), 4.0 if critical else 3.0)
	return result


func add_damage_number(entry: Dictionary) -> void:
	if not damage_numbers_enabled():
		return
	# 中後期優先保留暴擊、治療與高額傷害數字，避免大量小字造成繪製壓力。
	var text_value: String = str(entry.get("text", ""))
	var important: bool = text_value.contains("!") or text_value.begins_with("+")
	if performance_level >= 1 and not important:
		var stride: int = 2 + performance_level
		if frame_serial % stride != 0:
			return
	if damage_numbers.size() >= MAX_DAMAGE_NUMBERS:
		fast_remove_at(damage_numbers, 0)
	damage_numbers.append(emphasize_damage_number(entry))


func can_spawn_visual_zone() -> bool:
	var visual_cap: int = int(float(MAX_ZONES) * effect_density()) - performance_level * 12
	return zones.size() < max(24, visual_cap) and performance_pressure != "偏高"


func build_resonance_scores() -> Dictionary:
	var scores: Dictionary = {"blade":0, "arrow":0, "poison":0, "command":0, "survival":0, "element":0}
	if chosen_identity == "swordsman":
		scores["blade"] += 2
	elif chosen_identity in ["hunter", "archer"]:
		scores["arrow"] += 2
	elif chosen_identity in ["poisoner", "strategist"]:
		scores["poison"] += 2
	elif chosen_identity == "heroine":
		scores["element"] += 2
	for sid in skill_levels:
		var lv: int = int(skill_levels[sid])
		match str(sid):
			"projectile", "pierce", "multishot": scores["arrow"] += lv
			"poison": scores["poison"] += lv * 2
			"armor", "max_hp", "heal", "dash": scores["survival"] += lv
			"hero_cd": scores["command"] += lv * 2
			"crit", "attack_speed": scores["blade"] += lv
	for rid in relics:
		match str(rid):
			"arrowhead", "crossbow": scores["arrow"] += 2
			"poisonbag", "yellowwater": scores["poison"] += 2
			"warbanner", "formationseal", "tigerseal": scores["command"] += 2
			"ironbracer", "qingnang", "frostjade": scores["survival"] += 2
			"returningblade", "redhare": scores["blade"] += 2
			"copperfan", "moonbell", "jade": scores["element"] += 2
	for eid in equipped.values():
		var text: String = str(eid)
		if text in ["serpent_spear", "green_dragon", "sky_halberd"]:
			scores["blade"] += 3
		elif "bow" in text or "crossbow" in text:
			scores["arrow"] += 3
		elif "poison" in text:
			scores["poison"] += 3
		elif text != "":
			scores["survival"] += 1
	if active_heroes.size() >= 2:
		scores["command"] += active_heroes.size()
	return scores

func dominant_build() -> Dictionary:
	var names: Dictionary = {"blade":"破軍斬陣", "arrow":"萬箭穿雲", "poison":"百毒蝕骨", "command":"群雄號令", "survival":"鐵壁長存", "element":"奇策天變"}
	var colors: Dictionary = {"blade":Color8(218,92,67), "arrow":Color8(110,184,128), "poison":Color8(175,102,201), "command":Color8(224,181,86), "survival":Color8(112,161,205), "element":Color8(103,196,211)}
	var scores: Dictionary = build_resonance_scores()
	var best: String = "blade"
	for key in scores:
		if int(scores[key]) > int(scores[best]):
			best = str(key)
	return {"id":best, "name":names[best], "score":int(scores[best]), "color":colors[best]}

func build_damage_multiplier(source: String) -> float:
	var build: Dictionary = dominant_build()
	var score: int = int(build["score"])
	if score < 5:
		return 1.0
	var stage: int = build_resonance_stage(score)
	var cap: float = 0.18 if stage < 3 else 0.25
	var mult: float = 1.0 + min(cap, float(score - 4) * 0.018)
	match str(build["id"]):
		"blade":
			return mult if source in ["slash", "guanyu", "zhangfei", "sunjian", "lvlingqi", "return_blade"] else 1.0
		"arrow":
			return mult if source in ["arrow", "fire_arrow", "taishici", "sunshangxiang", "huangzhong"] else 1.0
		"poison":
			return mult if source in ["poison", "needle", "poison_tick"] else 1.0
		"command":
			return mult if heroes.has(source) else 1.0
		"element":
			return mult if source in ["fire", "lightning", "frost", "zhangjiao", "zhouyu", "zhenji"] else 1.0
		_:
			return 1.0

func damage_enemy(index: int, amount: float, source: String, crit: bool) -> int:
	if index < 0 or index >= enemies.size():
		return -1
	amount *= ElementalSynergyService.damage_multiplier(enemies[index], source)
	if ElementalSynergyService.is_lightning_source(source):
		StatusEffectService.apply_enemy(self, index, "shock", 2.4, 0.22, 1)
	var e: Dictionary = enemies[index]
	var uid: int = int(e.get("uid", -1))
	var final: float = max(
		1.0,
		(
			amount * build_damage_multiplier(source) * equipment_effect("damage_mult", 1.0) * float(history_modifiers.get("player_damage_mult", 1.0))
			- float(e.get("armor", 0.0))
		)
	)
	if bool(e["elite"]) and reserve_heroes.has("guanyu"):
		final *= 1.05
	if float(e["marked"]) > 0.0:
		final *= 1.0 + passive_level("taishici") * 0.025
	if float(e["slow"]) > 0.0 and reserve_heroes.has("zhenji"):
		final *= 1.08
	e["hp"] = float(e["hp"]) - final
	e["last_hit"] = source
	run_stats["damage_dealt"] = float(run_stats["damage_dealt"]) + final
	add_damage_number(
		{
			"pos": e["pos"] + Vector2(rng.randf_range(-8, 8), -22),
			"text": "%d%s" % [int(round(final)), "!" if crit else ""],
			"life": 0.65,
			"color": Color8(255, 222, 126) if crit else Color8(235, 235, 220)
		}
	)
	if crit:
		spawn_sparks(e["pos"], Color8(255, 219, 103), 7)
	spawn_impact_effect(e["pos"], source, crit, final)
	if crit:
		request_hit_stop(0.020)
	elif final >= 42.0 and source in ["slash", "guanyu", "zhangfei", "sunjian", "lvlingqi"]:
		request_hit_stop(0.012)
	enemies[index] = e
	if float(e["hp"]) <= 0.0:
		kill_enemy(index)
		return -1
	return enemy_index_by_uid(uid)


func damage_boss(amount: float, source: String, crit: bool) -> void:
	if boss.is_empty() or float(boss.get("hp", 0.0)) <= 0.0:
		return
	amount *= ElementalSynergyService.damage_multiplier(boss, source)
	if ElementalSynergyService.is_lightning_source(source):
		StatusEffectService.apply_boss(self, "shock", 2.0, 0.18, 1)
	if bool(boss_phase_state.get("transitioning", false)):
		return
	amount *= RelicStatusSynergyService.damage_multiplier(self, boss, source)
	HeroElementalBuildService.apply_named_hero_status(self, "boss", -1, source)
	var final: float = amount * build_damage_multiplier(source) * equipment_effect("damage_mult", 1.0) * float(history_modifiers.get("player_damage_mult", 1.0))
	if boss_counter_window > 0.0:
		final *= Alpha34BossCounterWindow.counter_damage_multiplier(boss_counter_was_break)
		spawn_sparks(boss.get("pos", Vector2.ZERO) as Vector2, Color8(247, 220, 130), 3)
	if not boss_attack_timeline.is_empty() and boss_break_immunity <= 0.0:
		boss_break_damage += final
		var break_need: float = Alpha34BossCounterWindow.break_threshold(boss, difficulty_id()) * Alpha35BossPhaseEnrage.break_threshold_mult(boss_phase_state)
		if boss_break_damage >= break_need:
			trigger_boss_break()
	if has_relic("tigerseal"):
		final *= 1.12
	if reserve_heroes.has("guanyu"):
		final *= 1.04
	final *= boss_cooperation_multiplier()
	boss["hp"] = float(boss["hp"]) - final
	spawn_impact_effect(boss["pos"], source, crit, final)
	if crit:
		request_hit_stop(0.026)
	elif final >= 55.0 or source in ["guanyu", "zhangfei", "sunjian", "lvlingqi"]:
		request_hit_stop(0.016)
	run_stats["damage_dealt"] = float(run_stats["damage_dealt"]) + final
	run_stats["boss_damage"] = float(run_stats["boss_damage"]) + final
	add_damage_number(
		{
			"pos": boss["pos"] + Vector2(rng.randf_range(-18, 18), -48),
			"text": "%d%s" % [int(round(final)), "!" if crit else ""],
			"life": 0.65,
			"color": Color8(255, 210, 100)
		}
	)
	if float(boss["hp"]) <= 0.0:
		boss["hp"] = 0.0
		if support_boss_alive():
			boss["downed"] = true
			show_message("主將已倒下，擊破副將才能結束戰鬥！", 3.0)
			spawn_ring(boss["pos"], Color8(201, 172, 108), 120.0, 0.65)
		else:
			finish_boss_if_ready()


func spawn_impact_effect(pos: Vector2, source: String, crit: bool, amount: float) -> void:
	if not can_spawn_visual_zone():
		return
	var impact_color: Color = Color8(238, 215, 165)
	if source in ["poison", "zhangjiao"]:
		impact_color = Color8(183, 112, 211)
	elif source in ["fire", "sunjian", "sunshangxiang"]:
		impact_color = Color8(240, 118, 54)
	elif source in ["frost", "zhenji"]:
		impact_color = Color8(145, 211, 239)
	elif source in ["guanyu", "slash", "blade_wave"]:
		impact_color = Color8(113, 213, 158)
	zones.append(
		{
			"kind": "impact_visual",
			"pos": pos,
			"r": 18.0 + min(22.0, amount * 0.18),
			"life": 0.18 if not crit else 0.26,
			"max_life": 0.18 if not crit else 0.26,
			"color": impact_color,
			"crit": crit
		}
	)
	spawn_sparks(pos, impact_color, 7 if crit else 3)


func boss_cooperation_multiplier() -> float:
	if boss.is_empty():
		return 1.0
	var bid: String = str(boss.get("id", ""))
	if bid == "lvbu" and active_bonds.has("taoyuan"):
		return 1.28 if history_flags.has("three_heroes_challenge") else 1.18
	if (
		bid == "huaxiong"
		and active_heroes.has("liubei")
		and active_heroes.has("caocao")
		and active_heroes.has("sunjian")
	):
		return 1.15
	if bid == "gaoshun" and active_bonds.has("western_resolve"):
		return 1.10
	if bid == "yuanshao" and active_bonds.has("wenji_return"):
		return 1.12
	return 1.0


func hero_role(hid: String) -> String:
	var roles: Dictionary = {
		"liubei": "援軍・護衛",
		"guanyu": "重斬・破陣",
		"zhangfei": "震退・控場",
		"zhaoyun": "穿陣・直線清場",
		"huangzhong": "重箭・遠程狙擊",
		"huatuo": "治療・護盾",
		"caocao": "軍令・加速",
		"sunjian": "突進・清線",
		"taishici": "神射・貫穿",
		"zhangjiao": "雷法・傳毒",
		"diaochan": "魅惑・牽引",
		"sunshangxiang": "連射・火箭",
		"zhenji": "冰霜・控場",
		"lvlingqi": "突擊・爆發",
		"wangyi": "回刃・暴擊",
		"caiwenji": "治療・音波",
		"daqiao": "屏障・反射"
	}
	return str(roles.get(hid, "名將之力"))


func spawn_hero_signature_effect(hid: String, center: Vector2, dir: Vector2, lv: int) -> void:
	if not can_spawn_visual_zone():
		hero_cast_flash = {"id": hid, "life": Alpha27ActionProfiles.hero_cast_duration(hid), "max_life": Alpha27ActionProfiles.hero_cast_duration(hid), "pos": center}
		return
	zones.append(
		{
			"kind": "hero_effect",
			"hero": hid,
			"pos": center,
			"angle": dir.angle(),
			"r": 150.0 + lv * 10.0,
			"life": 0.72,
			"max_life": 0.72,
			"color": heroes[hid]["color"]
		}
	)
	hero_cast_flash = {"id": hid, "life": Alpha27ActionProfiles.hero_cast_duration(hid), "max_life": Alpha27ActionProfiles.hero_cast_duration(hid), "pos": center}


func damage_arc(
	pos: Vector2, angle: float, radius: float, arc_width: float, damage: float, knock_force: float
) -> void:
	for enemy_index in range(enemies.size() - 1, -1, -1):
		if enemy_index >= enemies.size():
			continue
		var enemy: Dictionary = enemies[enemy_index]
		var diff: Vector2 = enemy["pos"] - pos
		if (
			diff.length_squared() <= radius * radius
			and abs(wrapf(diff.angle() - angle, -PI, PI)) <= arc_width * 0.5
		):
			var live_index: int = damage_enemy(
				enemy_index, damage, "slash", rng.randf() < float(player["crit"])
			)
			if live_index >= 0:
				enemies[live_index]["knock"] += diff.normalized() * knock_force
	if not boss.is_empty():
		var diff: Vector2 = boss["pos"] - pos
		if (
			diff.length_squared() <= pow(radius + float(boss["radius"]), 2.0)
			and abs(wrapf(diff.angle() - angle, -PI, PI)) <= arc_width * 0.5
		):
			damage_boss(damage, "slash", false)


func equipment_slot_unlock_requirement(slot: String) -> int:
	match slot:
		"accessory": return 4
		"jade": return 7
	return 0


func equipment_slot_unlocked(slot: String) -> bool:
	var requirement: int = equipment_slot_unlock_requirement(slot)
	if requirement <= 0:
		return true
	return chapter_manager.completed_ids().size() >= requirement


func equipment_slot_lock_text(slot: String) -> String:
	var requirement: int = equipment_slot_unlock_requirement(slot)
	return "完成第%d章後開放" % requirement if requirement > 0 else ""


func equipment_effect(key: String, default_value: float = 1.0) -> float:
	var result: float = default_value
	for slot in ["weapon", "body", "treasure", "accessory", "jade"]:
		var eid: String = str(equipped.get(slot, ""))
		if eid == "" or not equipment_defs.has(eid):
			continue
		var effects: Dictionary = equipment_defs[eid].get("effects", {})
		if effects.has(key):
			result *= float(effects[key])
	return result


func equipment_slot_name(slot: String) -> String:
	match slot:
		"weapon": return "武器"
		"body": return "身體"
		"treasure": return "寶物"
		"accessory": return "飾品"
		"jade": return "玉佩"
		_: return slot


func grant_equipment(eid: String, reason: String) -> bool:
	if eid == "" or not equipment_defs.has(eid):
		return false
	if equipment_inventory.has(eid):
		player["coins"] = int(player.get("coins", 0)) + 35
		show_message("%s已持有，轉化為35枚銅錢。" % equipment_defs[eid]["name"], 2.5)
		return false
	equipment_inventory.append(eid)
	var slot: String = str(equipment_defs[eid].get("slot", "treasure"))
	if equipment_slot_unlocked(slot) and str(equipped.get(slot, "")) == "":
		equipped[slot] = eid
	var suffix: String = "" if equipment_slot_unlocked(slot) else "（%s，可先收藏）" % equipment_slot_lock_text(slot)
	show_message("獲得%s：%s%s" % [equipment_slot_name(slot), equipment_defs[eid]["name"], suffix], 3.0)
	play_sfx("levelup", 0.92)
	return true


func equip_selected_inventory_item() -> void:
	if equipment_inventory.is_empty():
		return
	tab_index = clampi(tab_index, 0, equipment_inventory.size() - 1)
	var eid: String = str(equipment_inventory[tab_index])
	var slot: String = str(equipment_defs[eid].get("slot", "treasure"))
	if not equipment_slot_unlocked(slot):
		show_message("%s尚未開放：%s" % [equipment_slot_name(slot), equipment_slot_lock_text(slot)], 2.6)
		play_sfx("ui_cancel")
		return
	equipped[slot] = eid
	show_message("已裝備：%s" % equipment_defs[eid]["name"], 2.0)
	play_sfx("ui_confirm")


func boss_equipment_drop(force_drop: bool = false) -> String:
	var boss_id: String = str(chapter_manager.boss_definition().get("id", ""))
	var chapter_index: int = int(current_chapter().get("index", 0))
	var chance: float = clamp(0.18 + float(chapter_index) * 0.018, 0.18, 0.40)
	if not force_drop and rng.randf() > chance:
		return ""
	var dedicated: Array[String] = []
	var general: Array[String] = []
	for eid_value in equipment_defs.keys():
		var eid: String = str(eid_value)
		if equipment_inventory.has(eid):
			continue
		var bosses: Array = equipment_defs[eid].get("bosses", [])
		if bosses.has(boss_id):
			dedicated.append(eid)
		else:
			general.append(eid)
	if not dedicated.is_empty() and rng.randf() < 0.55:
		return dedicated[rng.randi_range(0, dedicated.size() - 1)]
	if general.is_empty():
		return ""
	return general[rng.randi_range(0, general.size() - 1)]


func prepare_boss_loot() -> void:
	var reward_id: String = str(chapter_manager.boss_definition().get("reward", ""))
	var relic_id: String = random_unowned_relic(reward_id)
	var boss_id: String = str(chapter_manager.boss_definition().get("id", ""))
	var first_clear: bool = int(boss_defeat_counts.get(boss_id, 0)) <= 0
	var equipment_id: String = boss_equipment_drop(first_clear)
	var coin_reward: int = 70 + int(current_chapter().get("index", 0)) * 18
	pending_boss_loot = {
		"boss_name": str(chapter_manager.boss_definition().get("name", "敵將")),
		"relic": relic_id,
		"equipment": equipment_id,
		"coins": coin_reward,
		"first_clear": first_clear
	}


func accept_boss_loot() -> void:
	if pending_boss_loot.is_empty():
		return
	chapter_boss_relic_given = true
	chapter_reward_relic = str(pending_boss_loot.get("relic", ""))
	if chapter_reward_relic != "":
		grant_relic(chapter_reward_relic, "擊敗章末敵將", true)
	var equipment_id: String = str(pending_boss_loot.get("equipment", ""))
	if equipment_id != "":
		grant_equipment(equipment_id, "敵將掉落")
	player["coins"] = int(player.get("coins", 0)) + int(pending_boss_loot.get("coins", 0))
	hero_star_points += 1
	if bool(pending_boss_loot.get("first_clear", false)):
		hero_orders += 1
	show_message("獲得將星點×1%s" % ("、名將令×1" if bool(pending_boss_loot.get("first_clear", false)) else ""), 2.8)
	var defeated_boss_id: String = str(chapter_manager.boss_definition().get("id", ""))
	boss_defeat_counts[defeated_boss_id] = int(boss_defeat_counts.get(defeated_boss_id, 0)) + 1
	pending_boss_loot.clear()
	boss_ability_banner.clear()
	finalize_chapter_victory()


func finalize_chapter_victory() -> void:
	if chosen_mode == "story" and chapter_manager.is_final_chapter():
		finalize_campaign_ending()
		return
	if not chapter_manager.resolve_chapter():
		push_error("Chapter victory could not be resolved")
		return
	screen = "victory"
	var definition: Dictionary = chapter_manager.boss_definition()
	game_over_reason = "擊敗%s，%s戰局暫告一段落。" % [str(definition.get("name", "敵將")), chapter_manager.current_title()]
	chapter_clear_snapshot = {
		"chapter_id": chapter_manager.current_id(),
		"chapter_title": chapter_manager.current_title(),
		"reward_relic": chapter_reward_relic
	}
	if chapter_manager.has_next_chapter():
		save_run_checkpoint()
	else:
		clear_run_checkpoint()
	option_index = 0

func random_relic_offer(preferred: String = "") -> String:
	if preferred != "" and relic_defs.has(preferred):
		if not relics.has(preferred) or relic_level(preferred) < MAX_RELIC_LEVEL:
			return preferred
	var upgrade_pool: Array[String] = []
	var new_pool: Array[String] = []
	for key in relic_defs.keys():
		var rid: String = str(key)
		if relics.has(rid):
			if relic_level(rid) < MAX_RELIC_LEVEL:
				upgrade_pool.append(rid)
		else:
			new_pool.append(rid)
	# 已有流派成形後，優先讓遺物升級而不是一路塞入新種類。
	if not upgrade_pool.is_empty() and (new_pool.is_empty() or rng.randf() < 0.58):
		return upgrade_pool[rng.randi_range(0, upgrade_pool.size() - 1)]
	if not new_pool.is_empty():
		return new_pool[rng.randi_range(0, new_pool.size() - 1)]
	if not upgrade_pool.is_empty():
		return upgrade_pool[rng.randi_range(0, upgrade_pool.size() - 1)]
	return ""


func random_unowned_relic(preferred: String = "") -> String:
	# 舊呼叫名稱保留相容性；現在可能回傳可升級的既有遺物。
	return random_relic_offer(preferred)



func open_relic_notice(rid: String, reason: String, upgraded: bool, old_level: int, new_level: int) -> void:
	if rid == "" or not relic_defs.has(rid):
		return
	pending_relic_notice = {
		"id": rid,
		"reason": reason,
		"upgraded": upgraded,
		"old_level": old_level,
		"new_level": new_level
	}
	modal_input_lock_until_ms = Time.get_ticks_msec() + 160

func grant_relic(rid: String, reason: String, counts_toward_chapter_limit: bool = true) -> bool:
	if rid == "" or not relic_defs.has(rid):
		player["coins"] = int(player.get("coins", 0)) + 10
		show_message("遺物池已完成，轉化為10枚銅錢。", 2.5)
		return false
	var already_owned: bool = relics.has(rid)
	var previous_level: int = relic_level(rid) if already_owned else 0
	if not already_owned and counts_toward_chapter_limit and chapter_natural_relics >= MAX_NEW_RELICS_PER_CHAPTER:
		player["coins"] = int(player.get("coins", 0)) + 14
		show_message("本章新遺物已達3種上限，轉化為14枚銅錢。", 2.5)
		return false
	if already_owned:
		var old_level: int = relic_level(rid)
		if old_level >= MAX_RELIC_LEVEL:
			player["coins"] = int(player.get("coins", 0)) + 12
			show_message("%s已達Lv.%d，轉化為12枚銅錢。" % [relic_defs[rid]["name"], MAX_RELIC_LEVEL], 2.5)
			return false
		relic_levels[rid] = old_level + 1
		open_relic_notice(rid, reason, already_owned, previous_level, relic_level(rid))
		trigger_relic(rid, "%s　Lv.%d → Lv.%d" % [reason, old_level, old_level + 1])
		play_sfx("levelup", 1.12)
		return true
	relics.append(rid)
	relic_levels[rid] = 1
	if counts_toward_chapter_limit:
		chapter_natural_relics += 1
	open_relic_notice(rid, reason, already_owned, previous_level, relic_level(rid))
	trigger_relic(rid, "%s　獲得Lv.1" % reason)
	play_sfx("levelup", 1.08)
	return true

func grant_random_relic(reason: String, preferred: String = "", counts_toward_chapter_limit: bool = true) -> String:
	var rid: String = random_relic_offer(preferred)
	return rid if grant_relic(rid, reason, counts_toward_chapter_limit) else ""


func spawn_relic_pickup(pos: Vector2, preferred: String = "") -> void:
	var rid: String = random_relic_offer(preferred)
	if rid != "" and not relics.has(rid) and chapter_natural_relics >= MAX_NEW_RELICS_PER_CHAPTER:
		pickups.append({"kind": "coin", "pos": pos, "value": 14, "vel": Vector2.ZERO})
		return
	if rid == "":
		pickups.append({"kind": "coin", "pos": pos, "value": 10, "vel": Vector2.ZERO})
		return
	pickups.append({"kind": "relic", "id": rid, "pos": pos, "value": 0, "vel": Vector2.ZERO})


func kill_enemy(index: int) -> void:
	if index < 0 or index >= enemies.size():
		return
	var e: Dictionary = enemies[index]
	var was_poisoned: bool = float(e["poison"]) > 0.0
	var was_support_boss: bool = bool(e.get("boss_support", false))
	RelicStatusSynergyService.on_enemy_killed(self, e)
	var support_name: String = str(e.get("name", "副將"))
	var pos: Vector2 = e["pos"]
	var was_elite: bool = bool(e.get("elite", false))
	run_stats["kills"] = int(run_stats["kills"]) + 1
	var xp_value: float = 5.5 if was_elite else 2.8
	if pickups.size() >= 66 or performance_pressure != "穩定":
		gain_xp(xp_value)
	else:
		pickups.append(
			{
				"kind": "xp",
				"pos": pos,
				"value": xp_value,
				"vel": Vector2.from_angle(rng.randf_range(0, TAU)) * 55.0
			}
		)
	if rng.randf() < (0.28 if was_elite else 0.10):
		var coin_value: int = 3 if was_elite else 1
		if pickups.size() >= 76 or performance_pressure == "偏高":
			player["coins"] = int(player.get("coins", 0)) + coin_value
		else:
			pickups.append(
				{
					"kind": "coin",
					"pos": pos + Vector2(8, 0),
					"value": coin_value,
					"vel": Vector2.from_angle(rng.randf_range(0, TAU)) * 45.0
				}
			)
	if was_elite and not chapter_elite_relic_given:
		chapter_elite_relic_given = true
		spawn_relic_pickup(pos + Vector2(0, -18))
		show_message("精英敵將掉落了遺物！", 2.5)
	var heal_chance: float = (
		0.018 + (0.018 if reserve_heroes.has("huatuo") else 0.0) + skill_level("heal") * 0.005
	)
	if rng.randf() < heal_chance:
		pickups.append(
			{"kind": "heal", "pos": pos + Vector2(-8, 0), "value": 13.0, "vel": Vector2.ZERO}
		)
	if was_poisoned and has_relic("poisonbag"):
		zones.append(
			{
				"kind": "poison",
				"pos": pos,
				"r": 74.0,
				"life": 3.2,
				"tick": 0.0,
				"damage": 4.0,
				"color": Color8(128, 91, 160)
			}
		)
		trigger_relic("poisonbag", "毒霧生成")
	if was_poisoned and reserve_heroes.has("zhangjiao") and rng.randf() < 0.35:
		spread_poison(pos, 110.0, 1.0)
	if reserve_heroes.has("sunjian"):
		player["kill_speed_buff"] = 1.2
	spawn_sparks(pos, Color8(210, 185, 120), 7)
	var removed_uid: int = int(e.get("uid", -1))
	var last_index: int = enemies.size() - 1
	if index != last_index:
		enemies[index] = enemies[last_index]
		var moved_uid: int = int(enemies[index].get("uid", -1))
		enemy_uid_index[moved_uid] = index
	enemies.pop_back()
	enemy_uid_index.erase(removed_uid)
	if was_support_boss:
		show_message("副將%s已敗！" % support_name, 2.5)
		spawn_ring(pos, Color8(231, 190, 101), 100.0, 0.55)
		finish_boss_if_ready()


func apply_poison(index: int, amount: float) -> void:
	StatusEffectService.apply_enemy(self, index, "poison", 5.2, max(0.15, amount), max(1, int(ceil(amount))))


func apply_enemy_status(index: int, effect_id: String, duration: float, potency: float = 1.0, stacks: int = 1) -> bool:
	return StatusEffectService.apply_enemy(self, index, effect_id, duration, potency, stacks)


func apply_boss_status(effect_id: String, duration: float, potency: float = 1.0, stacks: int = 1) -> bool:
	return StatusEffectService.apply_boss(self, effect_id, duration, potency, stacks)


func spread_poison(pos: Vector2, radius: float, stacks: float) -> void:
	for i in range(enemies.size()):
		if enemies[i]["pos"].distance_to(pos) <= radius:
			apply_poison(i, stacks)


func update_pickups(delta: float) -> void:
	for i in range(pickups.size() - 1, -1, -1):
		var p: Dictionary = pickups[i]
		p["life"] = float(p.get("life", 32.0)) - delta
		p["pos"] += p.get("vel", Vector2.ZERO) * delta
		p["vel"] = p.get("vel", Vector2.ZERO).move_toward(Vector2.ZERO, 160.0 * delta)
		var dist: float = p["pos"].distance_to(player["pos"])
		var magnet: float = (
			float(player["magnet"]) + (35.0 if reserve_heroes.has("liubei") else 0.0)
		)
		if str(p["kind"]) == "relic":
			magnet = max(magnet, 165.0)
		if dist < magnet or float(p["life"]) < 12.0 or pickups.size() > 82:
			var pull_speed: float = 180.0 + max(0.0, magnet - dist) * 2.0
			if float(p["life"]) < 12.0 or pickups.size() > 82:
				pull_speed = max(pull_speed, 420.0)
			p["pos"] = p["pos"].move_toward(player["pos"], pull_speed * delta)
		if float(p["life"]) <= 0.0 and str(p["kind"]) not in ["relic"]:
			if str(p["kind"]) == "xp":
				gain_xp(float(p["value"]))
			elif str(p["kind"]) == "coin":
				player["coins"] = int(player["coins"]) + int(p["value"])
			fast_remove_at(pickups, i)
			continue
		if p["pos"].distance_to(player["pos"]) < 22.0:
			match str(p["kind"]):
				"xp":
					gain_xp(float(p["value"]))
				"coin":
					player["coins"] = (
						int(player["coins"])
						+ int(
							round(
								(
									float(p["value"])
									* (
										1.20
										if has_relic("grainledger") and elapsed <= 60.0
										else 1.0
									)
								)
							)
						)
						+ (1 if has_relic("jade") else 0)
					)
				"heal":
					heal_player(float(p["value"]))
				"relic":
					grant_relic(str(p.get("id", "")), "拾取遺物")
			play_sfx("pickup", rng.randf_range(0.94, 1.12))
			fast_remove_at(pickups, i)
		else:
			pickups[i] = p


func gain_xp(value: float) -> void:
	var gained: float = (
		value
		* equipment_effect("xp_mult", 1.0)
		* difficulty_reward_mult()
		* (1.20 if has_relic("grainledger") and elapsed <= 60.0 else 1.0)
	)
	player["xp"] = float(player["xp"]) + gained
	while float(player["xp"]) >= float(player["xp_need"]):
		player["xp"] = float(player["xp"]) - float(player["xp_need"])
		player["level"] = int(player["level"]) + 1
		player["xp_need"] = 17.0 + int(player["level"]) * 9.0
		pending_levelups += 1
	if pending_levelups > 0 and screen == "game":
		open_levelup()


func update_zones(delta: float) -> void:
	for zone_index in range(zones.size() - 1, -1, -1):
		var zone: Dictionary = zones[zone_index]
		zone["life"] = float(zone["life"]) - delta
		if zone.has("tick"):
			zone["tick"] = float(zone["tick"]) - delta
		if zone["kind"] in ["fire", "poison", "frost", "lightning"] and float(zone["tick"]) <= 0.0:
			zone["tick"] = 0.45 if zone["kind"] != "lightning" else 0.75
			var radius_sq: float = float(zone["r"]) * float(zone["r"])
			var zone_candidates: Array = nearby_enemy_uids(zone["pos"])
			for uid_value in zone_candidates:
				var uid: int = int(uid_value)
				var enemy_index: int = int(enemy_uid_index.get(uid, -1))
				if enemy_index < 0 or enemy_index >= enemies.size():
					continue
				if enemies[enemy_index]["pos"].distance_squared_to(zone["pos"]) <= radius_sq:
					var live_index: int = damage_enemy(
						enemy_index, float(zone["damage"]), str(zone["kind"]), false
					)
					if live_index >= 0:
						if zone["kind"] == "poison":
							apply_poison(live_index, 0.5)
						elif zone["kind"] == "frost":
							enemies[live_index]["slow"] = max(
								float(enemies[live_index]["slow"]), 1.3
							)
			if not boss.is_empty():
				var boss_radius: float = float(zone["r"]) + float(boss["radius"])
				if boss["pos"].distance_squared_to(zone["pos"]) <= boss_radius * boss_radius:
					damage_boss(float(zone["damage"]), str(zone["kind"]), false)
		if zone["kind"] == "enemy_control_warning" and float(zone["life"]) <= 0.0:
			if player["pos"].distance_squared_to(zone["pos"]) <= float(zone["r"]) * float(zone["r"]):
				damage_player(float(zone["damage"]), "spell", float(zone.get("shield_pierce", 0.0)))
				var control_kind: String = str(zone.get("control", "slow"))
				if control_kind == "slow":
					player["move_slow"] = max(float(player.get("move_slow", 0.0)), 2.2)
				elif control_kind == "bind" and float(player.get("control_resist", 0.0)) <= 0.0:
					player["control_lock"] = max(float(player.get("control_lock", 0.0)), 0.45)
					player["control_resist"] = 3.0
				elif control_kind == "smoke":
					player["vision_obscure"] = max(float(player.get("vision_obscure", 0.0)), 3.0)
			spawn_ring(zone["pos"], zone.get("color", Color8(180, 120, 200)), float(zone["r"]), 0.40)
			fast_remove_at(zones, zone_index)
			continue
		if zone["kind"] == "enemy_warning" and float(zone["life"]) <= 0.0:
			if (
				player["pos"].distance_squared_to(zone["pos"])
				<= float(zone["r"]) * float(zone["r"])
			):
				damage_player(float(zone["damage"]), "boss", float(zone.get("shield_pierce", 0.0)))
			spawn_ring(zone["pos"], Color8(230, 83, 67), float(zone["r"]), 0.35)
			fast_remove_at(zones, zone_index)
			continue
		if float(zone["life"]) <= 0.0:
			fast_remove_at(zones, zone_index)
		else:
			zones[zone_index] = zone


func update_allies(delta: float) -> void:
	for i in range(allies.size() - 1, -1, -1):
		var a: Dictionary = allies[i]
		a["life"] = float(a["life"]) - delta
		a["hit_cd"] = max(0.0, float(a["hit_cd"]) - delta)
		if float(a["life"]) <= 0.0 or float(a["hp"]) <= 0.0:
			fast_remove_at(allies, i)
			continue
		var target: Vector2 = nearest_enemy_position(a["pos"])
		if target.x < 1.0e19:
			a["pos"] = a["pos"].move_toward(target, 145.0 * delta)
			if a["pos"].distance_to(target) < 27.0 and float(a["hit_cd"]) <= 0.0:
				a["hit_cd"] = 0.55
				var idx: int = nearest_enemy_index(a["pos"])
				if idx >= 0:
					var was_elite: bool = bool(enemies[idx]["elite"])
					var live_index: int = damage_enemy(idx, float(a["damage"]), "militia", false)
					if live_index >= 0 and active_bonds.has("benevolent_blade") and was_elite:
						enemies[live_index]["armor_break"] = 3.0
				elif (
					not boss.is_empty()
					and a["pos"].distance_to(boss["pos"]) < float(boss["radius"]) + 32.0
				):
					damage_boss(float(a["damage"]) * 0.85, "militia", false)
		allies[i] = a


func nearest_enemy_index(pos: Vector2) -> int:
	var idx: int = -1
	var dist: float = INF
	var candidate_uids: Array = nearby_enemy_uids(pos)
	if candidate_uids.is_empty():
		for i in range(enemies.size()):
			var fallback_distance: float = pos.distance_squared_to(enemies[i]["pos"])
			if fallback_distance < dist:
				dist = fallback_distance
				idx = i
		return idx
	for uid_value in candidate_uids:
		var uid: int = int(uid_value)
		var index: int = int(enemy_uid_index.get(uid, -1))
		if index < 0 or index >= enemies.size():
			continue
		var distance: float = pos.distance_squared_to(enemies[index]["pos"])
		if distance < dist:
			dist = distance
			idx = index
	return idx


func update_particles(delta: float) -> void:
	for i in range(particles.size() - 1, -1, -1):
		var p: Dictionary = particles[i]
		p["life"] = float(p["life"]) - delta
		p["pos"] += p["vel"] * delta
		p["vel"] *= pow(0.06, delta)
		if float(p["life"]) <= 0.0:
			fast_remove_at(particles, i)
		else:
			particles[i] = p
	for i in range(damage_numbers.size() - 1, -1, -1):
		var n: Dictionary = damage_numbers[i]
		n["life"] = float(n["life"]) - delta
		n["pos"] += Vector2(0, -32.0 * delta)
		if float(n["life"]) <= 0.0:
			fast_remove_at(damage_numbers, i)
		else:
			damage_numbers[i] = n


func spawn_sparks(pos: Vector2, color: Color, count: int) -> void:
	var particle_cap: int = max(70, int(float(MAX_PARTICLES) * effect_density()) - performance_level * 38)
	var requested: int = maxi(1, int(round(float(count) * effect_density())))
	var allowed: int = min(requested, max(0, particle_cap - particles.size()))
	if particles.size() > int(float(particle_cap) * 0.74):
		allowed = min(allowed, 2)
	for i in range(allowed):
		particles.append(
			{
				"pos": pos,
				"vel": Vector2.from_angle(rng.randf_range(0.0, TAU)) * rng.randf_range(45.0, 170.0),
				"life": rng.randf_range(0.22, 0.55),
				"max_life": 0.55,
				"color": color,
				"size": rng.randf_range(2.0, 5.0)
			}
		)


func spawn_ring(pos: Vector2, color: Color, radius: float, life: float) -> void:
	if not can_spawn_visual_zone():
		return
	zones.append(
		{
			"kind": "ring_visual",
			"pos": pos,
			"r": radius,
			"life": life,
			"max_life": life,
			"color": color
		}
	)


func show_message(text: String, duration := 2.5) -> void:
	game_message = text
	game_message_timer = duration


func default_history_modifiers() -> Dictionary:
	return {
		"spawn_interval_mult": 1.0,
		"max_enemies_delta": 0,
		"enemy_hp_mult": 1.0,
		"enemy_damage_mult": 1.0,
		"enemy_arrow_cap_delta": 0,
		"player_damage_mult": 1.0,
		"incoming_damage_mult": 1.0,
		"boss_hp_mult": 1.0,
		"boss_damage_mult": 1.0,
		"boss_speed_mult": 1.0,
		"camp_recovery_mult": 1.0
	}


func update_frame_metrics(delta: float) -> void:
	frame_time_ema = lerpf(frame_time_ema, delta, 0.035)
	frame_stats_timer += delta
	frame_peak_accum = max(frame_peak_accum, delta)
	if delta >= 0.022:
		frame_spikes_accum += 1
	if frame_stats_timer < 1.0:
		return
	frame_peak_last_ms = frame_peak_accum * 1000.0
	frame_spikes_last = frame_spikes_accum
	hit_stop_triggers_last = hit_stop_triggers_accum
	frame_stats_timer = fmod(frame_stats_timer, 1.0)
	frame_peak_accum = 0.0
	frame_spikes_accum = 0
	hit_stop_triggers_accum = 0


func request_hit_stop(duration: float) -> void:
	# 普通連射不再停止全場。只有暴擊、重擊與Boss招式可在節流後短暫停頓。
	if duration <= 0.0 or hit_stop_cooldown > 0.0:
		return
	hit_stop_timer = max(hit_stop_timer, duration)
	hit_stop_cooldown = 0.16
	hit_stop_triggers_accum += 1


func update_performance_guard(delta: float) -> void:
	performance_cleanup_timer -= delta
	if performance_cleanup_timer > 0.0:
		return
	performance_cleanup_timer = 0.65
	var frame_ms: float = frame_time_ema * 1000.0
	if frame_ms > 20.5:
		low_fps_timer += 0.65
		recovery_timer = 0.0
	elif frame_ms < 17.8:
		recovery_timer += 0.65
		low_fps_timer = max(0.0, low_fps_timer - 0.65)
	else:
		low_fps_timer = max(0.0, low_fps_timer - 0.25)
		recovery_timer = max(0.0, recovery_timer - 0.20)
	if low_fps_timer >= 2.6 and performance_level < 2:
		performance_level += 1
		low_fps_timer = 0.0
		show_message("效能保護已啟動：降低遠距AI與純視覺特效負載。", 2.8)
	elif recovery_timer >= 6.5 and performance_level > 0:
		performance_level -= 1
		recovery_timer = 0.0

	var particle_cap: int = max(70, int(float(MAX_PARTICLES) * effect_density()) - performance_level * 38)
	var number_cap: int = max(30, int(float(MAX_DAMAGE_NUMBERS) * effect_density()) - performance_level * 12)
	var shot_cap: int = MAX_PLAYER_SHOTS - performance_level * 30
	var pickup_cap: int = MAX_PICKUPS - performance_level * 22
	var zone_cap: int = max(28, int(float(MAX_ZONES) * effect_density()) - performance_level * 12)
	while particles.size() > particle_cap:
		fast_remove_at(particles, 0)
	while damage_numbers.size() > number_cap:
		fast_remove_at(damage_numbers, 0)
	while player_shots.size() > shot_cap:
		fast_remove_at(player_shots, 0)
	while allies.size() > MAX_ALLIES:
		fast_remove_at(allies, 0)
	if zones.size() > zone_cap:
		for i in range(zones.size() - 1, -1, -1):
			if zones.size() <= zone_cap:
				break
			if str(zones[i].get("kind", "")) in ["ring_visual", "telegraph_circle", "telegraph_line", "telegraph_sector", "impact_visual", "slash_visual", "shockwave_visual", "hero_effect", "hero_line_visual", "hero_arrow_visual"]:
				fast_remove_at(zones, i)
		while zones.size() > zone_cap:
			fast_remove_at(zones, 0)
	if pickups.size() > pickup_cap:
		for i in range(pickups.size() - 1, -1, -1):
			if pickups.size() <= pickup_cap:
				break
			var pickup: Dictionary = pickups[i]
			match str(pickup.get("kind", "")):
				"xp":
					gain_xp(float(pickup.get("value", 0.0)))
					fast_remove_at(pickups, i)
				"coin":
					player["coins"] = int(player.get("coins", 0)) + int(pickup.get("value", 0))
					fast_remove_at(pickups, i)
				"heal":
					heal_player(float(pickup.get("value", 0.0)) * 0.5)
					fast_remove_at(pickups, i)
	var load_ratio: float = max(
		float(pickups.size()) / float(max(1, pickup_cap)),
		float(particles.size()) / float(max(1, particle_cap)),
		float(zones.size()) / float(max(1, zone_cap)),
		float(player_shots.size()) / float(max(1, shot_cap))
	)
	if performance_level >= 2 or load_ratio > 0.84:
		performance_pressure = "偏高"
	elif performance_level == 1 or load_ratio > 0.64:
		performance_pressure = "注意"
	else:
		performance_pressure = "穩定"


func chapter_history_event_definitions() -> Array:
	var chapter_id: String = chapter_manager.current_id()
	var value: Variant = history_event_defs.get(chapter_id, [])
	if value is Array:
		return (value as Array).duplicate(true)
	if value is Dictionary:
		return [(value as Dictionary).duplicate(true)]
	return []


func has_known_hero(hid: String) -> bool:
	return known_heroes.has(hid) or active_heroes.has(hid) or reserve_heroes.has(hid) or camp_heroes.has(hid)


func history_option_available(option: Dictionary) -> bool:
	if int(option.get("cost", 0)) > int(player.get("coins", 0)):
		return false
	var all_heroes: Array = option.get("requires_all_heroes", [])
	for hid in all_heroes:
		if not active_heroes.has(str(hid)):
			return false
	var all_bonds: Array = option.get("requires_all_bonds", [])
	for bid in all_bonds:
		if not active_bonds.has(str(bid)):
			return false
	var any_heroes: Array = option.get("requires_any_heroes", [])
	var any_bonds: Array = option.get("requires_any_bonds", [])
	if not any_heroes.is_empty() or not any_bonds.is_empty():
		var matched: bool = false
		for hid in any_heroes:
			if active_heroes.has(str(hid)):
				matched = true
		for bid in any_bonds:
			if active_bonds.has(str(bid)):
				matched = true
		if not matched:
			return false
	return true


func history_option_lock_reason(option: Dictionary) -> String:
	if int(option.get("cost", 0)) > int(player.get("coins", 0)):
		return "銅錢不足"
	for hid_value in option.get("requires_all_heroes", []):
		var hid: String = str(hid_value)
		if reserve_heroes.has(hid):
			return "%s目前在後備，需調為主動" % str(heroes.get(hid, {}).get("name", hid))
		if not active_heroes.has(hid):
			return "需要主動名將：%s" % str(heroes.get(hid, {}).get("name", hid))
	for bid_value in option.get("requires_all_bonds", []):
		var bid: String = str(bid_value)
		if not active_bonds.has(bid):
			return "需要啟動羈絆：%s" % str(bond_defs.get(bid, {}).get("name", bid))
	var any_heroes: Array = option.get("requires_any_heroes", [])
	var any_bonds: Array = option.get("requires_any_bonds", [])
	if not any_heroes.is_empty() or not any_bonds.is_empty():
		var reserve_names: Array[String] = []
		for hid_value in any_heroes:
			var hid: String = str(hid_value)
			if active_heroes.has(hid):
				return ""
			if reserve_heroes.has(hid):
				reserve_names.append(str(heroes.get(hid, {}).get("name", hid)))
		for bid_value in any_bonds:
			if active_bonds.has(str(bid_value)):
				return ""
		if not reserve_names.is_empty():
			return "%s在後備，特殊選項不可用" % "／".join(reserve_names)
		return "目前主動名將／羈絆不符"
	return ""

func spawn_history_event_if_ready() -> void:
	if history_event_active or not current_history_event.is_empty():
		return
	var chapter_id: String = chapter_manager.current_id()
	var definitions: Array = chapter_history_event_definitions()
	if definitions.is_empty():
		return
	var selected_event: Dictionary = {}
	for value in definitions:
		if not (value is Dictionary):
			continue
		var event_def: Dictionary = value
		var event_id: String = str(event_def.get("id", ""))
		if event_id == "" or bool(history_event_done.get(event_id, false)):
			continue
		if elapsed >= float(event_def.get("time", 9999.0)):
			selected_event = event_def.duplicate(true)
			break
	if selected_event.is_empty():
		return
	history_event_active = true
	current_history_event = selected_event
	history_event_pos = player["pos"] + Vector2.from_angle(rng.randf_range(0.0, TAU)) * 285.0
	history_event_pos.x = clamp(history_event_pos.x, 90.0, WORLD.size.x - 90.0)
	history_event_pos.y = clamp(history_event_pos.y, 90.0, WORLD.size.y - 90.0)
	history_event_cursor[chapter_id] = int(history_event_cursor.get(chapter_id, 0)) + 1
	show_message("史勢奇遇：%s" % str(selected_event.get("title", "亂世抉擇")), 3.8)


func open_history_event() -> void:
	if not history_event_active or current_history_event.is_empty():
		return
	history_event_options = (current_history_event.get("options", []) as Array).duplicate(true)
	history_event_index = 0
	history_event_phase = "choice"
	history_result_title = ""
	history_result_detail = ""
	screen = "history_event"
	play_bgm("event")
	play_sfx("ui_confirm", 0.9)


func handle_chapter_intro_key(key: int) -> void:
	var max_page: int = 2
	if key == KEY_ESCAPE:
		screen = chapter_intro_return_screen
		play_current_battle_bgm()
		return
	if is_left_key(key) or is_up_key(key):
		chapter_intro_page = maxi(0, chapter_intro_page - 1)
		play_sfx("ui_move")
	elif is_right_key(key) or is_down_key(key):
		chapter_intro_page = mini(max_page, chapter_intro_page + 1)
		play_sfx("ui_move")
	elif is_confirm_key(key):
		if chapter_intro_page < max_page:
			chapter_intro_page += 1
			play_sfx("ui_confirm", 0.92)
		else:
			screen = chapter_intro_return_screen
			play_current_battle_bgm()


func handle_history_event_key(key: int) -> void:
	if history_event_phase == "result":
		if is_confirm_key(key) or key == KEY_ESCAPE:
			finish_history_event_result()
		return
	if history_event_options.is_empty():
		screen = "game"
		return
	if is_up_key(key) or is_left_key(key):
		history_event_index = wrapi(history_event_index - 1, 0, history_event_options.size())
		play_sfx("ui_move")
	elif is_down_key(key) or is_right_key(key):
		history_event_index = wrapi(history_event_index + 1, 0, history_event_options.size())
		play_sfx("ui_move")
	elif key == KEY_ESCAPE:
		screen = "game"
		play_sfx("ui_move")
	elif is_confirm_key(key):
		var option: Dictionary = history_event_options[history_event_index]
		if not history_option_available(option):
			show_message("條件不足：需要特定名將／羈絆或足夠銅錢。", 2.2)
			play_sfx("ui_move", 0.72)
			return
		apply_history_choice(option)


func apply_history_route_impact(effect: String) -> void:
	var result: Dictionary = HistoryRouteRules.apply_impact(
		faction_momentum, history_rewrite_rate, history_route_tags, effect
	)
	faction_momentum = (result.get("momentum", faction_momentum) as Dictionary).duplicate(true)
	history_rewrite_rate = float(result.get("rewrite_rate", history_rewrite_rate))
	history_route_tags = (result.get("route_tags", history_route_tags) as Dictionary).duplicate(true)


func history_route_summary() -> String:
	return HistoryRouteRules.route_summary(faction_momentum, history_rewrite_rate)


func record_history_choice(flag: String, text: String) -> void:
	if flag != "":
		history_flags[flag] = true
	var chapter_name: String = str(current_chapter().get("title", "章回"))
	var line: String = "%s：%s" % [chapter_name, text]
	history_log.append(line)
	run_stats["history_choices"] = int(run_stats.get("history_choices", 0)) + 1


func apply_history_choice(option: Dictionary) -> void:
	var effect: String = str(option.get("effect", ""))
	var cost: int = int(option.get("cost", 0))
	player["coins"] = max(0, int(player.get("coins", 0)) - cost)
	var summary: String = str(option.get("text", "完成抉擇"))
	match effect:
		"zhuo_relief":
			history_modifiers["spawn_interval_mult"] = (
				float(history_modifiers["spawn_interval_mult"]) * 1.10
			)
			history_modifiers["boss_damage_mult"] = (
				float(history_modifiers["boss_damage_mult"]) * 0.96
			)
			record_history_choice("zhuo_relief", "分糧濟民，涿郡民心歸附。")
		"zhuo_militia":
			player["shield"] = float(player["shield"]) + 14.0
			for i in range(3):
				allies.append(
					{
						"pos": player["pos"] + Vector2.from_angle(float(i) / 3.0 * TAU) * 42.0,
						"hp": 34.0,
						"life": 18.0,
						"damage": 11.0,
						"hit_cd": 0.0,
						"anim": 0.0
					}
				)
			history_modifiers["enemy_damage_mult"] = (
				float(history_modifiers["enemy_damage_mult"]) * 1.03
			)
			record_history_choice("zhuo_militia", "徵集鄉勇守村，黃巾軍提高警戒。")
		"zhuo_mercy":
			player["max_hp"] = float(player["max_hp"]) + 6.0
			heal_player(28.0)
			player["shield"] = float(player["shield"]) + 10.0
			history_modifiers["camp_recovery_mult"] = (
				float(history_modifiers["camp_recovery_mult"]) * 1.10
			)
			record_history_choice("benevolent_mercy", "義診安民，仁心濟世之名流傳。")
		"luoyang_rescue":
			player["shield"] = float(player["shield"]) + 16.0
			history_modifiers["boss_hp_mult"] = float(history_modifiers["boss_hp_mult"]) * 0.94
			record_history_choice("luoyang_rescue", "護送宮人出城，取得西涼軍情。")
		"luoyang_treasure":
			player["coins"] = int(player["coins"]) + 24
			grant_random_relic("洛陽軍庫")
			history_modifiers["boss_damage_mult"] = (
				float(history_modifiers["boss_damage_mult"]) * 1.07
			)
			record_history_choice("luoyang_treasure", "轉入軍庫取資，驚動西涼守軍。")
		"luoyang_melody":
			for hid in active_heroes:
				hero_cooldowns[hid] = max(0.0, float(hero_cooldowns.get(hid, 0.0)) - 5.0)
			history_modifiers["boss_hp_mult"] = float(history_modifiers["boss_hp_mult"]) * 0.92
			record_history_choice("melody_escape", "胡笳清音引開追兵，眾人由密道脫身。")
		"hulao_vanguard":
			history_modifiers["player_damage_mult"] = (
				float(history_modifiers["player_damage_mult"]) * 1.10
			)
			history_modifiers["incoming_damage_mult"] = (
				float(history_modifiers["incoming_damage_mult"]) * 1.06
			)
			record_history_choice("hulao_vanguard", "請命先鋒，以戰功壓過諸侯。")
		"hulao_flank":
			player["shield"] = float(player["shield"]) + 24.0
			history_modifiers["enemy_arrow_cap_delta"] = (
				int(history_modifiers["enemy_arrow_cap_delta"]) - 3
			)
			record_history_choice("hulao_flank", "守住盟軍側翼，弓弩威脅下降。")
		"hulao_three_heroes":
			history_modifiers["boss_hp_mult"] = float(history_modifiers["boss_hp_mult"]) * 0.90
			history_modifiers["boss_speed_mult"] = (
				float(history_modifiers["boss_speed_mult"]) * 0.96
			)
			record_history_choice("three_heroes_challenge", "劉關張三英請戰，直面飛將。")
		"xuzhou_people":
			heal_player(25.0)
			history_modifiers["spawn_interval_mult"] = (
				float(history_modifiers["spawn_interval_mult"]) * 1.08
			)
			record_history_choice("xuzhou_people", "先護百姓入城，徐州人心相助。")
		"xuzhou_grain":
			player["coins"] = int(player["coins"]) + 26
			history_modifiers["player_damage_mult"] = (
				float(history_modifiers["player_damage_mult"]) * 1.07
			)
			history_modifiers["max_enemies_delta"] = int(history_modifiers["max_enemies_delta"]) + 3
			record_history_choice("xuzhou_grain", "保住軍糧，陷陣營增兵來奪。")
		"xuzhou_benevolent_route":
			player["max_hp"] = float(player["max_hp"]) + 8.0
			heal_player(32.0)
			history_modifiers["camp_recovery_mult"] = (
				float(history_modifiers["camp_recovery_mult"]) * 1.20
			)
			history_modifiers["boss_damage_mult"] = (
				float(history_modifiers["boss_damage_mult"]) * 0.95
			)
			record_history_choice("xuzhou_benevolent", "仁醫分路，百姓與部分糧車皆得保全。")
		"guandu_raid":
			history_modifiers["boss_hp_mult"] = float(history_modifiers["boss_hp_mult"]) * 0.84
			history_modifiers["enemy_hp_mult"] = float(history_modifiers["enemy_hp_mult"]) * 1.04
			record_history_choice("wuchao_raid", "冒險奇襲烏巢，袁軍糧秣大亂。")
		"guandu_supply":
			grant_random_relic("固守官渡糧道")
			player["shield"] = float(player["shield"]) + 22.0
			record_history_choice("guandu_supply", "固守糧道，以穩制勝。")
		"guandu_caocao":
			history_modifiers["boss_hp_mult"] = float(history_modifiers["boss_hp_mult"]) * 0.74
			history_modifiers["max_enemies_delta"] = int(history_modifiers["max_enemies_delta"]) - 4
			history_modifiers["spawn_interval_mult"] = (
				float(history_modifiers["spawn_interval_mult"]) * 1.06
			)
			record_history_choice("caocao_wuchao", "孟德決斷奇襲烏巢，河北軍勢崩解。")
		"zhuo_wine":
			for hid in active_heroes:
				hero_cooldowns[hid] = max(0.0, float(hero_cooldowns.get(hid, 0.0)) - 4.5)
			temporary_attack_speed = max(temporary_attack_speed, 6.0)
			record_history_choice("zhuo_wine", "以酒犒軍，義勇軍士氣大振。")
		"zhuo_store":
			player["shield"] = float(player["shield"]) + 12.0
			history_modifiers["camp_recovery_mult"] = float(history_modifiers["camp_recovery_mult"]) * 1.18
			record_history_choice("zhuo_store", "封存糧酒備荒，鄉里得以喘息。")
		"zhuo_oath":
			grant_relic("warbanner", "同心立誓")
			history_modifiers["boss_hp_mult"] = float(history_modifiers["boss_hp_mult"]) * 0.94
			record_history_choice("zhuo_oath", "桃園同心立誓，義軍旗幟高揚。")
		"luoyang_guard_emperor":
			history_modifiers["enemy_damage_mult"] = float(history_modifiers["enemy_damage_mult"]) * 0.94
			history_modifiers["max_enemies_delta"] = int(history_modifiers["max_enemies_delta"]) + 2
			record_history_choice("guard_deposed_emperor", "暗護車駕，西涼追兵沿街搜捕。")
		"luoyang_false_order":
			history_modifiers["spawn_interval_mult"] = float(history_modifiers["spawn_interval_mult"]) * 1.10
			history_modifiers["boss_speed_mult"] = float(history_modifiers["boss_speed_mult"]) * 1.04
			record_history_choice("false_xiliang_order", "散布假軍令，洛陽守軍一度混亂。")
		"luoyang_diaochan_decoy":
			grant_random_relic("閉月調虎")
			history_modifiers["boss_hp_mult"] = float(history_modifiers["boss_hp_mult"]) * 0.90
			record_history_choice("diaochan_decoy", "貂蟬引開西涼主力，密道得以保全。")
		"hulao_raise_banner":
			for hid in active_heroes:
				hero_cooldowns[hid] = max(0.0, float(hero_cooldowns.get(hid, 0.0)) - 3.0)
			history_modifiers["max_enemies_delta"] = int(history_modifiers["max_enemies_delta"]) + 3
			record_history_choice("raise_coalition_banner", "盟軍舊旗重立，士氣與敵意同時高漲。")
		"hulao_banner_armor":
			player["shield"] = float(player["shield"]) + 26.0
			history_modifiers["boss_damage_mult"] = float(history_modifiers["boss_damage_mult"]) * 0.94
			record_history_choice("banner_armor", "拆旗製甲，前線士卒得以抵擋重擊。")
		"hulao_sunjian_banner":
			history_modifiers["boss_hp_mult"] = float(history_modifiers["boss_hp_mult"]) * 0.92
			history_modifiers["player_damage_mult"] = float(history_modifiers["player_damage_mult"]) * 1.05
			record_history_choice("sunjian_reclaims_banner", "江東猛虎奪回軍旗，盟軍聲勢大振。")
		"xuzhou_truce":
			history_modifiers["spawn_interval_mult"] = float(history_modifiers["spawn_interval_mult"]) * 1.14
			record_history_choice("xuzhou_truce", "轅門射戟止住混戰，兩軍暫時退兵。")
		"xuzhou_seize_arms":
			player["coins"] = int(player["coins"]) + 22
			history_modifiers["player_damage_mult"] = float(history_modifiers["player_damage_mult"]) * 1.06
			history_modifiers["max_enemies_delta"] = int(history_modifiers["max_enemies_delta"]) + 3
			record_history_choice("xuzhou_seize_arms", "趁亂奪械，陷陣營隨即增兵。")
		"xuzhou_lv_family":
			history_modifiers["boss_speed_mult"] = float(history_modifiers["boss_speed_mult"]) * 0.91
			history_modifiers["max_enemies_delta"] = int(history_modifiers["max_enemies_delta"]) - 3
			record_history_choice("lv_family_appeal", "飛將舊情使陷陣營軍心動搖。")
		"guandu_accept_intel":
			history_modifiers["boss_hp_mult"] = float(history_modifiers["boss_hp_mult"]) * 0.88
			history_modifiers["enemy_damage_mult"] = float(history_modifiers["enemy_damage_mult"]) * 1.05
			record_history_choice("accept_xuyou_intel", "立即採納故人密報，決戰提前爆發。")
		"guandu_verify_intel":
			history_modifiers["max_enemies_delta"] = int(history_modifiers["max_enemies_delta"]) - 3
			history_modifiers["boss_hp_mult"] = float(history_modifiers["boss_hp_mult"]) * 0.96
			record_history_choice("verify_xuyou_intel", "反覆核驗軍情，避開袁軍伏兵。")
		"guandu_trust_talent":
			grant_random_relic("識人用人")
			history_modifiers["max_enemies_delta"] = int(history_modifiers["max_enemies_delta"]) - 5
			history_modifiers["boss_hp_mult"] = float(history_modifiers["boss_hp_mult"]) * 0.82
			record_history_choice("trust_talent", "曹操與文姬辨明情報，河北軍勢被看穿。")
		"jingzhou_share_grain":
			heal_player(24.0)
			history_modifiers["spawn_interval_mult"] = float(history_modifiers["spawn_interval_mult"]) * 1.09
			record_history_choice("jingzhou_share_grain", "分糧安民，新野撤離秩序稍定。")
		"jingzhou_burn_grain":
			history_modifiers["boss_hp_mult"] = float(history_modifiers["boss_hp_mult"]) * 0.88
			history_modifiers["max_enemies_delta"] = int(history_modifiers["max_enemies_delta"]) + 3
			record_history_choice("jingzhou_burn_grain", "焚倉設伏，曹軍追擊受阻但策士加強搜捕。")
		"jingzhou_benevolent_convoy":
			player["max_hp"] = float(player["max_hp"]) + 8.0
			heal_player(32.0)
			player["shield"] = float(player["shield"]) + 18.0
			record_history_choice("jingzhou_benevolent_convoy", "仁德安民，百姓車隊得以整編南撤。")
		"jingzhou_people_first":
			history_modifiers["enemy_damage_mult"] = float(history_modifiers["enemy_damage_mult"]) * 0.94
			history_modifiers["max_enemies_delta"] = int(history_modifiers["max_enemies_delta"]) + 2
			record_history_choice("jingzhou_people_first", "先送百姓渡河，曹軍精銳提前趕至。")
		"jingzhou_arms_first":
			history_modifiers["player_damage_mult"] = float(history_modifiers["player_damage_mult"]) * 1.07
			player["pierce"] = int(player.get("pierce", 0)) + 1
			history_modifiers["boss_speed_mult"] = float(history_modifiers["boss_speed_mult"]) * 1.04
			record_history_choice("jingzhou_arms_first", "軍械先渡，撤軍火力提升。")
		"jingzhou_wu_route":
			grant_random_relic("江東水路")
			history_modifiers["boss_hp_mult"] = float(history_modifiers["boss_hp_mult"]) * 0.91
			history_modifiers["boss_damage_mult"] = float(history_modifiers["boss_damage_mult"]) * 0.94
			record_history_choice("jingzhou_wu_route", "江東船工開闢支流，蔡瑁水軍部署被擾亂。")
		"changban_rescue_wounded":
			player["shield"] = float(player["shield"]) + 22.0
			for i in range(3):
				allies.append({"pos":player["pos"] + Vector2.from_angle(float(i) / 3.0 * TAU) * 44.0, "hp":38.0, "life":22.0, "damage":12.0, "hit_cd":0.0, "anim":0.0})
			history_modifiers["max_enemies_delta"] = int(history_modifiers["max_enemies_delta"]) + 2
			record_history_choice("changban_rescue_wounded", "回頭救下傷兵，護衛加入斷後。")
		"changban_breakthrough":
			temporary_speed = max(temporary_speed, 18.0)
			history_modifiers["player_damage_mult"] = float(history_modifiers["player_damage_mult"]) * 1.08
			history_modifiers["incoming_damage_mult"] = float(history_modifiers["incoming_damage_mult"]) * 1.05
			record_history_choice("changban_breakthrough", "集中兵力破陣，撤離速度加快。")
		"changban_taoyuan_rescue":
			history_modifiers["max_enemies_delta"] = int(history_modifiers["max_enemies_delta"]) - 4
			history_modifiers["camp_recovery_mult"] = float(history_modifiers["camp_recovery_mult"]) * 1.20
			record_history_choice("changban_taoyuan_rescue", "桃園同心分路接應，百姓得以續行。")
		"changban_hold_bridge":
			history_modifiers["boss_damage_mult"] = float(history_modifiers["boss_damage_mult"]) * 0.92
			history_modifiers["max_enemies_delta"] = int(history_modifiers["max_enemies_delta"]) + 3
			record_history_choice("changban_hold_bridge", "列陣守橋，追兵攻勢被迫放緩。")
		"changban_break_bridge":
			history_modifiers["boss_speed_mult"] = float(history_modifiers["boss_speed_mult"]) * 0.90
			history_modifiers["camp_recovery_mult"] = float(history_modifiers["camp_recovery_mult"]) * 0.85
			record_history_choice("changban_break_bridge", "拆橋阻敵，部分補給也被留在彼岸。")
		"changban_zhangfei_bridge":
			history_modifiers["boss_hp_mult"] = float(history_modifiers["boss_hp_mult"]) * 0.80
			history_modifiers["boss_speed_mult"] = float(history_modifiers["boss_speed_mult"]) * 0.94
			record_history_choice("changban_zhangfei_bridge", "燕人獨守橋頭，曹軍追兵為之一滯。")
		_:
			record_history_choice(effect, summary)
	apply_history_route_impact(effect)
	var event_id: String = str(current_history_event.get("id", ""))
	if event_id != "":
		history_event_done[event_id] = true
	history_event_active = false
	history_event_pos = Vector2.ZERO
	history_event_phase = "result"
	history_result_title = "史勢已改變・%s" % summary
	history_result_detail = (history_log[-1] if not history_log.is_empty() else str(option.get("detail", "你的選擇改變了此章戰局。"))) + "\n" + history_route_summary()
	play_sfx("hero", 1.05)
	spawn_ring(player["pos"], Color8(235, 199, 116), 110.0, 0.72)


func finish_history_event_result() -> void:
	current_history_event.clear()
	history_event_options.clear()
	history_event_phase = "choice"
	screen = "game"
	play_current_battle_bgm()
	show_message(history_result_title, 3.4)
	history_result_title = ""
	history_result_detail = ""
	play_sfx("ui_confirm", 0.95)


func history_event_focus_id() -> String:
	for option in history_event_options:
		for key in ["requires_all_heroes", "requires_any_heroes"]:
			var ids: Array = option.get(key, []) as Array
			if not ids.is_empty() and portrait_tex.has(str(ids[0])):
				return str(ids[0])
	var boss_def: Dictionary = chapter_manager.boss_definition()
	return str(boss_def.get("id", ""))


func draw_history_event_screen() -> void:
	draw_overlay_backdrop()
	var panel: Rect2 = Rect2(92, 58, 1096, 606)
	draw_panel(panel, Color(0.038, 0.04, 0.035, 0.99), Color8(190, 151, 81), 2.5)
	var focus_id: String = history_event_focus_id()
	var portrait_rect: Rect2 = Rect2(116, 92, 310, 500)
	draw_panel(portrait_rect, Color(0.025, 0.029, 0.028, 0.96), Color8(98, 88, 65), 1.0)
	if focus_id != "" and portrait_tex.has(focus_id):
		draw_texture_contain(hero_portrait(str(focus_id)), portrait_rect.grow(-10.0))
	else:
		draw_centered_text("奇遇", portrait_rect, 260.0, 31, Color8(216, 188, 119), true)
	var right: Rect2 = Rect2(458, 88, 685, 510)
	draw_text("史勢奇遇", right.position + Vector2(0, 34), 27, Color8(241, 211, 145), true)
	draw_text(str(current_history_event.get("title", "亂世抉擇")), right.position + Vector2(0, 73), 23, Color8(236, 224, 190), true, HORIZONTAL_ALIGNMENT_LEFT, 650)
	if history_event_phase == "result":
		draw_panel(Rect2(right.position + Vector2(0, 112), Vector2(650, 300)), Color(0.10, 0.085, 0.045, 0.96), Color8(224, 184, 91), 2.0)
		draw_text(history_result_title, right.position + Vector2(28, 165), 25, Color8(244, 218, 151), true, HORIZONTAL_ALIGNMENT_LEFT, 590)
		draw_wrapped(history_result_detail, Rect2(right.position + Vector2(28, 185), Vector2(590, 120)), 19, Color8(220, 222, 207), 30.0, true)
		draw_text("這項選擇已寫入本局史勢，後續敵軍、Boss或資源可能受到影響。", right.position + Vector2(28, 355), 15, Color8(177, 202, 181), false, HORIZONTAL_ALIGNMENT_LEFT, 590)
		draw_text("Enter／Space返回戰場", Vector2(800, 620), 15, Color8(210, 195, 157), true, HORIZONTAL_ALIGNMENT_CENTER, 600)
		return
	draw_wrapped(str(current_history_event.get("text", "")), Rect2(right.position + Vector2(0, 92), Vector2(650, 76)), 17, Color8(209, 213, 202), 26.0, true)
	for i in range(history_event_options.size()):
		var option: Dictionary = history_event_options[i]
		var available: bool = history_option_available(option)
		var rect: Rect2 = Rect2(right.position + Vector2(0, 180 + i * 104), Vector2(650, 88))
		var selected: bool = i == history_event_index
		draw_panel(rect, Color(0.22, 0.16, 0.07, 0.93) if selected else Color(0.06, 0.065, 0.06, 0.94), Color8(235, 198, 111) if available else Color8(105, 103, 93), 2.0 if selected else 1.0)
		var title_color: Color = Color8(241, 222, 174) if available else Color8(125, 126, 119)
		draw_text(("▶ " if selected else "　") + str(option.get("text", "選擇")), rect.position + Vector2(18, 28), 18, title_color, true)
		var detail_text: String = str(option.get("detail", ""))
		if not available:
			var lock_reason: String = history_option_lock_reason(option)
			if lock_reason != "":
				detail_text += "　[條件：" + lock_reason + "]"
		draw_wrapped(detail_text, Rect2(rect.position + Vector2(34, 39), Vector2(590, 38)), 13, Color8(188, 197, 188) if available else Color8(106, 109, 104), 19.0)
	draw_text("方向鍵選擇　Enter／Space確認　Esc稍後再決定", Vector2(800, 632), 14, Color8(186, 193, 184), false, HORIZONTAL_ALIGNMENT_CENTER, 650)


# -----------------------------------------------------------------------------
# 名將、事件、商人、羈絆與Boss
# -----------------------------------------------------------------------------


func has_relic(id: String) -> bool:
	return relics.has(id)


func relic_level(id: String) -> int:
	return int(relic_levels.get(id, 1 if relics.has(id) else 0))


func relic_stat(stat_id: String, default_value: float = 0.0) -> float:
	var total: float = default_value
	for rid_value in relics:
		var rid: String = str(rid_value)
		var rdef: Dictionary = relic_defs.get(rid, {})
		var per_level: float = float(rdef.get(stat_id, 0.0))
		if per_level != 0.0:
			total += per_level * float(relic_level(rid))
	return total


func skill_level(id: String) -> int:
	return int(skill_levels.get(id, 0))


func hero_skill_level(hid: String) -> int:
	return clampi(int(hero_skill_levels.get(hid, 1)), 1, 8)


func hero_bond_level(hid: String) -> int:
	return clampi(int(hero_bond_levels.get(hid, hero_levels.get(hid, 1))), 1, 5)


func initial_hero_skill_level(_hid: String) -> int:
	var chapter_number: int = int(current_chapter().get("index", 0)) + 1
	var active_levels: Array[int] = []
	for active_id_value in active_heroes:
		active_levels.append(hero_skill_level(str(active_id_value)))
	return HeroProgressionRules.initial_skill_level(chapter_number, active_levels)


func initial_hero_bond_level() -> int:
	var chapter_number: int = int(current_chapter().get("index", 0)) + 1
	return HeroProgressionRules.initial_bond_level(chapter_number)


func initialize_hero_progress(hid: String) -> void:
	if not hero_skill_levels.has(hid):
		hero_skill_levels[hid] = initial_hero_skill_level(hid)
	if not hero_bond_levels.has(hid):
		hero_bond_levels[hid] = initial_hero_bond_level()
	hero_levels[hid] = int(hero_bond_levels[hid])
	departed_heroes.erase(hid)


func improve_hero_skill(hid: String, amount: int = 1) -> bool:
	initialize_hero_progress(hid)
	var old_level: int = hero_skill_level(hid)
	var new_level: int = clampi(old_level + amount, 1, 8)
	hero_skill_levels[hid] = new_level
	if new_level == old_level:
		return false
	hero_cooldowns[hid] = 0.0
	show_message("%s技能提升：Lv.%d → Lv.%d" % [heroes[hid]["name"], old_level, new_level], 3.0)
	return true


func improve_hero_bond(hid: String, amount: int = 1) -> bool:
	initialize_hero_progress(hid)
	var old_level: int = hero_bond_level(hid)
	var new_level: int = clampi(old_level + amount, 1, 5)
	hero_bond_levels[hid] = new_level
	hero_levels[hid] = new_level
	if new_level == old_level:
		return false
	show_message("%s羈絆提升：Lv.%d → Lv.%d" % [heroes[hid]["name"], old_level, new_level], 3.0)
	update_bonds()
	return true


func passive_level(id: String) -> int:
	if not reserve_heroes.has(id):
		return 0
	return hero_bond_level(id)


func trigger_relic(id: String, text: String) -> void:
	run_stats["relic_triggers"][id] = int(run_stats["relic_triggers"].get(id, 0)) + 1
	show_message("%s Lv.%d：%s" % [relic_defs[id]["name"], relic_level(id), text], 2.0)
	play_sfx("hero", 1.2)


func update_hero_cooldowns(delta: float) -> void:
	for hid in hero_cooldowns.keys():
		hero_cooldowns[hid] = max(0.0, float(hero_cooldowns[hid]) - delta)
	auto_hero_cast_delay = max(0.0, auto_hero_cast_delay - delta)
	# 自動施放保留短暫間隔，避免多名武將同一幀把畫面塞滿。
	if screen != "game" or not combat_target_available() or auto_hero_cast_delay > 0.0:
		return
	for hid in active_heroes:
		if float(hero_cooldowns.get(hid, 0.0)) <= 0.0:
			try_trigger_hero(hid, false)
			auto_hero_cast_delay = 0.42
			break


func hero_cooldown_value(hid: String) -> float:
	var cd: float = float(heroes[hid]["cooldown"])
	# alpha.4：知名名將以較短冷卻呈現直觀強度；小眾名將保留正常循環，改以特殊機制取勝。
	cd *= float(heroes.get(hid, {}).get("cooldown_mult", 1.0))
	cd *= float(player.get("hero_cd_mult", 1.0))
	cd *= build_hero_cooldown_multiplier()
	cd *= max(0.76, 1.0 - 0.035 * float(hero_skill_level(hid) - 1))
	if has_relic("warbanner"):
		cd *= max(0.72, 1.0 - 0.10 * relic_level("warbanner"))
	if (
		has_relic("moonbell")
		and (
			hid
			in ["diaochan", "sunshangxiang", "zhenji", "lvlingqi", "wangyi", "caiwenji", "daqiao"]
		)
	):
		cd *= max(0.70, 1.0 - 0.12 * relic_level("moonbell"))
	return max(4.0, cd)


func try_trigger_hero(hid: String, manual: bool) -> void:
	if not active_heroes.has(hid) or float(hero_cooldowns.get(hid, 0.0)) > 0.0:
		if manual:
			play_sfx("ui_move", 0.75)
		return
	var lv: int = hero_skill_level(hid)
	var center: Vector2 = player["pos"]
	var target: Vector2 = nearest_enemy_position(center)
	if target.x > 1000000.0:
		target = center + Vector2.RIGHT
	var dir: Vector2 = (target - center).normalized()
	if dir.length_squared() < 0.01:
		dir = Vector2.RIGHT
	# Alpha.58：成功施放任何主將技能都先建立統一 cast flash。
	# 專屬技能視覺仍可使用 hero_line_visual / hero_arrow_visual 等自己的形態，
	# 不再依賴通用 spawn_hero_signature_effect() 才能顯示頭上喊招與施放姿態。
	var cast_duration: float = Alpha27ActionProfiles.hero_cast_duration(hid)
	hero_cast_flash = {
		"id": hid,
		"life": cast_duration,
		"max_life": cast_duration,
		"pos": center,
	}
	match hid:
		"liubei":
			var count: int = 3 + (1 if lv >= 3 else 0)
			for i in range(count):
				var a: float = (float(i) - (count - 1) * 0.5) * 0.34
				allies.append(
					{
						"pos": center + dir.rotated(a) * 42.0,
						"hp": 28.0 + lv * 7.0,
						"life": 13.0 + lv * 1.2,
						"damage": 9.0 + lv * 2.5,
						"hit_cd": 0.0,
						"anim": 0.0
					}
				)
			spawn_ring(center, Color8(229, 204, 128), 125.0, 0.55)
			show_message("劉備・義勇同心", 1.5)
		"guanyu":
			play_sfx("slash", 0.78)
			damage_arc(center, dir.angle(), 285.0 + lv * 12.0, 2.10, 42.0 + lv * 8.0, 410.0)
			# 可視的大月牙刀氣。
			for a in [-0.18, 0.0, 0.18]:
				spawn_player_projectile(
					"blade_wave", dir.rotated(a), 31.0 + lv * 5.0, 390.0, 0.78, 18.0, 4, 0.0
				)
			for i in range(enemies.size()):
				if enemies[i]["pos"].distance_to(center) < 310.0:
					enemies[i]["armor_break"] = max(float(enemies[i]["armor_break"]), 3.5)
			show_message("關羽・青龍偃月", 1.5)
		"zhangfei":
			play_sfx("slash", 0.56)
			var radius: float = 255.0 + lv * 10.0
			for i in range(enemies.size() - 1, -1, -1):
				if i >= enemies.size():
					continue
				var diff: Vector2 = enemies[i]["pos"] - center
				if diff.length() <= radius:
					var live_index: int = damage_enemy(i, 27.0 + lv * 5.0, "zhangfei", false)
					if live_index >= 0:
						enemies[live_index]["stun"] = max(
							float(enemies[live_index]["stun"]), 1.0 + lv * 0.08
						)
						enemies[live_index]["knock"] += diff.normalized() * 560.0
			zones.append(
				{
					"kind": "shockwave_visual",
					"pos": center,
					"r": radius,
					"life": 0.72,
					"max_life": 0.72,
					"color": Color8(235, 91, 61)
				}
			)
			show_message("張飛・燕人怒喝（震波向外擴散）", 1.5)
		"zhaoyun":
			play_sfx("slash", 1.18)
			# 七進七出改為整條直線穿陣，不再以主角為中心畫圓。
			var dash_length: float = 520.0 + lv * 28.0
			var dash_width: float = 54.0 + lv * 3.0
			var end: Vector2 = center + dir * dash_length
			for i in range(enemies.size() - 1, -1, -1):
				if i >= enemies.size():
					continue
				var ep: Vector2 = enemies[i]["pos"]
				var along: float = clamp((ep - center).dot(dir), 0.0, dash_length)
				var closest: Vector2 = center + dir * along
				if along > 0.0 and ep.distance_to(closest) <= dash_width:
					var live_index: int = damage_enemy(i, 31.0 + lv * 6.2, "zhaoyun", false)
					if live_index >= 0:
						enemies[live_index]["knock"] += dir * 430.0
			# 三道槍芒沿同一條進攻線推出，Lv.5後增加兩側副槍芒。
			var spear_offsets: Array[float] = [0.0]
			if lv >= 3:
				spear_offsets = [-0.055, 0.0, 0.055]
			if lv >= 5:
				spear_offsets = [-0.10, -0.05, 0.0, 0.05, 0.10]
			for off in spear_offsets:
				spawn_player_projectile(
					"glaive", dir.rotated(off), 22.0 + lv * 4.8, 780.0, 0.92, 14.0, 8 + int(lv / 2.0), 0.0
				)
			player["invuln"] = max(float(player["invuln"]), 0.45 + lv * 0.03)
			zones.append({"kind":"hero_line_visual", "pos":center, "end":end, "width":dash_width, "life":0.62, "max_life":0.62, "color":heroes[hid]["color"]})
			show_message("趙雲・七進七出（直線穿陣）", 1.5)
		"huangzhong":
			play_sfx("arrow", 1.35)
			# 百步穿楊改為單發可見的重箭，鎖定最強敵人並貫穿整條射線。
			var arrow_damage: float = 54.0 + lv * 9.0
			var arrow_speed: float = 920.0 + lv * 22.0
			var pierce: int = 9 + lv
			spawn_player_projectile(
				"hero_arrow", dir, arrow_damage, arrow_speed, 1.55, 18.0, pierce, 0.0
			)
			# Lv.5後重箭帶一道較窄的破甲尾跡，仍維持單箭主體。
			if lv >= 5:
				for i in range(enemies.size()):
					var ep: Vector2 = enemies[i]["pos"]
					var along: float = clamp((ep - center).dot(dir), 0.0, 760.0)
					var closest: Vector2 = center + dir * along
					if along > 0.0 and ep.distance_to(closest) <= 28.0:
						enemies[i]["armor_break"] = max(float(enemies[i].get("armor_break", 0.0)), 2.5 + lv * 0.25)
			zones.append({"kind":"hero_arrow_visual", "pos":center, "angle":dir.angle(), "length":760.0, "life":0.50, "max_life":0.50, "color":heroes[hid]["color"]})
			show_message("黃忠・百步穿楊（貫穿重箭）", 1.5)
		"huatuo":
			heal_player(20.0 + lv * 6.0)
			for i in range(enemies.size()):
				var diff: Vector2 = enemies[i]["pos"] - center
				if diff.length() < 205.0:
					enemies[i]["knock"] += diff.normalized() * 400.0
					enemies[i]["slow"] = max(float(enemies[i]["slow"]), 1.0)
			spawn_ring(center, Color8(145, 226, 157), 205.0, 0.75)
			show_message("華佗・青囊濟世", 1.5)
		"caocao":
			# 軍令改為前方軍陣齊射：三條平行劍氣推進，不再是自身大圓。
			var command_length: float = 470.0 + lv * 22.0
			var normal: Vector2 = dir.rotated(PI * 0.5)
			for lane in [-1, 0, 1]:
				var lane_start: Vector2 = center + normal * lane * 72.0
				for i in range(enemies.size() - 1, -1, -1):
					if i >= enemies.size():
						continue
					var ep: Vector2 = enemies[i]["pos"]
					var along: float = clamp((ep - lane_start).dot(dir), 0.0, command_length)
					var closest: Vector2 = lane_start + dir * along
					if along > 0.0 and ep.distance_to(closest) <= 34.0:
						damage_enemy(i, 18.0 + lv * 4.2, "caocao", false)
				spawn_player_projectile("blade_wave", dir, 18.0 + lv * 3.8, 610.0, 0.95, 15.0, 6, 0.0)
				zones.append({"kind":"hero_line_visual", "pos":lane_start, "end":lane_start + dir * command_length, "width":30.0, "life":0.52, "max_life":0.52, "color":heroes[hid]["color"]})
			player["attack_speed_buff"] = 6.0 + lv * 0.5
			temporary_attack_speed = 6.0 + lv * 0.5
			if active_bonds.has("wenji_return"):
				heal_player(6.0 + lv * 1.5)
				player["attack_speed_buff"] = float(player["attack_speed_buff"]) + 2.0
				temporary_attack_speed += 2.0
				show_message("文姬歸漢：軍令伴隨胡笳清音", 1.8)
			for other in active_heroes:
				if other != hid:
					hero_cooldowns[other] = max(
						0.0, float(hero_cooldowns.get(other, 0.0)) - (1.2 + lv * 0.25)
					)
			show_message("曹操・唯才是舉（軍陣齊射）", 1.5)
		"sunjian":
			var end: Vector2 = center + dir * (320.0 + lv * 18.0)
			for i in range(enemies.size() - 1, -1, -1):
				if i >= enemies.size():
					continue
				var ep: Vector2 = enemies[i]["pos"]
				var proj: float = clamp((ep - center).dot(dir), 0.0, center.distance_to(end))
				var close: Vector2 = center + dir * proj
				if ep.distance_to(close) < 62.0:
					var live_index: int = damage_enemy(i, 34.0 + lv * 6.0, "sunjian", false)
					if live_index >= 0:
						enemies[live_index]["knock"] += dir * 520.0
			zones.append(
				{
					"kind": "fire",
					"pos": (center + end) * 0.5,
					"r": 78.0,
					"life": 2.4,
					"tick": 0.0,
					"damage": 4.0 + lv
				}
			)
			spawn_ring(end, Color8(230, 168, 64), 135.0, 0.65)
			for i in range(enemies.size() - 1, -1, -1):
				if i < enemies.size() and enemies[i]["pos"].distance_to(end) < 135.0:
					damage_enemy(i, 20.0 + lv * 4.0, "sunjian", false)
			show_message("孫堅・猛虎破陣", 1.5)
		"taishici":
			play_sfx("arrow", 1.15)
			# 太史慈改成雙弓交叉狙擊，兩條斜線在目標處交會。
			var normal: Vector2 = dir.rotated(PI * 0.5)
			for side in [-1.0, 1.0]:
				var shot_start: Vector2 = center + normal * side * 58.0
				var shot_dir: Vector2 = (target - shot_start).normalized()
				spawn_player_projectile("hero_arrow", shot_dir, 34.0 + lv * 5.2, 760.0, 1.25, 11.0, 7 + int(lv / 2.0), 0.0)
				zones.append({"kind":"hero_arrow_visual", "pos":shot_start, "angle":shot_dir.angle(), "length":620.0, "life":0.42, "max_life":0.42, "color":heroes[hid]["color"]})
			var idx: int = nearest_enemy_index(center)
			if idx >= 0:
				enemies[idx]["marked"] = 5.0
			show_message("太史慈・神射貫日", 1.5)
		"zhangjiao":
			play_sfx("poison", 0.82)
			for i in range(3 + (1 if lv >= 4 else 0)):
				var p: Vector2 = (
					target + Vector2.from_angle(float(i) / 3.0 * TAU) * (75.0 + i * 18.0)
				)
				zones.append(
					{
						"kind": "lightning",
						"pos": p,
						"r": 88.0,
						"life": 1.25,
						"tick": 0.0,
						"damage": 12.0 + lv * 3.0
					}
				)
				zones.append(
					{
						"kind": "poison",
						"pos": p,
						"r": 92.0,
						"life": 4.2,
						"tick": 0.0,
						"damage": 3.5 + lv * 0.8
					}
				)
			show_message("張角・太平雷法", 1.5)
		"diaochan":
			play_sfx("hero", 1.32)
			# 貂蟬改為在敵群中心展開閉月舞陣，魅惑向中心牽引。
			var radius: float = 205.0 + lv * 9.0
			for i in range(enemies.size() - 1, -1, -1):
				var diff: Vector2 = enemies[i]["pos"] - target
				if diff.length() < radius:
					var live_index: int = damage_enemy(i, 12.0 + lv * 2.8, "diaochan", false)
					if live_index >= 0:
						enemies[live_index]["charm"] = max(float(enemies[live_index]["charm"]), 2.1 + lv * 0.18)
						enemies[live_index]["knock"] += -diff.normalized() * 210.0
			spawn_ring(target, Color8(237, 169, 213), radius, 0.9)
			show_message("貂蟬・閉月流光", 1.5)
		"sunshangxiang":
			play_sfx("arrow", 1.32)
			# 孫尚香改為左右掃射的弓腰連珠，形成兩段扇面而非單一正面散射。
			var count: int = 7 + int(lv / 2.0)
			for sweep in [-0.38, 0.38]:
				for i in range(count):
					var spread: float = sweep + (float(i) - (count - 1) * 0.5) * 0.045
					spawn_player_projectile("fire_arrow", dir.rotated(spread), 14.0 + lv * 2.4, 610.0, 1.25, 7.0, 2, 0.0)
			zones.append(
				{
					"kind": "fire",
					"pos": target,
					"r": 105.0,
					"life": 2.2,
					"tick": 0.0,
					"damage": 4.0 + lv
				}
			)
			show_message("孫尚香・弓腰連珠", 1.5)
		"zhenji":
			play_sfx("hero", 0.92)
			# 甄姬改為前方洛水冰河，沿直線留下連續冰霜區。
			var radius: float = 92.0 + lv * 3.0
			for segment in range(5):
				var frost_pos: Vector2 = center + dir * (105.0 + segment * 95.0)
				zones.append(
					{
						"kind": "frost",
						"pos": frost_pos,
						"r": radius,
					"life": 4.0,
					"tick": 0.0,
					"damage": 4.0 + lv * 0.8
				}
			)
			for i in range(enemies.size()):
				var ep: Vector2 = enemies[i]["pos"]
				var along: float = clamp((ep - center).dot(dir), 0.0, 560.0)
				var closest: Vector2 = center + dir * along
				if along > 0.0 and ep.distance_to(closest) < radius:
					enemies[i]["slow"] = 3.2 + lv * 0.2
					if lv >= 3:
						enemies[i]["stun"] = max(float(enemies[i]["stun"]), 0.65)
			show_message("甄姬・洛水凝霜", 1.5)
		"lvlingqi":
			play_sfx("slash", 1.25)
			# 呂玲綺改成紫電折返突擊：先正面、再左右交叉切入。
			for a in [0.0, -0.32, 0.32]:
				spawn_player_projectile("glaive", dir.rotated(a), 27.0 + lv * 4.5, 740.0, 0.82, 16.0, 5, 0.0)
			for a in [-0.68, 0.68]:
				spawn_player_projectile("return_blade", dir.rotated(a), 19.0 + lv * 3.6, 560.0, 1.05, 13.0, 4, 0.0)
			player["invuln"] = max(float(player["invuln"]), 0.55)
			show_message("呂玲綺・紫電連戟", 1.5)
		"wangyi":
			play_sfx("slash", 1.05)
			# 王異改為鎖定目標的十字回刃，避免又是自身八方向。
			for a in [-0.52, 0.0, 0.52, PI]:
				spawn_player_projectile("return_blade", dir.rotated(a), 20.0 + lv * 3.8, 590.0, 1.12, 12.0, 4, 0.0)
			zones.append({"kind":"hero_line_visual", "pos":center, "end":center + dir * 430.0, "width":36.0, "life":0.44, "max_life":0.44, "color":heroes[hid]["color"]})
			show_message("王異・烈刃雪恨", 1.5)
		"caiwenji":
			play_sfx("heal", 0.88)
			heal_player(10.0 + lv * 3.0)
			# 胡笳清音改成三段前方音波扇形，保留回復但不再全周震波。
			for wave in range(3):
				var wave_radius: float = 180.0 + wave * 85.0
				for i in range(enemies.size() - 1, -1, -1):
					if i < enemies.size():
						var diff: Vector2 = enemies[i]["pos"] - center
						if diff.length() <= wave_radius and abs(wrapf(diff.angle() - dir.angle(), -PI, PI)) <= 0.78:
							var live_index: int = damage_enemy(i, 8.0 + lv * 2.2, "caiwenji", false)
							if live_index >= 0:
								enemies[live_index]["knock"] += (
								(enemies[live_index]["pos"] - center).normalized()
								* (170.0 + wave * 35.0)
							)
				spawn_ring(center, Color8(193, 216, 190), wave_radius, 0.42 + wave * 0.08)
			show_message("蔡文姬・胡笳清音", 1.5)
		"daqiao":
			play_sfx("hero", 1.18)
			# 大喬改為前方風牆：清除迎面投射物並向前推出扇形風刃。
			for i in range(enemy_shots.size() - 1, -1, -1):
				var shot_diff: Vector2 = enemy_shots[i]["pos"] - center
				if shot_diff.length() < 330.0 + lv * 10.0 and abs(wrapf(shot_diff.angle() - dir.angle(), -PI, PI)) <= 1.0:
					fast_remove_at(enemy_shots, i)
			for i in range(9):
				var spread: float = (float(i) - 4.0) * 0.13
				spawn_player_projectile(
					"wind_blade",
					dir.rotated(spread),
					14.0 + lv * 2.8,
					470.0,
					0.85,
					13.0,
					2,
					0.0
				)
			if active_bonds.has("jiangdong_grace"):
				for i in range(4):
					spawn_player_projectile(
						"fire_arrow",
						Vector2.from_angle(float(i) / 4.0 * TAU + PI * 0.25),
						18.0 + lv * 2.5,
						540.0,
						1.05,
						12.0,
						3,
						0.0
					)
				show_message("江東雙姝：花風化作燃燒箭雨", 1.8)
			player["shield"] = min(90.0, float(player["shield"]) + 10.0 + lv * 3.0)
			zones.append({"kind":"hero_line_visual", "pos":center, "end":center + dir * 350.0, "width":90.0, "life":0.62, "max_life":0.62, "color":heroes[hid]["color"]})
			show_message("大喬・流風花扇（前方風牆）", 1.5)
	if hid not in ["zhaoyun", "huangzhong", "caocao", "taishici", "diaochan", "sunshangxiang", "zhenji", "lvlingqi", "wangyi", "caiwenji", "daqiao"]:
		spawn_hero_signature_effect(hid, center, dir, lv)
	hero_cooldowns[hid] = hero_cooldown_value(hid)
	apply_hero_balance_identity(hid, lv, center)
	run_stats["hero_uses"][hid] = int(run_stats["hero_uses"].get(hid, 0)) + 1
	register_bond_cast(hid)
	play_sfx("hero", 1.0)


func hero_balance_tier(hid: String) -> String:
	return str(heroes.get(hid, {}).get("balance_tier", "B"))


func hero_has_legendary(hid: String, lv: int) -> bool:
	# 現階段以羈絆等級5代表傳奇能力解鎖；後續可再接個人劇情旗標。
	return lv >= 5


func apply_hero_balance_identity(hid: String, lv: int, center: Vector2) -> void:
	# 小眾名將不靠純傷害追趕，而以能改變Build的特殊回饋建立選擇價值。
	match hid:
		"huatuo":
			player["shield"] = min(100.0, float(player.get("shield", 0.0)) + 4.0 + lv * 1.5)
			if hero_has_legendary(hid, lv):
				player["invuln"] = max(float(player.get("invuln", 0.0)), 0.55)
		"diaochan":
			var crowded: int = 0
			for enemy in enemies:
				if enemy["pos"].distance_to(center) < 230.0:
					crowded += 1
			if crowded >= 8:
				hero_cooldowns[hid] = max(0.0, float(hero_cooldowns.get(hid, 0.0)) - 1.2)
		"zhenji":
			if hero_has_legendary(hid, lv):
				player["shield"] = min(100.0, float(player.get("shield", 0.0)) + 7.0 + lv)
		"wangyi":
			if float(player.get("hp", 1.0)) <= float(player.get("max_hp", 1.0)) * 0.5:
				player["dash_timer"] = 0.0
				show_message("王異・雪恨：閃避已重整", 1.2)
		"caiwenji":
			player["shield"] = min(100.0, float(player.get("shield", 0.0)) + 3.0 + lv)
			if hero_has_legendary(hid, lv):
				player["coins"] = int(player.get("coins", 0)) + 2 + lv
		"daqiao":
			if hero_has_legendary(hid, lv):
				for i in range(4):
					spawn_player_projectile("wind_blade", Vector2.from_angle(float(i) / 4.0 * TAU), 12.0 + lv * 2.0, 450.0, 0.75, 10.0, 2, 0.0)
		_:
			pass


func register_bond_cast(hid: String) -> void:
	if active_bonds.has("taoyuan") and hid in ["liubei", "guanyu", "zhangfei"]:
		for other in ["liubei", "guanyu", "zhangfei"]:
			if other != hid:
				hero_cooldowns[other] = max(0.0, float(hero_cooldowns.get(other, 0.0)) - 0.85)
		var seq: Array = bond_combo_progress.get("taoyuan", [])
		if not seq.has(hid):
			seq.append(hid)
		bond_combo_progress["taoyuan"] = seq
		if seq.size() >= 3:
			bond_combo_progress["taoyuan"] = []
			for i in range(8):
				var dir: Vector2 = Vector2.from_angle(float(i) / 8.0 * TAU)
				spawn_player_projectile("blade_wave", dir, 24.0, 410.0, 0.8, 14.0, 3, 0.0)
			show_message("桃園結義・義勇合擊！", 2.2)
	if active_bonds.has("western_resolve") and hid in ["wangyi", "lvlingqi"]:
		var partner: String = "lvlingqi" if hid == "wangyi" else "wangyi"
		hero_cooldowns[partner] = max(0.0, float(hero_cooldowns.get(partner, 0.0)) - 1.5)
		show_message("西涼烈志：%s冷卻縮短" % heroes[partner]["name"], 1.5)
	if active_bonds.has("heroines") and hid in ["diaochan", "sunshangxiang", "lvlingqi"]:
		var seq: Array = bond_combo_progress.get("heroines", [])
		if not seq.has(hid):
			seq.append(hid)
		bond_combo_progress["heroines"] = seq
		if seq.size() >= 3:
			bond_combo_progress["heroines"] = []
			player["invuln"] = max(float(player["invuln"]), 1.2)
			for i in range(12):
				spawn_player_projectile(
					"ring",
					Vector2.from_angle(float(i) / 12.0 * TAU),
					20.0,
					470.0,
					0.85,
					10.0,
					3,
					0.0
				)
			show_message("巾幗並肩・流光合擊！", 2.2)


const EVENT_MIN_DISTANCE: float = 620.0


func event_anchor_positions() -> Array[Vector2]:
	var anchors: Array[Vector2] = []
	if current_encounter != "":
		anchors.append(encounter_pos)
	if merchant_active:
		anchors.append(merchant_pos)
	if camp_active:
		anchors.append(camp_pos)
	return anchors


func spaced_event_position(distance_min: float, distance_max: float, margin: float = 80.0) -> Vector2:
	var anchors: Array[Vector2] = event_anchor_positions()
	for attempt in range(28):
		var candidate: Vector2 = player["pos"] + Vector2.from_angle(rng.randf_range(0.0, TAU)) * rng.randf_range(distance_min, distance_max)
		candidate.x = clamp(candidate.x, margin, WORLD.size.x - margin)
		candidate.y = clamp(candidate.y, margin, WORLD.size.y - margin)
		var valid: bool = candidate.distance_to(player["pos"]) >= distance_min * 0.82
		for anchor in anchors:
			if candidate.distance_to(anchor) < EVENT_MIN_DISTANCE:
				valid = false
				break
		if valid:
			return candidate
	# 地圖邊緣或窄形戰場無法完全滿足時，仍選擇距離既有事件最遠的位置。
	var best: Vector2 = player["pos"]
	var best_score: float = -1.0
	for angle_index in range(16):
		var candidate: Vector2 = player["pos"] + Vector2.from_angle(float(angle_index) / 16.0 * TAU) * distance_max
		candidate.x = clamp(candidate.x, margin, WORLD.size.x - margin)
		candidate.y = clamp(candidate.y, margin, WORLD.size.y - margin)
		var score: float = candidate.distance_to(player["pos"])
		for anchor in anchors:
			score = min(score, candidate.distance_to(anchor))
		if score > best_score:
			best_score = score
			best = candidate
	return best


func historical_hero_weight(hid: String) -> int:
	var chapter_id: String = str(current_chapter().get("id", ""))
	var priority: Dictionary = {
		"yellow_turban": {"liubei": 5, "guanyu": 5, "zhangfei": 5, "zhangjiao": 4, "caocao": 2, "sunjian": 2},
		"luoyang_turmoil": {"caocao": 5, "sunjian": 4, "diaochan": 4, "lvlingqi": 2, "liubei": 2},
		"hulao_coalition": {"liubei": 4, "guanyu": 5, "zhangfei": 5, "diaochan": 4, "lvlingqi": 4, "caocao": 3, "sunjian": 3},
		"xuzhou_flames": {"liubei": 5, "guanyu": 4, "zhangfei": 4, "caocao": 4, "lvlingqi": 2},
		"guandu_showdown": {"caocao": 6, "zhenji": 4, "caiwenji": 3, "guanyu": 3},
		"jingzhou_retreat": {"liubei": 6, "guanyu": 4, "zhangfei": 4, "caiwenji": 2, "daqiao": 2},
		"changban_escape": {"liubei": 6, "zhangfei": 6, "guanyu": 3, "caiwenji": 2, "sunshangxiang": 2, "daqiao": 2}
	}
	return int((priority.get(chapter_id, {}) as Dictionary).get(hid, 1))


func update_world_events(delta: float) -> void:
	if not chapter_manager.boss_is_locked():
		return
	var chapter: Dictionary = current_chapter()
	if not camp_spawned and elapsed >= float(chapter.get("camp_time", 78.0)):
		camp_spawned = true
		camp_active = true
		camp_pos = spaced_event_position(430.0, 690.0, 80.0)
		show_message("附近出現安全營地，可回復生命、獲得護盾並整備名將。", 3.0)
	if not chest_spawned and elapsed >= float(chapter.get("chest_time", 135.0)):
		chest_spawned = true
		chest_active = true
		chest_pos = player["pos"] + Vector2.from_angle(rng.randf_range(0.0, TAU)) * 330.0
		chest_pos.x = clamp(chest_pos.x, 80.0, WORLD.size.x - 80.0)
		chest_pos.y = clamp(chest_pos.y, 80.0, WORLD.size.y - 80.0)
		show_message("戰場上發現遺物寶箱。", 3.0)
	spawn_history_event_if_ready()
	if current_encounter == "":
		hero_spawn_timer -= delta
		if hero_spawn_timer <= 0.0 and Alpha36RosterProgressionHud.can_spawn_recruit(self, alpha36_37_state):
			spawn_hero_encounter()
		elif hero_spawn_timer <= 0.0:
			hero_spawn_timer = 30.0
	if not merchant_active:
		merchant_spawn_timer -= delta
		if merchant_spawn_timer <= 0.0:
			spawn_merchant()


func hero_pool() -> Array:
	return chapter_manager.hero_pool()


func current_stage_branch_profile() -> Dictionary:
	var cid: String = chapter_manager.current_id()
	var profile: Dictionary = {"route":"neutral", "difficulty_mult":1.0, "boss_variant":"standard", "support":"none"}
	if cid == "yellow_turban_zhuo":
		if history_flags.has("benevolent_mercy") or history_route_tags.has("people_first"):
			profile = {"route":"people_first", "difficulty_mult":1.04, "boss_variant":"protect_people", "support":"militia"}
		elif dominant_faction() == "群":
			profile = {"route":"local_uprising", "difficulty_mult":1.08, "boss_variant":"yellow_turban_fury", "support":"rebels"}
	elif cid == "hulao_coalition":
		if history_flags.has("three_heroes_challenge") and active_heroes.has("liubei") and active_heroes.has("guanyu") and active_heroes.has("zhangfei"):
			profile = {"route":"three_heroes", "difficulty_mult":1.08, "boss_variant":"early_enrage", "support":"coalition"}
		elif active_heroes.has("diaochan") or active_heroes.has("lvlingqi"):
			profile = {"route":"flying_general_ties", "difficulty_mult":0.96, "boss_variant":"hesitation", "support":"personal"}
		elif dominant_faction() == "群" and history_rewrite_rate >= 20.0:
			profile = {"route":"western_alliance", "difficulty_mult":1.12, "boss_variant":"double_vanguard", "support":"xiliang"}
	elif cid == "guandu_showdown":
		if history_flags.has("wuchao_raid") or history_flags.has("caocao_wuchao"):
			profile = {"route":"wuchao_success", "difficulty_mult":0.90, "boss_variant":"supply_broken", "support":"caowei"}
		elif history_flags.has("accept_xuyou_intel"):
			profile = {"route":"intelligence_war", "difficulty_mult":1.06, "boss_variant":"ambush", "support":"strategist"}
		elif dominant_faction() == "群":
			profile = {"route":"support_yuan", "difficulty_mult":1.14, "boss_variant":"caowei_counterattack", "support":"hebei"}
	elif cid == "red_cliffs":
		if dominant_faction() == "魏":
			profile = {"route":"break_fire_attack", "difficulty_mult":1.12, "boss_variant":"wu_fire_command", "support":"caowei"}
		elif dominant_faction() == "吳" or history_route_tags.has("jiangdong_route"):
			profile = {"route":"east_wind", "difficulty_mult":0.96, "boss_variant":"fire_attack_success", "support":"jiangdong"}
		elif history_rewrite_rate >= 60.0:
			profile = {"route":"alternate_chibi", "difficulty_mult":1.18, "boss_variant":"chaos_fleet", "support":"unknown"}
	return profile


func dominant_faction() -> String:
	var counts: Dictionary = faction_momentum.duplicate(true)
	for hid_value in active_heroes + reserve_heroes:
		var hid: String = str(hid_value)
		var faction: String = str(heroes.get(hid, {}).get("faction", "群"))
		counts[faction] = int(counts.get(faction, 0)) + hero_bond_level(hid)
	var best: String = ""
	var best_score: int = 0
	for faction_value in counts:
		if int(counts[faction_value]) > best_score:
			best = str(faction_value)
			best_score = int(counts[faction_value])
	return best


func hero_story_weight(hid: String) -> int:
	var weight: int = max(1, historical_hero_weight(hid))
	var faction: String = str(heroes.get(hid, {}).get("faction", "群"))
	var dominant: String = dominant_faction()
	if dominant != "" and faction == dominant:
		weight += 2
	weight += clampi(int(faction_momentum.get(faction, 0)) / 6, 0, 3)
	if not known_heroes.has(hid):
		weight += 2
	else:
		weight = max(1, weight - int(hero_levels.get(hid, 1) >= 4))
	# 劇情旗標會把後續人物池往玩家曾經支持的方向推動，但不完全封鎖其他陣營。
	var faction_flags: Dictionary = {
		"蜀": ["zhuo_mercy", "zhuo_oath", "xuzhou_people", "jingzhou_share_grain", "changban_people_first"],
		"魏": ["guandu_raid", "guandu_caocao", "guandu_accept_intel", "jingzhou_arms_first"],
		"吳": ["jingzhou_wu_route", "chibi_alliance", "chibi_fire_attack"],
		"群": ["hulao_vanguard", "xuzhou_seize_arms", "luoyang_treasure"]
	}
	for flag_value in faction_flags.get(faction, []):
		if history_flags.has(str(flag_value)):
			weight += 1
	return clampi(weight, 1, 10)


func hero_is_rostered(hid: String) -> bool:
	return active_heroes.has(hid) or reserve_heroes.has(hid) or camp_heroes.has(hid)


func lvbu_legendary_clue_count() -> int:
	var count: int = 0
	if known_heroes.has("diaochan"):
		count += 1
	if known_heroes.has("lvlingqi"):
		count += 1
	if history_flags.has("hulao_three_heroes") or history_flags.has("hulao_vanguard") or history_flags.has("zhuo_oath"):
		count += 1
	if equipment_inventory.has("red_hare") or equipment_inventory.has("sky_halberd") or equipped.values().has("red_hare") or equipped.values().has("sky_halberd"):
		count += 1
	return count


func legendary_hero_available(hid: String) -> bool:
	if hid == "lvbu":
		return lvbu_legendary_clue_count() >= 2
	return true


func legendary_hero_weight(hid: String) -> int:
	if hid != "lvbu":
		return hero_story_weight(hid)
	var clues: int = lvbu_legendary_clue_count()
	if clues < 2:
		return 0
	if clues == 2:
		return 1
	if clues == 3:
		return 3
	return 8


func weighted_hero_pick(pool: Array, excluded: Array[String]) -> String:
	var weighted: Array[String] = []
	for hid_value in pool:
		var hid: String = str(hid_value)
		if excluded.has(hid) or float(encounter_cooldowns.get(hid, 0.0)) > 0.0:
			continue
		# 主戰、後備與營地可直接在整備調度，不再重複佔用招賢館名額；真正離隊者仍可等權重回歸。
		if hero_is_rostered(hid):
			continue
		if not legendary_hero_available(hid):
			continue
		var recruit_weight: int = HeroRecruitmentAffinityService.adjusted_weight(self, hid, legendary_hero_weight(hid))
		for i in range(recruit_weight):
			weighted.append(hid)
	if weighted.is_empty():
		return ""
	return weighted[rng.randi_range(0, weighted.size() - 1)]


func recruit_candidate_count() -> int:
	var chapter_index: int = int(current_chapter().get("index", 0))
	var roll: float = rng.randf()
	if chapter_index <= 1:
		return 1 if roll < 0.55 else 2
	if chapter_index <= 5:
		return 1 if roll < 0.20 else (2 if roll < 0.72 else 3)
	return 1 if roll < 0.12 else (2 if roll < 0.55 else 3)


func roll_recruit_candidates(excluded: Array[String] = []) -> Array[String]:
	var pool: Array = hero_pool()
	var result: Array[String] = []
	var target_count: int = recruit_candidate_count()
	for _i in range(target_count):
		var hid: String = weighted_hero_pick(pool, excluded + result)
		if hid == "":
			break
		result.append(hid)
	return result


func spawn_hero_encounter() -> void:
	encounter_candidates = roll_recruit_candidates()
	if encounter_candidates.is_empty():
		hero_spawn_timer = 12.0
		return
	current_encounter = encounter_candidates[0]
	Alpha36RosterProgressionHud.register_recruit_visit(self, alpha36_37_state)
	encounter_pos = spaced_event_position(420.0, 720.0, 70.0)
	hero_spawn_timer = 55.0
	recruit_refresh_count = 0
	show_message("遠處出現招賢館，似有豪傑等待明主。", 4.0)


func recruit_refresh_cost() -> int:
	var costs: Array[int] = [20, 40, 70, 110, 170]
	if recruit_refresh_count < costs.size():
		return costs[recruit_refresh_count]
	return costs[-1] + (recruit_refresh_count - costs.size() + 1) * 80


func recruit_refresh_is_free() -> bool:
	return has_relic("bole_eye") and not recruit_free_refresh_used


func refresh_recruit_candidates() -> void:
	var free_refresh: bool = recruit_refresh_is_free()
	var cost: int = 0 if free_refresh else recruit_refresh_cost()
	if int(player.get("coins", 0)) < cost:
		show_message("銅錢不足，無法刷新招賢館名單。", 2.2)
		play_sfx("ui_cancel")
		return
	if not free_refresh:
		player["coins"] = int(player.get("coins", 0)) - cost
	else:
		recruit_free_refresh_used = true
	var old_candidates: Array[String] = encounter_candidates.duplicate()
	var new_candidates: Array[String] = roll_recruit_candidates(old_candidates)
	if new_candidates.is_empty():
		new_candidates = roll_recruit_candidates()
	if new_candidates.is_empty():
		show_message("今日已無其他豪傑可薦。", 2.2)
		return
	encounter_candidates = new_candidates
	current_encounter = encounter_candidates[0]
	recruit_refresh_count += 1
	option_index = 0
	show_message("招賢館已換上一批新的豪傑名單。", 2.3)
	play_sfx("merchant", 0.94)


func merchant_rarity_rank(rarity: String) -> int:
	return {"common":0, "rare":1, "epic":2, "legendary":3, "mythic":4}.get(rarity, 0)


func choose_merchant_kind() -> String:
	var chapter_index: int = int(current_chapter().get("index", 0))
	var weighted: Array[String] = ["peddler", "peddler", "blacksmith", "quartermaster"]
	if chapter_index >= 2:
		weighted.append("antiquarian")
	if chapter_index >= 4:
		weighted.append("mysterious")
	if merchant_visit >= 2:
		weighted.append("blacksmith")
	return weighted[rng.randi_range(0, weighted.size() - 1)]


func shuffled_ids(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		result.append(str(value))
	for i in range(result.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var temp: String = result[i]
		result[i] = result[j]
		result[j] = temp
	return result


func spawn_merchant() -> void:
	merchant_active = true
	merchant_pos = spaced_event_position(450.0, 760.0, 80.0)
	merchant_kind = choose_merchant_kind()
	var mdef: Dictionary = merchant_defs.get(merchant_kind, merchant_defs.get("peddler", {}))
	merchant_stock.clear()
	merchant_equipment_stock.clear()

	var relic_pool: Array[String] = shuffled_ids(relic_defs.keys())
	var equipment_pool: Array[String] = shuffled_ids(equipment_defs.keys())
	var relic_limit: int = int(mdef.get("relic_count", 3))
	var equipment_limit: int = int(mdef.get("equipment_count", 2))
	var min_rank: int = int(mdef.get("min_rarity_rank", 0))
	var military_tags: Array = ["名將", "防禦", "策略"]

	for rid in relic_pool:
		if relics.has(rid) and relic_level(rid) >= MAX_RELIC_LEVEL:
			continue
		var rdef: Dictionary = relic_defs[rid]
		var rank: int = merchant_rarity_rank(str(rdef.get("rarity", "common")))
		if rank < min_rank:
			continue
		if merchant_kind == "quartermaster":
			var matched: bool = false
			for tag in (rdef.get("tags", []) as Array):
				if military_tags.has(str(tag)):
					matched = true
			if not matched:
				continue
		merchant_stock.append(rid)
		if merchant_stock.size() >= relic_limit:
			break

	for eid in equipment_pool:
		var edef: Dictionary = equipment_defs[eid]
		var rank: int = merchant_rarity_rank(str(edef.get("rarity", "common")))
		if rank < min_rank:
			continue
		if merchant_kind == "antiquarian" and (edef.get("bosses", []) as Array).is_empty():
			continue
		if merchant_kind == "quartermaster" and str(edef.get("slot", "")) == "weapon":
			continue
		merchant_equipment_stock.append(eid)
		if merchant_equipment_stock.size() >= equipment_limit:
			break

	# 池過窄時補足，避免商店空白。
	for eid in equipment_pool:
		if merchant_equipment_stock.size() >= equipment_limit:
			break
		if not merchant_equipment_stock.has(eid):
			merchant_equipment_stock.append(eid)

	show_message("%s：%s" % [str(mdef.get("name", "行商")), str(mdef.get("greeting", "看看貨吧。"))], 4.0)


func try_interact() -> void:
	if history_event_active and player["pos"].distance_to(history_event_pos) < 88.0:
		open_history_event()
		return
	if current_encounter != "" and player["pos"].distance_to(encounter_pos) < 72.0:
		previous_screen = "game"
		option_index = 0
		modal_input_lock_until_ms = Time.get_ticks_msec() + 140
		screen = "hero_encounter_pick"
		play_sfx("hero", 0.92)
		return
	if camp_active and player["pos"].distance_to(camp_pos) < 92.0:
		camp_active = false
		var camp_mult: float = float(history_modifiers.get("camp_recovery_mult", 1.0))
		var camp_heal: float = float(player["max_hp"]) * 0.22 * camp_mult
		var camp_shield: float = float(player["max_hp"]) * 0.12 * camp_mult
		heal_player(camp_heal)
		player["shield"] = min(100.0, float(player["shield"]) + camp_shield)
		spawn_ring(player["pos"], Color8(235, 184, 91), 105.0, 0.62)
		spawn_ring(player["pos"], Color8(242, 222, 172), 76.0, 0.48)
		show_message("紮營休整：回復生命並獲得護盾%s" % ("（史勢加成）" if camp_mult > 1.0 else ""), 3.0)
		previous_screen = "game"
		camp_menu_index = 0
		option_index = 0
		screen = "camp_menu"
		modal_input_lock_until_ms = Time.get_ticks_msec() + 140
		return
	if chest_active and player["pos"].distance_to(chest_pos) < 82.0:
		chest_active = false
		grant_random_relic("開啟戰場寶箱")
		return
	if merchant_active and player["pos"].distance_to(merchant_pos) < 78.0:
		open_shop()


func choose_hero_candidate(index: int) -> void:
	var refresh_index: int = encounter_candidates.size()
	var leave_index: int = encounter_candidates.size() + 1
	if index == refresh_index:
		refresh_recruit_candidates()
		return
	if index >= leave_index:
		for hid in encounter_candidates:
			encounter_cooldowns[hid] = rng.randf_range(48.0, 72.0)
		encounter_candidates.clear()
		current_encounter = ""
		hero_spawn_timer = rng.randf_range(20.0, 30.0)
		screen = "game"
		show_message("你離開招賢館，豪傑各自散去。", 2.8)
		return
	if index < 0 or index >= encounter_candidates.size():
		return
	current_encounter = encounter_candidates[index]
	option_index = 0
	modal_input_lock_until_ms = Time.get_ticks_msec() + 120
	screen = "hero_encounter"


func choose_hero_encounter(index: int) -> void:
	var hid: String = current_encounter
	if hid == "":
		screen = "game"
		return
	match index:
		0:  # 邀請上場
			if active_heroes.has(hid):
				level_up_hero(hid)
				finish_hero_encounter(hid, 42.0)
			elif active_heroes.size() < active_limit():
				add_active_hero(hid)
				finish_hero_encounter(hid, 52.0)
			else:
				replace_candidate = hid
				replace_index = 0
				option_index = 0
				screen = "replace_hero"
		1:  # 後備
			if active_heroes.has(hid) or reserve_heroes.has(hid):
				level_up_hero(hid)
			else:
				var destination: String = place_hero_in_support(hid)
				known_heroes[hid] = true
				initialize_hero_progress(hid)
				show_message("%s加入%s。" % [heroes[hid]["name"], "後備" if destination == "reserve" else "營地"], 2.5)
			update_bonds()
			finish_hero_encounter(hid, 48.0)
		2:  # 暫不同行
			encounter_cooldowns[hid] = rng.randf_range(55.0, 82.0)
			current_encounter = ""
			encounter_candidates.clear()
			hero_spawn_timer = rng.randf_range(18.0, 28.0)
			screen = "game"
			show_message("暫別%s；往後仍可能再度相逢。" % heroes[hid]["name"], 3.0)


func choose_replacement(index: int) -> void:
	if index >= active_heroes.size():
		# 取消替換，改列後備。
		place_hero_in_support(replace_candidate)
		known_heroes[replace_candidate] = true
		hero_levels[replace_candidate] = int(hero_levels.get(replace_candidate, 1))
		update_bonds()
		finish_hero_encounter(replace_candidate, 48.0)
		return
	var old: String = str(active_heroes[index])
	active_heroes[index] = replace_candidate
	place_hero_in_support(old)
	reserve_heroes.erase(replace_candidate)
	camp_heroes.erase(replace_candidate)
	known_heroes[replace_candidate] = true
	initialize_hero_progress(replace_candidate)
	hero_cooldowns[replace_candidate] = hero_cooldown_value(replace_candidate)
	update_bonds()
	finish_hero_encounter(replace_candidate, 52.0)
	show_message("%s上場，%s轉為後備。" % [heroes[replace_candidate]["name"], heroes[old]["name"]], 3.0)


func add_active_hero(hid: String) -> void:
	active_heroes.append(hid)
	reserve_heroes.erase(hid)
	camp_heroes.erase(hid)
	known_heroes[hid] = true
	initialize_hero_progress(hid)
	# 初次入隊立即可以施放，強化第一章體感。
	hero_cooldowns[hid] = 0.0
	update_bonds()
	show_message("%s加入前線！主動技能已準備完成。" % heroes[hid]["name"], 3.0)


func level_up_hero(hid: String) -> void:
	known_heroes[hid] = true
	initialize_hero_progress(hid)
	# 舊識重逢改為二選一式成長：技能未滿優先提升技能，之後才提升羈絆。
	if hero_skill_level(hid) < 8:
		improve_hero_skill(hid)
	elif hero_bond_level(hid) < 5:
		improve_hero_bond(hid)
	else:
		player["coins"] = int(player.get("coins", 0)) + 80
		show_message("%s已臻化境，轉贈軍資80。" % heroes[hid]["name"], 3.0)
	hero_cooldowns[hid] = 0.0


func finish_hero_encounter(hid: String, cooldown: float) -> void:
	encounter_cooldowns[hid] = cooldown
	current_encounter = ""
	encounter_candidates.clear()
	hero_spawn_timer = rng.randf_range(34.0, 51.0)
	screen = "game"
	update_bonds()


func open_shop() -> void:
	shop_choices.clear()
	var mdef: Dictionary = merchant_defs.get(merchant_kind, merchant_defs.get("peddler", {}))
	var price_mult: float = float(mdef.get("price_mult", 1.0))
	for rid_value in merchant_stock:
		var rid: String = str(rid_value)
		var rarity: String = str(relic_defs[rid].get("rarity", "common"))
		var relic_chapter_number: int = int(current_chapter().get("index", 0)) + 1
		var discount_mult: float = 0.88 if has_relic("jade") else 1.0
		var base: int = MerchantPricingService.relic_price(merchant_kind, rarity, relic_chapter_number, discount_mult)
		shop_choices.append({"kind": "relic", "id": rid, "price": base, "rarity": rarity})
	for eid_value in merchant_equipment_stock:
		var eid: String = str(eid_value)
		var edef: Dictionary = equipment_defs[eid]
		var rarity: String = str(edef.get("rarity", "common"))
		var equipment_chapter_number: int = int(current_chapter().get("index", 0)) + 1
		var price: int = MerchantPricingService.equipment_price(merchant_kind, rarity, equipment_chapter_number, equipment_effect("shop_price_mult", 1.0))
		shop_choices.append({"kind":"equipment","id":eid,"price":price,"rarity":rarity})
	if bool(mdef.get("sells_heal", true)):
		shop_choices.append({"kind": "heal", "id": "heal", "price": MerchantPricingService.heal_price(merchant_kind, int(current_chapter().get("index", 0)) + 1)})
	shop_choices.append({"kind": "config", "id": "config", "price": 0})
	option_index = 0
	previous_screen = "game"
	screen = "shop"
	play_bgm("merchant")


func choose_shop(index: int) -> void:
	var item_count: int = shop_choices.size()
	if index == item_count:
		previous_screen = "shop"
		screen = "tab"
		tab_page = 1
		tab_index = 0
		tab_scroll = 0
		play_sfx("ui_confirm")
		return
	if index > item_count:
		screen = "game"
		play_current_battle_bgm()
		return
	var item: Dictionary = shop_choices[index]
	if str(item["kind"]) == "config":
		open_hero_config("merchant")
		return
	if int(player["coins"]) < int(item["price"]):
		show_message("銅錢不足。", 1.8)
		play_sfx("ui_move", 0.7)
		return
	player["coins"] = int(player["coins"]) - int(item["price"])
	if str(item["kind"]) == "heal":
		heal_player(28.0)
	elif str(item["kind"]) == "equipment":
		grant_equipment(str(item["id"]), "行商購入")
	else:
		grant_relic(str(item["id"]), "行商購入", true)
	merchant_visit += 1
	var purchased_id: String = str(item.get("id", ""))
	if str(item.get("type", "relic")) == "equipment":
		merchant_equipment_stock.erase(purchased_id)
	else:
		merchant_stock.erase(purchased_id)
	shop_choices.remove_at(index)
	option_index = clampi(index, 0, shop_choices.size() + 1)
	screen = "shop"
	play_bgm("merchant")
	show_message("交易完成，可繼續選購或前往裝備整備。", 2.4)


func open_levelup() -> void:
	if pending_levelups <= 0:
		return
	level_choices.clear()
	var pool: Array = []
	for sid in skill_defs:
		if skill_level(sid) < int(skill_defs[sid]["max"]):
			pool.append(sid)
	pool = PlayerUpgradeService.weighted_pool(pool, skill_defs, chosen_identity, rng)
	var count: int = min(5, 3 + (1 if has_relic("artofwar") else 0))
	if reserve_heroes.has("caocao") and rng.randf() < 0.35:
		count = min(5, count + 1)
	for i in range(min(count, pool.size())):
		level_choices.append(pool[i])
	# Alpha.15：少量加入名將成長卡，不擠壓主角Build；只從主戰／後備中選擇。
	var eligible_heroes: Array[String] = []
	for hid_value in active_heroes + reserve_heroes:
		var hid: String = str(hid_value)
		if hero_skill_level(hid) < 8 or hero_bond_level(hid) < 5:
			eligible_heroes.append(hid)
	if not eligible_heroes.is_empty() and rng.randf() < 0.20:
		var hid: String = eligible_heroes[rng.randi_range(0, eligible_heroes.size() - 1)]
		var choice_id: String = "hero_skill:%s" % hid if hero_skill_level(hid) < 8 else "hero_bond:%s" % hid
		if level_choices.size() >= count and not level_choices.is_empty():
			level_choices[level_choices.size() - 1] = choice_id
		else:
			level_choices.append(choice_id)
	if level_choices.is_empty():
		# 全部技能已滿時一次結清待處理等級，避免卡在不存在的升級選單。
		var rewards: int = pending_levelups
		pending_levelups = 0
		heal_player(10.0 * rewards)
		player["coins"] = int(player["coins"]) + rewards * 5
		show_message("武藝已臻化境：轉化為補給與銅錢", 2.5)
		screen = "game"
		return
	option_index = 0
	previous_screen = "game"
	alpha19_filter_level_choices()
	screen = "levelup"
	modal_input_lock_until_ms = Time.get_ticks_msec() + 140
	play_sfx("levelup")


func choose_levelup(index: int) -> void:
	if index < 0 or index >= level_choices.size():
		return
	var sid: String = str(level_choices[index])
	if sid.begins_with("hero_skill:") or sid.begins_with("hero_bond:"):
		var parts: PackedStringArray = sid.split(":", false, 1)
		var hid: String = str(parts[1]) if parts.size() > 1 else ""
		if hid != "" and heroes.has(hid):
			if sid.begins_with("hero_skill:"):
				improve_hero_skill(hid)
			else:
				improve_hero_bond(hid)
		pending_levelups = max(0, pending_levelups - 1)
		level_choices.clear()
		if pending_levelups > 0:
			open_levelup()
		else:
			screen = "game"
		return
	skill_levels[sid] = skill_level(sid) + 1
	match sid:
		"move_speed":
			player["speed"] = float(player["speed"]) * 1.07
		"max_hp":
			player["max_hp"] = float(player["max_hp"]) + 15.0
			player["hp"] = min(float(player["max_hp"]), float(player["hp"]) + 15.0)
		"armor":
			player["armor"] = float(player["armor"]) + 1.0
		"crit":
			player["crit"] = min(0.55, float(player["crit"]) + 0.05)
		"magnet":
			player["magnet"] = float(player["magnet"]) + 45.0
		"dash":
			pass
		"hero_cd":
			player["hero_cd_mult"] = float(player["hero_cd_mult"]) * 0.92
		"projectile":
			player["projectile_mult"] = float(player["projectile_mult"]) * 1.12
		"pierce":
			player["pierce"] = int(player["pierce"]) + 1
		"poison":
			player["poison_power"] = float(player["poison_power"]) * 1.18
		"multishot":
			player["multishot"] = int(player["multishot"]) + 1
		"heal":
			player["heal_power"] = float(player["heal_power"]) * 1.18
	pending_levelups = max(0, pending_levelups - 1)
	level_choices.clear()
	show_message("習得：%s Lv.%d" % [skill_defs[sid]["name"], skill_level(sid)], 2.5)
	if pending_levelups > 0:
		open_levelup()
	else:
		screen = "game"


func update_bonds() -> void:
	var new_active: Array = []
	for bid in bond_defs:
		var b: Dictionary = bond_defs[bid]
		var ok: bool = false
		match str(b["type"]):
			"active_all":
				ok = true
				for m in b["members"]:
					if not active_heroes.has(m):
						ok = false
			"reserve_all":
				ok = true
				for m in b["members"]:
					if not reserve_heroes.has(m):
						ok = false
			"active_reserve":
				if b.has("active_any"):
					for m in b["active_any"]:
						if active_heroes.has(m):
							ok = true
				else:
					ok = active_heroes.has(str(b["active"]))
				ok = ok and reserve_heroes.has(str(b["reserve"]))
		if ok:
			new_active.append(bid)
			if not save_data["unlocked_bonds"].has(bid):
				save_data["unlocked_bonds"][bid] = {
					"time": Time.get_datetime_string_from_system(),
					"mode": chosen_mode,
					"identity": chosen_identity
				}
				save_game_meta()
				show_message("羈絆圖鑑解鎖：%s" % b["name"], 3.2)
	active_bonds = new_active


func support_boss_index() -> int:
	for i in range(enemies.size()):
		if bool(enemies[i].get("boss_support", false)) and float(enemies[i].get("hp", 0.0)) > 0.0:
			return i
	return -1


func support_boss_alive() -> bool:
	return support_boss_index() >= 0


func finish_boss_if_ready() -> void:
	if boss.is_empty() or float(boss.get("hp", 0.0)) > 0.0 or support_boss_alive():
		return
	if chapter_manager.mark_boss_defeated():
		spawn_sparks(boss["pos"], Color8(245, 196, 90), 36)
		request_run_result(true)


func boss_threat_damage_multiplier() -> float:
	var chapter_index: int = int(current_chapter().get("index", 0))
	var base: float = 1.28 + min(0.28, float(chapter_index) * 0.022)
	if difficulty_id() == "hard":
		base *= 1.10
	elif difficulty_id() == "easy":
		base *= 0.92
	return base


func boss_attack_speed_multiplier(phase: int) -> float:
	var value: float = 1.22 if phase == 1 else 1.42
	if difficulty_id() == "hard":
		value *= 1.08
	elif difficulty_id() == "easy":
		value *= 0.94
	return value


func boss_chase_speed_multiplier(phase: int) -> float:
	var value: float = 1.14 if phase == 1 else 1.28
	if difficulty_id() == "hard":
		value *= 1.06
	return value


func boss_combat_archetype(boss_id: String) -> String:
	# 遠程Boss維持施法距離，混合型會依距離切換，避免所有Boss都只會貼臉追擊。
	if boss_id in ["zhangliang", "yuanshao", "caimao", "caocao", "simayi", "luxun"]:
		return "ranged"
	if boss_id in ["zhanghe", "xiahouyuan", "huangzhong", "zhangliao"]:
		return "hybrid"
	return "melee"


func boss_preferred_range(archetype: String) -> float:
	if archetype == "ranged":
		return 285.0
	if archetype == "hybrid":
		return 185.0
	return 72.0


func move_boss_by_archetype(diff: Vector2, delta: float, phase: int) -> void:
	if diff.length_squared() <= 0.001:
		return
	var archetype: String = str(boss.get("archetype", boss_combat_archetype(str(boss.get("id", "")))))
	var distance: float = diff.length()
	var direction: Vector2 = diff / distance
	var chase_mult: float = boss_chase_speed_multiplier(phase)
	var speed: float = float(boss["speed"]) * chase_mult
	if boss["id"] == "lvbu":
		speed *= 1.12
	elif boss["id"] in ["zhanghe", "gaoshun"]:
		speed *= 1.0 + 0.06 * relic_level("dilu")
	var preferred: float = boss_preferred_range(archetype)
	if archetype == "ranged":
		if distance < preferred - 55.0:
			# 玩家貼近時優先後撤，並略為側移，遠程Boss不再傻站或反向貼臉。
			var side: Vector2 = Vector2(-direction.y, direction.x) * (1.0 if sin(float(boss["anim"])) >= 0.0 else -1.0)
			boss["pos"] += (-direction * speed * 1.08 + side * speed * 0.34) * delta
		elif distance > preferred + 95.0:
			boss["pos"] += direction * speed * 0.82 * delta
		else:
			var strafe: Vector2 = Vector2(-direction.y, direction.x) * (1.0 if sin(float(boss["anim"]) * 0.65) >= 0.0 else -1.0)
			boss["pos"] += strafe * speed * 0.42 * delta
	elif archetype == "hybrid":
		if distance < preferred - 45.0:
			boss["pos"] -= direction * speed * 0.55 * delta
		elif distance > preferred + 90.0:
			boss["pos"] += direction * speed * (1.16 if distance > 430.0 else 0.95) * delta
		else:
			var hybrid_strafe: Vector2 = Vector2(-direction.y, direction.x)
			boss["pos"] += hybrid_strafe * speed * 0.20 * delta
	else:
		if distance > 420.0:
			speed *= 1.18
		boss["pos"] += direction * speed * delta


func alpha30_boss_skill_name() -> String:
	if boss.is_empty():
		return "敵將絕技"
	match str(boss.get("id", "")):
		"zhangjiao": return "太平天雷"
		"huaxiong": return "西涼裂地斬"
		"lvbu": return "天下無雙"
		"caoren": return "鐵壁震軍"
		"zhanghe": return "巧變突襲"
		"gaoshun": return "陷陣衝鋒"
		_: return "敵將絕技"


func alpha30_boss_telegraph_duration() -> float:
	match str(boss.get("id", "")):
		"lvbu": return 1.05
		"zhangjiao": return 0.95
		"huaxiong", "gaoshun": return 0.78
		_: return 0.68


func alpha30_begin_boss_telegraph() -> void:
	if boss.is_empty() or float(boss.get("telegraph_time", 0.0)) > 0.0:
		return
	var duration: float = alpha30_boss_telegraph_duration()
	boss["telegraph_time"] = duration
	boss["telegraph_total"] = duration
	boss["telegraph_target"] = player.get("pos", boss.get("pos", Vector2.ZERO))
	boss["control_lock"] = duration
	boss_ability_banner = {
		"name": alpha30_boss_skill_name(),
		"time": duration,
		"max_time": duration,
		"warning": true
	}
	var warning_pos: Vector2 = boss.get("telegraph_target", boss.get("pos", Vector2.ZERO))
	Alpha31TelegraphShapes.append_visuals(zones, boss, warning_pos, duration)
	play_sfx("boss_warning", 1.0)
	show_message("%s正在蓄力，注意紅色預警區！" % alpha30_boss_skill_name(), duration)


func alpha30_update_boss_telegraph(delta: float) -> bool:
	var remaining: float = float(boss.get("telegraph_time", 0.0))
	if remaining <= 0.0:
		return false
	remaining = max(0.0, remaining - delta)
	boss["telegraph_time"] = remaining
	boss["control_lock"] = remaining
	if not boss_ability_banner.is_empty():
		boss_ability_banner["time"] = remaining
	if remaining <= 0.0:
		boss_ability_banner["warning"] = false
		start_boss_attack_timeline()
		boss_action_anim = {
			"time": 0.42,
			"max_time": 0.42,
			"kind": "special_release"
		}
		screen_shake = max(screen_shake, 8.0)
		return false
	return true


func update_boss(delta: float) -> void:
	# Boss生成只能由章節狀態機從LOCKED切到INTRO一次。
	# 任何結算、死亡、選單或已擊敗狀態都不允許重新生成。
	if screen != "game":
		return
	if not boss.is_empty():
		StatusEffectService.tick_boss(self, delta)
		if boss.is_empty():
			return
		if StatusEffectService.boss_stunned(boss):
			return
	if chapter_manager.request_boss_intro(elapsed):
		spawn_boss()
		return
	if not chapter_manager.boss_is_active():
		return
	if boss.is_empty():
		return
	if bool(boss.get("downed", false)):
		boss["anim"] = float(boss["anim"]) + delta * 1.5
		finish_boss_if_ready()
		return
	boss["anim"] = float(boss["anim"]) + delta * 5.5
	boss["attack_cd"] = max(0.0, float(boss["attack_cd"]) - delta)
	var alpha35_special_delta: float = delta / Alpha35BossPhaseEnrage.special_cooldown_mult(str(boss.get("id", ""))) if int(boss_phase_state.get("phase", 1)) >= 2 else delta
	boss["special_cd"] = max(0.0, float(boss["special_cd"]) - alpha35_special_delta)
	if alpha30_update_boss_telegraph(delta):
		boss["anim"] = float(boss["anim"]) + delta * 1.8
		return
	boss["contact_cd"] = max(0.0, float(boss["contact_cd"]) - delta)
	boss["charge_time"] = max(0.0, float(boss["charge_time"]) - delta)
	boss["dodge_cd"] = max(0.0, float(boss.get("dodge_cd", 0.0)) - delta)
	boss["sidestep_time"] = max(0.0, float(boss.get("sidestep_time", 0.0)) - delta)
	var diff: Vector2 = player["pos"] - boss["pos"]
	var phase: int = 2 if float(boss["hp"]) <= float(boss["max_hp"]) * 0.52 else 1
	boss["phase"] = phase
	if float(boss.get("sidestep_time", 0.0)) > 0.0:
		var sidestep_dir: Vector2 = boss.get("sidestep_dir", Vector2.ZERO)
		boss["pos"] += sidestep_dir * 410.0 * delta
	elif float(boss["charge_time"]) > 0.0:
		boss["pos"] += (
			boss["charge_dir"]
			* (365.0 if boss["id"] == "lvbu" else (330.0 if boss["id"] == "gaoshun" else 285.0))
			* delta
		)
	else:
		move_boss_by_archetype(diff, delta, phase)
	if diff.length() < float(boss["radius"]) + 22.0 and float(boss["contact_cd"]) <= 0.0:
		boss["contact_cd"] = 0.56 if phase == 1 else 0.42
		damage_player(
			float(boss["damage"]) * boss_threat_damage_multiplier(),
			"boss",
			0.12 if phase == 2 and str(boss.get("archetype", "melee")) == "melee" else 0.0
		)
	if float(boss["attack_cd"]) <= 0.0:
		boss_basic_attack()
		var archetype: String = str(boss.get("archetype", "melee"))
		if boss["id"] == "lvbu":
			boss["attack_cd"] = 1.78 if phase == 1 else 1.18
		elif boss["id"] == "caoren":
			boss["attack_cd"] = 2.20 if phase == 1 else 1.58
		elif archetype == "ranged":
			boss["attack_cd"] = 1.72 if phase == 1 else 1.18
		elif archetype == "hybrid":
			boss["attack_cd"] = 1.92 if phase == 1 else 1.30
		else:
			boss["attack_cd"] = 2.25 if phase == 1 else 1.62
		boss["attack_cd"] = max(0.56, float(boss["attack_cd"]) / boss_attack_speed_multiplier(phase))
	if float(boss["special_cd"]) <= 0.0:
		alpha30_begin_boss_telegraph()
		if boss["id"] == "lvbu":
			boss["special_cd"] = 6.4 if phase == 1 else 4.35
		elif boss["id"] in ["caoren", "zhanghe"]:
			boss["special_cd"] = 7.2 if phase == 1 else 5.0
		else:
			boss["special_cd"] = 8.5 if phase == 1 else 6.1
		boss["special_cd"] = max(2.8, float(boss["special_cd"]) / boss_attack_speed_multiplier(phase))
	var boss_pos: Vector2 = boss["pos"]
	boss_pos.x = clamp(boss_pos.x, 42.0, WORLD.size.x - 42.0)
	boss_pos.y = clamp(boss_pos.y, 42.0, WORLD.size.y - 42.0)
	boss["pos"] = boss_pos


func story_adjusted_boss_definition() -> Dictionary:
	var definition: Dictionary = chapter_manager.boss_definition()
	var cid: String = str(current_chapter().get("id", ""))
	# 重大抉擇至少會回收到Boss血量、傷害、速度、副將或技能節奏其中一項。
	var hp_mult: float = 1.0
	var dmg_mult: float = 1.0
	var speed_mult: float = 1.0
	var extra_support: bool = false
	if history_flags.has("zhuo_oath") and cid in ["hulao_coalition", "xuzhou_flames"]:
		hp_mult *= 0.92
	if history_flags.has("hulao_vanguard") and cid in ["xuzhou_flames", "guandu_showdown"]:
		dmg_mult *= 1.08
	if history_flags.has("xuzhou_people") and cid in ["jingzhou_retreat", "changban_escape"]:
		dmg_mult *= 0.94
	if history_flags.has("xuzhou_seize_arms") and cid in ["guandu_showdown", "jingzhou_retreat"]:
		extra_support = true
	if history_flags.has("guandu_raid") and cid in ["guandu_showdown", "jingzhou_retreat"]:
		hp_mult *= 0.86
		speed_mult *= 1.06
	if history_flags.has("jingzhou_people_first") and cid in ["changban_escape", "red_cliffs"]:
		dmg_mult *= 0.92
		extra_support = true
	if history_flags.has("jingzhou_wu_route") and cid in ["red_cliffs", "jingzhou_campaign"]:
		hp_mult *= 0.90
	var branch_profile: Dictionary = current_stage_branch_profile()
	var branch_variant: String = str(branch_profile.get("boss_variant", "standard"))
	if branch_variant in ["double_vanguard", "caowei_counterattack", "chaos_fleet"]:
		extra_support = true
	if branch_variant == "fire_attack_success":
		hp_mult *= 0.92
	if branch_variant == "wu_fire_command":
		dmg_mult *= 1.10
	definition["hp"] = float(definition.get("hp", 1680.0)) * hp_mult
	definition["damage"] = float(definition.get("damage", 14.0)) * dmg_mult
	definition["speed"] = float(definition.get("speed", 68.0)) * speed_mult
	definition["story_variant"] = true
	definition["extra_support"] = extra_support
	return definition


func spawn_boss() -> void:
	if not chapter_manager.boss_is_intro():
		return
	boss_spawned = true
	current_encounter = ""
	encounter_candidates.clear()
	merchant_active = false
	var definition: Dictionary = story_adjusted_boss_definition()
	var branch_profile: Dictionary = current_stage_branch_profile()
	var branch_difficulty: float = float(branch_profile.get("difficulty_mult", 1.0))
	var bid: String = str(definition.get("id", "zhangliang"))
	var hp: float = (
		float(definition.get("hp", 1680.0))
		* float(history_modifiers.get("boss_hp_mult", 1.0))
		* branch_difficulty
	)
	var spawn_pos: Vector2 = player["pos"] + Vector2(480.0, 0.0)
	spawn_pos.x = clamp(spawn_pos.x, 80.0, WORLD.size.x - 80.0)
	spawn_pos.y = clamp(spawn_pos.y, 80.0, WORLD.size.y - 80.0)
	boss = {
		"id": bid,
		"archetype": boss_combat_archetype(bid),
		"pos": spawn_pos,
		"hp": hp,
		"max_hp": hp,
		"speed":
		float(definition.get("speed", 68.0)) * float(history_modifiers.get("boss_speed_mult", 1.0)),
		"damage":
		(
			float(definition.get("damage", 14.0))
			* float(history_modifiers.get("boss_damage_mult", 1.0))
			* branch_difficulty
			* 1.12
		),
		"radius": float(definition.get("radius", 42.0)),
		"attack_cd": 1.15,
		"special_cd": 3.9,
		"contact_cd": 0.0,
		"charge_time": 0.0,
		"charge_dir": Vector2.ZERO,
		"dodge_cd": 1.4,
		"sidestep_time": 0.0,
		"sidestep_dir": Vector2.ZERO,
		"special_cycle": 0,
		"phase": 1,
		"branch_route": str(branch_profile.get("route", "neutral")),
		"branch_variant": str(branch_profile.get("boss_variant", "standard")),
		"downed": false,
		"anim": 0.0
	}
	var support_definition: Dictionary = current_chapter().get("support_boss", {}).duplicate(true)
	if support_definition.is_empty() and bool(definition.get("extra_support", false)):
		support_definition = {"id":"story_reinforcement","name":"史勢追兵","kind":"elite","hp":760.0,"damage":13.0,"sprite":"enemy_elite"}
	if not support_definition.is_empty():
		var support_kind: String = str(support_definition.get("kind", "elite"))
		spawn_enemy(support_kind, spawn_pos + Vector2(-150.0, 115.0))
		if not enemies.is_empty():
			var support_enemy: Dictionary = enemies[enemies.size() - 1]
			support_enemy["boss_support"] = true
			support_enemy["support_id"] = str(support_definition.get("id", "support"))
			support_enemy["ability_cd"] = 1.2
			support_enemy["name"] = str(support_definition.get("name", "副將"))
			support_enemy["hp"] = float(support_definition.get("hp", 900.0)) * chapter_difficulty()
			support_enemy["max_hp"] = support_enemy["hp"]
			support_enemy["damage"] = float(support_definition.get("damage", 14.0))
			support_enemy["radius"] = 26.0
			support_enemy["elite"] = true
			support_enemy["sprite"] = str(support_definition.get("sprite", "enemy_elite"))
			enemies[enemies.size() - 1] = support_enemy
			show_message("%s與主將同時壓陣！" % support_enemy["name"], 2.6)
	if has_relic("tigerseal"):
		for h in active_heroes:
			hero_cooldowns[h] = 0.0
	if boss_cooperation_multiplier() > 1.0:
		for h in active_heroes:
			hero_cooldowns[h] = min(float(hero_cooldowns.get(h, 0.0)), 1.5)
		show_message("歷史羈絆對此敵將產生特殊強化！", 3.0)
	boss_intro_timer = boss_intro_duration
	screen = "boss_intro"
	play_sfx("boss_intro")
	play_sfx("boss_warning")
	play_current_boss_bgm()
	enemy_shots.clear()
	show_message(
		"%s・%s" % [str(definition.get("title", "敵將")), str(definition.get("name", "未知"))], 2.5
	)


func boss_basic_attack() -> void:
	boss_action_anim = {"kind":"attack", "life":0.34, "max_life":0.34}
	var dir: Vector2 = (player["pos"] - boss["pos"]).normalized()
	match str(boss["id"]):
		"zhangliang":
			for angle_offset in [-0.28, 0.0, 0.28]:
				enemy_shots.append(
					{
						"kind": "spell",
						"pos": boss["pos"],
						"vel": dir.rotated(angle_offset) * 205.0,
						"damage": float(boss["damage"]) * 0.88 * boss_threat_damage_multiplier(),
						"life": 4.2,
						"radius": 10.0,
						"shield_pierce": 0.30
					}
				)
			play_sfx("poison", 0.65)
		"huaxiong":
			zones.append(
				{
					"kind": "enemy_warning",
					"pos": boss["pos"] + dir * 88.0,
					"r": 102.0,
					"life": 0.88,
					"damage": float(boss["damage"]) * 1.05 * boss_threat_damage_multiplier(),
					"color": Color8(217, 92, 51)
				}
			)
			play_sfx("slash", 0.62)
		"gaoshun":
			for offset in [-0.34, 0.0, 0.34]:
				zones.append(
					{
						"kind": "enemy_warning",
						"pos": boss["pos"] + dir.rotated(offset) * 118.0,
						"r": 66.0,
						"life": 0.78,
						"damage": float(boss["damage"]) * 1.12 * boss_threat_damage_multiplier(),
						"color": Color8(190, 170, 105)
					}
				)
			play_sfx("slash", 0.72)
		"lvbu":
			for offset in [-0.36, 0.0, 0.36]:
				zones.append(
					{
						"kind": "enemy_warning",
						"pos": boss["pos"] + dir.rotated(offset) * 112.0,
						"r": 76.0,
						"life": 0.58,
						"damage": float(boss["damage"]) * 1.18 * boss_threat_damage_multiplier(),
						"color": Color8(226, 64, 52)
					}
				)
			play_sfx("slash", 0.78)
		"caoren":
			for offset in [-0.30, 0.0, 0.30]:
				zones.append({"kind":"enemy_warning", "pos":boss["pos"] + dir.rotated(offset) * 108.0, "r":70.0, "life":0.72, "damage":float(boss["damage"]) * boss_threat_damage_multiplier(), "color":Color8(92, 132, 169)})
			play_sfx("slash", 0.68)
		"zhanghe":
			for offset in [-0.25, 0.0, 0.25]:
				enemy_shots.append({"kind":"bolt", "pos":boss["pos"], "vel":dir.rotated(offset) * 245.0, "damage":float(boss["damage"]) * 0.86 * boss_threat_damage_multiplier(), "life":4.0, "radius":7.0, "shield_pierce":0.18})
			play_sfx("arrow", 0.88)
		"yuanshao":
			for offset in [-0.42, -0.21, 0.0, 0.21, 0.42]:
				enemy_shots.append(
					{
						"kind": "arrow",
						"pos": boss["pos"],
						"vel": dir.rotated(offset) * 212.0,
						"damage": float(boss["damage"]) * 0.82 * boss_threat_damage_multiplier(),
						"life": 4.4,
						"radius": 8.0,
						"shield_pierce": 0.12
					}
				)
			play_sfx("arrow", 0.70)
		"caimao", "caocao", "simayi", "luxun":
			var spread_count: int = 4 if int(boss.get("phase", 1)) == 1 else 6
			for i in range(spread_count):
				var t: float = 0.0 if spread_count <= 1 else float(i) / float(spread_count - 1)
				var offset: float = lerp(-0.46, 0.46, t)
				enemy_shots.append({
					"kind":"spell",
					"pos":boss["pos"],
					"vel":dir.rotated(offset) * (235.0 if boss["id"] != "luxun" else 215.0),
					"damage":float(boss["damage"]) * 0.78 * boss_threat_damage_multiplier(),
					"life":4.4,
					"radius":9.0,
					"shield_pierce":0.22 if boss["id"] in ["simayi", "luxun"] else 0.14
				})
			play_sfx("poison" if boss["id"] == "simayi" else "arrow", 0.72)
		"xiahouyuan", "huangzhong", "zhangliao":
			for offset in [-0.20, 0.0, 0.20]:
				enemy_shots.append({"kind":"bolt", "pos":boss["pos"], "vel":dir.rotated(offset) * 270.0, "damage":float(boss["damage"]) * 0.90 * boss_threat_damage_multiplier(), "life":4.0, "radius":7.0, "shield_pierce":0.10})
			play_sfx("arrow", 0.86)
		_:
			zones.append(
				{
					"kind": "enemy_warning",
					"pos": boss["pos"] + dir * 95.0,
					"r": 115.0,
					"life": 0.72,
					"damage": float(boss["damage"]) * 1.08 * boss_threat_damage_multiplier(),
					"color": Color8(229, 74, 61)
				}
			)
			play_sfx("slash", 0.58)


func boss_special_attack() -> void:
	boss_action_anim = {"kind":"cast", "life":0.72, "max_life":0.72}
	match str(boss["id"]):
		"zhangliang":
			for i in range(5 if int(boss["phase"]) == 1 else 7):
				var pos: Vector2 = (
					player["pos"]
					+ Vector2.from_angle(rng.randf_range(0.0, TAU)) * rng.randf_range(30.0, 220.0)
				)
				zones.append(
					{
						"kind": "enemy_warning",
						"pos": pos,
						"r": 62.0,
						"life": 1.05,
						"damage": float(boss["damage"]) * 0.82 * boss_threat_damage_multiplier(),
						"color": Color8(218, 187, 65),
						"shield_pierce": 0.40
					}
				)
			show_message("張梁：黃天神雷，落！", 2.0)
		"huaxiong":
			boss["charge_dir"] = (player["pos"] - boss["pos"]).normalized()
			boss["charge_time"] = 0.78
			for i in range(3):
				zones.append(
					{
						"kind": "enemy_warning",
						"pos": boss["pos"] + boss["charge_dir"] * (70.0 + i * 85.0),
						"r": 48.0,
						"life": 0.95,
						"damage": float(boss["damage"]) * 1.05 * boss_threat_damage_multiplier(),
						"color": Color8(221, 101, 55)
					}
				)
			show_message("華雄：關東鼠輩，接我一刀！", 2.0)
		"lvbu":
			var cycle: int = int(boss.get("special_cycle", 0)) % 3
			boss["special_cycle"] = cycle + 1
			if cycle == 0:
				var dash_dir: Vector2 = player.get("dash_dir", Vector2.ZERO)
				var predicted: Vector2 = player["pos"] + dash_dir * 95.0
				boss["charge_dir"] = (predicted - boss["pos"]).normalized()
				boss["charge_time"] = 0.72
				for i in range(4):
					zones.append(
						{
							"kind": "enemy_warning",
							"pos": boss["pos"] + boss["charge_dir"] * (78.0 + i * 90.0),
							"r": 48.0,
							"life": 0.62,
							"damage": float(boss["damage"]) * 1.08,
							"color": Color8(232, 64, 52),
							"shield_pierce": 0.22
						}
					)
				show_boss_ability("你的退路，我早已看穿！", 1.8)
			elif cycle == 1:
				for i in range(8):
					var ring_pos: Vector2 = (
						boss["pos"] + Vector2.from_angle(float(i) / 8.0 * TAU) * 150.0
					)
					zones.append(
						{
							"kind": "enemy_warning",
							"pos": ring_pos,
							"r": 55.0,
							"life": 0.82,
							"damage": float(boss["damage"]),
							"color": Color8(215, 55, 48),
							"shield_pierce": 0.18
						}
					)
				show_boss_ability("方天亂舞！", 1.8)
			else:
				for offset in [-0.42, 0.0, 0.42]:
					var strike_pos: Vector2 = player["pos"] + Vector2.from_angle(offset) * 85.0
					zones.append(
						{
							"kind": "enemy_warning",
							"pos": strike_pos,
							"r": 88.0,
							"life": 0.68,
							"damage": float(boss["damage"]) * 1.12,
							"color": Color8(236, 73, 55),
							"shield_pierce": 0.28
						}
					)
				show_boss_ability("連環戟影・破！", 1.8)
		"gaoshun":
			boss["charge_dir"] = (player["pos"] - boss["pos"]).normalized()
			boss["charge_time"] = 0.84
			for i in range(2 + int(boss["phase"])):
				if enemies.size() >= int(current_chapter().get("max_enemies", 50)):
					break
				spawn_enemy(
					"shield" if i % 2 == 0 else "elite",
					boss["pos"] + Vector2.from_angle(float(i) / 4.0 * TAU) * 95.0
				)
			show_message("高順：陷陣之志，有死無生！", 2.0)
		"caoren":
			for i in range(3 + int(boss["phase"])):
				if enemies.size() >= int(current_chapter().get("max_enemies", 56)):
					break
				spawn_enemy("shield" if i % 2 == 0 else "spearman", boss["pos"] + Vector2.from_angle(float(i) / 5.0 * TAU) * 120.0)
			for ring_index in range(6):
				var caoren_pos: Vector2 = boss["pos"] + Vector2.from_angle(float(ring_index) / 6.0 * TAU) * 145.0
				zones.append({"kind":"enemy_warning", "pos":caoren_pos, "r":52.0, "life":0.92, "damage":float(boss["damage"]) * 0.92, "color":Color8(91, 135, 177)})
			show_message("曹仁：鐵壁合圍，寸步不讓！", 2.0)
		"zhanghe":
			var zhanghe_cycle: int = int(boss.get("special_cycle", 0)) % 2
			boss["special_cycle"] = zhanghe_cycle + 1
			if zhanghe_cycle == 0:
				boss["charge_dir"] = (player["pos"] - boss["pos"]).normalized()
				boss["charge_time"] = 0.66
				for i in range(4):
					zones.append({"kind":"enemy_warning", "pos":boss["pos"] + boss["charge_dir"] * (72.0 + i * 82.0), "r":43.0, "life":0.62, "damage":float(boss["damage"]) * 1.03, "color":Color8(187, 176, 139)})
				show_message("張郃：隨勢而變，破其一點！", 1.8)
			else:
				for i in range(7):
					var target_pos: Vector2 = player["pos"] + Vector2.from_angle(rng.randf_range(0.0, TAU)) * rng.randf_range(35.0, 230.0)
					zones.append({"kind":"enemy_warning", "pos":target_pos, "r":48.0, "life":0.78, "damage":float(boss["damage"]) * 0.88, "color":Color8(199, 183, 137)})
				show_message("張郃：變陣！槍雨封路！", 1.8)
		"yuanshao":
			for i in range(6 if int(boss["phase"]) == 1 else 9):
				var target_pos: Vector2 = (
					player["pos"]
					+ Vector2.from_angle(rng.randf_range(0.0, TAU)) * rng.randf_range(45.0, 260.0)
				)
				zones.append(
					{
						"kind": "enemy_warning",
						"pos": target_pos,
						"r": 54.0,
						"life": 1.0,
						"damage": float(boss["damage"]) * 1.08 * boss_threat_damage_multiplier(),
						"color": Color8(202, 165, 82)
					}
				)
			if enemies.size() < int(current_chapter().get("max_enemies", 54)):
				spawn_enemy("cavalry", boss["pos"] + Vector2(-90, 50))
			if enemies.size() < int(current_chapter().get("max_enemies", 54)):
				spawn_enemy("shield", boss["pos"] + Vector2(-90, -50))
			show_message("袁紹：河北精銳，合圍此人！", 2.0)
		_:
			boss["charge_dir"] = (player["pos"] - boss["pos"]).normalized()
			boss["charge_time"] = 0.95
			for i in range(3):
				zones.append(
					{
						"kind": "enemy_warning",
						"pos": player["pos"] + boss["charge_dir"] * i * 85.0,
						"r": 52.0,
						"life": 0.72,
						"damage": float(boss["damage"]) * 1.12 * boss_threat_damage_multiplier(),
						"color": Color8(231, 70, 55),
						"shield_pierce": 0.20
					}
				)
			show_boss_ability("敵將猛攻——避開殺陣！", 2.0)


func end_run(victory: bool) -> void:
	if screen in ["game_over", "victory", "ending", "intermission"]:
		return
	enemy_shots.clear()
	player_shots.clear()
	zones.clear()
	allies.clear()
	current_encounter = ""
	encounter_candidates.clear()
	merchant_active = false
	camp_active = false
	chest_active = false
	if victory:
		boss_spawned = false
		prepare_boss_loot()
		screen = "boss_loot"
	else:
		boss_spawned = false
		screen = "game_over"
		if int(run_stats.get("arrows_taken", 0)) > int(run_stats.get("contact_taken", 0)):
			game_over_reason = "主要受創來源：敵方箭矢。留意紅色瞄準線，或尋找防守型名將。"
		else:
			game_over_reason = "主要受創來源：近身包圍。保留閃避，並利用張飛、華佗等技能脫困。"
	boss.clear()
	option_index = 0
	play_bgm("victory" if victory else "defeat", 0.9)
	if victory:
		play_sfx("equipment_drop", 1.0)


func self_test_fail(reason: String) -> void:
	push_error("DEMO6_SELF_TEST_FAIL: %s" % reason)
	print("DEMO6_SELF_TEST_FAIL: ", reason)
	get_tree().quit(1)


func run_self_test() -> void:
	print("DEMO6_SELF_TEST_BEGIN")
	if not asset_errors.is_empty():
		self_test_fail("素材載入失敗：%s" % str(asset_errors))
		return
	if menu_bg == null or menu_bg.get_width() < 100:
		self_test_fail("選單背景無法讀取")
		return
	if portrait_tex.size() < identities.size() + heroes.size() + 9:
		self_test_fail("武將或Boss肖像數量不足")
		return
	if (
		sprite_tex.size() < 36
		or relic_tex.size() < 18
		or map_tex.size() < 7
		or prop_tex.size() < 13
	):
		self_test_fail("像素角色、遺物圖示、地圖或戰場物件數量不足")
		return
	var chapters: Array = GameData.chapters()
	if chapters.size() < 12:
		self_test_fail("正式章節資料不足七章")
		return
	for chapter_value in chapters:
		var chapter: Dictionary = chapter_value
		if not bool(chapter.get("ready", false)):
			self_test_fail("存在未啟用章節：%s" % str(chapter.get("id", "")))
			return
	if (chapters[2].get("enemy_weights", {}) as Dictionary).get("crossbow", 0.0) <= 0.0:
		self_test_fail("第三章後新兵種未接入生成權重")
		return
	var support_boss_chapters: int = 0
	for chapter_value in chapters:
		var support_chapter: Dictionary = chapter_value
		var support_data: Dictionary = support_chapter.get("support_boss", {}) as Dictionary
		if support_data.is_empty():
			continue
		support_boss_chapters += 1
		if (
			str(support_data.get("id", "")).is_empty()
			or str(support_data.get("name", "")).is_empty()
			or float(support_data.get("hp", 0.0)) <= 0.0
			or float(support_data.get("damage", 0.0)) <= 0.0
		):
			self_test_fail("雙Boss副將資料不完整：%s" % str(support_chapter.get("id", "")))
			return
	if support_boss_chapters < 4:
		self_test_fail("中後期雙Boss資料不足四章")
		return
	if (
		int(chapters[0].get("active_limit", 0)) != 2
		or int(chapters[1].get("active_limit", 0)) != 2
		or int(chapters[2].get("active_limit", 0)) != 3
		or int(chapters[3].get("active_limit", 0)) != 3
		or int(chapters[4].get("active_limit", 0)) != 3
		or int(chapters[5].get("active_limit", 0)) != 3
		or int(chapters[6].get("active_limit", 0)) != 4
	):
		self_test_fail("主動名將上限不是第1章2、第3章3、第7章4、第10章5")
		return
	if history_event_defs.size() < 7:
		self_test_fail("史勢奇遇資料不足七章")
		return
	for chapter_id_value in history_event_defs.keys():
		var chapter_id: String = str(chapter_id_value)
		var chapter_events_value: Variant = history_event_defs.get(chapter_id, [])
		if not (chapter_events_value is Array) or (chapter_events_value as Array).size() < 2:
			self_test_fail("每章史勢奇遇不足兩組：%s" % chapter_id)
			return
	for audio_key in [
		"bgm_chapter1",
		"bgm_chapter2",
		"bgm_chapter3",
		"bgm_chapter4",
		"bgm_chapter5",
		"bgm_chapter6",
		"bgm_chapter7",
		"bgm_boss",
		"bgm_boss_lvbu"
	]:
		if not audio_streams.has(audio_key) or audio_streams[audio_key] == null:
			self_test_fail("章節或Boss音樂載入失敗：%s" % audio_key)
			return
	start_run("story", "swordsman")
	player["dash_timer"] = 0.0
	try_dash()
	if float(player.get("dash_timer", 0.0)) < 0.70 or float(player.get("dash_active", 0.0)) <= 0.0:
		self_test_fail("閃避冷卻或位移狀態失效")
		return
	player["dash_timer"] = 0.0
	player["dash_active"] = 0.0
	var chapter_events: Array = chapter_history_event_definitions()
	if chapter_events.size() < 2:
		self_test_fail("第一章史勢奇遇未提供雙事件")
		return
	var event_def: Dictionary = chapter_events[0] as Dictionary
	var event_options: Array = event_def.get("options", []) as Array
	if str(event_def.get("id", "")) != "zhuo_starving_villagers" or event_options.size() != 3:
		self_test_fail("第一章史勢奇遇資料或選項錯誤")
		return
	var special_option: Dictionary = event_options[2] as Dictionary
	if history_option_available(special_option):
		self_test_fail("未結識名將時特殊史勢選項不應開放")
		return
	known_heroes["liubei"] = true
	reserve_heroes = ["liubei"]
	if history_option_available(special_option):
		self_test_fail("後備名將不應解鎖史勢特殊選項")
		return
	active_heroes = ["liubei"]
	reserve_heroes.clear()
	if not history_option_available(special_option):
		self_test_fail("主動劉備仍無法解鎖史勢特殊選項")
		return
	known_heroes.clear()
	active_heroes.clear()
	particles.clear()
	damage_numbers.clear()
	player_shots.clear()
	zones.clear()
	for i in range(MAX_PARTICLES + 25):
		particles.append(
			{
				"pos": player["pos"],
				"vel": Vector2.ZERO,
				"life": 1.0,
				"max_life": 1.0,
				"color": Color.WHITE,
				"size": 2.0
			}
		)
	for i in range(MAX_DAMAGE_NUMBERS + 12):
		damage_numbers.append(
			{"pos": player["pos"], "text": "1", "life": 1.0, "color": Color.WHITE}
		)
	for i in range(MAX_PLAYER_SHOTS + 20):
		player_shots.append(
			{
				"kind": "test",
				"pos": player["pos"],
				"vel": Vector2.ZERO,
				"life": 1.0,
				"radius": 1.0,
				"damage": 1.0,
				"poison": 0.0,
				"pierce": 0,
				"hit_ids": []
			}
		)
	for i in range(MAX_ZONES + 10):
		zones.append({"kind": "ring_visual", "pos": player["pos"], "r": 10.0, "life": 1.0})
	performance_cleanup_timer = 0.0
	update_performance_guard(1.0)
	if (
		particles.size() > MAX_PARTICLES
		or damage_numbers.size() > MAX_DAMAGE_NUMBERS
		or player_shots.size() > MAX_PLAYER_SHOTS
		or zones.size() > MAX_ZONES
	):
		self_test_fail("中後期物件上限清理失效")
		return
	particles.clear()
	damage_numbers.clear()
	player_shots.clear()
	zones.clear()
	performance_pressure = "穩定"
	# Alpha.28：以乾淨狀態分別驗證「新取得」與「重複取得升級」，
	# 避免既有章節上限或隨機抽到已持有遺物，讓自測誤判授予流程失效。
	relics.clear()
	relic_levels.clear()
	chapter_natural_relics = 0
	var offered_relic: String = random_relic_offer()
	if offered_relic == "":
		self_test_fail("遺物池未提供可授予項目")
		return
	if not grant_relic(offered_relic, "自動測試取得", false):
		self_test_fail("新遺物授予流程失效")
		return
	if not relics.has(offered_relic) or relic_level(offered_relic) != 1:
		self_test_fail("新遺物未正確加入背包或等級不是Lv.1")
		return
	var relic_count_after_first_grant: int = relics.size()
	if not grant_relic(offered_relic, "自動測試升級", false):
		self_test_fail("既有遺物升級流程失效")
		return
	if relics.size() != relic_count_after_first_grant or relic_level(offered_relic) != 2:
		self_test_fail("既有遺物升級後數量或等級異常")
		return
	if pending_relic_notice.is_empty() or str(pending_relic_notice.get("id", "")) != offered_relic:
		self_test_fail("新遺物提示未建立")
		return
	if int(pending_relic_notice.get("new_level", 0)) != 2 or not bool(pending_relic_notice.get("upgraded", false)):
		self_test_fail("遺物升級提示內容錯誤")
		return
	pending_relic_notice.clear()
	known_heroes = {"liubei": true, "guanyu": true, "zhangfei": true}
	active_heroes = ["liubei"]
	reserve_heroes = ["guanyu", "zhangfei"]
	hero_levels = {"liubei": 1, "guanyu": 1, "zhangfei": 1}
	player["hp"] = float(player["max_hp"]) * 0.50
	player["shield"] = 0.0
	camp_active = true
	camp_pos = player["pos"]
	current_encounter = ""
	encounter_candidates.clear()
	merchant_active = false
	chest_active = false
	try_interact()
	var expected_camp_hp: float = float(player["max_hp"]) * 0.72
	var expected_camp_shield: float = float(player["max_hp"]) * 0.12
	if (
		screen != "camp_menu"
		or known_hero_order().size() != 3
		or abs(float(player["hp"]) - expected_camp_hp) > 0.1
		or abs(float(player["shield"]) - expected_camp_shield) > 0.1
	):
		self_test_fail("營地回復、護盾或營地選單失效")
		return
	screen = "game"
	enemies.clear()
	spawn_enemy("peasant", player["pos"] + Vector2(58.0, 0.0))
	spawn_enemy("sword", player["pos"] + Vector2(82.0, 12.0))
	var before_count: int = enemies.size()
	var impact_before: int = zones.size()
	damage_arc(player["pos"], 0.0, 120.0, 2.2, 999.0, 0.0)
	if enemies.size() >= before_count or zones.size() <= impact_before:
		self_test_fail("近戰傷害、命中特效或擊殺流程失效")
		return
	hit_stop_timer = 0.0
	hit_stop_cooldown = 0.0
	enemies.clear()
	spawn_enemy("peasant", player["pos"] + Vector2(58.0, 0.0))
	damage_enemy(0, 12.0, "arrow", false)
	if hit_stop_timer > 0.0:
		self_test_fail("普通連射仍會造成全場停頓")
		return
	enemies.clear()
	boss = {
		"id": "zhangliang",
		"pos": player["pos"] + Vector2(62.0, 0.0),
		"hp": 500.0,
		"max_hp": 500.0,
		"radius": 42.0,
		"anim": 0.0
	}
	var boss_hp_before: float = float(boss["hp"])
	perform_auto_attack()
	if float(boss.get("hp", boss_hp_before)) >= boss_hp_before:
		self_test_fail("單獨Boss鎖定或攻擊失效")
		return
	boss.clear()
	var test_offsets: Array[Vector2] = [Vector2(70, 0), Vector2(95, 35), Vector2(90, -42)]
	for hero_key in heroes.keys():
		var hero_id: String = str(hero_key)
		enemies.clear()
		for offset in test_offsets:
			spawn_enemy("peasant", player["pos"] + offset)
		active_heroes = [hero_id]
		reserve_heroes.clear()
		hero_levels[hero_id] = 3
		hero_cooldowns[hero_id] = 0.0
		zones.clear()
		hero_cast_flash.clear()
		try_trigger_hero(hero_id, true)
		var signature_found: bool = false
		for zone_value in zones:
			var zone: Dictionary = zone_value
			# Alpha.58：名將可以使用直線、箭雨、風牆等專屬形態，不再強迫全部生成通用 hero_effect。
			# 每輪測試前 zones 都已清空，因此本次新生成的 hero_* 視覺即可證明該名將有專屬演出。
			if str(zone.get("kind", "")).begins_with("hero_"):
				signature_found = true
				break
		if not signature_found or str(hero_cast_flash.get("id", "")) != hero_id:
			self_test_fail("名將專屬技能特效失效：%s" % hero_id)
			return
	for enemy_kind in ["peasant", "sword", "archer", "elite", "cavalry", "shield", "spearman", "tactician"]:
		enemies.clear()
		spawn_enemy(enemy_kind, player["pos"] + Vector2(90.0, 0.0))
		if enemies.is_empty() or str(enemies[0].get("kind", "")) != enemy_kind:
			self_test_fail("敵兵生成失效：%s" % enemy_kind)
			return
	boss = {"id": "lvbu"}
	active_bonds = ["taoyuan"]
	if abs(boss_cooperation_multiplier() - 1.18) > 0.001:
		self_test_fail("桃園結義對呂布的特殊強化失效")
		return
	active_bonds.clear()
	boss.clear()
	for boss_id in ["zhangliang", "huaxiong", "lvbu", "gaoshun", "yuanshao", "caoren", "zhanghe"]:
		enemies.clear()
		enemy_shots.clear()
		zones.clear()
		boss = {
			"id": boss_id,
			"pos": player["pos"] + Vector2(180.0, 0.0),
			"hp": 500.0,
			"max_hp": 500.0,
			"speed": 90.0,
			"damage": 20.0,
			"radius": 48.0,
			"phase": 1,
			"charge_dir": Vector2.ZERO,
			"charge_time": 0.0,
			"dodge_cd": 0.0,
			"sidestep_time": 0.0,
			"sidestep_dir": Vector2.ZERO,
			"special_cycle": 0
		}
		boss_basic_attack()
		boss_special_attack()
	start_run("story", "swordsman")
	# start_run 會先進入章回開場畫面；自我測試需模擬玩家完成開場後回到戰場，
	# 否則 update_boss 依正式流程會因 screen != "game" 而不生成 Boss。
	screen = "game"
	elapsed = boss_time() + 1.0
	update_boss(0.0)
	if not chapter_manager.boss_is_intro() or boss.is_empty():
		self_test_fail("Boss首次生成狀態錯誤")
		return
	chapter_manager.mark_boss_active()
	screen = "game"
	boss["hp"] = 1.0
	damage_boss(10.0, "self_test", false)
	flush_pending_run_result()
	# 正式流程會先進入Boss戰利品畫面；只有玩家領取戰利品後，
	# finalize_chapter_victory 才會把章節由DEFEATED推進至RESOLVED。
	if screen != "boss_loot" or not chapter_manager.boss_is_defeated():
		self_test_fail("Boss擊敗後未進入戰利品結算狀態")
		return
	if pending_boss_loot.is_empty():
		self_test_fail("Boss擊敗後未建立戰利品資料")
		return
	accept_boss_loot()
	if screen != "victory" or not chapter_manager.boss_is_resolved():
		self_test_fail("領取Boss戰利品後未進入永久結算狀態")
		return
	update_boss(0.0)
	if not boss.is_empty() or not chapter_manager.boss_is_resolved():
		self_test_fail("Boss擊敗後再次生成")
		return
	if chapter_manager.request_boss_intro(boss_time() + 999.0):
		self_test_fail("已結算Boss仍能再次進入登場狀態")
		return
	if not chapter_manager.advance_to_next():
		self_test_fail("章節結算後無法推進至洛陽")
		return
	if chapter_manager.current_id() != "luoyang_turmoil" or chapter_manager.active_limit() != 2:
		self_test_fail("洛陽章索引或主動欄位錯誤")
		return
	if not chapter_manager.request_boss_intro(chapter_manager.boss_time() + 1.0):
		self_test_fail("洛陽Boss無法進入登場狀態")
		return
	chapter_manager.mark_boss_active()
	chapter_manager.mark_boss_defeated()
	chapter_manager.resolve_chapter()
	if not chapter_manager.advance_to_next():
		self_test_fail("章節結算後無法推進至虎牢關")
		return
	if chapter_manager.current_id() != "hulao_coalition" or chapter_manager.active_limit() != 3:
		self_test_fail("虎牢關索引或主動欄位錯誤")
		return
	var expected_progression: Array = [
		["xuzhou_flames", 3],
		["guandu_showdown", 3],
		["jingzhou_retreat", 3],
		["changban_escape", 4]
	]
	for progression in expected_progression:
		var expected_id: String = str(progression[0])
		var expected_limit: int = int(progression[1])
		if not chapter_manager.request_boss_intro(chapter_manager.boss_time() + 1.0):
			self_test_fail("後續章節Boss無法登場：%s" % expected_id)
			return
		chapter_manager.mark_boss_active()
		chapter_manager.mark_boss_defeated()
		chapter_manager.resolve_chapter()
		if not chapter_manager.advance_to_next():
			self_test_fail("無法推進後續章節：%s" % expected_id)
			return
		if chapter_manager.current_id() != expected_id or chapter_manager.active_limit() != expected_limit:
			self_test_fail("後續章節索引或欄位錯誤：%s" % expected_id)
			return
	if not chapter_manager.request_boss_intro(chapter_manager.boss_time() + 1.0):
		self_test_fail("長坂坡Boss無法登場")
		return
	chapter_manager.mark_boss_active()
	chapter_manager.mark_boss_defeated()
	chapter_manager.resolve_chapter()
	# 長坂坡並非最終章；章節資料已擴充至赤壁、荊州、漢中、夷陵與五丈原。
	# 測試應依目前章節資料動態走到最後一章，避免再次把特定章回寫死為終點。
	if not chapter_manager.has_next_chapter() or not chapter_manager.advance_to_next():
		self_test_fail("長坂坡結束後未正確銜接下一章")
		return
	if chapter_manager.current_id() != "red_cliffs":
		self_test_fail("長坂坡後章節不是赤壁之戰")
		return
	while true:
		var tested_chapter_id: String = chapter_manager.current_id()
		if not chapter_manager.request_boss_intro(chapter_manager.boss_time() + 1.0):
			self_test_fail("後期章節Boss無法登場：%s" % tested_chapter_id)
			return
		chapter_manager.mark_boss_active()
		chapter_manager.mark_boss_defeated()
		chapter_manager.resolve_chapter()
		if not chapter_manager.has_next_chapter():
			break
		if not chapter_manager.advance_to_next():
			self_test_fail("後期章節無法推進：%s" % tested_chapter_id)
			return
	var final_chapter_id: String = chapter_manager.current_id()
	if chapter_manager.story_chapters.is_empty() or final_chapter_id != str(chapter_manager.story_chapters[-1].get("id", "")):
		self_test_fail("章節流程未抵達資料中的最終章")
		return
	if chapter_manager.has_next_chapter() or chapter_manager.advance_to_next():
		self_test_fail("最終章結束後仍出現不存在的下一章：%s" % final_chapter_id)
		return
	# 驗證空間索引與章間存檔恢復。
	start_run("story", "swordsman")
	enemies.clear()
	spawn_enemy("peasant", player["pos"] + Vector2(40.0, 0.0))
	spawn_enemy("archer", player["pos"] + Vector2(260.0, 0.0))
	rebuild_enemy_spatial_index()
	var nearby_ids: Array = nearby_enemy_uids(player["pos"])
	if nearby_ids.is_empty() or enemy_uid_index.size() != enemies.size():
		self_test_fail("敵軍空間索引失效")
		return
	if not save_run_checkpoint():
		self_test_fail("章間存檔建立失效")
		return
	if not has_run_checkpoint():
		self_test_fail("章間存檔未寫入記憶體")
		return
	var saved_checkpoint: Dictionary = (save_data["run_save"] as Dictionary).duplicate(true)
	if int(saved_checkpoint.get("version", 0)) != CHECKPOINT_VERSION:
		self_test_fail("章間存檔版本錯誤")
		return
	var checkpoint_json: String = JSON.stringify(saved_checkpoint)
	var checkpoint_roundtrip: Variant = JSON.parse_string(checkpoint_json)
	if not (checkpoint_roundtrip is Dictionary):
		self_test_fail("章間存檔 JSON 序列化失效")
		return
	var roundtrip_data: Dictionary = checkpoint_roundtrip as Dictionary
	if int(roundtrip_data.get("version", 0)) != CHECKPOINT_VERSION:
		self_test_fail("章間存檔 JSON 往返版本錯誤")
		return
	if (roundtrip_data.get("player", {}) as Dictionary).is_empty():
		self_test_fail("章間存檔 JSON 往返角色資料遺失")
		return
	if (
		HUD_RELIC_RECT.intersects(HUD_HEADER_RECT)
		or HUD_HEADER_RECT.intersects(HUD_MINIMAP_RECT)
		or HUD_PLAYER_RECT.intersects(HUD_HERO_RAIL_RECT)
	):
		self_test_fail("HUD安全區互相重疊")
		return
	clear_run_checkpoint()
	screen = "victory"
	var final_options: Array[String] = result_options()
	if final_options.has("重玩本章") or final_options.has("再試一次"):
		self_test_fail("勝利畫面仍出現重玩本關功能")
		return
	boss = {"id": "lvbu", "hp": 1.0}
	player_shots.append({"kind": "test"})
	reset_run_data()
	if not boss.is_empty() or not player_shots.is_empty() or boss_spawned:
		self_test_fail("重開後Boss或投射物殘留")
		return
	print("DEMO6_SELF_TEST_OK")
	get_tree().quit(0)


func draw_debug_overlay() -> void:
	var active_sfx_count: int = 0
	for audio_player_value in sfx_players:
		var audio_player: AudioStreamPlayer = audio_player_value as AudioStreamPlayer
		if audio_player != null and audio_player.playing:
			active_sfx_count += 1
	var memory_mb: float = float(Performance.get_monitor(Performance.MEMORY_STATIC)) / 1048576.0
	var object_count: int = int(Performance.get_monitor(Performance.OBJECT_COUNT))
	var node_count: int = int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	var lines: Array[String] = [
		"F3 DEBUG",
		"FPS %d　EMA %.1fms　峰值 %.1fms" % [Engine.get_frames_per_second(), frame_time_ema * 1000.0, frame_peak_last_ms],
		"幀尖峰 %d　停頓 %d　保護L%d" % [frame_spikes_last, hit_stop_triggers_last, performance_level],
		"敵人 %d　敵箭 %d　我方彈 %d" % [enemies.size(), enemy_shots.size(), player_shots.size()],
		"區域 %d　友軍 %d　掉落 %d" % [zones.size(), allies.size(), pickups.size()],
		"粒子 %d　傷害字 %d　音效 %d" % [particles.size(), damage_numbers.size(), active_sfx_count],
		"記憶體 %.1fMB　物件 %d　節點 %d" % [memory_mb, object_count, node_count],
		"章節 %s　Boss %s　負載 %s" % [chapter_manager.current_id(), chapter_manager.boss_state_label(), performance_pressure],
		(
			"素材：肖像%d／角色%d／遺物%d　錯誤%d"
			% [portrait_tex.size(), sprite_tex.size(), relic_tex.size(), asset_errors.size()]
		)
	]
	draw_panel(
		Rect2(900, 382, 360, 242), Color(0.01, 0.012, 0.012, 0.88), Color8(210, 179, 97), 1.0
	)
	for i in range(lines.size()):
		draw_text(lines[i], Vector2(920, 416 + i * 22), 14, Color8(231, 226, 205), i == 0)


# -----------------------------------------------------------------------------
# 繪圖與UI
# -----------------------------------------------------------------------------


func camera_offset() -> Vector2:
	if player.is_empty():
		return Vector2.ZERO
	var base: Vector2 = CENTER - player["pos"]
	if bool(save_data["settings"].get("shake", true)) and screen_shake > 0.01:
		var phase: float = elapsed * 47.0
		base += Vector2(sin(phase), cos(phase * 1.31)) * screen_shake
	return base


func world_to_screen(pos: Vector2) -> Vector2:
	return pos + camera_offset()


func draw_panel(
	rect: Rect2,
	color := Color(0.045, 0.055, 0.063, 0.93),
	border := Color(0.63, 0.50, 0.29, 0.9),
	width := 2.0
) -> void:
	# V1.7.1.3：統一為「墨鐵底＋金屬描邊＋角飾」的三國介面語言。
	draw_rect(rect, color, true)
	draw_rect(rect, border, false, width)
	if rect.size.x >= 80.0 and rect.size.y >= 42.0:
		var inner: Rect2 = rect.grow(-5.0)
		draw_rect(inner, Color(border.r, border.g, border.b, border.a * 0.22), false, 1.0)
		var arm: float = min(14.0, min(rect.size.x, rect.size.y) * 0.18)
		var c: Color = Color(border.r, border.g, border.b, min(1.0, border.a * 0.86))
		draw_line(rect.position + Vector2(1, arm), rect.position + Vector2(1, 1), c, 2.0)
		draw_line(rect.position + Vector2(1, 1), rect.position + Vector2(arm, 1), c, 2.0)
		draw_line(Vector2(rect.end.x - arm, rect.position.y + 1), Vector2(rect.end.x - 1, rect.position.y + 1), c, 2.0)
		draw_line(Vector2(rect.end.x - 1, rect.position.y + 1), Vector2(rect.end.x - 1, rect.position.y + arm), c, 2.0)
		draw_line(Vector2(rect.position.x + 1, rect.end.y - arm), Vector2(rect.position.x + 1, rect.end.y - 1), c, 2.0)
		draw_line(Vector2(rect.position.x + 1, rect.end.y - 1), Vector2(rect.position.x + arm, rect.end.y - 1), c, 2.0)
		draw_line(Vector2(rect.end.x - arm, rect.end.y - 1), Vector2(rect.end.x - 1, rect.end.y - 1), c, 2.0)
		draw_line(Vector2(rect.end.x - 1, rect.end.y - arm), Vector2(rect.end.x - 1, rect.end.y - 1), c, 2.0)


func draw_screen_wash(strength: float = 0.32) -> void:
	# 淡墨分區與戰旗斜紋，避免純色背景像開發工具畫面。
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.008, 0.012, 0.012, strength), true)
	for i in range(9):
		var x: float = -120.0 + float(i) * 190.0
		draw_line(Vector2(x, 0), Vector2(x + 310.0, VIEW.y), Color(0.62, 0.49, 0.26, 0.035), 2.0)


func draw_section_header(title: String, subtitle: String, rect: Rect2) -> void:
	draw_text(title, rect.position + Vector2(0, 34), 30, Color8(241, 216, 158), true)
	draw_line(rect.position + Vector2(0, 48), rect.position + Vector2(rect.size.x, 48), Color(0.72, 0.56, 0.29, 0.62), 1.5)
	if subtitle != "":
		draw_text(subtitle, rect.position + Vector2(0, 72), 14, Color8(170, 181, 172), false, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x)


func draw_action_button(rect: Rect2, label: String, selected: bool, enabled: bool = true) -> void:
	var fill: Color = Color(0.42, 0.275, 0.09, 0.96) if selected else Color(0.045, 0.052, 0.052, 0.94)
	var edge: Color = Color8(237, 204, 126) if selected else Color8(101, 104, 94)
	var text_color: Color = Color8(242, 226, 190) if enabled else Color8(105, 109, 104)
	if not enabled:
		fill = Color(0.025, 0.03, 0.03, 0.82)
	draw_panel(rect, fill, edge, 1.8 if selected else 1.0)
	if selected:
		draw_rect(Rect2(rect.position + Vector2(8, rect.size.y - 5), Vector2(rect.size.x - 16, 2)), Color8(236, 201, 119), true)
	draw_centered_text(label, rect.grow(-4.0), rect.size.y * 0.64, 19, text_color, selected)


func draw_text(
	text: String,
	pos: Vector2,
	size := 20,
	color := Color.WHITE,
	bold := false,
	align := HORIZONTAL_ALIGNMENT_LEFT,
	width := -1.0
) -> void:
	draw_string(font_bold if bold else font, pos, text, align, width, size, color)


func draw_centered_text(
	text: String,
	rect: Rect2,
	baseline_offset: float,
	size := 20,
	color := Color.WHITE,
	bold := false
) -> void:
	draw_text(
		text,
		Vector2(rect.position.x, rect.position.y + baseline_offset),
		size,
		color,
		bold,
		HORIZONTAL_ALIGNMENT_CENTER,
		rect.size.x
	)


func draw_wrapped(
	text: String, rect: Rect2, size := 18, color := Color.WHITE, line_height := 25.0, bold := false
) -> float:
	var lines: Array = []
	for paragraph in text.split("\n"):
		var current: String = ""
		for ch in paragraph:
			var test: String = current + ch
			if (
				(
					(
						(font_bold if bold else font)
						. get_string_size(test, HORIZONTAL_ALIGNMENT_LEFT, -1, size)
						. x
					)
					> rect.size.x
				)
				and current != ""
			):
				lines.append(current)
				current = ch
			else:
				current = test
		lines.append(current)
	var y: float = rect.position.y + size
	for line in lines:
		draw_text(str(line), Vector2(rect.position.x, y), size, color, bold)
		y += line_height
		if y > rect.end.y:
			break
	return y


func draw_texture_contain(tex: Texture2D, rect: Rect2, modulate: Color = Color.WHITE) -> void:
	if tex == null or tex.get_width() <= 0 or tex.get_height() <= 0:
		return
	var source_size: Vector2 = Vector2(tex.get_width(), tex.get_height())
	var factor: float = min(rect.size.x / source_size.x, rect.size.y / source_size.y)
	var target_size: Vector2 = source_size * factor
	var target: Rect2 = Rect2(rect.position + (rect.size - target_size) * 0.5, target_size)
	draw_texture_rect(tex, target, false, modulate)


func draw_sprite_frame(
	tex: Texture2D, pos: Vector2, scale := 1.0, frame := 0, modulate := Color.WHITE
) -> void:
	if tex == null:
		return
	var fw: float = tex.get_width() / 4.0
	var fh: float = tex.get_height()
	var src: Rect2 = Rect2(fw * (frame % 4), 0.0, fw, fh)
	var dst: Rect2 = Rect2(pos - Vector2(fw, fh) * scale * 0.5, Vector2(fw, fh) * scale)
	draw_texture_rect_region(tex, dst, src, modulate)


func draw_sprite_pose(
	tex: Texture2D, pos: Vector2, base_scale: float, frame: int, modulate: Color,
	rotation: float = 0.0, stretch: Vector2 = Vector2.ONE
) -> void:
	# 只改變當次繪製座標，完成後立刻還原，避免影響 HUD 與其他物件。
	draw_set_transform(pos, rotation, stretch)
	draw_sprite_frame(tex, Vector2.ZERO, base_scale, frame, modulate)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func action_progress(anim: Dictionary) -> float:
	if anim.is_empty():
		return 0.0
	return clamp(1.0 - float(anim.get("life", 0.0)) / max(0.001, float(anim.get("max_life", 1.0))), 0.0, 1.0)


func _draw() -> void:
	match screen:
		"menu":
			draw_menu_screen()
		"character_select":
			draw_character_select_screen()
		"game":
			draw_game_screen()
		"boss_intro":
			draw_game_screen()
			draw_boss_intro_screen()
		"chapter_intro":
			draw_game_screen()
			draw_chapter_intro_screen()
		"levelup":
			draw_game_screen()
			draw_levelup_screen()
		"hero_encounter_pick":
			draw_game_screen()
			draw_hero_candidate_screen()
		"hero_encounter":
			draw_game_screen()
			draw_hero_encounter_screen()
		"history_event":
			draw_game_screen()
			draw_history_event_screen()
		"replace_hero":
			draw_game_screen()
			draw_replace_screen()
		"shop":
			draw_game_screen()
			draw_shop_screen()
		"tab":
			draw_game_screen()
			draw_tab_screen()
		"codex":
			draw_codex_screen()
		"skins":
			draw_skins_screen()
		"settings":
			draw_settings_screen()
		"load_save":
			draw_load_save_screen()
		"confirm_new_game", "confirm_delete_save":
			draw_save_confirmation_screen()
		"boss_loot":
			draw_boss_loot_screen()
		"ending":
			draw_ending_screen()
		"game_over", "victory":
			draw_result_screen()
		"intermission":
			draw_intermission_screen()
		"camp_menu":
			draw_camp_menu_screen()
		"hero_config":
			if hero_config_origin != "intermission":
				draw_game_screen()
			draw_hero_config_screen()
		"config_replace":
			if hero_config_origin != "intermission":
				draw_game_screen()
			draw_config_replace_screen()
	if not pending_relic_notice.is_empty():
		RelicNoticeUIScript.draw(self, pending_relic_notice)


func draw_menu_screen() -> void:
	draw_texture_rect(menu_bg, Rect2(Vector2.ZERO, VIEW), false)
	draw_screen_wash(0.30)
	# 左側主標題改為縱向章回式構圖，右側顯示旅程摘要。
	var title_panel: Rect2 = Rect2(58, 42, 700, 186)
	draw_panel(title_panel, Color(0.018, 0.024, 0.024, 0.90), Color(0.66, 0.52, 0.29, 0.94), 2.2)
	draw_text("三國人生錄", Vector2(88, 111), 49, Color8(242, 218, 166), true)
	draw_text("亂世倖存", Vector2(91, 158), 25, Color8(206, 216, 205), true)
	draw_line(Vector2(90, 176), Vector2(710, 176), Color(0.77, 0.61, 0.31, 0.55), 1.5)
	draw_text("V2.0.0 Alpha.17・亂世終卷", Vector2(91, 207), 15, Color8(170, 183, 173))
	var seal: Rect2 = Rect2(672, 72, 54, 72)
	draw_panel(seal, Color(0.34, 0.055, 0.045, 0.92), Color8(205, 119, 94), 1.6)
	draw_centered_text("亂
世", seal, 29.0, 18, Color8(242, 214, 176), true)

	var options: Array = menu_options()
	menu_index = clampi(menu_index, 0, max(0, options.size() - 1))
	var menu_panel: Rect2 = Rect2(68, 252, 520, 414)
	draw_panel(menu_panel, Color(0.012, 0.018, 0.018, 0.76), Color(0.38, 0.31, 0.19, 0.66), 1.4)
	draw_text("旅程選單", menu_panel.position + Vector2(22, 34), 18, Color8(213, 191, 141), true)
	for i in range(options.size()):
		var row: Rect2 = Rect2(88, 296 + i * 43, 480, 37)
		var enabled: bool = not (str(options[i]) == "繼續遊戲" and not has_run_checkpoint())
		draw_action_button(row, str(options[i]), i == menu_index, enabled)

	var info_panel: Rect2 = Rect2(804, 250, 410, 316)
	draw_panel(info_panel, Color(0.016, 0.022, 0.022, 0.91), Color8(112, 128, 101), 1.5)
	draw_text("亂世紀錄", info_panel.position + Vector2(22, 37), 22, Color8(190, 218, 184), true)
	if has_run_checkpoint():
		var summary: Dictionary = checkpoint_summary()
		draw_text(str(summary["chapter"]), info_panel.position + Vector2(22, 82), 20, Color8(235, 215, 170), true, HORIZONTAL_ALIGNMENT_LEFT, 360)
		draw_text("主角　%s" % summary["identity"], info_panel.position + Vector2(22, 122), 16, Color8(207, 214, 205))
		draw_wrapped("名將　%s" % summary["heroes"], Rect2(info_panel.position + Vector2(22, 140), Vector2(360, 48)), 15, Color8(196, 205, 197), 22.0)
		draw_text("遊玩時間　%s" % summary["time"], info_panel.position + Vector2(22, 213), 15, Color8(174, 191, 179))
		draw_text("最後存檔　%s" % summary["saved_at"], info_panel.position + Vector2(22, 246), 13, Color8(160, 178, 165), false, HORIZONTAL_ALIGNMENT_LEFT, 360)
		draw_text("可由繼續遊戲或讀取存檔恢復", info_panel.position + Vector2(22, 286), 13, Color8(145, 199, 154), true)
	else:
		draw_centered_text("尚未留下章間紀錄", info_panel.grow(-28.0), 128.0, 20, Color8(171, 180, 171), true)
		draw_centered_text("選擇開始新遊戲，寫下你的亂世人生。", info_panel.grow(-28.0), 170.0, 14, Color8(140, 153, 143))
	draw_text("WASD／方向鍵選擇　Enter／Space確認", Vector2(78, 700), 14, Color8(188, 197, 188))


func checkpoint_summary() -> Dictionary:
	if not has_run_checkpoint():
		return {}
	var cp: Dictionary = save_data.get("run_save", {}) as Dictionary
	var idx: int = int(cp.get("chapter_index", 0))
	var chapters: Array = GameData.chapters()
	var chapter_title: String = "未知章節"
	if idx >= 0 and idx < chapters.size():
		chapter_title = str((chapters[idx] as Dictionary).get("title", chapter_title))
	var identity_id: String = str(cp.get("identity", "swordsman"))
	var identity_name: String = identity_id
	if identities.has(identity_id):
		identity_name = str((identities[identity_id] as Dictionary).get("name", identity_id))
	var hero_names: Array[String] = []
	for hid in cp.get("active_heroes", []) as Array:
		var hero_id: String = str(hid)
		if heroes.has(hero_id):
			hero_names.append(str((heroes[hero_id] as Dictionary).get("name", hero_id)))
	var seconds: int = int(float(cp.get("elapsed_seconds", 0.0)))
	return {
		"chapter": "第%d章・%s" % [idx + 1, chapter_title],
		"identity": identity_name,
		"heroes": "、".join(hero_names) if not hero_names.is_empty() else "尚未配置",
		"time": "%02d:%02d:%02d" % [seconds / 3600, (seconds / 60) % 60, seconds % 60],
		"saved_at": str(cp.get("saved_at", save_data.get("last_saved_at", ""))),
		"version": str(cp.get("game_version", "舊版存檔"))
	}


func draw_load_save_screen() -> void:
	draw_texture_rect(menu_bg, Rect2(Vector2.ZERO, VIEW), false)
	draw_screen_wash(0.58)
	draw_section_header("讀取存檔", "確認章間紀錄後返回亂世。", Rect2(72, 42, 1080, 80))
	var panel: Rect2 = Rect2(130, 126, 1020, 410)
	draw_panel(panel, Color(0.02, 0.028, 0.028, 0.95), Color8(143, 126, 84), 2.0)
	var summary: Dictionary = checkpoint_summary()
	if summary.is_empty():
		draw_centered_text("目前沒有可讀取的章間存檔", panel, 210.0, 24, Color8(194, 194, 184), true)
	else:
		draw_text(str(summary["chapter"]), Vector2(172, 188), 28, Color8(235, 211, 157), true)
		draw_text("主角：%s" % summary["identity"], Vector2(174, 244), 20, Color8(220, 224, 213))
		draw_text("上場名將：%s" % summary["heroes"], Vector2(174, 285), 20, Color8(220, 224, 213))
		draw_text("本章遊玩時間：%s" % summary["time"], Vector2(174, 326), 18, Color8(188, 201, 190))
		draw_text("最後存檔：%s" % summary["saved_at"], Vector2(174, 365), 18, Color8(188, 201, 190))
		draw_text("存檔版本：%s" % summary["version"], Vector2(174, 404), 18, Color8(163, 183, 166))
		draw_text("存檔採暫存驗證與上一版備份保護", Vector2(174, 468), 16, Color8(142, 181, 151))
	var labels: Array[String] = ["載入此存檔", "返回主選單"]
	for i in range(labels.size()):
		var rect: Rect2 = Rect2(330 + i * 330, 578, 290, 54)
		draw_action_button(rect, labels[i], i == save_screen_index, not (i == 0 and summary.is_empty()))
	draw_text("方向鍵選擇　Enter確認　Esc返回", Vector2(72, 690), 15, Color8(190, 197, 190))


func draw_save_confirmation_screen() -> void:
	draw_menu_screen()
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.0, 0.0, 0.0, 0.58), true)
	var panel: Rect2 = Rect2(260, 205, 760, 310)
	draw_panel(panel, Color(0.025, 0.03, 0.03, 0.98), Color8(178, 139, 75), 2.0)
	var deleting: bool = screen == "confirm_delete_save"
	draw_centered_text("刪除存檔" if deleting else "開始新遊戲？", Rect2(300, 232, 680, 54), 38.0, 28, Color8(239, 211, 156), true)
	var line1: String = "目前章間進度將被刪除。" if deleting else "開始新遊戲將覆蓋目前的章間進度。"
	draw_centered_text(line1, Rect2(305, 308, 670, 40), 28.0, 19, Color8(228, 222, 205))
	draw_centered_text("永久解鎖、圖鑑、造型與設定不受影響。", Rect2(305, 352, 670, 40), 28.0, 17, Color8(170, 200, 174))
	var labels: Array[String] = ["確認", "取消"]
	for i in range(2):
		var rect: Rect2 = Rect2(365 + i * 290, 425, 250, 54)
		if i == confirm_index:
			draw_panel(rect, Color(0.40, 0.27, 0.10, 0.96), Color8(239, 211, 145), 1.8)
		else:
			draw_panel(rect, Color(0.06, 0.07, 0.065, 0.92), Color8(94, 99, 91), 1.0)
		draw_centered_text(labels[i], rect, 34.0, 20, Color8(235, 226, 201), i == confirm_index)

func identity_visual_id(id: String) -> String:
	if id == "archer" and (not portrait_tex.has(id) or not sprite_tex.has(id)):
		return "hunter"
	if id == "strategist" and (not portrait_tex.has(id) or not sprite_tex.has(id)):
		return "poisoner"
	return id


func weapon_display_name(id: String) -> String:
	match id:
		"blade":
			return "環首刀"
		"bow":
			return "北地長弓"
		"poison":
			return "百草毒針"
		"rings":
			return "紅袖環刃"
		"talisman":
			return "符籙法器"
	return id


func draw_character_select_screen() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color8(24, 31, 31), true)
	draw_text("選擇亂世出身", Vector2(48, 66), 34, Color8(239, 214, 152), true)
	draw_text(
		"%s模式｜難度：%s" % [("史傳" if chosen_mode == "story" else "演武試煉"), difficulty_name()],
		Vector2(1010, 62),
		18,
		Color8(190, 206, 195),
		true
	)
	var order: Array = identity_order()
	var card_margin: float = 32.0
	var card_gap: float = 12.0
	var card_width: float = (VIEW.x - card_margin * 2.0 - card_gap * 3.0) / 4.0
	var card_height: float = 510.0
	for i in range(order.size()):
		var id: String = str(order[i])
		if not identities.has(id):
			push_warning("Identity definition missing: %s" % id)
			continue
		var data: Dictionary = identities[id]
		var r: Rect2 = Rect2(card_margin + i * (card_width + card_gap), 112, card_width, card_height)
		draw_panel(
			r,
			Color(0.07, 0.08, 0.08, 0.96) if i != select_index else Color(0.19, 0.15, 0.085, 0.98),
			Color8(229, 200, 128) if i == select_index else Color8(100, 105, 98),
			3.0 if i == select_index else 1.5
		)
		var content_x: float = r.position.x + 16.0
		var content_w: float = r.size.x - 32.0
		var pr: Rect2 = Rect2(Vector2(content_x, r.position.y + 16.0), Vector2(content_w, 220.0))
		draw_texture_contain(hero_portrait(identity_visual_id(id)), pr)
		draw_text(data["name"], Vector2(content_x, r.position.y + 272.0), 23, data.get("color", Color8(222, 203, 150)), true)
		draw_text(
			"生命 %d　傷害 %d" % [data["hp"], data["damage"]],
			Vector2(content_x, r.position.y + 307.0),
			15,
			Color8(216, 218, 205)
		)
		draw_wrapped(
			data["desc"],
			Rect2(Vector2(content_x, r.position.y + 327.0), Vector2(content_w, 82.0)),
			13,
			Color8(199, 205, 196),
			19.0
		)
		draw_text(
			"專屬：%s" % PlayerUpgradeService.passive_name(id),
			Vector2(content_x, r.position.y + 438.0),
			12,
			Color8(169, 213, 185),
			true,
			HORIZONTAL_ALIGNMENT_LEFT,
			content_w
		)
		draw_text(
			"武器：%s" % weapon_display_name(str(data["weapon"])),
			Vector2(content_x, r.position.y + 478.0),
			14,
			Color8(232, 207, 145),
			true,
			HORIZONTAL_ALIGNMENT_LEFT,
			content_w
		)
	draw_text("方向鍵選擇　Enter／Space開始　Esc返回", Vector2(48, 684), 16, Color8(191, 198, 192))

func draw_game_screen() -> void:
	draw_world()
	draw_hud()
	if debug_overlay:
		draw_debug_overlay()


func draw_chapter_atmosphere(chapter: Dictionary) -> void:
	var cid: String = str(chapter.get("id", ""))
	var tint: Color = Color(0.05, 0.06, 0.05, 0.08)
	match cid:
		"zhuo": tint = Color(0.82, 0.61, 0.22, 0.055)
		"luoyang": tint = Color(0.82, 0.20, 0.08, 0.075)
		"hulao": tint = Color(0.56, 0.18, 0.12, 0.075)
		"xuzhou": tint = Color(0.18, 0.42, 0.28, 0.060)
		"guandu": tint = Color(0.66, 0.42, 0.13, 0.060)
		"redcliffs": tint = Color(0.80, 0.22, 0.07, 0.080)
		"jingzhou", "jingzhou_campaign": tint = Color(0.16, 0.40, 0.36, 0.060)
		"changban": tint = Color(0.54, 0.50, 0.40, 0.055)
		"hanzhong": tint = Color(0.27, 0.36, 0.48, 0.060)
		"yiling": tint = Color(0.75, 0.30, 0.08, 0.075)
		"wuzhang": tint = Color(0.30, 0.35, 0.48, 0.070)
	draw_rect(Rect2(Vector2.ZERO, VIEW), tint, true)
	# 輕量環境粒子：只繪製、不建立節點，保持效能穩定。
	var particle_color: Color = Color(0.86, 0.77, 0.52, 0.18)
	if cid in ["redcliffs", "luoyang", "yiling"]:
		particle_color = Color(1.0, 0.37, 0.12, 0.25)
	elif cid in ["wuzhang", "hanzhong"]:
		particle_color = Color(0.72, 0.82, 0.94, 0.18)
	for i in range(24):
		var px: float = fposmod(float(i * 149) + elapsed * (10.0 + i % 4), VIEW.x + 80.0) - 40.0
		var py: float = fposmod(float(i * 83) + sin(elapsed * 0.7 + i) * 34.0, VIEW.y + 60.0) - 30.0
		draw_circle(Vector2(px, py), 1.5 + float(i % 3), particle_color)
	# 電影感暗角，讓中央戰鬥與角色更聚焦。
	for ring in range(5):
		draw_rect(Rect2(8.0 + ring * 8.0, 8.0 + ring * 6.0, VIEW.x - 16.0 - ring * 16.0, VIEW.y - 16.0 - ring * 12.0), Color(0.01,0.012,0.012,0.07), false, 12.0)

func terrain_palette(chapter: Dictionary) -> Dictionary:
	var map_kind: String = str(chapter.get("map_kind", "village"))
	var base: Color = Color.from_string(str(chapter.get("ground_color", "#434e3e")), Color8(67, 78, 62))
	var palette: Dictionary = {
		"base": base,
		"road": base.lightened(0.12),
		"road_edge": base.darkened(0.16),
		"detail": base.lightened(0.20),
		"shadow": base.darkened(0.22),
		"water": Color8(58, 92, 105),
		"field": Color8(102, 107, 57)
	}
	match map_kind:
		"capital":
			palette["road"] = Color8(105, 101, 92)
			palette["road_edge"] = Color8(54, 51, 49)
			palette["detail"] = Color8(138, 126, 103)
		"fortress":
			palette["road"] = Color8(104, 88, 70)
			palette["road_edge"] = Color8(52, 39, 34)
			palette["detail"] = Color8(151, 119, 72)
		"guandu":
			palette["road"] = Color8(121, 91, 52)
			palette["field"] = Color8(118, 97, 49)
		"jingzhou", "changban":
			palette["water"] = Color8(44, 101, 111)
			palette["field"] = Color8(75, 112, 69)
	return palette


func draw_interactive_terrain_overlay(chapter: Dictionary, off: Vector2) -> void:
	# alpha.2：危險與減速地形使用形狀與邊界雙重提示，不只依賴顏色。
	var center_screen: Vector2 = WORLD.size * 0.5 + off
	var shape: String = str(chapter.get("map_shape", "open"))
	if shape == "river_channels":
		for band in [-1.0, 1.0]:
			var river_y: float = center_screen.y + band * 260.0
			for x in range(-40, int(VIEW.x) + 80, 72):
				draw_line(Vector2(x, river_y - 42), Vector2(x + 28, river_y - 42), Color(0.78, 0.92, 0.95, 0.28), 2.0)
				draw_line(Vector2(x + 18, river_y + 35), Vector2(x + 46, river_y + 35), Color(0.78, 0.92, 0.95, 0.22), 2.0)
	var cid: String = str(chapter.get("id", ""))
	if cid in ["luoyang", "redcliffs", "yiling"]:
		var cell: float = 180.0
		var sx: int = int(floor(-off.x / cell)) - 1
		var sy: int = int(floor(-off.y / cell)) - 1
		for gx in range(sx, sx + int(VIEW.x / cell) + 4):
			for gy in range(sy, sy + int(VIEW.y / cell) + 4):
				var code: int = abs(gx * 317 + gy * 911)
				var wp := Vector2(gx * cell + 90.0, gy * cell + 90.0)
				if code % 17 != 0 or wp.distance_to(WORLD.size * 0.5) <= 240.0:
					continue
				var sp: Vector2 = wp + off
				draw_circle(sp, 34.0, Color(0.82, 0.20, 0.06, 0.10))
				draw_arc(sp, 34.0, 0.0, TAU, 24, Color(1.0, 0.48, 0.16, 0.46), 2.0)
				for ray in range(6):
					var a: float = TAU * float(ray) / 6.0 + elapsed * 0.15
					draw_line(sp + Vector2.from_angle(a) * 13.0, sp + Vector2.from_angle(a) * 27.0, Color(1.0, 0.62, 0.24, 0.38), 2.0)


func portrait_faction_color(character_id: String) -> Color:
	var faction: String = "wanderer"
	if heroes.has(character_id):
		faction = str(heroes[character_id].get("faction", heroes[character_id].get("camp", "wanderer")))
	match faction:
		"shu": return Color8(92, 151, 94)
		"wei": return Color8(78, 116, 166)
		"wu": return Color8(174, 75, 66)
		"qun", "other": return Color8(139, 96, 157)
	return Color8(190, 151, 81)


func draw_remaster_portrait(character_id: String, rect: Rect2, emphasis: float = 1.0) -> void:
	# alpha.3：統一立繪框、陣營色、柔和光帶與呼吸感；保留既有像素角色。
	var accent: Color = portrait_faction_color(character_id)
	var pulse: float = (sin(elapsed * 1.7) + 1.0) * 0.5
	var grow_amount: float = 3.0 * pulse * emphasis
	draw_panel(rect, Color(0.018, 0.022, 0.023, 0.98), Color(accent, 0.72), 2.0 + pulse)
	var inner: Rect2 = rect.grow(-8.0 - grow_amount)
	if portrait_tex.has(character_id):
		draw_texture_contain(hero_portrait(str(character_id)), inner)
	draw_rect(Rect2(rect.position + Vector2(8, rect.size.y - 54), Vector2(rect.size.x - 16, 46)), Color(0.01, 0.012, 0.013, 0.76), true)
	draw_line(rect.position + Vector2(12, 12), rect.position + Vector2(rect.size.x - 12, 12), Color(accent, 0.58 + pulse * 0.22), 3.0)
	draw_line(rect.position + Vector2(12, rect.size.y - 12), rect.position + Vector2(rect.size.x - 12, rect.size.y - 12), Color(accent, 0.42), 2.0)


func draw_terrain_layers(chapter: Dictionary, off: Vector2) -> void:
	# V2.0 Alpha：以世界座標繪製章節地貌，避免背景貼圖跟著角色滑動。
	# 只使用固定公式，不消耗 rng，因此不會改變敵人、掉落或事件隨機序列。
	var palette: Dictionary = terrain_palette(chapter)
	var shape: String = str(chapter.get("map_shape", "open"))
	var map_kind: String = str(chapter.get("map_kind", "village"))
	var center_world: Vector2 = WORLD.size * 0.5
	var center_screen: Vector2 = center_world + off

	# 主道路／戰場動線。不同 map_shape 會有可辨識的骨架。
	if shape == "crossroads":
		draw_rect(Rect2(Vector2(0, center_screen.y - 96), Vector2(VIEW.x, 192)), palette["road"], true)
		draw_rect(Rect2(Vector2(center_screen.x - 112, 0), Vector2(224, VIEW.y)), palette["road"], true)
		draw_line(Vector2(0, center_screen.y - 98), Vector2(VIEW.x, center_screen.y - 98), palette["road_edge"], 4.0)
		draw_line(Vector2(0, center_screen.y + 98), Vector2(VIEW.x, center_screen.y + 98), palette["road_edge"], 4.0)
	elif shape in ["narrow", "long_road", "supply_corridor"]:
		draw_rect(Rect2(Vector2(0, center_screen.y - 112), Vector2(VIEW.x, 224)), palette["road"], true)
		draw_line(Vector2(0, center_screen.y - 114), Vector2(VIEW.x, center_screen.y - 114), palette["road_edge"], 5.0)
		draw_line(Vector2(0, center_screen.y + 114), Vector2(VIEW.x, center_screen.y + 114), palette["road_edge"], 5.0)
	elif shape == "courtyard":
		var yard := Rect2(center_screen - Vector2(470, 310), Vector2(940, 620))
		draw_rect(yard, palette["road"], true)
		draw_rect(yard, palette["road_edge"], false, 7.0)
	elif shape == "river_channels":
		for band in [-1.0, 1.0]:
			var river_y: float = center_screen.y + band * 260.0
			draw_rect(Rect2(Vector2(0, river_y - 54), Vector2(VIEW.x, 108)), palette["water"], true)
			draw_line(Vector2(0, river_y - 57), Vector2(VIEW.x, river_y - 57), palette["road_edge"], 4.0)
			draw_line(Vector2(0, river_y + 57), Vector2(VIEW.x, river_y + 57), palette["road_edge"], 4.0)
	else:
		draw_rect(Rect2(Vector2(0, center_screen.y - 74), Vector2(VIEW.x, 148)), palette["road"], true)

	# 地表斑駁、農田、石板接縫。固定網格確保攝影機移動時不漂浮。
	var cell: int = 128
	var start_x: int = int(floor(-off.x / cell)) - 1
	var start_y: int = int(floor(-off.y / cell)) - 1
	for gx in range(start_x, start_x + int(VIEW.x / cell) + 4):
		for gy in range(start_y, start_y + int(VIEW.y / cell) + 4):
			var wp := Vector2(gx * cell + 64, gy * cell + 64)
			if not WORLD.has_point(wp):
				continue
			var sp: Vector2 = wp + off
			var code: int = abs(gx * 92821 + gy * 68917 + int(str(chapter.get("id", "")).hash()))
			if map_kind in ["village", "guandu", "jingzhou"] and code % 5 == 0:
				var field_rect := Rect2(sp - Vector2(47, 32), Vector2(94, 64))
				draw_rect(field_rect, Color(palette["field"], 0.22), true)
				for furrow in range(4):
					draw_line(field_rect.position + Vector2(10, 12 + furrow * 13), field_rect.end - Vector2(10, 52 - furrow * 13), Color(palette["detail"], 0.20), 1.0)
			elif map_kind in ["capital", "fortress"]:
				draw_rect(Rect2(sp - Vector2(55, 39), Vector2(110, 78)), Color(palette["detail"], 0.09), false, 1.0)
			elif code % 3 == 0:
				draw_circle(sp + Vector2(code % 23 - 11, code % 17 - 8), 2.0 + float(code % 4), Color(palette["detail"], 0.16))

	# 河面細波與赤壁／夷陵的餘燼，增加章節辨識但不遮住攻擊預警。
	if shape == "river_channels":
		for i in range(18):
			var wave_x: float = fposmod(float(i * 97) + elapsed * 12.0, VIEW.x + 80.0) - 40.0
			for band in [-1.0, 1.0]:
				var wy: float = center_screen.y + band * 260.0 + sin(float(i) + elapsed) * 18.0
				draw_line(Vector2(wave_x, wy), Vector2(wave_x + 28, wy), Color(0.72, 0.88, 0.91, 0.20), 2.0)


func draw_area_symbol(center: Vector2, symbol: String, color: Color, scale: float = 1.0) -> void:
	var c := Color(color.r, color.g, color.b, 0.88)
	match symbol:
		"damage":
			draw_line(center + Vector2(-7, -7) * scale, center + Vector2(7, 7) * scale, c, 3.0 * scale)
			draw_line(center + Vector2(7, -7) * scale, center + Vector2(-7, 7) * scale, c, 3.0 * scale)
		"slow":
			draw_line(center + Vector2(0, -8) * scale, center + Vector2(0, 6) * scale, c, 3.0 * scale)
			draw_colored_polygon(PackedVector2Array([center + Vector2(-6, 1) * scale, center + Vector2(6, 1) * scale, center + Vector2(0, 9) * scale]), c)
		"bind":
			draw_arc(center + Vector2(-5, 0) * scale, 6.0 * scale, -1.1, 1.1, 12, c, 2.5 * scale)
			draw_arc(center + Vector2(5, 0) * scale, 6.0 * scale, 2.0, 4.2, 12, c, 2.5 * scale)
		"blind":
			draw_arc(center, 9.0 * scale, PI, TAU, 18, c, 2.5 * scale)
			draw_circle(center, 3.0 * scale, c)
			draw_line(center + Vector2(-10, -8) * scale, center + Vector2(10, 8) * scale, c, 2.5 * scale)
		"pierce":
			draw_arc(center, 9.0 * scale, 0, TAU, 18, c, 2.5 * scale)
			draw_line(center + Vector2(-8, 8) * scale, center + Vector2(8, -8) * scale, c, 3.0 * scale)


func draw_repeated_area_symbols(center: Vector2, radius: float, symbol: String, color: Color) -> void:
	draw_area_symbol(center, symbol, color, 0.9)
	if radius < 58.0:
		return
	var count := 4 if radius < 100.0 else 8
	for i in range(count):
		var d := Vector2.from_angle(float(i) / float(count) * TAU + PI * 0.25)
		draw_area_symbol(center + d * radius * 0.58, symbol, color, 0.72)


func draw_world() -> void:
	var chapter: Dictionary = current_chapter()
	var ground_code: String = str(chapter.get("ground_color", "#434e3e"))
	var ground: Color = Color.from_string(ground_code, Color8(67, 78, 62))
	draw_rect(Rect2(Vector2.ZERO, VIEW), ground, true)
	var off: Vector2 = camera_offset()
	draw_terrain_layers(chapter, off)
	draw_interactive_terrain_overlay(chapter, off)
	var chapter_id: String = str(chapter.get("id", ""))
	if map_tex.has(chapter_id):
		# 地圖固定於世界座標；攝影機移動時背景不再與主角黏在螢幕上。
		draw_texture_rect(
			map_tex[chapter_id], Rect2(camera_offset(), WORLD.size), true, Color(1, 1, 1, 0.72)
		)
	draw_chapter_atmosphere(chapter)
	# 明確戰場邊界：木柵／城牆線會在接近世界邊緣時出現，避免隱形牆感。
	var boundary_rect: Rect2 = Rect2(camera_offset(), WORLD.size)
	draw_rect(boundary_rect, Color(0.78, 0.58, 0.28, 0.72), false, 10.0)
	var boundary_asset: String = (
		"wall" if str(chapter.get("map_kind", "")) in ["capital", "fortress"] else "palisade"
	)
	if prop_tex.has(boundary_asset):
		for x in range(0, int(WORLD.size.x), 110):
			var edge_y_values: Array[float] = [0.0, WORLD.size.y]
			for wy in edge_y_values:
				var bp: Vector2 = world_to_screen(Vector2(x + 55.0, wy))
				if bp.x > -80.0 and bp.x < VIEW.x + 80.0 and bp.y > -70.0 and bp.y < VIEW.y + 70.0:
					draw_texture_contain(
						prop_tex[boundary_asset], Rect2(bp - Vector2(55, 31), Vector2(110, 62))
					)
		for y in range(0, int(WORLD.size.y), 90):
			var edge_x_values: Array[float] = [0.0, WORLD.size.x]
			for wx in edge_x_values:
				var bp: Vector2 = world_to_screen(Vector2(wx, y + 45.0))
				if bp.x > -80.0 and bp.x < VIEW.x + 80.0 and bp.y > -70.0 and bp.y < VIEW.y + 70.0:
					draw_texture_contain(
						prop_tex[boundary_asset], Rect2(bp - Vector2(42, 28), Vector2(84, 56))
					)
	# 細格線僅作為走位參考，降低存在感。
	for x in range(0, int(WORLD.size.x), 96):
		var sx: float = x + off.x
		if sx > -100 and sx < VIEW.x + 100:
			draw_line(Vector2(sx, 0), Vector2(sx, VIEW.y), Color(0.23, 0.27, 0.20, 0.10), 1.0)
	for y in range(0, int(WORLD.size.y), 96):
		var sy: float = y + off.y
		if sy > -100 and sy < VIEW.y + 100:
			draw_line(Vector2(0, sy), Vector2(VIEW.x, sy), Color(0.23, 0.27, 0.20, 0.10), 1.0)
	for d in decorations:
		var p: Vector2 = world_to_screen(d["pos"])
		if not Rect2(-50, -50, VIEW.x + 100, VIEW.y + 100).has_point(p):
			continue
		match int(d["kind"]):
			0:
				draw_circle(p, 3.0 * float(d["size"]), Color8(115, 130, 77))
			1:
				draw_line(p + Vector2(-5, 5), p + Vector2(5, -5), Color8(112, 99, 67), 2.0)
			2:
				draw_circle(p, 2.5, Color8(195, 178, 91))
			3:
				draw_rect(Rect2(p - Vector2(4, 2), Vector2(8, 4)), Color8(103, 83, 54), true)
			4:
				draw_line(p, p + Vector2(0, -9), Color8(75, 101, 61), 2.0)
	for ob in obstacles:
		var p: Vector2 = world_to_screen(ob["pos"])
		var r: Rect2 = Rect2(p - ob["size"] * 0.5, ob["size"])
		if not r.intersects(Rect2(Vector2.ZERO, VIEW)):
			continue
		var asset_id: String = str(ob.get("asset", "barricade"))
		# 碰撞範圍使用柔和陰影與細框標示，避免看不出被哪個物件卡住。
		draw_rect(Rect2(r.position + Vector2(0, 7), r.size), Color(0, 0, 0, 0.22), true)
		if prop_tex.has(asset_id):
			draw_texture_contain(prop_tex[asset_id], r)
			draw_rect(r.grow(-3.0), Color(0.93, 0.74, 0.36, 0.34), false, 1.5)
		else:
			var c: Color = [Color8(96, 81, 58), Color8(76, 87, 66), Color8(114, 104, 80)][int(
				ob["kind"]
			)]
			draw_rect(r, c, true)
			draw_rect(r, c.lightened(0.25), false, 2.0)
	# 史勢奇遇與名將事件標記
	if history_event_active:
		var hp_event: Vector2 = world_to_screen(history_event_pos)
		draw_circle(hp_event + Vector2(0, 12), 27.0, Color(0, 0, 0, 0.24))
		draw_circle(hp_event, 30.0 + sin(elapsed * 4.0) * 2.0, Color(0.76, 0.54, 0.18, 0.18))
		draw_arc(hp_event, 29.0, 0, TAU, 28, Color8(234, 197, 113), 2.5)
		draw_rect(Rect2(hp_event - Vector2(13, 17), Vector2(26, 34)), Color8(211, 190, 142), true)
		draw_line(hp_event + Vector2(-8, -9), hp_event + Vector2(8, -9), Color8(99, 72, 45), 2.0)
		draw_line(hp_event + Vector2(-8, -2), hp_event + Vector2(6, -2), Color8(99, 72, 45), 2.0)
		draw_text("E 奇遇", hp_event + Vector2(-28, -40), 15, Color8(250, 229, 157), true)
	if current_encounter != "":
		var ep: Vector2 = world_to_screen(encounter_pos)
		draw_circle(ep + Vector2(0, 24), 38.0, Color(0, 0, 0, 0.24))
		draw_panel(Rect2(ep - Vector2(42, 34), Vector2(84, 66)), Color8(71, 55, 38), Color8(214, 176, 102), 2.0)
		draw_rect(Rect2(ep - Vector2(48, 38), Vector2(96, 11)), Color8(115, 45, 35), true)
		draw_line(ep + Vector2(-46, -27), ep + Vector2(46, -27), Color8(222, 178, 95), 2.0)
		draw_rect(Rect2(ep - Vector2(12, 5), Vector2(24, 37)), Color8(38, 31, 25), true)
		draw_text("招賢", ep + Vector2(-22, -8), 13, Color8(244, 220, 157), true)
		draw_text("E 招賢館", ep + Vector2(-38, -48), 16, Color8(250, 229, 157), true)
	if merchant_active:
		var mp: Vector2 = world_to_screen(merchant_pos)
		draw_circle(mp + Vector2(0, 25), 36.0, Color(0, 0, 0, 0.22))
		draw_texture_contain(prop_tex["merchant"], Rect2(mp - Vector2(52, 43), Vector2(104, 82)))
		draw_text("E 行商", mp + Vector2(-28, -48), 16, Color8(250, 229, 157), true)
	if camp_active:
		var cp: Vector2 = world_to_screen(camp_pos)
		draw_circle(cp + Vector2(0, 26), 38.0, Color(0, 0, 0, 0.22))
		draw_texture_contain(prop_tex["camp"], Rect2(cp - Vector2(56, 46), Vector2(112, 92)))
		draw_arc(cp, 50.0 + sin(elapsed * 3.0) * 2.0, 0, TAU, 32, Color8(125, 214, 151), 2.0)
		draw_text("E 紮營", cp + Vector2(-30, -54), 16, Color8(250, 229, 157), true)
	if chest_active:
		var chest_screen: Vector2 = world_to_screen(chest_pos)
		draw_circle(chest_screen + Vector2(0, 15), 27.0, Color(0, 0, 0, 0.20))
		draw_texture_contain(
			prop_tex["chest"], Rect2(chest_screen - Vector2(35, 27), Vector2(70, 54))
		)
		draw_arc(
			chest_screen, 33.0 + sin(elapsed * 5.0) * 2.0, 0, TAU, 28, Color8(238, 199, 92), 2.0
		)
		draw_text("E 遺物箱", chest_screen + Vector2(-38, -37), 15, Color8(250, 229, 157), true)
	# 地面區域
	for z in zones:
		var p: Vector2 = world_to_screen(z["pos"])
		if not Rect2(-180, -180, VIEW.x + 360, VIEW.y + 360).has_point(p):
			continue
		var alpha: float = clamp(
			float(z["life"]) / max(0.01, float(z.get("max_life", z["life"]))), 0.15, 1.0
		)
		match str(z["kind"]):
			"fire":
				draw_circle(p, float(z["r"]), Color(0.84, 0.29, 0.08, 0.18))
			"poison":
				draw_circle(p, float(z["r"]), Color(0.43, 0.23, 0.53, 0.20))
			"frost":
				draw_circle(p, float(z["r"]), Color(0.47, 0.72, 0.86, 0.19))
			"lightning":
				draw_circle(p, float(z["r"]), Color(0.95, 0.84, 0.24, 0.22))
			"enemy_control_warning":
				var control_r: float = float(z["r"])
				var control_pulse: float = 0.5 + 0.5 * sin(elapsed * 16.0)
				var control_kind: String = str(z.get("control", "slow"))
				var control_color: Color = Color8(166, 56, 92) if control_kind == "slow" else (Color8(205, 72, 48) if control_kind == "bind" else Color8(111, 42, 67))
				draw_circle(p, control_r, Color(control_color.r, control_color.g, control_color.b, 0.13 + control_pulse * 0.08))
				draw_arc(p, control_r, 0, TAU, 42, Color(control_color.r, control_color.g, control_color.b, 0.96), 3.5)
				var symbol: String = "slow" if control_kind == "slow" else ("bind" if control_kind == "bind" else "blind")
				draw_repeated_area_symbols(p, control_r, symbol, Color8(255, 218, 218))
				if float(z.get("shield_pierce", 0.0)) > 0.0:
					draw_area_symbol(p + Vector2(0, control_r * 0.32), "pierce", Color8(255, 228, 202), 0.8)
			"enemy_warning":
				var warning_r: float = float(z["r"])
				var warning_pulse: float = 0.5 + 0.5 * sin(elapsed * 20.0)
				draw_circle(p, warning_r, Color(0.72, 0.06, 0.04, 0.12 + 0.12 * warning_pulse))
				draw_arc(p, warning_r, 0, TAU, 48, Color(0.98, 0.18, 0.10, 0.95), 4.0)
				draw_arc(p, warning_r * (0.42 + warning_pulse * 0.22), 0, TAU, 36, Color(1.0, 0.55, 0.18, 0.78), 2.0)
				draw_line(p + Vector2(-warning_r, 0), p + Vector2(-warning_r * 0.62, 0), Color(1.0, 0.72, 0.28, 0.9), 3.0)
				draw_line(p + Vector2(warning_r * 0.62, 0), p + Vector2(warning_r, 0), Color(1.0, 0.72, 0.28, 0.9), 3.0)
				draw_line(p + Vector2(0, -warning_r), p + Vector2(0, -warning_r * 0.62), Color(1.0, 0.72, 0.28, 0.9), 3.0)
				draw_line(p + Vector2(0, warning_r * 0.62), p + Vector2(0, warning_r), Color(1.0, 0.72, 0.28, 0.9), 3.0)
				draw_repeated_area_symbols(p, warning_r, "damage", Color8(255, 225, 215))
				if float(z.get("shield_pierce", 0.0)) > 0.0:
					draw_area_symbol(p + Vector2(0, warning_r * 0.34), "pierce", Color8(255, 235, 205), 0.78)
			"telegraph_circle":
				var pulse: float = 0.82 + sin(Time.get_ticks_msec() * 0.018) * 0.10
				var circle_radius: float = float(z.get("r", 150.0))
				draw_circle(p, circle_radius, Color(0.78, 0.05, 0.04, 0.15 * pulse), true)
				draw_arc(p, circle_radius, 0.0, TAU, 56, Color(1.0, 0.20, 0.12, 0.92), 4.0)
				draw_arc(p, circle_radius * clamp(1.0 - alpha, 0.08, 1.0), 0.0, TAU, 48, Color(1.0, 0.72, 0.30, 0.88), 2.0)
			"telegraph_line":
				var line_dir: Vector2 = z.get("dir", Vector2.RIGHT) as Vector2
				var line_length: float = float(z.get("length", 360.0))
				var line_width: float = float(z.get("width", 76.0))
				var side: Vector2 = line_dir.orthogonal() * line_width * 0.5
				var line_end: Vector2 = p + line_dir * line_length
				var polygon := PackedVector2Array([p - side, p + side, line_end + side, line_end - side])
				draw_colored_polygon(polygon, Color(0.78, 0.05, 0.04, 0.17))
				draw_polyline(PackedVector2Array([p - side, line_end - side, line_end + side, p + side]), Color(1.0, 0.20, 0.12, 0.94), 4.0)
				draw_line(p, line_end, Color(1.0, 0.72, 0.30, 0.90), 2.0)
			"telegraph_sector":
				var sector_angle: float = float(z.get("angle", 0.0))
				var half_angle: float = float(z.get("half_angle", deg_to_rad(36.0)))
				var sector_radius: float = float(z.get("radius", 230.0))
				var points := PackedVector2Array([p])
				var segments: int = 28
				for sector_index in range(segments + 1):
					var t: float = float(sector_index) / float(segments)
					points.append(p + Vector2.from_angle(lerp(sector_angle - half_angle, sector_angle + half_angle, t)) * sector_radius)
				draw_colored_polygon(points, Color(0.78, 0.05, 0.04, 0.17))
				draw_arc(p, sector_radius, sector_angle - half_angle, sector_angle + half_angle, segments, Color(1.0, 0.20, 0.12, 0.94), 4.0)
				draw_line(p, p + Vector2.from_angle(sector_angle - half_angle) * sector_radius, Color(1.0, 0.20, 0.12, 0.94), 3.0)
				draw_line(p, p + Vector2.from_angle(sector_angle + half_angle) * sector_radius, Color(1.0, 0.20, 0.12, 0.94), 3.0)
			"ring_visual":
				draw_arc(p, float(z["r"]) * alpha, 0, TAU, 48, z.get("color", Color.WHITE), 3.0)
			"slash_visual":
				var a: float = float(z.get("angle", 0.0))
				var progress: float = 1.0 - alpha
				var inner_r: float = 22.0 + progress * 34.0
				var outer_r: float = float(z["r"]) * (0.62 + progress * 0.38)
				var slash_color: Color = z.get("color", Color.WHITE)
				draw_arc(p, outer_r, a - 0.76, a + 0.76, 30, slash_color, 7.0)
				draw_arc(
					p,
					max(inner_r, outer_r - 24.0),
					a - 0.70,
					a + 0.70,
					26,
					Color(slash_color.r, slash_color.g, slash_color.b, alpha * 0.55),
					3.0
				)
				for slash_offset in [-0.62, 0.0, 0.62]:
					var slash_dir: Vector2 = Vector2.from_angle(a + slash_offset)
					draw_line(p + slash_dir * inner_r, p + slash_dir * outer_r, Color(slash_color.r, slash_color.g, slash_color.b, alpha * 0.70), 2.0)
			"shockwave_visual":
				var shock_progress: float = 1.0 - alpha
				var shock_radius: float = lerp(24.0, float(z["r"]), shock_progress)
				var shock_color: Color = z.get("color", Color.WHITE)
				draw_circle(
					p,
					shock_radius * 0.92,
					Color(shock_color.r, shock_color.g, shock_color.b, 0.07 * alpha)
				)
				draw_arc(
					p,
					shock_radius,
					0.0,
					TAU,
					56,
					Color(shock_color.r, shock_color.g, shock_color.b, alpha),
					6.0
				)
				draw_arc(
					p,
					max(8.0, shock_radius - 22.0),
					0.0,
					TAU,
					48,
					Color(1.0, 0.78, 0.58, alpha * 0.55),
					3.0
				)
				for ray in range(12):
					var shock_dir: Vector2 = Vector2.from_angle(float(ray) / 12.0 * TAU)
					draw_line(
						p + shock_dir * max(18.0, shock_radius - 42.0),
						p + shock_dir * shock_radius,
						Color(shock_color.r, shock_color.g, shock_color.b, alpha * 0.72),
						2.0
					)
			"hero_line_visual":
				var line_end: Vector2 = world_to_screen(z.get("end", z["pos"]))
				var line_color: Color = z.get("color", Color.WHITE)
				var line_width: float = float(z.get("width", 56.0))
				draw_line(p, line_end, Color(line_color.r, line_color.g, line_color.b, 0.22 * alpha), line_width)
				draw_line(p, line_end, Color(line_color.r, line_color.g, line_color.b, 0.95 * alpha), 7.0)
				var dline: Vector2 = (line_end - p).normalized()
				var normal: Vector2 = dline.rotated(PI * 0.5)
				for streak in [-2, -1, 1, 2]:
					draw_line(p + normal * streak * 10.0, line_end + normal * streak * 10.0, Color(1.0, 1.0, 1.0, 0.34 * alpha), 2.0)
			"hero_arrow_visual":
				var arrow_color: Color = z.get("color", Color.WHITE)
				var arrow_dir: Vector2 = Vector2.from_angle(float(z.get("angle", 0.0)))
				var arrow_end: Vector2 = p + arrow_dir * float(z.get("length", 760.0))
				draw_line(p, arrow_end, Color(arrow_color.r, arrow_color.g, arrow_color.b, 0.30 * alpha), 12.0)
				draw_line(p, arrow_end, Color(1.0, 0.92, 0.58, 0.95 * alpha), 4.0)
				var tip: Vector2 = arrow_end
				draw_line(tip, tip - arrow_dir.rotated(0.55) * 22.0, Color(1.0, 0.92, 0.58, alpha), 4.0)
				draw_line(tip, tip - arrow_dir.rotated(-0.55) * 22.0, Color(1.0, 0.92, 0.58, alpha), 4.0)
			"impact_visual":
				var ir: float = float(z["r"]) * (1.2 - alpha * 0.2)
				var ic: Color = z.get("color", Color.WHITE)
				draw_circle(p, ir, Color(ic.r, ic.g, ic.b, 0.16 * alpha))
				for ray in range(6 if bool(z.get("crit", false)) else 4):
					var rd: Vector2 = Vector2.from_angle(float(ray) / 6.0 * TAU + elapsed * 0.8)
					draw_line(p + rd * 4.0, p + rd * ir, Color(ic.r, ic.g, ic.b, alpha), 3.0)
			"hero_effect":
				draw_hero_signature_visual(
					str(z.get("hero", "")), p, float(z.get("angle", 0.0)), float(z["r"]), alpha
				)
	# 掉落物
	for p in pickups:
		var sp: Vector2 = world_to_screen(p["pos"])
		if not Rect2(-40, -40, VIEW.x + 80, VIEW.y + 80).has_point(sp):
			continue
		match str(p["kind"]):
			"xp":
				draw_circle(sp, 5.0, Color8(105, 203, 211))
			"coin":
				draw_circle(sp, 6.0, Color8(236, 193, 75))
				draw_circle(sp, 3.0, Color8(112, 76, 32), false, 1.0)
			"heal":
				draw_rect(Rect2(sp - Vector2(7, 2), Vector2(14, 4)), Color8(111, 222, 137), true)
				draw_rect(Rect2(sp - Vector2(2, 7), Vector2(4, 14)), Color8(111, 222, 137), true)
			"relic":
				var relic_id: String = str(p.get("id", ""))
				draw_circle(sp, 20.0 + sin(elapsed * 5.0) * 2.0, Color(0.94, 0.76, 0.28, 0.18))
				if relic_tex.has(relic_id):
					draw_texture_contain(
						relic_tex[relic_id], Rect2(sp - Vector2(15, 15), Vector2(30, 30))
					)
				draw_arc(sp, 18.0, 0, TAU, 24, Color8(241, 206, 104), 2.0)
	# 友軍與敵人
	for a in allies:
		var ap: Vector2 = world_to_screen(a["pos"])
		if not Rect2(-70, -70, VIEW.x + 140, VIEW.y + 140).has_point(ap):
			continue
		draw_circle(ap + Vector2(0, 14), 13.0, Color(0, 0, 0, 0.20))
		draw_sprite_frame(sprite_tex["ally_militia"], ap, 1.4, int(elapsed * 8.0 + a["pos"].x) % 4)
	for e in enemies:
		var ep: Vector2 = world_to_screen(e["pos"])
		if not Rect2(-80, -80, VIEW.x + 160, VIEW.y + 160).has_point(ep):
			continue
		var mod: Color = Color.WHITE
		if float(e["poison"]) > 0.0:
			mod = Color8(203, 154, 222)
		elif float(e["slow"]) > 0.0:
			mod = Color8(175, 219, 240)
		draw_circle(
			ep + Vector2(0, 14), 13.0 if not bool(e["elite"]) else 18.0, Color(0, 0, 0, 0.22)
		)
		draw_sprite_frame(
			sprite_tex[e["sprite"]],
			ep,
			ENEMY_SPRITE_SCALE if not bool(e["elite"]) else ELITE_SPRITE_SCALE,
			int(float(e["anim"])) % 4,
			mod
		)
		if float(e["telegraph"]) > 0.0:
			draw_line(ep, world_to_screen(player["pos"]), Color(0.96, 0.20, 0.14, 0.62), 2.0)
		if str(e.get("kind", "")) in ["caster_slow", "caster_bind", "caster_smoke"]:
			var caster_color: Color = Color8(100, 178, 222) if e["kind"] == "caster_slow" else (Color8(231, 207, 80) if e["kind"] == "caster_bind" else Color8(151, 102, 177))
			draw_arc(ep, 24.0 + sin(elapsed * 4.0) * 2.0, 0, TAU, 28, Color(caster_color.r, caster_color.g, caster_color.b, 0.82), 2.0)
		if float(e["marked"]) > 0.0:
			draw_arc(ep, 22.0, 0, TAU, 20, Color8(248, 231, 156), 2.0)
		if bool(e.get("boss_support", false)):
			draw_text(str(e.get("name", "副將")), ep + Vector2(-42, -42), 14, Color8(241, 204, 134), true, HORIZONTAL_ALIGNMENT_CENTER, 84)
		if bool(e["elite"]):
			var elite_pulse: float = 0.5 + 0.5 * sin(elapsed * 3.8 + float(e.get("ai_phase", 0)))
			draw_circle(ep + Vector2(0, 13), 27.0 + elite_pulse * 2.0, Color(0.95, 0.62, 0.12, 0.10 + elite_pulse * 0.08))
			draw_arc(ep + Vector2(0, 13), 28.0, 0, TAU, 30, Color(0.96, 0.69, 0.20, 0.82), 2.2)
			var w: float = 58.0
			draw_rect(Rect2(ep.x - w * 0.5, ep.y - 38, w, 7), Color8(42, 34, 24), true)
			draw_rect(Rect2(ep.x - w * 0.5, ep.y - 38, w * float(e["hp"]) / float(e["max_hp"]), 7), Color8(224, 166, 55), true)
			draw_rect(Rect2(ep.x - w * 0.5, ep.y - 38, w, 7), Color8(247, 211, 113), false, 1.0)
			draw_text(str(e.get("elite_name", "精英敵將")), ep + Vector2(-54, -46), 12, Color8(246, 216, 137), true, HORIZONTAL_ALIGNMENT_CENTER, 108)
	# Alpha.54：敵人異常狀態以最多三個小圓點呈現，避免文字與特效淹沒戰場。
	for status_enemy in enemies:
		var status_pos: Vector2 = world_to_screen(status_enemy.get("pos", Vector2.ZERO))
		if not Rect2(-80, -80, VIEW.x + 160, VIEW.y + 160).has_point(status_pos):
			continue
		var status_map_value: Variant = status_enemy.get("status_effects", {})
		if not status_map_value is Dictionary:
			continue
		var status_map: Dictionary = status_map_value as Dictionary
		var status_slot: int = 0
		for status_id in StatusEffectService.EFFECT_ORDER:
			if not status_map.has(status_id):
				continue
			var status_data: Dictionary = status_map[status_id] as Dictionary
			if float(status_data.get("duration", 0.0)) <= 0.0:
				continue
			var dot_pos: Vector2 = status_pos + Vector2(-12.0 + float(status_slot) * 12.0, -31.0 if not bool(status_enemy.get("elite", false)) else -58.0)
			draw_circle(dot_pos, 4.0, StatusEffectService.effect_color(status_id))
			draw_circle(dot_pos, 5.5, Color(1, 1, 1, 0.35), false, 1.0)
			status_slot += 1
			if status_slot >= 3:
				break
	# Boss
	if not boss.is_empty():
		var bp: Vector2 = world_to_screen(boss["pos"])
		var boss_offset: Vector2 = Vector2.ZERO
		var boss_stretch: Vector2 = Vector2.ONE
		var boss_rotation: float = 0.0
		if not boss_action_anim.is_empty():
			var bap: float = action_progress(boss_action_anim)
			var boss_kind: String = str(boss_action_anim.get("kind", "attack"))
			if boss_kind == "cast":
				boss_offset.y = -sin(bap * PI) * 13.0
				boss_stretch = Vector2(1.0 + sin(bap * PI) * 0.09, 1.0 - sin(bap * PI) * 0.05)
				for sigil_i in range(3):
					var sigil_r: float = 42.0 + sigil_i * 12.0 + sin(elapsed * 6.0 + sigil_i) * 3.0
					draw_arc(bp, sigil_r, elapsed * (1.2 + sigil_i * 0.2), elapsed * (1.2 + sigil_i * 0.2) + PI * 1.35, 28, Color(0.95, 0.30, 0.18, 0.62), 2.5)
			else:
				var lunge: float = sin(bap * PI) * 17.0
				var toward_player: Vector2 = (world_to_screen(player["pos"]) - bp).normalized()
				boss_offset = toward_player * lunge
				boss_rotation = sin(bap * TAU) * 0.045
		draw_circle(bp + Vector2(0, 30), 34.0, Color(0, 0, 0, 0.30))
		draw_sprite_pose(sprite_tex[boss["id"]], bp + boss_offset, BOSS_SPRITE_SCALE, int(float(boss["anim"])) % 4, Color.WHITE, boss_rotation, boss_stretch)
	# 投射物
	for s in player_shots:
		var p: Vector2 = world_to_screen(s["pos"])
		if not Rect2(-30, -30, VIEW.x + 60, VIEW.y + 60).has_point(p):
			continue
		var col: Color = Color8(248, 238, 190)
		if s["kind"] in ["needle"]:
			col = Color8(173, 112, 204)
		elif s["kind"] in ["fire_arrow"]:
			col = Color8(241, 120, 58)
		elif s["kind"] in ["glaive"]:
			col = Color8(211, 146, 235)
		elif s["kind"] == "return_blade":
			col = Color8(224, 126, 136)
		elif s["kind"] == "wind_blade":
			col = Color8(242, 184, 193)
		draw_line(
			p - Vector2.from_angle(float(s["angle"])) * 10.0,
			p + Vector2.from_angle(float(s["angle"])) * 10.0,
			col,
			3.0
		)
		draw_circle(p, 3.0, Color.WHITE, false, 1.0)
	for s in enemy_shots:
		var p: Vector2 = world_to_screen(s["pos"])
		if not Rect2(-30, -30, VIEW.x + 60, VIEW.y + 60).has_point(p):
			continue
		var dir: Vector2 = s["vel"].normalized()
		draw_line(p - dir * 9.0, p + dir * 9.0, Color8(52, 28, 25), 5.0)
		draw_line(p - dir * 9.0, p + dir * 9.0, Color8(231, 72, 55), 2.0)
	# 玩家最後畫，保持辨識度。
	var pp: Vector2 = world_to_screen(player["pos"])
	var pm: Color = (
		Color(1, 1, 1, 0.42)
		if float(player["invuln"]) > 0.0 and int(elapsed * 16.0) % 2 == 0
		else Color.WHITE
	)
	draw_circle(pp + Vector2(0, 17), 17.0, Color(0, 0, 0, 0.28))
	var build_visual: Dictionary = dominant_build()
	draw_circle(pp, 24.0 + sin(elapsed * 4.0) * 1.5, Color(build_visual["color"], 0.10))
	draw_arc(pp, 27.0, -PI * 0.15, PI * 1.15, 30, Color(build_visual["color"], 0.75), 2.2)
	var player_offset: Vector2 = Vector2.ZERO
	var player_stretch: Vector2 = Vector2.ONE
	var player_rotation: float = 0.0
	if not player_action_anim.is_empty():
		var pap: float = action_progress(player_action_anim)
		var action_dir: Vector2 = Vector2.from_angle(float(player_action_anim.get("angle", 0.0)))
		var action_kind: String = str(player_action_anim.get("kind", "blade"))
		var pose: Dictionary = Alpha27ActionProfiles.player_pose(action_kind, pap)
		player_offset = action_dir * float(pose.get("lunge", 0.0))
		player_rotation = float(pose.get("rotation", 0.0)) * (1.0 if action_dir.x >= 0.0 else -1.0)
		player_stretch = pose.get("stretch", Vector2.ONE) as Vector2
	draw_sprite_pose(sprite_tex[identity_visual_id(chosen_identity)], pp + player_offset, PLAYER_SPRITE_SCALE, int(elapsed * 8.0) % 4, pm, player_rotation, player_stretch)
	if float(player["shield"]) > 0.0:
		var shield_ratio: float = clamp(float(player["shield"]) / 100.0, 0.0, 1.0)
		var pulse: float = 2.5 + sin(elapsed * 5.0) * 1.5
		draw_circle(pp, 29.0 + pulse, Color(0.30, 0.72, 0.96, 0.12 + shield_ratio * 0.10))
		draw_arc(pp, 30.0 + pulse, 0, TAU, 40, Color8(135, 215, 248), 4.0)
		draw_arc(pp, 35.0 + pulse, -PI * 0.72, PI * 0.22, 24, Color(0.82, 0.95, 1.0, 0.72), 2.0)
		for orbit_index in range(3):
			var orbit_angle: float = elapsed * 2.1 + float(orbit_index) / 3.0 * TAU
			draw_circle(pp + Vector2.from_angle(orbit_angle) * (35.0 + pulse), 3.0, Color8(187, 232, 252))
	for p in particles:
		var sp: Vector2 = world_to_screen(p["pos"])
		if Rect2(-24, -24, VIEW.x + 48, VIEW.y + 48).has_point(sp):
			draw_circle(sp, float(p["size"]) * float(p["life"]) / float(p["max_life"]), p["color"])
	if damage_numbers_enabled():
		for n in damage_numbers:
			var number_pos: Vector2 = world_to_screen(n["pos"])
			if Rect2(-60, -60, VIEW.x + 120, VIEW.y + 120).has_point(number_pos):
				draw_text(n["text"], number_pos, 16, n["color"], true)


func draw_hero_signature_visual(
	hid: String, p: Vector2, angle: float, radius: float, alpha: float
) -> void:
	var hero_def: Dictionary = heroes.get(hid, {})
	var color: Color = hero_def.get("color", Color.WHITE)
	var c: Color = Color(color.r, color.g, color.b, 0.85 * alpha)
	match hid:
		"guanyu":
			for offset in [-0.16, 0.0, 0.16]:
				draw_arc(
					p,
					radius * (0.72 + alpha * 0.28),
					angle - 0.9 + offset,
					angle + 0.9 + offset,
					30,
					c,
					8.0
				)
		"zhangfei":
			for ring in range(3):
				draw_arc(
					p,
					radius * (0.28 + ring * 0.18) * (0.20 + (1.0 - alpha) * 1.05),
					0,
					TAU,
					40,
					c,
					5.0 - ring
				)
			for ray in range(8):
				var rd: Vector2 = Vector2.from_angle(float(ray) / 8.0 * TAU)
				draw_line(p + rd * 35.0, p + rd * radius, c, 3.0)
		"liubei":
			for i in range(3):
				var fp: Vector2 = p + Vector2((i - 1) * 44.0, -42.0)
				draw_line(fp, fp + Vector2(0, 80), c, 4.0)
				draw_colored_polygon(
					PackedVector2Array([fp, fp + Vector2(38, 12), fp + Vector2(0, 28)]), c
				)
		"huatuo":
			for i in range(8):
				var rd: Vector2 = Vector2.from_angle(float(i) / 8.0 * TAU + elapsed)
				draw_circle(p + rd * radius * 0.62, 8.0, c)
			draw_arc(p, radius * 0.72, 0, TAU, 42, c, 5.0)
		"caocao":
			for i in range(-2, 3):
				draw_line(
					p + Vector2(i * 35, -radius * 0.55), p + Vector2(i * 35, radius * 0.55), c, 3.0
				)
			draw_arc(p, radius * 0.75, angle - 1.1, angle + 1.1, 30, c, 6.0)
		"sunjian":
			var d: Vector2 = Vector2.from_angle(angle)
			for i in range(5):
				draw_line(
					p - d * 35.0 + d.rotated(PI * 0.5) * (i - 2) * 15.0,
					p + d * radius,
					c,
					6.0 - i * 0.5
				)
			draw_arc(p + d * radius * 0.72, 38.0, angle - 1.2, angle + 1.2, 22, c, 5.0)
		"taishici":
			for i in range(-3, 4):
				var ad: Vector2 = Vector2.from_angle(angle + i * 0.10)
				draw_line(p + ad * 25.0, p + ad * radius, c, 3.0)
		"zhangjiao":
			for i in range(6):
				var a0: float = float(i) / 6.0 * TAU
				var p0: Vector2 = p + Vector2.from_angle(a0) * radius * 0.25
				var p1: Vector2 = p + Vector2.from_angle(a0 + 0.16) * radius * 0.62
				var p2: Vector2 = p + Vector2.from_angle(a0 - 0.12) * radius
				draw_polyline(PackedVector2Array([p0, p1, p2]), c, 4.0)
		"diaochan":
			for i in range(3):
				draw_arc(p, radius * (0.45 + i * 0.20), elapsed + i, elapsed + i + 3.8, 36, c, 5.0)
		"sunshangxiang":
			for i in range(-5, 6):
				var ad: Vector2 = Vector2.from_angle(angle + i * 0.07)
				draw_line(p + ad * 20.0, p + ad * radius, c, 3.0)
		"zhenji":
			for i in range(8):
				var rd: Vector2 = Vector2.from_angle(float(i) / 8.0 * TAU)
				draw_line(p, p + rd * radius, c, 4.0)
			draw_arc(p, radius * 0.7, 0, TAU, 40, c, 4.0)
		"lvlingqi":
			for off in [-0.55, -0.18, 0.18, 0.55]:
				var ad: Vector2 = Vector2.from_angle(angle + off)
				draw_line(p - ad * 25.0, p + ad * radius, c, 7.0)
		"wangyi":
			for i in range(8):
				var rd: Vector2 = Vector2.from_angle(float(i) / 8.0 * TAU + elapsed)
				draw_arc(
					p + rd * radius * 0.55, 20.0, rd.angle() - 0.8, rd.angle() + 0.8, 12, c, 4.0
				)
		"caiwenji":
			for i in range(3):
				draw_arc(p, radius * (0.45 + i * 0.24), 0, TAU, 44, c, 4.5 - i * 0.7)
		"daqiao":
			for i in range(10):
				var rd: Vector2 = Vector2.from_angle(float(i) / 10.0 * TAU + elapsed * 0.4)
				draw_arc(
					p + rd * radius * 0.56, 17.0, rd.angle() - 0.7, rd.angle() + 0.7, 12, c, 3.0
				)
		_:
			draw_arc(p, radius * 0.75, 0, TAU, 40, c, 5.0)


func draw_minimap_shape(rect: Rect2, shape: String) -> void:
	var c: Color = Color(0.58, 0.55, 0.40, 0.34)
	var mid: Vector2 = rect.position + rect.size * 0.5
	match shape:
		"crossroads":
			draw_line(Vector2(rect.position.x, mid.y), Vector2(rect.end.x, mid.y), c, 5.0)
			draw_line(Vector2(mid.x, rect.position.y), Vector2(mid.x, rect.end.y), c, 5.0)
		"narrow", "supply_corridor", "long_road":
			draw_rect(Rect2(rect.position + Vector2(0, rect.size.y * 0.32), Vector2(rect.size.x, rect.size.y * 0.36)), c, true)
		"courtyard":
			draw_rect(rect.grow(-12.0), c, false, 5.0)
		"river_channels":
			draw_line(Vector2(rect.position.x, mid.y - 14.0), Vector2(rect.end.x, mid.y - 14.0), c, 6.0)
			draw_line(Vector2(rect.position.x, mid.y + 14.0), Vector2(rect.end.x, mid.y + 14.0), c, 6.0)
		_:
			draw_circle(mid, min(rect.size.x, rect.size.y) * 0.36, c, false, 3.0)



func relic_rarity_color(rarity: String) -> Color:
	match rarity:
		"uncommon": return Color8(91, 190, 105)
		"rare": return Color8(76, 145, 230)
		"epic": return Color8(174, 91, 224)
		"legendary": return Color8(235, 185, 55)
		"mythic": return Color8(225, 72, 72)
		_: return Color8(175, 180, 180)

func draw_hud() -> void:
	Alpha36RosterProgressionHud.draw_integrated_hud(self)
	return
	if not asset_errors.is_empty():
		draw_panel(
			Rect2(390, 154, 500, 38),
			Color(0.25, 0.02, 0.15, 0.94),
			Color(1.0, 0.25, 0.72, 1.0),
			2.0
		)
		draw_centered_text(
			"素材讀取異常，已使用替代圖",
			Rect2(405, 154, 470, 38),
			25.0,
			16,
			Color.WHITE,
			true
		)

	# 妖煙只限制外圍視線，不遮住玩家、Boss血條與危險預警。
	if float(player.get("vision_obscure", 0.0)) > 0.0:
		var obscure_alpha: float = clamp(float(player.get("vision_obscure", 0.0)) / 3.0, 0.0, 1.0)
		for fog_i in range(5):
			var fog_margin: float = float(fog_i) * 44.0
			draw_rect(Rect2(fog_margin, fog_margin, VIEW.x - fog_margin * 2.0, VIEW.y - fog_margin * 2.0), Color(0.05, 0.025, 0.07, 0.055 * obscure_alpha), false, 46.0)

	# 左上：整合玩家狀態、經濟、閃避與遺物，減少零碎面板。
	draw_panel(HUD_RELIC_RECT, Color(0.025, 0.032, 0.032, 0.93), Color8(126, 112, 78), 1.4)
	draw_text("%s　Lv.%d　銅錢 %d" % [identities[chosen_identity]["name"], player["level"], player["coins"]], HUD_RELIC_RECT.position + Vector2(12, 24), 16, Color8(236, 220, 176), true)
	var hp_ratio_hud: float = clamp(float(player["hp"]) / max(1.0, float(player["max_hp"])), 0.0, 1.0)
	var hp_hud: Rect2 = Rect2(HUD_RELIC_RECT.position + Vector2(12, 34), Vector2(300, 10))
	draw_rect(hp_hud, Color8(52, 37, 34), true)
	draw_rect(Rect2(hp_hud.position, Vector2(hp_hud.size.x * hp_ratio_hud, hp_hud.size.y)), Color8(185, 58, 54), true)
	draw_text("生命 %d/%d　護盾 %d" % [int(player["hp"]), int(player["max_hp"]), int(player["shield"])], HUD_RELIC_RECT.position + Vector2(12, 62), 12, Color8(226, 226, 215))
	if float(player.get("control_lock", 0.0)) > 0.0:
		draw_text("麻痺", HUD_RELIC_RECT.position + Vector2(242, 62), 11, Color8(245, 216, 92), true)
	elif float(player.get("move_slow", 0.0)) > 0.0:
		draw_text("緩速", HUD_RELIC_RECT.position + Vector2(242, 62), 11, Color8(123, 197, 231), true)
	elif float(player.get("vision_obscure", 0.0)) > 0.0:
		draw_text("妖煙", HUD_RELIC_RECT.position + Vector2(242, 62), 11, Color8(194, 137, 211), true)
	var dodge_left_hud: float = max(0.0, float(player.get("dash_timer", 0.0)))
	var dodge_total_hud: float = max(0.72, float(player.get("dash_cd", 5.0)) * pow(0.88, skill_level("dash")) * (0.88 if has_relic("dilu") else 1.0))
	var dodge_ready_ratio: float = 1.0 - clamp(dodge_left_hud / dodge_total_hud, 0.0, 1.0)
	draw_text("Space閃避：%s　｜　遺物 %d" % [("可用" if dodge_left_hud <= 0.0 else "%.1f秒" % dodge_left_hud), relics.size()], HUD_RELIC_RECT.position + Vector2(12, 80), 12, Color8(166, 218, 226) if dodge_left_hud <= 0.0 else Color8(191, 187, 167))
	var dodge_track: Rect2 = Rect2(HUD_RELIC_RECT.position + Vector2(12, 86), Vector2(128, 4))
	draw_rect(dodge_track, Color8(45, 51, 52), true)
	draw_rect(Rect2(dodge_track.position, Vector2(dodge_track.size.x * dodge_ready_ratio, dodge_track.size.y)), Color8(102, 206, 219) if dodge_left_hud <= 0.0 else Color8(190, 151, 77), true)
	var build_hud: Dictionary = dominant_build()
	draw_text("流派：%s｜%s %d" % [build_hud["name"], build_resonance_stage_name(build_resonance_stage(int(build_hud["score"]))), build_hud["score"]], HUD_RELIC_RECT.position + Vector2(154, 80), 11, build_hud["color"], true, HORIZONTAL_ALIGNMENT_RIGHT, 158)
	for relic_index in range(min(relics.size(), 9)):
		var rid: String = str(relics[relic_index])
		var rect: Rect2 = Rect2(24.0 + relic_index * 33.0, 92.0, 26.0, 26.0)
		var rarity: String = str(relic_defs.get(rid, {}).get("rarity", "common"))
		draw_rect(rect, Color(0.05, 0.06, 0.06, 0.94), true)
		draw_texture_contain(relic_tex[rid], rect.grow(-2.0))
		draw_rect(rect, relic_rarity_color(rarity), false, 2.0)
	if relics.size() > 9:
		draw_text("+%d" % (relics.size() - 9), Vector2(296, 112), 11, Color8(239, 217, 168), true)

	# 中上：章節資訊。文字以整個安全框置中，不再把中心座標誤當成左側座標。
	var chapter: Dictionary = current_chapter()
	draw_panel(HUD_HEADER_RECT, Color(0.025, 0.034, 0.036, 0.95), Color(0.66, 0.52, 0.29, 0.82), 1.5)
	var chapter_prefix: String = (
		"演武" if chosen_mode == "trial" else "第%d章" % (int(chapter.get("index", 0)) + 1)
	)
	draw_centered_text(
		"%s｜%s" % [chapter_prefix, str(chapter.get("title", "未知章回"))],
		HUD_HEADER_RECT,
		31.0,
		20,
		Color8(238, 218, 166),
		true
	)
	var status_text: String = "%s｜%s" % [str(chapter.get("place", "")), chapter_manager.boss_state_label()]
	if chapter_manager.boss_is_locked():
		status_text = "%s｜敵將 %d 秒後現身" % [str(chapter.get("place", "")), max(0, int(boss_time() - elapsed))]
	draw_centered_text(
		"%02d:%02d　%s" % [int(elapsed / 60.0), int(elapsed) % 60, status_text],
		HUD_HEADER_RECT,
		59.0,
		13,
		Color8(200, 207, 198)
	)

	# Boss血條另列，不擠入章節資訊框。
	if not boss.is_empty():
		var boss_definition: Dictionary = chapter_manager.boss_definition()
		draw_panel(HUD_BOSS_RECT, Color(0.035, 0.025, 0.025, 0.96), Color8(196, 75, 54), 2.0)
		var ratio: float = clamp(float(boss["hp"]) / max(1.0, float(boss["max_hp"])), 0.0, 1.0)
		draw_centered_text(
			"%s・%s　P%d" % [str(boss_definition.get("title", "敵將")), str(boss_definition.get("name", "未知")), int(boss["phase"])],
			HUD_BOSS_RECT,
			22.0,
			16,
			Color8(244, 222, 179),
			true
		)
		var hp_track: Rect2 = Rect2(HUD_BOSS_RECT.position + Vector2(24, 32), Vector2(HUD_BOSS_RECT.size.x - 48, 9))
		draw_rect(hp_track, Color8(54, 29, 27), true)
		draw_rect(Rect2(hp_track.position, Vector2(hp_track.size.x * ratio, hp_track.size.y)), Color8(202, 59, 49), true)
		var support_index: int = support_boss_index()
		if support_index >= 0:
			var support_enemy: Dictionary = enemies[support_index]
			var support_ratio: float = clamp(float(support_enemy["hp"]) / max(1.0, float(support_enemy["max_hp"])), 0.0, 1.0)
			var support_track: Rect2 = Rect2(HUD_BOSS_RECT.position + Vector2(24, 48), Vector2(HUD_BOSS_RECT.size.x - 48, 8))
			draw_rect(support_track, Color8(35, 42, 52), true)
			draw_rect(Rect2(support_track.position, Vector2(support_track.size.x * support_ratio, support_track.size.y)), Color8(81, 139, 185), true)
			draw_text("副將 %s" % str(support_enemy.get("name", "未知")), HUD_BOSS_RECT.position + Vector2(28, 61), 11, Color8(176, 203, 224))

	# Boss台詞統一依附在血條正下方，避免飄到畫面角落或遮住戰場。
	if not boss_ability_banner.is_empty() and not boss.is_empty():
		var ability_alpha: float = clamp(float(boss_ability_banner.get("life", 0.0)) / max(0.01, float(boss_ability_banner.get("max_life", 1.0))), 0.0, 1.0)
		var ability_text: String = str(boss_ability_banner.get("text", "敵將絕技！"))
		var ability_rect: Rect2 = Rect2(HUD_BOSS_RECT.position.x, HUD_BOSS_RECT.end.y + 5.0, HUD_BOSS_RECT.size.x, 42.0)
		draw_panel(ability_rect, Color(0.10, 0.012, 0.012, 0.94 * ability_alpha), Color(0.96, 0.30, 0.18, ability_alpha), 1.8)
		draw_text("敵將絕技", ability_rect.position + Vector2(14, 17), 11, Color(1.0, 0.62, 0.35, ability_alpha), true)
		draw_text(ability_text, ability_rect.position + Vector2(92, 27), 17, Color(1.0, 0.90, 0.74, ability_alpha), true, HORIZONTAL_ALIGNMENT_CENTER, ability_rect.size.x - 116.0)
		var ability_progress: float = 1.0 - ability_alpha
		var ability_track: Rect2 = Rect2(ability_rect.position + Vector2(14, ability_rect.size.y - 6), Vector2(ability_rect.size.x - 28, 3))
		draw_rect(ability_track, Color(0.25, 0.05, 0.035, 0.92), true)
		draw_rect(Rect2(ability_track.position, Vector2(ability_track.size.x * ability_progress, ability_track.size.y)), Color(1.0, 0.43, 0.18, ability_alpha), true)

	# 右上：小地圖。
	draw_panel(HUD_MINIMAP_RECT, Color(0.03, 0.04, 0.04, 0.88), Color8(125, 122, 92), 1.0)
	var map_rect: Rect2 = Rect2(HUD_MINIMAP_RECT.position + Vector2(10, 10), HUD_MINIMAP_RECT.size - Vector2(20, 20))
	draw_minimap_shape(map_rect, str(chapter.get("map_shape", "open")))
	var player_norm: Vector2 = player["pos"] / WORLD.size
	draw_circle(map_rect.position + player_norm * map_rect.size, 4.0, Color8(238, 231, 187))
	if history_event_active:
		draw_circle(map_rect.position + (history_event_pos / WORLD.size) * map_rect.size, 4.0, Color8(236, 197, 108))
	if current_encounter != "":
		draw_rect(Rect2(map_rect.position + (encounter_pos / WORLD.size) * map_rect.size - Vector2(4, 4), Vector2(8, 8)), Color8(218, 174, 92), true)
	if merchant_active:
		draw_rect(Rect2(map_rect.position + (merchant_pos / WORLD.size) * map_rect.size - Vector2(3, 3), Vector2(6, 6)), Color8(235, 185, 65), true)
	if camp_active:
		draw_circle(map_rect.position + (camp_pos / WORLD.size) * map_rect.size, 4.0, Color8(116, 220, 145))
	if chest_active:
		draw_rect(Rect2(map_rect.position + (chest_pos / WORLD.size) * map_rect.size - Vector2(3, 3), Vector2(6, 6)), Color8(240, 198, 83), true)
	if not boss.is_empty():
		draw_circle(map_rect.position + (boss["pos"] / WORLD.size) * map_rect.size, 5.0, Color8(231, 69, 55))

	# 下方軍陣列：主角、主戰名將與全部後備被動名將集中呈現。
	draw_panel(HUD_HERO_RAIL_RECT, Color(0.014, 0.020, 0.021, 0.88), Color(0.45, 0.39, 0.27, 0.75), 1.2)

	# 主角狀態卡。
	var player_card: Rect2 = Rect2(HUD_HERO_RAIL_RECT.position + Vector2(8, 7), Vector2(198, 62))
	draw_panel(player_card, Color(0.055, 0.047, 0.034, 0.96), identities[chosen_identity]["color"], 1.5)
	var player_portrait: Rect2 = Rect2(player_card.position + Vector2(5, 5), Vector2(44, 52))
	draw_texture_contain(hero_portrait(str(chosen_identity)), player_portrait)
	draw_text("主角｜%s Lv.%d" % [identities[chosen_identity]["name"], int(player["level"])], player_card.position + Vector2(56, 19), 12, Color8(241, 222, 175), true, HORIZONTAL_ALIGNMENT_LEFT, 134)
	var player_hp_track: Rect2 = Rect2(player_card.position + Vector2(56, 25), Vector2(128, 7))
	draw_rect(player_hp_track, Color8(55, 37, 34), true)
	draw_rect(Rect2(player_hp_track.position, Vector2(player_hp_track.size.x * hp_ratio_hud, player_hp_track.size.y)), Color8(190, 61, 55), true)
	draw_text("HP %d/%d　盾 %d" % [int(player["hp"]), int(player["max_hp"]), int(player["shield"])], player_card.position + Vector2(56, 44), 10, Color8(207, 213, 202))
	draw_text("閃避 %s" % ("READY" if dodge_left_hud <= 0.0 else "%.1fs" % dodge_left_hud), player_card.position + Vector2(56, 57), 9, Color8(126, 218, 225) if dodge_left_hud <= 0.0 else Color8(205, 178, 126), true)

	# 主戰技能卡。
	var active_origin_x: float = player_card.end.x + 8.0
	var active_area_w: float = 560.0
	var slot_count: int = max(1, active_limit())
	var active_gap: float = 5.0
	var active_card_w: float = (active_area_w - active_gap * float(slot_count - 1)) / float(slot_count)
	for i in range(slot_count):
		var card: Rect2 = Rect2(active_origin_x + i * (active_card_w + active_gap), HUD_HERO_RAIL_RECT.position.y + 7.0, active_card_w, 62.0)
		if i < active_heroes.size():
			var hero_id: String = str(active_heroes[i])
			draw_panel(card, Color(0.045, 0.052, 0.055, 0.96), heroes[hero_id]["color"], 1.4)
			draw_texture_contain(hero_portrait(str(hero_id)), Rect2(card.position + Vector2(4, 5), Vector2(40, 50)))
			var text_x: float = card.position.x + 48.0
			var text_w: float = max(42.0, card.size.x - 53.0)
			draw_text("%d｜%s" % [i + 1, heroes[hero_id]["name"]], Vector2(text_x, card.position.y + 18), 11, Color8(239, 224, 187), true, HORIZONTAL_ALIGNMENT_LEFT, text_w)
			var cooldown: float = float(hero_cooldowns.get(hero_id, 0.0))
			var cd_ratio: float = clamp(cooldown / max(0.01, hero_cooldown_value(hero_id)), 0.0, 1.0)
			var track: Rect2 = Rect2(text_x, card.position.y + 27, text_w - 3.0, 6)
			draw_rect(track, Color8(47, 52, 51), true)
			draw_rect(Rect2(track.position, Vector2(track.size.x * (1.0 - cd_ratio), track.size.y)), Color8(117, 190, 132) if cooldown <= 0.0 else Color8(194, 151, 79), true)
			draw_text("可施放" if cooldown <= 0.0 else "%.1fs" % cooldown, Vector2(text_x, card.position.y + 48), 9, Color8(150, 220, 160) if cooldown <= 0.0 else Color8(205, 181, 133), false, HORIZONTAL_ALIGNMENT_LEFT, text_w)
		else:
			draw_panel(card, Color(0.035, 0.041, 0.043, 0.82), Color8(73, 78, 74), 1.0)
			draw_centered_text("主戰空位", card, 38.0, 10, Color8(117, 123, 117))

	# 後備被動名將列。所有已編入後備者都納入，超過可視寬度時壓縮尺寸。
	var reserve_origin_x: float = active_origin_x + active_area_w + 10.0
	var reserve_area: Rect2 = Rect2(reserve_origin_x, HUD_HERO_RAIL_RECT.position.y + 6.0, HUD_HERO_RAIL_RECT.end.x - reserve_origin_x - 8.0, 64.0)
	draw_text("後備被動 %d/%d" % [reserve_heroes.size(), reserve_limit()], reserve_area.position + Vector2(2, 12), 9, Color8(186, 194, 181), true)
	var reserve_count: int = reserve_heroes.size()
	if reserve_count == 0:
		draw_text("尚無後備名將", reserve_area.position + Vector2(2, 39), 10, Color8(112, 120, 113))
	else:
		var reserve_gap: float = 3.0
		var reserve_icon_w: float = clamp((reserve_area.size.x - reserve_gap * float(max(0, reserve_count - 1))) / float(reserve_count), 28.0, 47.0)
		for i in range(reserve_count):
			var reserve_id: String = str(reserve_heroes[i])
			var reserve_card: Rect2 = Rect2(reserve_area.position.x + i * (reserve_icon_w + reserve_gap), reserve_area.position.y + 17.0, reserve_icon_w, 44.0)
			draw_panel(reserve_card, Color(0.032, 0.039, 0.040, 0.94), Color(heroes[reserve_id]["color"], 0.72), 1.0)
			draw_texture_contain(hero_portrait(str(reserve_id)), Rect2(reserve_card.position + Vector2(3, 3), Vector2(reserve_card.size.x - 6, 28)))
			var short_name: String = str(heroes[reserve_id]["name"])
			draw_text(short_name, reserve_card.position + Vector2(1, 40), 8, Color8(206, 211, 199), true, HORIZONTAL_ALIGNMENT_CENTER, reserve_card.size.x - 2)

	# 主動名將施放時改為角色頭上的小型喊招，不再使用全畫面大字。
	if not hero_cast_flash.is_empty():
		var cast_id: String = str(hero_cast_flash.get("id", ""))
		if sprite_tex.has(cast_id):
			var cast_alpha: float = clamp(float(hero_cast_flash.get("life", 0.0)) / max(0.01, float(hero_cast_flash.get("max_life", 1.0))), 0.0, 1.0)
			var cast_progress: float = 1.0 - cast_alpha
			var cast_center: Vector2 = world_to_screen(hero_cast_flash.get("pos", player["pos"]))
			var cast_side: float = -1.0 if int(active_heroes.find(cast_id)) % 2 == 0 else 1.0
			var cast_pose: Dictionary = Alpha27ActionProfiles.cast_pose(cast_id, cast_progress)
			var cast_pos: Vector2 = cast_center + Vector2(46.0 * cast_side, -24.0 + float(cast_pose.get("rise", 0.0)))
			var cast_scale: float = float(cast_pose.get("scale", 1.15))
			draw_circle(cast_pos, 24.0 + sin(elapsed * 9.0) * 2.0, Color(heroes.get(cast_id, {}).get("color", Color.WHITE), 0.18 * cast_alpha))
			draw_sprite_pose(sprite_tex[cast_id], cast_pos, cast_scale, int(cast_progress * 8.0) % 4, Color(1, 1, 1, min(1.0, cast_alpha * 1.8)), float(cast_pose.get("rotation", 0.0)))
	if not hero_cast_flash.is_empty():
		var shout_id: String = str(hero_cast_flash.get("id", ""))
		if heroes.has(shout_id):
			var shout_alpha: float = clamp(float(hero_cast_flash.get("life", 0.0)) / max(0.01, float(hero_cast_flash.get("max_life", 1.0))), 0.0, 1.0)
			var shout_text: String = str(heroes[shout_id].get("shout", "%s！" % heroes[shout_id]["name"]))
			var shout_world: Vector2 = hero_cast_flash.get("pos", player["pos"])
			var shout_pos: Vector2 = world_to_screen(shout_world) + Vector2(0, -52.0 - (1.0 - shout_alpha) * 8.0)
			var shout_w: float = min(220.0, font_bold.get_string_size(shout_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x + 22.0)
			var shout_rect: Rect2 = Rect2(shout_pos.x - shout_w * 0.5, shout_pos.y - 22.0, shout_w, 25.0)
			draw_panel(shout_rect, Color(0.02, 0.025, 0.025, 0.75 * shout_alpha), Color(0.88, 0.70, 0.34, shout_alpha), 1.2)
			draw_centered_text(shout_text, shout_rect, 18.0, 13, Color(1.0, 0.92, 0.72, shout_alpha), true)

	# 低血量與無敵時間提示：只畫邊緣，不遮住戰場中心。
	if hp_ratio_hud <= 0.30:
		var danger_alpha: float = (0.30 - hp_ratio_hud) / 0.30 * (0.16 + 0.08 * (0.5 + 0.5 * sin(elapsed * 6.0)))
		draw_rect(Rect2(0, 0, VIEW.x, 18), Color(0.72, 0.03, 0.03, danger_alpha), true)
		draw_rect(Rect2(0, VIEW.y - 18, VIEW.x, 18), Color(0.72, 0.03, 0.03, danger_alpha), true)
		draw_rect(Rect2(0, 0, 18, VIEW.y), Color(0.72, 0.03, 0.03, danger_alpha), true)
		draw_rect(Rect2(VIEW.x - 18, 0, 18, VIEW.y), Color(0.72, 0.03, 0.03, danger_alpha), true)
	if float(player.get("invuln", 0.0)) > 0.0:
		var inv_alpha: float = 0.20 + 0.12 * (0.5 + 0.5 * sin(elapsed * 24.0))
		draw_arc(world_to_screen(player["pos"]), 29.0, 0, TAU, 32, Color(0.72, 0.92, 1.0, inv_alpha), 2.0)

	if checkpoint_notice_timer > 0.0 and checkpoint_notice != "":
		var save_rect: Rect2 = Rect2(1030, 520, 222, 34)
		draw_panel(save_rect, Color(0.025, 0.055, 0.04, 0.92), Color8(120, 197, 139), 1.2)
		draw_centered_text(checkpoint_notice, save_rect, 23.0, 14, Color8(181, 231, 188), true)
	# 系統訊息固定在技能欄正上方，使用真正的矩形置中。
	if game_message_timer > 0.0 and game_message != "":
		var width: float = min(650.0, font_bold.get_string_size(game_message, HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x + 46.0)
		var message_rect: Rect2 = Rect2(640.0 - width * 0.5, HUD_MESSAGE_Y, width, 36.0)
		draw_panel(message_rect, Color(0.02, 0.025, 0.025, 0.90), Color(0.77, 0.61, 0.31, 0.85), 1.3)
		draw_centered_text(game_message, message_rect.grow(-8.0), 24.0, 16, Color8(245, 231, 196), true)


func draw_overlay_backdrop() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.015, 0.018, 0.019, 0.72), true)


func chapter_intro_beats(chapter: Dictionary) -> Array[String]:
	var intro: String = str(chapter.get("intro", "亂世烽煙再起，你將在此章寫下新的命運。"))
	var place: String = str(chapter.get("place", "前線"))
	var boss_def: Dictionary = chapter_manager.boss_definition()
	var enemy_name: String = str(boss_def.get("name", "敵軍主將"))
	return [
		intro,
		"鏡頭轉向%s。斥候回報：%s已整軍壓境，沿途百姓與潰兵令戰線更加混亂。" % [place, enemy_name],
		"此戰不只關乎勝負。你的奇遇抉擇、同行名將與裝備配置，都將改寫這一章的結局。"
	]


func draw_chapter_intro_screen() -> void:
	draw_overlay_backdrop()
	var chapter: Dictionary = current_chapter()
	var boss_def: Dictionary = chapter_manager.boss_definition()
	var boss_id: String = str(boss_def.get("id", ""))
	var panel: Rect2 = Rect2(92, 58, 1096, 606)
	draw_panel(panel, Color(0.026, 0.031, 0.03, 0.99), Color8(190, 151, 81), 2.2)
	# 左側以本章敵將立繪建立章回辨識度。
	var art_rect: Rect2 = Rect2(118, 92, 360, 500)
	draw_panel(art_rect, Color(0.025, 0.028, 0.028, 0.96), Color8(91, 83, 64), 1.0)
	if boss_id != "" and portrait_tex.has(boss_id):
		draw_remaster_portrait(boss_id, art_rect.grow(-4.0), 0.7)
	else:
		draw_centered_text("亂世烽煙", art_rect, 255.0, 28, Color8(201, 180, 126), true)
	var content: Rect2 = Rect2(505, 86, 640, 520)
	draw_text("第%d章" % (int(chapter.get("index", 0)) + 1), content.position + Vector2(0, 36), 20, Color8(205, 183, 130), true)
	draw_text(str(chapter.get("title", "亂世征途")), content.position + Vector2(0, 86), 37, Color8(242, 215, 151), true, HORIZONTAL_ALIGNMENT_LEFT, 610)
	draw_text(str(chapter.get("place", "")), content.position + Vector2(0, 119), 17, Color8(181, 192, 183))
	var beats: Array[String] = chapter_intro_beats(chapter)
	var beat: String = beats[clampi(chapter_intro_page, 0, beats.size() - 1)]
	draw_text("章回演出 %d／3" % (chapter_intro_page + 1), content.position + Vector2(0, 163), 15, Color8(197, 166, 103), true)
	draw_wrapped(beat, Rect2(content.position + Vector2(0, 183), Vector2(610, 150)), 20, Color8(219, 220, 205), 31.0, true)
	if chapter_intro_page == 2:
		var objective: String = str(chapter.get("objective", "擊退敵軍，迎戰章末敵將。"))
		var feature: String = str(chapter.get("feature", chapter.get("special", "留意戰場事件與敵軍增援。")))
		draw_panel(Rect2(content.position + Vector2(0, 345), Vector2(610, 112)), Color(0.055, 0.06, 0.055, 0.94), Color8(112, 103, 76), 1.2)
		draw_text("本章目標", content.position + Vector2(20, 379), 17, Color8(237, 207, 137), true)
		draw_wrapped(objective, Rect2(content.position + Vector2(125, 361), Vector2(465, 35)), 15, Color8(211, 215, 204), 22.0)
		draw_text("戰場提示", content.position + Vector2(20, 424), 17, Color8(237, 207, 137), true)
		draw_wrapped(feature, Rect2(content.position + Vector2(125, 406), Vector2(465, 35)), 15, Color8(211, 215, 204), 22.0)
	else:
		draw_text("敵將：%s・%s" % [str(boss_def.get("title", "敵軍主將")), str(boss_def.get("name", "未知"))], content.position + Vector2(0, 390), 18, Color8(221, 183, 108), true)
	# 頁面節點與操作提示。
	for i in range(3):
		var dot_pos: Vector2 = Vector2(635 + i * 28, 620)
		draw_circle(dot_pos, 6.0 if i == chapter_intro_page else 4.0, Color8(231, 195, 111) if i == chapter_intro_page else Color8(94, 96, 88))
	draw_text("←→翻頁　Enter／Space繼續　Esc略過", Vector2(865, 628), 14, Color8(183, 191, 182), false, HORIZONTAL_ALIGNMENT_CENTER, 520)


func draw_boss_intro_screen() -> void:
	draw_overlay_backdrop()
	var definition: Dictionary = chapter_manager.boss_definition()
	var bid: String = str(boss.get("id", definition.get("id", "zhangliang")))
	var pr: Rect2 = Rect2(70, 80, 410, 555)
	if portrait_tex.has(bid):
		draw_remaster_portrait(bid, pr, 1.0)
	draw_rect(Rect2(455, 70, 760, 570), Color(0.03, 0.035, 0.037, 0.94), true)
	draw_text(
		str(definition.get("title", "敵將")), Vector2(525, 180), 28, Color8(226, 200, 111), true
	)
	var display_name: String = str(definition.get("name", "未知"))
	if display_name.length() == 2:
		display_name = "%s　%s" % [display_name.substr(0, 1), display_name.substr(1, 1)]
	draw_text(display_name, Vector2(525, 258), 65, Color8(241, 224, 177), true)
	var quote: String = str(definition.get("quote", "「來戰！」"))
	if bid == "lvbu" and active_bonds.has("taoyuan"):
		quote = "「又是你們三人？今日便一併了結！」"
	elif (
		bid == "huaxiong"
		and active_heroes.has("liubei")
		and active_heroes.has("caocao")
		and active_heroes.has("sunjian")
	):
		quote = "「三路諸侯齊至？照樣斬於刀下！」"
	elif bid == "gaoshun" and active_bonds.has("western_resolve"):
		quote = "「西涼烈志？且看誰能踏破陷陣！」"
	elif bid == "yuanshao" and active_bonds.has("wenji_return"):
		quote = "「曹孟德竟借胡笳定軍心？徒勞而已！」"
	draw_wrapped(quote, Rect2(525, 330, 620, 100), 30, Color8(238, 211, 143), 42.0, true)
	draw_text("戰鬥即將開始", Vector2(525, 552), 21, Color8(188, 194, 185))
	if boss_cooperation_multiplier() > 1.0:
		draw_text("特殊歷史合作生效：對此敵將強化", Vector2(525, 590), 18, Color8(132, 222, 160), true)


func draw_levelup_screen() -> void:
	draw_overlay_backdrop()
	draw_text(
		"境界提升", Vector2(640, 105), 42, Color8(240, 214, 145), true, HORIZONTAL_ALIGNMENT_CENTER, 500
	)
	var count: int = min(5, level_choices.size())
	var columns: int = 3 if count > 3 else count
	var rows: int = 2 if count > 3 else 1
	var w: float = 300.0
	var h: float = 220.0 if rows == 2 else 360.0
	var start_x: float = 640.0 - columns * w * 0.5
	for i in range(count):
		var sid: String = str(level_choices[i])
		var is_hero_skill: bool = sid.begins_with("hero_skill:")
		var is_hero_bond: bool = sid.begins_with("hero_bond:")
		var hero_id: String = str(sid.split(":", false, 1)[1]) if (is_hero_skill or is_hero_bond) else ""
		var col: int = i % columns
		var row: int = int(i / columns)
		var r: Rect2 = Rect2(start_x + col * w + 8, 155 + row * (h + 14), w - 16, h)
		draw_panel(
			r,
			Color(0.07, 0.075, 0.075, 0.97) if i != option_index else Color(0.20, 0.15, 0.07, 0.98),
			Color8(229, 199, 124) if i == option_index else Color8(102, 105, 96),
			3.0 if i == option_index else 1.5
		)
		var card_name: String = str(skill_defs[sid]["name"]) if not (is_hero_skill or is_hero_bond) else "%s・%s" % [str(heroes[hero_id]["name"]), "技能精進" if is_hero_skill else "羈絆深化"]
		var old_lv: int = skill_level(sid) if not (is_hero_skill or is_hero_bond) else (hero_skill_level(hero_id) if is_hero_skill else hero_bond_level(hero_id))
		var card_desc: String = str(skill_defs[sid]["desc"]) if not (is_hero_skill or is_hero_bond) else HeroProgressionRules.upgrade_description(hero_id, old_lv + 1, is_hero_skill)
		draw_text(
			card_name, r.position + Vector2(18, 48), 24, Color8(237, 217, 166), true
		)
		draw_text(
			"Lv.%d → Lv.%d" % [old_lv, old_lv + 1],
			r.position + Vector2(18, 80),
			17,
			Color8(143, 205, 172),
			true
		)
		draw_wrapped(
			card_desc,
			Rect2(r.position + Vector2(18, 110), Vector2(r.size.x - 36, max(65.0, r.size.y - 150.0))),
			18,
			Color8(214, 218, 207),
			27.0
		)
		draw_text("Enter／Space", r.position + Vector2(18, r.size.y - 22), 15, Color8(170, 176, 168))


func draw_hero_candidate_screen() -> void:
	option_index = clampi(option_index, 0, encounter_candidates.size() + 1)
	draw_overlay_backdrop()
	var panel: Rect2 = Rect2(70, 54, 1140, 612)
	draw_panel(panel, Color(0.035, 0.04, 0.041, 0.98), Color8(213, 177, 103), 2.5)
	draw_centered_text("招賢館", panel, 54.0, 36, Color8(239, 215, 159), true)
	draw_centered_text("今日有 %d 位豪傑願意投效；只能擇一同行。" % encounter_candidates.size(), panel, 88.0, 16, Color8(190, 196, 190))
	var count: int = max(1, encounter_candidates.size())
	var gap: float = 18.0
	var cards_w: float = panel.size.x - 96.0
	var card_w: float = min(330.0, (cards_w - gap * float(count - 1)) / float(count))
	var total_w: float = card_w * float(count) + gap * float(count - 1)
	var start_x: float = panel.position.x + (panel.size.x - total_w) * 0.5
	for i in range(encounter_candidates.size()):
		var hid: String = encounter_candidates[i]
		var rect := Rect2(start_x + i * (card_w + gap), 165, card_w, 350)
		var selected: bool = i == option_index
		draw_panel(rect, Color(0.20, 0.15, 0.08, 0.96) if selected else Color(0.05, 0.055, 0.052, 0.96), heroes[hid]["color"] if selected else Color8(104, 103, 88), 2.4 if selected else 1.2)
		draw_remaster_portrait(hid, Rect2(rect.position + Vector2(16, 14), Vector2(rect.size.x - 32, 170)), 0.52)
		draw_centered_text(str(heroes[hid]["name"]), rect, 214.0, 25, heroes[hid]["color"], true)
		draw_centered_text(str(heroes[hid]["title"]), rect, 242.0, 14, Color8(222, 211, 178))
		var tactical_tag: String = HeroRecruitmentAffinityService.element_label(hid)
		var affinity_hint: String = HeroRecruitmentAffinityService.affinity_hint(self, hid)
		var synergy_hint: String = HeroRecruitmentAffinityService.synergy_description(hid)
		draw_centered_text(tactical_tag, rect, 263.0, 12, Color8(196, 207, 191), true)
		if affinity_hint != "":
			draw_centered_text(affinity_hint, rect, 282.0, 11, Color8(238, 199, 112), true)
		elif synergy_hint != "":
			draw_centered_text(synergy_hint, rect, 282.0, 10, Color8(166, 190, 177))
		draw_wrapped("主動：%s\n後備：%s" % [heroes[hid]["active"], heroes[hid]["passive"]], Rect2(rect.position + Vector2(16, 300), Vector2(rect.size.x - 32, 42)), 10, Color8(205, 211, 202), 15.0)
	var refresh_index: int = encounter_candidates.size()
	var leave_index: int = encounter_candidates.size() + 1
	var refresh_rect: Rect2 = Rect2(panel.position.x + 215, 525, 340, 56)
	var leave_rect: Rect2 = Rect2(panel.position.x + panel.size.x - 555, 525, 340, 56)
	var free_refresh: bool = recruit_refresh_is_free()
	var refresh_label: String = "刷新名單（免費）" if free_refresh else "刷新名單（%d 銅錢）" % recruit_refresh_cost()
	for item in [[refresh_rect, refresh_index, refresh_label], [leave_rect, leave_index, "離開招賢館"]]:
		var r: Rect2 = item[0]
		var idx: int = item[1]
		var selected: bool = option_index == idx
		draw_panel(r, Color(0.42, 0.30, 0.13, 0.82) if selected else Color(0.055, 0.058, 0.055, 0.94), Color8(220, 184, 108) if selected else Color8(102, 103, 94), 1.8)
		draw_centered_text(str(item[2]), r, 36.0, 18, Color8(240, 224, 187), selected)
	draw_centered_text("←→／↑↓切換　Enter／Space確認", panel, 590.0, 14, Color8(166, 172, 164))


func draw_hero_encounter_screen() -> void:
	draw_overlay_backdrop()
	var hid: String = current_encounter
	if hid == "":
		return
	draw_panel(
		Rect2(100, 70, 1080, 580), Color(0.035, 0.04, 0.041, 0.98), heroes[hid]["color"], 2.5
	)
	draw_remaster_portrait(hid, Rect2(130, 100, 345, 475), 0.75)
	draw_text(heroes[hid]["name"], Vector2(520, 150), 43, heroes[hid]["color"], true)
	draw_text(heroes[hid]["title"], Vector2(520, 190), 22, Color8(222, 211, 178), true)
	draw_wrapped(
		"主動：%s\n\n後備：%s" % [heroes[hid]["active"], heroes[hid]["passive"]],
		Rect2(520, 225, 600, 170),
		18,
		Color8(211, 217, 207),
		28.0
	)
	var opts: Array[String] = ["邀請同行（主動）", "留作後援（後備）", "暫不同行"]
	for i in range(3):
		var r: Rect2 = Rect2(520, 430 + i * 54, 560, 43)
		if i == option_index:
			draw_rect(r, Color(0.55, 0.39, 0.16, 0.78), true)
		draw_text(
			("▶ " if i == option_index else "　") + opts[i],
			r.position + Vector2(15, 29),
			20,
			Color8(242, 228, 192),
			i == option_index
		)


func draw_replace_screen() -> void:
	draw_overlay_backdrop()
	var panel := Rect2(260, 100, 760, 520)
	draw_panel(panel, Color(0.035, 0.04, 0.041, 0.98), Color8(220, 188, 112), 2.0)
	draw_centered_text("主動欄已滿：請選擇替換名將", panel, 58.0, 28, Color8(239, 215, 159), true)
	for i in range(active_heroes.size() + 1):
		var label: String = "取消，改列後備"
		if i < active_heroes.size():
			var hid: String = str(active_heroes[i])
			label = "替換 %s Lv.%d" % [heroes[hid]["name"], hero_levels.get(hid, 1)]
		var r: Rect2 = Rect2(panel.position.x + 80, panel.position.y + 105 + i * 68, 600, 52)
		draw_panel(r, Color(0.53, 0.36, 0.14, 0.82) if i == option_index else Color(0.045, 0.05, 0.05, 0.85), Color8(220, 188, 112) if i == option_index else Color8(90, 88, 76), 1.5 if i == option_index else 1.0)
		draw_centered_text(("▶ " if i == option_index else "") + label, r, 34.0, 21, Color8(238, 226, 198), i == option_index)


func draw_shop_screen() -> void:
	draw_overlay_backdrop()
	draw_panel(Rect2(90, 48, 1100, 624), Color(0.04, 0.042, 0.039, 0.98), Color8(202, 160, 80), 2.2)
	var mdef: Dictionary = merchant_defs.get(merchant_kind, merchant_defs.get("peddler", {}))
	draw_text(str(mdef.get("name", "行商貨棧")), Vector2(130, 96), 35, Color8(239, 209, 135), true)
	draw_text("%s｜持有銅錢：%d" % [str(mdef.get("subtitle", "遺物與裝備分區販售")), player["coins"]], Vector2(720, 92), 18, Color8(225, 205, 153), true)
	for i in range(shop_choices.size()):
		var col: int = i % 2
		var row: int = int(i / 2)
		var rect: Rect2 = Rect2(130 + col * 520, 118 + row * 90, 490, 76)
		var selected: bool = i == option_index
		draw_panel(rect, Color(0.43, 0.30, 0.12, 0.88) if selected else Color(0.055, 0.06, 0.057, 0.94), Color8(233, 193, 103) if selected else Color8(105, 100, 78), 1.8 if selected else 1.0)
		var item: Dictionary = shop_choices[i]
		var kind: String = str(item["kind"])
		if kind == "relic":
			var rid: String = str(item["id"])
			draw_texture_contain(relic_tex[rid], Rect2(rect.position + Vector2(10, 10), Vector2(52, 52)))
			draw_text("遺物｜%s　Lv.%d" % [relic_defs[rid]["name"], relic_level(rid) + 1 if has_relic(rid) else 1], rect.position + Vector2(73, 27), 18, relic_rarity_color(str(item.get("rarity", "common"))), true)
			draw_text(relic_defs[rid]["desc"], rect.position + Vector2(73, 50), 12, Color8(195, 202, 194), false, HORIZONTAL_ALIGNMENT_LEFT, 305)
		elif kind == "equipment":
			var eid: String = str(item["id"])
			var edef: Dictionary = equipment_defs[eid]
			draw_texture_contain(equipment_tex[eid], Rect2(rect.position + Vector2(10, 10), Vector2(52, 52)))
			draw_text("%s｜%s" % [equipment_slot_name(str(edef["slot"])), edef["name"]], rect.position + Vector2(73, 27), 18, relic_rarity_color(str(item.get("rarity", "common"))), true)
			draw_text(str(edef["desc"]), rect.position + Vector2(73, 50), 12, Color8(195, 202, 194), false, HORIZONTAL_ALIGNMENT_LEFT, 305)
		elif kind == "heal":
			draw_text("回春藥包", rect.position + Vector2(24, 28), 19, Color8(151, 224, 164), true)
			draw_text("立即回復28生命。", rect.position + Vector2(24, 53), 13, Color8(195, 202, 194))
		else:
			draw_text("名將整備", rect.position + Vector2(24, 28), 19, Color8(161, 207, 232), true)
			draw_text("調整主動／後備名將。", rect.position + Vector2(24, 53), 13, Color8(195, 202, 194))
		if kind != "config":
			draw_text("%d錢" % int(item.get("price", 0)), rect.position + Vector2(420, 28), 15, Color8(244, 205, 109), true)
	var leave_index: int = shop_choices.size()
	var leave_rect: Rect2 = Rect2(390, 583, 500, 48)
	draw_panel(leave_rect, Color(0.43, 0.30, 0.12, 0.88) if option_index == leave_index else Color(0.05, 0.055, 0.052, 0.94), Color8(233, 193, 103) if option_index == leave_index else Color8(105, 100, 78), 1.8 if option_index == leave_index else 1.0)
	draw_centered_text("離開貨棧", leave_rect, 32.0, 19, Color8(236, 225, 199), option_index == leave_index)
	draw_text("↑↓切換列　←→切換商品　Enter／Space購買　Esc離開", Vector2(640, 655), 14, Color8(188, 194, 185), false, HORIZONTAL_ALIGNMENT_CENTER, 860)

func draw_hero_config_screen() -> void:
	if hero_config_origin != "intermission":
		draw_overlay_backdrop()
	else:
		draw_rect(Rect2(Vector2.ZERO, VIEW), Color8(24, 29, 29), true)

	var root: Rect2 = Rect2(72, 42, 1136, 636)
	draw_panel(root, Color(0.03, 0.036, 0.038, 0.985), Color8(182, 151, 89), 2.0)
	draw_text("名將整備", root.position + Vector2(36, 48), 34, Color8(239, 214, 156), true)
	draw_text(
		"主戰 %d／%d　後備 %d／%d　營地 %d" % [active_heroes.size(), active_limit(), reserve_heroes.size(), reserve_limit(), camp_heroes.size()],
		root.position + Vector2(root.size.x - 36, 45), 16, Color8(193, 201, 193), true,
		HORIZONTAL_ALIGNMENT_RIGHT, 440
	)

	# 主戰與後備各自獨立成列，玩家可直接看懂目前編成。
	var active_panel: Rect2 = Rect2(108, 112, 1040, 76)
	draw_panel(active_panel, Color(0.04, 0.045, 0.044, 0.96), Color8(132, 112, 70), 1.2)
	draw_text("主戰陣容", active_panel.position + Vector2(14, 24), 17, Color8(235, 211, 153), true)
	var active_slots_x: float = active_panel.position.x + 104.0
	var active_slot_w: float = min(174.0, (active_panel.size.x - 118.0 - 10.0 * float(max(0, active_limit() - 1))) / float(max(1, active_limit())))
	for slot_i in range(active_limit()):
		var slot_rect: Rect2 = Rect2(active_slots_x + slot_i * (active_slot_w + 10.0), active_panel.position.y + 9.0, active_slot_w, 58.0)
		draw_panel(slot_rect, Color(0.05, 0.055, 0.053, 0.96), Color8(112, 103, 79), 1.0)
		if slot_i < active_heroes.size():
			var slot_id: String = str(active_heroes[slot_i])
			draw_texture_contain(hero_portrait(str(slot_id)), Rect2(slot_rect.position + Vector2(5, 5), Vector2(44, 48)))
			draw_text(str(heroes[slot_id]["name"]), slot_rect.position + Vector2(56, 25), 15, heroes[slot_id]["color"], true, HORIZONTAL_ALIGNMENT_LEFT, max(60.0, slot_rect.size.x - 62.0))
			draw_text("Lv.%d" % int(hero_bond_level(slot_id)), slot_rect.position + Vector2(56, 45), 11, Color8(177, 186, 177))
		else:
			draw_centered_text("空位", slot_rect, 35.0, 14, Color8(126, 132, 126))

	var reserve_panel: Rect2 = Rect2(108, 198, 1040, 76)
	draw_panel(reserve_panel, Color(0.035, 0.043, 0.048, 0.96), Color8(82, 125, 151), 1.2)
	draw_text("後備陣容", reserve_panel.position + Vector2(14, 24), 17, Color8(157, 207, 232), true)
	var reserve_slots_x: float = reserve_panel.position.x + 104.0
	var reserve_count: int = max(1, reserve_limit())
	var reserve_slot_w: float = min(174.0, (reserve_panel.size.x - 118.0 - 10.0 * float(max(0, reserve_count - 1))) / float(reserve_count))
	for slot_i in range(reserve_count):
		var slot_rect: Rect2 = Rect2(reserve_slots_x + slot_i * (reserve_slot_w + 10.0), reserve_panel.position.y + 9.0, reserve_slot_w, 58.0)
		draw_panel(slot_rect, Color(0.043, 0.052, 0.058, 0.96), Color8(83, 126, 151), 1.0)
		if slot_i < reserve_heroes.size():
			var slot_id: String = str(reserve_heroes[slot_i])
			draw_texture_contain(hero_portrait(str(slot_id)), Rect2(slot_rect.position + Vector2(5, 5), Vector2(44, 48)))
			draw_text(str(heroes[slot_id]["name"]), slot_rect.position + Vector2(56, 25), 15, heroes[slot_id]["color"], true, HORIZONTAL_ALIGNMENT_LEFT, max(60.0, slot_rect.size.x - 62.0))
			draw_text("被動 Lv.%d" % int(hero_bond_level(slot_id)), slot_rect.position + Vector2(56, 45), 11, Color8(157, 199, 220))
		else:
			draw_centered_text("空位", slot_rect, 35.0, 14, Color8(111, 137, 149))

	var order: Array[String] = known_hero_order()
	if order.is_empty():
		draw_text("尚未結識任何名將。", Vector2(108, 320), 22, Color8(196, 202, 195))
		return
	hero_config_index = clampi(hero_config_index, 0, order.size() - 1)

	var list_panel: Rect2 = Rect2(108, 290, 500, 326)
	draw_panel(list_panel, Color(0.038, 0.043, 0.044, 0.96), Color8(102, 96, 76), 1.2)
	draw_text("全部名將", list_panel.position + Vector2(18, 30), 20, Color8(225, 205, 160), true)
	var visible_count: int = 5
	var start: int = clampi(hero_config_index - int(visible_count / 2), 0, max(0, order.size() - visible_count))
	var finish: int = min(order.size(), start + visible_count)
	for i in range(start, finish):
		var hid: String = order[i]
		var row: int = i - start
		var rect: Rect2 = Rect2(list_panel.position.x + 12, list_panel.position.y + 48 + row * 52, list_panel.size.x - 24, 46)
		if i == hero_config_index:
			draw_rect(rect, Color(0.45, 0.31, 0.12, 0.88), true)
		draw_texture_contain(hero_portrait(str(hid)), Rect2(rect.position + Vector2(5, 4), Vector2(40, 38)))
		var state: String = "主戰" if active_heroes.has(hid) else ("後備" if reserve_heroes.has(hid) else "營地")
		var state_color: Color = Color8(232, 196, 112) if state == "主戰" else (Color8(129, 191, 225) if state == "後備" else Color8(157, 164, 157))
		draw_text("%s　Lv.%d" % [heroes[hid]["name"], hero_bond_level(hid)], rect.position + Vector2(53, 29), 17, heroes[hid]["color"], true, HORIZONTAL_ALIGNMENT_LEFT, 270)
		var badge: Rect2 = Rect2(rect.end.x - 92, rect.position.y + 8, 78, 30)
		draw_panel(badge, Color(state_color.r, state_color.g, state_color.b, 0.13), state_color, 1.0)
		draw_centered_text(state, badge, 21.0, 13, state_color, true)

	var selected_id: String = order[hero_config_index]
	var detail_panel: Rect2 = Rect2(630, 290, 518, 326)
	draw_panel(detail_panel, Color(0.045, 0.05, 0.05, 0.94), heroes[selected_id]["color"], 1.5)
	draw_texture_contain(hero_portrait(str(selected_id)), Rect2(detail_panel.position + Vector2(18, 22), Vector2(156, 204)))
	draw_text(str(heroes[selected_id]["name"]), detail_panel.position + Vector2(198, 48), 30, heroes[selected_id]["color"], true, HORIZONTAL_ALIGNMENT_LEFT, 285)
	draw_text(str(heroes[selected_id]["title"]), detail_panel.position + Vector2(198, 78), 17, Color8(223, 212, 179), true, HORIZONTAL_ALIGNMENT_LEFT, 285)
	draw_text("主動技能", detail_panel.position + Vector2(198, 112), 15, Color8(228, 204, 150), true)
	draw_wrapped(str(heroes[selected_id]["active"]), Rect2(detail_panel.position + Vector2(198, 122), Vector2(286, 62)), 13, Color8(207, 214, 205), 19.0)
	draw_text("後備能力", detail_panel.position + Vector2(198, 198), 15, Color8(157, 207, 232), true)
	draw_wrapped(str(heroes[selected_id]["passive"]), Rect2(detail_panel.position + Vector2(198, 208), Vector2(286, 58)), 13, Color8(207, 214, 205), 19.0)
	var state_label: String = "主戰" if active_heroes.has(selected_id) else ("後備" if reserve_heroes.has(selected_id) else "營地")
	var state_color: Color = Color8(232, 196, 112) if state_label == "主戰" else (Color8(129, 191, 225) if state_label == "後備" else Color8(157, 164, 157))
	var state_badge: Rect2 = Rect2(detail_panel.position.x + 18, detail_panel.end.y - 64, 156, 34)
	draw_panel(state_badge, Color(state_color.r, state_color.g, state_color.b, 0.13), state_color, 1.0)
	draw_centered_text("目前：%s" % state_label, state_badge, 24.0, 14, state_color, true)
	draw_text("Enter／Space 調整位置", detail_panel.position + Vector2(198, 294), 14, Color8(230, 211, 168), true)

	draw_text("↑↓選擇名將　Enter／Space調整位置　Esc／Tab返回", Vector2(root.position.x + root.size.x - 36, root.end.y - 17), 13, Color8(181, 189, 181), false, HORIZONTAL_ALIGNMENT_RIGHT, 640)
	if hero_position_picker_open:
		draw_hero_position_picker()


func draw_hero_position_picker() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.0, 0.0, 0.0, 0.66), true)
	var panel: Rect2 = Rect2(335, 132, 610, 456)
	draw_panel(panel, Color(0.028, 0.034, 0.035, 0.995), Color8(215, 181, 105), 2.2)
	var hid: String = hero_position_candidate
	var hero_name: String = str(heroes.get(hid, {}).get("name", hid))
	draw_centered_text("調整%s的編成位置" % hero_name, panel, 54.0, 28, Color8(239, 215, 159), true)
	draw_centered_text("欄位未滿時直接編入；已滿時再選擇替換名將。", panel, 88.0, 14, Color8(180, 190, 181))
	var labels: Array[String] = ["主戰", "後備", "營地", "取消"]
	var descriptions: Array[String] = [
		"跟隨出戰，可施放主動技能。",
		"提供後備能力與羈絆效果。",
		"暫不參戰，也不提供後備效果。",
		"保持目前編成位置。"
	]
	for i in range(labels.size()):
		var r: Rect2 = Rect2(panel.position.x + 52, panel.position.y + 120 + i * 74, panel.size.x - 104, 60)
		var selected: bool = i == hero_position_index
		draw_panel(r, Color(0.42, 0.30, 0.13, 0.94) if selected else Color(0.045, 0.051, 0.051, 0.98), Color8(230, 194, 112) if selected else Color8(96, 99, 91), 1.8 if selected else 1.0)
		draw_text(("▶ " if selected else "　") + labels[i], r.position + Vector2(18, 27), 19, Color8(241, 224, 185), selected)
		draw_text(descriptions[i], r.position + Vector2(142, 26), 14, Color8(191, 201, 191), false, HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 158)
	draw_centered_text("↑↓選擇　Enter／Space確認　Esc取消", panel, 430.0, 13, Color8(169, 178, 169))

func draw_config_replace_screen() -> void:
	draw_overlay_backdrop()
	var panel: Rect2 = Rect2(250, 95, 780, 530)
	draw_panel(panel, Color(0.035, 0.04, 0.041, 0.985), Color8(220, 188, 112), 2.0)
	var is_active: bool = config_replace_mode == "active"
	var title: String = "主戰欄已滿：選擇替換名將" if is_active else "後備欄已滿：選擇返回營地的名將"
	draw_centered_text(title, panel, 55.0, 28, Color8(239, 215, 159), true)
	if config_candidate != "" and heroes.has(config_candidate):
		draw_centered_text("準備編入%s：%s" % ["主戰" if is_active else "後備", heroes[config_candidate]["name"]], panel, 92.0, 18, heroes[config_candidate]["color"], true)
	var pool: Array = active_heroes if is_active else reserve_heroes
	for i in range(pool.size() + 1):
		var label: String = "取消替換"
		if i < pool.size():
			var hid: String = str(pool[i])
			label = ("替換 %s" if is_active else "%s返回營地") % heroes[hid]["name"]
		var rect: Rect2 = Rect2(panel.position.x + 85, panel.position.y + 130 + i * 66, panel.size.x - 170, 50)
		var selected: bool = i == config_replace_index
		draw_panel(rect, Color(0.53, 0.36, 0.14, 0.86) if selected else Color(0.045, 0.05, 0.05, 0.94), Color8(226, 190, 108) if selected else Color8(93, 96, 89), 1.6 if selected else 1.0)
		draw_centered_text(("▶ " if selected else "") + label, rect, 32.0, 20, Color8(238, 226, 198), selected)
	draw_centered_text("↑↓選擇　Enter／Space確認　Esc取消", panel, panel.size.y - 24.0, 13, Color8(170, 179, 170))

func camp_menu_options() -> Array[String]:
	return ["名將編成", "裝備管理", "遺物確認", "返回戰場"]


func choose_camp_menu(index: int) -> void:
	var options: Array[String] = camp_menu_options()
	if index < 0 or index >= options.size():
		return
	match options[index]:
		"名將編成":
			if known_hero_order().is_empty():
				show_message("目前尚無可整備名將。", 2.2)
			else:
				open_hero_config("camp")
		"裝備管理":
			previous_screen = "camp_menu"
			screen = "tab"
			tab_page = 1
			tab_index = 0
			tab_scroll = 0
		"遺物確認":
			previous_screen = "camp_menu"
			screen = "tab"
			tab_page = 2
			tab_index = 0
			tab_scroll = 0
		"返回戰場":
			save_run_checkpoint()
			screen = "game"
			show_message("整備完成，章節進度已保存。", 2.2)


func draw_camp_menu_screen() -> void:
	draw_overlay_backdrop()
	var panel := Rect2(170, 88, 940, 548)
	draw_panel(panel, Color(0.025, 0.028, 0.027, 0.98), Color8(190, 157, 91), 2.0)
	draw_section_header("紮營整備", "檢視遺物、調整裝備與編成名將", Rect2(205, 110, 870, 74))
	draw_text("生命 %d／%d　護盾 %d" % [int(player.get("hp", 0.0)), int(player.get("max_hp", 0.0)), int(player.get("shield", 0.0))], Vector2(215, 210), 18, Color8(226, 215, 184), true)
	draw_text("主戰 %d／%d　後備 %d／%d　營地 %d" % [active_heroes.size(), active_limit(), reserve_heroes.size(), reserve_limit(), camp_heroes.size()], Vector2(215, 244), 17, Color8(190, 201, 190))
	draw_text("遺物 %d件｜%s" % [relics.size(), relic_category_summary()], Vector2(215, 276), 17, Color8(203, 190, 151))
	var options := camp_menu_options()
	for i in range(options.size()):
		var r := Rect2(255, 325 + i * 64, 770, 48)
		draw_action_button(r, options[i], i == option_index, true)
	draw_text("↑↓選擇　Enter／Space確認　離開營地時自動存檔", Vector2(326, 606), 15, Color8(168, 176, 168))


func draw_tab_screen() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.0, 0.0, 0.0, 0.78), true)
	var panel: Rect2 = Rect2(56, 38, 1168, 642)
	draw_panel(panel, Color(0.018, 0.023, 0.025, 0.99), Color8(178, 150, 88), 2.0)
	var tabs: Array[String] = ["名將", "裝備", "遺物", "羈絆", "戰術總覽"]
	var tab_w: float = 216.0
	for i in range(5):
		var r: Rect2 = Rect2(82 + i * (tab_w + 4.0), 62, tab_w, 42)
		draw_panel(r, Color(0.45, 0.31, 0.12, 0.92) if i == tab_page else Color(0.035, 0.04, 0.04, 0.96), Color8(198, 169, 106), 1.0)
		draw_centered_text(tabs[i], r, 28.0, 18, Color8(239, 220, 175), i == tab_page)
	match tab_page:
		0:
			draw_tab_heroes()
		1:
			draw_tab_equipment()
		2:
			draw_tab_relics()
		3:
			draw_tab_bonds()
		4:
			draw_tab_summary()
	var tab_footer: String = "←→切換頁籤　↑↓捲動　Tab／I／Esc返回"
	if previous_screen == "intermission":
		tab_footer = "章間整備｜裝備頁可按 Enter／Space 更換　Tab／Esc返回下一章準備"
	elif previous_screen == "camp_menu":
		tab_footer = "紮營整備｜裝備頁可按 Enter／Space 更換　Tab／Esc返回營帳"
	draw_text(tab_footer, Vector2(82, 657), 15, Color8(177, 184, 177))

func draw_tab_heroes() -> void:
	var content: Rect2 = Rect2(84, 120, 1112, 510)
	draw_text("主動名將", Vector2(92, 151), 22, Color8(235, 211, 153), true)
	var card_count: int = max(1, active_limit())
	var gap: float = 8.0
	var card_w: float = min(240.0, (content.size.x - gap * float(card_count - 1)) / float(card_count))
	var cards_total: float = card_w * float(card_count) + gap * float(card_count - 1)
	var cards_x: float = content.position.x + (content.size.x - cards_total) * 0.5
	for i in range(card_count):
		var r: Rect2 = Rect2(cards_x + i * (card_w + gap), 166, card_w, 124)
		if i < active_heroes.size():
			var hid: String = str(active_heroes[i])
			draw_panel(r, Color(0.045, 0.05, 0.05, 0.96), heroes[hid]["color"], 1.4)
			draw_texture_contain(hero_portrait(str(hid)), Rect2(r.position + Vector2(8, 8), Vector2(65, 82)))
			draw_text("%s Lv.%d" % [heroes[hid]["name"], hero_bond_level(hid)], r.position + Vector2(80, 29), 17, heroes[hid]["color"], true, HORIZONTAL_ALIGNMENT_LEFT, max(50.0, r.size.x - 88.0))
			draw_wrapped(str(heroes[hid]["active"]), Rect2(r.position + Vector2(80, 38), Vector2(max(50.0, r.size.x - 90.0), 72)), 13, Color8(203, 210, 201), 18.0)
		else:
			draw_panel(r, Color(0.035, 0.04, 0.04, 0.8), Color8(78, 83, 78), 1.0)
			draw_centered_text("空位", r, 67.0, 16, Color8(121, 128, 121))
	draw_text("後備名將（↑↓捲動）", Vector2(92, 328), 22, Color8(205, 194, 166), true)
	var visible_rows: int = 8
	var max_start: int = max(0, reserve_heroes.size() - visible_rows)
	tab_scroll = clampi(tab_scroll, 0, max_start)
	for row in range(visible_rows):
		var idx: int = tab_scroll + row
		if idx >= reserve_heroes.size():
			break
		var hid: String = str(reserve_heroes[idx])
		var rr: Rect2 = Rect2(92, 345 + row * 34, 1084, 30)
		if idx == tab_index:
			draw_rect(rr, Color(0.30, 0.23, 0.10, 0.62), true)
		draw_text("• %s Lv.%d" % [heroes[hid]["name"], hero_bond_level(hid)], rr.position + Vector2(8, 21), 15, heroes[hid]["color"], true, HORIZONTAL_ALIGNMENT_LEFT, 180)
		draw_text(str(heroes[hid]["passive"]), rr.position + Vector2(195, 21), 14, Color8(198, 205, 196), false, HORIZONTAL_ALIGNMENT_LEFT, 860)

func draw_tab_equipment() -> void:
	draw_text("主角裝備", Vector2(92, 142), 23, Color8(235, 211, 153), true)
	var slots: Array[String] = ["weapon", "body", "treasure", "accessory", "jade"]
	var card_gap: float = 10.0
	var card_w: float = (1080.0 - card_gap * 4.0) / 5.0
	for i in range(slots.size()):
		var slot: String = slots[i]
		var rect: Rect2 = Rect2(92 + i * (card_w + card_gap), 160, card_w, 142)
		var unlocked: bool = equipment_slot_unlocked(slot)
		draw_panel(rect, Color(0.04, 0.045, 0.045, 0.96), Color8(137, 119, 82) if unlocked else Color8(78, 82, 78), 1.2)
		draw_text(equipment_slot_name(slot), rect.position + Vector2(12, 24), 16, Color8(210, 199, 169) if unlocked else Color8(135, 140, 135), true)
		if not unlocked:
			draw_centered_text("🔒", Rect2(rect.position, Vector2(rect.size.x, 74)), 56.0, 24, Color8(145, 150, 145))
			draw_wrapped(equipment_slot_lock_text(slot), Rect2(rect.position + Vector2(12, 82), Vector2(rect.size.x - 24, 42)), 12, Color8(145, 150, 145), 16.0)
			continue
		var eid: String = str(equipped.get(slot, ""))
		if eid == "":
			draw_centered_text("尚未裝備", rect, 84.0, 14, Color8(130, 137, 130))
		else:
			var edef: Dictionary = equipment_defs[eid]
			draw_texture_contain(equipment_tex[eid], Rect2(rect.position + Vector2(12, 39), Vector2(54, 54)))
			draw_text(str(edef["name"]), rect.position + Vector2(72, 58), 15, relic_rarity_color(str(edef.get("rarity", "common"))), true, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 82)
			draw_wrapped(str(edef["desc"]), Rect2(rect.position + Vector2(12, 96), Vector2(rect.size.x - 24, 36)), 11, Color8(194, 201, 193), 15.0)
	draw_text("行囊裝備（Enter／Space裝備）", Vector2(92, 335), 20, Color8(207, 196, 169), true)
	if equipment_inventory.is_empty():
		draw_text("尚未取得裝備。可從行商、事件或Boss戰利品獲得。", Vector2(100, 382), 17, Color8(170, 178, 170))
		return
	tab_index = clampi(tab_index, 0, equipment_inventory.size() - 1)
	var visible: int = 7
	var start_index: int = clampi(tab_index - 3, 0, max(0, equipment_inventory.size() - visible))
	for row in range(min(visible, equipment_inventory.size() - start_index)):
		var idx: int = start_index + row
		var eid: String = str(equipment_inventory[idx])
		var edef: Dictionary = equipment_defs[eid]
		var slot: String = str(edef.get("slot", "treasure"))
		var rect: Rect2 = Rect2(92, 352 + row * 39, 1080, 34)
		if idx == tab_index:
			draw_rect(rect, Color(0.32, 0.24, 0.10, 0.68), true)
		var mark: String = "【已裝備】" if str(equipped.get(slot, "")) == eid else ""
		var lock_mark: String = "【未開放】" if not equipment_slot_unlocked(slot) else ""
		draw_text("%s %s｜%s %s%s" % [("▶" if idx == tab_index else " "), equipment_slot_name(slot), edef["name"], mark, lock_mark], rect.position + Vector2(8, 23), 15, relic_rarity_color(str(edef.get("rarity", "common"))) if equipment_slot_unlocked(slot) else Color8(130, 136, 130), idx == tab_index, HORIZONTAL_ALIGNMENT_LEFT, 470)
		draw_text(str(edef["desc"]), rect.position + Vector2(490, 23), 14, Color8(195, 202, 194), false, HORIZONTAL_ALIGNMENT_LEFT, 570)


func relic_category(rid: String) -> String:
	var definition: Dictionary = relic_defs.get(rid, {})
	var tags: Array = definition.get("tags", []) as Array
	var tag_text: String = "、".join(tags)
	if tag_text.contains("毒") or tag_text.contains("雷") or tag_text.contains("燃燒") or tag_text.contains("異常"):
		return "異術"
	if tag_text.contains("治療") or tag_text.contains("護盾") or tag_text.contains("回復"):
		return "醫術"
	if tag_text.contains("標記") or tag_text.contains("穿透") or tag_text.contains("投射") or tag_text.contains("射程"):
		return "神射"
	if tag_text.contains("名將") or tag_text.contains("召喚") or tag_text.contains("羈絆") or tag_text.contains("冷卻"):
		return "軍略"
	if tag_text.contains("銅錢") or tag_text.contains("商店") or tag_text.contains("移動") or tag_text.contains("探索"):
		return "行旅"
	return "武力"


func relic_category_summary() -> String:
	var counts: Dictionary = {}
	for relic_value in relics:
		var category: String = relic_category(str(relic_value))
		counts[category] = int(counts.get(category, 0)) + 1
	var parts: Array[String] = []
	for category in ["武力", "神射", "軍略", "醫術", "異術", "行旅"]:
		if int(counts.get(category, 0)) > 0:
			parts.append("%s%d" % [category, int(counts[category])])
	return "　".join(parts) if not parts.is_empty() else "尚未形成遺物方向"


func draw_tab_relics() -> void:
	if relics.is_empty():
		draw_text("尚未取得遺物。", Vector2(100, 170), 22, Color8(192, 198, 190))
		return
	tab_index = clamp(tab_index, 0, relics.size() - 1)
	var visible_count: int = 8
	var start: int = clampi(
		tab_index - int(visible_count / 2), 0, max(0, relics.size() - visible_count)
	)
	var end: int = min(relics.size(), start + visible_count)
	var y: float = 145.0
	for i in range(start, end):
		var rid: String = str(relics[i])
		var row: int = i - start
		var r: Rect2 = Rect2(90, y + row * 52, 390, 44)
		if i == tab_index:
			draw_rect(r, Color(0.43, 0.30, 0.12, 0.84), true)
		draw_texture_contain(relic_tex[rid], Rect2(r.position + Vector2(5, 4), Vector2(36, 36)))
		draw_text(
			relic_defs[rid]["name"],
			r.position + Vector2(51, 29),
			18,
			Color8(234, 216, 174),
			i == tab_index
		)
	if relics.size() > visible_count:
		draw_text(
			"%d／%d" % [tab_index + 1, relics.size()],
			Vector2(402, 585),
			15,
			Color8(171, 180, 172),
			true
		)
	var selected: String = str(relics[tab_index])
	draw_panel(Rect2(520, 145, 630, 410), Color(0.045, 0.05, 0.05, 0.92), Color8(110, 104, 81), 1.5)
	draw_texture_contain(relic_tex[selected], Rect2(555, 185, 92, 92))
	draw_text("%s　Lv.%d" % [relic_defs[selected]["name"], relic_level(selected)], Vector2(680, 220), 29, Color8(240, 216, 157), true)
	draw_text("類型：%s" % relic_category(selected), Vector2(680, 248), 16, Color8(225, 185, 112), true)
	draw_text(
		"【%s】" % "】【".join(relic_defs[selected]["tags"]),
		Vector2(680, 274),
		17,
		Color8(154, 201, 184),
		true
	)
	draw_wrapped(
		relic_defs[selected]["desc"], Rect2(555, 322, 550, 100), 21, Color8(218, 222, 211), 31.0
	)
	var triggers: int = int(run_stats.get("relic_triggers", {}).get(selected, 0))
	draw_text("本局觸發：%d次" % triggers, Vector2(555, 465), 18, Color8(194, 200, 191))


func draw_tab_bonds() -> void:
	if active_bonds.is_empty():
		draw_text("目前沒有生效羈絆。調整主動／後備配置後可能形成新組合。", Vector2(100, 170), 20, Color8(197, 203, 195))
		return
	var y: float = 155.0
	for bid in active_bonds:
		var b: Dictionary = bond_defs[bid]
		draw_panel(
			Rect2(90, y, 1060, 100), Color(0.055, 0.06, 0.058, 0.94), Color8(194, 162, 91), 1.3
		)
		draw_text(b["name"], Vector2(115, y + 34), 24, Color8(239, 211, 145), true)
		draw_text(
			"成員：%s" % hero_names(b["members"]),
			Vector2(115, y + 61),
			16,
			Color8(180, 204, 188),
			true
		)
		draw_text(b["desc"], Vector2(115, y + 86), 16, Color8(210, 214, 204))
		y += 115.0


func draw_tab_summary() -> void:
	var build: String = build_summary()
	draw_text("目前戰術評估", Vector2(100, 160), 27, Color8(239, 213, 153), true)
	draw_wrapped(build, Rect2(100, 195, 1020, 210), 20, Color8(215, 220, 210), 31.0)
	var build_now: Dictionary = dominant_build()
	draw_text("戰術共鳴：%s｜%s（%d）" % [build_now["name"], build_resonance_stage_name(build_resonance_stage(int(build_now["score"]))), build_now["score"]], Vector2(100, 425), 19, build_now["color"], true)
	draw_text("主角專屬：%s" % PlayerUpgradeService.passive_name(chosen_identity), Vector2(100, 490), 17, Color8(176, 218, 188), true)
	draw_wrapped("專屬進化：%s" % PlayerUpgradeService.signature_summary(chosen_identity, skill_levels), Rect2(100, 514, 1020, 38), 15, Color8(205, 211, 202), 23.0)
	draw_wrapped(build_bonus_description(), Rect2(100, 446, 1020, 40), 15, Color8(196, 207, 193), 20.0)
	draw_text("遺物傾向：%s" % relic_category_summary(), Vector2(100, 566), 17, Color8(194, 207, 184), true)
	draw_text("戰績", Vector2(100, 596), 20, Color8(205, 193, 159), true)
	draw_text(
		(
			"擊敗 %d　造成傷害 %d　承受傷害 %d　箭矢命中 %d"
			% [
				run_stats.get("kills", 0),
				int(run_stats.get("damage_dealt", 0.0)),
				int(run_stats.get("damage_taken", 0.0)),
				run_stats.get("arrows_taken", 0)
			]
		),
		Vector2(100, 624),
		15,
		Color8(201, 207, 198)
	)


func build_summary() -> String:
	var tags: Array = []
	if (
		chosen_identity == "hunter"
		or active_heroes.has("taishici")
		or active_heroes.has("sunshangxiang")
	):
		tags.append("遠距穿透")
	if chosen_identity in ["poisoner", "strategist"] or reserve_heroes.has("zhangjiao") or has_relic("poisonbag"):
		tags.append("中毒傳播")
	if active_heroes.has("zhangfei") or active_heroes.has("huatuo"):
		tags.append("防守脫困")
	if active_heroes.has("guanyu") or active_heroes.has("lvlingqi"):
		tags.append("爆發清場")
	if active_heroes.has("diaochan") or active_heroes.has("zhenji"):
		tags.append("群體控制")
	if tags.is_empty():
		tags.append("基礎生存")
	var weak: String = "近身保護較少，請保留閃避。"
	if tags.has("防守脫困"):
		weak = "防守穩定，但需留意Boss單體爆發。"
	return (
		"核心方向：%s\n\n優勢：目前名將、技能與遺物已形成可辨識的戰鬥循環。\n弱點：%s\n\n提示：名將技能會自動施放，也可按1～%d手動施放；Tab畫面僅供查看，戰鬥中不可換將。"
		% ["／".join(tags), weak, active_limit()]
	)


func codex_item_name(item: Variant) -> String:
	match codex_page:
		0:
			var bid: String = str(item)
			return str(bond_defs[bid]["name"]) if save_data["unlocked_bonds"].has(bid) else "尚未發現"
		1:
			return str(heroes[str(item)]["name"])
		2:
			return str(equipment_defs[str(item)]["name"])
		3:
			return str(relic_defs[str(item)]["name"])
		_:
			return "%s・%s" % [str(item.get("year", "")), str(item.get("title", "未名章回"))]


func draw_codex_screen() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color8(24, 29, 29), true)
	draw_text("亂世圖鑑", Vector2(65, 66), 38, Color8(239, 213, 150), true)
	var pages: Array[String] = codex_pages()
	for i in range(pages.size()):
		var tr: Rect2 = Rect2(65 + i * 151, 86, 140, 38)
		if i == codex_page:
			draw_rect(tr, Color(0.46, 0.31, 0.12, 0.92), true)
		draw_text(pages[i], tr.position + Vector2(38, 26), 18, Color8(243, 220, 168) if i == codex_page else Color8(151, 157, 150), i == codex_page)
	var ids: Array = codex_ids()
	codex_index = clampi(codex_index, 0, maxi(0, ids.size() - 1))
	var visible_start: int = maxi(0, codex_index - 5)
	for row in range(mini(10, ids.size() - visible_start)):
		var idx: int = visible_start + row
		var r: Rect2 = Rect2(65, 145 + row * 48, 390, 40)
		if idx == codex_index:
			draw_rect(r, Color(0.43, 0.30, 0.12, 0.84), true)
		draw_text(("◆ " if idx == codex_index else "• ") + codex_item_name(ids[idx]), r.position + Vector2(12, 28), 18, Color8(237, 217, 172) if idx == codex_index else Color8(174, 181, 173), idx == codex_index)
	draw_panel(Rect2(495, 145, 710, 475), Color(0.045, 0.05, 0.05, 0.96), Color8(126, 116, 86), 1.5)
	if ids.is_empty():
		draw_text("尚無資料", Vector2(535, 205), 30, Color8(130, 136, 130), true)
	else:
		var item: Variant = ids[codex_index]
		match codex_page:
			0:
				var bid: String = str(item)
				var b: Dictionary = bond_defs[bid]
				var unlocked: bool = save_data["unlocked_bonds"].has(bid)
				draw_text(str(b["name"]) if unlocked else "？？？", Vector2(535, 205), 34, Color8(240, 215, 155) if unlocked else Color8(116, 122, 116), true)
				if unlocked:
					draw_text("成員：%s" % hero_names(b["members"]), Vector2(535, 245), 19, Color8(165, 205, 181), true)
					draw_wrapped(str(b["desc"]), Rect2(535, 280, 620, 150), 21, Color8(214, 220, 209), 31.0)
				else:
					draw_text("解鎖線索", Vector2(535, 255), 21, Color8(202, 182, 130), true)
					draw_wrapped(str(b["hint"]), Rect2(535, 290, 620, 120), 21, Color8(174, 181, 173), 31.0)
			1:
				var h: Dictionary = heroes[str(item)]
				draw_texture_rect(runtime_texture(str(h["portrait"])), Rect2(535, 180, 190, 250), false)
				draw_text("%s・%s" % [h["name"], h["title"]], Vector2(755, 215), 30, h["color"], true)
				draw_text("勢力：%s" % h["faction"], Vector2(755, 252), 18, Color8(180, 190, 180), true)
				draw_wrapped("主動｜%s\n\n後備｜%s\n\n相遇徵兆｜%s" % [h["active"], h["passive"], h["signal"]], Rect2(755, 285, 410, 280), 18, Color8(214, 220, 209), 27.0)
			2:
				var e: Dictionary = equipment_defs[str(item)]
				draw_text(str(e["name"]), Vector2(535, 205), 34, Color8(240, 215, 155), true)
				draw_text("部位：%s　稀有度：%s" % [str(e.get("slot", "-")), str(e.get("rarity", "common"))], Vector2(535, 245), 18, Color8(165, 205, 181), true)
				draw_wrapped(str(e["desc"]), Rect2(535, 285, 620, 130), 22, Color8(214, 220, 209), 32.0)
				if e.has("bosses"):
					draw_text("名將專屬戰利品", Vector2(535, 450), 19, Color8(226, 179, 105), true)
			3:
				var rdef: Dictionary = relic_defs[str(item)]
				draw_text(str(rdef["name"]), Vector2(535, 205), 34, Color8(240, 215, 155), true)
				draw_text("標籤：%s" % "／".join(rdef.get("tags", [])), Vector2(535, 245), 18, Color8(165, 205, 181), true)
				draw_wrapped(str(rdef["desc"]), Rect2(535, 285, 620, 160), 22, Color8(214, 220, 209), 32.0)
			_:
				var ch: Dictionary = item
				draw_text("%s　%s" % [ch["year"], ch["title"]], Vector2(535, 205), 34, Color8(240, 215, 155), true)
				draw_text("地點：%s" % ch["place"], Vector2(535, 245), 19, Color8(165, 205, 181), true)
				draw_wrapped(str(ch["intro"]), Rect2(535, 285, 620, 120), 21, Color8(214, 220, 209), 31.0)
				draw_text("章回目標", Vector2(535, 440), 20, Color8(226, 179, 105), true)
				draw_wrapped(str(ch["objective"]), Rect2(535, 470, 620, 90), 20, Color8(214, 220, 209), 29.0)
	draw_text("←→切換分類　↑↓瀏覽　Enter／Space／Esc返回", Vector2(65, 680), 17, Color8(181, 188, 181))


func draw_skins_screen() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color8(25, 30, 30), true)
	draw_text("武將造型", Vector2(65, 70), 39, Color8(239, 213, 150), true)
	var hlist: Array = skin_defs.keys()
	var hid: String = str(hlist[skin_hero_index])
	var skins: Array = skin_defs[hid]
	var skin: Dictionary = skins[skin_variant_index]
	draw_texture_rect(runtime_texture(str(skin["portrait"])), Rect2(95, 120, 405, 540), false)
	draw_text(heroes[hid]["name"], Vector2(560, 170), 42, heroes[hid]["color"], true)
	draw_text(skin["name"], Vector2(560, 220), 30, Color8(238, 218, 172), true)
	draw_text(skin["tag"], Vector2(560, 255), 18, Color8(164, 202, 181), true)
	draw_sprite_frame(
		runtime_texture(str(skin["sprite"])),
		Vector2(740, 390),
		4.0,
		int(Time.get_ticks_msec() / 180) % 4
	)
	for i in range(skins.size()):
		var r: Rect2 = Rect2(550, 500 + i * 55, 520, 44)
		if i == skin_variant_index:
			draw_rect(r, Color(0.46, 0.32, 0.13, 0.88), true)
		var selected: bool = (
			str(save_data["selected_skins"].get(hid, "default")) == str(skins[i]["id"])
		)
		draw_text(
			("✓ " if selected else "　") + skins[i]["name"],
			r.position + Vector2(15, 30),
			20,
			Color8(239, 222, 181),
			i == skin_variant_index
		)
	draw_text("←→切換武將　↑↓選擇造型　Enter／Space套用　Esc返回", Vector2(65, 688), 17, Color8(183, 190, 182))


func draw_settings_screen() -> void:
	draw_texture_rect(menu_bg, Rect2(Vector2.ZERO, VIEW), false)
	draw_screen_wash(0.54)
	var root: Rect2 = Rect2(105, 48, 1070, 620)
	draw_panel(root, Color(0.016, 0.022, 0.022, 0.97), Color8(175, 145, 82), 2.0)
	draw_section_header("設定", "調整聲音、演出與顯示方式；所有變更會獨立保存。", Rect2(145, 72, 990, 76))
	var st: Dictionary = save_data["settings"]
	var labels: Array[String] = [
		"背景音樂　%d%%" % int(float(st["bgm"]) * 100),
		"音效　　　%d%%" % int(float(st["sfx"]) * 100),
		"特效濃度　%d%%" % int(float(st.get("effects", 0.82)) * 100),
		"遊戲難度　%s" % difficulty_name(),
		"畫面震動　%s" % ("開" if st.get("shake", true) else "關"),
		"傷害數字　%s" % ("開" if st.get("damage_numbers", true) else "關"),
		"全螢幕　　%s" % ("開" if st["fullscreen"] else "關"),
		"返回主選單"
	]
	var left: Rect2 = Rect2(145, 168, 630, 424)
	draw_panel(left, Color(0.028, 0.034, 0.034, 0.88), Color8(91, 95, 85), 1.0)
	for i in range(labels.size()):
		var r: Rect2 = Rect2(168, 185 + i * 48, 584, 40)
		draw_action_button(r, ("▶ " if i == settings_index else "　") + labels[i], i == settings_index)
	var detail: Rect2 = Rect2(805, 168, 330, 424)
	draw_panel(detail, Color(0.026, 0.031, 0.03, 0.92), Color8(117, 105, 77), 1.2)
	draw_text("目前項目", detail.position + Vector2(22, 36), 19, Color8(225, 205, 158), true)
	draw_wrapped(labels[settings_index], Rect2(detail.position + Vector2(22, 60), Vector2(286, 55)), 21, Color8(238, 224, 190), 28.0, true)
	var difficulty_desc: String = "標準敵軍與Boss強度。"
	match difficulty_id():
		"easy":
			difficulty_desc = "敵人傷害與生命降低，經驗略多，適合體驗歷史與Build。"
		"hard":
			difficulty_desc = "敵軍與Boss更快、更痛，但經驗與遺物循環略有補償。"
	var desc: String = "使用方向鍵左右調整目前項目。"
	if settings_index == 3:
		desc = difficulty_desc
	elif settings_index == 4:
		desc = "關閉後仍保留必要受擊提示，適合容易暈眩的玩家。"
	elif settings_index == 5:
		desc = "關閉可降低後期戰場雜訊與文字生成負擔。"
	elif settings_index == 6:
		desc = "切換視窗與全螢幕顯示；設定會在重新啟動後保留。"
	draw_wrapped(desc, Rect2(detail.position + Vector2(22, 144), Vector2(286, 124)), 16, Color8(185, 196, 186), 24.0)
	draw_text("操作", detail.position + Vector2(22, 316), 17, Color8(214, 190, 137), true)
	draw_wrapped("↑↓ 選擇
←→ 調整
Enter／Space 切換", Rect2(detail.position + Vector2(22, 334), Vector2(270, 72)), 15, Color8(176, 187, 177), 23.0)
	draw_text("Esc返回", Vector2(145, 641), 14, Color8(178, 188, 179))


func finalize_campaign_ending() -> bool:
	if ending_committed:
		return true
	if not chapter_manager.can_finalize_campaign():
		push_error("Campaign ending requested before final boss defeat")
		return false
	ending_committed = true
	var definition: Dictionary = chapter_manager.boss_definition()
	var run_save: Dictionary = save_data.get("run_save", {}) as Dictionary
	var run_id: String = str(run_save.get("run_id", ""))
	if run_id.is_empty():
		run_id = "%s:%s:%s" % [chosen_mode, chosen_identity, str(run_save.get("saved_at", save_data.get("last_saved_at", "unknown")))]
	var context: Dictionary = {
		"run_id": run_id,
		"mode": chosen_mode,
		"difficulty": difficulty_id(),
		"chapter_id": chapter_manager.current_id(),
		"chapter_title": chapter_manager.current_title(),
		"boss_id": str(definition.get("id", "")),
		"identity": chosen_identity,
		"elapsed": elapsed,
		"stats": run_stats.duplicate(true),
		"active_heroes": active_heroes.duplicate(),
		"reserve_heroes": reserve_heroes.duplicate(),
		"active_bonds": active_bonds.duplicate(),
		"relics": relics.duplicate(),
		"equipment": equipped.duplicate(true),
		"completed_chapters": chapter_manager.completed_ids(),
		"history_log": history_log.duplicate(),
		"route_tags": history_route_tags.duplicate(true),
		"faction_momentum": faction_momentum.duplicate(true),
		"rewrite_rate": history_rewrite_rate
	}
	var validation_errors: Array[String] = ending_manager.validate_context(context)
	if not validation_errors.is_empty():
		ending_committed = false
		push_error("Ending context rejected: %s" % "; ".join(validation_errors))
		return false
	ending_snapshot = ending_manager.build_snapshot(context)
	var previous_save_data: Dictionary = save_data.duplicate(true)
	if not (save_data.get("endings", {}) is Dictionary):
		save_data["endings"] = {}
	var ending_id: String = str(ending_snapshot.get("ending_id", "historical_witness"))
	(save_data["endings"] as Dictionary)[ending_id] = ending_snapshot.duplicate(true)
	save_data["latest_ending"] = ending_snapshot.duplicate(true)
	save_data["run_save"] = {}
	if not save_game_meta():
		save_data = previous_save_data
		ending_committed = false
		ending_snapshot["historian_comment"] = str(ending_snapshot.get("historian_comment", "")) + "（結局紀錄寫入失敗；章間進度仍保留。）"
		screen = "ending"
		option_index = 0
		return false
	if not chapter_manager.finalize_campaign():
		push_error("Ending saved but chapter manager could not finalize campaign")
	game_over_reason = "擊敗%s，亂世旅程寫下最終一頁。" % str(definition.get("name", "最終敵將"))
	pending_boss_loot.clear()
	chapter_reward_relic = ""
	option_index = 0
	screen = "ending"
	play_bgm("victory", 1.2)
	play_sfx("equipment_drop", 0.85)
	return true

func ending_hero_names(ids: Variant) -> String:
	var names: Array[String] = []
	if ids is Array:
		for value in ids:
			var hid: String = str(value)
			names.append(str(heroes.get(hid, {}).get("name", hid)))
	return "、".join(names) if not names.is_empty() else "無"


func ending_equipment_summary(snapshot: Dictionary = ending_snapshot) -> String:
	var parts: Array[String] = []
	var equipment: Dictionary = snapshot.get("equipment", {}) as Dictionary
	for slot in ["weapon", "body", "treasure", "accessory", "jade"]:
		var eid: String = str(equipment.get(slot, ""))
		if eid != "" and equipment_defs.has(eid):
			parts.append(str(equipment_defs[eid].get("name", eid)))
	return "、".join(parts) if not parts.is_empty() else "未裝備"


func draw_ending_screen() -> void:
	EndingUIScript.draw(self, ending_snapshot)


func draw_ending() -> void:
	draw_ending_screen()


func handle_ending_key(key: int) -> void:
	if is_confirm_key(key) or key == KEY_ESCAPE:
		option_index = 0
		handle_victory_option(0)


func draw_boss_loot_screen() -> void:
	BossLootUIScript.draw(self, pending_boss_loot)

func draw_result_screen() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color8(27, 30, 29), true)
	var victory: bool = screen == "victory"
	var root: Rect2 = Rect2(175, 52, 930, 616)
	draw_panel(root, Color(0.035, 0.04, 0.039, 0.985), Color8(190, 151, 81) if victory else Color8(157, 74, 61), 2.2)
	draw_centered_text("章回告捷" if victory else "亂世夢斷", Rect2(root.position.x + 40, root.position.y + 22, root.size.x - 80, 62), 48.0, 43, Color8(237, 205, 132) if victory else Color8(209, 98, 76), true)
	draw_wrapped(game_over_reason, Rect2(255, 128, 770, 58), 18, Color8(222, 220, 204), 26.0, true)
	var stats_rect: Rect2 = Rect2(225, 205, 510, 280)
	var reward_rect: Rect2 = Rect2(760, 205, 295, 280)
	draw_panel(stats_rect, Color(0.05, 0.055, 0.053, 0.95), Color8(126, 111, 75), 1.3)
	draw_panel(reward_rect, Color(0.05, 0.055, 0.053, 0.95), Color8(126, 111, 75), 1.3)
	var stat_lines: Array[String] = [
		"章節　%s" % chapter_manager.current_title(),
		"存活　%02d:%02d" % [int(elapsed / 60.0), int(elapsed) % 60],
		"擊敗敵軍　%d" % run_stats.get("kills", 0),
		"造成傷害　%d" % int(run_stats.get("damage_dealt", 0.0)),
		"承受傷害　%d" % int(run_stats.get("damage_taken", 0.0)),
		"生效羈絆　%s" % ("、".join(bond_names(active_bonds)) if not active_bonds.is_empty() else "無")
	]
	for i in range(stat_lines.size()):
		draw_text(stat_lines[i], stats_rect.position + Vector2(28, 42 + i * 39), 17 if i > 0 else 19, Color8(233, 215, 173) if i == 0 else Color8(204, 210, 201), i == 0, HORIZONTAL_ALIGNMENT_LEFT, stats_rect.size.x - 56)
	draw_text("本章收穫", reward_rect.position + Vector2(24, 37), 21, Color8(233, 215, 173), true)
	if victory and chapter_reward_relic != "" and relic_defs.has(chapter_reward_relic):
		draw_texture_contain(relic_tex[chapter_reward_relic], Rect2(reward_rect.position + Vector2(87, 58), Vector2(120, 120)))
		draw_centered_text("%s　Lv.%d" % [str(relic_defs[chapter_reward_relic]["name"]), relic_level(chapter_reward_relic)], Rect2(reward_rect.position + Vector2(18, 186), Vector2(reward_rect.size.x - 36, 38)), 27.0, 20, Color8(239, 214, 155), true)
		draw_wrapped(str(relic_defs[chapter_reward_relic].get("desc", "")), Rect2(reward_rect.position + Vector2(24, 224), Vector2(reward_rect.size.x - 48, 42)), 12, Color8(190, 198, 190), 17.0, true)
	else:
		draw_centered_text("整軍再戰", reward_rect, 145.0, 19, Color8(170, 178, 170))
	var options: Array[String] = result_options()
	var button_w: float = 260.0 if options.size() <= 2 else 220.0
	var gap: float = 24.0
	var total_w: float = button_w * float(options.size()) + gap * float(options.size() - 1)
	var start_x: float = 640.0 - total_w * 0.5
	for i in range(options.size()):
		var rect: Rect2 = Rect2(start_x + i * (button_w + gap), 525, button_w, 56)
		draw_panel(rect, Color(0.49, 0.34, 0.13, 0.92) if i == option_index else Color(0.055, 0.06, 0.057, 0.94), Color8(231, 194, 108) if i == option_index else Color8(108, 101, 77), 1.8 if i == option_index else 1.0)
		draw_centered_text(options[i], rect.grow(-4.0), 37.0, 19, Color8(239, 224, 188), i == option_index)
	if victory and chapter_manager.has_next_chapter():
		var next: Dictionary = chapter_manager.next_chapter()
		draw_text("下一章：%s・%s｜內容已可進入" % [str(next.get("title", "")), str(next.get("place", ""))], Vector2(640, 626), 15, Color8(183, 190, 182), false, HORIZONTAL_ALIGNMENT_CENTER, 820)
	else:
		draw_text("方向鍵選擇　Enter／Space確認", Vector2(640, 626), 15, Color8(183, 190, 182), false, HORIZONTAL_ALIGNMENT_CENTER, 820)

func draw_intermission_screen() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color8(24, 29, 29), true)
	var previous: Dictionary = chapter_manager.current()
	var next: Dictionary = chapter_manager.next_chapter()

	# V2.0 alpha.9：所有章間元素都由同一個安全區推導，避免標題、面板與按鈕各用不同中心。
	var safe_margin_x: float = 60.0
	var safe_rect := Rect2(safe_margin_x, 36.0, VIEW.x - safe_margin_x * 2.0, VIEW.y - 72.0)
	var header_rect := Rect2(safe_rect.position.x, 42.0, safe_rect.size.x, 64.0)
	var panel_gap: float = 24.0
	var panel_width: float = (safe_rect.size.x - panel_gap) * 0.5
	var panel_y: float = 120.0
	var panel_h: float = 430.0
	var left_rect := Rect2(safe_rect.position.x, panel_y, panel_width, panel_h)
	var right_rect := Rect2(safe_rect.position.x + panel_width + panel_gap, panel_y, panel_width, panel_h)

	draw_centered_text("史勢演變", header_rect, 46.0, 44, Color8(238, 207, 139), true)

	draw_panel(left_rect, Color(0.045, 0.052, 0.052, 0.96), Color8(116, 105, 77), 1.5)
	draw_text("上一章結果", left_rect.position + Vector2(30, 43), 25, Color8(226, 205, 156), true)
	draw_text(
		"%s・%s" % [str(previous.get("title", "")), str(previous.get("place", ""))],
		left_rect.position + Vector2(30, 83),
		22,
		Color8(239, 224, 188),
		true
	)
	draw_wrapped(game_over_reason, Rect2(left_rect.position + Vector2(30, 108), Vector2(panel_width - 60, 82)), 18, Color8(205, 211, 202), 27.0)
	draw_text("保留內容", left_rect.position + Vector2(30, 215), 21, Color8(226, 205, 156), true)
	draw_wrapped(
		(
			"主動：%s\n後備：%s\n裝備：%d件　遺物：%d件\n技能：%d項　銅錢：%d"
			% [
				hero_names(active_heroes),
				hero_names(reserve_heroes),
				equipment_inventory.size(),
				relics.size(),
				skill_levels.size(),
				int(player.get("coins", 0))
			]
		),
		Rect2(left_rect.position + Vector2(30, 240), Vector2(panel_width - 60, 108)),
		17,
		Color8(201, 208, 200),
		27.0
	)
	if not history_log.is_empty():
		draw_text("本局史勢", left_rect.position + Vector2(30, 350), 18, Color8(226, 205, 156), true)
		draw_wrapped(history_log[-1], Rect2(left_rect.position + Vector2(30, 369), Vector2(panel_width - 60, 38)), 14, Color8(196, 203, 195), 20.0)
	draw_text(history_route_summary(), left_rect.position + Vector2(30, 420), 16, Color8(236, 190, 104), true)
	draw_text(
		"蜀%d　魏%d　吳%d　群%d" % [int(faction_momentum.get("蜀", 0)), int(faction_momentum.get("魏", 0)), int(faction_momentum.get("吳", 0)), int(faction_momentum.get("群", 0))],
		left_rect.position + Vector2(30, 447), 14, Color8(171, 188, 181)
	)

	draw_panel(right_rect, Color(0.05, 0.052, 0.048, 0.96), Color8(164, 132, 72), 1.5)
	draw_text("下一章", right_rect.position + Vector2(30, 43), 25, Color8(232, 204, 139), true)
	draw_text(
		"%s｜%s" % [str(next.get("title", "尚無後續章節")), str(next.get("place", ""))],
		right_rect.position + Vector2(30, 88),
		29,
		Color8(242, 224, 181),
		true
	)
	draw_text(str(next.get("year", "")), right_rect.position + Vector2(30, 121), 17, Color8(174, 184, 177))
	draw_wrapped(
		str(next.get("intro", "")), Rect2(right_rect.position + Vector2(30, 150), Vector2(panel_width - 60, 118)), 19, Color8(207, 213, 204), 29.0
	)
	draw_text(
		"主戰上限：%d位　後備上限：%d位" % [int(next.get("active_limit", 2)), reserve_limit()],
		right_rect.position + Vector2(30, 298),
		19,
		Color8(209, 185, 128),
		true
	)
	draw_wrapped(
		"名將與主角裝備皆可在此調整；進入下一章後，遺物、名將、技能、裝備與銅錢將繼續保留。",
		Rect2(right_rect.position + Vector2(30, 331), Vector2(panel_width - 60, 52)),
		16,
		Color8(197, 202, 195),
		23.0
	)
	var save_summary: Dictionary = checkpoint_summary()
	var saved_line: String = "尚未建立章節存檔"
	if not save_summary.is_empty():
		saved_line = "最後存檔：%s" % str(save_summary.get("saved_at", ""))
	draw_text(saved_line, right_rect.position + Vector2(30, 401), 14, Color8(145, 199, 154), true, HORIZONTAL_ALIGNMENT_LEFT, panel_width - 60)

	var options: Array[String] = intermission_options()
	option_index = clampi(option_index, 0, max(0, options.size() - 1))
	var footer_rect := Rect2(safe_rect.position.x, 575.0, safe_rect.size.x, 58.0)
	var button_gap: float = 12.0
	var button_width: float = (footer_rect.size.x - button_gap * float(options.size() - 1)) / float(options.size())
	for i in range(options.size()):
		var rect: Rect2 = Rect2(footer_rect.position.x + i * (button_width + button_gap), footer_rect.position.y, button_width, footer_rect.size.y)
		var selected: bool = i == option_index
		draw_panel(
			rect,
			Color(0.49, 0.34, 0.13, 0.92) if selected else Color(0.055, 0.06, 0.058, 0.96),
			Color8(210, 169, 89) if selected else Color8(104, 99, 82),
			1.5
		)
		draw_centered_text(
			options[i],
			rect.grow(-4.0),
			39.0,
			20,
			Color8(247, 231, 192) if selected else Color8(207, 207, 196),
			selected
		)

	var hint_rect := Rect2(safe_rect.position.x, 648.0, safe_rect.size.x, 34.0)
	draw_centered_text("← →／A D 切換　Enter／Space確認", hint_rect, 23.0, 15, Color8(183, 190, 182), false)


func hero_names(ids: Array) -> String:
	var names: Array = []
	for hid in ids:
		if heroes.has(hid):
			names.append(heroes[hid]["name"])
	return "、".join(names)


func bond_names(ids: Array) -> Array:
	var names: Array = []
	for bid in ids:
		if bond_defs.has(bid):
			names.append(bond_defs[bid]["name"])
	return names


# Alpha.19: Build、名將大成、史勢與章節特色整合層。
func alpha19_initialize_run() -> void:
	alpha19_build_state = Alpha19BuildRules.evaluate(chosen_identity, str(player.get("weapon", "blade")), skill_levels, relics)
	alpha19_mastery_state.clear()
	alpha19_history_state = Alpha19HistoryInfluence.evaluate(history_flags, history_route_tags, faction_momentum, history_rewrite_rate)
	alpha19_chapter_state = Alpha19ChapterGimmicks.for_chapter(str(current_chapter().get("id", "")))
	alpha19_refresh_timer = 0.0
	player["alpha19_damage_mult"] = 1.0
	alpha19_refresh_progression()
	alpha20_initialize_run()


func alpha19_update(delta: float) -> void:
	if player.is_empty() or screen not in ["game", "shop", "tab", "hero_config", "camp_menu"]:
		return
	alpha19_refresh_timer -= delta
	if alpha19_refresh_timer > 0.0:
		return
	alpha19_refresh_timer = 0.35
	alpha19_refresh_progression()


func alpha19_refresh_progression() -> void:
	alpha19_build_state = Alpha19BuildRules.evaluate(chosen_identity, str(player.get("weapon", "blade")), skill_levels, relics)
	alpha19_mastery_state = Alpha19HeroMastery.evaluate(active_heroes, reserve_heroes, hero_bond_levels)
	alpha19_history_state = Alpha19HistoryInfluence.evaluate(history_flags, history_route_tags, faction_momentum, history_rewrite_rate)
	var build_damage: float = float(alpha19_build_state.get("damage_mult", 1.0))
	var mastery_damage: float = float(alpha19_mastery_state.get("damage_mult", 1.0))
	var history_damage: float = float(alpha19_history_state.get("damage_mult", 1.0))
	player["alpha19_damage_mult"] = build_damage * mastery_damage * history_damage
	player["hero_cd_mult"] = clamp(
		float(alpha19_build_state.get("hero_cd_mult", 1.0))
		* float(alpha19_mastery_state.get("hero_cd_mult", 1.0)),
		0.55,
		1.0
	)
	player["control_resist"] = max(float(player.get("control_resist", 0.0)), float(alpha19_mastery_state.get("control_resist", 0.0)))


func alpha19_filter_level_choices() -> void:
	if level_choices.is_empty():
		return
	var filtered: Array = []
	for choice_value in level_choices:
		var skill_id: String = ""
		if choice_value is Dictionary:
			var choice: Dictionary = choice_value
			skill_id = str(choice.get("id", choice.get("skill", "")))
		elif choice_value is String or choice_value is StringName:
			skill_id = str(choice_value)
		else:
			# 未知格式不應讓升級畫面當機；保留選項交由原流程處理。
			filtered.append(choice_value)
			continue
		if Alpha19BuildRules.skill_allowed(str(player.get("weapon", "blade")), skill_id, skill_levels):
			filtered.append(choice_value)
	if filtered.size() >= 2:
		level_choices = filtered
	option_index = clampi(option_index, 0, max(0, level_choices.size() - 1))
	Alpha36RosterProgressionHud.diversify_level_choices(self)


func alpha19_apply_chapter_setup() -> void:
	alpha19_history_state = Alpha19HistoryInfluence.evaluate(history_flags, history_route_tags, faction_momentum, history_rewrite_rate)
	alpha19_chapter_state = Alpha19ChapterGimmicks.for_chapter(str(current_chapter().get("id", "")))
	merchant_spawn_timer *= float(alpha19_chapter_state.get("merchant_time_mult", 1.0))
	hero_spawn_timer *= float(alpha19_chapter_state.get("hero_time_mult", 1.0))
	var history_merchant: float = float(alpha19_history_state.get("merchant_time_mult", 1.0))
	merchant_spawn_timer *= history_merchant
	var label: String = str(alpha19_chapter_state.get("label", ""))
	if label != "":
		show_message("章節機制｜%s" % label, 3.2)
	alpha20_prepare_chapter()


func alpha19_build_summary() -> String:
	return "%s・%s" % [
		str(alpha19_build_state.get("name", "未定流派")),
		str(alpha19_build_state.get("stage_name", "起步"))
	]


# Alpha.20: 關卡導演、章節挑戰與 Steam Demo 精修層。
func alpha20_initialize_run() -> void:
	alpha20_demo_state = Alpha20DemoProfile.new_run(chosen_mode, chosen_identity)
	alpha20_director_state.clear()
	alpha20_challenge_state.clear()
	alpha20_tick_timer = 0.0
	alpha20_hazard_timer = 0.0
	alpha20_last_kills = int(run_stats.get("kills", 0))
	alpha20_prepare_chapter()
	alpha21_initialize_run()


func alpha20_prepare_chapter() -> void:
	if chapter_manager == null:
		return
	var chapter_id: String = str(current_chapter().get("id", ""))
	alpha20_director_state = Alpha20DemoDirector.profile(chapter_id, chosen_mode)
	alpha20_challenge_state = Alpha20ChallengeTracker.start_chapter(chapter_id, alpha20_director_state)
	alpha20_hazard_timer = float(alpha20_director_state.get("hazard_interval", 24.0))
	alpha20_last_kills = int(run_stats.get("kills", 0))
	spawn_timer *= float(alpha20_director_state.get("opening_spawn_mult", 1.0))
	merchant_spawn_timer *= float(alpha20_director_state.get("merchant_mult", 1.0))
	hero_spawn_timer *= float(alpha20_director_state.get("hero_mult", 1.0))
	var title: String = str(alpha20_director_state.get("title", ""))
	var objective: String = str(alpha20_challenge_state.get("label", ""))
	if title != "":
		show_message("Alpha.20戰場｜%s\n挑戰：%s" % [title, objective], 4.2)


func alpha20_update(delta: float) -> void:
	if player.is_empty() or screen != "game":
		return
	alpha20_tick_timer -= delta
	alpha20_hazard_timer -= delta
	if alpha20_tick_timer <= 0.0:
		alpha20_tick_timer = 0.25
		alpha20_update_challenge()
		alpha20_apply_adaptive_pressure()
	if alpha20_hazard_timer <= 0.0:
		alpha20_hazard_timer = Alpha20DemoDirector.next_hazard_interval(alpha20_director_state, performance_level)
		alpha20_trigger_hazard()


func alpha20_update_challenge() -> void:
	if alpha20_challenge_state.is_empty():
		return
	var current_kills: int = int(run_stats.get("kills", 0))
	var gained_kills: int = max(0, current_kills - alpha20_last_kills)
	alpha20_last_kills = current_kills
	var hp_ratio: float = float(player.get("hp", 0.0)) / max(1.0, float(player.get("max_hp", 1.0)))
	alpha20_challenge_state = Alpha20ChallengeTracker.update(
		alpha20_challenge_state,
		delta_for_alpha20_tick(),
		gained_kills,
		hp_ratio,
		boss_spawned
	)
	if bool(alpha20_challenge_state.get("just_completed", false)):
		alpha20_challenge_state["just_completed"] = false
		var reward: int = int(alpha20_challenge_state.get("reward_coins", 0))
		player["coins"] = int(player.get("coins", 0)) + reward
		player["shield"] = min(float(player.get("max_hp", 1.0)) * 0.35, float(player.get("shield", 0.0)) + float(reward) * 0.45)
		show_message("章節挑戰完成！獲得%d銅錢與護盾。" % reward, 3.4)
		play_sfx("levelup", 1.08)


func delta_for_alpha20_tick() -> float:
	return 0.25


func alpha20_apply_adaptive_pressure() -> void:
	if alpha20_director_state.is_empty():
		return
	var hp_ratio: float = float(player.get("hp", 0.0)) / max(1.0, float(player.get("max_hp", 1.0)))
	var pressure: Dictionary = Alpha20DemoDirector.adaptive_pressure(alpha20_director_state, hp_ratio, performance_level, elapsed)
	player["alpha20_damage_mult"] = float(pressure.get("player_damage_mult", 1.0))
	if bool(pressure.get("force_wave", false)):
		spawn_timer = min(spawn_timer, 0.08)


func alpha20_trigger_hazard() -> void:
	if alpha20_director_state.is_empty() or boss_spawned:
		return
	var hazard: Dictionary = Alpha20DemoDirector.pick_hazard(alpha20_director_state, rng.randi())
	var hazard_id: String = str(hazard.get("id", "pressure_wave"))
	match hazard_id:
		"arrow_rain":
			spawn_timer = min(spawn_timer, 0.05)
			screen_shake = max(screen_shake, 4.5)
		"fire_wind":
			temporary_speed = max(temporary_speed, 2.5)
			player["shield"] = max(0.0, float(player.get("shield", 0.0)) - 4.0)
		"cavalry_charge":
			spawn_timer = min(spawn_timer, -0.18)
			screen_shake = max(screen_shake, 6.0)
		"fog_of_war":
			temporary_attack_speed = min(temporary_attack_speed, -0.12)
		"supply_window":
			player["coins"] = int(player.get("coins", 0)) + 12
			player["shield"] = float(player.get("shield", 0.0)) + 8.0
		_:
			spawn_timer = min(spawn_timer, 0.12)
	var label: String = str(hazard.get("label", "敵軍壓境"))
	show_message("戰場變化｜%s" % label, 2.8)
	play_sfx("boss_warning", 0.78)


func alpha20_demo_summary() -> String:
	return Alpha20DemoProfile.summary(alpha20_demo_state, alpha20_challenge_state, alpha20_director_state)


# Alpha.21：主角戰鬥辨識、名將招牌技與 Boss 階段資料。
func alpha21_initialize_run() -> void:
	alpha21_identity_state = Alpha21CombatIdentity.profile(chosen_identity)
	alpha21_boss_sequence = 0
	alpha21_boss_phase = 1
	alpha22_initialize_profile()
	alpha23_initialize_story()
	var crit_bonus: float = Alpha21CombatIdentity.crit_bonus(chosen_identity)
	player["alpha21_crit_bonus"] = crit_bonus
	player["alpha21_dash_cd_mult"] = Alpha21CombatIdentity.dash_cooldown_multiplier(chosen_identity)
	show_message("Alpha.21武魂｜%s" % Alpha21CombatIdentity.summary(chosen_identity), 4.0)


func alpha21_identity_damage_multiplier() -> float:
	return Alpha21CombatIdentity.base_damage_multiplier(chosen_identity) * alpha22_legacy_damage_multiplier()


func alpha21_contextual_damage_multiplier(distance: float, is_dot: bool = false, is_return_hit: bool = false) -> float:
	return Alpha21CombatIdentity.contextual_damage_multiplier(chosen_identity, distance, is_dot, is_return_hit)


func alpha21_hero_signature(hero_id: String) -> Dictionary:
	return Alpha21HeroSignatures.signature(hero_id)


func alpha21_hero_cast_label(hero_id: String) -> String:
	return Alpha21HeroSignatures.cast_label(hero_id, int(hero_levels.get(hero_id, 1)))


func alpha21_boss_next_move() -> String:
	if boss.is_empty():
		return ""
	var boss_id: String = str(boss.get("id", boss.get("key", "")))
	var hp_ratio: float = float(boss.get("hp", 0.0)) / max(1.0, float(boss.get("max_hp", 1.0)))
	alpha21_boss_phase = Alpha21BossPatterns.phase_for_hp(boss_id, hp_ratio)
	var move_id: String = Alpha21BossPatterns.next_move(boss_id, alpha21_boss_sequence, hp_ratio)
	alpha21_boss_sequence += 1
	return move_id


func alpha21_boss_weakness_window(interrupted: bool = false) -> float:
	if boss.is_empty():
		return 0.0
	var boss_id: String = str(boss.get("id", boss.get("key", "")))
	return Alpha21BossPatterns.weakness_window(boss_id, interrupted)


# Alpha.22：局外傳承、圖鑑、成就與永久解鎖。
func alpha22_initialize_profile() -> void:
	alpha22_meta_state = Alpha22MetaProgression.normalize(save_data.get("meta_progression", {}))
	alpha22_codex_state = Alpha22Codex.normalize(save_data.get("codex", {}))
	var achievements_raw: Variant = save_data.get("achievements", {})
	alpha22_achievement_state = achievements_raw.duplicate(true) if achievements_raw is Dictionary else {}
	alpha22_last_rewards.clear()
	alpha22_apply_starting_bonuses()


func alpha22_apply_starting_bonuses() -> void:
	if player.is_empty():
		return
	var vitality: float = Alpha22MetaProgression.modifier(alpha22_meta_state, "vitality")
	var fortune: float = Alpha22MetaProgression.modifier(alpha22_meta_state, "fortune")
	var max_hp: float = float(player.get("max_hp", 1.0)) * (1.0 + vitality)
	player["max_hp"] = max_hp
	player["hp"] = min(max_hp, float(player.get("hp", max_hp)) * (1.0 + vitality))
	player["alpha22_coin_bonus"] = fortune
	player["alpha22_insight_bonus"] = Alpha22MetaProgression.modifier(alpha22_meta_state, "insight")


func alpha22_legacy_damage_multiplier() -> float:
	return 1.0 + Alpha22MetaProgression.modifier(alpha22_meta_state, "resolve")


func alpha22_record_run_result(result: Dictionary) -> Dictionary:
	alpha22_meta_state = Alpha22MetaProgression.award_for_run(alpha22_meta_state, result)
	var completion: Dictionary = Alpha22Codex.completion(alpha22_codex_state, alpha22_codex_totals())
	var metrics: Dictionary = {
		"runs": int(alpha22_meta_state.get("lifetime_runs", 0)),
		"kills": int(alpha22_meta_state.get("lifetime_kills", 0)),
		"bosses": int(alpha22_meta_state.get("lifetime_bosses", 0)),
		"chapter": int(alpha22_meta_state.get("best_chapter", 0)),
		"codex_percent": int(round(float(completion.get("ratio", 0.0)) * 100.0)),
	}
	alpha22_achievement_state = Alpha22Achievements.evaluate(alpha22_achievement_state, metrics)
	var reward: int = int(alpha22_achievement_state.get("reward_total", 0))
	if reward > 0:
		alpha22_meta_state["legacy_points"] = int(alpha22_meta_state.get("legacy_points", 0)) + reward
	alpha22_last_rewards = alpha22_achievement_state.get("newly_unlocked", []).duplicate()
	alpha22_achievement_state["reward_total"] = 0
	alpha22_achievement_state["newly_unlocked"] = []
	alpha22_commit_profile()
	return {"legacy_earned":int(alpha22_meta_state.get("last_earned", 0)), "achievements":alpha22_last_rewards.duplicate()}


func alpha22_discover(category: String, id: String, details: Dictionary = {}) -> void:
	alpha22_codex_state = Alpha22Codex.discover(alpha22_codex_state, category, id, details)
	alpha22_commit_profile()


func alpha22_purchase_upgrade(id: String) -> bool:
	var before: int = int(alpha22_meta_state.get("upgrades", {}).get(id, 0))
	alpha22_meta_state = Alpha22MetaProgression.purchase(alpha22_meta_state, id)
	var after: int = int(alpha22_meta_state.get("upgrades", {}).get(id, 0))
	if after > before:
		alpha22_commit_profile()
		return true
	return false


func alpha22_commit_profile() -> void:
	save_data["meta_progression"] = alpha22_meta_state.duplicate(true)
	save_data["codex"] = alpha22_codex_state.duplicate(true)
	save_data["achievements"] = alpha22_achievement_state.duplicate(true)


func alpha22_codex_totals() -> Dictionary:
	return {
		"heroes": heroes.size(),
		"bosses": 6,
		"relics": relic_defs.size(),
		"endings": 8,
	}


func alpha22_menu_entries() -> Array[String]:
	return ["傳承", "圖鑑", "成就"]


func alpha22_summary() -> String:
	var completion: Dictionary = Alpha22Codex.completion(alpha22_codex_state, alpha22_codex_totals())
	return "傳承點%d｜圖鑑%d/%d｜成就%d/%d" % [
		int(alpha22_meta_state.get("legacy_points", 0)),
		int(completion.get("found", 0)),
		int(completion.get("total", 0)),
		alpha22_achievement_state.get("unlocked", {}).size(),
		Alpha22Achievements.DEFINITIONS.size(),
	]


# Alpha.23：章節故事、歷史路線、關卡變體與多結局。
func alpha23_initialize_story() -> void:
	alpha24_initialize_demo()
	var raw: Variant = save_data.get("story_routes", {})
	alpha23_route_state = raw.duplicate(true) if raw is Dictionary and not raw.is_empty() else Alpha23RouteResolver.new_state()
	alpha23_story_scene.clear()
	alpha23_chapter_variant.clear()
	alpha23_pending_ending.clear()


func alpha23_apply_history_choice(choice_id: String, effects: Dictionary) -> Dictionary:
	alpha23_route_state = Alpha23RouteResolver.apply_choice(alpha23_route_state, choice_id, effects)
	save_data["story_routes"] = alpha23_route_state.duplicate(true)
	return alpha23_route_state.duplicate(true)


func alpha23_prepare_chapter_story(phase: String = "opening") -> Dictionary:
	var chapter_id: String = ""
	if chapter_manager != null:
		chapter_id = str(current_chapter().get("id", ""))
	alpha23_story_scene = Alpha23StoryDirector.chapter_scene(chapter_id, phase, alpha23_route_state)
	alpha23_chapter_variant = Alpha23RouteResolver.chapter_variant(chapter_id, alpha23_route_state)
	return alpha23_story_scene.duplicate(true)


func alpha23_current_chapter_variant() -> Dictionary:
	if alpha23_chapter_variant.is_empty():
		alpha23_prepare_chapter_story("opening")
	return alpha23_chapter_variant.duplicate(true)


func alpha23_resolve_ending(run_summary: Dictionary) -> Dictionary:
	alpha23_pending_ending = Alpha23EndingRoutes.resolve(alpha23_route_state, run_summary)
	var ending_id: String = str(alpha23_pending_ending.get("id", ""))
	if ending_id != "":
		alpha22_discover("endings", ending_id, {
			"name": str(alpha23_pending_ending.get("title", ending_id)),
			"route": str(alpha23_pending_ending.get("route", "balanced"))
		})
	return alpha23_pending_ending.duplicate(true)


func alpha23_route_summary() -> String:
	var dominant: String = str(alpha23_route_state.get("dominant", "balanced"))
	var variant_label: String = str(alpha23_chapter_variant.get("label", "史勢未定"))
	return "%s｜%s" % [Alpha23RouteResolver.ending_route_label(dominant), variant_label]


# Alpha.24：Steam Demo 封版、教學、效能降載與完成提示。
func alpha24_initialize_demo() -> void:
	var stored: Variant = save_data.get("alpha24_demo", {})
	alpha24_demo_state = Alpha24SteamDemo.normalize(stored)
	alpha24_quality_profile = Alpha24SteamDemo.quality_profile(str(alpha24_demo_state.get("quality", "high")))
	alpha24_frame_sample_timer = 0.0


func alpha24_tutorial_event(event_id: String, amount: float = 1.0) -> void:
	var before: int = int(alpha24_demo_state.get("tutorial_index", 0))
	alpha24_demo_state = Alpha24SteamDemo.advance_tutorial(alpha24_demo_state, event_id, amount)
	var after: int = int(alpha24_demo_state.get("tutorial_index", 0))
	if after > before:
		var next_step: Dictionary = Alpha24SteamDemo.current_tutorial(alpha24_demo_state)
		if next_step.is_empty():
			show_message("新手教學完成！亂世之路由你開創。", 3.5)
		else:
			show_message("教學｜%s" % str(next_step.get("label", "")), 3.2)
	alpha24_commit_demo_state()


func alpha24_current_tutorial_label() -> String:
	var step: Dictionary = Alpha24SteamDemo.current_tutorial(alpha24_demo_state)
	return str(step.get("label", ""))


func alpha24_story_chapter_allowed(chapter_number: int) -> bool:
	return Alpha24SteamDemo.demo_chapter_allowed(chosen_mode, chapter_number)


func alpha24_complete_demo() -> String:
	alpha24_demo_state["demo_completed"] = true
	alpha24_commit_demo_state()
	var route_name: String = Alpha23RouteResolver.route_label(str(alpha23_route_state.get("dominant", "")))
	var ending_title: String = str(alpha23_pending_ending.get("title", ""))
	return Alpha24SteamDemo.completion_message(route_name, ending_title)


func alpha24_update_release_guard(delta: float) -> void:
	alpha24_frame_sample_timer -= delta
	if alpha24_frame_sample_timer > 0.0:
		return
	alpha24_frame_sample_timer = 1.0
	var frame_ms: float = frame_time_ema * 1000.0
	var current_quality: String = str(alpha24_demo_state.get("quality", "high"))
	var next_quality: String = Alpha24SteamDemo.quality_for_frame_time(frame_ms, current_quality)
	if next_quality != current_quality:
		alpha24_demo_state["quality"] = next_quality
		alpha24_quality_profile = Alpha24SteamDemo.quality_profile(next_quality)
		alpha24_commit_demo_state()
	alpha24_apply_quality_caps()


func alpha24_apply_quality_caps() -> void:
	var enemy_cap: int = int(alpha24_quality_profile.get("enemy_cap", MAX_PICKUPS))
	var particle_cap: int = int(alpha24_quality_profile.get("particle_cap", MAX_PARTICLES))
	var shot_cap: int = int(alpha24_quality_profile.get("shot_cap", MAX_PLAYER_SHOTS))
	var number_cap: int = int(alpha24_quality_profile.get("damage_number_cap", MAX_DAMAGE_NUMBERS))
	if enemies.size() > enemy_cap:
		enemies.resize(enemy_cap)
	if particles.size() > particle_cap:
		particles.resize(particle_cap)
	if player_shots.size() > shot_cap:
		player_shots.resize(shot_cap)
	if damage_numbers.size() > number_cap:
		damage_numbers.resize(number_cap)


func alpha24_commit_demo_state() -> void:
	save_data["alpha24_demo"] = alpha24_demo_state.duplicate(true)


func alpha24_release_readiness() -> Dictionary:
	return Alpha24SteamDemo.release_readiness(
		GAME_VERSION,
		SAVE_FORMAT_VERSION >= 4,
		bool(alpha24_demo_state.get("tutorial_done", false)),
		startup_checks.filter(func(value: String) -> bool: return value.find("ERROR") >= 0).size(),
		asset_errors.size()
	)
