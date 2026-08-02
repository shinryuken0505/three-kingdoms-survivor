# V2.0.0-alpha.17 待改清單

本文件集中記錄目前測試中確認的問題、功能需求與架構整理工作，供後續 AI／工程師依序處理。

## 使用方式

- 每次只處理一個項目，避免同時修改 UI、輸入、戰鬥與存檔。
- 每個項目完成後，補上 Commit、測試結果與剩餘限制。
- 玩家可見文字需預留繁中、簡中、英文、日文翻譯 key。
- 所有畫面需以 1280×720 為基準，並確認 16:9 等比縮放。
- 未經本機 Godot 4.7.x F5 實測，不可標記為完成。
- 架構整理項目不得在同一輪同時改玩法規則與存檔格式。

---

## A17-UI-001　章間整備／史勢演變畫面排版修正

**優先度：高**

### 問題

「史勢演變」章間畫面左側資訊區出現文字重疊與垂直空間不足：

- 「保留內容」區塊與「本局史勢」互相壓疊。
- 裝備、遺物、技能、銅錢等資訊行距過密。
- 底部群雄傾向與勢力數值靠近按鈕列。
- 左右卡片高度與內容密度不一致。

### 調整方向

- 左側內容拆為明確區塊：上一章結果、保留內容、本局史勢。
- 每個區塊使用獨立矩形與固定 padding。
- 長文字改用 `draw_wrapped()`，數值資訊採雙欄或緊湊表格。
- 底部按鈕與資訊區保留至少 20px 安全距離。
- 不再以單一絕對座標連續堆疊文字。

### 驗收條件

1. 1280×720 下沒有重疊、截字或超出邊框。
2. 主戰、後備、裝備、遺物、技能與銅錢皆可清楚辨識。
3. 「本局史勢」與群雄傾向完整顯示。
4. 五個底部按鈕位置與尺寸一致。
5. 英文與日文較長文字不會破版。

---

## A17-HERO-002　招賢館加入營地與統一編成流程

**優先度：高**

### 現況問題

招賢館選擇名將後，目前流程偏向直接加入主戰／後備或進入替換，與「名將整備」的主戰／後備／營地三層編成邏輯不一致。

### 目標流程

選定名將後，進入與名將整備一致的配置選擇：

1. 主戰
2. 後備
3. 營地
4. 取消／暫不同行

### 規則

- 主戰未滿：可直接加入主戰。
- 主戰已滿：才進入主戰替換畫面。
- 後備未滿：可直接加入後備。
- 後備已滿：才進入後備替換畫面。
- 營地：不限容量，直接加入營地。
- 招募完成後，玩家可在後續營地、商人或章間整備自由調整主戰／後備／營地。
- 名將首次加入時應初始化技能、羈絆、圖鑑與冷卻資料。
- 不可讓同一名將同時存在於兩個編成陣列。

### 架構要求

- 招賢館不得自行複製一套編成規則。
- 統一使用 `HeroRosterManager` 與 `HeroRosterController`。
- UI 只處理顯示與選擇，編成結果由 system 層回傳。
- 招賢館與名將整備共用位置名稱與翻譯 key。

### 驗收條件

1. 招賢館選定名將後可選主戰、後備或營地。
2. 主戰／後備滿額時進入正確替換畫面。
3. 選營地後，名將會出現在名將整備清單並標示【營地】。
4. 存檔後重新讀取，名將位置保持正確。
5. Enter、Space、Esc 操作一致。

---

## A17-HUD-003　主角負面狀態圖示

**優先度：中高**

### 目標

玩家在戰場中可立即辨識主角目前受到哪些負面狀態，以及剩餘時間或層數。

### 顯示位置建議

1. 主角頭上方小型圖示列。
2. 若同時狀態過多，右上角 HUD 顯示完整狀態列。
3. 主角頭上保留最多 3 個最重要狀態，其餘顯示於 HUD。

### 圖示規格

