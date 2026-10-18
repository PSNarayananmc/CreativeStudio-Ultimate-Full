import {AbsoluteFill, staticFile, useVideoConfig} from 'remotion';
import {Video} from '@remotion/media';
export const Opening = () => {
  const {fps} = useVideoConfig();
  return <AbsoluteFill style={{backgroundColor: '#f6f5f2'}}><Video src={staticFile('opening.mp4')} muted premountFor={fps} style={{width: '100%', height: '100%'}} /></AbsoluteFill>;
};
