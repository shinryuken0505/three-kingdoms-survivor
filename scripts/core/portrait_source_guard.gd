extends Node

## Alpha.57 正式立繪來源防回歸。
##
## main.gd 目前仍保留舊 _default / portraits_remastered 載入相容邏輯；
## 本 Guard 在主場景 ready 後統一覆寫 portrait_tex，避免新 UI 或舊存檔路徑
## 把已完成的正式立繪蓋回舊版。僅處理外觀，不改角色資料、能力或存檔。
## 少數角色若在 Alpha.57 後已重新確認新版 _default 圖，則以該最新確認檔為準。

const CANONICAL_PORTRAITS: Dictionary = {
	# 主角：優先使用 Alpha.57 已完成的新主角立繪。
	"swordsman": "res://assets/portraits/player_swordsman.png",
	"hunter": "res://assets/portraits/player_archer.png",

	# 名將 / Boss：以已確認的正式立繪為唯一來源，禁止回退到 remastered 或角色小人。
	"caimao": "res://assets/portraits/caimao_default.png",
	"caiwenji": "res://assets/portraits/cai_wenji.png",
	"caocao": "res://assets/portraits/cao_cao.png",
	"caoren": "res://assets/portraits/caoren_default.png",
	"chengong": "res://assets/portraits/chen_gong.png",
	"daqiao": "res://assets/portraits/da_qiao.png",
	"diaochan": "res://assets/portraits/diao_chan.png",
	"dongzhuo": "res://assets/portraits/dong_zhuo.png",
	"fazheng": "res://assets/portraits/fa_zheng.png",
	"gaoshun": "res://assets/portraits/gao_shun.png",
	"guanyu": "res://assets/portraits/guan_yu.png",
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
	"xuchu": "res://assets/portraits/xuchu_default.png",
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


func _ready() -> void:
	# Autoload 的 ready 早於 main scene；延後一個 frame，確保 main.load_assets() 已完成。
	call_deferred("_apply_to_current_scene")


func _apply_to_current_scene() -> void:
	await get_tree().process_frame
	var scene: Node = get_tree().current_scene
	if scene == null:
		return
	if not scene.has_method("runtime_texture"):
		push_warning("PortraitSourceGuard: current scene has no runtime_texture().")
		return
	var portrait_value: Variant = scene.get("portrait_tex")
	if not (portrait_value is Dictionary):
		push_warning("PortraitSourceGuard: current scene has no portrait_tex dictionary.")
		return
	var portrait_tex: Dictionary = portrait_value as Dictionary
	var applied: int = 0
	for raw_id in CANONICAL_PORTRAITS.keys():
		var character_id: String = str(raw_id)
		var path: String = str(CANONICAL_PORTRAITS[raw_id])
		if not ResourceLoader.exists(path) and not FileAccess.file_exists(path):
			# 不以舊圖靜默替代；缺檔時保留目前值並留下明確警告。
			push_warning("PortraitSourceGuard: canonical portrait missing: %s -> %s" % [character_id, path])
			continue
		portrait_tex[character_id] = scene.call("runtime_texture", path)
		applied += 1
	scene.set("portrait_tex", portrait_tex)
	if scene.has_method("queue_redraw"):
		scene.call("queue_redraw")
	print("PortraitSourceGuard: applied %d canonical Alpha.57 portraits." % applied)
