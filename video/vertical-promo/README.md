# Creative Pic — vertical promotional video

20 seconds · 1080 × 1920 · 30 fps · 9:16.

Five scenes use the genuine Creative Pic screenshots, the landing page's violet palette, locally bundled Inter fonts, and an original 120 BPM synthesized electronic cue. No voiceover.

## Preview and edit

Requires Node.js 18+ (Node 22+ recommended).

```sh
npm ci
npm run studio
```

From `video/vertical-promo`, run the commands above, then open the URL printed by Remotion and choose **CreativePic-Promo**. Individual scenes are under **Scenes**. Each scene is separately authored in `src/scenes/`. Brand colors and durations are in `src/theme-v2.ts`; timeline and transitions are in `src/Promo.tsx`.

Run `npm run preview` to build a self-contained interactive Remotion Player preview at `preview.html`. Open it in a current browser, then press Play. Its embedded images, fonts, and music do not require a network connection. The product link opens the original website.

## Export MP4

Use Studio's Render button, or:

```sh
npm run render
```

The completed export is checked in at `../../landing-page/media/creative-pic-promo-vertical.mp4`. The command creates `exports/creative-pic-promo.mp4` with H.264, CRF 14 and lossless PNG intermediate frames. Remotion downloads its supported browser if needed. To use an already installed browser, set `REMOTION_BROWSER_EXECUTABLE=/path/to/chromium` for the command.

The final master has exactly 600 frames. Transition overlap is accounted for in the scene durations. Original soundtrack is 22 seconds long; the composition trims playback to 20 seconds and fades the end.

## Rebuild the portable preview

```sh
npm run preview
```

## Audio and timing

`public/creative-flow.wav` is an original synthesized cue with no third-party samples. `references/compose-soundtrack.py` contains the complete reproducible score and synthesis source (requires numpy and soundfile). `beats.json` records the exact authored 120 BPM grid, and `references/detected-beats.json` is the independent librosa onset analysis. Scene boundaries at frames 120, 270, 420 and 510 have explicit musical accents. Motion events use frame-based easing; no CSS animations.

## Source and attribution

Website: https://psnarayananmc.github.io/CreativeStudio-Ultimate-Full/landing-page/

Product captures: https://github.com/psnarayananmc/CreativeStudio-Ultimate-Full/tree/main/assets

Creative Pic is a desktop image studio built on Krita 5.2.16, distributed by its project under GNU GPL v3 or later. The PSD capture is from the project's earlier Creative Studio build. Captures preserve the original application and artwork contents; only their viewport framing changes. The violet star mark follows the landing page's icon treatment.

Inter is bundled under the SIL Open Font License, included in `public/FONT-LICENSE.txt`. Remotion has its own licensing terms; see https://www.remotion.dev/license.

The design and plan in `docs/superpowers/` reflect the direction approved in chat. No external reference videos were supplied; visual direction comes from the product's own landing page.

## Reference-style revision

Select `CreativePic-ReferenceStyle` for the revised 20-second vertical cut inspired by the user-uploaded agency reel. It uses a black/white editorial opening, circular logo aperture, lime/purple screen stacks, fast product crops and a collapsed-stack brand close. The previous `CreativePic-Promo` composition remains available.

Export the new version with `npm run render:reference`. The reference breakdown is in `references/template-breakdown.md`. The uploaded reference is not redistributed.
