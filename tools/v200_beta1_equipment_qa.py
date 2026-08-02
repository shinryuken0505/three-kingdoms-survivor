from pathlib import Path

root = Path(__file__).resolve().parents[1]
main = (root / "scripts/main.gd").read_text(encoding="utf-8")
data = (root / "scripts/game_data.gd").read_text(encoding="utf-8")
checks = {
    "version": 'V2.0.0-beta.1' in main,
    "new slots": all(x in main for x in ['"accessory":""', '"jade":""']),
    "unlock rules": all(x in main for x in ['"accessory": return 4', '"jade": return 7']),
    "locked equip guard": 'if not equipment_slot_unlocked(slot):' in main,
    "new equipment": all(x in data for x in ['swift_ring', 'soul_bead', 'army_pendant', 'azure_jade', 'vermilion_jade', 'black_jade']),
}
failed = [name for name, ok in checks.items() if not ok]
if failed:
    raise SystemExit("BETA1 EQUIPMENT QA FAIL: " + ", ".join(failed))
print("BETA1 EQUIPMENT QA: PASS")
