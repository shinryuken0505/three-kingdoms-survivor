# 主角負面狀態 HUD 接線指南

本文件說明如何把目前已完成的狀態效果資料與繪圖元件接入 `scripts/main.gd`。

## 已完成元件

- `PlayerStatusAdapter`：讀取舊 `player` 欄位與新 `status_effects` 陣列。
- `StatusEffectManager`：排序、堆疊與 ViewModel。
- `StatusEffectPresenter`：翻譯、Tooltip、字形及色彩備援。
- `StatusEffectRenderer`：主角頭上與 HUD 排版。
- `StatusEffectIconPainter`：無圖片素材時的程式化圖示。
- `StatusEffectHud`：整合以上元件的單一入口。

## main.gd 最小接線方式

在 preload 區新增：

```gdscript
const StatusEffectHudScript = preload("res://scripts/ui/components/status_effect_hud.gd")
```

在戰場 HUD 繪製階段呼叫：

```gdscript
var player_screen_pos: Vector2 = world_to_screen(player["pos"])
StatusEffectHudScript.draw(
    self,
    player,
    player_screen_pos,
    font,
    VIEW
)
```

接線後可移除原本 HUD 只顯示單一文字的區塊：

```gdscript
if float(player.get("control_lock", 0.0)) > 0.0:
    draw_text("麻痺", ...)
elif float(player.get("move_slow", 0.0)) > 0.0:
    draw_text("緩速", ...)
elif float(player.get("vision_obscure", 0.0)) > 0.0:
    draw_text("妖煙", ...)
```

新元件可同時顯示多個狀態，不再使用 `elif` 互相覆蓋。

## 建議驗收

1. 緩速時，主角頭上與右側 HUD 同時出現緩速圖示及倒數。
2. 暈眩與煙霧同時存在時，兩個狀態都可見，暈眩優先排列。
3. 倒數低於 1.5 秒時，圖示背景產生低透明度提醒。
4. 流血多層時顯示層數。
5. 狀態結束後圖示於下一次重繪消失。
6. 沒有任何狀態時，不留下空框。

## 風險控制

- 本接線只讀取 `player`，不修改戰鬥規則或倒數。
- 不更動存檔格式。
- 正式圖片不存在時仍使用程式化圖示，不會造成載入錯誤。
- `StatusEffectHud.build()` 可先於 headless 測試，不需要 CanvasItem。
