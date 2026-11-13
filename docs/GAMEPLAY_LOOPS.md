# Gameplay loops — The Calling

Status: Phase B (gardening) implemented 2026-11-13. Phase A (inventory and items) remains. Phases C–F are specified here so they can plug in; they are not built yet.

## Baseline (before Phase A)

- **Branch:** `main` tracking `origin/main`
- **Commit:** `4af3da4` (Milestone 12: church grounds redesign)
- **Remote:** https://github.com/gutiefive/the-calling
- **Engine:** Godot 4.7.2, typed GDScript, 2D only
- **State:** M0–M12 implemented. Chapter 1 plays start to finish. Continue in Oakridge runs the weekly loop, ChurchFunds, and the Fellowship Hall project. Hidden Pull, Shepherd/Builder/Skeptic leanings, and story threads persist. No inventory, no personal wallet, no shop purchases.
- **Save:** `user://the_calling_save.json`, version 6. Versions 1–5 migrate. Church money lives only on `ChurchFunds` and the ledger.
- **Test suites (all green at M12):** `m1`, `m2`, `m3`, `m4`, `m4_5`, `m5a`, `m5b`, `m6a`, `m6a2`, `m7`, `m8`, `m9`, `m9b`, `m10`, `m11`, `m11b`, `m11c`, `m12`, plus `tests/toolchain/`

## Integration-point audit

These existing systems stay in place. Phase A hooks them; it does not replace them.

| System | Where | Phase A use | Later phases |
|---|---|---|---|
| `DayClock` | autoload | Inventory and shop set `NarrativeState` locks so the clock holds still, same as the journal and ledger. | B: `GardenState` ticks growth on `time_changed` when the weekday advances past 6:00 a.m., guarded by `last_processed_day`. |
| `NarrativeState` | autoload | New UI flags `inventory_open` / `shop_open` join `movement_locked()`. Starter grants use new flags only (`starter_tools_taken`, `starter_seeds_taken`). Existing story flags, quests, leanings, and threads are untouched. | C: request accept/complete flags. D: repair flags mapped from `grounds_tidy` / `garden_*` when safe. |
| `ChurchFunds` | autoload | Never spent on personal items. Personal cash is `Inventory` wallet. Dollar amounts stay out of dialogue JSON. | E: potluck prep does not siphon the plate. |
| `SaveGame` | `scripts/systems/save_game.gd` | Version 8. Migration from 7 adds empty untilled church plots. Version 6 still gains a default pack and wallet on the way through 7. | C–E: extra blobs (`requests`, `repairs`, `event`) with the same migrate-forward rule. |
| Dialogue | `data/dialogue/`, `DialogueRunner` | Thomas, Margaret, garden_help, and Chapter 1 lines are unchanged. No `$` or dollar words in JSON. Shop is a separate UI, not a dialogue tree. | C: request accept nodes added beside existing routers, existing first choices kept. |
| Maple Lane garden | `GardenPlot`, `garden_help.json` | Unchanged Chapter 1 clear/plant beat. Weeds, `garden_cleared`, `garden_planted`, and `garden_growth` stay on this plot. The Phase A seed crate moved to the church garden. | C: garden-needs-hands request can read the same flags. |
| Hardware store | `building_interior.gd` HardwareInterior | Thomas still talks. A shelf interactable opens the shop UI (seeds, Wood, Nails). | D: same shop sells repair stock. |
| Parsonage | `building_interior.gd` | A toolbox grants the starter tools once. Bed / sleep unchanged. | B: sleep still advances garden morning. |
| HUD | `scenes/ui/hud.tscn` | Inventory panel (I), shop panel, small equipped-tool strip. Same panel chrome as journal / ledger. | B: short contextual lines (“Planted Carrot Seeds.”). C: journal lists active requests. |
| Input | `project.godot` | `inventory` (I). Esc closes inventory/shop before pause, matching journal/map/ledger. | B: no new energy bar. |
| Art pipeline | `scripts/art`, `tools/art/author_environment.gd` | 16×16 item icons, palette-only, written to `assets/items/`. | B–E: soil, crop stages, water, repair, potluck props through the same pipeline. |
| Church grounds chores | `GroundsChore` | Untouched. | D: refactor only when flags can be mapped 1:1. |

Signals: `item_added`, `item_consumed` (A), `crop_watered`, `crop_harvested`, `garden_action` (B). Reserved for later: `request_completed`, `repair_finished`, `event_prepared`.

---

## Daily and weekly loops

**Daily (existing, unchanged by A):** wake in the parsonage → optional exploration, talk, chores → sleep. The clock advances while walking and holds during dialogue, journal, map, ledger, pause, the morning card, inventory, and shop.

