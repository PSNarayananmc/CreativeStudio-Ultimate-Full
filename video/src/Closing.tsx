import {AbsoluteFill, Easing, interpolate, useCurrentFrame, useVideoConfig} from 'remotion';
export const Closing=()=>{
 const frame=useCurrentFrame();const {fps}=useVideoConfig();
 return <AbsoluteFill style={{backgroundColor:'#e6deec',color:'#19181b',fontFamily:'Arial, sans-serif',padding:'120px 170px',display:'flex',flexDirection:'column',justifyContent:'center',alignItems:'center',gap:32}}>
 <div style={{fontSize:23,fontFamily:'Courier New, monospace',letterSpacing:4,color:'#6c6871',opacity:interpolate(frame,[0,.6*fps],[0,1],{extrapolateRight:'clamp'})}}>CREATIVE PIC / v0.2</div>
 <h1 style={{fontSize:110,letterSpacing:-6,fontWeight:400,textAlign:'center',lineHeight:1.05,maxWidth:1450,margin:0,translate:`0 ${interpolate(frame,[0,.8*fps],[40,0],{extrapolateRight:'clamp',easing:Easing.out(Easing.cubic)})}px`}}>Make space for your next idea.</h1>
 <div style={{fontSize:32,color:'#6c6871',opacity:interpolate(frame,[.3*fps,1*fps],[0,1],{extrapolateLeft:'clamp',extrapolateRight:'clamp'})}}>Free and open source. Linux + Windows. Works offline.</div>
 <div style={{fontSize:28,background:'#19181b',color:'#f6f5f2',padding:'23px 40px',borderRadius:12,opacity:interpolate(frame,[.6*fps,1.2*fps],[0,1],{extrapolateLeft:'clamp',extrapolateRight:'clamp'})}}>Download Creative Pic ↓</div>
 <div style={{fontSize:22,color:'#6c6871'}}>Built on Krita · GPL v3 or later</div>
 </AbsoluteFill>;
};
