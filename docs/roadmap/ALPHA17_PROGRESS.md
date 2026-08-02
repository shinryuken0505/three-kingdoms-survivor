# V2.0.0-alpha.17 重構進度紀錄

本文件補充 `ALPHA17_BACKLOG.md` 的實際提交與驗證狀態。Backlog 保留需求與驗收條件；本文件只記錄已完成批次，避免把「建立基礎模組」誤標成「功能已完成」。

## 狀態定義

- **已提交／待本機驗證**：程式與測試已提交，尚待 Godot F5 驗證。
- **本機啟動通過**：使用者確認 F5 可正常啟動，但不代表所有功能情境均已驗收。
- **功能驗收通過**：指定操作流程與畫面均已測試。

## 目前進度

| 項目 | 狀態 | 內容 | 主要 Commit |
|---|---|---|---|
| A17-ARCH-004 名將整備拆分 | 進行中／多批本機啟動通過 | Manager、Controller、ViewModel、Session 與三個畫面排版模型已建立；`main.gd` 完整 renderer 尚未移除 | `015b2f6`、`4fdf597`、`de6bef8`、`55462f6` |
| A17-ARCH-005 共用 UI 元件 | 已提交／待本批驗證 | Panel、Modal、文字排版、選項按鈕、狀態徽章已建立；名將位置、替換與章間 layout 已開始共用 | `7c1665c`、`20ea766`、`e03f561`、`e586c82`、`6e93964` |
| A17-UI-001 章間排版 | 進行中 | 安全區、左右欄、左側三區塊與五按鈕列 layout 已完成；舊 `main.gd` renderer 尚待正式接線 | `d03e4e7`、`6fea443`、`20ea766` |
| A17-HERO-002 招賢館統一編成 | 基礎完成／尚未接線 | 招募位置服務與名將編成共用規則已建立；招賢館現有流程尚待接入 | `becf615` |
| A17-ARCH-009 狀態效果系統 | 基礎完成／尚未接線 | 定義、Manager、舊欄位 Adapter、HUD layout 與程式化 icon 已完成 | `5c7dad9`、`a285730` |
| A17-HUD-003 負面狀態圖示 | 進行中 | HUD 元件完成，尚未實際接入戰場 `main.gd` | `a285730` |
| A17-ARCH-007 多國語言 | 工具完成／內容待遷移 | 四語 key 一致性檢查已加入 Architecture Guard | `6e0a5e5` |

## 2026-08-03 本批內容

1. 新增 `menu_option_renderer.gd`，統一正常、選取與停用選項樣式。
2. 新增 `status_badge_renderer.gd`，統一主戰、後備與營地徽章配色及尺寸。
3. `HeroConfigScreen.visible_rows()` 改為委派 `TextLayout`。
4. `HeroReplaceScreen` 改用 `TextLayout` 與 `MenuOptionRenderer` 契約。
5. 新增 `shared_ui_components_test.gd`，檢查樣式差異、狀態徽章、可視範圍與替換列不重疊。

### 本批驗證

- 存檔格式：未變更。
- 戰鬥規則：未變更。
- 玩家可見文字：未新增。
- Godot 本機 F5：待使用者驗證。
- 功能驗收：待後續 renderer 正式接線後進行。
