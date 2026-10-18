import {Composition, Folder, Sequence, staticFile, useVideoConfig} from 'remotion';
import {Audio} from '@remotion/media';
import {TransitionSeries,linearTiming} from '@remotion/transitions';
import {fade} from '@remotion/transitions/fade';
import {Hook,Meet,Brushes,Psd,Platforms,Closing} from './Scenes';
import {Captions} from './Captions';
const Short=()=>{const {fps}=useVideoConfig();return <>
<TransitionSeries>
 <TransitionSeries.Sequence name="HyperFrames hook" durationInFrames={2.8*fps} premountFor={fps}><Hook/></TransitionSeries.Sequence>
 <TransitionSeries.Transition presentation={fade()} timing={linearTiming({durationInFrames:.4*fps})}/>
 <TransitionSeries.Sequence name="Meet Creative Pic" durationInFrames={3.8*fps} premountFor={fps}><Meet/></TransitionSeries.Sequence>
 <TransitionSeries.Transition presentation={fade()} timing={linearTiming({durationInFrames:.4*fps})}/>
 <TransitionSeries.Sequence name="Brushes and layers" durationInFrames={4.4*fps} premountFor={fps}><Brushes/></TransitionSeries.Sequence>
 <TransitionSeries.Transition presentation={fade()} timing={linearTiming({durationInFrames:.4*fps})}/>
 <TransitionSeries.Sequence name="PSD and offline" durationInFrames={4.2*fps} premountFor={fps}><Psd/></TransitionSeries.Sequence>
 <TransitionSeries.Transition presentation={fade()} timing={linearTiming({durationInFrames:.4*fps})}/>
 <TransitionSeries.Sequence name="Linux and Windows" durationInFrames={3.7*fps} premountFor={fps}><Platforms/></TransitionSeries.Sequence>
 <TransitionSeries.Transition presentation={fade()} timing={linearTiming({durationInFrames:.4*fps})}/>
 <TransitionSeries.Sequence name="Download invitation" durationInFrames={9.1*fps} premountFor={fps}><Closing/></TransitionSeries.Sequence>
</TransitionSeries>
<Sequence name="Continuous narration, music, and synchronized captions" durationInFrames={26*fps} premountFor={fps}><Audio src={staticFile('mix.wav')} premountFor={fps}/><Captions/></Sequence>
</>};
export const Root=()=> <>
<Composition id="CreativePicShort" component={Short} durationInFrames={780} fps={30} width={1080} height={1920}/>
<Folder name="Scenes">
<Composition id="Hook" component={Hook} durationInFrames={84} fps={30} width={1080} height={1920}/>
<Composition id="Meet" component={Meet} durationInFrames={114} fps={30} width={1080} height={1920}/>
<Composition id="Brushes" component={Brushes} durationInFrames={132} fps={30} width={1080} height={1920}/>
<Composition id="Psd" component={Psd} durationInFrames={126} fps={30} width={1080} height={1920}/>
<Composition id="Platforms" component={Platforms} durationInFrames={111} fps={30} width={1080} height={1920}/>
<Composition id="Closing" component={Closing} durationInFrames={273} fps={30} width={1080} height={1920}/>
</Folder>
</>;
