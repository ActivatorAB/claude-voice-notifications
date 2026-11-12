# Development notes

How the plugin works, why it is built this way and how to change it. Read this before you change anything.

## What the plugin does

The plugin plays a voice line when a Claude Code agent needs you. Each event has its own sound folder and the plugin picks a random file from it every time:

| Event | Hook | Folder |
|---|---|---|
| The agent is done | `Stop` | `sounds/done/` |
| The agent asks a question | `PreToolUse` on `AskUserQuestion`, `Notification` with `elicitation_dialog` | `sounds/input/` |
| The agent needs permission | `Notification` with `permission_prompt`, `PreToolUse` on `ExitPlanMode` | `sounds/permission/` |
| Something went wrong | `StopFailure` | `sounds/error/` |

All hooks are `async`, so Claude never waits for a sound. The repository is also a marketplace, which is why the plugin lives in `plugins/voice-notifications/`.

## Why hooks

Many terminals and agent managers can play a notification sound, but usually one sound for every kind of notification. A different sound per event needs Claude Code hooks. The trade-off is that the plugin only covers Claude Code agents. Other agents running in the same tool are not affected. If your tool plays its own sound, turn it off or you will hear both.

## Sound lookup

`scripts/play-sound.sh` uses the first folder that contains `.mp3`, `.wav` or `.ogg` files:

1. `$CLAUDE_VOICE_NOTIFICATIONS_DIR/<event>`
2. `~/.claude/voice-notifications/<event>`
3. `<plugin>/sounds/<event>`

User folders survive plugin updates. An event with no files plays nothing.

## Making voice lines

The scripts in `tools/` reproduce the bundled sounds with any ElevenLabs voice you have the right to use.

1. **Voice (optional).** To clone a voice, join a few minutes of clean recordings into one sample with `tools/build-clone-sample.sh` and upload it as a voice clone in ElevenLabs. Only clone voices you have consent to use.
2. **Lines.** Edit `tools/lines.tsv` (event, file name, prompt) and run:

   ```bash
   ELEVENLABS_API_KEY=... tools/generate-lines.sh <voice_id>
   ```

   The script uses `eleven_v4` with audio tags and writes to `plugins/voice-notifications/sounds/`. Pass a second argument to write somewhere else.
3. **Check.** Listen to the files or transcribe them (for example with ElevenLabs Scribe) to make sure no audio tags were read out loud.

Keep the API key in your environment. Never commit it.

## License

The code is MIT licensed. The files in `plugins/voice-notifications/sounds/` are excluded, as stated in the README.

## Common changes

**Release a new version:** bump `version` in `plugins/voice-notifications/.claude-plugin/plugin.json`, run `claude plugin validate .`, commit and push. Users update with `/plugin marketplace update voice-notifications`.

**Add an event:** add a hook in `hooks/hooks.json` that calls `play-sound.sh <event>`, add a `sounds/<event>/` folder and document the event in the README.

## Design decisions

- **`idle_prompt` is left out on purpose.** It fires a minute after every finished turn and would repeat the input sound right after the done sound.
- **Requires bash.** On Windows without Git Bash the hooks do not run. A PowerShell variant with `"shell": "powershell"` would solve that if needed.
