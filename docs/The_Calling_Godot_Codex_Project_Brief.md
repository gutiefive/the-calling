# THE CALLING
## Codex-Ready Game Design & Technical Project Brief

**Project:** The Calling  
**Genre:** Story-driven small-town pastoral RPG with light church/community progression  
**Engine:** Godot 4.x (stable installed version; use GDScript)  
**Platform target:** Windows desktop first; keyboard + mouse; controller support later  
**Visual style:** Top-down 2D pixel-art RPG with modern 2D lighting and shadows; classic Pokémon readability, Graveyard Keeper atmosphere and environmental detail  
**Camera:** Fixed top-down / three-quarter *art perspective* using 2D sprites and tilemaps (not a rotating 3D camera)  
**Phase:** First playable vertical slice; do not implement the full game yet  
**Document version:** 0.1, November 2026

---

# 0. INSTRUCTIONS TO CODEX — READ THIS FIRST

You are the lead Godot developer for an original indie RPG titled **The Calling**. Use this document as the project's initial design brief and implementation contract. Work in the existing repository if one is present; otherwise initialize a clean Godot 4 project in the current workspace.

Your immediate assignment is to implement **Milestone 1: a playable exploration prototype**, **not the entire game**. Keep all future systems described here as design context. Build Milestone 1 in small, verifiable increments; leave the project runnable after each increment.

**Do first:**
1. Inspect the environment, determine the installed Godot version and the current repository structure. Do not overwrite user work.
2. Create a concise `README.md`, `docs/ROADMAP.md`, and `docs/DECISIONS.md` (record decisions and unresolved tradeoffs).
3. Set up a Godot 4 project, input actions, a main scene, and an outdoor church blockout using simple **original placeholder art or procedural shapes**. Do not depend on downloaded paid assets or proprietary reference-game graphics.
4. Implement responsive 8-direction player movement with collisions and animation/state placeholders; a following fixed camera with pixel-art-aware settings; a small outdoor map with church, pavement, grass, and at least three environmental features; and at least one interactable character/object with a clear interaction prompt.
5. Implement a basic time-of-day demonstration (day/evening/night lighting) using Godot's 2D lighting tools. Prioritize correct function and readability over polish.
6. Add one door interaction that transitions between outdoor church grounds and a simple sanctuary interior, with a safe return spawn.
7. Make the game launch directly into the playable scene. Provide a short test plan and a list of next steps. If Godot is available headlessly, run project validation. Report what was actually tested versus what still requires manual playtesting.

**At the end of Milestone 1, stop** and summarize the files changed, controls, implementation details, known issues, and how to launch. Do not silently expand scope into a full dialogue system, quest framework, inventory, multiplayer, procedural map generator, or advanced church economy.

**Engineering expectations:** typed GDScript where sensible; small focused scenes/scripts; reusable interaction interface or pattern; descriptive naming; externalized configuration/data where useful; defensive null checks; no hidden hardcoded absolute paths; no fabricated claims of successful tests; meaningful comments around non-obvious logic. Use native Godot resources and features compatible with the installed stable Godot 4 version.

---

# 1. HIGH-LEVEL VISION

## 1.1 One-sentence pitch

**The Calling** is a story-driven, top-down RPG in which a new pastor moves to a struggling small town, earns the trust of its residents, faces difficult moral and leadership choices, and helps a fractured church find its purpose again.

## 1.2 Player fantasy

The player isn't a detached manager clicking on church buildings. They **are** the new pastor: walking through town, meeting neighbors, listening to their stories, completing practical tasks, preparing for Sundays, and living with the consequences of their choices.

## 1.3 Design pillars

1. **People before numbers.** Named residents, relationships, and believable dilemmas drive the game.
2. **Meaningful exploration.** The player walks a lived-in town, enters buildings, finds information, and discovers stories through interaction.
3. **Consequences without obvious min-maxing.** Decisions affect trust, relationships, and story conditions; avoid labeling dialogue choices with simple +10/-10 rewards.
4. **Visible community change.** The church and town evolve as quests and chapters progress. Attendance is one signal, not the sole success metric.
5. **Cozy look, grounded writing.** Pixel-art warmth, dynamic atmosphere, occasional humor, mature themes treated carefully, and no forced sermon after every quest.
6. **A compelling minute-to-minute game.** Movement, discovery, chores with purpose, dialogue, and quests need to feel engaging without bloated systems.

