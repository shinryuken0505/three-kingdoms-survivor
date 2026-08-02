from pathlib import Path
import sys
root=Path(__file__).resolve().parents[1]
s=(root/'scripts/main.gd').read_text(encoding='utf-8')
checks={
 'version':'V1.7.5' in s,
 'boss_cast_bar':'ability_progress' in s and 'ability_track' in s,
 'dodge_bar':'dodge_ready_ratio' in s and 'dodge_track' in s,
 'warning_crosshair':'warning_pulse' in s and 'warning_r * 0.62' in s,
 'low_hp_edge':'danger_alpha' in s and 'hp_ratio_hud <= 0.30' in s,
 'invulnerability_ring':'inv_alpha' in s and 'player.get("invuln"' in s,
}
failed=[k for k,v in checks.items() if not v]
print('V1.7.5_BATTLE_READABILITY_QA', 'PASS' if not failed else 'FAIL')
for k,v in checks.items(): print(('PASS' if v else 'FAIL'), k)
sys.exit(1 if failed else 0)
