# Claude Voice Notifications

A Claude Code plugin that plays a voice line when your agent needs you. Different events get different sounds, so you know what happened without looking at the screen.

| Event | When it plays | Sound folder |
|---|---|---|
| `done` | Claude finished its turn | `done/` |
| `input` | Claude asks you a question (`AskUserQuestion`) or an MCP server needs input | `input/` |
| `permission` | Claude needs permission to run a tool, or wants a plan approved | `permission/` |
| `error` | The turn stopped because of an API error | `error/` |

Each event picks a random file from its folder, so you can add several lines per event for variety.

## Bundled sounds

The plugin ships with eight lines in a starship captain style voice:

| Event | Lines |
|---|---|
| `done` | "Task complete, Commander. Awaiting new orders." · "Mission accomplished. Standing by." · "Code deployed. All systems nominal." · "The job's done. Ready for the next one." |
| `input` | "Bridge to Commander. Your input is required." |
| `permission` | "Requesting authorization to proceed." |
| `error` | "We've got a problem on deck, Commander." · "Warning. Something needs your attention." |

The lines were generated with ElevenLabs Eleven v4. The sound files are **not** covered by the MIT license. If you redistribute the plugin, leave out `plugins/voice-notifications/sounds/` and use your own sounds.

## Install

In Claude Code:

```
/plugin marketplace add ActivatorAB/claude-voice-notifications
/plugin install voice-notifications@voice-notifications
```

Restart Claude Code (or run `/hooks`) so the hooks load.

## Use your own sounds instead

Put `.mp3`, `.wav` or `.ogg` files in these folders:

```
~/.claude/voice-notifications/done/
~/.claude/voice-notifications/input/
~/.claude/voice-notifications/permission/
~/.claude/voice-notifications/error/
```

On Windows that is `C:\Users\<you>\.claude\voice-notifications\`.

The plugin looks for sounds in this order and uses the first folder that has files in it:

1. `$CLAUDE_VOICE_NOTIFICATIONS_DIR/<event>`, if you set that environment variable
2. `~/.claude/voice-notifications/<event>`
3. The sounds bundled with the plugin

Your own folders survive plugin updates. An empty event plays nothing.

### Make your own voice lines

Any text-to-speech tool works. With ElevenLabs Eleven v4 short lines with audio tags work well:

```
[calm, confident naval captain] Task complete, Commander... [short pause] Awaiting new orders.
[radio-transmission tone] Bridge to Commander... [short pause] Your input is required.
[formal] Requesting authorization to proceed.
[concerned, urgent] We've got a problem on deck, Commander.
```

Keep each line around 2 to 4 seconds. Longer lines get annoying after the fiftieth task.

Only use voices you have the right to use. Do not clone a real person's voice without their consent.

## Requirements

- Claude Code with plugin support
- `bash` (on Windows, Git Bash, which Claude Code uses anyway)
- One audio player. The script tries them in this order:
  - `ffplay` (part of FFmpeg, works everywhere)
  - `afplay` (built into macOS)
  - `paplay` or `mpg123` (Linux)
  - PowerShell's media player (built into Windows, no install needed)

## Tips

- **Does your terminal or agent manager play its own notification sound?** Turn that sound off, or you will hear both.
- **Running with `bypassPermissions`?** You will rarely hear the `permission` sound, since Claude seldom asks.
- **Turn it off temporarily** with `/plugin disable voice-notifications`.

## How it works

See [docs/development.md](docs/development.md) for design notes and how to regenerate the bundled sounds.

`hooks/hooks.json` registers async hooks on `Stop`, `StopFailure`, `Notification` and `PreToolUse`. Each hook runs `scripts/play-sound.sh <event>`, which picks a random file and plays it in the background. Claude never waits for the sound.

## License

The code (scripts, hooks and manifests) is MIT licensed, see [LICENSE](LICENSE).

The files in `plugins/voice-notifications/sounds/` are excluded from the MIT license. See [Bundled sounds](#bundled-sounds).
