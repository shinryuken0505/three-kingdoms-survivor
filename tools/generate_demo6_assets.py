from PIL import Image, ImageDraw, ImageFilter
import numpy as np, math, wave, os, random

ROOT='/mnt/data/三國人生錄_亂世倖存Demo6_v0.6_Godot重製版'
POR=os.path.join(ROOT,'assets','portraits'); SPR=os.path.join(ROOT,'assets','sprites'); REL=os.path.join(ROOT,'assets','relics'); AUD=os.path.join(ROOT,'assets','audio')
os.makedirs(POR,exist_ok=True); os.makedirs(SPR,exist_ok=True); os.makedirs(REL,exist_ok=True); os.makedirs(AUD,exist_ok=True)

# ---------- visual helpers ----------
def hexcol(s):
    s=s.lstrip('#'); return tuple(int(s[i:i+2],16) for i in (0,2,4))

def add_noise(im, amount=10, seed=1):
    rng=np.random.default_rng(seed)
    arr=np.array(im).astype(np.int16)
    noise=rng.integers(-amount, amount+1, arr.shape[:2])[:,:,None]
    arr[:,:,:3]=np.clip(arr[:,:,:3]+noise,0,255)
    return Image.fromarray(arr.astype(np.uint8),'RGBA')

def portrait(name, cfg, variant='default'):
    random.seed(hash(name+variant)&0xffffffff)
    W,H=128,160
    bg=hexcol(cfg['bg']); accent=hexcol(cfg['accent']); armor=hexcol(cfg['armor']); skin=hexcol(cfg.get('skin','#d6a06c'))
    im=Image.new('RGBA',(W,H),bg+(255,)); d=ImageDraw.Draw(im)
    # parchment / mountains
    for y in range(H):
        t=y/H
        col=tuple(int(bg[i]*(1-t*0.25)+32*t) for i in range(3))
        d.line((0,y,W,y),fill=col+(255,))
    # distant ink mountains
    for x in range(-10,140,22):
        peak=random.randint(24,55); base=96
        c=tuple(max(0,v-35) for v in bg)
        d.polygon([(x,base),(x+12,peak),(x+28,base)],fill=c+(90,))
    # halo / faction disc
    d.ellipse((34,15,94,75), fill=accent+(45,), outline=accent+(120,), width=2)
    # cloak silhouette
    d.polygon([(18,157),(27,105),(45,88),(83,88),(102,105),(112,157)], fill=tuple(max(0,c-25) for c in armor)+(255,))
    # armor torso
    d.rounded_rectangle((28,94,100,158),8,fill=armor+(255,),outline=accent+(255,),width=2)
    # shoulder plates
    d.ellipse((18,94,48,125),fill=accent+(230,),outline=(25,20,18,255),width=2)
    d.ellipse((80,94,110,125),fill=accent+(230,),outline=(25,20,18,255),width=2)
    # armor panels
    for i in range(4):
        x=38+i*14
        d.rectangle((x,112,x+10,154),fill=tuple(max(0,c-18) for c in armor)+(255,),outline=accent+(200,))
    # neck
    d.rectangle((53,74,75,100),fill=skin+(255,))
    # hair mass
    hair=hexcol(cfg.get('hair','#211a16'))
    d.ellipse((39,35,89,91),fill=hair+(255,))
    # face
    d.ellipse((43,41,85,90),fill=skin+(255,),outline=(65,38,25,255),width=1)
    # ears
    d.ellipse((39,56,47,69),fill=skin+(255,)); d.ellipse((81,56,89,69),fill=skin+(255,))
    # eyebrows / eyes
    eye_y=60
    d.line((50,56,59,55),fill=(45,27,20,255),width=2); d.line((69,55,78,56),fill=(45,27,20,255),width=2)
    d.line((51,61,59,61),fill=(24,19,17,255),width=1); d.line((69,61,77,61),fill=(24,19,17,255),width=1)
    # nose and mouth
    d.line((64,61,62,70),fill=(120,71,47,255)); d.line((58,76,70,76),fill=(92,40,34,255),width=1)
    # hair style / helmet
    style=cfg.get('style','helmet')
    if style=='crown':
        d.rectangle((48,24,80,42),fill=hair+(255,)); d.polygon([(55,26),(60,14),(64,27),(70,13),(74,28)],fill=accent+(255,))
    elif style=='hood':
        # cloth hood frames the face without hiding it
        d.arc((34,25,94,96),180,360,fill=accent+(255,),width=8)
        d.polygon([(38,43),(44,31),(50,42)],fill=accent+(255,))
        d.polygon([(90,43),(84,31),(78,42)],fill=accent+(255,))
    elif style=='scholar':
        d.polygon([(38,42),(48,27),(80,27),(92,42),(84,48),(44,48)],fill=hair+(255,))
        d.rectangle((42,26,86,36),fill=(25,23,24,255)); d.rectangle((58,14,70,29),fill=(25,23,24,255))
    elif style=='lady':
        # side locks and parted fringe keep the face readable
        d.polygon([(42,35),(51,29),(60,39),(52,49),(44,51)],fill=hair+(255,))
        d.polygon([(86,35),(77,29),(68,39),(76,49),(84,51)],fill=hair+(255,))
        d.line((40,42,28,86),fill=hair+(255,),width=5); d.line((88,42,100,86),fill=hair+(255,),width=5)
        d.ellipse((57,18,71,31),fill=accent+(255,)); d.line((64,18,64,8),fill=accent+(255,),width=2)
        d.ellipse((60,6,68,14),fill=(235,205,120,255))
    elif style=='wild':
        for a in range(0,360,30):
            r1,r2=24,34; cx,cy=64,52
            p1=(cx+math.cos(math.radians(a))*r1, cy+math.sin(math.radians(a))*r1)
            p2=(cx+math.cos(math.radians(a+8))*r2, cy+math.sin(math.radians(a+8))*r2)
            p3=(cx+math.cos(math.radians(a+16))*r1, cy+math.sin(math.radians(a+16))*r1)
            d.polygon([p1,p2,p3],fill=hair+(255,))
    else:
        d.polygon([(38,47),(43,30),(53,21),(75,21),(85,30),(90,47),(82,50),(46,50)],fill=accent+(255,),outline=(35,27,25,255))
        d.rectangle((50,18,78,30),fill=tuple(max(0,c-20) for c in accent)+(255,))
        d.polygon([(61,18),(64,4),(68,18)],fill=(225,190,88,255))
    # beard / facial markers
    beard=cfg.get('beard','none')
    if beard=='long':
        d.polygon([(53,76),(75,76),(80,126),(64,143),(48,126)],fill=hair+(255,),outline=(20,17,15,255))
        for x in (56,61,66,71): d.line((x,82,x+random.randint(-5,5),128),fill=(70,50,38,255))
    elif beard=='short':
        d.polygon([(49,73),(79,73),(75,91),(64,97),(53,91)],fill=hair+(240,))
    elif beard=='moustache':
        d.arc((48,68,64,80),15,170,fill=hair+(255,),width=2); d.arc((64,68,80,80),10,165,fill=hair+(255,),width=2)
    # accessories
    if cfg.get('scar'):
        d.line((75,53,70,73),fill=(120,45,38,220),width=1)
    if cfg.get('fan'):
        d.polygon([(88,107),(121,87),(111,128)],fill=(235,228,205,255),outline=accent+(255,))
        for i in range(5): d.line((89,108,116-i*2,92+i*7),fill=accent+(180,))
    if cfg.get('bow'):
        d.arc((3,84,41,151),270,90,fill=(85,47,24,255),width=3); d.line((22,84,22,151),fill=(220,210,175,255))
    if cfg.get('weapon')=='halberd':
        d.line((101,76,115,157),fill=(65,48,33,255),width=3); d.polygon([(96,80),(110,68),(118,79),(107,83)],fill=(190,190,185,255))
    if cfg.get('weapon')=='blade':
        d.line((10,118,39,85),fill=(75,50,28,255),width=3); d.polygon([(5,117),(35,80),(43,88),(15,125)],fill=(193,205,196,255))
    # frame
    d.rectangle((2,2,W-3,H-3),outline=(19,18,17,255),width=2)
    d.rectangle((5,5,W-6,H-6),outline=accent+(180,),width=1)
    im=add_noise(im,5,seed=abs(hash(name+variant))%9999)
    im=im.resize((256,320),Image.Resampling.NEAREST)
    im.save(os.path.join(POR,f'{name}_{variant}.png'))


