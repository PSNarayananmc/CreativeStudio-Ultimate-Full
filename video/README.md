# Creative Pic product film

A silent, 19.5-second 1920×1080 product tour at 30 fps. HyperFrames renders the 4-second brand opening; Remotion combines it with the real workspace screenshot, real hardware PSD capture, and a download invitation using consistent half-second crossfades. Nothing in the film is presented as a live recording.

## Render and publish with GitHub Actions

The **Creative Pic website and product film** workflow renders on pull requests and saves `creative-pic-website-with-video` as a downloadable artifact. This contains a complete static website and the MP4. On pushes to `main` or a manual run on `main`, it also publishes through GitHub Pages. GitHub may require an owner to approve a first workflow run, enable Pages, or approve the `github-pages` environment. Deployment success and its actual URL appear in the workflow; a merge alone does not establish publication.

## Local preview and render

Requirements: Node 22+, FFmpeg, and network access for npm and Chromium installation.

From `video/`:

```sh
npm install
npm run prepare-assets
npx --yes hyperframes@0.8.172 init .hf-stage --non-interactive
cp hyperframes/index.html hyperframes/DESIGN.md .hf-stage/
cd .hf-stage
npx --yes hyperframes@0.8.172 lint
npx --yes hyperframes@0.8.172 validate
npx --yes hyperframes@0.8.172 inspect
npx --yes hyperframes@0.8.172 preview
```

Open the Studio project URL printed by HyperFrames. Then render the opening from the same directory:

```sh
npx --yes hyperframes@0.8.172 render --fps 30 --quality high --workers 2 --output ../public/opening.mp4
cd ..
npm run studio
```

Open the exact URL printed by Remotion Studio. Review `CreativePicTour` and each individual scene, then:

```sh
npm run check
npm run render
```

The output is `landing-page/media/creative-pic-tour.mp4`. Serve the repository root (for example `python3 -m http.server 8080`), then visit `/landing-page/`. Serve the repository root so `../assets/` image references resolve correctly. The page does not autoplay video; visitors control playback. English descriptive captions accompany the silent film. Generated binaries and dependencies are ignored.

## Validation status in the authoring environment

HTML parsing, screenshot paths, navigation targets, video source wiring, JSON syntax, inline JavaScript syntax, and timeline duration were checked locally. Dependency download was blocked by the workspace proxy, so TypeScript compilation, HyperFrames visual checks, browser rendering, and MP4 rendering were not executed here. The CI workflow runs the required checks before saving the packaged website or publishing it. Verify its result before treating the video or site as ready.

## Attribution

Screenshots come from `assets/` in this repository. The PSD workflow screenshot is a v0.1-era capture; the product is now branded Creative Pic. Creative Pic is built on Krita 5.2.16, © the Krita Foundation and contributors, under GNU GPL v3 or later. The film uses factual project descriptions and no copied third-party marketing copy, music, or assets.
