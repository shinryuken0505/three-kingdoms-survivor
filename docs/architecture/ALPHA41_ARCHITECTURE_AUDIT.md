# Alpha.41 架構體檢與擴充準備

## 結論

目前專案仍可繼續開發，但 `scripts/main.gd` 已同時承擔遊戲流程、戰鬥、UI、存檔、內容資料、商店、名將與章節事件，擴充風險偏高。Alpha.41 採用 **adapter-first**：先建立穩定契約與驗證層，再逐版搬移，不直接一次重寫。

## 高風險區域

1. `main.gd` 為大型集中式腳本，修改容易跨系統連鎖影響。
2. Alpha.36～40 以多個 Autoload 疊加功能，生命週期與寫入順序需要統一。
3. 名將、主角、遺物仍存在資料與行為分散於多處 `match`／條件判斷的情況。
4. 章節進度依賴多個布林值與畫面狀態，缺少單一狀態機真相來源。
5. 存檔同時保存舊欄位與新欄位，需持續做版本遷移與資料清理。
6. UI 直接讀寫戰鬥容器，後續改版容易與核心邏輯互相綁死。

## Alpha.41 新增基礎

- `scripts/core/game_event_bus.gd`
  - 提供主角、名將、遺物、行商、Boss、章節與存檔事件。
  - 讓 UI、音效、成就、存檔逐步改為訂閱事件。
- `scripts/core/content_registry.gd`
  - 定義 player、hero、relic、merchant、chapter 的必要欄位與統一 ID。
  - 新內容先通過驗證，再註冊進遊戲。
- `scripts/systems/chapter/chapter_flow_contract.gd`
  - 統一章節階段與合法轉換。
- `scripts/core/alpha41_architecture_guard.gd`
  - 啟動時非侵入式檢查目前主場景必要屬性與方法。

## 建議目錄責任

```text
scripts/core/
  game_event_bus.gd
  content_registry.gd
  save_manager.gd              # 後續遷移
  run_state.gd                 # 後續遷移

scripts/systems/player/
  player_registry.gd
  player_combat.gd
  player_progression.gd

scripts/systems/hero/
  hero_registry.gd
  hero_combat.gd
  hero_progression.gd
  hero_roster.gd

scripts/systems/relic/
  relic_registry.gd
  relic_effect_router.gd
  relic_reward_service.gd

scripts/systems/merchant/
  merchant_manager.gd
  merchant_inventory.gd
  merchant_pricing.gd

scripts/systems/chapter/
  chapter_flow_contract.gd
  chapter_flow_controller.gd
  chapter_branch_resolver.gd
```

## 內容擴充契約

### 主角

必要欄位：`id`、`name`、`base_stats`、`weapon`、`starting_skills`、`portrait`、`sprite`。

### 名將

必要欄位：`id`、`name`、`faction`、`active_skill`、`reserve_passive`、`growth_profile`、`portrait`、`sprite`。

### 遺物

必要欄位：`id`、`name`、`rarity`、`max_level`、`effect_id`。效果行為後續改由事件路由器處理，避免在主戰鬥流程累積 `has_relic()` 條件。

### 行商

必要欄位：`id`、`name`、`inventory_pool`、`pricing_profile`、`spawn_rules`。出現規則、價格與商品池需分離。

### 章節

必要欄位：`id`、`name`、`index`、`phases`、`branches`。分支條件與下一章解析不得直接寫在 UI 中。

## 遷移順序

1. Alpha.41：建立契約、事件匯流排、架構檢查與文件。
2. Alpha.42：用 ContentRegistry 新增主角種類，驗證資料驅動流程。
3. Alpha.43：名將註冊、技能與成長 Profile 遷移。
4. Alpha.44：遺物效果路由與行商庫存／價格拆分。
5. Alpha.45：章節狀態機與歷史分支正式接管。
6. 完成以上遷移後，再逐步縮減 Alpha.36～40 Autoload，避免雙重寫入。

## 禁止事項

- 不再新增直接寫死於 `main.gd` 的大型內容表。
- 不以角色中文名稱作為永久 ID。
- UI 不直接決定章節分支、商品價格或戰鬥傷害。
- 不新增沒有存檔版本遷移方案的永久狀態。
- 不在未確認舊邏輯停用前，同時啟用兩套相同系統。
