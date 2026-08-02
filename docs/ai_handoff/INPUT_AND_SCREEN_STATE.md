# 輸入與畫面狀態規範

## 支援輸入

- 移動：方向鍵／WASD
- 確認：Space／Enter／數字鍵盤 Enter
- 返回：Esc
- 互動：依 `handle_game_key` 現有設定
- 滑鼠：所有卡片式 modal 應提供點擊確認

## Modal 安全規範

所有新 modal 必須：

1. 設定 `previous_screen`。
2. 設定 `screen`。
3. 將選擇索引重設為 0。
4. 設定短暫輸入鎖。
5. 在 `_input` 中有明確分派。
6. 在滑鼠處理中有 hitbox。
7. 在 `_draw` 中有分派。
8. 有明確退出路徑。
9. 選擇成功後立即清理候選資料，防止重複確認。

建議共用入口：

```gdscript
func open_modal(next_screen: String, return_screen: String = "game") -> void:
    previous_screen = return_screen
    screen = next_screen
    select_index = 0
    modal_input_lock_until_ms = Time.get_ticks_msec() + 150
    queue_redraw()
```

目前尚未抽成共用函式，新增畫面時請遵循相同行為。

## 常見卡死原因

- 用開啟 modal 的同一個 Space 立刻確認。
- `event.echo` 沒有排除。
- `screen` 名稱拼字不一致。
- `_draw` 有畫面，但 `_input` 沒有分派。
- 候選陣列為空或索引失效。
- 選擇函式內發生型別錯誤，畫面因此未切換。
- GUI 或其他節點先消耗事件；因此本專案主入口使用 `_input`。

## 修改輸入時的最低回歸測試

- 第一章連續升級至少三次。
- Space、Enter、數字鍵盤 Enter 各測一次。
- 方向鍵和 WASD 都能選擇。
- 滑鼠可直接點卡片。
- 連按 Space 不會一次選兩次。
- 暫停／TAB／商店／名將／劇情事件返回遊戲後仍可操作。
