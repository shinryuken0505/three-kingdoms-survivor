from pathlib import Path

MAIN_PATH = Path("scripts/main.gd")
REPORT_PATH = Path("docs/art/alpha28_relic_flow_report.md")

text = MAIN_PATH.read_text(encoding="utf-8")
text = text.replace(
    'const GAME_VERSION: String = "V2.0.0-alpha.27"',
    'const GAME_VERSION: String = "V2.0.0-alpha.28"',
    1,
)

old = '''\tvar initial_relic_count: int = relics.size()
\tvar granted: String = grant_random_relic("自動測試")
\tif granted == "" or relics.size() != initial_relic_count + 1:
\t\tself_test_fail("遺物授予流程失效")
\t\treturn
'''
new = '''\t# Alpha.28：以乾淨狀態分別驗證「新取得」與「重複取得升級」，
\t# 避免既有章節上限或隨機抽到已持有遺物，讓自測誤判授予流程失效。
\trelics.clear()
\trelic_levels.clear()
\tchapter_natural_relics = 0
\tvar offered_relic: String = random_relic_offer()
\tif offered_relic == "":
\t\tself_test_fail("遺物池未提供可授予項目")
\t\treturn
\tif not grant_relic(offered_relic, "自動測試取得", false):
\t\tself_test_fail("新遺物授予流程失效")
\t\treturn
\tif not relics.has(offered_relic) or relic_level(offered_relic) != 1:
\t\tself_test_fail("新遺物未正確加入背包或等級不是Lv.1")
\t\treturn
\tvar relic_count_after_first_grant: int = relics.size()
\tif not grant_relic(offered_relic, "自動測試升級", false):
\t\tself_test_fail("既有遺物升級流程失效")
\t\treturn
\tif relics.size() != relic_count_after_first_grant or relic_level(offered_relic) != 2:
\t\tself_test_fail("既有遺物升級後數量或等級異常")
\t\treturn
'''

if old in text:
    text = text.replace(old, new, 1)
elif 'const GAME_VERSION: String = "V2.0.0-alpha.28"' not in text:
    raise SystemExit("Alpha.28 target self-test block not found")

MAIN_PATH.write_text(text, encoding="utf-8")
REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
REPORT_PATH.write_text(
    """# Alpha.28 遺物授予流程修復

## 修正目標

- 排除章節新遺物上限干擾自動測試。
- 分開驗證首次取得與重複取得升級。
- 首次取得必須加入 `relics` 且等級為 Lv.1。
- 重複取得必須升為 Lv.2，背包數量不得重複增加。

## 驗收條件

1. Godot 專案與 GDScript 可正常解析。
2. `DEMO6_SELF_TEST` 不再回報「遺物授予流程失效」。
3. 新遺物取得與既有遺物升級皆通過自動驗證。
""",
    encoding="utf-8",
)
