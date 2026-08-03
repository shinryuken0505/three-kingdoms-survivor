from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

required_files = [
    ROOT / "scripts/ui/intermission_visual_layer.gd",
    ROOT / "scripts/ui/recruitment_roster_visual_layer.gd",
    ROOT / "scripts/ui/screens/intermission_input_controller.gd",
    ROOT / "main.tscn",
]

missing = [str(path.relative_to(ROOT)) for path in required_files if not path.exists()]
if missing:
    raise SystemExit("Missing Alpha.18 UI files: " + ", ".join(missing))

scene = (ROOT / "main.tscn").read_text(encoding="utf-8")
for node_name in ["IntermissionVisualLayer", "RecruitmentRosterVisualLayer"]:
    if node_name not in scene:
        raise SystemExit(f"Scene is missing {node_name}")

intermission = (ROOT / "scripts/ui/intermission_visual_layer.gd").read_text(encoding="utf-8")
for token in ["上一章結果", "承接資源", "史勢演變與整備", "intermission_options"]:
    if token not in intermission:
        raise SystemExit(f"Intermission visual layer is missing: {token}")

recruitment = (ROOT / "scripts/ui/recruitment_roster_visual_layer.gd").read_text(encoding="utf-8")
for token in ["編入主戰", "編入後備", "留在營地", "已滿，需替換", "replaced"]:
    if token not in recruitment:
        raise SystemExit(f"Recruitment visual layer is missing: {token}")

controller = (ROOT / "scripts/ui/screens/intermission_input_controller.gd").read_text(encoding="utf-8")
if "match action:" in controller:
    raise SystemExit("Intermission input controller still uses script constants as match patterns")
if "InputRouterScript" not in controller:
    raise SystemExit("Intermission input controller must preload InputRouter")

print("Alpha.18 intermission and recruitment UI checks passed")
