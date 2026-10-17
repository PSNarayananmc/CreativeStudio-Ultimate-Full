CREATIVE STUDIO ULTIMATE (Full edition)
========================================
A professional image studio built on the Krita 5.2.16 paint engine,
packaged as a self-contained AppImage for Ubuntu 20.04 LTS (x86_64)
and compatible distributions (glibc >= 2.31 target, works on newer).

HIGHLIGHTS
- Photoshop-style dark studio theme ("Creative Studio Dark", default)
- Studio workspace preset: left toolbox / center canvas / right dockers
  (Tool Options, Advanced Color Selector, Layers, Brush Presets)
  selectable via --workspace CreativeStudio or Window > Workspace
- Photoshop-compatible keyboard shortcut profile included and
  selectable in Settings > Keyboard Shortcuts
- Full Krita feature set: layers, masks, selections, brushes, filters,
  color management (LCMS/OCIO), PSD import/export, animation, scripting

LOW-SPEC PROFILE (baked defaults for 4 GB RAM / 2-core CPUs)
  memoryHardLimitPercent=35   memorySoftLimitPercent=2
  maxNumberOfThreads=2        maxSwapSize=2048
  undoStackLimit=100
Users can override any key in ~/.config/kritarc (root group, top of
file, no section header). A reference of further low-memory keys is in
/usr/share/creative-studio/LOWMEM-PROFILE.conf.

USAGE
  chmod +x CreativeStudio-Ultimate-Full-x86_64.AppImage
  ./CreativeStudio-Ultimate-Full-x86_64.AppImage [file]
No root installation required; runs offline.
