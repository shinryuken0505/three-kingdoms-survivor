from pathlib import Path
import re

path = Path('scripts/main.gd')
text = path.read_text(encoding='utf-8')

# Enter/Space from hero config should switch to a real screen, not a hidden overlay flag.
text = text.replace(
    '\t\thero_position_picker_open = true\n\t\tplay_sfx("ui_confirm")',
    '\t\thero_position_picker_open = true\n\t\tscreen = "hero_position_picker"\n\t\tplay_sfx("ui_confirm")',
    1,
)

# Picker cancel/confirm always returns to hero_config unless it opens a replacement screen.
text = text.replace(
    '\t\thero_position_picker_open = false\n\t\tplay_sfx("ui_cancel")\n\t\treturn',
    '\t\thero_position_picker_open = false\n\t\tscreen = "hero_config"\n\t\tplay_sfx("ui_cancel")\n\t\treturn',
    1,
)
text = text.replace(
    '\t\thero_position_picker_open = false\n\t\tplay_sfx("ui_cancel")\n\t\treturn',
    '\t\thero_position_picker_open = false\n\t\tscreen = "hero_config"\n\t\tplay_sfx("ui_cancel")\n\t\treturn',
    1,
)
text = text.replace(
    '\thero_position_picker_open = false\n\nfunc handle_config_replace_key',
    '\thero_position_picker_open = false\n\tscreen = "hero_config"\n\nfunc handle_config_replace_key',
    1,
)

# Add input dispatch for the dedicated picker screen.
if '"hero_position_picker":\n\t\t\thandle_hero_position_picker_key(key)' not in text:
    marker = '\t\t"hero_config":\n\t\t\thandle_hero_config_key(key)\n'
    if marker not in text:
        raise SystemExit('input dispatch marker not found')
    text = text.replace(marker, marker + '\t\t"hero_position_picker":\n\t\t\thandle_hero_position_picker_key(key)\n', 1)

# Add draw dispatch. Draw the config behind the modal so it remains visually grounded.
if '"hero_position_picker":\n\t\t\tdraw_hero_config_screen()' not in text:
    marker = '\t\t"hero_config":\n\t\t\tdraw_hero_config_screen()\n'
    if marker not in text:
        raise SystemExit('draw dispatch marker not found')
    text = text.replace(marker, marker + '\t\t"hero_position_picker":\n\t\t\tdraw_hero_config_screen()\n\t\t\tdraw_hero_position_picker()\n', 1)

# Avoid double drawing when the main hero config is used directly.
text = text.replace(
    '\tif hero_position_picker_open:\n\t\tdraw_hero_position_picker()\n',
    '',
)

path.write_text(text, encoding='utf-8')
