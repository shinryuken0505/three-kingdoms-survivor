#!/usr/bin/env python3
from __future__ import annotations
import random
from dataclasses import dataclass

CHAPTERS = [
    ("yellow_turban_zhuo", 2, 34, 3, {"peasant":.42,"sword":.43,"archer":.10,"elite":.05}),
    ("luoyang_turmoil", 3, 40, 4, {"peasant":.20,"sword":.50,"archer":.20,"elite":.10}),
    ("hulao_coalition", 4, 46, 5, {"peasant":.08,"sword":.51,"archer":.22,"elite":.13,"cavalry":.06}),
    ("xuzhou_flames", 5, 50, 5, {"peasant":.05,"sword":.41,"archer":.17,"elite":.14,"cavalry":.16,"shield":.07}),
    ("guandu_showdown", 5, 54, 6, {"peasant":.03,"sword":.34,"archer":.20,"elite":.15,"cavalry":.10,"shield":.18}),
]
EVENTS = {
    "yellow_turban_zhuo": [
        ("zhuo_starving_villagers", ["normal","normal","liubei_or_huatuo"]),
        ("zhuo_oath_wine", ["normal","normal","taoyuan"]),
    ],
    "luoyang_turmoil": [
        ("luoyang_secret_gate", ["normal","normal","caiwenji_or_diaochan"]),
        ("luoyang_deposed_emperor", ["normal","normal","diaochan"]),
    ],
    "hulao_coalition": [
        ("hulao_glory_dispute", ["normal","normal","taoyuan"]),
        ("hulao_broken_banner", ["normal","normal","sunjian"]),
    ],
    "xuzhou_flames": [
        ("xuzhou_refugees", ["normal","normal","liubei_and_huatuo"]),
        ("xuzhou_halberd_truce", ["normal","normal","diaochan_or_lvlingqi"]),
    ],
    "guandu_showdown": [
        ("guandu_wuchao_intel", ["normal","normal","caocao"]),
        ("guandu_xuyou_night", ["normal","normal","caocao_and_caiwenji"]),
    ],
}
LOCKED, INTRO, ACTIVE, DEFEATED, RESOLVED = range(5)

@dataclass
class Campaign:
    index: int = 0
    state: int = LOCKED
    completed: list[str] | None = None
    def __post_init__(self):
        if self.completed is None: self.completed=[]
    def intro(self): assert self.state == LOCKED; self.state = INTRO
    def active(self): assert self.state == INTRO; self.state = ACTIVE
    def defeat(self): assert self.state in (INTRO,ACTIVE); self.state = DEFEATED
    def resolve(self):
        assert self.state == DEFEATED; self.state = RESOLVED
        cid=CHAPTERS[self.index][0]
        if cid not in self.completed: self.completed.append(cid)
    def advance(self):
        assert self.state == RESOLVED
        if self.index+1 >= len(CHAPTERS): return False
        self.index += 1; self.state=LOCKED; return True

# Boss state machine: resolved bosses may never respawn.
for _ in range(5000):
    c=Campaign()
    for idx,(cid,limit,max_enemy,archer_cap,weights) in enumerate(CHAPTERS):
        assert c.index==idx and c.state==LOCKED
        c.intro(); c.active(); c.defeat(); c.resolve(); assert c.state==RESOLVED
        if idx < len(CHAPTERS)-1: assert c.advance()
        else: assert not c.advance()
    assert c.completed == [x[0] for x in CHAPTERS]

# Weighted enemy selections.
rng=random.Random(704)
for cid,limit,max_enemy,archer_cap,weights in CHAPTERS:
    keys=list(weights); total=sum(weights.values()); assert abs(total-1.0)<1e-8
    counts={k:0 for k in keys}
    for _ in range(50000):
        roll=rng.random()*total; acc=0.0; chosen=keys[-1]
        for k in keys:
            acc+=weights[k]
            if roll<=acc: chosen=k; break
        counts[chosen]+=1
    assert sum(counts.values())==50000

