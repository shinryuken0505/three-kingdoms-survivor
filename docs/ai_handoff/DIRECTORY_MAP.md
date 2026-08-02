# 目錄用途

```text
/
├── AI_START_HERE.md              # AI／工程師接手入口
├── project.godot                 # Godot 專案設定
├── main.tscn                     # 目前唯一主場景
├── scripts/
│   ├── main.gd                   # 主控制器
│   ├── game_data.gd              # 遊戲靜態資料
│   ├── chapter_manager.gd        # 章節管理
│   └── history_event_data.gd     # 歷史事件資料
├── assets/
│   ├── audio/
│   ├── maps/
│   ├── portraits/
│   ├── props/
│   ├── relics/
│   └── sprites/
├── localization/                 # 四語 PO
├── tools/                        # QA 與分析工具
└── docs/
    ├── ai_handoff/               # 接手與架構文件
    ├── qa/                       # 建議集中新 QA 報告
    ├── release_notes/            # 建議集中後續版本說明
    └── legacy assets/docs        # 舊版圖片與歷史報告，暫不搬動避免遺漏
```

## 整理策略

目前根目錄有許多歷史版本說明。為避免破壞既有批次檔或人工流程，本次不強制搬移；從下一版起，新增文件請放入：

- 版本說明：`docs/release_notes/`
- QA 報告：`docs/qa/`
- 架構與規格：`docs/ai_handoff/`
