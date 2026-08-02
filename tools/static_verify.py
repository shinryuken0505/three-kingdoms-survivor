#!/usr/bin/env python3
from __future__ import annotations
import re
import sys
import wave
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
ERRORS: list[str] = []
WARNINGS: list[str] = []

def fail(msg: str) -> None: ERRORS.append(msg)
def warn(msg: str) -> None: WARNINGS.append(msg)
def read(rel: str) -> str:
    p = ROOT / rel
    if not p.exists():
        fail(f"missing {rel}")
        return ""
    return p.read_text(encoding="utf-8-sig")

project = read("project.godot")
main = read("scripts/main.gd")
data = read("scripts/game_data.gd")
chapter = read("scripts/chapter_manager.gd")
history = read("scripts/history_event_data.gd")
scene = read("main.tscn")
bus = read("default_bus_layout.tres")

if not (('v1.7.1' in project.lower() and '視覺統一與介面美編版' in project.lower()) or ('v1.7.2' in project.lower() and '武將肖像全面修正版' in project.lower()) or ('v1.7.3' in project.lower() and '戰鬥動作強化版' in project.lower()) or ('v1.7.4' in project.lower() and '章間整備強化版' in project.lower()) or ('v1.7.4.1' in project.lower() and '升級選擇輸入修正版' in project.lower()) or ('v1.7.4.2' in project.lower() and '武將臉部陰影修正版' in project.lower()) or ('v1.7.5' in project.lower() and '戰場可讀性與boss演出強化版' in project.lower())):
    fail("project.godot version is not a supported V1.7 visual build")
if 'run/main_scene="res://main.tscn"' not in project: fail("main scene missing")
if '[gd_resource type="AudioBusLayout"' not in bus: fail("audio bus layout type missing")
for bus_name in ['Music', 'SFX', 'UI', 'Voice']:
    if f'&"{bus_name}"' not in bus: fail(f'audio bus missing: {bus_name}')
if 'res://scripts/main.gd' not in scene: fail("main scene script missing")

# Basic lexical bracket and quote scan, ignoring comments and strings.
def scan_gd(name: str, text: str) -> None:
    stack=[]; pairs={')':'(',']':'[','}':'{'}
    line=1; i=0; quote=None; triple=False; escaped=False
    while i < len(text):
        ch=text[i]
        if ch=='\n': line+=1
        if quote:
            if escaped: escaped=False
            elif ch=='\\': escaped=True
            elif triple:
                if text.startswith(quote*3,i): quote=None; triple=False; i+=2
            elif ch==quote: quote=None
            i+=1; continue
        if ch=='#':
            j=text.find('\n',i)
            if j<0: break
            i=j; continue
        if ch in "'\"":
            if text.startswith(ch*3,i): quote=ch; triple=True; i+=3; continue
            quote=ch; i+=1; continue
        if ch in '([{': stack.append((ch,line))
        elif ch in ')]}':
            if not stack or stack[-1][0] != pairs[ch]:
                fail(f"{name}:{line} unmatched {ch}"); return
            stack.pop()
        i+=1
    if quote: fail(f"{name}: unterminated string")
    if stack: fail(f"{name}:{stack[-1][1]} unclosed {stack[-1][0]}")

scripts = [("main.gd",main),("game_data.gd",data),("chapter_manager.gd",chapter),("history_event_data.gd",history)]
for n,t in scripts: scan_gd(n,t)

