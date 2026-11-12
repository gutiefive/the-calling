# Environment Setup — The Calling

Set up and verified on **Wednesday, Nov 11, 2026 (≈11:00–11:30 PM CST)** on Nathan's PC (Windows 11 Home, x64,
NVIDIA RTX 4070 SUPER). No secrets or tokens are written in this document.

## 1. Installed software and verified versions

| Software | Version | How verified |
|---|---|---|
| Godot (standard, GDScript) | 4.7.2.stable.official.ed1daf0bf | `godot --version` from a fresh shell |
| Cursor | 2.0.77 (x64) | `cursor --version`; supports project-level MCP (`.cursor/mcp.json`) |
| Beckett — MCP for Godot (Lite, MIT) | 1.17.0 (+b3535ee5, "pristine" per `doctor`) | live MCP session: 56 tools |
| LibreSprite | 1.3 (portable) | `libresprite.exe --version`; drew + saved via MCP |
| LibreSprite-MCP (`libresprite-mcp`, PyPI) | 0.1.4 (remote script `mcp.js` v0.1.4) | live MCP session over stdio |
| Git | 2.53 | pre-existing |
| Python | 3.12.10 | pre-existing (uv also manages its own CPython 3.11 for tools) |
| uv / uvx | 0.12.6 | pre-existing, `C:\Users\natha\.local\bin` |
| Node.js / npm | 24.11.1 / 11.6.2 | pre-existing (not required by either MCP) |

Engine features checked with `tests/toolchain/check_features.gd` (all OK): GDScript, Node2D, Sprite2D,
AnimatedSprite2D, CharacterBody2D, Camera2D, TileMapLayer, TileSet, PointLight2D, DirectionalLight2D,
CanvasModulate, LightOccluder2D, OccluderPolygon2D, NavigationAgent2D, NavigationRegion2D.
Renderer in use: Vulkan 1.4 Forward+.

## 2. MCP servers selected

| Name | Purpose | Transport | Why |
|---|---|---|---|
| `beckett` | Drive the Godot editor: scene tree, nodes, scripts (validate-before-write), play/stop, logs, screenshots, live remote tree | Streamable HTTP, `http://127.0.0.1:8770/mcp/<token>` (served by the editor plugin) | Free MIT Lite edition, CI-tested on Godot 4.7.2 Windows, actively released (v1.17.0 on Nov 1, 2026), no Node/Python sidecar |
| `libresprite` | Run JavaScript inside LibreSprite (pixels, layers, palettes, frames, save/export) | stdio, `uvx libresprite-mcp` + relay on `localhost:64823` | Only MCP found that supports free LibreSprite |

Evaluated and **not** used:
- `shin2344234/godot-mcp` — alternative; Beckett chosen for 4.7.2 verification, maintenance, and run/see tools.
- `DaxianLee/godot-mcp` (the `godot-mcp` entry already in your **global** Cursor config, used by CardShop) —
  non-commercial license and reported 4.7 problems; left untouched, not used here.
- **Beckett Full** ($15) — not purchased. Adds input-driving playtests, test runner, animation tools.
- `MalloyTheDev/aseprite-mcp` — requires real **Aseprite** (not LibreSprite). **Upgrade path:** buy Aseprite
  ($19.99, Steam/itch) or self-build it (its EULA allows personal builds), then add aseprite-mcp to
  `.cursor/mcp.json` per its README. `.ase` files made in LibreSprite open in Aseprite.

## 3. Installation paths

