#!/usr/bin/env bash
# Joins extracted voice files into one normalized MP3 for ElevenLabs voice cloning.
# Usage: tools/build-clone-sample.sh <folder with .ogg files> <glob> <out.mp3>

set -euo pipefail
src="$1"; pattern="$2"; out="$3"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
ffmpeg -v error -f lavfi -i anullsrc=r=44100:cl=mono -t 0.4 -c:a pcm_s16le "$tmp/sil.wav"
i=0
for f in "$src"/$pattern; do
  i=$((i+1))
  ffmpeg -v error -i "$f" -ar 44100 -ac 1 -c:a pcm_s16le "$tmp/$i.wav"
  printf "file '%s'\nfile '%s'\n" "$tmp/$i.wav" "$tmp/sil.wav" >> "$tmp/list.txt"
done
ffmpeg -v error -y -f concat -safe 0 -i "$tmp/list.txt" -af "loudnorm=I=-18:TP=-1.5:LRA=11" \
  -ar 44100 -c:a libmp3lame -b:a 192k "$out"
echo "$i clips -> $out"
