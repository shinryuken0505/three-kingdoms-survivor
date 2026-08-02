# 資料契約

## 原則

- ID 是穩定 API，不可任意改名。
- 顯示名稱可改，ID 不可直接改，除非同時提供存檔遷移。
- 資料讀取後應使用 `.get(key, default)`，避免舊存檔缺欄位崩潰。
- 新增欄位必須有預設值。

## 核心資料來源

### `scripts/game_data.gd`

包含：

- identities
- heroes
- relics
- equipment
- skills
- bonds
- skins

新增武將時至少確認：

- 唯一 ID
- 顯示名稱
- 陣營
- 主動技能
- 被動效果
- 肖像路徑
- 像素素材路徑
- 羈絆引用
- 章節／歷史權重是否合理

### `scripts/chapter_manager.gd`

章節資料不可假設固定數量。取得最後一章時，必須由章節陣列長度動態判斷。

每章可能包含：

- 章名與副標
- 地圖主題
- Boss
- 支援 Boss
- 時間與難度參數
- 歷史事件

### `scripts/history_event_data.gd`

事件選項應包括：

- 顯示文字
- 條件
- 結果
- 世界旗標
- 即時效果
- 後續回收方向

重大旗標必須至少在一個後續可玩內容中被讀取。

## 存檔

目前：

- `SAVE_FORMAT_VERSION = 3`
- `CHECKPOINT_VERSION = 3`

修改存檔結構時：

1. 增加版本。
2. 在 `normalize_save_document()` 中補遷移。
3. 保留舊欄位兼容至少一個主要版本。
4. 測試正常存檔、備份存檔與損壞存檔。

## 世界旗標建議格式

```gdscript
world_flags = {
    "helped_liubei": true,
    "saved_zhanghe": true,
    "angered_lvbu": 2,
    "allied_with_wu": true
}
```

布林旗標用於是否發生；整數用於程度或次數。不要把顯示文字當作邏輯 ID。
