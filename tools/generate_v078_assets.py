from __future__ import annotations
from pathlib import Path
import math, wave
from PIL import Image, ImageDraw
import numpy as np

ROOT=Path(__file__).resolve().parents[1]
POR=ROOT/'assets'/'portraits'; SPR=ROOT/'assets'/'sprites'; MAP=ROOT/'assets'/'maps'; AUDIO=ROOT/'assets'/'audio'
for p in (POR,SPR,MAP,AUDIO): p.mkdir(parents=True,exist_ok=True)

def mix(a,b,t): return tuple(round(a[i]*(1-t)+b[i]*t) for i in range(3))
def rgba(c,a=255): return (*c,a)

STYLES={
 'caoren': dict(bg=(24,38,52),accent=(104,151,190),cloth=(55,75,104),dark=(20,28,38),skin=(211,147,99),hair=(25,22,21),weapon='spear',crown=True,beard=True),
 'zhanghe':dict(bg=(49,43,33),accent=(210,187,126),cloth=(100,89,66),dark=(35,31,27),skin=(218,157,108),hair=(31,25,22),weapon='spear',crown=True,beard=False),
 'caimao':dict(bg=(24,49,52),accent=(91,176,177),cloth=(43,91,94),dark=(20,35,37),skin=(214,153,104),hair=(27,24,23),weapon='fan',crown=True,beard=True),
 'xiahouen':dict(bg=(58,30,28),accent=(201,112,77),cloth=(104,55,49),dark=(40,24,23),skin=(205,139,93),hair=(24,20,18),weapon='spear',crown=False,beard=True),
}

def portrait(key,st):
 im=Image.new('RGBA',(128,160),rgba(st['bg'])); d=ImageDraw.Draw(im,'RGBA')
 # atmospheric background
 d.ellipse((28,8,103,83),fill=rgba(st['accent'],24),outline=rgba(st['accent'],90),width=2)
 d.polygon([(0,116),(22,92),(39,111),(58,83),(80,113),(103,87),(128,110),(128,160),(0,160)],fill=rgba(mix(st['bg'],(0,0,0),.26),190))
 # body
 d.polygon([(12,160),(20,101),(43,87),(85,87),(108,103),(118,160)],fill=rgba(st['dark']))
 d.rounded_rectangle((24,91,104,159),8,fill=rgba(st['cloth']),outline=rgba(st['accent']),width=2)
 d.ellipse((14,92,50,128),fill=rgba(mix(st['accent'],st['cloth'],.25)),outline=rgba(st['dark']),width=2)
 d.ellipse((78,92,114,128),fill=rgba(mix(st['accent'],st['cloth'],.25)),outline=rgba(st['dark']),width=2)
 for x in range(39,92,12): d.rounded_rectangle((x,116,x+8,156),2,fill=rgba(mix(st['cloth'],st['dark'],.2)),outline=rgba(st['accent'],170))
 # head complete face, no black half-mask
 d.rectangle((55,76,73,96),fill=rgba(st['skin']))
 d.ellipse((39,30,89,88),fill=rgba(st['hair']))
 d.ellipse((43,37,85,88),fill=rgba(st['skin']),outline=rgba(mix(st['skin'],st['dark'],.5)),width=1)
 d.polygon([(77,43),(84,51),(83,77),(76,86),(73,80),(76,63)],fill=rgba(mix(st['skin'],st['dark'],.14),80))
 # hair/crown
 d.polygon([(39,46),(44,28),(55,22),(64,30),(75,20),(86,33),(89,47),(80,41),(70,35),(58,43),(49,35)],fill=rgba(st['hair']))
 if st['crown']:
  d.polygon([(46,31),(51,14),(58,26),(64,10),(71,26),(80,14),(83,34)],fill=rgba(st['accent']),outline=rgba(st['dark']))
 # face
 brow=mix(st['hair'],(0,0,0),.25)
 d.line((49,55,58,53),fill=rgba(brow),width=2); d.line((70,53,79,55),fill=rgba(brow),width=2)
 d.ellipse((49,57,59,67),fill=(240,229,211,255),outline=rgba(st['dark']))
 d.ellipse((69,57,79,67),fill=(240,229,211,255),outline=rgba(st['dark']))
 d.ellipse((53,59,57,65),fill=rgba(mix(st['dark'],st['accent'],.25))); d.ellipse((71,59,75,65),fill=rgba(mix(st['dark'],st['accent'],.25)))
 d.line((64,61,62,72),fill=rgba(mix(st['skin'],st['dark'],.35))); d.line((58,78,70,78),fill=(104,55,43,255))
 if st['beard']:
  d.polygon([(52,76),(76,76),(73,94),(64,101),(55,94)],fill=rgba(st['hair']))
 # weapon aside
 if st['weapon']=='spear':
  d.line((105,61,115,157),fill=(112,77,40,255),width=3); d.polygon([(100,68),(111,52),(120,66),(111,73)],fill=(224,225,214,255),outline=rgba(st['dark']))
 else:
  d.polygon([(100,92),(119,77),(113,111)],fill=rgba((220,210,177)),outline=rgba(st['dark'])); d.line((105,99,115,145),fill=rgba((102,72,43)),width=2)
 d.rectangle((2,2,125,157),outline=rgba(st['dark']),width=2); d.rectangle((5,5,122,154),outline=rgba(st['accent'],160),width=1)
 im.resize((256,320),Image.Resampling.NEAREST).save(POR/f'{key}_default.png')

