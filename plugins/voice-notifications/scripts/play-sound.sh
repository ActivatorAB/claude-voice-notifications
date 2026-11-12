#!/usr/bin/env bash
# Plays a random sound for a Claude Code hook event.
# Usage: play-sound.sh <done|input|permission|error>
#
# Sound folders are searched in this order, first non-empty folder wins:
#   1. $CLAUDE_VOICE_NOTIFICATIONS_DIR/<event>
#   2. ~/.claude/voice-notifications/<event>
#   3. <plugin>/sounds/<event>

event="$1"
cat > /dev/null  # drain the hook payload on stdin

root="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
shopt -s nullglob nocaseglob

files=()
for dir in "${CLAUDE_VOICE_NOTIFICATIONS_DIR:+$CLAUDE_VOICE_NOTIFICATIONS_DIR/$event}" \
           "$HOME/.claude/voice-notifications/$event" \
           "$root/sounds/$event"; do
  [ -n "$dir" ] || continue
  files=("$dir"/*.mp3 "$dir"/*.wav "$dir"/*.ogg)
  [ ${#files[@]} -gt 0 ] && break
done
[ ${#files[@]} -eq 0 ] && exit 0

file="${files[RANDOM % ${#files[@]}]}"

if command -v ffplay >/dev/null 2>&1; then
  ffplay -nodisp -autoexit -loglevel quiet "$file"
elif command -v afplay >/dev/null 2>&1; then
  afplay "$file"
elif command -v paplay >/dev/null 2>&1; then
  paplay "$file"
elif command -v mpg123 >/dev/null 2>&1; then
  mpg123 -q "$file"
elif command -v powershell.exe >/dev/null 2>&1; then
  winpath="$(cygpath -w "$file" 2>/dev/null || echo "$file")"
  powershell.exe -NoProfile -NonInteractive -Command "
    Add-Type -AssemblyName PresentationCore
    \$p = New-Object System.Windows.Media.MediaPlayer
    \$p.Open([Uri]'$winpath')
    for (\$i = 0; \$i -lt 20 -and -not \$p.NaturalDuration.HasTimeSpan; \$i++) { Start-Sleep -Milliseconds 100 }
    \$p.Play()
    if (\$p.NaturalDuration.HasTimeSpan) { Start-Sleep -Milliseconds ([int]\$p.NaturalDuration.TimeSpan.TotalMilliseconds + 200) } else { Start-Sleep -Seconds 5 }
    \$p.Close()"
fi
exit 0
