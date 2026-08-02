import math, wave
from pathlib import Path
import numpy as np
from scipy.signal import butter, sosfilt

SR = 22050
OUT = Path('/mnt/data/三國人生錄_亂世倖存Demo6_v0.7.4_效能與史勢奇遇版/assets/audio')
OUT.mkdir(parents=True, exist_ok=True)
RNG = np.random.default_rng(20260719)

NOTE = {name: 440.0 * (2.0 ** ((midi - 69) / 12.0)) for name, midi in {
    'C2':36,'D2':38,'E2':40,'F2':41,'G2':43,'A2':45,'Bb2':46,'Eb2':39,'C3':48,'D3':50,'E3':52,'F3':53,'G3':55,'A3':57,'Bb3':58,
    'C4':60,'D4':62,'E4':64,'F4':65,'G4':67,'A4':69,'Bb4':70,'C5':72,'D5':74,'E5':76,'F5':77,'G5':79,'A5':81
}.items()}

def env_adsr(n, a=.01, d=.12, s=.7, r=.2):
    e = np.ones(n, dtype=np.float32)*s
    ai=max(1,int(a*SR)); di=max(1,int(d*SR)); ri=max(1,int(r*SR))
    if ai+di+ri > n:
        scale=n/(ai+di+ri); ai=max(1,int(ai*scale)); di=max(1,int(di*scale)); ri=max(1,n-ai-di)
    e[:ai]=np.linspace(0,1,ai,endpoint=False)
    e[ai:ai+di]=np.linspace(1,s,di,endpoint=False)
    e[-ri:]=np.linspace(s,0,ri)
    return e

def add_tone(buf, start, dur, freq, amp, kind='pluck', pan=0.0):
    i0=int(start*SR); n=int(dur*SR)
    if n<=4 or i0>=len(buf): return
    n=min(n,len(buf)-i0); t=np.arange(n)/SR
    if kind=='pluck':
        sig=(np.sin(2*np.pi*freq*t)+0.5*np.sin(2*np.pi*freq*2*t)+0.22*np.sin(2*np.pi*freq*3*t)+0.12*np.sin(2*np.pi*freq*5*t))
        sig*=np.exp(-4.5*t/max(dur,.1))*env_adsr(n,.005,.08,.55,.18)
    elif kind=='reed':
        sig=sum((1/k)*np.sin(2*np.pi*freq*k*t) for k in range(1,7))
        sig*=env_adsr(n,.05,.14,.76,.25)
        sig=np.tanh(sig*1.25)
    elif kind=='string':
        sig=(np.sin(2*np.pi*freq*t)+.38*np.sin(2*np.pi*freq*2*t)+.18*np.sin(2*np.pi*freq*3*t))
        sig*=env_adsr(n,.18,.35,.72,.45)
    elif kind=='drone':
        sig=(np.sin(2*np.pi*freq*t)+.25*np.sin(2*np.pi*freq*2*t)+.12*np.sin(2*np.pi*freq*3*t))
        sig*=env_adsr(n,.4,.5,.8,.8)
    else:
        sig=np.sin(2*np.pi*freq*t)*env_adsr(n,.01,.1,.7,.2)
    buf[i0:i0+n] += (sig*amp).astype(np.float32)

def add_drum(buf, start, amp=.7, low=78, dur=.34):
    i0=int(start*SR); n=min(int(dur*SR),len(buf)-i0)
    if n<=0:return
    t=np.arange(n)/SR
    sweep=low*2.1-(low*1.1)*(t/dur)
    phase=2*np.pi*np.cumsum(sweep)/SR
    noise=RNG.normal(0,1,n)
    sos=butter(2,900,btype='low',fs=SR,output='sos')
    noise=sosfilt(sos,noise)
    sig=(np.sin(phase)*.9+noise*.12)*np.exp(-9*t/dur)
    buf[i0:i0+n]+=sig.astype(np.float32)*amp

def add_clack(buf,start,amp=.3):
    i0=int(start*SR); n=min(int(.06*SR),len(buf)-i0)
    if n<=0:return
    t=np.arange(n)/SR
    noise=RNG.normal(0,1,n)
    sos=butter(2,[1800,7000],btype='band',fs=SR,output='sos')
    sig=sosfilt(sos,noise)*np.exp(-55*t)
    buf[i0:i0+n]+=sig.astype(np.float32)*amp

def add_gong(buf,start,amp=.45,dur=2.4):
    i0=int(start*SR); n=min(int(dur*SR),len(buf)-i0)
    if n<=0:return
    t=np.arange(n)/SR
    freqs=[114,167,238,311,428,581]
    sig=np.zeros(n)
    for j,f in enumerate(freqs):
        sig+=(1/(1+j*.5))*np.sin(2*np.pi*f*t+RNG.uniform(0,6.28))*np.exp(-(1.0+j*.18)*t)
    sig+=RNG.normal(0,.07,n)*np.exp(-4*t)
    buf[i0:i0+n]+=sig.astype(np.float32)*amp

def add_wind(buf, amp=.018):
    noise=RNG.normal(0,1,len(buf))
    sos=butter(2,[180,1400],btype='band',fs=SR,output='sos')
    w=sosfilt(sos,noise)
    slow=.55+.45*np.sin(2*np.pi*np.arange(len(buf))/SR/7.3)
    buf += (w*slow*amp).astype(np.float32)