def sprite(key,st):
 im=Image.new('RGBA',(256,64),(0,0,0,0)); d=ImageDraw.Draw(im,'RGBA')
 for f in range(4):
  ox=f*64; bob=1 if f in (1,3) else 0; arm=[0,2,0,-2][f]; leg=[0,1,0,-1][f]
  d.ellipse((ox+14,51,ox+50,60),fill=(0,0,0,75)); d.rectangle((ox+21,41+leg,ox+28,55+leg),fill=rgba(st['dark'])); d.rectangle((ox+36,41-leg,ox+43,55-leg),fill=rgba(st['dark']))
  d.rectangle((ox+19,25+bob,ox+45,45+bob),fill=rgba(st['cloth']),outline=rgba(st['dark'])); d.rectangle((ox+13,28+bob+arm,ox+21,39+bob+arm),fill=rgba(st['accent'])); d.rectangle((ox+43,28+bob-arm,ox+51,39+bob-arm),fill=rgba(st['accent']))
  d.rectangle((ox+24,14+bob,ox+40,28+bob),fill=rgba(st['skin']),outline=rgba(st['dark'])); d.point((ox+28,20+bob),fill=rgba(st['dark'])); d.point((ox+36,20+bob),fill=rgba(st['dark']))
  d.polygon([(ox+21,16+bob),(ox+25,8+bob),(ox+32,12+bob),(ox+39,7+bob),(ox+44,16+bob)],fill=rgba(st['hair']))
  if st['crown']: d.polygon([(ox+23,10+bob),(ox+27,2+bob),(ox+31,9+bob),(ox+35,1+bob),(ox+39,9+bob),(ox+43,3+bob),(ox+44,12+bob)],fill=rgba(st['accent']))
  if st['beard']: d.polygon([(ox+26,25+bob),(ox+38,25+bob),(ox+36,35+bob),(ox+32,39+bob),(ox+28,35+bob)],fill=rgba(st['hair']))
  if st['weapon']=='spear':
   d.line((ox+51,8+bob,ox+56,56+bob),fill=(111,76,39,255),width=3); d.polygon([(ox+47,12+bob),(ox+54,3+bob),(ox+61,11+bob),(ox+55,15+bob)],fill=(225,225,214,255))
  else:
   d.polygon([(ox+49,25+bob),(ox+61,17+bob),(ox+57,37+bob)],fill=rgba((218,207,174)),outline=rgba(st['dark']))
 im.save(SPR/f'{key}_default.png')