def sprite_sheet(name,cfg,variant='default'):
    # 4 frame, 32x32 pixel sprite
    W,H=128,32
    im=Image.new('RGBA',(W,H),(0,0,0,0)); d=ImageDraw.Draw(im)
    armor=hexcol(cfg['armor']); accent=hexcol(cfg['accent']); skin=hexcol(cfg.get('skin','#d6a06c')); hair=hexcol(cfg.get('hair','#211a16'))
    for f in range(4):
        ox=f*32; bob=1 if f in (1,3) else 0
        # shadow
        d.ellipse((ox+8,26,ox+24,30),fill=(0,0,0,85))
        # legs
        d.rectangle((ox+10,21+bob,ox+14,28+bob),fill=(42,35,30,255)); d.rectangle((ox+18,21-bob,ox+22,28-bob),fill=(42,35,30,255))
        # body / shoulders
        d.rectangle((ox+9,12+bob,ox+23,23+bob),fill=armor+(255,),outline=(20,16,14,255))
        d.rectangle((ox+6,13+bob,ox+10,19+bob),fill=accent+(255,)); d.rectangle((ox+22,13+bob,ox+26,19+bob),fill=accent+(255,))
        # head
        d.rectangle((ox+12,6+bob,ox+20,13+bob),fill=skin+(255,)); d.rectangle((ox+11,4+bob,ox+21,8+bob),fill=hair+(255,))
        style=cfg.get('style','helmet')
        if style in ('helmet','hood'):
            d.polygon([(ox+10,7+bob),(ox+12,2+bob),(ox+20,2+bob),(ox+22,7+bob)],fill=accent+(255,))
        elif style=='lady':
            d.rectangle((ox+9,5+bob,ox+12,14+bob),fill=hair+(255,)); d.rectangle((ox+20,5+bob,ox+23,14+bob),fill=hair+(255,)); d.point((ox+16,2+bob),fill=accent+(255,))
        elif style=='scholar':
            d.rectangle((ox+10,3+bob,ox+22,6+bob),fill=(28,25,25,255)); d.rectangle((ox+15,0+bob,ox+17,4+bob),fill=(28,25,25,255))
        # weapon silhouette
        if cfg.get('bow'):
            d.arc((ox+22,8+bob,ox+31,27+bob),270,90,fill=(109,64,31,255),width=1)
        elif cfg.get('weapon')=='halberd':
            d.line((ox+25,5+bob,ox+28,28+bob),fill=(93,64,35,255),width=2); d.line((ox+24,7+bob,ox+30,4+bob),fill=(210,210,200,255),width=2)
        elif cfg.get('weapon')=='blade' or cfg.get('beard')=='long':
            d.line((ox+25,8+bob,ox+30,27+bob),fill=(190,200,190,255),width=2)
        elif cfg.get('fan'):
            d.polygon([(ox+23,12+bob),(ox+31,8+bob),(ox+29,18+bob)],fill=(226,218,194,255))
    im.save(os.path.join(SPR,f'{name}_{variant}.png'))

