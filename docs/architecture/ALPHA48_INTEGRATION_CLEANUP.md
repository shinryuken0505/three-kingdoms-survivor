# Alpha.48 Runtime 整合與技術清債

## 目標

Alpha.48 不新增大型玩法，先把 Alpha.36～47 疊加出的 Runtime、版本資訊與存檔橋接做收斂，讓後續主角、名將、遺物、行商與章節分支可以在較穩定的底層上繼續擴充。

## 已完成

### 1. Autoload 收斂

`project.godot` 由原本十多個 Alpha Runtime Autoload 收斂為：

- `GameEvents`
- `Alpha48RuntimeCoordinator`

`Alpha48RuntimeCoordinator` 啟動時會將舊 Runtime 以原名稱掛回 `/root`，例如：

- `/root/Alpha45ChapterBranchFlow`
- `/root/Alpha46BranchResultUI`
- `/root/Alpha47BranchGameplayEffects`

因此舊跨模組 NodePath 不必在本版全部重寫。

### 2. 版本單一化

`project.godot` 與 `scripts/main.gd` 的版本均同步為：

`V2.0.0-alpha.48`

CI 會檢查兩者是否一致，避免再次出現專案標題已升版、主程式仍停在舊版本的情況。

### 3. Runtime 存檔橋接

Alpha.48 會將下列資料放入：

`save_data.run_save.alpha48_integration`

目前保存：

- Alpha.46 歷史分支選擇
- 指定下一章
- 援軍
- Boss Variant
- 名將相遇加權
- 特殊商人覆寫
- Alpha.47 特殊交易使用紀錄
- Alpha.47 裝備重鑄後 effects

讀取存檔時會把上述資料重新套回 Runtime，降低分支或交易效果在讀檔後消失的機率。

### 4. Runtime 健康檢查

協調器會檢查必要 Runtime 是否成功建立，並檢查主場景是否仍提供核心欄位：

- player
- save_data
- chapter_manager
- relic_defs
- equipment_defs
- merchant_defs

檢查失敗先用 warning 呈現，不在 Alpha.48 直接中止遊戲。

### 5. 靜態回歸 CI

新增 `.github/workflows/alpha48_integration_regression.yml`，目前會檢查：

- project.godot 版本
- main.gd GAME_VERSION
- 舊 Autoload 是否仍殘留
- 協調器是否註冊所有舊 Runtime
- Registry 核心檔案是否存在

並可自動修正 main.gd 從 Alpha.37 遺留的版本常數。

## 仍保留的技術債

Alpha.48 是「收斂入口」，不是一次把舊系統全部重寫。以下仍需要後續逐步遷移：

1. Alpha.42 主角 attack_mode 尚未完全接管 `perform_auto_attack()`。
2. Alpha.42 upgrade_weights 尚未完全接管 `open_levelup()` 的抽選。
3. Alpha.39／40 仍有部分依名將 ID 的 `match`，尚未全面改為技能處理器 Registry。
4. Alpha.44 商店 Registry 已存在，但舊 `open_shop()` 還保留原始價格計算。
5. Alpha.45～47 章節狀態機仍以 Runtime 監控主流程，ChapterManager 尚未完全成為唯一真相來源。
6. `main.gd` 仍過大，後續需要按 player / hero / relic / merchant / chapter 分批搬移。

## 後續原則

- 不再新增新的「每版一個 Autoload」。
- 新功能優先放入既有 Registry / Service / Manager。
- 必須新增 Runtime 時，由 `Alpha48RuntimeCoordinator` 統一管理。
- 新增內容不得直接在多處用人物、遺物或章節 ID 寫死判斷。
- 章節與存檔資料優先使用明確版本與 migration。

## 建議下一階段

Alpha.49 應開始做第一批真正核心遷移：

1. PlayerCombatService 接管主角普通攻擊。
2. PlayerUpgradeService 接管升級抽選與權重。
3. MerchantPricingService 接管商店價格。
4. HeroSkillHandlerRegistry 開始替代 Alpha.39／40 人物 `match`。
5. ChapterManager 吸收 Alpha.45～47 已驗證的章節狀態。

完成後再進入大量新增主角、名將、遺物與章節內容會更安全。
