import {staticFile} from 'remotion';
declare global {interface Window {__CREATIVE_PIC_ASSETS__?: Record<string,string>}}
export const asset=(name:string):string=>
 typeof window!=='undefined' && window.__CREATIVE_PIC_ASSETS__?.[name]
  ? window.__CREATIVE_PIC_ASSETS__[name]
  : staticFile(name);
