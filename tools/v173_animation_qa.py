from pathlib import Path
root=Path(__file__).resolve().parents[1]
s=(root/"scripts/main.gd").read_text(encoding="utf-8-sig")
checks={
"player timer":"var player_action_anim: Dictionary",
"boss timer":"var boss_action_anim: Dictionary",
"player trigger":"player_action_anim = {",
"boss attack trigger":"boss_action_anim = {\"kind\":\"attack\"",
"boss cast trigger":"boss_action_anim = {\"kind\":\"cast\"",
"pose helper":"func draw_sprite_pose(",
"player pose":"draw_sprite_pose(sprite_tex[chosen_identity]",
"boss pose":"draw_sprite_pose(sprite_tex[boss[\"id\"]]",
"hero pose":"draw_sprite_pose(sprite_tex[cast_id]",
}
missing=[k for k,v in checks.items() if v not in s]
if missing:
 print("V173_ANIMATION_QA_FAIL", ", ".join(missing)); raise SystemExit(1)
print("V173_ANIMATION_QA_OK", len(checks))