# Character palettes and features
chars={
'swordsman':dict(bg='#5d3d27',accent='#d7a84a',armor='#7b4b2f',style='helmet',hair='#241a14',weapon='blade'),
'hunter':dict(bg='#314a3b',accent='#b6d8b0',armor='#506b4c',style='hood',hair='#2a2119',bow=True),
'poisoner':dict(bg='#3d324b',accent='#b8e080',armor='#514364',style='scholar',hair='#18171b',fan=True),
'heroine':dict(bg='#5c3041',accent='#e5b5be',armor='#7c4658',style='lady',hair='#22151a',weapon='blade'),
'liubei':dict(bg='#4b3927',accent='#d8c07a',armor='#88704c',style='crown',hair='#2a211a',beard='short',weapon='blade'),
'guanyu':dict(bg='#1e4637',accent='#c49a45',armor='#315f48',style='helmet',hair='#171412',beard='long',weapon='blade'),
'zhangfei':dict(bg='#493026',accent='#d36a45',armor='#654039',style='wild',hair='#15120f',beard='short',scar=True,weapon='halberd'),
'huatuo':dict(bg='#47594a',accent='#d9e5cf',armor='#728174',style='scholar',hair='#e7e2d2',beard='long',fan=True),
'caocao':dict(bg='#2e3547',accent='#c0b9a6',armor='#485167',style='crown',hair='#17191f',beard='moustache',weapon='blade'),
'sunjian':dict(bg='#55352b',accent='#d4a34b',armor='#744438',style='helmet',hair='#241812',beard='short',weapon='blade'),
'taishici':dict(bg='#2f4152',accent='#d9e0e8',armor='#4d6072',style='helmet',hair='#1f2022',bow=True),
'zhangjiao':dict(bg='#5a4b23',accent='#e7d459',armor='#75652c',style='hood',hair='#382d1e',beard='long',fan=True),
'diaochan':dict(bg='#523044',accent='#e9c0cb',armor='#7a4665',style='lady',hair='#21131c',fan=True),
'sunshangxiang':dict(bg='#5d3426',accent='#ecb76c',armor='#844b34',style='lady',hair='#251711',bow=True),
'zhenji':dict(bg='#333e5a',accent='#cddaf2',armor='#52617f',style='lady',hair='#191c28',fan=True),
'lvlingqi':dict(bg='#49304c',accent='#d8a1df',armor='#6b4770',style='helmet',hair='#211522',weapon='halberd'),
'lvbu':dict(bg='#481f24',accent='#e6b044',armor='#722d35',style='helmet',hair='#1b1012',beard='short',weapon='halberd'),
'zhangliang':dict(bg='#5b4821',accent='#e5cf55',armor='#72602b',style='hood',hair='#35291b',beard='short',fan=True),
'guan_young':dict(bg='#284a3a',accent='#d9b45e',armor='#486a53',style='helmet',hair='#191512',beard='short',weapon='blade'),
'diaochan_red':dict(bg='#612c36',accent='#f1c3b2',armor='#8c4555',style='lady',hair='#221318',fan=True),
}

