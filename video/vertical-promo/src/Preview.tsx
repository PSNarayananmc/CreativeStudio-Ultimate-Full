import React from 'react';
import {createRoot} from 'react-dom/client';
import {Player} from '@remotion/player';
import {Promo} from './Promo';

const Preview=()=> <main style={{display:'flex',flexDirection:'column',alignItems:'center',padding:'24px 16px',gap:16}}>
 <div style={{width:'min(100%,460px)',display:'flex',justifyContent:'space-between',alignItems:'center',color:'#a9a6bd',fontSize:12,letterSpacing:'.08em'}}><span>CREATIVE PIC</span><span>20 SECONDS · 9:16</span></div>
 <Player component={Promo} compositionWidth={1080} compositionHeight={1920} durationInFrames={600} fps={30} controls loop initiallyMuted={false} clickToPlay doubleClickToFullscreen showVolumeControls style={{width:'min(100%,460px)',height:'auto',aspectRatio:'9/16',borderRadius:16,overflow:'hidden',boxShadow:'0 12px 100px #0008'}}/>
 <div style={{color:'#a9a6bd',fontSize:13,textAlign:'center'}}>Press play for the full promo with music.</div>
 <a href="https://psnarayananmc.github.io/CreativeStudio-Ultimate-Full/landing-page/" target="_blank" rel="noreferrer" style={{fontSize:13,color:'#bca3ff',textDecoration:'none'}}>Explore Creative Pic</a>
</main>;
createRoot(document.getElementById('root')!).render(<Preview/>);
