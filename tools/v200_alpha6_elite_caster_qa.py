from pathlib import Path
text = Path('scripts/main.gd').read_text(encoding='utf-8')
checks = {
    'version': 'V2.0.0-alpha.6' in text,
    'chapter_gate': 'chapter_index >= 2' in text,
    'caster_slow': '"caster_slow"' in text,
    'caster_bind': '"caster_bind"' in text,
    'caster_smoke': '"caster_smoke"' in text,
    'control_warning': 'enemy_control_warning' in text,
    'control_resist': 'control_resist' in text,
    'vision_obscure': 'vision_obscure' in text,
    'elite_visual': 'elite_pulse' in text and '黃巾渠帥' in text,
}
failed = [name for name, ok in checks.items() if not ok]
if failed:
    raise SystemExit('V2_ALPHA6_QA_FAIL: ' + ', '.join(failed))
print('V2_ALPHA6_QA_OK')
