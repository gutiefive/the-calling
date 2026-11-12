# tests/toolchain — environment smoke test

Not part of the game. Proves the toolchain works end to end:

| File | What it is |
|---|---|
| `test_tile_32.ase` | Editable LibreSprite source of an original 32×32 test tile (drawn via LibreSprite-MCP) |
| `test_tile_32.png` | PNG exported from LibreSprite, imported by Godot (`.import` = nearest via project default) |
| `toolchain_test.tscn/.gd` | Shows the tile at 4×; checks size, filter setting, and (windowed) that rendered pixels contain no blended colors |
| `check_features.gd` | Headless check that required 2D classes exist and the default filter is Nearest |

```powershell
cd C:\Users\natha\Projects\the-calling
godot --headless --path . --script res://tests/toolchain/check_features.gd        # expect FEATURES_ALL_OK
godot --path . res://tests/toolchain/toolchain_test.tscn --quit-after 30          # expect TOOLCHAIN_OK
```
