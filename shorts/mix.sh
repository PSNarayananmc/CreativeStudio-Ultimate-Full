#!/usr/bin/env bash
set -euo pipefail
# Normalize the voice, duck the instrumental under speech, then master to -14 LUFS.
ffmpeg -hide_banner -y -i public/voice.mp3 -i public/music.mp3 -filter_complex \
 '[0:a]aresample=48000,loudnorm=I=-16:TP=-1.5:LRA=7,adelay=200|200,apad,atrim=duration=26,asplit=2[voice][key];[1:a]aresample=48000,loudnorm=I=-20:TP=-2:LRA=9,atrim=duration=26,afade=t=in:st=0:d=0.25,afade=t=out:st=24:d=2[bed];[bed][key]sidechaincompress=threshold=0.035:ratio=5:attack=15:release=220:level_sc=1[ducked];[voice][ducked]amix=inputs=2:weights=1\ 0.45:normalize=0,loudnorm=I=-14:TP=-1.5:LRA=8,aresample=48000[mix]' \
 -map '[mix]' -t 26 -c:a pcm_s16le public/mix.wav
