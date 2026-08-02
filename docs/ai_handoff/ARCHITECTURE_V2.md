# V2 架構藍圖（AI／工程師共用）

本文件定義專案接下來的目標架構。重構採「可玩版本優先、一次只搬一個模組」原則，不做一次性全面改寫。

## 1. 技術與命名決策

- 程式識別字、檔名、資料欄位、翻譯 key：英文。
- 文件、設計說明與必要註解：繁體中文。
- 玩家可見文字：一律透過翻譯 key，不以中文文字作為流程判斷條件。
- 穩定 ID 與顯示文字分離。例如 `hero_id = "zhangfei"`，顯示名稱使用 `hero.zhangfei.name`。
- 畫面狀態集中在 `scripts/core/screen_ids.gd`，不得在新功能中新增散落的裸字串。

## 2. 目標目錄

```text
scripts/
  core/                 # 穩定共用基礎：畫面 ID、本地化、事件、設定
  data/                 # 靜態資料存取與資料驗證
  systems/
    combat/             # 戰鬥、傷害、投射物、Boss
    hero/               # 名將編成、成長、羈絆
    world/              # 章節、事件、路線、地圖規則
    save/               # 存檔、遷移、檢查點
    audio/              # BGM、SFX、音訊策略
  ui/
    screens/            # 完整畫面 renderer/controller
    components/         # 可重用卡片、按鈕、狀態徽章、彈窗
  main.gd               # 暫時保留為 Composition Root，逐步縮小
localization/           # zh_TW、zh_CN、en、ja 翻譯檔
assets/                 # 純素材；玩法資料不可依賴造型素材
```

## 3. 分層責任

### `main.gd`

只應逐步保留：

1. 建立服務與系統。
2. 接收 Godot lifecycle。
3. 將輸入委派給目前畫面。
4. 將更新委派給戰鬥／世界系統。
5. 將繪製委派給 UI renderer。

禁止繼續新增大型資料表、完整畫面與獨立玩法演算法。

### `core`

不可依賴特定章節或角色。所有系統皆可使用：

- `ScreenIds`
- `LocalizationService`
- 後續：`GameEvents`、`InputRouter`、`GameSettings`

### `systems`

處理規則與狀態，不直接畫 UI。回傳結果物件或事件，例如：

```gdscript
{
  "ok": true,
  "event": "hero_moved",
  "hero_id": "zhangfei",
  "from": "camp",
  "to": "reserve"
}
```

### `ui`

只讀取 view model 並繪製，不修改核心規則。畫面操作必須使用 ID，不得比較翻譯後文字。

## 4. 多國語言契約

支援語系：

- `zh_TW`：主要內容與 fallback
- `zh_CN`
- `en`
- `ja`

Key 命名：

```text
ui.<screen>.<element>
hero.<hero_id>.name
hero.<hero_id>.title
hero.<hero_id>.active
hero.<hero_id>.passive
chapter.<chapter_id>.title
chapter.<chapter_id>.intro
item.<item_id>.name
item.<item_id>.desc
message.<domain>.<event>
```

參數採 `{name}` 格式，統一透過 `LocalizationService.format()` 代換。

新增玩家可見內容時，Definition of Done 必須包含四語 key。未完成翻譯時可暫用繁中 fallback，但不得把 fallback 當作資料 ID。

## 5. 資料契約

所有可擴充內容使用穩定 ID：

- 英文小寫 snake_case。
- ID 存入存檔；顯示文字不存入存檔。
- 外觀 skin 與玩法資料分離；skin 不影響能力、掉落、羈絆、成就與存檔有效性。
- 新增欄位必須提供預設值與舊存檔遷移策略。

## 6. 畫面契約

新增或修改畫面時，必須同時完成：

1. `ScreenIds` 宣告。
2. 輸入路由。
3. 繪製路由。
4. 進入與離開函式。
5. Enter／Space／Esc；滑鼠支援列入後續 UI 元件化。
6. 1280×720 基準與 16:9 縮放檢查。
7. Modal 輸入鎖，避免同一按鍵穿透兩層畫面。

## 7. 重構順序

每階段通過 Godot Check 與本機 F5 後才進下一階段：

1. **基礎層**：畫面 ID、本地化服務、架構文件。
2. **名將整備**：輸入、規則、renderer 分離。
3. **結果與章回 UI**：結算、章回開場、替換彈窗。
4. **戰鬥 HUD**：只搬繪製與 view model，不改傷害規則。
5. **存檔服務**：序列化、遷移、備份。
6. **戰鬥系統**：Boss、投射物、技能依序拆分。
7. **靜態資料**：將 `game_data.gd` 逐域拆分並加入資料驗證。

## 8. AI 修改規則

AI 每次工作前必須回答：

- 修改哪一層？
- 會改哪些檔案？
- 有無存檔格式變更？
- 有無新增玩家可見文字？翻譯 key 是否齊全？
- 驗收方式是什麼？

AI 不得：

- 用正規表示式跨越不確定的大型函式區塊而不驗證結果。
- 建立 workflow patch 後聲稱主檔已修改，卻未檢查生成 commit。
- 以玩家可見中文作為 match／if 的唯一條件。
- 同一輪同時搬移輸入、規則、存檔與 UI。
