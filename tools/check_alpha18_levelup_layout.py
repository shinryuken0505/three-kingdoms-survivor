from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
main_path = ROOT / "scripts/main.gd"
layer_path = ROOT / "scripts/ui/levelup_card_metadata_layer.gd"
scene_path = ROOT / "main.tscn"

for path in [main_path, layer_path, scene_path]:
    if not path.exists():
        raise SystemExit(f"Missing required file: {path.relative_to(ROOT)}")

main = main_path.read_text(encoding="utf-8")
layer = layer_path.read_text(encoding="utf-8")
scene = scene_path.read_text(encoding="utf-8")

# 升級卡與補充標籤必須共用相同的幾何基準。
shared_tokens = [
    "var card_width: float = 300.0",
    "var start_x: float = 640.0 - float(columns) * card_width * 0.5",
    "155.0 + float(row) * (card_height + 14.0)",
]
for token in shared_tokens:
    if token not in layer:
        raise SystemExit(f"Metadata layer is missing shared layout token: {token}")

for token in ["var w: float = 300.0", "var start_x: float = 640.0 - columns * w * 0.5", "155 + row * (h + 14)"]:
    if token not in main:
        raise SystemExit(f"Legacy level-up layout changed; update metadata layer too: {token}")

# 不允許重新加入會壓住卡片內容的大型標籤列。
for forbidden in ["Build 標籤", "目前路線", "路線完成度", "下一步建議"]:
    if forbidden in layer:
        raise SystemExit(f"Oversized player-facing metadata returned: {forbidden}")

if "LevelupCardMetadataLayer" not in scene:
    raise SystemExit("LevelupCardMetadataLayer is not mounted in main.tscn")

if "card_rect.end.y - 33.0" in layer:
    raise SystemExit("Bottom tag row overlaps the legacy Enter/Space hint")

print("Alpha.18 level-up layout checks passed.")
