# Alpha.45 章節流程、歷史分支與特殊商人

## 目標

將章節開場、戰鬥、事件、精英、Boss、戰利品、結算、分支、整備、自動存檔與完成建立為單一流程狀態，並把歷史分支條件與效果集中管理。

## 新增檔案

- `scripts/systems/chapter/chapter_branch_registry.gd`
- `scripts/systems/chapter/alpha45_chapter_branch_runtime.gd`
- `scripts/systems/merchant/special_trade_registry.gd`

## 章節階段

`intro -> combat -> event -> elite -> boss -> loot -> result -> branch -> formation -> autosave -> complete`

Runtime 只允許合法轉換或有限度的安全跳階；異常逆向與跨度過大的轉換會警告並拒絕。

## 分支條件

目前支援：

- 劇情旗標
- 已結識名將
- 已擊敗 Boss
- 已持有遺物

## 分支效果

目前可提供：

- 下一章 ID
- Boss 版本
- 援軍
- 指定商人
- 名將出現權重
- 設定劇情旗標

## 特殊交易

特殊商人交易已使用 Registry 定義，可使用銅錢、遺物數量或生命上限比例作為成本，並支援每章限購。

## 相容策略

Alpha.45 暫不全面替換 `main.gd` 的章節結算函式，而是以 Autoload 監控既有畫面與 Boss 狀態，建立單一流程快照並阻止已提交的 Boss 與結算再次觸發。正式接管下一章跳轉與分支 UI 應在後續版本逐步完成。

## 驗證重點

- Boss 死亡只提交一次。
- 章節結算只提交一次。
- 分支條件依名將、Boss、遺物與劇情旗標正確判定。
- 分支商人能覆寫下一次商人類型。
- 武將整備後只執行一次自動存檔。
