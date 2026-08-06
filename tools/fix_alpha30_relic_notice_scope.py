from pathlib import Path

path = Path("scripts/main.gd")
text = path.read_text(encoding="utf-8")
old = 'if pending_relic_notice.is_empty() or str(pending_relic_notice.get("id", "")) != granted:'
new = 'if pending_relic_notice.is_empty() or str(pending_relic_notice.get("id", "")) != offered_relic:'
if old not in text:
    raise SystemExit("target relic notice scope line not found")
text = text.replace(old, new, 1)
path.write_text(text, encoding="utf-8")
print("Replaced out-of-scope granted with offered_relic")