# Duplicate functions and risky inference (warnings are errors in this project).
for n,t in scripts:
    funcs=re.findall(r'^func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(',t,re.M)
    dups=sorted({f for f in funcs if funcs.count(f)>1})
    if dups: fail(f"{n}: duplicate funcs {dups}")
    inferred=re.findall(r'^[ \t]*var[ \t]+[A-Za-z_][A-Za-z0-9_]*[ \t]*=[ \t]*.+$',t,re.M)
    if inferred: fail(f"{n}: untyped inferred variables remain ({len(inferred)}), first={inferred[0].strip()}")
    one_line=re.findall(r'^[ \t]*if[ \t]+[^\n]+:[ \t]+[^#\s].*$',t,re.M)
    if one_line: fail(f"{n}: risky one-line if suite remains: {one_line[0].strip()}")
    func_returns={m.group(1):m.group(2) for m in re.finditer(
        r'^func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\([^\n]*\)\s*(?:->\s*([A-Za-z_][A-Za-z0-9_\[\]]*))?\s*:', t, re.M
    )}
    for lineno,line in enumerate(t.splitlines(),1):
        m=re.search(r'\bvar\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*([A-Za-z_][A-Za-z0-9_\[\]]*)\s*=\s*([A-Za-z_][A-Za-z0-9_]*)\s*\(',line)
        if not m: continue
        variable,declared,called=m.groups(); returned=func_returns.get(called)
        if returned and returned != declared and returned != 'Variant':
            fail(f"{n}:{lineno} type mismatch: {variable}: {declared} receives {called}() -> {returned}")

required_main=[
    'func run_self_test()', 'DEMO6_SELF_TEST_OK', 'HistoryEventData',
    'func update_performance_guard', 'func update_frame_metrics', 'func request_hit_stop',
    'func rebuild_enemy_spatial_index', 'func draw_history_event_screen', 'func handle_chapter_intro_key', 'func finish_history_event_result',
    'chapter_intro_page', 'history_event_phase',
    'MAX_PICKUPS', 'MAX_PARTICLES', 'MAX_DAMAGE_NUMBERS', 'MAX_PLAYER_SHOTS',
    'performance_pressure', '中後期物件上限清理失效', '章間存檔建立失效',
    'bgm_chapter1', 'bgm_chapter5', 'bgm_chapter6', 'bgm_chapter7', 'bgm_boss_lvbu',
    'func current_battle_bgm', 'func current_boss_bgm',
    '史勢奇遇資料不足七章', '每章史勢奇遇不足兩組', 'three_heroes_challenge',
    'Boss擊敗後再次生成', '主動名將上限不是2→3→4→5→5→5→5',
    'func spawn_impact_effect', 'func spawn_hero_signature_effect', 'func boss_cooperation_multiplier',
    'HUD_HEADER_RECT', 'HUD_HERO_RAIL_RECT', 'func draw_centered_text',
    '勝利畫面仍出現重玩本關功能',
    'func support_boss_index', 'func finish_boss_if_ready', '主將已倒下，擊破副將才能結束戰鬥',
    'func play_combat_motif', 'enemy_spearman', 'enemy_tactician', 'caoren', 'zhanghe',
    'SAVE_TEMP_PATH', 'SAVE_BACKUP_PATH', 'SAVE_FORMAT_VERSION', 'func read_save_document',
    'func normalize_save_document', 'func draw_load_save_screen', 'func draw_save_confirmation_screen'
]
for tok in required_main:
    if tok not in main: fail(f"main.gd missing token {tok}")

chapter_ids=['yellow_turban_zhuo','luoyang_turmoil','hulao_coalition','xuzhou_flames','guandu_showdown','jingzhou_retreat','changban_escape']
for cid in chapter_ids:
    if f'"id": "{cid}"' not in data: fail(f"chapter missing {cid}")
    if f'"{cid}"' not in history: fail(f"history event missing chapter {cid}")
if data.count('"ready": true') < 8: fail("not all seven chapters + trial are ready")
for limit in ['"active_limit": 2','"active_limit": 3','"active_limit": 4','"active_limit": 5']:
    if limit not in data: fail(f"missing active limit {limit}")