for name,cfg in chars.items():
    if name=='guan_young': portrait('guanyu',cfg,'young'); sprite_sheet('guanyu',cfg,'young')
    elif name=='diaochan_red': portrait('diaochan',cfg,'red'); sprite_sheet('diaochan',cfg,'red')
    else: portrait(name,cfg,'default'); sprite_sheet(name,cfg,'default')

# enemies
for en,cfg in {
 'enemy_peasant':dict(armor='#7a673f',accent='#c3a761',hair='#2b2318',style='hood'),
 'enemy_sword':dict(armor='#6c3f34',accent='#b96a52',hair='#211815',style='helmet',weapon='blade'),
 'enemy_archer':dict(armor='#4b5940',accent='#96a56e',hair='#241d16',style='hood',bow=True),
 'enemy_elite':dict(armor='#5a3140',accent='#c76e7b',hair='#1c1517',style='helmet',weapon='halberd'),
 'ally_militia':dict(armor='#726343',accent='#d5c58c',hair='#2a231a',style='hood',weapon='blade'),
}.items():
    cfg.update(bg='#40372d',skin='#c08d5f')
    sprite_sheet(en,cfg,'default')

# relic icons
relics={
 'qingnang':('#719c78','十'), 'arrowhead':('#c7d6e4','➤'), 'warbanner':('#b34d42','旗'), 'ironbracer':('#737d87','甲'),
 'poisonbag':('#775897','毒'), 'dilu':('#9d7a4a','馬'), 'tigerseal':('#c58d39','虎'), 'artofwar':('#b0a273','策'),
 'jade':('#6fae9c','玉'), 'frostjade':('#86aeca','冰'), 'crossbow':('#8d6a43','弩'), 'redhare':('#b24739','赤'),
 'yellowwater':('#c8b143','符'), 'copperfan':('#ad7b6f','扇'), 'moonbell':('#a777a7','鈴')
}
for key,(c,mark) in relics.items():
    im=Image.new('RGBA',(32,32),(0,0,0,0)); d=ImageDraw.Draw(im); col=hexcol(c)
    d.rounded_rectangle((2,2,29,29),5,fill=tuple(max(0,x-35) for x in col)+(255,),outline=col+(255,),width=2)
    # symbolic geometric glyph; Chinese text omitted to avoid font dependency in asset
    if key in ('qingnang','yellowwater'):
        d.rectangle((14,7,18,25),fill=(235,230,190,255)); d.rectangle((8,13,24,18),fill=(235,230,190,255))
    elif key in ('arrowhead','crossbow'):
        d.polygon([(6,16),(24,8),(18,16),(24,24)],fill=(230,230,220,255))
    elif key in ('warbanner','tigerseal'):
        d.line((9,5,9,27),fill=(230,220,180,255),width=2); d.polygon([(10,6),(25,10),(10,16)],fill=(230,185,95,255))
    elif key in ('poisonbag','moonbell'):
        d.ellipse((8,10,24,26),fill=(210,185,220,255)); d.rectangle((12,6,20,12),fill=(190,160,200,255))
    elif key in ('dilu','redhare'):
        d.arc((6,5,26,26),190,340,fill=(235,220,185,255),width=3); d.line((12,19,8,27),fill=(235,220,185,255),width=2); d.line((20,19,24,27),fill=(235,220,185,255),width=2)
    elif key in ('ironbracer',):
        d.polygon([(9,6),(23,6),(26,14),(22,27),(10,27),(6,14)],fill=(205,210,215,255),outline=(80,85,90,255))
    elif key in ('artofwar','jade','frostjade','copperfan'):
        d.ellipse((7,7,25,25),outline=(230,225,195,255),width=3); d.line((11,21,22,10),fill=(230,225,195,255),width=2)
    im=im.resize((64,64),Image.Resampling.NEAREST); im.save(os.path.join(REL,key+'.png'))

