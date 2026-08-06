#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAIN = ROOT / "scripts" / "main.gd"
REPORT = ROOT / "docs" / "art" / "alpha27_combat_identity_report.md"


def replace_once(text: str, old: str, new: str, label: str) -> str:
    if old not in text:
        raise SystemExit(f"missing patch anchor: {label}")
    return text.replace(old, new, 1)


def main() -> None:
    text = MAIN.read_text(encoding="utf-8")
    text = replace_once(
        text,
        'const Alpha24SteamDemo = preload("res://scripts/systems/demo/alpha24_steam_demo.gd")\n',
        'const Alpha24SteamDemo = preload("res://scripts/systems/demo/alpha24_steam_demo.gd")\nconst Alpha27ActionProfiles = preload("res://scripts/systems/combat/alpha27_action_profiles.gd")\n',
        "alpha27 preload",
    )
    text = text.replace('const GAME_VERSION: String = "V2.0.0-alpha.25"', 'const GAME_VERSION: String = "V2.0.0-alpha.27"')
    text = replace_once(
        text,
        'var action_duration: float = 0.24 if weapon_kind == "blade" else 0.20\n\tplayer_action_anim = {"kind": weapon_kind, "life": action_duration, "max_life": action_duration, "angle": dir.angle()}\n',
        'var action_profile: Dictionary = Alpha27ActionProfiles.player_profile(weapon_kind)\n\tvar action_duration: float = float(action_profile.get("duration", 0.46))\n\tplayer_action_anim = {\n\t\t"kind": weapon_kind,\n\t\t"life": action_duration,\n\t\t"max_life": action_duration,\n\t\t"angle": dir.angle(),\n\t\t"windup": float(action_profile.get("windup", 0.25)),\n\t\t"active": float(action_profile.get("active", 0.40)),\n\t\t"recover": float(action_profile.get("recover", 0.35))\n\t}\n',
        "player action duration",
    )
    text = text.replace(
        'hero_cast_flash = {"id": hid, "life": 1.0, "max_life": 1.0, "pos": center}',
        'hero_cast_flash = {"id": hid, "life": Alpha27ActionProfiles.hero_cast_duration(hid), "max_life": Alpha27ActionProfiles.hero_cast_duration(hid), "pos": center}',
    )
    old_pose = '''\tif not player_action_anim.is_empty():
\t\tvar pap: float = action_progress(player_action_anim)
\t\tvar action_dir: Vector2 = Vector2.from_angle(float(player_action_anim.get("angle", 0.0)))
\t\tvar action_kind: String = str(player_action_anim.get("kind", "blade"))
\t\tif action_kind == "blade":
\t\t\tplayer_offset = action_dir * sin(pap * PI) * 10.0
\t\t\tplayer_rotation = sin(pap * PI) * (0.10 if action_dir.x >= 0.0 else -0.10)
\t\t\tplayer_stretch = Vector2(1.0 + sin(pap * PI) * 0.12, 1.0 - sin(pap * PI) * 0.07)
\t\telif action_kind in ["bow", "poison"]:
\t\t\tplayer_offset = -action_dir * sin(pap * PI) * 6.0
\t\t\tplayer_stretch = Vector2(1.0 - sin(pap * PI) * 0.05, 1.0 + sin(pap * PI) * 0.08)
\t\telse:
\t\t\tplayer_rotation = sin(pap * TAU) * 0.08
'''
    new_pose = '''\tif not player_action_anim.is_empty():
\t\tvar pap: float = action_progress(player_action_anim)
\t\tvar action_dir: Vector2 = Vector2.from_angle(float(player_action_anim.get("angle", 0.0)))
\t\tvar action_kind: String = str(player_action_anim.get("kind", "blade"))
\t\tvar pose: Dictionary = Alpha27ActionProfiles.player_pose(action_kind, pap)
\t\tplayer_offset = action_dir * float(pose.get("lunge", 0.0))
\t\tplayer_rotation = float(pose.get("rotation", 0.0)) * (1.0 if action_dir.x >= 0.0 else -1.0)
\t\tplayer_stretch = pose.get("stretch", Vector2.ONE) as Vector2
'''
    text = replace_once(text, old_pose, new_pose, "player pose block")
    old_cast = '''\t\t\tvar cast_pos: Vector2 = cast_center + Vector2(46.0 * cast_side, -24.0 - sin(cast_progress * PI) * 20.0)
\t\t\tvar cast_scale: float = 1.15 + sin(cast_progress * PI) * 0.18
'''
    new_cast = '''\t\t\tvar cast_pose: Dictionary = Alpha27ActionProfiles.cast_pose(cast_id, cast_progress)
\t\t\tvar cast_pos: Vector2 = cast_center + Vector2(46.0 * cast_side, -24.0 + float(cast_pose.get("rise", 0.0)))
\t\t\tvar cast_scale: float = float(cast_pose.get("scale", 1.15))
'''
    text = replace_once(text, old_cast, new_cast, "hero cast pose")
    text = text.replace(
        'draw_sprite_pose(sprite_tex[cast_id], cast_pos, cast_scale, int(cast_progress * 8.0) % 4, Color(1, 1, 1, min(1.0, cast_alpha * 1.8)), sin(cast_progress * TAU) * 0.035)',
        'draw_sprite_pose(sprite_tex[cast_id], cast_pos, cast_scale, int(cast_progress * 8.0) % 4, Color(1, 1, 1, min(1.0, cast_alpha * 1.8)), float(cast_pose.get("rotation", 0.0)))',
    )
    MAIN.write_text(text, encoding="utf-8")
    REPORT.parent.mkdir(parents=True, exist_ok=True)
    REPORT.write_text("""# Alpha.27 戰鬥辨識與簡易動作演出\n\n- [x] 版本更新為 V2.0.0-alpha.27。\n- [x] 主角近戰揮擊延長並拆成起手、出招、收招。\n- [x] 弓箭加入拉弓、放箭、回位節奏。\n- [x] 毒術加入施法前搖與停留。\n- [x] 名將技能顯示依近戰、弓將、軍師／醫者延長至 0.92～1.18 秒。\n- [x] 名將登場動作加入上升、停留、收勢與類型化旋轉。\n\n## 驗收重點\n- [ ] 刀客揮擊能清楚看到向後蓄力與向前揮動。\n- [ ] 弓手射擊能看出拉弓，不再只有瞬間閃動。\n- [ ] 諸葛亮、周瑜、華佗等施法角色至少停留約一秒。\n- [ ] 關羽、張飛、趙雲、呂布出招方向與目標一致。\n- [ ] 高攻速後期不因動畫延長而阻塞實際攻擊判定。\n\n## 後續人工精修\n- [ ] 增加武器獨立圖層，讓青龍偃月刀、蛇矛與方天畫戟真正揮動。\n- [ ] 為核心 10 位角色補專屬起手姿勢。\n- [ ] Boss 大招加入 0.35～0.60 秒專屬蓄力姿勢。\n""", encoding="utf-8")
    print("Alpha.27 action animation patch applied")


if __name__ == "__main__":
    main()
