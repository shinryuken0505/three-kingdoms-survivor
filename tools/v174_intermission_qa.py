#!/usr/bin/env python3
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
main = (ROOT / "scripts/main.gd").read_text(encoding="utf-8-sig")
project = (ROOT / "project.godot").read_text(encoding="utf-8-sig")
checks = {
    "version": ("V1.7.4 章間整備強化版" in project or "V1.7.4.1 升級選擇輸入修正版" in project or "V1.7.4.2 武將臉部陰影修正版" in project),
    "equipment_option": '["名將整備", "裝備整備", "進入下一章", "返回主選單"]' in main,
    "equipment_open": 'previous_screen = "intermission"' in main and 'tab_page = 1' in main,
    "equipment_confirm": 'elif is_confirm_key(key) and tab_page == 1:' in main and 'equip_selected_inventory_item()' in main,
    "checkpoint_on_return": '章間裝備配置已保存。' in main and 'save_run_checkpoint()' in main,
    "hero_layout": '目前主動陣容' in main and '已結識名將' in main and '主動技能' in main and '後備能力' in main,
    "intermission_copy": '名將與主角裝備皆可在此調整' in main,
}
failed = [k for k,v in checks.items() if not v]
if failed:
    raise SystemExit("V174_INTERMISSION_QA_FAILED " + ",".join(failed))
print(f"V174_INTERMISSION_QA_OK {len(checks)}")
