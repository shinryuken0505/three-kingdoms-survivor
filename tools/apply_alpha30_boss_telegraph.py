from pathlib import Path

MAIN = Path("scripts/main.gd")
REPORT = Path("docs/art/alpha30_boss_telegraph_report.md")
text = MAIN.read_text(encoding="utf-8")

text = text.replace(
    'const GAME_VERSION: String = "V2.0.0-alpha.29"',
    'const GAME_VERSION: String = "V2.0.0-alpha.30"',
    1,
)

anchor = "\n\nfunc update_boss(delta: float) -> void:\n"
helper = r'''

func alpha30_boss_skill_name() -> String:
	if boss.is_empty():
		return "敵將絕技"
	match str(boss.get("id", "")):
		"zhangjiao": return "太平天雷"
		"huaxiong": return "西涼裂地斬"
		"lvbu": return "天下無雙"
		"caoren": return "鐵壁震軍"
		"zhanghe": return "巧變突襲"
		"gaoshun": return "陷陣衝鋒"
		_: return "敵將絕技"


func alpha30_boss_telegraph_duration() -> float:
	match str(boss.get("id", "")):
		"lvbu": return 1.05
		"zhangjiao": return 0.95
		"huaxiong", "gaoshun": return 0.78
		_: return 0.68


func alpha30_begin_boss_telegraph() -> void:
	if boss.is_empty() or float(boss.get("telegraph_time", 0.0)) > 0.0:
		return
	var duration: float = alpha30_boss_telegraph_duration()
	boss["telegraph_time"] = duration
	boss["telegraph_total"] = duration
	boss["telegraph_target"] = player.get("pos", boss.get("pos", Vector2.ZERO))
	boss["control_lock"] = duration
	boss_ability_banner = {
		"name": alpha30_boss_skill_name(),
		"time": duration,
		"max_time": duration,
		"warning": true
	}
	var warning_pos: Vector2 = boss.get("telegraph_target", boss.get("pos", Vector2.ZERO))
	zones.append({
		"kind": "ring_visual",
		"pos": warning_pos,
		"r": 150.0 if str(boss.get("id", "")) != "lvbu" else 190.0,
		"life": duration,
		"max_life": duration,
		"color": Color8(239, 80, 62)
	})
	play_sfx("boss_warning", 1.0)
	show_message("%s正在蓄力，注意紅色預警區！" % alpha30_boss_skill_name(), duration)


func alpha30_update_boss_telegraph(delta: float) -> bool:
	var remaining: float = float(boss.get("telegraph_time", 0.0))
	if remaining <= 0.0:
		return false
	remaining = max(0.0, remaining - delta)
	boss["telegraph_time"] = remaining
	boss["control_lock"] = remaining
	if not boss_ability_banner.is_empty():
		boss_ability_banner["time"] = remaining
	if remaining <= 0.0:
		boss_ability_banner["warning"] = false
		boss_special_attack()
		boss_action_anim = {
			"time": 0.42,
			"max_time": 0.42,
			"kind": "special_release"
		}
		screen_shake = max(screen_shake, 8.0)
		return false
	return true
'''
if "func alpha30_begin_boss_telegraph()" not in text:
    if anchor not in text:
        raise SystemExit("update_boss anchor not found")
    text = text.replace(anchor, helper + anchor, 1)

old_tick = '\tboss["special_cd"] = max(0.0, float(boss["special_cd"]) - delta)\n'
new_tick = old_tick + '\tif alpha30_update_boss_telegraph(delta):\n\t\tboss["anim"] = float(boss["anim"]) + delta * 1.8\n\t\treturn\n'
if "alpha30_update_boss_telegraph(delta)" not in text:
    if old_tick not in text:
        raise SystemExit("special cooldown tick anchor not found")
    text = text.replace(old_tick, new_tick, 1)

old_fire = '\tif float(boss["special_cd"]) <= 0.0:\n\t\tboss_special_attack()\n'
new_fire = '\tif float(boss["special_cd"]) <= 0.0:\n\t\talpha30_begin_boss_telegraph()\n'
if old_fire in text:
    text = text.replace(old_fire, new_fire, 1)
elif new_fire not in text:
    raise SystemExit("boss special trigger anchor not found")

# Keep the existing cooldown assignment after the trigger, but ensure the telegraph state exists on spawn.
spawn_anchor = '\tboss_spawned = true\n'
spawn_patch = '\tboss_spawned = true\n\tboss["telegraph_time"] = 0.0\n\tboss["telegraph_total"] = 0.0\n\tboss["control_lock"] = 0.0\n'
if spawn_patch not in text:
    if spawn_anchor not in text:
        raise SystemExit("boss spawn anchor not found")
    text = text.replace(spawn_anchor, spawn_patch, 1)

MAIN.write_text(text, encoding="utf-8")
REPORT.parent.mkdir(parents=True, exist_ok=True)
REPORT.write_text(
    """# Alpha.30 Boss Telegraph & Effects Report

## Implemented
- Version raised to `V2.0.0-alpha.30`.
- Boss special attacks now enter a readable wind-up phase instead of firing instantly.
- Added per-boss skill names and tuned warning durations.
- Added red ground warning rings, HUD banner state, warning sound, and release shake.
- Boss movement/attack processing pauses during the warning window so the telegraph remains readable.
- First pass covers Zhang Jiao, Hua Xiong, Lu Bu, Cao Ren, Zhang He, and Gao Shun, with a safe fallback for other bosses.

## Timing
- Standard special: about 0.68 seconds.
- Charge/melee specialists: about 0.78 seconds.
- Zhang Jiao: about 0.95 seconds.
- Lu Bu: about 1.05 seconds.

## Acceptance checks
- A special attack cannot execute on the same frame its cooldown expires.
- Warning banner and red area appear before damage is released.
- The special executes once when the timer reaches zero.
- Existing boss cooldown assignment remains active after the telegraph begins.
""",
    encoding="utf-8",
)
print("Alpha.30 boss telegraph patch applied")
