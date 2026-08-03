# 招賢館統一編成接線指南

本文件說明如何將現有 `choose_hero_encounter()` 與 `choose_replacement()` 逐步改為共用名將編成規則，避免招賢館與名將整備出現不同的欄位上限、替換去向與重複名將問題。

## 已完成模組

```text
scripts/systems/hero/recruitment_placement_service.gd
scripts/systems/hero/recruitment_roster_coordinator.gd
scripts/systems/hero/hero_roster_event_applier.gd
scripts/systems/hero/hero_roster_manager.gd
```

## 建議接線順序

1. 玩家在招賢館選擇邀請名將時，呼叫 `RecruitmentRosterCoordinator.begin()`。
2. 以回傳的 `target_index` 開啟既有位置選擇畫面。
3. 玩家確認主戰、後備或營地後，呼叫 `choose_target()`。
4. 回傳 `open_replacement` 時，沿用既有替換畫面並保存 `mode`。
5. 玩家選定被替換名將後，呼叫 `confirm_replacement()`。
6. 套用回傳的 `initialization`：
   - 設為已結識。
   - 初始化技能等級。
   - 初始化羈絆等級。
   - 依最終位置設定或移除冷卻。
7. 完成後再由 `main.gd` 處理遭遇冷卻、訊息、音效與返回戰場。

## 必須保留的舊行為

- 已在主戰或後備的舊識再次相逢時，仍走名將成長，而不是重複加入。
- 新名將進主戰時可依遊戲設計決定立即可用或完整冷卻；此規則留在 `main.gd`，不寫入編成規則層。
- 取消邀請時不得修改主戰、後備或營地陣列。
- 主戰滿額替換後，舊名將優先進後備；後備滿額才進營地。
- 後備滿額替換後，舊名將回營地。
- 任一名將同一時間只能存在於一個位置。

## 驗收流程

```text
招賢館遇到新名將
→ 選主戰且有空位
→ 選後備且有空位
→ 選營地
→ 主戰滿額替換
→ 後備滿額替換
→ 取消位置選擇
→ 取消替換
→ 舊識重逢升級
→ 返回戰場後名將技能與羈絆資料完整
```

## 本批限制

本批建立協調器、效果計畫與測試契約，尚未直接改動巨大 `scripts/main.gd`。正式接線時應採單一可驗證提交，且必須實測招賢館與名將整備兩條流程，不得只以 F5 啟動作為功能驗收。
