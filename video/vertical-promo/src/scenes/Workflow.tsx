import React from 'react';
import {interpolate,useCurrentFrame,useVideoConfig} from 'remotion';
import {Backdrop,Brand,Label,Reveal,Screenshot,Window,Footer,Badge,clamp,ease} from '../components';
import {BRAND} from '../theme-v2';
export const Workflow:React.FC=()=>{
 const f=useCurrentFrame();const {fps}=useVideoConfig();const t=interpolate(f,[fps*2.4,fps*3],[0,1],{...clamp,easing:ease});
 return <Backdrop><Brand/><Label style={{position:'absolute',left:80,top:310}}>Less friction. More flow.</Label><div style={{position:'absolute',left:74,top:385}}><Reveal size={116}>Keep your</Reveal><Reveal size={116} at={fps*.4} color={BRAND.violet}>creative flow.</Reveal></div><Window title="Your PSD. Your familiar workflow." style={{position:'absolute',left:80,top:740,opacity:1-t,scale:1-t*.06,translate:`0 ${interpolate(f,[0,fps*.65],[100,0],{...clamp,easing:ease})-t*50}px`}}><Screenshot file="real-hardware-psd-youtube-template.png" crop={[0,26,1366,714]} width={918} height={620}/></Window><Window title="Ready for the final export." style={{position:'absolute',left:80,top:740,opacity:t,translate:`0 ${(1-t)*160}px`}}><Screenshot file="export-dialog-png.png" crop={[450,225,1050,610]} width={918} height={620}/></Window><div style={{position:'absolute',left:95,top:1470,display:'flex',gap:18}}><Badge>PSD import + export</Badge><Badge color={BRAND.blue}>PNG export</Badge></div><p style={{position:'absolute',top:1560,left:82,fontSize:21,color:BRAND.muted,margin:0}}>Your files. Your familiar tools.</p><Footer index="03"/></Backdrop>;
};
