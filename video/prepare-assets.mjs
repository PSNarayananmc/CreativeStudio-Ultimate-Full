import {copyFile, mkdir} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
const root = new URL('./', import.meta.url);
await mkdir(new URL('public/', root), {recursive: true});
for (const name of ['hero-main-workspace.png', 'real-hardware-psd-youtube-template.png']) {
  await copyFile(new URL('../assets/' + name, root), new URL('public/' + name, root));
}
console.log('Prepared project screenshots in', fileURLToPath(new URL('public/', root)));