## 1.4 What the game is NOT

- Not a church tycoon or budget spreadsheet simulator.
- Not an evangelism score-chasing or NPC-conversion collection game.
- Not a theology quiz or preaching training tool.
- Not a satire of religious people or a proselytizing app.
- Not a 3D open world, multiplayer game, procedural sandbox, or farming clone in the first release.

## 1.5 Audience and tone

Players who enjoy character-driven exploration RPGs, cozy pixel-art towns, branching stories, and light resource/relationship systems. The game's Christian setting is sincere and specific, but human motivations should be understandable to players regardless of their background. Characters may be faithful, skeptical, wounded, uninterested, or undecided; all deserve agency and credible arcs.

---

# 2. WORLD, SETTING, AND PREMISE

## 2.1 Town

**Oakridge**, a fictional contemporary American small town of roughly 2,400 residents. It has a main street, diner, auto repair shop, hardware store, homes, a park, and a small aging church. The game begins in a constrained neighborhood slice, not an entire simulated city.

## 2.2 Church

**Grace Community Church**, once attended by around 200 people and now drawing approximately 17 on Sundays. The building is tired; some members feel unheard; leadership trust is low; the prior pastor's departure remains a sensitive topic. An underlying financial problem is discovered at the end of the opening chapter.

## 2.3 Protagonist

A new pastor, approximately 28 years old, relocating to Oakridge to lead Grace Community Church. For the initial build, provide a neutral default visual presentation and name placeholder; **do not** build character customization yet. Later, let the player choose a name/appearance if design and writing support it.

## 2.4 Core dramatic question

Can a new pastor help a struggling church become a healthy part of the town without losing their integrity, ignoring difficult truths, or treating relationships as transactions?

## 2.5 Themes

Trust, forgiveness, service, stewardship, grief, legacy, community, honesty, and the tension between growth and care. Avoid simplistic claims that every moral dilemma has a universally agreeable answer.

---

# 3. STORY OUTLINE

## Chapter 1 — The Arrival / The First Sunday

Thursday afternoon: the player arrives at the church, finds the front door locked, and meets secretary Margaret. A walk to the hardware store introduces the town and Frank, a mechanic with painful history involving the church. The player inspects the building, helps with a practical task, prepares a short sermon theme, and experiences a first Sunday service. Afterward, Margaret reveals evidence of deeper financial trouble. Choices affect some dialogue and relationships; the same broad story beats remain accessible to protect the early-game experience.

## Chapter 2 — New Beginnings

The player follows up with residents and explores why trust eroded. A young family may return to an event; a skeptical resident may form a friendship without attending. New service and outreach options appear. Longtime members disagree about the church's direction.

## Chapter 3 — Growing Pains

More community activity places pressure on aging facilities, volunteer capacity, and unresolved relationships. A public disagreement creates a leadership dilemma.

## Chapter 4 — The Crossroads

A major donation or property opportunity could help stabilize finances but carries conditions or social consequences. The player must reconcile competing priorities and earlier promises.

## Chapter 5 — What We Built

A significant town event and church gathering reveal the cumulative impact of the player's choices. Endings reflect trust, accountability, community service, congregation health, and individual character arcs—not just attendance.

**Only Chapter 1 is in scope for the first vertical slice. Only the minimal location and interaction foundation is in Milestone 1.**

---

# 4. INITIAL CHARACTERS

These are provisional story design records, not yet fully implemented NPC AI.

| Character | Role | First impression | Narrative purpose |
|---|---|---|---|
| Margaret | Church secretary, 68 | Dry humor, practical, guardedly welcoming | Tutorial guide; knowledge of church history; keeper of records |
| Frank Miller | Auto shop owner, 62 | Helpful but skeptical of church leadership | Tests listening vs persuasion; key resident story arc |
| Harold | Longtime deacon | Proud, cautious, protective of tradition | Represents legitimate institutional concerns, not a cartoon villain |
| Sarah | Local mother | Busy, thoughtful, unsure whether to return | Shows practical family needs and the value of follow-through |
| Thomas | Hardware-store owner | Friendly, knows everyone | Introduces exploration, purchases, errands, and town gossip |

