# 《三國人生錄：亂世倖存》AI 開發接手入口

本文件是任何新 AI、工程師或協作者進入專案時的第一站。

## 1. 閱讀順序

1. `AI_START_HERE.md`
2. `docs/ai_handoff/ARCHITECTURE_V2.md`（目前目標架構，優先）
3. `docs/ai_handoff/ARCHITECTURE.md`（既有架構紀錄）
4. `docs/ai_handoff/GAMEPLAY_FLOW.md`
5. `docs/ai_handoff/INPUT_AND_SCREEN_STATE.md`
6. `docs/ai_handoff/DATA_CONTRACTS.md`
7. `docs/ai_handoff/TESTING_AND_RELEASE.md`
8. `docs/ai_handoff/KNOWN_RISKS.md`
9. `docs/ai_handoff/AI_TASK_TEMPLATE.md`

## 2. 專案現況

- 引擎：Godot 4.7.x
- 主場景：`main.tscn`
- 主程式：`scripts/main.gd`
- 目前版本：V2.0.0-alpha.17
- 工作分支：`feature/alpha17-ending`
- 畫面基準：1280×720
- 世界範圍：3200×2200
- 儲存位置：`user://demo6_save.json`
- 支援語系：繁中、簡中、英文、日文
- 語系 fallback：`zh_TW`

## 3. 工程語言決策

- 程式識別字、檔名、資料 ID、翻譯 key：英文。
- 文件、設計說明與必要註解：繁體中文。
- 玩家可見文字：逐步改為翻譯 key，不得用顯示文字作為流程 ID。
- 新畫面 ID：集中於 `scripts/core/screen_ids.gd`。
- 新的格式化翻譯：使用 `scripts/core/localization_service.gd`。

## 4. 目前架構

目前仍以「單場景＋大型主控制器」為主，但已開始拆分：

- `scripts/main.gd`：輸入、流程、戰鬥、部分 UI、音效、存檔與自測。
- `scripts/game_data.gd`：角色、技能、裝備、羈絆等靜態資料。
- `scripts/chapter_manager.gd`：章節流程與狀態。
- `scripts/history_event_data.gd`：歷史事件與選項。
- `scripts/systems/hero/hero_roster_manager.gd`：名將編成規則基礎。
- `scripts/systems/ending/ending_manager.gd`：結局選擇與快照。
- `scripts/ui/ending_ui.gd`、`scripts/ui/boss_loot_ui.gd`：已抽離的 UI renderer。

修改前先確認功能屬於 core、data、system、UI、save、localization 哪一層。

## 5. 重構原則

1. `main.gd` 作為 Composition Root，逐步縮小，不一次全面改寫。
2. 一次只搬移一個可測試模組。
3. 規則與 UI 分離；system 不直接繪圖。
4. 穩定 ID 與顯示文字分離。
5. 每次重構後先看 Godot Check，再由本機 F5 驗證。
6. 存檔欄位變更必須提供預設值與遷移。
7. DLC／skin 只影響外觀，不影響能力、掉落、羈絆、成就或存檔有效性。

## 6. 禁止事項

- 不可在未執行 Godot 的情況下聲稱「已實機通關」。
- 不可硬編碼最後一章或固定章節索引。
- 不可只修 Space；Modal 必須維持 Enter、Space、Esc 一致，並處理輸入穿透。
- 不可使用翻譯後的中文／英文文字作為主要 match 條件。
- 不可讓劇情選擇只改文字；重大選擇至少回收到一項可玩內容。
- 不可同一輪大改輸入、存檔、戰鬥與資料格式。
- 不可只提交 patch workflow，卻沒有確認生成結果已進入目標檔案。

## 7. 新 AI 接手第一步

```bash
python tools/project_structure_report.py
python tools/static_smoke_test.py
```

再檢查 GitHub Actions 的 `Godot Check`。上述皆不能取代 Godot 4.7.x 本機實測。

## 8. 既有重要契約

### 歷史分歧

- `scripts/systems/world/history_route_rules.gd` 集中管理蜀／魏／吳／群勢力與改寫率。
- `faction_momentum`、`history_rewrite_rate`、`history_route_tags` 已納入存檔。
- 新增歷史效果優先在 `HistoryRouteRules.impact_for()` 補資料。
- Boss 分支由 `current_stage_branch_profile()` 統一解析。

### 名將技能形態

- 不要將所有技能做成玩家中心圓形 AOE。
- 依角色定位使用直線、狙擊、扇形、法陣、風牆、援軍或合理全周控場。
- 張飛、華佗等近身角色可保留圓形效果。
