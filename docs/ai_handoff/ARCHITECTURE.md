# 架構說明

## 現況總覽

```text
main.tscn
└── scripts/main.gd                 # 主控制器：狀態、輸入、戰鬥、UI、存檔、繪圖
    ├── scripts/game_data.gd        # 武將、技能、裝備、羈絆、外觀等靜態資料
    ├── scripts/chapter_manager.gd  # 章節定義、章節切換與進度
    └── scripts/history_event_data.gd # 歷史事件與選項
```

素材：

```text
assets/
├── audio/
├── maps/
├── portraits/
├── props/
├── relics/
└── sprites/
```

## main.gd 區域索引

行號會隨版本變動，請用函式名稱搜尋，不要依賴固定行號。

### 啟動與資源

- `_ready`
- `setup_fonts`
- `runtime_texture`
- `runtime_wav`
- `load_assets`
- `setup_audio`

### 存檔

- `read_save_document`
- `normalize_save_document`
- `load_save`
- `save_game_meta`
- `save_run_checkpoint`
- `continue_run_from_checkpoint`

### 輸入與畫面狀態

- `_input`
- `handle_modal_mouse_click`
- `handle_menu_key`
- `handle_game_key`
- `handle_option_screen_key`
- `handle_hero_config_key`
- `handle_history_event_key`

### 戰鬥

- `update_game`
- `update_player`
- `perform_auto_attack`
- `update_enemies`
- `damage_player`
- `damage_enemy`
- `damage_boss`
- `update_boss`

### 名將／羈絆

- `hero_pool`
- `dominant_faction`
- `hero_story_weight`
- `weighted_hero_pick`
- `spawn_hero_encounter`
- `choose_hero_candidate`
- `update_bonds`

### 歷史事件

- `chapter_history_event_definitions`
- `open_history_event`
- `apply_history_choice`
- `record_history_choice`
- `story_adjusted_boss_definition`

### 升級與商店

- `open_shop`
- `choose_shop`
- `open_levelup`
- `choose_levelup`

### Boss

- `spawn_boss`
- `boss_basic_attack`
- `boss_special_attack`
- `finish_boss_if_ready`
- `prepare_boss_loot`
- `accept_boss_loot`

### 繪製

所有 `draw_*` 函式集中在檔案後段。新增畫面時必須同步處理：

1. 狀態進入
2. `_input` 分派
3. `_process`／更新
4. `_draw` 分派
5. 離開／返回

## 建議的漸進拆分方向

不要一次重寫。建議順序：

1. `systems/input_router.gd`
2. `systems/save_system.gd`
3. `systems/story_state.gd`
4. `systems/hero_encounter_system.gd`
5. `systems/boss_system.gd`
6. `ui/screen_renderer.gd`

每拆一個模組，都要保留原函式入口作為薄包裝，避免大量呼叫點同時改動。
