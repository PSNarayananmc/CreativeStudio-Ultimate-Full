import {Composition, Folder, useVideoConfig} from 'remotion';
import {TransitionSeries, linearTiming} from '@remotion/transitions';
import {fade} from '@remotion/transitions/fade';
import {Opening} from './Opening';
import {Workspace} from './Workspace';
import {Psd} from './Psd';
import {Closing} from './Closing';
const Tour=()=>{const {fps}=useVideoConfig();return <TransitionSeries>
 <TransitionSeries.Sequence name="HyperFrames opening" durationInFrames={4*fps} premountFor={fps}><Opening /></TransitionSeries.Sequence>
 <TransitionSeries.Transition presentation={fade()} timing={linearTiming({durationInFrames:.5*fps})} />
 <TransitionSeries.Sequence name="Studio workspace" durationInFrames={6*fps} premountFor={fps}><Workspace /></TransitionSeries.Sequence>
 <TransitionSeries.Transition presentation={fade()} timing={linearTiming({durationInFrames:.5*fps})} />
 <TransitionSeries.Sequence name="PSD workflow" durationInFrames={6*fps} premountFor={fps}><Psd /></TransitionSeries.Sequence>
 <TransitionSeries.Transition presentation={fade()} timing={linearTiming({durationInFrames:.5*fps})} />
 <TransitionSeries.Sequence name="Download invitation" durationInFrames={5*fps} premountFor={fps}><Closing /></TransitionSeries.Sequence>
 </TransitionSeries>};
export const Root=()=> <>
 <Composition id="CreativePicTour" component={Tour} durationInFrames={585} fps={30} width={1920} height={1080} />
 <Folder name="Scenes">
 <Composition id="Opening" component={Opening} durationInFrames={120} fps={30} width={1920} height={1080} />
 <Composition id="Workspace" component={Workspace} durationInFrames={180} fps={30} width={1920} height={1080} />
 <Composition id="Psd" component={Psd} durationInFrames={180} fps={30} width={1920} height={1080} />
 <Composition id="Closing" component={Closing} durationInFrames={150} fps={30} width={1920} height={1080} />
 </Folder>
 </>;
