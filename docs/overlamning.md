# Överlämning: claude-voice-notifications

Senast uppdaterad 2026-11-12. Den här filen beskriver vad projektet är, hur ljuden togs fram, vilka beslut som fattats och vad som återstår. Läs den innan du ändrar något, i synnerhet avsnittet om rättigheter.

## Vad projektet är

Ett Claude Code-plugin som spelar en röstreplik när en agent behöver dig. Varje händelse har sin egen mapp med ljud och pluginet slumpar fram en fil per gång:

| Händelse | Hook | Mapp |
|---|---|---|
| Agenten är klar | `Stop` | `sounds/done/` |
| Agenten ställer en fråga | `PreToolUse` på `AskUserQuestion`, `Notification` med `elicitation_dialog` | `sounds/input/` |
| Agenten behöver tillstånd | `Notification` med `permission_prompt`, `PreToolUse` på `ExitPlanMode` | `sounds/permission/` |
| Något gick fel | `StopFailure` | `sounds/error/` |

Alla hooks är `async`, så Claude väntar aldrig på ljudet. Repot fungerar samtidigt som marketplace, därför ligger pluginet under `plugins/voice-notifications/`.

## Varför hooks och inte Orca

Det började som ett önskemål om egna ljud i Orca. Orca har dock bara en egen ljudfil (`customSoundPath`), och den gäller alla notiser: klar, behöver input och terminalklocka. Det kontrollerades i Orcas källkod (`app.asar`). Orca spelar `.ogg`, `.mp3`, `.wav`, `.m4a`, `.aac` och `.flac`.

Olika ljud per händelse kräver alltså hooks i Claude Code. Konsekvensen är att det bara gäller Claude-agenter. Codex i Orca påverkas inte. Orcas eget notisljud bör stängas av, annars hörs båda.

## Hur ljuden togs fram

Hela kedjan går att köra om med skripten i `tools/`.






ElevenLabs-nyckeln står som `ELEVENLABS_API_KEY` i `C:\Users\rober\Repos\Activator.se\tools\podd\.env`. Den ska aldrig in i det här repot.

## Rättigheter (viktigt)




- **MIT-licensen gäller bara koden.** README:n undantar uttryckligen ljudfilerna.
- **Delning sker bara till inbjudna personer** för privat bruk. Det bryter fortfarande mot ElevenLabs villkor, så håll kretsen liten.
- **Ska pluginet bli publikt:** ta bort `sounds/` helt (även ur git-historiken) eller generera om replikerna med Roberts egen Professional Voice Clone (`DZvzq2c6zaa8bX0U5ehb`) via `tools/generate-lines.sh`.

## Status hos Robert

- Pluginet är installerat från GitHub med user scope: `voice-notifications@voice-notifications`.
- De tidigare hookarna i `~/.claude/settings.json` och skriptet `~/.claude/hooks/play-sound.sh` är borttagna. En kopia av inställningarna från innan finns i `~/.claude/settings.json.bak-ljud`.
- Orcas egna hooks i `settings.json` är orörda.
- Robert kör med `bypassPermissions`, så tillståndsljudet hörs sällan. Det spelas främst när en plan ska godkännas.

## Så gör du vanliga ändringar

**Byta eller lägga till ljud för en användare:** lägg filer i `~/.claude/voice-notifications/<event>/`. Den mappen går före de medföljande ljuden och överlever uppdateringar. `CLAUDE_VOICE_NOTIFICATIONS_DIR` går före båda.

**Byta de medföljande ljuden:** redigera `tools/lines.tsv` och kör

```bash
ELEVENLABS_API_KEY=... tools/generate-lines.sh hoFRVuV1dgrWMpMWgZqe
```

Lyssna, eller transkribera, innan du committar.

**Släppa en ny version:** höj `version` i `plugins/voice-notifications/.claude-plugin/plugin.json`, kör `claude plugin validate .`, committa och pusha. Användare uppdaterar med `/plugin marketplace update voice-notifications`.

**Bygga om extraheringsverktyget:**

```bash


dotnet build -c Release


```

## Öppna punkter

- **Bjuda in mottagare** till repot (GitHub, Settings → Collaborators, eller `gh api -X PUT repos/QuBaR/claude-voice-notifications/collaborators/<användare>`).
- **Stänga av Orcas notisljud** om det inte redan är gjort.
- **Hookarna har inte observerats live** i en ny session efter plugininstallationen. Skriptet är testat direkt (ffplay och PowerShell-reserv). Bekräfta att ett "klar"-ljud hörs efter omstart av Claude Code.
- **`idle_prompt` är medvetet utelämnad.** Den triggas en minut efter varje avslutad tur och skulle upprepa "input"-ljudet efter "klar"-ljudet.
- **Kräver bash.** På Windows utan Git Bash fungerar inte hookarna. Lös med `"shell": "powershell"` och ett PowerShell-skript om det blir aktuellt.
- **Publik variant** med Roberts egen röst är inte gjord.
