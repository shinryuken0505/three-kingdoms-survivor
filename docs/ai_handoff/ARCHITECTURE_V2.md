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
  core/                 # 畫面 ID、本地化、事件、設定、輸入與畫面路由
  data/                 # 靜態資料定義與驗證
  systems/
    combat/             # 戰鬥、傷害、狀態效果、投射物、Boss
    hero/               # 名將編成、成長、羈絆
    world/              # 章節、事件、路線、地圖規則
    save/               # 存檔、遷移、檢查點
    audio/              # BGM、SFX、音訊策略
  ui/
    screens/            # 完整畫面 renderer/controller
    components/         # 卡片、按鈕、狀態徽章、彈窗、文字排版
  main.gd               # Composition Root，逐步縮小
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
- `ScreenRouter`
- `InputRouter`
- 後續：`GameEvents`、`GameSettings`

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

只讀取 ViewModel 並繪製，不修改核心規則。畫面操作必須使用 ID，不得比較翻譯後文字。

## 4. 畫面與輸入契約

每個完整畫面應逐步具備一致介面：

```gdscript
enter(context: Dictionary) -> void
exit() -> void
handle_input(event: InputEvent) -> Dictionary
update(delta: float) -> void
draw(canvas: CanvasItem, view_model: Dictionary) -> void
```

新增或修改畫面時，必須同時完成：

1. `ScreenIds` 宣告。
2. 輸入路由。
3. 繪製路由。
4. 進入與離開函式。
5. Enter／Space／Esc 一致。
6. Modal 輸入鎖，避免同一按鍵穿透兩層畫面。
7. 1280×720 基準與 16:9 縮放檢查。
8. 長英文與日文文字版面檢查。

AI 不得只新增輸入狀態卻未新增對應繪製路由，也不得只新增 renderer 卻沒有進入／離開流程。

## 5. UI 元件契約

完整畫面放在：

```text
scripts/ui/screens/
```

可重用元件放在：

```text
scripts/ui/components/
```

優先共用：

- Panel 與邊框
- 標題與副標題
- 選項按鈕與高亮
- Modal 背景
- 狀態徽章
- 底部操作提示
- 文字換行、縮排與欄位排版

禁止每個畫面自行複製一套相同 Panel、按鈕與 Modal 程式。

