# V2.0.0-alpha.17 重構進度紀錄

本文件補充 `ALPHA17_BACKLOG.md` 的實際提交與驗證狀態。Backlog 保留需求與驗收條件；本文件只記錄已完成批次，避免把「建立基礎模組」誤標成「功能已完成」。

## 狀態定義

- **已提交／待本機驗證**：程式與測試已提交，尚待 Godot F5 驗證。
- **本機啟動通過**：使用者確認 F5 可正常啟動，但不代表所有功能情境均已驗收。
- **功能驗收通過**：指定操作流程與畫面均已測試。

## 目前進度

| 項目 | 狀態 | 內容 | 主要 Commit |
|---|---|---|---|
| A17-ARCH-004 名將整備拆分 | 進行中／多批本機啟動通過 | Manager、Controller、ViewModel、Session、畫面排版模型、輸入協調層、事件套用層、舊欄位橋接與完整流程協調器已建立；`main.gd` renderer 尚未移除 | `015b2f6`、`4fdf597`、`363f560`、`00aab4b`、`49c6519`、`e7d7ffb` |
| A17-ARCH-005 共用 UI 元件 | 基礎完成／本機啟動通過 | Panel、Modal、文字排版、選項按鈕、狀態徽章已建立；名將位置、替換與章間 layout 已開始共用 | `7c1665c`、`20ea766`、`e03f561`、`e586c82`、`6e93964` |
| A17-UI-001 章間排版 | 進行中 | 安全區、左右欄、左側三區塊與五按鈕列 layout 已完成；舊 `main.gd` renderer 尚待正式接線 | `d03e4e7`、`6fea443`、`20ea766` |
| A17-HERO-002 招賢館統一編成 | 基礎完成／尚未接線 | 招募位置服務與名將編成共用規則已建立；招賢館現有流程尚待接入 | `becf615` |
| A17-ARCH-006 畫面與輸入路由 | 基礎完成／多批本機啟動通過 | ScreenRouter、InputRouter 與名將整備完整協調流程已建立；尚未接管 `main.gd` | `1cd4f9b`、`68321ec`、`363f560`、`e7d7ffb` |
| A17-ARCH-009 狀態效果系統 | 基礎完成／尚未接線 | 定義、Manager、舊欄位 Adapter、HUD layout 與程式化 icon 已完成 | `5c7dad9`、`a285730` |
| A17-HUD-003 負面狀態圖示 | 進行中 | HUD 元件完成，尚未實際接入戰場 `main.gd` | `a285730` |
| A17-ARCH-007 多國語言 | 工具完成／內容待遷移 | 四語 key 一致性檢查已加入 Architecture Guard；名將整備提示已先改用穩定 message ID | `6e0a5e5`、`6470110` |

## 2026-08-03 共用 UI 批次

1. 新增 `menu_option_renderer.gd`，統一正常、選取與停用選項樣式。
2. 新增 `status_badge_renderer.gd`，統一主戰、後備與營地徽章配色及尺寸。
3. `HeroConfigScreen.visible_rows()` 改為委派 `TextLayout`。
4. `HeroReplaceScreen` 改用 `TextLayout` 與 `MenuOptionRenderer` 契約。
5. 新增 `shared_ui_components_test.gd`，檢查樣式差異、狀態徽章、可視範圍與替換列不重疊。
6. 使用者已確認本批可正常 F5 啟動。

## 2026-08-03 畫面／輸入路由批次

1. 新增 `screen_router.gd`：集中目前畫面、上一畫面、Context 與返回歷史。
2. 新增 `input_router.gd`：統一方向鍵、WASD、Enter、Space、Esc、E、Tab、P，並提供 Modal 輸入鎖。
3. 新增 `core_routing_test.gd`：驗證畫面生命週期、返回、未知畫面拒絕、按鍵與輸入鎖。
4. 使用者已確認本批可正常 F5 啟動。

## 2026-08-03 名將整備輸入協調批次

1. 新增 `hero_roster_input_controller.gd`：接收穩定 action，處理主畫面、位置選擇與滿額替換。
2. 新增 `hero_roster_input_controller_test.gd`：驗證游標、位置選擇、滿額替換與 Esc 分層關閉。
3. 使用者已確認本批可正常 F5 啟動。

## 2026-08-03 名將編成事件套用批次

1. 新增 `hero_roster_event_applier.gd`：將輸入事件轉成正式編成修改。
2. 統一呼叫 `HeroRosterManager.move()`、`replace_active()`、`replace_reserve()`。
3. 加入替換索引資料過期防護與編成正規化。
4. 新增 `hero_roster_event_applier_test.gd`。
5. 使用者已確認本批可正常 F5 啟動。

## 2026-08-03 名將整備完整協調批次

1. 新增 `hero_roster_legacy_bridge.gd`：
   - 集中 `main.gd` 舊暫存欄位與 `HeroRosterSession` 的雙向同步。
   - 保留過渡相容性，不處理規則、音效、畫面或存檔。
2. 新增 `hero_roster_flow_coordinator.gd`：
   - 將實體鍵轉 action、Session 更新、事件判斷與正式編成套用串成單一步驟。
   - 回傳穩定 `ui_command`、更新後舊欄位快照及編成結果。
3. 新增 `hero_roster_feedback.gd`：
   - 將流程結果轉成穩定音效 ID、message ID 與參數。
   - 不直接產生玩家可見中文，預留四語翻譯接入。
4. 新增 `hero_roster_flow_coordinator_test.gd`：
   - 驗證舊欄位往返不遺失。
   - 驗證後備移至營地的完整流程。
   - 驗證主戰滿額替換及舊名將優先進後備。
   - 驗證 Esc 依位置彈窗、主畫面順序關閉。
   - 驗證提示音效與穩定 message ID 契約。

### 本批驗證

- 存檔格式：未變更。
- 戰鬥規則：未變更。
- 玩家可見文字：未新增；只新增穩定 message ID。
- `main.gd`：尚未改動，現有操作行為不應改變。
- Godot 本機 F5：待使用者驗證。
- 下一階段：以單一小型接線提交，將 `handle_hero_config_key()`、位置選擇與替換輸入委派給 FlowCoordinator，保留原本顯示文字與音效行為。
