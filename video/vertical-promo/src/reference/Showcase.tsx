import React from 'react';
import {interpolate,useCurrentFrame,useVideoConfig} from 'remotion';
import {clamp,ease} from '../components';
import {Stage,C,Screen,Corner,Star,Word} from './Common';
export const ReferenceShowcase:React.FC=()=>{
 const f=useCurrentFrame();const {fps}=useVideoConfig();const p=interpolate(f,[0,fps*.65],[0,1],{...clamp,easing:ease});
 if(f<2*fps)return <Stage><div style={{position:'absolute',left:145,top:430,width:790,height:960,background:C.purple,translate:`${(1-p)*500}px ${(1-p)*180}px`,rotate:`${(1-p)*12}deg`}}/><div style={{position:'absolute',left:80,top:570,width:790,height:960,background:C.lime,translate:`${(1-p)*-500}px ${(1-p)*300}px`,rotate:'-5deg'}}/><Screen width={850} height={650} style={{position:'absolute',left:115,top:660,translate:`0 ${(1-p)*800}px`,rotate:`${interpolate(f,[0,2*fps],[-8,3],{...clamp,easing:ease})}deg`}}/><div style={{position:'absolute',top:265,left:80,fontSize:58,letterSpacing:-3,lineHeight:1.08}}>Your ideas.<br/>In full color.</div><Star size={115} style={{position:'absolute',top:1440,left:790,rotate:`${f*2}deg`}}/></Stage>;
 const q=interpolate(f,[2*fps,2.5*fps],[0,1],{...clamp,easing:ease});
 return <Stage bg={C.purple}><Corner/><div style={{position:'absolute',left:70,top:270}}><Word size={130} at={2*fps}>Make it</Word><Word size={130} at={2*fps+8} style={{color:C.lime}}>yours.</Word></div><Screen width={760} height={480} file="hero-main-workspace.png" style={{position:'absolute',left:-160+(1-q)*-500,top:770,rotate:'-9deg'}}/><Screen width={760} height={510} style={{position:'absolute',left:480+(1-q)*600,top:940,rotate:'8deg'}}/><div style={{position:'absolute',left:70,top:1540,fontSize:25}}>Paint. Compose. Refine.</div><Star size={95} color={C.lime} style={{position:'absolute',left:770,top:530,rotate:`${f*2}deg`}}/></Stage>;
};
