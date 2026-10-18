import {AbsoluteFill, CanvasImage, Easing, interpolate, staticFile, useCurrentFrame, useVideoConfig} from 'remotion';
export const Psd = () => {
 const frame=useCurrentFrame();const {fps}=useVideoConfig();
 return <AbsoluteFill style={{backgroundColor:'#f6f5f2',color:'#19181b',fontFamily:'Arial, sans-serif',padding:'65px 120px',gap:18,display:'flex',flexDirection:'column'}}>
 <div style={{fontFamily:'Courier New, monospace',fontSize:22,color:'#6c6871',letterSpacing:3,opacity:interpolate(frame,[0,.6*fps],[0,1],{extrapolateRight:'clamp'})}}>02 / KEEP YOUR CREATIVE MOMENTUM</div>
 <h1 style={{fontSize:82,lineHeight:1.1,letterSpacing:-4,fontWeight:400,margin:0,translate:`${interpolate(frame,[0,.8*fps],[-40,0],{extrapolateRight:'clamp',easing:Easing.out(Easing.cubic)})}px 0`}}>Your files. A fresh perspective.</h1>
 <p style={{fontSize:29,color:'#6c6871',margin:0,opacity:interpolate(frame,[.2*fps,.9*fps],[0,1],{extrapolateLeft:'clamp',extrapolateRight:'clamp'})}}>PSD import and export. Layers, groups, and masks.</p>
 <div style={{flex:1,minHeight:0,marginTop:12,padding:12,background:'#e6deec',borderRadius:22,overflow:'hidden',scale:interpolate(frame,[0,6*fps],[.98,1.015],{extrapolateRight:'clamp'})}}><CanvasImage src={staticFile('real-hardware-psd-youtube-template.png')} premountFor={fps} style={{width:'100%',height:'100%',objectFit:'contain',borderRadius:12,backgroundColor:'#19181b'}} /></div>
 <div style={{fontSize:20,color:'#6c6871',fontFamily:'Courier New, monospace'}}>Real hardware PSD workflow · v0.1-era capture · File compatibility varies</div>
 </AbsoluteFill>;
};