- 與範圍技／戰場提示 icon 使用一致的像素風與描邊規格。
- icon 必須清晰、易懂，避免只靠顏色區分。
- 建議圖示：中毒、燃燒、緩速、暈眩、沉默、流血、易傷。
- 圖示下方或外圈顯示剩餘時間。
- 可堆疊狀態顯示層數。
- 狀態即將結束時可閃爍或降低透明度。

### 架構要求

建議拆為：

```text
scripts/systems/combat/status_effect_manager.gd
scripts/data/status_effect_defs.gd
scripts/ui/components/status_effect_renderer.gd
```

- 戰鬥規則不直接繪製 icon。
- UI 不以中文狀態名稱判斷效果。
- 狀態 ID、icon path、翻譯 key 與優先級集中定義。

### 驗收條件

1. 主角中負面狀態後，圖示立即出現。
2. 狀態結束後圖示立即消失。
3. 同時多種狀態時不互相重疊。
4. 至少可辨識狀態種類與剩餘時間。
5. 1280×720 下不遮住 Boss 血條、小地圖或技能欄。
6. 四語 tooltip 不破版。

---

# 架構整理待辦

## A17-ARCH-004　完成名將整備模組拆分

**優先度：最高**

### 目標

將名將整備的規則、互動決策、ViewModel 與繪製完全分離，逐步縮小 `main.gd`。

### 目標檔案

```text
scripts/systems/hero/hero_roster_manager.gd
scripts/systems/hero/hero_roster_controller.gd
scripts/systems/hero/hero_roster_view_model.gd
scripts/ui/screens/hero_config_screen.gd
scripts/ui/screens/hero_position_picker_screen.gd
scripts/ui/screens/hero_replace_screen.gd
```

### 驗收條件

1. `main.gd` 不再包含完整名將整備畫面繪製。
2. 主戰、後備、營地、滿額替換與 Esc 取消維持現有行為。
3. UI 不直接修改編成陣列。
4. 不改存檔格式。

---

## A17-ARCH-005　建立共用 UI 元件

**優先度：高**

### 目標檔案

```text
scripts/ui/components/panel_renderer.gd
scripts/ui/components/menu_option_renderer.gd
scripts/ui/components/modal_renderer.gd
scripts/ui/components/status_badge_renderer.gd
scripts/ui/components/text_layout.gd
```

### 目的

統一 Panel、標題、選項、高亮、底部操作提示與 Modal 背景，降低各畫面各自手算座標造成的跑版問題。

### 驗收條件

1. 章間、名將整備與替換視窗至少共用一項元件。
2. 不改變既有視覺風格。
3. 英文與日文長字串可安全換行或縮排。

---

## A17-ARCH-006　畫面路由與輸入路由

**優先度：高**

### 目標檔案

```text
scripts/core/screen_router.gd
scripts/core/input_router.gd
```

### 目標

- 使用 `ScreenIds` 作為唯一畫面 ID 來源。
- 每個畫面具有固定的 enter／exit／handle_input／draw 契約。
- 統一 Enter、Space、Esc 與 Modal 輸入鎖。

### 驗收條件

1. 不再新增裸 `screen = "..."` 字串。
2. Modal 不會發生按鍵穿透。
3. 輸入路由與繪製路由對同一畫面 ID 都有登記。

---

## A17-ARCH-007　多國語言全面落地與檢查工具

**優先度：高**

### 目標檔案

```text
localization/game.zh_TW.po
localization/game.zh_CN.po
localization/game.en.po
localization/game.ja.po
tools/check_localization_keys.py
```

### 目標

- 玩家可見文字逐步改為翻譯 key。
- 四語 key 必須一致。
- 翻譯後文字不可作為流程判斷條件。

### 驗收條件

1. 工具可檢查缺少與多餘 key。
2. 至少完成名將整備、章間畫面與負面狀態三個區域的四語 key。
3. 繁中為 fallback，缺翻譯時不顯示空字串。

---

## A17-ARCH-008　存檔系統抽離

**優先度：中高**

### 目標檔案

```text
scripts/systems/save/save_manager.gd
scripts/systems/save/save_migrator.gd
scripts/systems/save/checkpoint_builder.gd
scripts/systems/save/save_validator.gd
```