for k,st in STYLES.items(): portrait(k,st); sprite(k,st)

# New enemy sheets derived from existing silhouettes with distinct weapons/colors.
def recolor_enemy(src_name,out_name,palette,weapon):
 src=Image.open(SPR/src_name).convert('RGBA'); pix=src.load()
 for y in range(src.height):
  for x in range(src.width):
   r,g,b,a=pix[x,y]
   if a==0: continue
   lum=(r+g+b)/3
   if lum<70: c=palette[0]
   elif lum<145: c=palette[1]
   else: c=palette[2]
   pix[x,y]=(*c,a)
 d=ImageDraw.Draw(src,'RGBA')
 for f in range(4):
  ox=f*64
  if weapon=='spear':
   d.line((ox+48,8,ox+58,57),fill=(112,77,39,255),width=3); d.polygon([(ox+44,12),(ox+52,2),(ox+61,10),(ox+53,16)],fill=(226,228,219,255))
  else:
   d.polygon([(ox+45,18),(ox+61,10),(ox+57,32)],fill=(187,205,220,255),outline=(30,39,46,255)); d.line((ox+50,27,ox+58,50),fill=(96,67,39,255),width=2)
 src.save(SPR/out_name)
recolor_enemy('enemy_sword_default.png','enemy_spearman_default.png',((30,34,38),(82,101,119),(178,194,205)),'spear')
recolor_enemy('enemy_crossbow_default.png','enemy_tactician_default.png',((25,33,42),(54,91,119),(139,177,201)),'fan')

# Maps
def map_jingzhou():
 im=Image.new('RGB',(1280,720),(53,74,58)); d=ImageDraw.Draw(im,'RGBA')
 # fields
 for y in range(0,720,72): d.rectangle((0,y,1280,y+34),fill=(69,91,63,115))
 # broad river
 river=[(-80,130),(300,70),(650,230),(980,170),(1360,300),(1360,485),(960,350),(620,420),(260,255),(-80,330)]
 d.polygon(river,fill=(55,101,117,255))
 for i in range(18):
  x=i*90-100; d.line((x,205,x+260,290),fill=(115,172,178,55),width=3)
 # bridge
 d.polygon([(545,252),(635,270),(702,404),(612,385)],fill=(104,70,42,255),outline=(55,40,28,255))
 for i in range(7): d.line((563+i*20,260+i*4,630+i*20,394+i*4),fill=(188,139,78,180),width=3)
 # villages/trees
 for x,y in [(150,470),(240,520),(1040,90),(1125,135)]:
  d.rectangle((x,y,x+65,y+42),fill=(101,68,43,230)); d.polygon([(x-8,y),(x+32,y-25),(x+73,y)],fill=(70,45,32,245))
 for x,y in [(80,90),(180,170),(1050,500),(1160,580),(880,570)]:
  d.rectangle((x-4,y,x+4,y+36),fill=(64,44,29,255)); d.ellipse((x-24,y-27,x+26,y+18),fill=(45,90,50,240))
 im.save(MAP/'jingzhou.png')