**Weekly (existing, unchanged by A):** after Chapter 1, Continue in Oakridge. Later Sundays run a short service, then the ledger. Attendance and the plate stay on `ChurchFunds`. Inventory work is optional and never required for Sunday.

**Target feeling once C–E land:** “one more day, the crops are almost ready, Sarah needs vegetables, I want to finish that fence.” Phase B adds the church garden. Harvests stay items until later phases give them somewhere to go.

Sunday stays special. Nothing in A forces a daily checklist.

---

## Inventory architecture (Phase A)

Autoload `Inventory` (`scripts/systems/inventory.gd`) is the pack and the personal wallet.

- **Catalog:** `data/items/catalog.json` loaded by `ItemCatalog`. Each item has id, name, description, category (`Tools`, `Seeds`, `Crops`, `Materials`, `Quest`), max stack, and icon id. No extra items beyond the listed catalog.
- **API:** `add`, `remove`, `quantity`, `has`, `can_add`. Invalid ids add nothing. Stacks fill existing piles up to `max_stack`, then occupy a new slot if capacity allows. Capacity is 16 slots (configurable in the JSON).
- **Signals:** `item_added(item_id, quantity)`, `item_consumed(item_id, quantity)`, plus `inventory_changed`, `wallet_changed`, `equipped_changed` for UI. Phase B should `remove` one seed on plant and listen to `item_consumed`.
- **Tools:** reusable, `max_stack` 1, no durability. `equip` / `equipped_tool` feed the hotbar. Phase B reads the equipped tool (hoe, watering can, hand tools).
- **Wallet:** integer cash on `Inventory`, starting `$20` from data. `gain_cash` / `spend_cash` / `can_afford`. `ChurchFunds.balance` is never read or written by these methods.
- **UI:** I toggles the inventory. Keyboard: arrows / WASD move the highlight, E equips a tool, I or Esc closes. Tools are tagged Tool; everything else is tagged as its category (consumable piles). Capacity and wallet print on the panel. A small equipped-tool strip sits at the bottom-left during exploration.
- **Shop UI:** at the hardware-store shelves. Lists catalog shop rows with fixed prices. E buys if the wallet and a free stack allow it; overspend and full-pack fail cleanly. Esc or I does not open the ledger. Dollars appear here, on the inventory panel, and on the wallet line — nowhere in dialogue.

## Item catalog (Phase A)

| Id | Name | Category | Max stack | How you get it |
|---|---|---|---|---|
| `watering_can` | Watering Can | Tools | 1 | Parsonage toolbox (once) |
| `hoe` | Hoe | Tools | 1 | Parsonage toolbox (once) |
| `hand_tools` | Basic Hand Tools | Tools | 1 | Parsonage toolbox (once) |
| `lettuce_seeds` | Lettuce Seeds | Seeds | 20 | Garden crate (once) or Thomas |
| `carrot_seeds` | Carrot Seeds | Seeds | 20 | Garden crate (once) or Thomas |
| `tomato_seeds` | Tomato Seeds | Seeds | 20 | Garden crate (once) or Thomas |
| `flower_seeds` | Flower Seeds | Seeds | 20 | Garden crate (once) or Thomas |
| `lettuce` | Lettuce | Crops | 20 | Phase B harvest |
| `carrots` | Carrots | Crops | 20 | Phase B harvest |
| `tomatoes` | Tomatoes | Crops | 20 | Phase B harvest |
| `flowers` | Flowers | Crops | 20 | Phase B harvest |
| `wood` | Wood | Materials | 50 | Thomas, `$4` |
| `nails` | Nails | Materials | 50 | Thomas, `$3` |
| `scrap` | Scrap | Materials | 50 | Not sold. Reserved for later find/repair beats. |

Shop prices (also in `catalog.json`): lettuce/carrot seeds `$2`, tomato/flower seeds `$3`, wood `$4`, nails `$3`. Starting wallet `$20`. Church money cannot buy these.

**Starter tools.** A toolbox in the **parsonage** (the kit left with the house). Taking it grants the three tools and sets `starter_tools_taken`. A second inspect only says the crate is empty. Margaret’s Chapter 1 lines are unchanged.

**Starter seeds.** A crate inside the **church vegetable garden** (east of the picnic lawn). Taking it grants a few of each seed packet and sets `starter_seeds_taken`. It does not touch the Chapter 1 Maple Lane plot. The neighbor’s `garden_help` conversation is unchanged.

