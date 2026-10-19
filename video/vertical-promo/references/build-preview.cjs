const fs=require('fs');
const path=require('path');
const esbuild=require('esbuild');

(async()=>{
 const root=path.resolve(__dirname,'..');
 const built=await esbuild.build({entryPoints:[path.join(root,'src/Preview.tsx')],bundle:true,write:false,format:'iife',minify:true,define:{'process.env.NODE_ENV':'"production"'},target:['chrome120','safari17']});
 const assets={};
 for(const file of fs.readdirSync(path.join(root,'public'))){
  const ext=path.extname(file);const type={'.png':'image/png','.wav':'audio/wav','.woff2':'font/woff2'}[ext];
  if(type)assets[file]=`data:${type};base64,${fs.readFileSync(path.join(root,'public',file)).toString('base64')}`;
 }
 const fonts=[400,600,800].map(w=>`@font-face{font-family:Inter;src:url("${assets[`inter-${w}.woff2`]}") format("woff2");font-weight:${w};font-display:block}`).join('');
 const html=`<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Creative Pic | 20-second vertical promo</title><style>${fonts}*{box-sizing:border-box}body{margin:0;background:#100d18;color:#f4f2fb;font-family:Inter,sans-serif}button{font-family:inherit}</style></head><body><div id="root"></div><script>window.__CREATIVE_PIC_ASSETS__=${JSON.stringify(assets)};</script><script>${built.outputFiles[0].text.replace(/<\/script/gi,'<\\/script')}</script></body></html>`;
 const out=process.argv[2]||path.join(root,'preview.html');
 fs.writeFileSync(out,html);
 console.log('Self-contained preview:',out,Math.round(Buffer.byteLength(html)/1024)+' KB');
})();
