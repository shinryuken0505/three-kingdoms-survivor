# V2.0.0-alpha.17 重構進度紀錄

本文件補充 `ALPHA17_BACKLOG.md` 的實際提交與驗證狀態。Backlog 保留需求與驗收條件；本文件只記錄實際完成度，避免把「建立基礎模組」誤標成「功能已完成」。

## 狀態定義

- **已提交／待本機驗證**：程式與測試已提交，尚待 Godot F5 驗證。
- **本機啟動通過**：使用者確認 F5 可正常啟動，但不代表所有功能情境均已驗收。
- **功能驗收通過**：指定操作流程與畫面均已測試。

## 目前進度

| 項目 | 狀態 | 實際完成內容 | 尚待處理 |
|---|---|---|---|
| A17-ARCH-004 名將整備拆分 | 架構完成／舊流程待替換 | Manager、Controller、ViewModel、Session、Input Controller、Event Applier、Flow Coordinator、Main Adapter、Effects、Feedback 與測試已建立 | `main.gd` 三段舊輸入與 renderer 尚未正式移除 |
| A17-ARCH-005 共用 UI 元件 | 基礎完成 | Panel、Modal、文字排版、選項與狀態徽章已建立，位置與替換畫面 layout 已共用 | 舊畫面繪製仍有部分硬編碼 |
| A17-UI-001 章間排版 | 模型與輸入完成／待畫面接線 | 安全區、左右欄、三個資訊區、四按鈕列、滑鼠命中與輸入 Controller 已完成 | `draw_intermission_screen()` 尚未正式委派給新模型 |
| A17-HERO-002 招賢館統一編成 | 協調器完成／待主流程接線 | Recruitment Placement Service 與 Recruitment Roster Coordinator 已建立 | 招賢館舊流程尚待委派 |
| A17-ARCH-006 畫面與輸入路由 | 註冊與命令層完成／待主流程接管 | ScreenRouter、InputRouter、ScreenRouteRegistry、UIInputCommand 與路由檢查已完成 | `main.gd` 仍使用既有分派 |
| A17-ARCH-009 狀態效果系統 | 基礎完成並已掛載 HUD | 定義、Manager、Adapter、Presenter、Renderer、Painter、Hud 與場景子節點已完成 | 舊 HUD 單一文字仍存在於 `main.gd`，目前由新層遮蔽避免重疊 |
| A17-HUD-003 負面狀態圖示 | 已接入／待功能驗收 | `main.tscn` 已掛載 StatusEffectHudLayer，主角頭上與右側 HUD 可同時繪製 | 待實際狀態效果與 Tooltip 驗收 |
| A17-ARCH-007 多國語言 | 工具完成／內容持續遷移 | 四語 key 一致性檢查已加入 Guard；名將整備提示有穩定 message ID 與 Presenter | 既有 `main.gd` 玩家文字尚未全面遷移 |

## 已完成批次摘要

1. 名將編成規則、Session、輸入、事件套用、主流程 Adapter、Effects 與 Feedback 完整拆分。
2. 招賢館位置選擇與編成協調器建立。
3. 共用 Panel、Modal、TextLayout、選項與狀態徽章建立。
4. 畫面 ID、ScreenRouter、InputRouter、RouteRegistry 與 UIInputCommand 建立。
5. 章間 Layout、ScreenModel 與 InputController 建立。
6. 狀態效果定義、舊欄位 Adapter、HUD Presenter、Renderer、Painter 與正式場景掛載完成。
7. 四語翻譯 key 檢查、狀態一致性檢查、路由檢查與 Alpha.17 整合檢查加入 Architecture Guard。
8. 新增 `alpha17_integration_smoke_test.gd` 與單次人工驗收清單。

## 2026-08-03 單次整合驗收批次

新增：

- `scripts/ui/screens/intermission_input_controller.gd`
- `tests/intermission_input_controller_test.gd`
- `tests/alpha17_integration_smoke_test.gd`
- `tools/check_alpha17_integration.py`
- `docs/roadmap/ALPHA17_FINAL_TEST_PLAN.md`

更新：

- `.github/workflows/architecture-guard.yml`
- 本進度紀錄

整合檢查涵蓋：

- `main.tscn` 是否掛載狀態 HUD。
- 所有 ScreenIds 是否有路由。
- 章間模型與輸入命令契約。
- 舊戰鬥狀態欄位是否能產生 HUD 資料。
- 名將整備確認鍵是否能開啟位置選擇與產生回饋。

## 驗證狀態

- 此前各基礎批次：使用者已多次確認 F5 正常啟動。
- 本次整合批次：尚待使用者最後一次統一拉取與測試。
- GitHub Architecture Guard：已加入所有靜態檢查；最新 Commit 的實際 CI 結果仍以 GitHub 回傳為準。
- Godot headless 測試：測試檔已建立，但助理端未宣稱執行通過。

## 重要限制

目前尚未安全替換巨大的 `scripts/main.gd` 三段名將輸入、招賢館輸入與章間 renderer。這些新模組已具備接線契約與測試，但正式移除舊邏輯仍應採單一、可回退的主檔修改，不能把「模組完成」誤記為「玩家流程已換新」。
