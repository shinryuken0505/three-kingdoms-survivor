from pathlib import Path
root=Path(__file__).resolve().parents[1]
s=(root/'scripts/main.gd').read_text(encoding='utf-8')
checks={
'alpha12 version':'V2.0.0-alpha.12' in s,
'manual save option':'儲存章節進度' in s,
'support cycling':'func cycle_support_assignment' in s,
'camp saved':'"camp_heroes": camp_heroes.duplicate()' in s,
'reserve limit':'func reserve_limit()' in s,
'save time display':'最後存檔：%s' in s,
}
failed=[k for k,v in checks.items() if not v]
for k,v in checks.items(): print(('PASS' if v else 'FAIL'),k)
raise SystemExit(1 if failed else 0)
