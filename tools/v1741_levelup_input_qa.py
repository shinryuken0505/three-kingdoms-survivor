#!/usr/bin/env python3
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
main=(ROOT/'scripts/main.gd').read_text(encoding='utf-8-sig')
checks={
 'input_first_layer':'func _input(event: InputEvent) -> void:' in main and 'func _unhandled_input(event: InputEvent) -> void:' not in main,
 'confirm_space':'KEY_SPACE' in main and 'KEY_KP_ENTER' in main,
 'physical_fallback':'key_event.physical_keycode' in main,
 'unicode_space':'key_event.unicode == 32' in main,
 'levelup_dispatch':'"levelup":\n\t\t\t\tchoose_levelup(option_index)' in main,
 'bounds_guard':'if index < 0 or index >= level_choices.size():' in main,
}
failed=[k for k,v in checks.items() if not v]
if failed: raise SystemExit('V1741_LEVELUP_INPUT_QA_FAILED '+','.join(failed))
print('V1741_LEVELUP_INPUT_QA_OK',len(checks))
