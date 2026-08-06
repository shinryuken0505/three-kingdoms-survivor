from pathlib import Path
import re

MAIN = Path("scripts/main.gd")
REPORT = Path("docs/art/alpha31_boss_telegraph_shapes_report.md")
text = MAIN.read_text(encoding="utf-8")

text = text.replace(
    'const Alpha27ActionProfiles = preload("res://scripts/systems/combat/alpha27_action_profiles.gd")',
    'const Alpha27ActionProfiles = preload("res://scripts/systems/combat/alpha27_action_profiles.gd")\nconst Alpha31TelegraphShapes = preload("res://scripts/systems/boss/alpha31_telegraph_shapes.gd")',
)
text = text.replace(
    'const GAME_VERSION: String = "V2.0.0-alpha.30"',
    'const GAME_VERSION: String = "V2.0.0-alpha.31"',
)

pattern = re.compile(
    r'\tvar warning_pos: Vector2 = boss\.get\("telegraph_target", boss\.get\("pos", Vector2\.ZERO\)\)\n'
    r'\tzones\.append\(\{.*?\n\t\}\)\n'
    r'\tplay_sfx\("boss_warning", 1\.0\)',
    re.S,
)
replacement = (
    '\tvar warning_pos: Vector2 = boss.get("telegraph_target", boss.get("pos", Vector2.ZERO))\n'
    '\tAlpha31TelegraphShapes.append_visuals(zones, boss, warning_pos, duration)\n'
    '\tplay_sfx("boss_warning", 1.0)'
)
text, count = pattern.subn(replacement, text, count=1)
if count != 1:
    raise SystemExit("Alpha.31 could not replace the Alpha.30 circle telegraph block")

renderer_anchor = '\t\t\t"ring_visual":\n\t\t\t\tdraw_arc(p, float(z["r"]) * alpha, 0, TAU, 48, z.get("color", Color.WHITE), 3.0)'
renderer_replacement = '''\t\t\t"telegraph_circle":
\t\t\t\tvar pulse: float = 0.82 + sin(Time.get_ticks_msec() * 0.018) * 0.10
\t\t\t\tvar circle_radius: float = float(z.get("r", 150.0))
\t\t\t\tdraw_circle(p, circle_radius, Color(0.78, 0.05, 0.04, 0.15 * pulse), true)
\t\t\t\tdraw_arc(p, circle_radius, 0.0, TAU, 56, Color(1.0, 0.20, 0.12, 0.92), 4.0)
\t\t\t\tdraw_arc(p, circle_radius * clamp(1.0 - alpha, 0.08, 1.0), 0.0, TAU, 48, Color(1.0, 0.72, 0.30, 0.88), 2.0)
\t\t\t"telegraph_line":
\t\t\t\tvar line_dir: Vector2 = z.get("dir", Vector2.RIGHT) as Vector2
\t\t\t\tvar line_length: float = float(z.get("length", 360.0))
\t\t\t\tvar line_width: float = float(z.get("width", 76.0))
\t\t\t\tvar side: Vector2 = line_dir.orthogonal() * line_width * 0.5
\t\t\t\tvar line_end: Vector2 = p + line_dir * line_length
\t\t\t\tvar polygon := PackedVector2Array([p - side, p + side, line_end + side, line_end - side])
\t\t\t\tdraw_colored_polygon(polygon, Color(0.78, 0.05, 0.04, 0.17))
\t\t\t\tdraw_polyline(PackedVector2Array([p - side, line_end - side, line_end + side, p + side]), Color(1.0, 0.20, 0.12, 0.94), 4.0)
\t\t\t\tdraw_line(p, line_end, Color(1.0, 0.72, 0.30, 0.90), 2.0)
\t\t\t"telegraph_sector":
\t\t\t\tvar sector_angle: float = float(z.get("angle", 0.0))
\t\t\t\tvar half_angle: float = float(z.get("half_angle", deg_to_rad(36.0)))
\t\t\t\tvar sector_radius: float = float(z.get("radius", 230.0))
\t\t\t\tvar points := PackedVector2Array([p])
\t\t\t\tvar segments: int = 28
\t\t\t\tfor sector_index in range(segments + 1):
\t\t\t\t\tvar t: float = float(sector_index) / float(segments)
\t\t\t\t\tpoints.append(p + Vector2.from_angle(lerp(sector_angle - half_angle, sector_angle + half_angle, t)) * sector_radius)
\t\t\t\tdraw_colored_polygon(points, Color(0.78, 0.05, 0.04, 0.17))
\t\t\t\tdraw_arc(p, sector_radius, sector_angle - half_angle, sector_angle + half_angle, segments, Color(1.0, 0.20, 0.12, 0.94), 4.0)
\t\t\t\tdraw_line(p, p + Vector2.from_angle(sector_angle - half_angle) * sector_radius, Color(1.0, 0.20, 0.12, 0.94), 3.0)
\t\t\t\tdraw_line(p, p + Vector2.from_angle(sector_angle + half_angle) * sector_radius, Color(1.0, 0.20, 0.12, 0.94), 3.0)
\t\t\t"ring_visual":
\t\t\t\tdraw_arc(p, float(z["r"]) * alpha, 0, TAU, 48, z.get("color", Color.WHITE), 3.0)'''
if renderer_anchor not in text:
    raise SystemExit("Alpha.31 renderer anchor not found")
text = text.replace(renderer_anchor, renderer_replacement, 1)

# Keep new warning zones eligible for visual cleanup under pressure.
text = text.replace(
    '["ring_visual", "impact_visual", "slash_visual", "shockwave_visual", "hero_effect", "hero_line_visual", "hero_arrow_visual"]',
    '["ring_visual", "telegraph_circle", "telegraph_line", "telegraph_sector", "impact_visual", "slash_visual", "shockwave_visual", "hero_effect", "hero_line_visual", "hero_arrow_visual"]',
)

MAIN.write_text(text, encoding="utf-8")
REPORT.parent.mkdir(parents=True, exist_ok=True)
REPORT.write_text(
    """# Alpha.31 Boss Telegraph Shapes\n\n"
    "- Added circle, multi-circle, line-charge, and sector telegraphs.\n"
    "- Locked telegraph direction and origin at cast start.\n"
    "- Added distinct profiles for Zhang Jiao/Zhang Liang, Cao Ren, Gao Shun/Zhang He, Hua Xiong, and Lu Bu.\n"
    "- Added pulse/fill/border rendering so danger areas remain readable without covering the entire battlefield.\n"
    "- Updated visual cleanup rules for the new telegraph zone kinds.\n"
    "- Manual QA remains required to compare each displayed area against the final damage collision.\n"
    """,
    encoding="utf-8",
)
print("Alpha.31 telegraph shapes applied")
