from pathlib import Path
import re

path = Path('scripts/main.gd')
text = path.read_text(encoding='utf-8')
name = 'sync_roster_after_change'
pattern = re.compile(rf'^func {name}\([^\n]*\) -> [^:]+:\n.*?(?=^func |\Z)', re.M | re.S)
matches = list(pattern.finditer(text))
if len(matches) <= 1:
    print(f'{name}: no duplicate found ({len(matches)} definition)')
    raise SystemExit(0)

# 保留最後一份，因為較新的重構通常追加在後方；刪除前面的重複定義。
keep = matches[-1]
parts = []
last = 0
for match in matches[:-1]:
    parts.append(text[last:match.start()])
    last = match.end()
parts.append(text[last:])
new_text = ''.join(parts)

remaining = len(list(pattern.finditer(new_text)))
if remaining != 1:
    raise SystemExit(f'cleanup failed: expected 1 definition, found {remaining}')

path.write_text(new_text, encoding='utf-8')
print(f'removed {len(matches) - 1} duplicate definition(s) of {name}')
