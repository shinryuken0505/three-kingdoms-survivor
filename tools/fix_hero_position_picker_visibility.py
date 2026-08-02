from pathlib import Path
import re

path = Path('scripts/main.gd')
text = path.read_text(encoding='utf-8')

pattern = re.compile(r'(func draw_hero_config_screen\(\) -> void:\n.*?)(?=\nfunc draw_hero_position_picker\(\) -> void:)', re.S)
match = pattern.search(text)
if not match:
    raise SystemExit('draw_hero_config_screen block not found')

block = match.group(1)
if 'draw_hero_position_picker()' not in block:
    block = block.rstrip() + '\n\tif hero_position_picker_open:\n\t\tdraw_hero_position_picker()\n\n'
    text = text[:match.start(1)] + block + text[match.end(1):]

path.write_text(text, encoding='utf-8')
print('hero position picker visibility fixed')
