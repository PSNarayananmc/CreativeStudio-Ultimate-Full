import React from 'react';
import {interpolate,useCurrentFrame,useVideoConfig} from 'remotion';
import {Screenshot,clamp,ease} from '../components';
import {Stage,C,Screen,Corner,Star} from './Common';
export const ReferenceWorkflow:React.FC=()=>{
 const f=useCurrentFrame();const {fps}=useVideoConfig();
 if(f<fps)return <Stage><div style={{position:'absolute',left:90,right:90,top:780,fontSize:58,lineHeight:1.25,letterSpacing:-2,textAlign:'center'}}>Tools <span style={{display:'inline-block',verticalAlign:'middle'}}><Star size={58}/></span> that keep<br/>your ideas moving.</div></Stage>;
 if(f<2.5*fps)return <Stage bg="#d8ddd4" color="#111"><Corner dark/><div style={{position:'absolute',left:75,top:275,fontSize:108,fontWeight:600,letterSpacing:-7}}>Paint. Layer.<br/>Create.</div><Screen width={1100} height={800} file="hero-main-workspace.png" focus="100% 50%" style={{position:'absolute',left:-15,top:650,rotate:'-4deg',scale:interpolate(f,[fps,2.5*fps],[.75,1.08],{...clamp,easing:ease})}}/><div style={{position:'absolute',left:75,top:1600,fontSize:28}}>Layers & masks / 100+ brushes</div></Stage>;
 if(f<3.75*fps)return <Stage bg={C.lime} color="#111"><Corner dark/><Screen width={960} height={850} style={{position:'absolute',left:60,top:420,scale:interpolate(f,[2.5*fps,3.75*fps],[1.1,1],{...clamp,easing:ease})}}/><div style={{position:'absolute',left:70,top:1390,fontSize:105,fontWeight:600,lineHeight:1,letterSpacing:-6}}>Your PSD.<br/>Your workflow.</div></Stage>;
 return <Stage bg={C.purple}><div style={{position:'absolute',left:70,top:300,fontSize:120,fontWeight:600,letterSpacing:-7,lineHeight:1}}>Ready.<br/>Set. Export.</div><div style={{position:'absolute',left:70,top:780,borderRadius:12,overflow:'hidden',rotate:'3deg',scale:interpolate(f,[3.75*fps,5*fps],[.9,1.04],{...clamp,easing:ease})}}><Screenshot file="export-dialog-png.png" crop={[450,225,1050,610]} width={940} height={680}/></div><Star size={140} style={{position:'absolute',top:1410,left:740,rotate:`${f*1.5}deg`}}/></Stage>;
};
