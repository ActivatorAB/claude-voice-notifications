#!/usr/bin/env bash
# Generates the voice lines in lines.tsv with ElevenLabs Eleven v4.
# Usage: ELEVENLABS_API_KEY=... tools/generate-lines.sh <voice_id> [out_dir]
# Default out_dir is the plugin's sounds folder. Existing files are overwritten.
set -euo pipefail
voice="${1:?voice_id required}"
here="$(cd "$(dirname "$0")" && pwd)"
out="${2:-$here/../plugins/voice-notifications/sounds}"
: "${ELEVENLABS_API_KEY:?set ELEVENLABS_API_KEY}"

grep -v '^#' "$here/lines.tsv" | while IFS=$'\t' read -r event name text; do
  [ -n "$event" ] || continue
  mkdir -p "$out/$event"
  body="$(python -c 'import json,sys; print(json.dumps({"text": sys.argv[1], "model_id": "eleven_v4"}))' "$text")"
  code=$(curl -s -o "$out/$event/$name.mp3" -w '%{http_code}' -X POST \
    "https://api.elevenlabs.io/v1/text-to-speech/$voice?output_format=mp3_44100_192" \
    -H "xi-api-key: $ELEVENLABS_API_KEY" -H 'Content-Type: application/json' --data-binary "$body")
  [ "$code" = 200 ] && echo "ok   $event/$name.mp3" || { echo "FAIL $event/$name ($code)"; rm -f "$out/$event/$name.mp3"; }
done
