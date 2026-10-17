#!/bin/bash
file /out/CreativeStudio-Ultimate-Full-x86_64.AppImage
head -c 16 /out/CreativeStudio-Ultimate-Full-x86_64.AppImage | xxd
ls -la /out/
tail -12 /root/appimage-final.log
