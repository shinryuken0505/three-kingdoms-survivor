# 《三國人生錄：亂世倖存》AI 開發接手入口

本文件是任何新 AI、工程師或協作者進入專案時的第一站。

## 1. 先讀哪些文件

依序閱讀：

1. `AI_START_HERE.md`（本文件）
2. `docs/ai_handoff/ARCHITECTURE.md`
3. `docs/ai_handoff/GAMEPLAY_FLOW.md`
4. `docs/ai_handoff/INPUT_AND_SCREEN_STATE.md`
5. `docs/ai_handoff/DATA_CONTRACTS.md`
6. `docs/ai_handoff/TESTING_AND_RELEASE.md`
7. `docs/ai_handoff/KNOWN_RISKS.md`

## 2. 專案現況

- 引擎：Godot 4.7.x
- 主場景：`main.tscn`
- 主程式：`scripts/main.gd`
- 目前版本：V2.0.0-alpha.1 地貌重製與世界架構
- 畫面基準：1280×720
- 世界範圍：3200×2200
- 儲存位置：`user://demo6_save.json`
- 語系：繁中、簡中、英文、日文

## 3. 最重要的工程事實

目前專案仍以「單場景＋大型主控制器」為主，但 V2.0 已開始建立可拆分模組：

- `scripts/main.gd` 約 8,000 行，負責輸入、流程、戰鬥、UI、繪製、音效、存檔與自我測試。
- `scripts/game_data.gd` 保存角色、技能、裝備、羈絆等靜態資料。
- `scripts/chapter_manager.gd` 管理章節流程與章節狀態。
- `scripts/history_event_data.gd` 保存歷史事件與選項資料。

因此修改前必須先確認功能屬於「資料」「流程」「輸入」「戰鬥」「繪製」哪一層，避免直接在錯誤區塊插入程式。

## 4. 目前最高優先事項

1. 根治升級選單偶發無法確認。
2. 保持名將 1～2 人候選、陣營／羈絆／劇情權重正常。
3. 讓劇情旗標真正影響中後期關卡、敵軍與 Boss。
4. 強化地形玩法與戰場視覺，但不要破壞既有碰撞／生成流程。
5. 武將像素角色可保留；優先提升立繪、背景、UI 與 Boss 演出。
6. 逐步拆分 `main.gd`，每次只搬移一個可測試模組。

## 5. 禁止事項

- 不可在未執行 Godot 的情況下聲稱「已實機通關」。
- 不可硬編碼「最後一章」或固定章節索引。
- 不可只修 Space；所有 modal 選單需同時支援 Enter、Space、滑鼠，並處理輸入鎖。
- 不可讓劇情選擇只改文字；重大選擇至少要回收到一項可玩內容。
- 不可批次覆蓋立繪而沒有保留原檔或 QA 報告。
- 不可在同一版本同時大改輸入、存檔、戰鬥與資料格式而沒有遷移方案。

## 6. 新 AI 接手時的第一個動作

先執行：

```bash
python tools/project_structure_report.py
```

再檢查：

```bash
python tools/static_smoke_test.py
```

這些只能做靜態檢查，最後仍必須在 Godot 4.7.x 進行實機測試。

## V2.0.0-alpha.14 歷史分歧新增契約
- `scripts/systems/world/history_route_rules.gd`：集中管理歷史選項對蜀／魏／吳／群勢力與改寫率的影響。
- `faction_momentum`、`history_rewrite_rate`、`history_route_tags` 已納入章節存檔。
- 新增歷史效果時，優先在 `HistoryRouteRules.impact_for()` 補資料，不要把勢力判定散落到 UI 或 Boss 程式。
- Boss 分支由 `current_stage_branch_profile()` 統一解析；主線選擇優先於勢力與主戰名將。

## V2.0.0-alpha.15.2 名將技能形態規則
- 不要將所有名將技能實作成以玩家為中心的圓形 AOE。
- 技能形態依角色定位分為：直線穿陣、單發狙擊、扇形掃射、目標區法陣、前方風牆、召喚援軍與少數合理的全周控場。
- 張飛、華佗等角色可保留近身圓形效果；遠程、軍師與突擊型名將應優先使用方向性技能。