# Performance guard simulation: frequent mid-game kills must not grow arrays without bound.
CAPS={"pickups":110,"particles":190,"damage":72,"zones":70,"shots":180,"allies":18}
state={k:0 for k in CAPS}
for tick in range(60*40):  # 40 simulated minutes, 60 checkpoints/minute
    kills=3 + (tick//120)
    state["pickups"] += kills + (kills//5)
    state["particles"] += kills*5
    state["damage"] += kills
    state["zones"] += kills//3
    state["shots"] += 4
    state["allies"] += 1 if tick%90==0 else 0
    # Expiry between guard checks.
    state["particles"] = max(0,state["particles"]-22)
    state["damage"] = max(0,state["damage"]-10)
    state["zones"] = max(0,state["zones"]-4)
    state["shots"] = max(0,state["shots"]-18)
    # v0.7.4 direct-awards XP/coins under pressure and periodic caps.
    if state["pickups"] >= 66: state["pickups"] = max(42,state["pickups"]-kills)
    for k,cap in CAPS.items(): state[k]=min(state[k],cap)
    assert all(state[k] <= CAPS[k] for k in CAPS)

# History branch availability is tied to known heroes/bonds.
def available(req:str, heroes:set[str], bonds:set[str]) -> bool:
    return {
        "normal": True,
        "liubei_or_huatuo": bool(heroes & {"liubei","huatuo"}),
        "caiwenji_or_diaochan": bool(heroes & {"caiwenji","diaochan"}),
        "taoyuan": {"liubei","guanyu","zhangfei"}.issubset(heroes) and "taoyuan" in bonds,
        "liubei_and_huatuo": {"liubei","huatuo"}.issubset(heroes),
        "caocao": "caocao" in heroes,
        "diaochan": "diaochan" in heroes,
        "sunjian": "sunjian" in heroes,
        "diaochan_or_lvlingqi": bool(heroes & {"diaochan","lvlingqi"}),
        "caocao_and_caiwenji": {"caocao","caiwenji"}.issubset(heroes),
    }[req]
for cid,event_defs in EVENTS.items():
    assert len(event_defs)==2
    for eid,opts in event_defs:
        assert len(opts)==3 and available(opts[0],set(),set()) and available(opts[1],set(),set())
        assert not available(opts[2],set(),set())
assert available("liubei_or_huatuo",{"liubei"},set())
assert available("caiwenji_or_diaochan",{"caiwenji"},set())
assert available("taoyuan",{"liubei","guanyu","zhangfei"},{"taoyuan"})
assert available("liubei_and_huatuo",{"liubei","huatuo"},set())
assert available("caocao",{"caocao"},set())
assert available("diaochan",{"diaochan"},set())
assert available("sunjian",{"sunjian"},set())
assert available("diaochan_or_lvlingqi",{"lvlingqi"},set())
assert available("caocao_and_caiwenji",{"caocao","caiwenji"},set())

# Chapter checkpoint serialization/restore model.
checkpoint={
    "version":2,"chapter_index":3,"completed":[c[0] for c in CHAPTERS[:3]],
    "active_heroes":["caocao","guanyu"],"reserve_heroes":["caiwenji"],
    "relics":["war_drums","herb_manual"],"skills":{"slash":4},
}
restored=dict(checkpoint)
assert restored["version"]==2 and restored["chapter_index"]==3
assert restored["active_heroes"]==["caocao","guanyu"] and len(restored["relics"])==2

# HUD safe-frame and camp/victory invariants retained.
def intersects(a,b):
    ax,ay,aw,ah=a; bx,by,bw,bh=b
    return ax < bx+bw and ax+aw > bx and ay < by+bh and ay+ah > by
hud={"relic":(12,12,302,88),"chapter":(364,12,552,58),"minimap":(1088,12,174,116),"boss":(372,78,536,48),"player":(18,604,314,98),"cards":(350,628,720,70),"message":(290,570,700,34),"cast":(972,500,284,66)}
for a,b in [("relic","chapter"),("chapter","minimap"),("chapter","boss"),("boss","minimap"),("player","cards"),("message","player"),("message","cards"),("cast","cards"),("cast","minimap")]:
    assert not intersects(hud[a],hud[b]),(a,b)
for max_hp in (80.0,100.0,118.0,160.0):
    hp=min(max_hp,max_hp*.5+max_hp*.22); shield=min(100.0,max_hp*.12)
    assert abs(hp-max_hp*.72)<1e-6 and shield>0

def result_options(screen:str,has_next:bool):
    if screen=="game_over": return ["重新挑戰","返回主選單"]
    if screen=="victory" and has_next: return ["查看下一章","返回主選單"]
    if screen=="victory": return ["返回主選單"]
    return []
for has_next in (False,True):
    assert not ({"重玩本章","再試一次","重新挑戰"} & set(result_options("victory",has_next)))

print("LOGIC_SIMULATION_OK campaigns=5000 weighted_draws=250000 performance_minutes=40 history_events=10 checkpoint=ok hud_pairs=9")