def write(name, x):
    x=np.tanh(x*1.15)
    peak=np.max(np.abs(x)) or 1
    x=x*(.92/peak)
    pcm=(x*32767).astype('<i2')
    with wave.open(str(OUT/name),'wb') as w:
        w.setnchannels(1);w.setsampwidth(2);w.setframerate(SR);w.writeframes(pcm.tobytes())

def compose(name, bpm, root, progression, melody, dur=36, boss=False, lvbu=False, rain=False):
    buf=np.zeros(int(dur*SR),dtype=np.float32)
    beat=60/bpm
    bar=beat*4
    add_wind(buf,.012 if boss else .018)
    if rain:
        noise=RNG.normal(0,1,len(buf)); sos=butter(2,[2600,8500],btype='band',fs=SR,output='sos')
        buf += sosfilt(sos,noise).astype(np.float32)*.008
    # drones / strings
    for b,t0 in enumerate(np.arange(0,dur,bar)):
        chord=progression[b%len(progression)]
        add_tone(buf,t0,min(bar+0.25,dur-t0),NOTE[chord[0]],.12 if not boss else .10,'drone')
        add_tone(buf,t0,min(bar+0.25,dur-t0),NOTE[chord[1]],.085,'string')
        add_tone(buf,t0,min(bar+0.25,dur-t0),NOTE[chord[2]],.07,'string')
        if b%4==0: add_gong(buf,t0,.28 if not boss else .35,2.0)
    # rhythm
    for k,t in enumerate(np.arange(0,dur,beat)):
        if boss:
            add_drum(buf,t,.48 if k%4 else .74,72 if not lvbu else 82,.26)
            if k%2: add_clack(buf,t+beat*.5,.18)
            if lvbu and k%4 in (1,3): add_drum(buf,t+beat*.5,.32,118,.16)
        else:
            if k%4 in (0,2): add_drum(buf,t,.40 if k%4==2 else .58,70,.32)
            if k%2==1: add_clack(buf,t,.12)
    # bass ostinato
    bass_notes=[root, progression[1%len(progression)][0], progression[2%len(progression)][0], progression[3%len(progression)][0]]
    for k,t in enumerate(np.arange(0,dur,beat*2)):
        add_tone(buf,t,beat*1.7,NOTE[bass_notes[k%len(bass_notes)]],.16,'pluck')
    # melody sections
    note_dur=beat*.85 if not boss else beat*.58
    step=beat if not boss else beat*.5
    for section,t0 in enumerate(np.arange(bar, dur-1, bar*2)):
        seq=melody if section%2==0 else melody[::-1]
        for j,nm in enumerate(seq):
            st=t0+j*step
            if st+note_dur>=dur:break
            kind='reed' if (section%3==1 or boss) else 'pluck'
            amp=.12 if kind=='reed' else .15
            if lvbu: amp*=1.15
            add_tone(buf,st,note_dur,NOTE[nm],amp,kind)
            if boss and j%4==3:
                add_tone(buf,st,beat*.35,NOTE[nm]*2,.045,'pluck')
    # fate motif every 4 bars
    motif=['D4','F4','G4','A4','G4','F4','D4'] if root.startswith('D') else ['A3','C4','D4','E4','D4','C4','A3']
    for t0 in np.arange(bar*3,dur,bar*4):
        for j,nm in enumerate(motif):
            add_tone(buf,t0+j*beat*.5,beat*.46,NOTE[nm],.095,'reed')
    write(name,buf)

compose('bgm_menu.wav',72,'D2', [('D2','A2','D3'),('Bb2','F3','A3'),('C3','G3','D4'),('D2','A2','F3')], ['D4','F4','G4','A4','C5','A4','G4','F4'],36)
compose('bgm_chapter1.wav',88,'D2',[('D2','A2','F3'),('C3','G3','E4'),('Bb2','F3','D4'),('D2','A2','G3')],['D4','F4','G4','A4','G4','F4','D4','C4'],36)
compose('bgm_chapter2.wav',92,'A2',[('A2','E3','C4'),('F2','C3','A3'),('G2','D3','Bb3'),('A2','E3','D4')],['A3','C4','D4','E4','G4','E4','D4','C4'],36)
compose('bgm_chapter3.wav',108,'D2',[('D2','A2','F3'),('Bb2','F3','D4'),('C3','G3','E4'),('D2','A2','A3')],['D4','A4','G4','F4','D4','F4','A4','C5'],36)
compose('bgm_chapter4.wav',96,'A2',[('A2','E3','C4'),('G2','D3','Bb3'),('F2','C3','A3'),('A2','E3','D4')],['A3','C4','E4','D4','C4','A3','G3','A3'],36,rain=True)
compose('bgm_chapter5.wav',102,'D2',[('D2','A2','F3'),('C3','G3','E4'),('Bb2','F3','D4'),('A2','E3','C4')],['D4','F4','A4','C5','A4','G4','F4','D4'],36)
compose('bgm_boss.wav',132,'D2',[('D2','A2','F3'),('C3','G3','E4'),('Bb2','F3','D4'),('D2','A2','A3')],['D4','F4','A4','G4','F4','D4','C4','D4'],32,boss=True)
compose('bgm_boss_lvbu.wav',148,'D2',[('D2','A2','F3'),('Eb2','Bb2','G3'),('C3','G3','E4'),('D2','A2','A3')],['D4','A4','C5','A4','G4','F4','D4','A4'],32,boss=True,lvbu=True)
print('generated', sorted(p.name for p in OUT.glob('bgm_*.wav')))
