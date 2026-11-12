# The Calling — Game Design (condensed)

Source: `docs/The_Calling_Godot_Codex_Project_Brief.md` (v0.1, Nov 2026) plus Nathan's setup brief (2026-11-11).
This is a condensed reference; the original brief remains authoritative where details differ.

## Pitch
A story-driven, top-down RPG in which a new pastor (≈28) moves to a struggling small town, earns the trust of its
residents, faces difficult moral and leadership choices, and helps a fractured church find its purpose again.

**Core dramatic question:** Can a new pastor help a struggling church become a healthy part of the town without
losing their integrity, ignoring difficult truths, or treating relationships as transactions?

## Setting
- **Oakridge** — fictional contemporary American small town (~2,400 residents): main street, diner, auto repair shop,
  hardware store, homes, park, small aging church. The game starts in a constrained neighborhood slice.
- **Grace Community Church** — once ~200 attendees, now ~17 on Sundays. Tired building, members who feel unheard,
  low leadership trust, a sensitive history around the prior pastor's departure. A financial problem surfaces at the
  end of Chapter 1.
- **Protagonist** — neutral default presentation and placeholder name; no character customization yet.

## Design pillars
1. **People before numbers** — named residents, relationships, believable dilemmas.
2. **Meaningful exploration** — a lived-in town, enterable buildings, environmental storytelling.
3. **Consequences without obvious min-maxing** — no +10/−10 labels on choices.
4. **Visible community change** — the church and town evolve; attendance is one signal, not the metric.
5. **Cozy look, grounded writing** — warmth, atmosphere, humor, mature themes handled carefully, no forced sermons.
6. **Compelling minute-to-minute play** — movement, discovery, purposeful chores, dialogue, quests.

## What it is NOT
Not a church tycoon / budget spreadsheet sim; not an evangelism score-chaser or NPC-conversion collector; not a theology
quiz or preaching trainer; not satire or a proselytizing app; not 3D, open-world, multiplayer, procedural, or a farming
clone in the first release.

## Themes and tone
Trust, forgiveness, service, stewardship, grief, legacy, community, honesty, growth vs. care. Sincere Christian setting;
NPCs may be faithful, skeptical, wounded, uninterested, or undecided, and all have agency.

## Gameplay
**Weekly loop:** start a day and review a few priorities → explore and meet people/events → talk, investigate, do
practical tasks, complete quests → make choices with consequences → return home/church, advance time, see changes →
**Sunday** service and post-service conversations as the week's culmination.

- **Exploration:** smooth movement on a top-down map; readable interactables (doors, notes, supplies, people, benches,
  bulletin boards); contextual prompt; y-sort occlusion; buildings as separate scenes via doors.
- **Dialogue (M2):** speaker name, branching choices, and flags kept on `NarrativeState`. Portrait and a text-speed
  setting come later. Lines live in `data/dialogue/`.
- **Quests (M4):** the spare key ring, Oak Street through Saturday, then First Sunday. Schedules and one save slot are in.
- **Sundays (M4):** one narrative service. The sermon theme is hope, forgiveness, or service. Outcomes change a few
  lines and relationships. None of the three is a best choice. Perseverance is not in this chapter.
- **Church growth as narrative (future):** congregation health, community trust, community impact, attendance (rough
  signal only), facility condition — shown through visible world changes (cleaned grounds, reopened classroom,
  community garden, busier Sundays), not dashboards.

## Story outline
1. **The Arrival / The First Sunday** — Thursday arrival, locked door, meet Margaret; walk to the hardware store, meet
   Frank; inspect building, practical task, sermon theme, first Sunday; Margaret reveals financial trouble.
2. **New Beginnings** — follow up with residents, why trust eroded; a young family may return; skeptic may befriend you.
3. **Growing Pains** — pressure on facilities, volunteers, unresolved relationships; a public leadership dilemma.
4. **The Crossroads** — a donation/property opportunity with conditions and social consequences.
5. **What We Built** — a town event reveals cumulative impact; endings reflect trust, accountability, service,
   congregation health and character arcs, not just attendance.

Only Chapter 1 is in scope for the first vertical slice.

## Initial characters (provisional)
| Character | Role | First impression | Narrative purpose |
|---|---|---|---|
| Margaret | Church secretary, 68 | Dry humor, practical, guardedly welcoming | Tutorial guide; church history; keeper of records |
| Frank Miller | Auto shop owner, 62 | Helpful but skeptical of church leadership | Tests listening vs. persuasion; key resident arc |
| Harold | Longtime deacon | Proud, cautious, protective of tradition | Legitimate institutional concerns, not a villain |
| Sarah | Local mother | Busy, thoughtful, unsure whether to return | Practical family needs; value of follow-through |
| Thomas | Hardware-store owner | Friendly, knows everyone | Exploration, purchases, errands, town gossip |

No NPC exists solely as a quest dispenser or attendance target.

## Writing rules
Concise, character-specific dialogue; no mechanic-explaining speeches; skeptical residents aren't villains and leaders
aren't saints; faith can be central without removing NPC freedom to disagree; no "good/bad Christian" meters;
attendance never equals moral worth; treat grief, crisis, misconduct and money with care; all names, text, maps, art
and music original.

## Technical targets
Godot 4 (4.7.2 installed), native 2D, typed GDScript; 32×32 tile grid; ~32×48 characters; nearest-neighbor pixel
rendering; dynamic 2D lighting with day/night atmosphere; warm small-town environments; Windows desktop first,
keyboard + mouse (controller later).

## Open decisions
| # | Question | Notes |
|---|---|---|
| D1 | **Movement: 8-direction vs 4-direction animation** | Resolved for M1. 8-direction movement, 4-direction facing. See `docs/DECISIONS.md`. |
| D2 | Final game title | Brief lists as open. |
| D3 | Protagonist gender/name customization | Neutral default for now. |
| D4 | Exact pixel scale / internal resolution | 640×360 provisional, integer scaling. |
| D5 | Optional driveable vehicle | Open. |
| D6 | Denomination / theological specificity | Open. |
| D7 | Full NPC daily schedules | Simple windows shipped in M3. A full simulated day is still open. See `docs/DECISIONS.md`. |
| D8 | Lightweight minigames for church activities | Open. |
| D9 | Controller / Steam Deck requirements | Later. |
| D10 | Renderer: Forward+ vs Compatibility | Forward+ chosen for setup; revisit for low-end laptops. |
