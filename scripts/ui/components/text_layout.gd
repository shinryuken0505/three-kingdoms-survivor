class_name TextLayout
extends RefCounted

## 共用文字排版計算，避免各畫面自行硬編碼行距與可視列。


static func visible_range(total_count: int, selected_index: int, max_rows: int) -> Dictionary:
	if total_count <= 0 or max_rows <= 0:
		return {"start": 0, "end": 0, "selected": 0}
	var selected: int = clampi(selected_index, 0, total_count - 1)
	var rows: int = mini(max_rows, total_count)
	var start: int = clampi(selected - rows / 2, 0, maxi(0, total_count - rows))
	return {"start": start, "end": start + rows, "selected": selected}


static func row_rects(area: Rect2, row_count: int, gap: float = 6.0) -> Array[Rect2]:
	var result: Array[Rect2] = []
	if row_count <= 0 or area.size.y <= 0.0:
		return result
	var safe_gap: float = maxf(0.0, gap)
	var row_height: float = maxf(0.0, (area.size.y - safe_gap * float(row_count - 1)) / float(row_count))
	for index in range(row_count):
		result.append(Rect2(
			Vector2(area.position.x, area.position.y + float(index) * (row_height + safe_gap)),
			Vector2(area.size.x, row_height)
		))
	return result


static func fit_font_size(
	font: Font,
	text: String,
	available_width: float,
	preferred_size: int,
	minimum_size: int = 11
) -> int:
	if font == null or text.is_empty() or available_width <= 0.0:
		return maxi(minimum_size, preferred_size)
	var size: int = maxi(minimum_size, preferred_size)
	while size > minimum_size and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size).x > available_width:
		size -= 1
	return size
