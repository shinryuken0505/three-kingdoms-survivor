from pathlib import Path
from PIL import Image, ImageDraw

ROOT=Path(__file__).resolve().parents[1]
POR=ROOT/'assets'/'portraits'
SPR=ROOT/'assets'/'sprites'

STYLES={
'swordsman':{'bg':(63,49,28),'accent':(218,179,92),'cloth':(115,82,35),'skin':(224,164,116),'hair':(42,28,20),'weapon':'blade','female':False},
'hunter':{'bg':(29,53,48),'accent':(105,181,157),'cloth':(43,96,80),'skin':(220,159,112),'hair':(36,28,23),'weapon':'bow','female':False},
'poisoner':{'bg':(40,57,29),'accent':(139,202,83),'cloth':(77,119,50),'skin':(218,157,110),'hair':(34,26,22),'weapon':'needle','female':False},
'heroine':{'bg':(57,35,58),'accent':(220,117,181),'cloth':(110,55,103),'skin':(232,171,132),'hair':(42,24,37),'weapon':'rings','female':True},
}

def portrait(key,s):
    im=Image.new('RGBA',(128,160),(*s['bg'],255)); d=ImageDraw.Draw(im,'RGBA')
    d.ellipse((25,8,103,86),fill=(*s['accent'],28),outline=(*s['accent'],120),width=2)
    d.polygon([(0,160),(0,125),(24,102),(42,88),(86,88),(106,103),(128,127),(128,160)],fill=(17,18,18,210))
    d.rounded_rectangle((22,92,106,159),10,fill=(*s['cloth'],255),outline=(*s['accent'],255),width=2)
    d.ellipse((12,96,48,132),fill=(*s['accent'],190),outline=(22,22,22,255),width=2)
    d.ellipse((80,96,116,132),fill=(*s['accent'],190),outline=(22,22,22,255),width=2)
    for x in range(38,92,12): d.rounded_rectangle((x,118,x+8,156),2,fill=(max(0,s['cloth'][0]-18),max(0,s['cloth'][1]-18),max(0,s['cloth'][2]-18),255),outline=(*s['accent'],180))
    d.rectangle((56,77,72,97),fill=(*s['skin'],255))
    # full face: no shadow polygon, no overlay, no mask
    d.ellipse((41,31,87,89),fill=(*s['skin'],255),outline=(92,55,37,255),width=1)
    # hair around face only
    if key=='heroine':
        d.polygon([(37,48),(39,28),(51,20),(63,25),(77,18),(90,35),(92,108),(82,100),(81,48),(72,34),(62,44),(51,34),(48,104),(35,109)],fill=(*s['hair'],255))
        d.ellipse((60,14,70,24),fill=(*s['accent'],255)); d.line((67,18,94,10),fill=(*s['accent'],255),width=2)
    elif key=='poisoner':
        d.arc((33,19,95,98),185,355,fill=(*s['accent'],255),width=7)
        d.polygon([(38,45),(45,27),(52,42)],fill=(*s['accent'],255)); d.polygon([(90,45),(83,27),(76,42)],fill=(*s['accent'],255))
        d.polygon([(41,43),(48,25),(61,36),(73,24),(87,43),(79,46),(49,46)],fill=(*s['hair'],255))
    elif key=='hunter':
        d.ellipse((55,16,73,34),fill=(*s['hair'],255)); d.polygon([(40,46),(45,29),(57,23),(70,28),(83,24),(88,46),(79,41),(69,34),(58,42),(49,35)],fill=(*s['hair'],255)); d.line((64,15,86,22),fill=(*s['accent'],255),width=2)
    else:
        d.polygon([(40,46),(44,29),(53,21),(64,26),(74,20),(85,31),(88,46),(80,42),(71,35),(61,43),(50,36)],fill=(*s['hair'],255))
    # symmetrical eyebrows and eyes
    brow=(45,31,24,255)
    d.line((49,55,58,53),fill=brow,width=2); d.line((70,53,79,55),fill=brow,width=2)
    d.ellipse((49,57,59,67),fill=(248,238,222,255),outline=(70,44,32,255)); d.ellipse((69,57,79,67),fill=(248,238,222,255),outline=(70,44,32,255))
    iris=s['accent'] if s['female'] else (54,62,54)
    d.ellipse((53,59,57,65),fill=(*iris,255)); d.ellipse((71,59,75,65),fill=(*iris,255))
    d.point((55,60),fill=(255,255,255,255)); d.point((73,60),fill=(255,255,255,255))
    d.line((64,61,63,71),fill=(156,96,68,255)); d.line((59,78,69,78),fill=((145,61,74,255) if s['female'] else (108,59,43,255)),width=1)
    # tiny soft cheek pixels only
    d.point((49,72),fill=(235,142,132,130)); d.point((79,72),fill=(235,142,132,130))
    # weapon stays outside face
    if s['weapon']=='blade':
        d.line((104,83,114,151),fill=(105,73,42,255),width=3); d.polygon([(100,88),(108,75),(115,78),(109,96)],fill=(230,229,215,255),outline=(33,31,27,255))
    elif s['weapon']=='bow':
        d.arc((5,82,43,151),270,90,fill=(138,85,42,255),width=3); d.line((24,82,24,151),fill=(240,231,198,255),width=1)
    elif s['weapon']=='needle':
        for i in range(3): d.line((100+i*4,99,113+i*2,72+i*8),fill=(228,232,220,255),width=1)
    else:
        d.ellipse((4,109,36,141),outline=(*s['accent'],255),width=4); d.ellipse((94,109,126,141),outline=(*s['accent'],255),width=4)
    d.rectangle((2,2,125,157),outline=(20,21,20,255),width=2); d.rectangle((5,5,122,154),outline=(*s['accent'],170),width=1)
    im.resize((256,320),Image.Resampling.NEAREST).save(POR/f'{key}_default.png')

for k,s in STYLES.items(): portrait(k,s)
print('PLAYER_PORTRAITS_V078_FIXED')