**NPC writing principle:** no character exists solely as a mission dispenser or attendance target. Most major NPCs should have their own schedule, wants, conflicts, and relationships beyond the protagonist.

---

# 5. MOMENT-TO-MOMENT GAMEPLAY

## 5.1 Primary loop

1. Start a day and review a small number of priorities.
2. Explore the accessible neighborhood and encounter characters/events.
3. Talk, investigate, perform practical interactions, and complete a story or side quest.
4. Make choices with consequences for characters and future scenes.
5. Return to church/home, progress time, and see changes in the world.
6. On Sundays, experience a narrative service and post-service conversations as a culmination of the week.

## 5.2 Exploration

- Smooth 8-direction movement on a top-down map.
- Clearly readable interactables: doors, notes, supplies, people, benches, bulletin boards.
- Contextual interaction prompt near a target.
- Layer sorting/occlusion for character moving behind trees and in front of buildings.
- Buildings are separate scenes initially; transition via doors. Avoid complex streaming.
- Environmental storytelling: neglected flower beds, church notice board, stacked chairs, tired walls, handwritten notes.

## 5.3 Dialogue (future milestone)

- Dialogue boxes with speaker name and optional portrait.
- Branching responses with conditions and persistent flags.
- Believable subtext and character voice; not every dialogue branch yields an explicit stat change.
- Explicitly mark temporarily unavailable responses only if the narrative needs it.
- Preserve accessibility and easy skipping of typewriter effects.

## 5.4 Quests (future milestone)

- **Main quests:** advance chapters and introduce the pastor/church conflicts.
- **Character quests:** build relationships and develop personal stories.
- **Community tasks:** grounded chores such as delivering supplies, repairing a fence, preparing an event, or restoring a room.
- Avoid repetitive fetch quests unless they create exploration, storytelling, or mechanical variety.
- Support objective tracking, clear completion feedback, and save persistence.

## 5.5 Sundays (future milestone)

- Weekly checkpoint, not an elaborate rhythm-game sermon minigame.
- Player chooses a sermon **theme** (e.g., hope, forgiveness, service, perseverance) and sometimes how to address a sensitive issue.
- Service attendance, conversations, community sentiment, and follow-up opportunities reflect prior story actions.
- Decisions can create tradeoffs; no sermon choice should be a guaranteed optimal growth strategy.

## 5.6 Church growth (future milestone)

Track several related but distinct outcomes:

- **Congregation health:** connection, conflict, belonging, volunteer well-being.
- **Community trust:** town perception of the pastor and church.
- **Community impact:** practical service and relationships beyond church membership.
- **Attendance:** rough participation signal, not a moral score.
- **Facility condition:** affects what events and services can run.

The player sees visible environmental milestones (cleaned grounds, reopened classroom, community garden, modestly busier Sunday) rather than only dashboard numbers.

---

# 6. ART DIRECTION AND PRESENTATION

## 6.1 Art target

**Original pixel art inspired by the readability of classic Pokémon and the density/atmosphere of Graveyard Keeper.** Do not copy sprites, maps, characters, logos, UI, soundtrack, or exact tile arrangements from either reference.

- Base environment grid: **32×32 logical pixels** per tile, subject to prototype testing.
- Provisional character sprite footprint: **32×48** pixels; tune scale against doors and furnishings.
- Pixel-art-first render, crisp nearest-neighbor textures, sensible integer scaling where practical.
- Top-down scene composition with illustrated building faces; visually angled geometry is in the art, not actual 3D perspective.
- Organic details: fences, hedges, cracked pavement, benches, light poles, utility boxes, notice boards.
- Palette: warm natural greens and earthy materials, with a small-town sense of age. Evening scenes can feel melancholy; mornings hopeful.
- UI: restrained, legible, inspired by pixel aesthetics but not restricted to illegible tiny fonts.

## 6.2 Lighting and weather

