# claude-voice-notifications

Claude Code plugin (and marketplace) that plays voice lines per hook event. Read `docs/development.md` before you change anything.

## Rules

- Never commit API keys. `tools/generate-lines.sh` reads `ELEVENLABS_API_KEY` from the environment.
- Bump `version` in `plugins/voice-notifications/.claude-plugin/plugin.json` for every change that should reach users.
- Run `claude plugin validate .` before committing.
- Scripts must use LF line endings (enforced by `.gitattributes`), otherwise they will not run on macOS and Linux.

## Structure

- `.claude-plugin/marketplace.json`: marketplace with one plugin
- `plugins/voice-notifications/hooks/hooks.json`: event → category
- `plugins/voice-notifications/scripts/play-sound.sh`: picks a random file and plays it
- `plugins/voice-notifications/sounds/<done|input|permission|error>/`: bundled sounds (excluded from the MIT license)
- `tools/`: clone sample builder and voice line generator
