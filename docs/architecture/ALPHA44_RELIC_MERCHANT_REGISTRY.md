# Alpha.44 遺物與行商資料驅動整理

## 目標

將遺物定義、商人類型、商品目錄、價格曲線與出現間隔從零散條件逐步集中，保留舊流程相容性，不在本版一次重寫商店 UI 或既有購買函式。

## 新增模組

- `scripts/systems/relic/relic_content_registry.gd`
  - 將舊遺物資料補齊為統一格式。
  - 統一 `id`、`rarity`、`max_level`、`effect_id`、`sources`、`event_hooks`。
  - 驗證稀有度、必要欄位與素材路徑。
- `scripts/systems/merchant/merchant_content_registry.gd`
  - 集中一般行商、鐵匠、古董商、神秘商人的設定。
  - 集中每場拜訪次數、出現間隔、刷新成本與章節價格成長。
- `scripts/systems/merchant/merchant_product_registry.gd`
  - 由遺物與裝備資料建立商品目錄。
  - 驗證商品 ID、類型、價格與重複項目。
  - 支援依商人、章節與標籤篩選商品。
- `scripts/systems/merchant/alpha44_relic_merchant_runtime.gd`
  - 將 Registry 非侵入式接入現有資料。
  - 透過 `GameEvents` 發送遺物取得與商人開啟事件。
  - 商人離場後統一下一次生成間隔。

## 統一遺物格式

```gdscript
{
    "id": "warbanner",
    "name": "義軍旗",
    "rarity": "rare",
    "max_level": 3,
    "effect_id": "warbanner",
    "sources": ["battle", "merchant"],
    "event_hooks": ["on_acquired", "on_boss_spawned"]
}
```

## 統一商品格式

```gdscript
{
    "id": "iron_blade",
    "type": "equipment",
    "name": "環首刀",
    "rarity": "common",
    "base_price": 85,
    "chapter_min": 1,
    "merchant_tags": ["general", "weapon"]
}
```

## 後續遷移

1. 將商店實際抽選改為呼叫 `eligible_products()`。
2. 將購買價格改為統一讀取 `merchant_price_multiplier()`。
3. 將既有 `has_relic()` 條件逐步搬到遺物效果路由器。
4. 將章節分支、陣營關係與特殊交易條件接入商品篩選 context。
5. 商店 UI 只接收商品 ViewModel，不直接讀寫戰鬥容器。

## 相容策略

Alpha.44 仍保留舊商店與遺物作用方式。Registry 先作為資料契約、驗證器與查詢服務，避免一次替換造成購買、存檔或掉落流程中斷。
