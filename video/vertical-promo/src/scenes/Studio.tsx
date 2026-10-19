import React from 'react';
import {interpolate,useCurrentFrame,useVideoConfig} from 'remotion';
import {Backdrop,Brand,Label,Reveal,Screenshot,Window,Badge,Footer,clamp,ease} from '../components';
import {BRAND} from '../theme-v2';
export const Studio:React.FC=()=>{
 const f=useCurrentFrame();const {fps}=useVideoConfig();
 return <Backdrop><Brand/><Label style={{position:'absolute',left:80,top:310}}>A full creative toolkit</Label><div style={{position:'absolute',left:74,top:385}}><Reveal size={124} at={0}>Paint. Layer.</Reveal><Reveal size={124} at={fps*.5} color={BRAND.violet}>Create.</Reveal></div><Window title="Creative Pic / Your workspace" style={{position:'absolute',left:80,top:760,translate:`0 ${interpolate(f,[0,fps*.8],[150,0],{...clamp,easing:ease})}px`,rotate:`${interpolate(f,[0,fps*.8],[-5,0],{...clamp,easing:ease})}deg`}}><Screenshot file="hero-main-workspace.png" width={918} height={650} focus="70% 50%"/></Window><div style={{position:'absolute',left:112,top:1500,display:'flex',gap:14,translate:`0 ${interpolate(f,[fps,fps*1.6],[65,0],{...clamp,easing:ease})}px`,opacity:interpolate(f,[fps,fps*1.4],[0,1],clamp)}}><Badge>Layers & masks</Badge><Badge>100+ brushes</Badge></div><div style={{position:'absolute',left:82,top:1610,color:BRAND.muted,fontSize:28}}>From first stroke to final detail.</div><Footer index="02"/></Backdrop>;
};