# Menu background 1280x720, painterly pixel landscape
W,H=1280,720
im=Image.new('RGB',(W,H)); px=im.load()
for y in range(H):
    t=y/H
    col=(int(30+55*(1-t)),int(42+52*(1-t)),int(45+40*(1-t))) if y<430 else (56,64,45)
    for x in range(W): px[x,y]=col
d=ImageDraw.Draw(im,'RGBA')
# sun and clouds
d.ellipse((910,85,1050,225),fill=(225,174,88,155))
for x,y,w in [(120,105,320),(530,165,280),(850,260,290)]:
    d.ellipse((x,y,x+w,y+55),fill=(200,188,165,30))
# mountains layers
for layer,(base,color,amp) in enumerate([(390,(27,34,38,220),170),(480,(35,48,43,230),130),(560,(48,59,43,255),90)]):
    pts=[(0,base)]
    for x in range(0,W+80,80): pts.append((x,base-random.randint(20,amp)))
    pts += [(W,H),(0,H)]
    d.polygon(pts,fill=color)
# river
d.polygon([(0,610),(430,545),(800,600),(1280,555),(1280,720),(0,720)],fill=(55,78,82,180))
# banners and soldiers
for x in range(120,1180,110):
    y=545+random.randint(-25,30)
    d.line((x,y-55,x,y+10),fill=(40,29,20,255),width=5)
    flag=(147,54,42,245) if x%220==120 else (182,148,55,245)
    d.polygon([(x+3,y-53),(x+48,y-42),(x+3,y-20)],fill=flag)
    d.ellipse((x-6,y-5,x+8,y+9),fill=(20,18,17,255)); d.rectangle((x-8,y+8,x+10,y+34),fill=(28,25,22,255))
# title panel brush frame
d.rounded_rectangle((62,65,590,315),22,fill=(18,20,19,180),outline=(191,153,82,220),width=3)
# texture and pixel blocks
im=im.resize((640,360),Image.Resampling.BILINEAR).resize((1280,720),Image.Resampling.NEAREST)
im=add_noise(im.convert('RGBA'),4,44).convert('RGB')
im.save(os.path.join(ROOT,'assets','menu_background.png'))

# icon
icon=Image.new('RGBA',(128,128),(25,32,29,255)); d=ImageDraw.Draw(icon)
d.ellipse((12,12,116,116),fill=(44,68,55,255),outline=(216,174,83,255),width=6)
d.polygon([(64,18),(82,50),(110,57),(88,78),(92,110),(64,94),(36,110),(40,78),(18,57),(46,50)],fill=(186,69,50,255),outline=(238,202,116,255))
d.ellipse((49,47,79,77),fill=(36,42,35,255),outline=(240,214,150,255),width=3)
icon.save(os.path.join(ROOT,'assets','icon.png'))

# ---------- audio generation ----------
SR=22050

def write_wav(path, data):
    data=np.clip(data,-1,1)
    pcm=(data*32767).astype(np.int16)
    with wave.open(path,'wb') as wf:
        wf.setnchannels(1); wf.setsampwidth(2); wf.setframerate(SR); wf.writeframes(pcm.tobytes())

