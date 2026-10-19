import {asset} from './assets';
import React from 'react';
import {AbsoluteFill,interpolate,useCurrentFrame,useVideoConfig} from 'remotion';
import {Audio} from '@remotion/media';
import {TransitionSeries,linearTiming} from '@remotion/transitions';
import {fade} from '@remotion/transitions/fade';
import {Intro} from './scenes/Intro';
import {Studio} from './scenes/Studio';
import {Workflow} from './scenes/Workflow';
import {Freedom} from './scenes/Freedom';
import {Close} from './scenes/Close';
import {TIMING} from './theme-v2';
import {clamp} from './components';
export const Promo:React.FC=()=>{
 const {fps}=useVideoConfig();const f=useCurrentFrame();
 return <AbsoluteFill style={{background:'#0b0b12'}}><Audio src={asset('creative-flow.wav')} premountFor={fps} volume={frame=>interpolate(frame,[0,fps*.15,TIMING.duration-fps*.65,TIMING.duration],[0,.8,.8,0],clamp)}/><TransitionSeries>
  <TransitionSeries.Sequence name="Your ideas" durationInFrames={TIMING.intro.duration+6} premountFor={fps}><Intro/></TransitionSeries.Sequence>
  <TransitionSeries.Transition presentation={fade()} timing={linearTiming({durationInFrames:6})}/>
  <TransitionSeries.Sequence name="Paint Layer Create" durationInFrames={TIMING.studio.duration+6} premountFor={fps}><Studio/></TransitionSeries.Sequence>
  <TransitionSeries.Transition presentation={fade()} timing={linearTiming({durationInFrames:6})}/>
  <TransitionSeries.Sequence name="Creative workflow" durationInFrames={TIMING.workflow.duration+6} premountFor={fps}><Workflow/></TransitionSeries.Sequence>
  <TransitionSeries.Transition presentation={fade()} timing={linearTiming({durationInFrames:6})}/>
  <TransitionSeries.Sequence name="Creative freedom" durationInFrames={TIMING.freedom.duration+6} premountFor={fps}><Freedom/></TransitionSeries.Sequence>
  <TransitionSeries.Transition presentation={fade()} timing={linearTiming({durationInFrames:6})}/>
  <TransitionSeries.Sequence name="Download Creative Pic" durationInFrames={TIMING.close.duration} premountFor={fps}><Close/></TransitionSeries.Sequence>
 </TransitionSeries><div style={{position:'absolute',left:0,right:0,bottom:0,height:4,background:'#bca3ff22'}}><div style={{height:'100%',background:'#bca3ff',width:`${100*f/(TIMING.duration-1)}%`}}/></div></AbsoluteFill>;
};
