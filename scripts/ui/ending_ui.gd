class_name EndingUI
extends RefCounted


static func draw(host: Node, snapshot: Dictionary) -> void:
	host.draw_rect(Rect2(Vector2.ZERO, host.VIEW), Color8(17, 20, 20), true)
	var root := Rect2(90, 42, 1100, 636)
	host.draw_panel(root, Color(0.025, 0.03, 0.029, 0.99), Color8(206, 169, 91), 2.4)
	host.draw_text("亂世終卷", Vector2(640, 92), 25, Color8(183, 170, 135), true, HORIZONTAL_ALIGNMENT_CENTER, 620)
	host.draw_text(str(snapshot.get("title", "亂世見證者")), Vector2(640, 142), 43, Color8(244, 215, 151), true, HORIZONTAL_ALIGNMENT_CENTER, 900)
	host.draw_wrapped(str(snapshot.get("narration", "")), Rect2(150, 166, 980, 82), 18, Color8(221, 221, 207), 27.0, true)

	var left := Rect2(140, 270, 480, 260)
	var right := Rect2(660, 270, 480, 260)
	host.draw_panel(left, Color(0.04, 0.046, 0.044, 0.96), Color8(116, 103, 72), 1.3)
	host.draw_panel(right, Color(0.04, 0.046, 0.044, 0.96), Color8(116, 103, 72), 1.3)

	var stats: Dictionary = snapshot.get("stats", {}) as Dictionary
	var seconds := int(float(snapshot.get("elapsed", 0.0)))
	var left_lines: Array[String] = [
		"最終章　%s" % str(snapshot.get("chapter_title", "")),
		"遊玩時間　%02d:%02d:%02d" % [seconds / 3600, (seconds / 60) % 60, seconds % 60],
		"擊敗敵軍　%d" % int(stats.get("kills", 0)),
		"造成傷害　%d" % int(stats.get("damage_dealt", 0.0)),
		"承受傷害　%d" % int(stats.get("damage_taken", 0.0))
	]
	for i in range(left_lines.size()):
		host.draw_text(left_lines[i], left.position + Vector2(24, 42 + i * 42), 17, Color8(223, 212, 184), i == 0)

	host.draw_text("同行群英", right.position + Vector2(24, 40), 21, Color8(235, 211, 157), true)
	host.draw_wrapped(
		"主動：%s\n後備：%s" % [
			host.ending_hero_names(snapshot.get("active_heroes", [])),
			host.ending_hero_names(snapshot.get("reserve_heroes", []))
		],
		Rect2(right.position + Vector2(24, 58), Vector2(432, 78)),
		16,
		Color8(207, 214, 204),
		24.0
	)
	host.draw_text("最終裝備", right.position + Vector2(24, 158), 19, Color8(235, 211, 157), true)
	host.draw_wrapped(host.ending_equipment_summary(), Rect2(right.position + Vector2(24, 176), Vector2(432, 58)), 15, Color8(194, 204, 194), 22.0)
	host.draw_wrapped("史官評曰：%s" % str(snapshot.get("historian_comment", "")), Rect2(145, 548, 990, 54), 16, Color8(212, 194, 151), 23.0, true)

	var button := Rect2(485, 612, 310, 50)
	host.draw_panel(button, Color(0.48, 0.34, 0.13, 0.94), Color8(235, 204, 137), 1.8)
	host.draw_centered_text("返回主選單", button, 33.0, 20, Color8(245, 231, 198), true)