- Use Godot 4 **CanvasModulate**, **PointLight2D**, **DirectionalLight2D** where appropriate, **LightOccluder2D**/occluder polygons, and ambient color changes.
- Note that 2D dynamic shadows are stylized, not physically accurate long 3D shadows. Achieve pleasing results with occluders, overlays, and authored shadow sprites.
- Milestone 1: simple time-of-day demonstration and at least one clearly visible light/shadow source; not a production weather simulation.
- Later: rain, indoor lamps, sunrise/sunset, stained-glass ambience, and localized fog, after performance/readability testing.

## 6.3 Camera and resolution

- Camera2D follows player within map bounds.
- Choose a sensible low-resolution internal viewport (for example **640×360**, subject to tests) with pixel-aware scaling and desktop window resizing.
- Avoid subpixel jitter. Document smoothing/snap choices after visual testing.
- No forced camera rotation or zoom systems in the first milestone.

## 6.4 Audio

- Future: original ambient sounds (birds, footsteps, AC hum, doors, town traffic), restrained music themes.
- Milestone 1: audio is optional; ensure no copyrighted placeholder files are required.

---

# 7. GODOT TECHNICAL DESIGN

## 7.1 Engine strategy

**Use native Godot 4 2D scenes** for the first vertical slice. Earlier concept discussions considered a 3D-built 2.5D game; this brief intentionally chooses 2D first for scope, sprite workflow, rendering clarity, and iteration speed. This is a deliberate production decision, not a claim that Godot 3D cannot work. If a 3D lighting test is desired later, create an isolated experimental scene before changing architecture.

## 7.2 Proposed scene layout (adapt to repository conventions)

```text
project.godot
README.md
docs/
  ROADMAP.md
  DECISIONS.md
  PLAYTEST.md
scenes/
  main.tscn
  world/
    church_exterior.tscn
    sanctuary.tscn
  actors/
    player.tscn
    npc_placeholder.tscn
  objects/
    interactable_door.tscn
    interactable_prop.tscn
  ui/
    interaction_prompt.tscn
scripts/
  actors/
    player.gd
    npc_placeholder.gd
  systems/
    world_transition.gd
    time_of_day.gd
  interactions/
    interactable.gd
    door.gd
  ui/
    interaction_prompt.gd
assets/
  placeholders/
  fonts/
  audio/
```

This is a starting structure; don't create empty files/directories just to match it. Use scene ownership and script boundaries that make practical sense.

## 7.3 Input map

| Action | Keyboard | Gamepad later |
|---|---|---|
| move_up | W / Up | Left stick up |
| move_down | S / Down | Left stick down |
| move_left | A / Left | Left stick left |
| move_right | D / Right | Left stick right |
| interact | E | South face button |
| pause | Escape | Start |
| advance_dialogue | Enter / Space | South face button |

Map only needed actions in Milestone 1. Ensure diagonals are normalized; no faster diagonal movement.

## 7.4 Entity principles

- **Player:** CharacterBody2D with collision, facing direction, move speed, animation state, and nearby interactable detection.
- **Interactables:** reusable base script or `interact()` contract; trigger only when within range, one target at a time, clear prompt.
- **World transitions:** door exposes destination scene and target spawn identifier. Avoid accidental instant re-entry on scene load.
- **NPCs:** begin as stationary, named placeholders. Dialogue and schedules added later.
- **GameState:** add an autoload only when cross-scene state genuinely needs it. Avoid an enormous global singleton.
- **Data:** later story/quest data should be externalized as Resource or JSON with validation, not scattered across dozens of conditionals.
- **Saving:** plan for it in interface design but do not implement full persistence in Milestone 1 unless required for functional transitions.

## 7.5 Collision and scene transitions

- Provide collision around building footprints and large props.
- Confirm player cannot walk through walls, block doorways accidentally, or spawn inside collision.
- Ensure outdoor-to-indoor and indoor-to-outdoor travel works consistently in repeated tests.
- Decide whether a transition fade is worth the complexity; a simple fade is acceptable, but not required for Milestone 1.

## 7.6 Performance and portability

