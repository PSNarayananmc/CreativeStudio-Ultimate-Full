"""Original 120 BPM electronic cue, composed for this promo. No samples."""
from pathlib import Path
import json
import numpy as np
import soundfile as sf

SR=44100
DURATION=22
rng=np.random.default_rng(19)
mix=np.zeros((SR*DURATION,2),dtype=np.float64)

def note(midi):
    return 440*2**((midi-69)/12)

def add(signal,start,volume=1,pan=0):
    i=round(start*SR)
    n=min(len(signal),len(mix)-i)
    if n<=0:return
    mix[i:i+n,0]+=signal[:n]*volume*np.sqrt((1-pan)/2)
    mix[i:i+n,1]+=signal[:n]*volume*np.sqrt((1+pan)/2)

chords=[[53,56,60,67],[49,53,56,63],[56,60,63,70],[51,55,58,65]]
for bar in range(11):
    chord=chords[bar%4]
    t=np.arange(int(2.25*SR))/SR
    env=np.minimum(t/.15,1)*np.minimum((2.25-t)/.35,1)
    duck=.5+.5*(1-np.exp(-((t%0.5)/.13)))
    pad=sum(np.sin(2*np.pi*note(n)*t)+.3*np.sin(2*np.pi*note(n)*1.0015*t) for n in chord)/len(chord)
    add(pad*env*duck,bar*2,.115,(-1)**bar*.3)
    for step in range(8):
        start=bar*2+step*.25
        t=np.arange(int(.36*SR))/SR
        freq=note(chord[[0,2,1,3,2,1,3,2][step]]+12)
        env=np.minimum(t/.006,1)*np.exp(-t*12)
        pluck=(np.sin(2*np.pi*freq*t)+.18*np.sin(4*np.pi*freq*t))*env
        add(pluck,start,.11,(-1)**step*.45)
        if step%2==0:
            bass=(np.sin(2*np.pi*note(chord[0]-24)*t)+.12*np.sin(4*np.pi*note(chord[0]-24)*t))*np.minimum(t/.008,1)*np.exp(-t*7)
            add(bass,start,.20)

for beat in range(44):
    start=beat*.5
    t=np.arange(int(.35*SR))/SR
    freq=48+100*np.exp(-t*32)
    phase=2*np.pi*np.cumsum(freq)/SR
    kick=np.sin(phase)*np.exp(-t*15)*np.minimum(t/.003,1)
    add(kick,start,.42)
    if beat%2==1 or beat in [8,18,28,34]:
        t=np.arange(int(.18*SR))/SR
        noise=rng.normal(0,1,len(t))
        noise=np.concatenate(([0],np.diff(noise)))*.35
        snare=(noise+.2*np.sin(2*np.pi*185*t))*np.exp(-t*25)*np.minimum(t/.001,1)
        add(snare,start,.22)
    for half in range(2):
        t=np.arange(int(.065*SR))/SR
        noise=rng.normal(0,1,len(t))
        hat=np.concatenate(([0],np.diff(noise)))*np.exp(-t*85)
        add(hat,start+half*.25,.026 if half==0 else .018,(-1)**beat*.25)

for start in [4,9,14,17]:
    t=np.arange(int(.2*SR))/SR
    noise=rng.normal(0,1,len(t))
    add(noise*np.exp(-t*30),start,.055,.15)

# Soft peak limiting and end tail. Playback adds the final 20-second fade.
mix=np.tanh(mix*1.5)
mix*=.86/max(np.max(np.abs(mix)),.86)
mix[:int(.02*SR)]*=np.linspace(0,1,int(.02*SR))[:,None]
mix[-SR:]*=np.linspace(1,0,SR)[:,None]
root=Path(__file__).resolve().parents[1]
sf.write(root/'public/creative-flow.wav',mix,SR,subtype='PCM_16')
grid={'bpm':120,'fps':30,'provenance':'Original synthesized cue; exact authored grid',
      'beat_frames':list(range(0,660,15)),
      'scene_start_frames':[0,120,270,420,510],
      'accent_frames':[120,270,420,510],
      'snare_frames':sorted(set(list(range(15,660,30))+[120,270,420,510]))}
(root/'beats.json').write_text(json.dumps(grid,indent=2)+'\n')
print('Created 22-second original stereo soundtrack, 120 BPM.')
