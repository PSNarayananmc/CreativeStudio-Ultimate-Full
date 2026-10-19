import React from 'react';
import {AbsoluteFill,interpolate,useCurrentFrame,useVideoConfig} from 'remotion';
import {clamp,ease} from '../components';
import {Stage,Icon,C,Star} from './Common';
export const ReferenceOpening:React.FC=()=>{
 const f=useCurrentFrame();const {fps}=useVideoConfig();
 if(f<2*fps)return <Stage><div style={{position:'absolute',left:100,top:610,fontSize:65,letterSpacing:-3,lineHeight:1.2}}>{[['A new space',0,0],['for your',12,110],['next big idea.',24,210]].map(([text,at,offset],i)=><div key={i} style={{marginLeft:Number(offset),marginBottom:22,opacity:interpolate(f,[Number(at),Number(at)+8],[0,1],clamp),translate:`0 ${interpolate(f,[Number(at),Number(at)+16],[45,0],{...clamp,easing:ease})}px`}}>{text}</div>)}</div><Star size={50} style={{position:'absolute',left:770,top:1015,rotate:`${f*2}deg`,opacity:interpolate(f,[34,44],[0,1],clamp)}}/></Stage>;
 if(f<3*fps)return <Stage><div style={{position:'absolute',left:65,top:725,right:65,scale:interpolate(f,[2*fps,2.3*fps],[1.2,1],{...clamp,easing:ease})}}><div style={{fontSize:174,fontWeight:800,lineHeight:.88,letterSpacing:-12}}>CREATIVE<br/>PIC<span style={{color:C.lime}}>.</span></div><div style={{fontSize:25,marginTop:36,letterSpacing:5}}>YOUR IDEAS. YOUR WAY.</div></div></Stage>;
 return <Stage><AbsoluteFill style={{background:C.white,clipPath:`circle(${interpolate(f,[3*fps,3.25*fps],[0,1300],{...clamp,easing:ease})}px at 50% 50%)`,alignItems:'center',justifyContent:'center'}}><div style={{rotate:`${interpolate(f,[3*fps,3.6*fps],[-35,0],{...clamp,easing:ease})}deg`,scale:interpolate(f,[3*fps,3.5*fps],[.3,1],{...clamp,easing:ease})}}><Icon size={260}/></div></AbsoluteFill></Stage>;
};
