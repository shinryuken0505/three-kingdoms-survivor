# 遊戲流程與狀態轉移

## 主要流程

```text
menu
→ character_select
→ chapter_intro
→ game
→ levelup / hero_encounter / shop / history_event / hero_config / tab
→ game
→ boss_intro
→ game（Boss戰）
→ boss_loot
→ victory
→ chapter_intermission
→ chapter_intro（下一章）
```

失敗流程：

```text
game
→ game_over
→ restart / menu
```

## 重要狀態原則

- `screen` 是唯一主要畫面狀態來源。
- `previous_screen` 用於 modal 返回。
- `modal_input_lock_until_ms` 防止開啟選單的同一按鍵被立刻當成確認。
- `last_confirm_ms` 防止同一顆按鍵重複確認。
- `pending_run_result` 讓勝敗在更新階段安全結算，避免迭代陣列時切換畫面。

## 升級流程

```text
玩家獲得足夠 XP
→ pending_levelups += 1
→ open_levelup()
→ screen = "levelup"
→ 產生 level_choices
→ 玩家方向鍵選擇
→ Space / Enter / 滑鼠確認
→ choose_levelup(index)
→ 套用效果
→ 若仍有 pending_levelups，再次開啟
→ 否則回到 game
```

### 升級卡死排查順序

1. `screen` 是否為 `levelup`。
2. `level_choices` 是否非空。
3. `select_index` 是否在陣列範圍。
4. `modal_input_lock_until_ms` 是否已過。
5. `_input` 是否收到 `pressed` 且非 `echo`。
6. `is_confirm_key()` 是否辨識 Space／Enter／數字鍵盤 Enter。
7. `choose_levelup()` 是否中途錯誤。
8. 選擇後是否正確切回 `game` 或下一次升級。

## 名將遭遇

```text
spawn_hero_encounter()
→ 建立 1～2 位 encounter_candidates
→ 權重來源：章節、陣營、羈絆、未結識、劇情旗標
→ screen = "hero_encounter"
→ choose_hero_candidate(index)
→ 加入／升級／替換／婉拒
→ finish_hero_encounter()
```

## 劇情影響 Boss

```text
apply_history_choice()
→ record_history_choice(flag)
→ 寫入本局世界狀態
→ 後續章節讀取旗標
→ story_adjusted_boss_definition()
→ 修改 Boss、支援 Boss、屬性、技能、台詞或掉落
```
