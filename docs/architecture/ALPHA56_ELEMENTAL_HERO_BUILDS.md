# Alpha.56 名將元素定位與 Build 聯動

Alpha.56 將名將的元素／異常定位從遺物系統抽離，集中到 `HeroElementalBuildService`。

## 元素 Profile

- 周瑜：火焰／燃燒／範圍反應
- 張角：雷電／感電／連鎖反應（目前仍缺 Alpha.43 正式 HeroContentRegistry 條目）
- 甄姬：冰霜／緩速／冰封控場
- 孫尚香：火焰／燃燒／遠程多段
- 華佗：治療／淨化／護盾
- 諸葛亮：策略／緩速／控制與元素反應輔助
- 貂蟬：魅惑／混亂／弱化控制

## 架構責任

- `HeroContentRegistry`：正式名將內容資料與可搜尋的 element/status_tags/synergy_tags。
- `HeroElementalBuildService`：戰鬥來源轉異常狀態、Runtime tags、華佗淨化。
- `StatusEffectService`：異常狀態本體。
- `ElementalSynergyService`：異常狀態間的元素反應。
- `RelicStatusSynergyService`：遺物修改異常與元素反應，不再作為名將元素來源的主要責任者。

## Alpha.40 整合

舊 `apply_control()` 已改走主場景 `apply_enemy_status()`，因此 slow/stun/confuse/burn/armor_break 可以共用 Alpha.53 之後的狀態生命週期。

周瑜加入 `red_cliff_flame -> zhouyu` Handler 與技能進化；華佗施放進化效果時會嘗試移除玩家負面狀態。

## 已知資料缺口

`zhangjiao` 已存在章節候選／戰鬥來源與元素 Profile，但 Alpha.43 的 `HeroContentRegistry.HEROES` 尚無正式條目。Alpha.56 不虛構立繪或技能資料，後續應依實際 GameData／素材補齊 canonical registry definition。
