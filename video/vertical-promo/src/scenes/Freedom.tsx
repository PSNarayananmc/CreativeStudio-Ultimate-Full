import React from 'react';
import {interpolate,useCurrentFrame,useVideoConfig} from 'remotion';
import {Backdrop,Brand,Label,Reveal,Brush,Footer,clamp,ease} from '../components';
export const Freedom:React.FC=()=>{
 const f=useCurrentFrame();const {fps}=useVideoConfig();
 return <Backdrop light><Brand light/><Label light style={{position:'absolute',left:80,top:335}}>Made for your freedom</Label><div style={{position:'absolute',left:72,top:475}}><Reveal size={150}>Free.</Reveal><Reveal at={fps*.5} size={134}>Open source.</Reveal><Reveal at={fps} size={134} color="#7951b1">Offline ready.</Reveal></div><Brush light progress={interpolate(f,[fps*.5,fps*1.8],[0,1],{...clamp,easing:ease})} style={{top:965,rotate:'8deg',opacity:.7}}/><div style={{position:'absolute',left:82,top:1480,fontSize:29,lineHeight:1.6,color:'#6c5b7e',opacity:interpolate(f,[fps*1.3,fps*1.6],[0,1],clamp)}}>Your canvas. Your pace.<br/>Your studio, wherever you work.</div><Footer index="04" light/></Backdrop>;
};
