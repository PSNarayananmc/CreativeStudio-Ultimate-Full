import {AbsoluteFill, CanvasImage, Easing, interpolate, staticFile, useCurrentFrame, useVideoConfig} from 'remotion';
export const Workspace = () => {
 const frame=useCurrentFrame(); const {fps}=useVideoConfig();
 return <AbsoluteFill style={{backgroundColor:'#f6f5f2',color:'#19181b',fontFamily:'Arial, sans-serif',padding:'65px 120px',gap:18,display:'flex',flexDirection:'column'}}>
 <div style={{fontFamily:'Courier New, monospace',fontSize:22,color:'#6c6871',letterSpacing:3,opacity:interpolate(frame,[0,.6*fps],[0,1],{extrapolateRight:'clamp'})}}>01 / FIND YOUR FLOW</div>
 <h1 style={{fontSize:82,lineHeight:1.1,letterSpacing:-4,fontWeight:400,margin:0,translate:`0 ${interpolate(frame,[0,.8*fps],[35,0],{extrapolateRight:'clamp',easing:Easing.out(Easing.cubic)})}px`}}>A workspace that feels like yours.</h1>
 <p style={{fontSize:29,color:'#6c6871',margin:0,opacity:interpolate(frame,[.2*fps,.9*fps],[0,1],{extrapolateLeft:'clamp',extrapolateRight:'clamp'})}}>Brushes. Color. Layers. All within reach.</p>
 <div style={{flex:1,minHeight:0,marginTop:12,padding:12,background:'#e6deec',borderRadius:22,overflow:'hidden',scale:interpolate(frame,[0,6*fps],[.98,1.015],{extrapolateRight:'clamp'})}}><CanvasImage src={staticFile('hero-main-workspace.png')} premountFor={fps} style={{width:'100%',height:'100%',objectFit:'contain',backgroundColor:'#19181b',borderRadius:12}} /></div>
 <div style={{fontSize:20,color:'#6c6871',fontFamily:'Courier New, monospace'}}>Genuine project screenshot · Krita 5.2.16 engine</div>
 </AbsoluteFill>;
};