| Item | Path |
|---|---|
| Project | `C:\Users\natha\Projects\the-calling` (outside OneDrive on purpose) |
| Godot (copy used by PATH) | `C:\Tools\Godot\4.7.2\` (`Godot_v4.7.2-stable_win64.exe`, `..._console.exe`, `godot.cmd`) |
| Godot original download (untouched) | `C:\Users\natha\Downloads\Godot_v4.7.2-stable_win64.exe\` |
| LibreSprite | `C:\Tools\LibreSprite\1.3\libresprite.exe` |
| LibreSprite user scripts | `%APPDATA%\LibreSprite\scripts\` → `mcp.js` (stock), `mcp-autoconnect.js` (local variant) |
| Beckett addon | `res://addons/beckett/` (from release asset `beckett-godot-mcp-lite-v1.17.0.zip`) |
| Beckett runtime state (token, port) | `res://.beckett/` — gitignored, never commit |
| Downloaded installers / test scratch | `C:\Tools\_downloads\` (safe to delete) |
| User PATH backup (before change) | `C:\Tools\_downloads\userpath-backup-20261111.txt` |

Download hashes (SHA-256): Beckett zip `2D35A8A2…6CC365`, LibreSprite zip `8408D2F9…475874`, mcp.js `FADCD37A…DA5CF09`.

## 4. Required dependencies
- Godot 4.7.2 standard build (no .NET needed).
- `uv`/`uvx` (for `libresprite-mcp`; it pulls `mcp` and `flask` from PyPI into uv's cache on first run).
- LibreSprite 1.3 running with the `mcp.js` (or `mcp-autoconnect.js`) script for pixel-art MCP calls.
- The Godot editor open on this project for Beckett calls.
- Node.js is **not** required.

## 5. Cursor configuration location
- **Project config (used):** `C:\Users\natha\Projects\the-calling\.cursor\mcp.json` — servers `beckett` and
  `libresprite` (command = absolute path `C:\Users\natha\.local\bin\uvx.exe`, args `libresprite-mcp`). **Gitignored** because Beckett embeds the auth token in the URL. Backup of the Beckett-written
  version before adding libresprite: `.cursor\mcp.json.bak-20261111` (also gitignored).
- Token-free template (tracked): `.cursor/mcp.example.json`.
- Project rule (tracked): `.cursor/rules/the-calling.mdc` → tells the agent to follow `AGENTS.md`.
- Beckett also writes `.mcp.json` (Claude Code format) — gitignored.
- **Global config `C:\Users\natha\.cursor\mcp.json` was not modified** (still has godot-mcp, unityMCP, rea).
  Note: the global `godot-mcp` entry will also appear in Cursor when you open this project; it targets the
  CardShop addon and will simply be disconnected here. You can toggle it off per project in Cursor's MCP settings.

## 6. Godot editor-plugin configuration
`project.godot`:
```ini
[editor_plugins]
enabled=PackedStringArray("res://addons/beckett/plugin.cfg")
[autoload]
BeckettRuntime="*uid://…"        ; added by Beckett: inert stub outside the editor, stripped from exports
[beckett]                          ; dock state written by Beckett
```
Beckett auto-starts its server ~1 s after the editor's first filesystem scan (not during `--import`/export runs)
and rewrites `.mcp.json` / `.cursor/mcp.json` (merging, keeps the libresprite entry). Dock: **Beckett** tab next to
the Inspector (Start/Stop, Connect Detected Clients, Auth token Rotate, AI-effort slider). Options: project settings
`beckett/autostart`, `beckett/port` (8770); env `BECKETT_PORT`, `BECKETT_READONLY=1`, `BECKETT_CONFIRM_DESTRUCTIVE=1`.

Display/render choices: 640×360 viewport, 1280×720 window, stretch `viewport` + `integer`, default canvas filter
Nearest, 2D transform + vertex pixel snap on, Forward+ renderer. See README and ART_BIBLE.

## 7. How to start Godot
```powershell
godot --version                                                   # 4.7.2.stable.official.ed1daf0bf
godot --editor --path C:\Users\natha\Projects\the-calling          # editor (+ Beckett server)
# or double-click C:\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe and pick the project
```
`godot` = `C:\Tools\Godot\4.7.2\godot.cmd` (console build, so output shows in the terminal). Open a **new**
terminal after setup so the PATH change is picked up.

## 8. How to open the project in Cursor
```powershell
cursor C:\Users\natha\Projects\the-calling
```
Then (one-time, in the Cursor UI):
1. **Cursor Settings → Models**: enable the newest **Claude Opus** model listed for your plan; pick it in the Agent
   chat's model dropdown. (Model availability/billing depends on your Cursor plan — no billing was changed.)
2. **Cursor Settings → Tools & MCP** (or "MCP"): under the project servers, confirm **beckett** (needs the Godot
   editor open) and **libresprite** are enabled and show a green dot with tools listed. Approve tool use when the
   agent first calls them (or enable auto-run for these servers if you prefer).
3. Ask the agent: *"Read AGENTS.md, then call beckett get_godot_version and get_scene_tree for
   res://tests/toolchain/toolchain_test.tscn."*

## 9. How to reconnect MCP servers
**Beckett:** open the Godot editor on this project first → in Cursor's MCP settings toggle `beckett` off/on (or
reload the window). If you get `401`, the token changed: press **Connect Detected Clients** in the Beckett dock (it
rewrites `.cursor/mcp.json`) and reload Cursor.

**LibreSprite:**
1. Make sure Cursor has started `libresprite` (green in MCP settings) — that starts the relay on port 64823.
2. Start LibreSprite and run the script, either:
   - GUI: LibreSprite → **Scripts** menu → `mcp` → click **Connect** in the dialog, or
   - Auto-connect launcher:
     ```powershell
     C:\Tools\LibreSprite\1.3\libresprite.exe --script "$env:APPDATA\LibreSprite\scripts\mcp-autoconnect.js" <file.ase|png>
     ```
3. LibreSprite's API cannot create a new sprite from script; open (or pass on the command line) an existing file
   of the right size first, e.g. a blank 32×32 PNG, then let the agent draw and `saveAs` it.
4. Running another LibreSprite script disconnects `mcp.js`; re-run it. Only one `libresprite-mcp` instance can run
   at a time (port 64823 must be free).

## 10. Troubleshooting
| Symptom | Fix |
|---|---|
| `godot` not recognized | Open a new terminal; check user PATH contains `C:\Tools\Godot\4.7.2` |
| beckett red/disconnected in Cursor | Godot editor not open, or another editor holds port 8770 (`BECKETT_PORT`), then toggle the server |
| beckett `401` | Stale token → dock **Connect Detected Clients** (or **Rotate**) → reload Cursor |
| Beckett runtime tools say "game not running" | `play_scene`, then `wait_until condition=game_connected` (repeat; per-call cap ~1.5 s) |
| libresprite tool hangs ~15 s then warns | LibreSprite isn't running `mcp.js` / not connected; run it and click Connect |
| libresprite fails to start | `uvx` not on PATH for Cursor → use the full path `C:\Users\natha\.local\bin\uvx.exe` as `command`; port 64823 busy → close other instance |
| Blurry pixel art | Check Project Settings → Rendering → Textures → Default Texture Filter = Nearest, and the node's Texture Filter = Inherit/Nearest |
| Godot cache weirdness | Close editor, delete `.godot/` (cache only), reopen |
| Project on OneDrive | Don't move it to Desktop/OneDrive (sync locks `.godot/` and `.git/`) |

## 11. How to update dependencies safely
1. Commit first (`git status` clean).
2. **Godot:** download the new official build from godotengine.org / GitHub releases into `C:\Tools\Godot\<ver>\`,
   update the user PATH entry and `godot.cmd`, open a *copy* of the project or a branch first; keep the old folder.
3. **Beckett:** read the release notes, download the `beckett-godot-mcp-lite-vX.zip` release asset, close the editor,
   replace `addons/beckett/` on a branch, open the editor, run `doctor`, re-run the toolchain test, commit.
4. **libresprite-mcp:** `uvx` picks the latest version from PyPI each start; to pin, use
   `"args": ["libresprite-mcp==0.1.4"]`. Update `mcp.js` from the matching GitHub release (and re-apply the one-line
   auto-connect patch to `mcp-autoconnect.js` if you use it).
5. **LibreSprite:** extract the new portable zip into `C:\Tools\LibreSprite\<ver>\`, keep the old one.
6. Re-run the toolchain test (below) after any update.

## 12. How to reproduce this environment (new PC)
1. Install Git, uv, Cursor. Download Godot 4.7.2 (win64) to `C:\Tools\Godot\4.7.2\`, create `godot.cmd`:
   `@echo off` / `"%~dp0Godot_v4.7.2-stable_win64_console.exe" %*`, add the folder to the user PATH.
2. Download `libresprite-v1.3-windows-x86_64.zip` from github.com/LibreSprite/LibreSprite/releases → extract to
   `C:\Tools\LibreSprite\1.3\`. Download `mcp.js` from github.com/Snehil-Shah/LibreSprite-MCP/releases →
   `%APPDATA%\LibreSprite\scripts\`.
3. `git clone` the repo to `C:\Users\<you>\Projects\the-calling` (addons/beckett is committed).
4. `godot --headless --path . --import`, then `godot --editor --path .` → Beckett writes `.beckett/token`,
   `.mcp.json` and `.cursor/mcp.json`.
5. Add the `libresprite` entry from `.cursor/mcp.example.json` into `.cursor/mcp.json` (keep the Beckett URL as written).
6. `cursor .` → steps in §8.

## Toolchain test results (actual, Nov 11, 2026 CST)
| Test | Result |
|---|---|
| Headless import (`--import`) | PASS, exit 0, no errors |
| Feature check (`check_features.gd`) | PASS, `FEATURES_ALL_OK` |
| Toolchain scene headless | PASS, `TOOLCHAIN_OK` |
| Toolchain scene windowed (Vulkan Forward+) | PASS, `TOOLCHAIN_OK`; 6 source colors, **0** rendered pixels outside the source palette at 4× → nearest-neighbor confirmed |
| Test tile import settings | `mipmaps/generate=false`, lossless; filter comes from project default (Nearest) |
| LibreSprite-MCP: initialize/tools | PASS — server `libresprite`, tool `run_script`, resources `docs://reference`, `docs://examples` |
| LibreSprite-MCP: run_script | PASS — drew an original 32×32 grass+stones tile (6 colors) in LibreSprite 1.3 |
| Editable source | PASS — `tests/toolchain/test_tile_32.ase` (Aseprite format, magic 0xA5E0, 32×32, RGBA) |
| PNG export | PASS — `tests/toolchain/test_tile_32.png` 32×32 RGBA, 6 colors |
| Sprite-sheet export (CLI) | PASS — `libresprite -b file.ase --sheet out.png --data out.json` |
| LibreSprite-MCP: palette set / NewFrame from script | **FAIL** — no effect (see notes and workarounds) |
| Beckett: initialize / tools/list | PASS — `beckett-godot-mcp 1.17.0`, protocol 2025-11-25, 56 tools |
| Beckett: get_godot_version, open_scene, get_scene_tree, read_script | PASS |
| Beckett: create_node → save_scene → delete_node → save_scene | PASS (verified in the .tscn on disk, then restored) |
| Beckett: validate_script on broken code | PASS — returned the parse error with line number |
| Beckett: play_scene, wait_until game_connected, get_remote_tree, screenshot, game_logs, logs_read, stop_scene | PASS (screenshot showed the crisp tile; no error logs) |
| Cursor model / MCP panel | **Not verifiable from the terminal** — see §8 (ACTION REQUIRED) |

