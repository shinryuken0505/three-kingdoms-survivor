# V2.0.0-alpha.17 重構進度紀錄

本文件補充 `ALPHA17_BACKLOG.md` 的實際提交與驗證狀態。Backlog 保留需求與驗收條件；本文件只記錄已完成批次，避免把「建立基礎模組」誤標成「功能已完成」。

## 狀態定義

- **已提交／待本機驗證**：程式與測試已提交，尚待 Godot F5 驗證。
- **本機啟動通過**：使用者確認 F5 可正常啟動，但不代表所有功能情境均已驗收。
- **功能驗收通過**：指定操作流程與畫面均已測試。

## 目前進度

| 項目 | 狀態 | 內容 | 主要 Commit |
|---|---|---|---|
| A17-ARCH-004 名將整備拆分 | 進行中／多批本機啟動通過 | Manager、Controller、ViewModel、Session、畫面排版模型、輸入協調層與事件套用橋接層已建立；`main.gd` 完整 renderer 尚未移除 | `015b2f6`、`4fdf597`、`de6bef8`、`55462f6`、`363f560`、`00aab4b` |
| A17-ARCH-005 共用 UI 元件 | 基礎完成／本機啟動通過 | Panel、Modal、文字排版、選項按鈕、狀態徽章已建立；名將位置、替換與章間 layout 已開始共用 | `7c1665c`、`20ea766`、`e03f561`、`e586c82`、`6e93964` |
| A17-UI-001 章間排版 | 進行中 | 安全區、左右欄、左側三區塊與五按鈕列 layout 已完成；舊 `main.gd` renderer 尚待正式接線 | `d03e4e7`、`6fea443`、`20ea766` |
| A17-HERO-002 招賢館統一編成 | 基礎完成／尚未接線 | 招募位置服務與名將編成共用規則已建立；招賢館現有流程尚待接入 | `becf615` |
| A17-ARCH-006 畫面與輸入路由 | 基礎完成／多批本機啟動通過 | ScreenRouter、InputRouter、名將整備輸入協調層與事件套用橋接層已建立；尚未接管 `main.gd` | `1cd4f9b`、`68321ec`、`34c3c97`、`363f560`、`00aab4b` |
| A17-ARCH-009 狀態效果系統 | 基礎完成／尚未接線 | 定義、Manager、舊欄位 Adapter、HUD layout 與程式化 icon 已完成 | `5c7dad9`、`a285730` |
| A17-HUD-003 負面狀態圖示 | 進行中 | HUD 元件完成，尚未實際接入戰場 `main.gd` | `a285730` |
| A17-ARCH-007 多國語言 | 工具完成／內容待遷移 | 四語 key 一致性檢查已加入 Architecture Guard | `6e0a5e5` |

## 2026-08-03 共用 UI 批次

1. 新增 `menu_option_renderer.gd`，統一正常、選取與停用選項樣式。
2. 新增 `status_badge_renderer.gd`，統一主戰、後備與營地徽章配色及尺寸。
3. `HeroConfigScreen.visible_rows()` 改為委派 `TextLayout`。
4. `HeroReplaceScreen` 改用 `TextLayout` 與 `MenuOptionRenderer` 契約。
5. 新增 `shared_ui_components_test.gd`，檢查樣式差異、狀態徽章、可視範圍與替換列不重疊。
6. 使用者已確認本批可正常 F5 啟動。

## 2026-08-03 畫面／輸入路由批次

1. 新增 `screen_router.gd`：
   - 集中目前畫面、上一畫面、Context 與返回歷史。
   - 支援畫面 `enter`、`exit`、`handle_input`、`update`、`draw` 契約。
   - 拒絕未登記於 `ScreenIds` 的畫面 ID。
2. 新增 `input_router.gd`：
   - 將方向鍵與 WASD 正規化為一致 action。
   - Enter、數字鍵盤 Enter 與 Space 統一為確認。
   - Esc、E、Tab、P 使用穩定 action ID。
   - 提供 Modal 輸入鎖與快速重複確認防護。
3. 新增 `core_routing_test.gd`：
   - 驗證畫面進入、離開、返回堆疊與未知畫面拒絕。
   - 驗證按鍵對應、輸入鎖與確認鍵防連點。
4. 使用者已確認本批可正常 F5 啟動。

## 2026-08-03 名將整備輸入協調批次

1. 新增 `hero_roster_input_controller.gd`：
   - 接收 `InputRouter` 的穩定 action，不再直接依賴實體按鍵。
   - 主畫面、位置選擇與滿額替換依 Modal 優先順序處理輸入。
   - 僅更新 `HeroRosterSession` 並回傳事件，不直接修改正式編成資料。
   - 支援主戰、後備、營地、已在該位置、滿額替換與取消流程。
2. 新增 `hero_roster_input_controller_test.gd`：
   - 驗證主清單游標與位置選擇開啟。
   - 驗證移至營地的事件資料。
   - 驗證主戰滿額後開啟替換、游標切換與確認替換。
   - 驗證 Esc 會依替換彈窗、位置彈窗、主畫面的順序逐層關閉。
3. 使用者已確認本批可正常 F5 啟動。

## 2026-08-03 名將編成事件套用批次

1. 新增 `hero_roster_event_applier.gd`：
   - 將 Input Controller 的事件轉成正式編成修改。
   - 統一呼叫 `HeroRosterManager.move()`、`replace_active()`、`replace_reserve()`。
   - 支援主戰替換後優先送往後備，後備滿額才回營地。
   - 驗證替換對象仍位於原索引，避免畫面資料過期時誤換其他名將。
   - 套用後執行編成正規化，避免同一名將同時存在多個位置。
2. 新增 `hero_roster_event_applier_test.gd`：
   - 驗證後備移至營地。
   - 驗證主戰替換與空後備欄位。
   - 驗證後備替換後舊名將回營地。
   - 驗證過期替換資料不會修改編成。

### 本批驗證

- 存檔格式：未變更。
- 戰鬥規則：未變更。
- 玩家可見文字：未新增。
- `main.gd`：尚未接線，現有操作行為不應改變。
- Godot 本機 F5：待使用者驗證。
- 功能驗收：下一階段只需在 `handle_hero_config_key()` 建立 Session 同步、呼叫 Input Controller，再將事件交給 Event Applier。
