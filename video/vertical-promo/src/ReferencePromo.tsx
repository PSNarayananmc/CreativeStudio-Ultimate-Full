import React from 'react';
import {AbsoluteFill,Sequence,interpolate,useVideoConfig} from 'remotion';
import {Audio} from '@remotion/media';
import {asset} from './assets';
import {clamp} from './components';
import {ReferenceOpening} from './reference/Opening';
import {ReferenceShowcase} from './reference/Showcase';
import {ReferenceWorkflow} from './reference/Workflow';
import {ReferenceFreedom} from './reference/Freedom';
import {ReferenceClosing} from './reference/Closing';
export const ReferencePromo:React.FC=()=>{
 const {fps}=useVideoConfig();
 return <AbsoluteFill style={{background:'#050505'}}><Audio src={asset('creative-flow.wav')} premountFor={fps} volume={f=>interpolate(f,[0,.1*fps,19.5*fps,20*fps],[0,.85,.85,0],clamp)}/>
 <Sequence name="Editorial intro and aperture" from={0} durationInFrames={4*fps} premountFor={fps}><ReferenceOpening/></Sequence>
 <Sequence name="Project screen stack" from={4*fps} durationInFrames={4*fps} premountFor={fps}><ReferenceShowcase/></Sequence>
 <Sequence name="Product montage" from={8*fps} durationInFrames={5*fps} premountFor={fps}><ReferenceWorkflow/></Sequence>
 <Sequence name="Creative freedom" from={13*fps} durationInFrames={3*fps} premountFor={fps}><ReferenceFreedom/></Sequence>
 <Sequence name="Stack collapse and brand" from={16*fps} durationInFrames={4*fps} premountFor={fps}><ReferenceClosing/></Sequence>
 </AbsoluteFill>;
};