**More stock.** Walk into Oak Street Hardware while Thomas is in, stand at the shelves, E to browse. Thomas’s spoken lines do not mention prices.

Icons are 16×16 palette pixels from `scripts/art/item_frames.gd`, authored to `assets/items/<id>.png`.

---

## Crops (Phase B)

Configurable in `data/crops/catalog.json`. Unwatered crops pause and never die. Ready crops do not need water. Sunday does not destroy crops.

| Crop | Watered days | Yield | Role |
|---|---|---|---|
| Lettuce | 2 | 1 | quick requests |
| Carrots | 3 | 2 | food deliveries |
| Tomatoes | 4 | 3 | community meals |
| Flowers | 3 | 2 | gifts and decoration |

## Gardening (Phase B)

**Where.** Nine plots sit in a fenced vegetable garden on the **church grounds**, east of the picnic lawn and south of the drive (`GroundsLayout.VEG_GARDEN`, tiles 39,32 9×9). It is not the memorial garden, not the parking lot, not a main path, and not one of the five Future Site lots in `data/grounds/plots.json`. A west gate opens onto an extension of the picnic spur. The Chapter 1 Maple Lane plot, its weeds, and `garden_cleared` / `garden_planted` / `garden_growth` are unchanged.

**Plots.** Autoload `GardenState` stores id, soil, crop, planted, watered, growth, stage, and ready for `church_0`…`church_8`. `GardenPlot` with a `plot_id` is a farm bed; an empty `plot_id` is still the Maple Lane story plot.

**Cycle.** Equip the Hoe, E to till. Equip a seed packet in the pack (I, then E), E to plant (consumes one). Equip the Watering Can, E to water (darker soil). Growth advances once per morning if the bed was watered, through sleep and DayClock, never a frame timer. `last_processed_day` prevents double-counting across skips, sleep, save/load, and leaving the room. Harvest yields the catalog crop and leaves plantable harvested soil. No energy bar. Wrong tool or missing seed does nothing and says why.

**Onboarding.** Ruth is still the Maple Lane walker (M5B one-place). She left a skippable card at the church garden: till, plant, water, come back after a morning, harvest. Plot prompts name the next action. A neighbor by the gate comments lightly when the beds look tended, with no numbers.

**Story.** Growing food is neutral. Gardening does not raise Pull, attendance, dependents, loyalty, or ChurchFunds. Harvests are items for later requests and the potluck.

## Community requests (Phase C, not built)

Data-driven, journal-visible, up to three active. At least: Sarah’s vegetables, Margaret’s sanctuary flowers, Harold’s fence (3 Wood, 2 Nails), and the garden-needs-hands beat. Rewards vary; no visible trust integers; no Pull for merely succeeding.

## Interactive repairs (Phase D, not built)

Weeds, litter, fence, flower bed. Short staged interactions with Basic Hand Tools equipped. Missing materials print “Missing: 3 Wood”. Persist across sleep, save, and the week. Keep `GroundsChore` flags working.

## Weekly potluck (Phase E, not built)

Extend the existing M8 potluck happening. Optional prep (food, flowers, grounds, invites) changes the room. Moral choice on who is invited uses existing hidden leanings. Do not duplicate Sunday or the Chapter 1 ending.

## Story integration

Growing food is neutral. Giving food, repairing public space, and how those things are offered are what may later touch relationships or Pull. Faith is not the villain. Insiders never say “cult”. No dollar amounts in dialogue. Phase B adds no Pull, no attendance bump, and no new story flags.

## Save changes

Version **8**. `capture()` writes `inventory: { slots, equipped, seed, cash }` and `garden: { last_processed_day, plots }`. Migration from 7 fills nine empty untilled plots and keeps the pack. Migration from 6 still fills default inventory on the way through 7. Church funds, narrative, clock, influence, pastor path, and threads pass through. A version 9 file is rejected until a later bump.

New Game / Restart call `Inventory.reset()` and `GardenState.reset()` from `NarrativeState.reset()`.

## Limitations (Phase B)

- Harvests have nowhere to go yet besides the pack (requests and the potluck are C and E).
- Scrap has no source.
- The shop does not sell tools (you already have them) or crops.
- No energy bar, no durability, no drag-and-drop mouse inventory.
- Item icons are procedural 16×16 PNGs scaled up in the pack. Crop stages are procedural 32×32 PNGs in `assets/garden/`. No LibreSprite `.ase` sources.

## Future expansion (do not build)

Greenhouse, larger farm, kitchen, workshop, volunteers, construction, town projects, seasons, weather, resident preferences, Sunday prep, staff scheduling. Phase A’s catalog, wallet, and signals are the hooks.
