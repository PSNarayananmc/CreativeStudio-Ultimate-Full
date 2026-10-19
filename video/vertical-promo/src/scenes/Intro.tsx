import React from 'react';
import {interpolate,useCurrentFrame,useVideoConfig} from 'remotion';
import {Backdrop,Brand,Brush,Label,Reveal,Footer,clamp,ease} from '../components';
import {BRAND} from '../theme-v2';
export const Intro:React.FC=()=>{
 const f=useCurrentFrame();const {fps}=useVideoConfig();
 return <Backdrop><Brand/><Label style={{position:'absolute',left:80,top:325}}>More space to imagine</Label><div style={{position:'absolute',left:72,top:415}}><Reveal at={0} size={146}>Your ideas.</Reveal><Reveal at={fps*.5} size={146}>Your studio.</Reveal><Reveal at={fps} size={146} color={BRAND.violet}>Your way.</Reveal></div><Brush progress={interpolate(f,[fps*.45,fps*2.6],[0,1],{...clamp,easing:ease})} style={{top:790,rotate:'-12deg',scale:1.22}}/><div style={{position:'absolute',left:82,top:1480,fontSize:28,lineHeight:1.5,color:BRAND.muted,opacity:interpolate(f,[fps*1.8,fps*2.3],[0,1],clamp)}}>Meet your next creative studio.<br/><span style={{color:BRAND.paper}}>Free. Open source. Built on Krita.</span></div><Footer index="01"/></Backdrop>;
};
