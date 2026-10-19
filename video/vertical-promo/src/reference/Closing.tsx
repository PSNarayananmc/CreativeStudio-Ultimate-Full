import React from 'react';
import {interpolate,useCurrentFrame,useVideoConfig} from 'remotion';
import {clamp,ease} from '../components';
import {Stage,C,Icon,Screen,Star} from './Common';
export const ReferenceClosing:React.FC=()=>{
 const f=useCurrentFrame();const {fps}=useVideoConfig();
 const collapse=interpolate(f,[fps*.8,fps*1.4],[1,0],{...clamp,easing:ease});
 if(f<fps*1.4)return <Stage><div style={{position:'absolute',top:380,left:100,width:880,height:1100,scale:.2+.8*collapse,opacity:collapse}}><div style={{position:'absolute',left:0,top:0,width:650,height:700,background:C.lime}}/><div style={{position:'absolute',left:130,top:150,width:650,height:700,background:C.purple}}/><Screen width={670} height={450} file="hero-main-workspace.png" style={{position:'absolute',left:30,top:240,rotate:'-7deg'}}/><Screen width={670} height={450} style={{position:'absolute',left:160,top:470,rotate:'5deg'}}/><Star size={155} style={{position:'absolute',left:70,top:820}}/></div></Stage>;
 const enter=interpolate(f,[fps*1.4,fps*1.8],[0,1],{...clamp,easing:ease});
 return <Stage><div style={{position:'absolute',top:500,left:0,right:0,display:'flex',flexDirection:'column',alignItems:'center',opacity:enter,scale:.9+enter*.1}}><Icon size={135}/><div style={{fontSize:125,fontWeight:800,letterSpacing:-8,lineHeight:.95,textAlign:'center',marginTop:48}}>CREATIVE<br/>PIC<span style={{color:C.lime}}>.</span></div><div style={{fontSize:34,marginTop:35,letterSpacing:-1}}>Your ideas. Your way.</div><div style={{marginTop:95,background:C.lime,color:'#111',padding:'24px 48px',fontSize:31,borderRadius:3,fontWeight:600}}>Download free</div><div style={{fontSize:24,color:'#aaa',marginTop:27}}>Windows + Linux</div></div><div style={{position:'absolute',left:70,right:70,top:1520,textAlign:'center',fontSize:23,lineHeight:1.6,color:'#aaa'}}>psnarayananmc.github.io/<br/>CreativeStudio-Ultimate-Full/landing-page/</div></Stage>;
};
