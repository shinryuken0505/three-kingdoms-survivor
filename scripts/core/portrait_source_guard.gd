extends Node

## Alpha.58 正式立繪來源防回歸。
##
## main.gd 目前仍保留舊 _default / portraits_remastered 載入相容邏輯；
## 本 Guard 在主場景 ready 後統一覆寫 portrait_tex，避免新 UI 或舊存檔路徑
## 把已完成的正式立繪蓋回舊版。僅處理外觀，不改角色資料、能力或存檔。
## 少數角色若在 Alpha.57 後已重新確認新版 _default 圖，則以該最新確認檔為準。
## Alpha.58 起若正式檔存在但解碼失敗，不再把粉黑 Missing Texture 蓋到玩家畫面，
## 而是保留 main.gd 已成功載入的同角色安全舊圖並留下明確警告。

const CANONICAL_PORTRAITS: Dictionary = {
	"swordsman": "res://assets/portraits/player_swordsman.png",
	"hunter": "res://assets/portraits/player_archer.png",
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
	if not portrait_value is Dictionary:
		push_warning("PortraitSourceGuard: current scene has no portrait_tex dictionary.")
		return
	var portrait_tex: Dictionary = portrait_value as Dictionary
	var applied: int = 0
	var retained_fallbacks: int = 0
	for raw_id in CANONICAL_PORTRAITS.keys():
		var character_id: String = str(raw_id)
		var path: String = str(CANONICAL_PORTRAITS[raw_id])
		if not ResourceLoader.exists(path) and not FileAccess.file_exists(path):
			push_warning("PortraitSourceGuard: canonical portrait missing; keeping current portrait: %s -> %s" % [character_id, path])
			retained_fallbacks += 1
			continue
		var candidate: Variant = scene.call("runtime_texture", path)
		var asset_errors_value: Variant = scene.get("asset_errors")
		var decode_failed: bool = asset_errors_value is Array and (asset_errors_value as Array).has(path)
		var texture_valid: bool = candidate is Texture2D and (candidate as Texture2D).get_width() > 32 and (candidate as Texture2D).get_height() > 32
		if decode_failed or not texture_valid:
			push_warning("PortraitSourceGuard: canonical portrait decode failed; keeping current portrait: %s -> %s" % [character_id, path])
			retained_fallbacks += 1
			continue
		portrait_tex[character_id] = candidate as Texture2D
		applied += 1
	scene.set("portrait_tex", portrait_tex)
	if scene.has_method("queue_redraw"):
		scene.call("queue_redraw")
	print("PortraitSourceGuard: applied %d canonical portraits; retained %d safe fallback(s)." % [applied, retained_fallbacks])
