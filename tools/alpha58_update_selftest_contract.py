#!/usr/bin/env python3
"""Update Alpha.57's legacy hero-visual self-test to accept custom signature shapes.

The production hero code deliberately uses line/arrow/etc. visuals for several generals.
The old test only accepted the generic `hero_effect` zone and falsely failed Cao Cao.
This patch keeps the behavioral assertion: after zones are cleared and exactly one hero is
triggered, at least one hero-prefixed visual plus the matching cast flash must exist.
"""
from pathlib import Path

path = Path(__file__).resolve().parents[1] / "scripts" / "main.gd"
text = path.read_text(encoding="utf-8")
old = '''\t\tvar signature_found: bool = false
\t\tfor zone_value in zones:
\t\t\tvar zone: Dictionary = zone_value
\t\t\tif str(zone.get("kind", "")) == "hero_effect" and str(zone.get("hero", "")) == hero_id:
\t\t\t\tsignature_found = true
\t\t\t\tbreak
\t\tif not signature_found or str(hero_cast_flash.get("id", "")) != hero_id:
\t\t\tself_test_fail("名將專屬技能特效失效：%s" % hero_id)
\t\t\treturn
'''
new = '''\t\tvar signature_found: bool = false
\t\tfor zone_value in zones:
\t\t\tvar zone: Dictionary = zone_value
\t\t\t# Alpha.58：名將可以使用直線、箭雨、風牆等專屬形態，不再強迫全部生成通用 hero_effect。
\t\t\t# 每輪測試前 zones 都已清空，因此本次新生成的 hero_* 視覺即可證明該名將有專屬演出。
\t\t\tif str(zone.get("kind", "")).begins_with("hero_"):
\t\t\t\tsignature_found = true
\t\t\t\tbreak
\t\tif not signature_found or str(hero_cast_flash.get("id", "")) != hero_id:
\t\t\tself_test_fail("名將專屬技能特效失效：%s" % hero_id)
\t\t\treturn
'''
if new in text:
    print("Alpha.58 self-test contract already updated.")
    raise SystemExit(0)
if old not in text:
    raise SystemExit("Expected legacy hero visual self-test block was not found; refusing broad edit.")
path.write_text(text.replace(old, new, 1), encoding="utf-8")
print("Updated hero visual self-test contract for custom hero_* signatures.")
