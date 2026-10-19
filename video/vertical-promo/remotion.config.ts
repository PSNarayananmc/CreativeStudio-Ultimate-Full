import {Config} from "@remotion/cli/config";
Config.setEntryPoint("./src/index.ts");
// Use the system Chromium here; elsewhere Remotion downloads its supported browser.
if (process.env.REMOTION_BROWSER_EXECUTABLE) Config.setBrowserExecutable(process.env.REMOTION_BROWSER_EXECUTABLE);
Config.setConcurrency(2);
Config.setVideoImageFormat("png");
