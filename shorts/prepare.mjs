import {mkdir,copyFile,readFile,writeFile,access} from 'node:fs/promises';
const root=new URL('./',import.meta.url);
await mkdir(new URL('public/',root),{recursive:true});
await mkdir(new URL('out/',root),{recursive:true});
for(const name of ['hero-main-workspace.png','real-hardware-psd-youtube-template.png'])await copyFile(new URL('../assets/'+name,root),new URL('public/'+name,root));
const sources=JSON.parse(await readFile(new URL('audio-sources.json',root),'utf8'));
for(const [name,url] of Object.entries(sources)){
 const dest=new URL('public/'+name+'.mp3',root);
 try{await access(dest);continue;}catch{}
 const response=await fetch(url);if(!response.ok)throw new Error(`Audio download ${name}: ${response.status}. Restore this file from the render artifact if its source link expired.`);
 await writeFile(dest,Buffer.from(await response.arrayBuffer()));
 console.log('Saved generated '+name+' audio.');
}