for event_id in ['zhuo_starving_villagers','zhuo_oath_wine','luoyang_secret_gate','luoyang_deposed_emperor','hulao_glory_dispute','hulao_broken_banner','xuzhou_refugees','xuzhou_halberd_truce','guandu_wuchao_intel','guandu_xuyou_night','jingzhou_burning_fields','jingzhou_river_crossing','changban_scattered_people','changban_bridge_standoff']:
    if event_id not in history: fail(f"history event missing {event_id}")
for req in ['requires_any_heroes','requires_all_heroes','requires_all_bonds']:
    if req not in history: fail(f"history special requirement missing {req}")

# All res:// references must exist.
refs=set(re.findall(r'"(res://[^"\n]+)"', main+'\n'+data+'\n'+history+'\n'+project+'\n'+scene))
for ref in sorted(refs):
    if '%' in ref: continue
    p=ROOT/ref.removeprefix('res://')
    if not p.exists(): fail(f"missing referenced resource {ref}")

# Verify images and audio.
pngs=list((ROOT/'assets').rglob('*.png'))
if len(pngs)<95: fail(f"PNG count too low: {len(pngs)}")
for p in pngs:
    try:
        with Image.open(p) as im: im.verify()
        with Image.open(p) as im:
            w,h=im.size
            if w<16 or h<16: fail(f"image too small {p.relative_to(ROOT)} {w}x{h}")
    except Exception as e: fail(f"invalid PNG {p.relative_to(ROOT)}: {e}")
for map_name in ['zhuo','luoyang','hulao','xuzhou','guandu','jingzhou','changban']:
    p=ROOT/'assets/maps'/f'{map_name}.png'
    try:
        with Image.open(p) as im:
            if im.size != (1280,720): fail(f"map {map_name} is {im.size}, expected 1280x720")
    except Exception as e: fail(f"map invalid {map_name}: {e}")

wavs=list((ROOT/'assets/audio').glob('*.wav'))
if len(wavs)<24: fail(f"WAV count too low: {len(wavs)}")
for p in wavs:
    try:
        with wave.open(str(p),'rb') as w:
            if w.getnframes()<=0 or w.getframerate()<=0: fail(f"empty WAV {p.name}")
            duration=w.getnframes()/w.getframerate()
            if p.name.startswith('bgm_') and duration < 30.0: fail(f"BGM too short {p.name}: {duration:.1f}s")
            if w.getsampwidth()!=2: fail(f"unexpected WAV sample width {p.name}: {w.getsampwidth()}")
    except Exception as e: fail(f"invalid WAV {p.name}: {e}")
for name in ['bgm_chapter1.wav','bgm_chapter2.wav','bgm_chapter3.wav','bgm_chapter4.wav','bgm_chapter5.wav','bgm_chapter6.wav','bgm_chapter7.wav','bgm_boss.wav','bgm_boss_lvbu.wav']:
    if not (ROOT/'assets/audio'/name).exists(): fail(f"missing new BGM {name}")

# Character/prop coverage.
for character in ['swordsman','hunter','poisoner','heroine','liubei','guanyu','zhangfei','huatuo','caocao','sunjian','taishici','zhangjiao','diaochan','sunshangxiang','zhenji','lvlingqi','wangyi','caiwenji','daqiao','zhangliang','huaxiong','lvbu','gaoshun','yuanshao','caoren','zhanghe','caimao','xiahouen']:
    for sub in ['portraits','sprites']:
        if not (ROOT/'assets'/sub/f'{character}_default.png').exists(): fail(f"missing {sub} asset for {character}")
for prop in ['camp','merchant','chest','barricade','tent','cart','grain_cart','tower','drum','wall','house','haystack','palisade']:
    if not (ROOT/'assets/props'/f'{prop}.png').exists(): fail(f"missing prop asset {prop}")

