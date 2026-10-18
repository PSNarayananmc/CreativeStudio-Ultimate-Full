import type {Caption} from '@remotion/captions';
import {useCurrentFrame,useVideoConfig} from 'remotion';
import source from '../captions.json';
// Short 2–4-word pages, with word-accurate ElevenLabs Scribe timings.
const words:Caption[]=source;
const groups:Caption[][]=[];
let page:Caption[]=[];
for(const word of words){page.push(word);if(page.length===4||/[.!?]$/.test(word.text.trim())){groups.push(page);page=[];}}
if(page.length)groups.push(page);
export const Captions=()=>{const frame=useCurrentFrame(),{fps}=useVideoConfig();const ms=frame/fps*1000-200;const group=groups.find(g=>ms>=g[0].startMs&&ms<g[g.length-1].endMs+100);if(!group)return null;return <div style={{position:'absolute',left:90,right:145,bottom:325,textAlign:'center',fontFamily:'Arial, sans-serif',fontSize:47,fontWeight:700,lineHeight:1.25,color:'#fff',zIndex:20}}><div style={{display:'inline-block',background:'#17131deb',padding:'16px 23px',borderRadius:16,boxShadow:'0 5px 20px #0002'}}>{group.map((w,i)=><span key={i} style={{color:ms>=w.startMs&&ms<w.endMs?'#dcc5f2':'#fff'}}>{w.text}</span>)}</div></div>};