def map_changban():
 im=Image.new('RGB',(1280,720),(83,70,53)); d=ImageDraw.Draw(im,'RGBA')
 # dusty road
 d.polygon([(-40,570),(220,470),(480,430),(730,280),(1040,235),(1320,80),(1320,310),(1050,380),(780,430),(520,585),(220,645),(-40,720)],fill=(139,116,79,255))
 # stream and bridge
 d.polygon([(-20,240),(390,205),(720,260),(1060,220),(1300,250),(1300,335),(1040,310),(720,345),(390,288),(-20,325)],fill=(58,91,103,255))
 d.rectangle((610,230,745,365),fill=(106,72,43,255),outline=(49,35,25,255),width=4)
 for x in range(620,746,18): d.line((x,235,x,360),fill=(182,132,72,190),width=3)
 # smoke and flags
 for x,y in [(160,125),(300,95),(990,120),(1120,170)]:
  for r in [52,38,27]: d.ellipse((x-r,y-r,x+r,y+r),fill=(65,61,57,45))
 for x,y in [(220,365),(930,420),(1090,500)]:
  d.line((x,y,x,y-78),fill=(58,38,25,255),width=4); d.polygon([(x,y-76),(x+45,y-62),(x,y-48)],fill=(116,42,37,240))
 # scattered carts
 for x,y in [(95,520),(430,610),(1010,560)]:
  d.rectangle((x,y,x+75,y+32),fill=(103,68,42,230)); d.ellipse((x+8,y+25,x+25,y+42),fill=(45,34,27,255)); d.ellipse((x+53,y+25,x+70,y+42),fill=(45,34,27,255))
 im.save(MAP/'changban.png')
map_jingzhou(); map_changban()

# Two loopable-ish 36 s pentatonic BGMs, mono PCM16.
SR=22050
NOTE=lambda midi: 440.0*2**((midi-69)/12)
def music(filename,bpm,root,melody,wind=False):
 dur=36.0; n=int(SR*dur); x=np.zeros(n,dtype=np.float64); beat=60/bpm
 rng=np.random.default_rng(780+root)
 def tone(start,length,midi,amp,decay=2.3):
  i=int(start*SR); m=min(int(length*SR),n-i)
  if m<=0:return
  t=np.arange(m)/SR; f=NOTE(midi)
  sig=(np.sin(2*np.pi*f*t)+.35*np.sin(4*np.pi*f*t)+.15*np.sin(6*np.pi*f*t))*np.exp(-decay*t/max(length,.1))
  a=min(int(.015*SR),m//3); r=min(int(.12*SR),m//3); env=np.ones(m)
  if a: env[:a]=np.linspace(0,1,a,endpoint=False)
  if r: env[-r:]=np.linspace(1,0,r)
  x[i:i+m]+=sig*env*amp
 def drum(start,amp=.32):
  i=int(start*SR); m=min(int(.24*SR),n-i)
  if m<=0:return
  t=np.arange(m)/SR; sig=np.sin(2*np.pi*(92-40*t/.24)*t)*np.exp(-18*t)+rng.normal(0,.12,m)*np.exp(-35*t)
  x[i:i+m]+=sig*amp
 if wind:
  noise=rng.normal(0,1,n); smooth=np.convolve(noise,np.ones(180)/180,mode='same'); x+=smooth*.035
 # drones and rhythm
 for bar,t0 in enumerate(np.arange(0,dur,beat*4)):
  tone(t0,min(beat*4,dur-t0),root,.08,.45); tone(t0,min(beat*4,dur-t0),root+7,.045,.4)
  if bar%2==0: tone(t0,min(beat*4,dur-t0),root+12,.035,.35)
 for k,t0 in enumerate(np.arange(0,dur,beat)):
  if k%4 in (0,2): drum(t0,.38 if k%4==0 else .27)
 for section,t0 in enumerate(np.arange(beat*4,dur-beat*2,beat*8)):
  seq=melody if section%2==0 else list(reversed(melody))
  for j,midi in enumerate(seq): tone(t0+j*beat*.75,beat*.68,midi,.12,3.2)
 peak=max(.001,np.max(np.abs(x))); x=np.tanh(x*1.1)*(.88/peak); pcm=(x*32767).astype('<i2')
 with wave.open(str(AUDIO/filename),'wb') as w: w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes(pcm.tobytes())
music('bgm_chapter6.wav',94,38,[62,65,67,69,67,65,62,60],True)
music('bgm_chapter7.wav',116,38,[62,69,67,65,74,69,67,62],False)
print('V078_ASSETS_OK')
