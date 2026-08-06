from pathlib import Path

path = Path('scripts/main.gd')
text = path.read_text(encoding='utf-8')
old = '''func hero_portrait(hero_id: String) -> Texture2D:\n\tif portrait_tex.has(hero_id) and hero_portrait(str(hero_id)) is Texture2D:\n\t\treturn hero_portrait(str(hero_id)) as Texture2D\n\tpush_warning("Hero portrait unavailable; sprite fallback forbidden: %s" % hero_id)\n\treturn runtime_texture("res://assets/portraits/placeholder.png")'''
new = '''func hero_portrait(hero_id: String) -> Texture2D:\n\tif portrait_tex.has(hero_id) and portrait_tex[hero_id] is Texture2D:\n\t\treturn portrait_tex[hero_id] as Texture2D\n\tpush_warning("Hero portrait unavailable; sprite fallback forbidden: %s" % hero_id)\n\treturn runtime_texture("res://assets/portraits/placeholder.png")'''
if old not in text:
    raise SystemExit('recursive hero_portrait block not found')
text = text.replace(old, new, 1)
text = text.replace(
    'if not portrait_tex.has(hero_id) or not (hero_portrait(str(hero_id)) is Texture2D):',
    'if not portrait_tex.has(hero_id) or not (portrait_tex[hero_id] is Texture2D):',
    1,
)
path.write_text(text, encoding='utf-8')