### 目標

集中管理序列化、備份、版本遷移、章間檢查點與讀檔驗證。

### 驗收條件

1. 舊存檔可讀取。
2. 主檔損壞時可使用備份。
3. `SAVE_FORMAT_VERSION` 與 `CHECKPOINT_VERSION` 有明確遷移規則。
4. 不在同一輪同時修改玩法與存檔格式。

---

## A17-ARCH-009　戰鬥狀態效果系統

**優先度：中高**

### 目標檔案

```text
scripts/systems/combat/status_effect_manager.gd
scripts/data/status_effect_defs.gd
scripts/ui/components/status_effect_renderer.gd
```

### 目標

統一處理中毒、燃燒、緩速、暈眩、沉默、流血與易傷等狀態，並提供 HUD 使用的 ViewModel。

### 驗收條件

1. 狀態規則與 HUD 繪製分離。
2. 狀態使用穩定英文 ID。
3. 支援 duration、stacks、source_id、priority。
4. 可直接支援 `A17-HUD-003`。

---

## A17-ARCH-010　靜態資料拆分與資料驗證

**優先度：中**

### 目標檔案

```text
scripts/data/hero_defs.gd
scripts/data/skill_defs.gd
scripts/data/equipment_defs.gd
scripts/data/relic_defs.gd
scripts/data/bond_defs.gd
scripts/data/chapter_defs.gd
scripts/data/enemy_defs.gd
scripts/data/data_validator.gd
```

### 驗收條件

1. ID 不重複。
2. 引用的角色、技能、羈絆與 Boss 都存在。
3. icon／portrait／sprite 路徑有效。
4. 所有玩家文字都有翻譯 key。
5. 新資料缺欄位時能在 CI 中明確報錯。

---

## A17-ARCH-011　清理暫時性工具與 Actions

**優先度：中**

### 目標

分類現有 `tools/fix_*.py` 與 `.github/workflows/fix-*.yml`：

- 保留：Godot Check、靜態檢查、資料驗證、翻譯驗證。
- 移除：只執行一次的 patch workflow。
- 封存：仍有追溯價值的歷史修復工具。

### 驗收條件

1. 新 AI 能清楚辨識哪些 workflow 是正式流程。
2. 不再使用一次性 patch workflow 作為一般開發方式。
3. 所有自動生成 commit 都必須被後續驗證。

---

## 建議處理順序

1. `A17-ARCH-004`：完成名將整備模組拆分。
2. `A17-ARCH-005`：建立共用 UI 元件。
3. `A17-UI-001`：使用共用版面工具修章間排版。
4. `A17-HERO-002`：統一招賢館與名將整備流程。
5. `A17-ARCH-006`：畫面與輸入路由。
6. `A17-ARCH-007`：多國語言落地。
7. `A17-ARCH-009`＋`A17-HUD-003`：狀態效果與 HUD。
8. `A17-ARCH-008`：存檔抽離。
9. `A17-ARCH-010`：靜態資料拆分。
10. `A17-ARCH-011`：清理暫時性工具與 Actions。

## 測試紀錄

| 項目 | 狀態 | Commit | Godot Check | 本機 F5 | 備註 |
|---|---|---|---|---|---|
| A17-UI-001 | 待處理 |  |  |  |  |
| A17-HERO-002 | 待處理 |  |  |  |  |
| A17-HUD-003 | 待處理 |  |  |  |  |
| A17-ARCH-004 | 進行中 |  |  |  | 名將規則與 Controller 已建立 |
| A17-ARCH-005 | 待處理 |  |  |  |  |
| A17-ARCH-006 | 待處理 |  |  |  |  |
| A17-ARCH-007 | 待處理 |  |  |  |  |
| A17-ARCH-008 | 待處理 |  |  |  |  |
| A17-ARCH-009 | 待處理 |  |  |  |  |
| A17-ARCH-010 | 待處理 |  |  |  |  |
| A17-ARCH-011 | 待處理 |  |  |  |  |