- Design for a conventional Windows laptop/desktop, not high-end hardware only.
- Limit dynamic lights and shadow casters; avoid excessive full-screen effects.
- Avoid plugins unless a clear necessity is documented.
- Check compatibility with the installed Godot 4 stable release rather than assuming methods from an unrelated version.

---

# 8. MILESTONE PLAN

## M1 — Playable World Foundation (BUILD THIS NOW)

**Goal:** Launch the game, walk around church grounds, see atmospheric lighting, interact with something, enter a basic sanctuary, and return outside.

**Must have:**
- Bootable Godot project.
- Keyboard-driven normalized 8-way movement and collisions.
- Follow camera, readable pixel presentation.
- A handcrafted church exterior blockout (church, path/parking area, trees/props).
- At least one stationary character or prop, clear prompt, and simple interaction response.
- Day/evening/night demonstration; lighting is visually legible.
- One functioning door to sanctuary and safe return door.
- Clear README controls and launch steps.
- Manual test checklist and automated validation where feasible.

**Out of scope:** full town map, quests, branching dialogue, NPC schedules, inventory, church economy, custom character creator, sermons, saving, crafting, combat, multiplayer, complex weather.

**Definition of done:**
- Project loads without parse errors or missing resource dependencies.
- Player moves in eight directions, diagonals not faster.
- Player collides with walls/obstacles.
- Camera follows without major jitter.
- Interact prompt appears only when target in range; action triggers once per press.
- Interior transitions work both directions without immediate bounce or trap.
- Evening/night visual change is apparent while player and paths remain visible.
- README explains how to run and test; known limitations listed.

## M2 — Conversation & Quest Slice

- Dialogue UI with name, advance/skip, selectable choices.
- Two NPCs with distinctive dialogue.
- First compact quest: retrieve church keys or obtain supplies.
- Quest state and basic journal.
- Narrative flags retained across room transitions.

## M3 — Clock, Story Consequences & Town Block

- Day clock, simple schedules for 3–5 NPCs, church/hardware-street location.
- Relationship flags and consequences in dialogue.
- Basic save/load using versioned data format.
- Opening story chain through Saturday.

## M4 — First Sunday Vertical Slice

- Sunday service cutscene/sequence.
- Sermon theme choice with meaningful but modest narrative impact.
- Character follow-up interactions.
- End-of-chapter financial discovery.
- 15–20 minute replayable demonstration with a start and ending.

## M5+ — Only after prototype feedback

- More town blocks, deeper character arcs, community tasks, restoration, events, church progression, additional chapters, improved art/audio, accessibility, balancing, and distribution planning.

---

# 9. M1 BUILD ORDER (IMPLEMENTATION CHECKLIST)

1. **Audit & bootstrap:** inspect repository, current Godot install, project conventions. Set up source control ignore patterns and basic documentation.
2. **Main scene & environment:** small church exterior blockout, simple tile/shape ground, collisions, visible spawn.
3. **Player & camera:** CharacterBody2D movement, collision, facing, camera, pixel presentation.
4. **Interaction system:** nearby-target detection, E prompt, small on-screen response, no overlapping action spam.
5. **Sanctuary:** second scene, two-way door transitions, spawn markers.
6. **Lighting:** demonstrate day/evening/night, indoor lighting, minimal shadow occluders and controlled debug switch if useful.
7. **Polish & validation:** fix edge cases, update docs, provide reproducible checklist and actual test results.

Build one step at a time; after each, verify or clearly state that verification is blocked by tooling. Prefer placeholder geometry that looks coherent over spending days generating art assets.

---

# 10. M1 ACCEPTANCE TESTS

The following should be executable as a manual smoke test; automate any Godot headless checks that are feasible.

**T01 — Launch:** Opening `project.godot` and running the main scene places the player outdoors with no missing resources or script errors.

**T02 — Movement:** W/A/S/D and arrow keys move as expected; diagonals have normalized velocity; letting go stops movement.

**T03 — Collision:** Player cannot walk through church walls, trees, or other designated obstacles.

**T04 — Camera:** Camera follows player and does not show outside playable bounds or visibly shake under normal movement.

**T05 — Interaction range:** Prompt appears near the designated interactable and disappears when out of range.

