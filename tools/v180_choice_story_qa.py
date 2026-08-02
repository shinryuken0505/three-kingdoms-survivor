from pathlib import Path
import sys
root=Path(sys.argv[1]) if len(sys.argv)>1 else Path(__file__).resolve().parents[1]
main=(root/'scripts/main.gd').read_text(encoding='utf-8')
checks={
 'ui_accept fallback':'is_action_pressed("ui_accept", true)' in main,
 'confirm debounce':'modal_input_lock_until_ms' in main and 'last_confirm_ms' in main,
 'mouse levelup':'handle_modal_mouse_click' in main and 'choose_levelup(i)' in main,
 '1-2 hero candidates':'encounter_candidates' in main and 'two_chance' in main,
 'faction weighting':'dominant_faction()' in main and 'hero_story_weight' in main,
 'story boss variant':'story_adjusted_boss_definition' in main and 'extra_support' in main,
 'candidate screen':'draw_hero_candidate_screen' in main and 'hero_encounter_pick' in main,
}
failed=[k for k,v in checks.items() if not v]
if failed:
 print('V180_CHOICE_STORY_QA_FAILED')
 for x in failed: print('-',x)
 raise SystemExit(1)
print('V180_CHOICE_STORY_QA_OK', len(checks))
