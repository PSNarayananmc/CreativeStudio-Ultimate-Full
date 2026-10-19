import React from 'react';
import {interpolate,useCurrentFrame,useVideoConfig} from 'remotion';
import {clamp,ease} from '../components';
import {Stage,C,Corner,Star,Word} from './Common';
export const ReferenceFreedom:React.FC=()=>{
 const f=useCurrentFrame();const {fps}=useVideoConfig();
 return <Stage bg={C.lime} color="#080808"><Corner dark/><div style={{position:'absolute',left:65,top:410}}><Word size={190} at={0}>Free.</Word><Word size={145} at={fps*.5}>Open source.</Word><Word size={145} at={fps} style={{color:C.purple}}>Offline ready.</Word></div><div style={{position:'absolute',left:80,top:1090,width:920,height:400,display:'flex',gap:35,alignItems:'center',translate:`${interpolate(f,[0,fps*3],[150,-150],clamp)}px 0`}}>{[0,1,2,3].map(i=><Star key={i} size={240} color={i%2?C.purple:'#111'} style={{flexShrink:0,rotate:`${f*(i%2?1:-1)}deg`,scale:interpolate(f,[fps*1.2+i*3,fps*1.6+i*3],[0,1],{...clamp,easing:ease})}}/>)}</div><div style={{position:'absolute',left:75,top:1570,fontSize:27}}>A full studio. Freely yours.</div></Stage>;
};