def note(freq,dur,kind='pluck',amp=.25):
    n=int(SR*dur); t=np.arange(n)/SR
    if kind=='pluck': env=np.exp(-4.8*t/dur); sig=np.sin(2*np.pi*freq*t)+.35*np.sin(2*np.pi*freq*2*t)+.15*np.sin(2*np.pi*freq*3*t)
    elif kind=='flute': env=np.minimum(1,t/.08)*np.minimum(1,(dur-t)/.12); sig=np.sin(2*np.pi*freq*t)+.18*np.sin(2*np.pi*freq*2*t)
    else: env=np.ones(n); sig=np.sin(2*np.pi*freq*t)
    return amp*env*sig

def drum(dur=.35,amp=.5,high=False):
    n=int(SR*dur); t=np.arange(n)/SR; rng=np.random.default_rng(3)
    if high: sig=rng.normal(0,1,n)*np.exp(-15*t)
    else: sig=np.sin(2*np.pi*(95-55*t/dur)*t)*np.exp(-9*t)
    return amp*sig

pent=[146.83,164.81,196.0,220.0,261.63,293.66]

def make_track(seconds,tempo,melody,boss=False):
    N=int(SR*seconds); out=np.zeros(N); beat=60/tempo
    for i,idx in enumerate(melody):
        st=i*beat*.5
        if st>=seconds: break
        freq=pent[idx%len(pent)]*(2 if idx>=6 else 1)
        wavev=note(freq,beat*.9,'pluck',.16 if not boss else .2)
        a=int(st*SR); out[a:min(N,a+len(wavev))]+=wavev[:max(0,min(N-a,len(wavev)))]
    for i in range(int(seconds/beat)+1):
        st=i*beat; a=int(st*SR)
        dv=drum(.32,.28 if not boss else .42,False); out[a:min(N,a+len(dv))]+=dv[:max(0,min(N-a,len(dv)))]
        if boss or i%2==1:
            a2=int((st+beat*.5)*SR); hv=drum(.16,.08 if not boss else .14,True); out[a2:min(N,a2+len(hv))]+=hv[:max(0,min(N-a2,len(hv)))]
    # drone
    t=np.arange(N)/SR; out += .04*np.sin(2*np.pi*73.42*t)+.025*np.sin(2*np.pi*110*t)
    # fade edges
    f=int(.25*SR); out[:f]*=np.linspace(0,1,f); out[-f:]*=np.linspace(1,0,f)
    return out

menu_mel=[0,2,3,5,3,2,0,1,2,4,3,1]*8
battle_mel=[0,2,3,2,4,3,5,4,2,3,1,2,0,3,4,5]*10
boss_mel=[0,3,5,4,3,5,7,5,4,2,5,7,8,7,5,3]*12
write_wav(os.path.join(AUD,'bgm_menu.wav'),make_track(36,72,menu_mel,False))
write_wav(os.path.join(AUD,'bgm_battle.wav'),make_track(40,112,battle_mel,False))
write_wav(os.path.join(AUD,'bgm_boss.wav'),make_track(32,138,boss_mel,True))

# SFX
sfx={}
sfx['ui_confirm']=note(660,.12,'pluck',.35)+np.pad(note(880,.08,'pluck',.25),(int(.04*SR),0))[:int(.12*SR)]
sfx['ui_move']=note(440,.08,'pluck',.22)
sfx['hit']=drum(.16,.42,True)+drum(.16,.25,False)
sfx['hurt']=note(130,.25,'pluck',.4)
sfx['arrow']=note(980,.12,'flute',.22)
sfx['slash']=note(260,.18,'flute',.32)
sfx['pickup']=note(880,.18,'pluck',.3)
sfx['levelup']=np.concatenate([note(440,.12,'pluck',.28),note(554,.12,'pluck',.28),note(659,.2,'pluck',.32)])
sfx['hero']=np.concatenate([drum(.22,.35,False),note(392,.5,'flute',.25)])
sfx['boss_intro']=np.concatenate([drum(.5,.6,False),np.zeros(int(.12*SR)),drum(.7,.7,False)])
sfx['heal']=note(523,.55,'flute',.22)+note(659,.55,'flute',.14)
sfx['poison']=note(185,.35,'flute',.18)+.08*np.random.default_rng(1).normal(0,1,int(.35*SR))*np.exp(-np.linspace(0,5,int(.35*SR)))
sfx['dash']=note(330,.14,'flute',.28)
for k,v in sfx.items(): write_wav(os.path.join(AUD,k+'.wav'),v)

print('generated assets',ROOT)
