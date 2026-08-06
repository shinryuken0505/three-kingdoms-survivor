# Alpha.43 名將資料驅動規格

## 單一真相來源

名將擴充資料集中於：

`res://scripts/systems/hero/hero_content_registry.gd`

新增名將至少需要：

- `id`
- `name`
- `faction`
- `active_skill`
- `reserve_passive`
- `growth_profile`
- `portrait`
- `sprite`

## ID 規則

程式內標準 ID 使用小寫英文字母；既有緊密格式如 `guanyu` 可保留。帶底線素材名稱由 Alias 轉換，例如：

- `guan_yu` → `guanyu`
- `sun_shang_xiang` → `sunshangxiang`
- `cai_wen_ji` → `caiwenji`

陣容、已知名將與後續存檔遷移均應先通過 `canonical_id()`。

## 素材驗證

Alpha.43 啟動時檢查：

1. 必要欄位是否齊全。
2. 立繪與戰鬥圖路徑是否存在。
3. 同一立繪路徑是否被多位名將共用。
4. 女性名將蔡文姬、貂蟬、孫尚香、甄姬、王異與呂玲綺均使用獨立明確路徑。

素材檔案內容是否真為正確人物仍需人工視覺驗收；檔名與路徑檢查無法辨識畫面中人物身分。

## 後續遷移

Alpha.39 與 Alpha.40 的人物 `match` 暫時保留以維持相容。下一輪應將技能 Profile 改為按 `growth_profile` 與 `active_skill` 查表，逐步移除人物硬編碼。
