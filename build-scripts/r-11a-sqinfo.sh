#!/bin/bash
AI=/out/CreativeStudio-Ultimate-Full-x86_64.AppImage
unsquashfs -s -o 194183 $AI 2>/dev/null | head -14
