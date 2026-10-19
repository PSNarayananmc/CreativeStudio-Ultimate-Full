# Creative Pic — YouTube Shorts commercial

26 seconds, 1080×1920, 30 fps, H.264 video and AAC audio. A kinetic HyperFrames hook opens a Remotion product edit with real project screenshots, transitions, a download CTA, and word-accurate captions transcribed by ElevenLabs Scribe.

Voice: Dior — Crisp, Confident, Modern, Global (ElevenLabs Multilingual v2). Music: original 30-second instrumental product-launch bed generated with ElevenLabs Music v2; trimmed and faded to 26 seconds. Narration begins at 200ms. The audio mix normalizes narration, ducks music under speech, and targets -14 LUFS with -1.5dB true peak. Review the rendered file and loudness report before uploading.

The `Creative Pic YouTube Short commercial` workflow renders on the commercial branch. Its finished-video artifact includes the MP4, thumbnail, caption timing JSON, media metadata, loudness report, and upload text. A second artifact includes the editable source and generated audio. This workflow does not upload to YouTube or modify the live website.

## Preview / render

Requires Node 22+, FFmpeg and network access for dependencies. From `shorts/`:

```sh
npm install
node prepare.mjs
bash mix.sh
npx --yes hyperframes@0.8.172 init .hf-stage --non-interactive
cp hyperframes/index.html hyperframes/DESIGN.md .hf-stage/
cd .hf-stage
npx --yes hyperframes@0.8.172 lint
npx --yes hyperframes@0.8.172 validate
npx --yes hyperframes@0.8.172 inspect
npx --yes hyperframes@0.8.172 preview
```

Review the HyperFrames Studio URL printed by the CLI. To render and assemble:

```sh
npx --yes hyperframes@0.8.172 render --fps 30 --quality high --workers 2 --output ../public/hook.mp4
cd ..
npm run studio
```

Open Remotion's exact printed Studio URL to inspect `CreativePicShort` or the individual scenes. Then run `npm run check` and `npm run render`. The finished file is `out/creative-pic-youtube-short.mp4`.

The initial audio download links expire. The editable-source artifact includes `public/voice.mp3`, `public/music.mp3`, `public/mix.wav`, and `public/hook.mp4`; retain these for later edits. When restoring that artifact, place `public/` in `shorts/` and skip expired downloads. Keep the existing product screenshots available there as well.

The footage is a screenshot-based product commercial; no simulated product features or fabricated artwork are shown. PSD screenshot captured on the v0.1-era build. Creative Pic is built on Krita 5.2.16, © the Krita Foundation and contributors, under GPL v3 or later. ElevenLabs audio assets remain available in the associated creative flow.
