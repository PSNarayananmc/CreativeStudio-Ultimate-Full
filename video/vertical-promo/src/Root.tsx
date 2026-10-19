import {asset} from './assets';
import React from 'react';
import {Composition,Folder} from 'remotion';
import {loadFont} from '@remotion/fonts';
import {Promo} from './Promo';
import {Intro} from './scenes/Intro';
import {Studio} from './scenes/Studio';
import {Workflow} from './scenes/Workflow';
import {Freedom} from './scenes/Freedom';
import {Close} from './scenes/Close';
loadFont({family:'Inter',url:asset('inter-400.woff2'),weight:'400'});
loadFont({family:'Inter',url:asset('inter-600.woff2'),weight:'600'});
loadFont({family:'Inter',url:asset('inter-800.woff2'),weight:'800'});
export const RemotionRoot:React.FC=()=> <>
 <Composition id="CreativePic-Promo" component={Promo} width={1080} height={1920} fps={30} durationInFrames={600}/>
 <Folder name="Scenes">
  <Composition id="Scene01-YourIdeas" component={Intro} width={1080} height={1920} fps={30} durationInFrames={126}/>
  <Composition id="Scene02-Studio" component={Studio} width={1080} height={1920} fps={30} durationInFrames={156}/>
  <Composition id="Scene03-Workflow" component={Workflow} width={1080} height={1920} fps={30} durationInFrames={156}/>
  <Composition id="Scene04-Freedom" component={Freedom} width={1080} height={1920} fps={30} durationInFrames={96}/>
  <Composition id="Scene05-Download" component={Close} width={1080} height={1920} fps={30} durationInFrames={90}/>
 </Folder>
</>;
