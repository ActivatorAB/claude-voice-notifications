# claude-voice-notifications

Claude Code-plugin (och marketplace) som spelar röstrepliker per hook-händelse. Läs `docs/overlamning.md` innan du ändrar något.

## Regler


- Lägg aldrig API-nycklar i repot. `tools/generate-lines.sh` läser `ELEVENLABS_API_KEY` från miljön.
- Höj `version` i `plugins/voice-notifications/.claude-plugin/plugin.json` vid varje ändring som ska nå användare.
- Kör `claude plugin validate .` före commit.
- Skript ska ha LF-radslut (styrs av `.gitattributes`), annars går de inte att köra på macOS och Linux.

## Struktur

- `.claude-plugin/marketplace.json`: marketplace med ett plugin
- `plugins/voice-notifications/hooks/hooks.json`: händelse → kategori
- `plugins/voice-notifications/scripts/play-sound.sh`: väljer slumpad fil och spelar upp den
- `plugins/voice-notifications/sounds/<done|input|permission|error>/`: medföljande ljud

