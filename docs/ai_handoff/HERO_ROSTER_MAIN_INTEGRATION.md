# 名將整備接入 `main.gd` 指南

本文件描述下一個實際接線提交應如何縮短 `main.gd` 的三段舊輸入流程，避免再次在巨型檔案內複製規則。

## 目標替換函式

```gdscript
handle_hero_config_key()
handle_hero_position_picker_key()
handle_config_replace_key()
```

三個入口最後應共用同一個薄層：

```text
HeroRosterMainState.snapshot
→ HeroRosterMainAdapter.handle_key
→ 套用 legacy_state
→ 依 screen_command 切畫面
→ 依 sfx 播放音效
→ 依 message 顯示提示
→ roster_changed 時同步羈絆與冷卻
→ origin 為 intermission 時保存檢查點
```

## 接線前需加入的 preload

```gdscript
const HeroRosterMainAdapterScript = preload("res://scripts/systems/hero/hero_roster_main_adapter.gd")
const HeroRosterMainStateScript = preload("res://scripts/systems/hero/hero_roster_main_state.gd")
```

## 建立舊欄位快照

```gdscript
var legacy_state := HeroRosterMainStateScript.snapshot(
    hero_config_index,
    hero_config_origin,
    config_candidate,
    config_replace_index,
    config_replace_mode,
    hero_position_picker_open,
    hero_position_index,
    hero_position_candidate
)
```

## 呼叫統一入口

```gdscript
var result := HeroRosterMainAdapterScript.handle_key(
    key as Key,
    legacy_state,
    known_hero_order(),
    active_heroes,
    reserve_heroes,
    camp_heroes,
    active_limit(),
    reserve_limit(),
    heroes
)
```

## 套用回傳欄位

`result["legacy_state"]` 必須一次完整套回八個舊欄位，不可只更新目前畫面看得到的欄位，否則取消替換後容易殘留候選名將。

## 畫面命令

- `keep`：維持目前畫面。
- `config_replace`：切至替換畫面。
- `hero_config`：回到名將整備主畫面。
- `close_hero_config`：呼叫既有 `close_hero_config()`，保留大喬加成與章間存檔行為。

## 編成變更後處理

當 `should_sync_roster` 為 `true`：

1. 更新主戰名將冷卻：新進主戰者使用 `hero_cooldown_value()`。
2. 離開主戰者移除 `hero_cooldowns`。
3. 呼叫 `sync_roster_after_change()`。
4. 只有 `hero_config_origin == "intermission"` 時才保存章間檢查點；Adapter 的 `should_save_checkpoint` 代表資料已變更，不代表任何來源都必須立即寫檔。

## 驗收流程

1. 名將清單上下循環。
2. Enter／Space 開啟位置選擇。
3. 主戰、後備、營地互相移動。
4. 主戰滿額替換，舊名將優先進後備。
5. 後備滿額替換，舊名將回營地。
6. Esc 先關替換，再關位置選擇，最後離開整備。
7. 從行商、營地、章間三個入口開啟並正確返回。
8. 章間改動後重新讀檔，編成保持一致。

## 禁止事項

- 不可在 `main.gd` 再直接修改三個編成陣列完成替換。
- 不可以中文顯示文字判斷流程。
- 不可同時更動存檔格式或戰鬥平衡。
- 不可保留新舊兩套輸入同時處理同一按鍵。