## 6. 多國語言契約

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
status.<status_id>.name
status.<status_id>.desc
message.<domain>.<event>
```

參數採 `{name}` 格式，統一透過 `LocalizationService.format()` 代換。

新增玩家可見內容時，Definition of Done 必須包含四語 key。未完成翻譯時可暫用繁中 fallback，但不得把 fallback 當作資料 ID。

應建立 `tools/check_localization_keys.py`，至少檢查：

- 四個 `.po` 的 key 是否一致。
- 是否有缺少或多餘 key。
- 程式是否引用不存在的 key。
- 缺翻譯時是否能回退繁中，而非顯示空字串。

## 7. 資料契約

所有可擴充內容使用穩定 ID：

- 英文小寫 snake_case。
- ID 存入存檔；顯示文字不存入存檔。
- 外觀 skin 與玩法資料分離；skin 不影響能力、掉落、羈絆、成就與存檔有效性。
- 新增欄位必須提供預設值與舊存檔遷移策略。

靜態資料應逐步拆為：

```text
scripts/data/hero_defs.gd
scripts/data/skill_defs.gd
scripts/data/equipment_defs.gd
scripts/data/relic_defs.gd
scripts/data/bond_defs.gd
scripts/data/chapter_defs.gd
scripts/data/enemy_defs.gd
scripts/data/status_effect_defs.gd
scripts/data/data_validator.gd
```

`data_validator.gd` 至少檢查：

- ID 重複。
- 引用不存在的角色、技能、羈絆、敵人或 Boss。
- 素材路徑不存在。
- 翻譯 key 缺漏。
- 必填欄位缺少。

## 8. 名將系統契約

名將編成統一使用：

```text
scripts/systems/hero/hero_roster_manager.gd
scripts/systems/hero/hero_roster_controller.gd
scripts/systems/hero/hero_roster_session.gd
scripts/systems/hero/hero_roster_view_model.gd
```

職責分工：

- `HeroRosterManager`：正式編成資料與移動／替換規則。
- `HeroRosterController`：把玩家意圖轉成 action，不直接修改正式資料。
- `HeroRosterSession`：只保存游標、候選名將與彈窗等暫存狀態；不得寫入存檔。
- `HeroRosterViewModel`：把 system 資料整理成 UI 可讀格式。

UI 逐步拆為：

```text
scripts/ui/screens/hero_config_screen.gd
scripts/ui/screens/hero_position_picker_screen.gd
scripts/ui/screens/hero_replace_screen.gd
```

規則：

- 主戰、後備、營地只能由 system 層修改。
- 招賢館不得另寫一套編成規則。
- 營地不限容量。
- 同一名將不可同時存在於兩個陣列。
- UI 只送出意圖，system 回傳結果。
- `HeroRosterSession` 僅屬畫面生命週期，離開整備畫面時必須重設。
- 對 session 的純狀態行為至少以 `tests/hero_roster_session_test.gd` 覆蓋。

## 9. 狀態效果系統契約

負面與正面狀態不得以散落的 `player["poisoned"]` 類布林欄位擴充。

統一資料結構：

```gdscript
{
  "id": "poison",
  "duration": 4.5,
  "stacks": 2,
  "source_id": "enemy_tactician",
  "priority": 80
}
```

目標檔案：

```text
scripts/systems/combat/status_effect_manager.gd
scripts/data/status_effect_defs.gd
scripts/ui/components/status_effect_renderer.gd
```

system 負責 duration、stacks、免疫、刷新與移除；UI 只讀 ViewModel 顯示 icon、時間與層數。

## 10. 存檔契約

目標檔案：

```text
scripts/systems/save/save_manager.gd
scripts/systems/save/save_migrator.gd
scripts/systems/save/checkpoint_builder.gd
scripts/systems/save/save_validator.gd
```

規則：

- `SAVE_FORMAT_VERSION` 與 `CHECKPOINT_VERSION` 必須集中管理。
- 新欄位需有預設值。
- 舊存檔遷移需可測試。
- 主檔、暫存檔、備份檔責任分離。
- 不得在同一輪同時修改存檔格式、戰鬥規則與 UI。

## 11. 重構順序

每階段通過 Godot Check 與本機 F5 後才進下一階段：

1. **基礎層**：畫面 ID、本地化服務、架構文件。
2. **名將整備**：規則、Controller、Session、ViewModel、renderer 分離。
3. **共用 UI 元件**：Panel、Modal、選項、狀態徽章、文字排版。
4. **章間與結果 UI**：修正排版並改用共用元件。
5. **招賢館統一編成**：接入名將 system。
6. **畫面／輸入路由**：降低裸字串與 Modal 穿透。
7. **多國語言落地**：逐畫面替換並加入檢查工具。
8. **狀態效果與 HUD**：建立資料、規則與 renderer。
9. **存檔服務**：序列化、遷移、備份。
10. **靜態資料拆分**：逐域拆分並加入資料驗證。
11. **戰鬥系統**：Boss、投射物、技能依序拆分。
12. **工具與 Actions 清理**：移除一次性 patch workflow。

完整追蹤請查看：

```text
docs/roadmap/ALPHA17_BACKLOG.md
```

## 12. AI 修改規則

AI 每次工作前必須回答：

- 修改哪一層？
- 會改哪些檔案？
- 有無存檔格式變更？
- 有無新增玩家可見文字？翻譯 key 是否齊全？
- 驗收方式是什麼？

AI 每次工作後必須驗證：

- 目標函式是否只有一份，避免重複宣告。
- 新 preload／class_name／常數名稱是否存在。
- 輸入路由與繪製路由是否成對。
- workflow 是否真的生成目標 commit。
- Godot Check 狀態。
- 本機 F5 尚未測試時必須明確標示。

AI 不得：

- 用正規表示式跨越不確定的大型函式區塊而不驗證結果。
- 建立 workflow patch 後聲稱主檔已修改，卻未檢查生成 commit。
- 以玩家可見中文作為 match／if 的唯一條件。
- 同一輪同時搬移輸入、規則、存檔與 UI。
- 未經使用者確認就自動合併高風險存檔或戰鬥重構。