**T06 — Single action:** Pressing E triggers a single interaction, not repeated triggers every frame.

**T07 — Doors:** Church entrance leads to sanctuary; interior exit leads outside to a safe spot; entering/exiting repeatedly does not cause a loop.

**T08 — Lighting:** A simple key/debug cycle demonstrates at least day/evening/night and does not make the game unplayably dark.

**T09 — Restart:** Restarting the game restores a predictable playable state.

**T10 — Documentation:** README contains exact run instructions, controls, file layout, and known limitations.

---

# 11. UX AND ACCESSIBILITY PRINCIPLES

- Clear interactions and objective context; do not make the player pixel-hunt.
- Legible UI at 1080p and smaller laptop displays.
- Ensure color is not the only signal for interactability.
- Avoid rapid flashing and excessively dark night scenes.
- Future dialogue will offer instant-text and adjustable text speed.
- Support pauses and eventual key rebinding, but do not build a full settings menu for M1.

---

# 12. WRITING RULES FOR FUTURE MILESTONES

- Dialogue is character-specific, concise, and grounded; characters should not deliver speeches to explain game mechanics.
- Show complicated experiences without turning every skeptical resident into a villain or every church leader into a saint.
- Faith, scripture, and prayer can be central to the protagonist's world, but NPCs have independent motivations and freedom to disagree.
- Choices should create believable consequences, not crude “good Christian / bad Christian” meters.
- Do not conflate attendance with moral worth or make friendship contingent on church membership.
- Treat sensitive issues (grief, family crisis, institutional misconduct, financial pressure) with care; avoid using suffering solely as an upgrade mechanism.
- Use original character names, text, maps, artwork, and music.

---

# 13. RISKS AND DECISIONS

| Risk | Mitigation |
|---|---|
| Massive RPG scope | Build one polished neighborhood and one chapter before expanding. |
| Pixel lighting looks muddy | Use restrained 2D lights and ambient palettes; prioritize silhouette readability. |
| “Pastor game” becomes a dialogue-only visual novel | Add purposeful physical interactions, environmental exploration, and compact practical tasks. |
| “Church growth” turns NPCs into points | Model relationships and community impact independently of attendance. |
| Contradictory 2D/3D implementation | Choose 2D-native for M1; revisit only via an isolated experimental spike. |
| Too much narrative content before gameplay works | Playtest controls/camera/world interaction first. |
| Generated assets are legally uncertain | Create original placeholders and track licenses for future assets. |

Open questions to record in `docs/DECISIONS.md`, not to block M1: final game title; gender/name customization; exact pixel scale; optional driveable vehicle; denomination/theological specificity; whether full daily schedules make the game better; whether church activities need lightweight minigames; controller and Steam Deck requirements.

---

# 14. RECOMMENDED FIRST SESSION DELIVERABLE

Codex should deliver a working project with:

- A small outdoor church scene with grass, paths, church facade and at least a few props.
- A movable player using original placeholders.
- Camera follow and collision.
- A simple interactable NPC named Margaret or a notice board.
- An enterable sanctuary and return exit.
- Day/evening/night atmospheric lighting toggle or test cycle.
- README, roadmap, decisions log, and test instructions.

**Important:** The result should be playable even if there are no finished art assets. If the environment lacks a graphical Godot editor or cannot run a window, still generate syntactically valid native scenes/scripts and use available headless validation; clearly call out what was not visually verified.

---

# 15. COPY-PASTE START COMMAND FOR CODEX

> Read `The_Calling_Godot_Codex_Project_Brief.md` in full. Treat Section 0 and Milestone 1 as the immediate implementation contract, with all other sections as future design context. Inspect the existing workspace and Godot version, then build **M1 only**: a launchable top-down 2D pixel-art church exterior, movable 8-direction character with collisions, fixed follow camera, simple interactable, sanctuary interior transition, and visible time-of-day lighting. Create or update README and project roadmap, validate with the tools available, and report exact test results and outstanding issues. Use original placeholder assets; do not add full quest/dialogue/economy systems yet. Preserve any existing code, stop after M1, and give me the precise steps to run it in Godot.