Notes:
- `mcp-autoconnect.js` was used for the automated test (stock `mcp.js` + auto-connect on discovery) because the
  stock script needs a human click on **Connect**. Everything else is the stock protocol path.
- The Beckett token was regenerated after testing (the first one appeared in a setup log). Rotate any time from the dock.
- LibreSprite-MCP's author describes it as brittle and lightly tested. Extra capability probe (scratch files in
  `C:\Tools\_downloads\lstest`, not the project):
  - **Pixels, layers' images, save `.ase`, export `.png`:** work (verified above).
  - **Palette editing from script: FAILED** — `sprite.palette.set(1, color)` had no effect on an RGB sprite
    (`palette.get(1)` stayed 0). Workaround: keep the master palette as a `.gpl`/`.ase` and load it in the GUI
    (or `--palette` on the command line), and have the agent draw with exact RGB values from `ART_BIBLE.md`.
  - **New animation frame from script: FAILED** — `app.command.NewFrame()` did nothing (`activeFrameNumber` stayed 0).
    Workarounds: (a) have the agent draw animation frames side by side in one wide image (e.g. 128×48 for four
    32×48 frames) and export that as the sprite sheet; (b) add frames in the GUI (Frame → New Frame), then let the
    agent draw on each; (c) upgrade path: Aseprite + aseprite-mcp, which has first-class frame/palette tools.
  - **Sprite-sheet export:** works through the LibreSprite CLI (`--sheet`, `--sheet-type horizontal`, `--data`).