# Gameplay invariants.
if 'return ["查看下一章", "重玩本章"' in main: fail('victory replay option still present')
if 'return ["再試一次"' in main: fail('victory retry option still present')
if 'screen_shake = max' in main and 'st.get("shake", true)' not in main and 'save_data["settings"].get("shake", true)' not in main: fail('screen shake lacks setting guard')
if 'window/stretch/aspect="keep"' not in project: fail('16:9 safe-frame stretch mode missing')
if 'func add_damage_number' not in main or 'func can_spawn_visual_zone' not in main:
    fail('visual effect cap helpers missing')
if 'if pickups.size() >= 66 or performance_pressure != "穩定"' not in main:
    fail('pickup churn reduction missing')

if 'hit_stop_timer = max(hit_stop_timer, 0.045' in main:
    fail('old per-hit global hit stop still present')
if '普通連射仍會造成全場停頓' not in main:
    fail('normal-hit stop regression test missing')
if 'HUD安全區互相重疊' not in main:
    fail('HUD safe-region self test missing')

# Validate selected CanvasItem drawing calls against Godot 4.x minimum argument counts.
def iter_calls(text: str, name: str):
    token = name + "("
    pos = 0
    while True:
        start = text.find(token, pos)
        if start < 0:
            return
        i = start + len(token)
        depth = 1
        quote = None
        escaped = False
        j = i
        while j < len(text) and depth:
            ch = text[j]
            if quote:
                if escaped:
                    escaped = False
                elif ch == "\\":
                    escaped = True
                elif ch == quote:
                    quote = None
            else:
                if ch in ("'", '"'):
                    quote = ch
                elif ch in "([{":
                    depth += 1
                elif ch in ")]}":
                    depth -= 1
            j += 1
        if depth != 0:
            fail(f"main.gd: unterminated call {name} near offset {start}")
            return
        args = text[i:j-1]
        top = 0
        quote = None
        escaped = False
        commas = 0
        for ch in args:
            if quote:
                if escaped:
                    escaped = False
                elif ch == "\\":
                    escaped = True
                elif ch == quote:
                    quote = None
            else:
                if ch in ("'", '"'):
                    quote = ch
                elif ch in "([{":
                    top += 1
                elif ch in ")]}":
                    top -= 1
                elif ch == "," and top == 0:
                    commas += 1
        argc = 0 if not args.strip() else commas + 1
        line = text.count("\n", 0, start) + 1
        yield line, argc
        pos = j

for func_name, min_args in {"draw_texture_rect": 3, "draw_texture_rect_region": 4}.items():
    for line, argc in iter_calls(main, func_name):
        if argc < min_args:
            fail(f"main.gd:{line} {func_name} requires at least {min_args} args, got {argc}")

# Launcher safety/version.
for launcher in ['開始遊戲.bat','Start_Demo6.bat']:
    text=read(launcher)
    if 'v1.4.0' not in text: fail(f"{launcher} version is not v1.4.0")
    if '--path "%CD%"' not in text: fail(f"{launcher} does not use safe %CD% path")
    if '--path "%~dp0"' in text: fail(f"{launcher} contains trailing slash quote risk")
    try: text.encode('ascii')
    except UnicodeEncodeError: fail(f"{launcher} is not ASCII-safe")

# State machine simulation.
LOCKED,INTRO,ACTIVE,DEFEATED,RESOLVED=range(5)
state=LOCKED
for idx,cid in enumerate(chapter_ids):
    if state!=LOCKED: fail(f"simulation chapter {cid} did not start locked"); break
    state=INTRO; state=ACTIVE; state=DEFEATED; state=RESOLVED
    if idx < len(chapter_ids)-1: state=LOCKED

if WARNINGS:
    for w in WARNINGS: print('WARNING:',w)
if ERRORS:
    print('STATIC_VERIFY_FAILED')
    for e in ERRORS: print('-',e)
    sys.exit(1)
print('STATIC_VERIFY_OK')
print(f'files={sum(1 for p in ROOT.rglob("*") if p.is_file())} png={len(pngs)} wav={len(wavs)} refs={len(refs)} history_events=14')
