#!/usr/bin/env python3
from pathlib import Path
root = Path(__file__).resolve().parents[1]
main = (root / "scripts/main.gd").read_text(encoding="utf-8")
project = (root / "project.godot").read_text(encoding="utf-8")
checks = {
    "version": (("V1.7.1" in project and "視覺統一與介面美編版" in project) or ("V1.7.2" in project and "武將肖像全面修正版" in project)),
    "ornamented panels": "func draw_panel(" in main and "角飾" in main and "var inner: Rect2" in main,
    "screen wash": "func draw_screen_wash" in main and "戰旗斜紋" in main,
    "section headers": "func draw_section_header" in main,
    "action buttons": "func draw_action_button" in main,
    "menu composition": "旅程選單" in main and "亂世紀錄" in main and (("V1.7.1・視覺統一與介面美編版" in main) or ("V1.7.2・武將肖像全面修正版" in main)),
    "settings composition": "調整聲音、演出與顯示方式" in main and "目前項目" in main,
    "save integration": "讀取存檔" in main and "checkpoint_summary" in main,
}
failed = [name for name, ok in checks.items() if not ok]
if failed:
    raise SystemExit("FAIL " + ", ".join(failed))
print("V171_VISUAL_CHECK_OK")
for name in checks:
    print(" -", name)
