# The Calling: The Quiet Ambition (design proposal, rev 4)

Status: approved as D42, 2026-11-13. Revision 4 settles how money is shown (section 6). Revision 3 added Nathan's earlier answers. Influence climbs a ladder from
personal trust to a voice on the council. A rare inner voice nudges but never decides. Raising funds to expand the
church grounds is now a core system. Earlier answers still stand: the story is driven by ambition, not a
supernatural pact; insiders never say "cult"; followers live on site and in town; spirits are a mix of faith-touched
and ordinary ghosts; endings are TBD. M7 (seeds and influence) is implemented. Later milestones in section 10 are not started.

---

## 1. Pitch and tone

**The Calling** stays a cozy small-town pastor RPG on the surface. Underneath, it becomes a story about a good person
discovering how much they like being needed, and how far they'll go to make a town run through their church.

You arrive sincere, fix the step, listen to Frank, and preach to seventeen people. Then the ledger shows deposits from
an account Margaret doesn't recognize, and a council member starts dropping by to "offer support." The church grows.
So does your reach: who trusts you, who owes you, who lives on your grounds, and whose vote you can count on. No
demon makes you do it. The hunger is yours, and the game lets you feed it or refuse it.

**Tone:** cozy meets dark, like Cult of the Lamb's contrast, but slower, more human, and with no combat. Days are porch
lights, potlucks and scaffolding going up. Nights get quiet and strange, with a few ghosts and a light in the
steeple. The unsettling part is always the people, including you.

**Keeping it respectful:**
- **Faith is never the villain.** Members sincerely believe in the church and the work, and that sincerity is what
  can be misused. Sincere faith (Margaret, Harold, Sarah) is often what *resists* the power-hungry path.
- **The danger is ordinary ambition**, in good-sounding steps: "the town needs a steady hand," "let the church handle
  it," "you don't need those people."
- **Spirits are never a punchline or a cause.** They witness.
- There's no gore and no mocking ritual. Grief and money keep the original brief's care.
- **Insiders never say "cult."** No member, follower, or attender uses or hints at the word. To them, this is the
  church finally working. Only non-attenders allude to it (section 2).

**Core question:** *Can a pastor help a struggling church become a healthy part of the town without making the town
belong to them?*

---

## 2. Two paths, Pull, and the influence ladder

| | **Community** | **Congregation** (the power-hungry path) |
|---|---|---|
| Trust | Given back: share credit, send people home, tell hard truths | Kept: you become the center and the one who decides |
| Followers | Keep their own lives and help when they choose | Depend on the church for housing, work and friends |
| Money | Small, clean, and said out loud | Big, fast, and owed to someone |
| The town | Grows connections that don't run through you | Its council, shops and families quietly answer to you |

### Pull (hidden)

**Pull** is never shown. It measures how much of Oakridge runs *through you*, across three parts: **Seats** (council
votes you can count on), **Storefronts** (businesses that depend on church money or labor), and **Dependents** (people
who rely on you for a roof, a job or food). The four visible journal measures (congregation health, community trust,
community impact, the building) stay as Strained, Steady and Growing. On the high-Pull path, they can look *great*.

**Pull rises when you:** take credit, accept a favor with strings, steer church money or labor to buy loyalty, keep
the ledger quiet, make someone's livelihood depend on you, ask for a vote, or let a follower cut off family.
**Pull falls when you:** say the true sentence out loud, refuse strings, send someone home to rest, point people to
each other instead of you, or let someone leave without guilt.

### The influence ladder (in stages)

Influence grows slowly, and every rung can be climbed for good reasons or selfish ones.

1. **Trust, person by person** (Chapters 1–2). This is today's game: listening to Frank, hearing Sarah, fixing the
   step. Relationships and community trust are the only currency, and nobody at the town hall knows your name.
2. **The invited guest** (Chapters 2–3). Residents who trust you start asking you to speak on town issues. Examples:
   - a **zoning dispute** over a fence line between two Maple Lane families
   - **creek flooding** after the spring rain, which threatens the park and three houses
   - the county **cutting the bus route** past the Maple Lane stop

   Each is a short guest scene, on a porch, at the diner, or as one agenda item at the town hall. You can calm the
   room and hand it back to the residents (Community), or take the issue as yours and become the person they call
   (Pull).
3. **The active voice** (Chapters 3–4). Tuesday-evening council meetings become scenes you attend at will. You can
   speak, stay silent, broker a deal in the hallway, or have the Gathered pack the room. The five council members
   each have a want, such as a road fixed, a rival embarrassed, or a nephew hired.
4. **A seat, or the power behind them** (Chapters 4–5). A seat opens. You can run in a special election, back a
   candidate you trust, or quietly make sure three votes are always yours. Holding the seat openly is honest about
   power. Owning it from the pulpit is not.

**Off-screen influence runs the whole time.** Favors get called in, gossip travels, a shop owner gets a church
contract, and a casserole arrives with a note asking for "a word before Tuesday." You hear about it through Thomas,
Pearl's column, and the barks, not through a menu.

### The inner voice (rare, never decides)

Ambition comes mainly from the player's choices. A light inner voice adds flavor: two to four private lines per
chapter, shown in italics after a choice, at the council door, or in the parsonage mirror. As Pull rises, it gets
slightly more frequent and more sure of itself. On the Community path, it grows quieter and doubtful.
- Low Pull: *"They listened. That felt good. Maybe too good."*
- Mid Pull: *"Ostrow needs you more than you need him. Remember that."*
- High Pull: *"Who else would they follow? Be honest."*

It's never a dialogue option, never locks or highlights a choice, and has a toggle in settings.

### Tells, never numbers

- **What people call you.** It goes from "Pastor" to "Pastor [name]" to "Shepherd." Members say it warmly and
  sincerely.
- **The journal's wording.** "Growing" becomes "Gathering," and "a small gathering" becomes "the faithful."
- **Storefront signs.** "Church family discount" appears in windows. Plaques on the new buildings name who paid.

**Outsiders who don't attend** allude to what's happening. They rarely say it outright:
- **"Around Oakridge," Pearl Haskins's newspaper column** (new): "A reader asks whether a church can own a town. I told
  her I'd look into it."
- **Sidewalk neighbors** Ada, Ben and Cleo: "Everyone up there wears the same coat now."
- **Cal Bright** (new), who runs the diner and won't take church money: "My dad had a word for groups like that. Not
  in my diner."
- **Frank, if he stops attending:** "I've seen this before. Last time it had a different pastor."

---

## 3. How Chapter 1 seeds it (small, concrete changes)

1. **The ledger** (`sunday_ledger.json`). Margaret adds: "Some months there's a deposit from an account I don't
   recognize. Always the week before a council vote."
2. **The spare key ring.** Add an old key that fits nothing. Margaret: "Pastor Reece kept that one on him." It later
   opens his file box in the parsonage.
3. **The first "Shepherd."** A congregant says "Thank you, Shepherd," then corrects herself: "Pastor. Sorry. That's
   what we called him."
4. **A council visitor.** On Saturday, Councilman Dell Ostrow (new) stops on the church walk: "Pastor Reece and I got
   a lot done together."
5. **The garden.** Ruth: "Pastor Reece used to say the garden was how you learn who'll show up."
6. **Frank's "Don't spend it."** The line already exists. Keep it as the quiet thesis: trust is not currency.
7. **Pull starts recording.** Pressing Frank toward Sunday adds 1. Inviting Sarah instead of hearing her adds 1.
   Listening to either subtracts 1. No Chapter 1 outcome changes.

**What happened to Alden Reece.** Reece wasn't cursed. He was ambitious. He took quiet money from Ostrow and the
landowner Ivey Dunmore (new) to build a grand new wing, in exchange for the church's backing on council votes. When a
vote went wrong, the money stopped, the wing was never built, the ledger got papered over, and he stopped returning
calls. His letters show a sincere man who talked himself into running a town. That's the mirror the player is
holding. His unfinished foundation is still behind the church, and it's where your building starts.

---

## 4. The spirit world (a mixture, no fighting)

Spirits give Oakridge's nights a second life worth exploring and sometimes reflect your ambition. They never cause it
and are never fought.

- **Town ghosts (Lingerers).** These are the quiet dead at places they loved: a boy fishing at the creek, an old man
  at the Maple Lane bus stop, a woman sweeping a porch that's gone. Each has one small unfinished thing. Helping one
  is an optional short scene that leaves a permanent mark on the town.
- **Frank's wife.** A figure waits outside his bay at closing. This is the emotional heart of the ghost story.
- **The watcher in the steeple.** A still light some members would call an angel. It's brighter in weeks you did
  something selfless and absent after a deal. It never speaks.
- **Prayer-lights.** Warm lights around people praying alone at night. They're also a burnout tell: a follower ringed
  with them needs rest.
- **The Hollow.** A shadow that could be a demon or just the shape of a worst urge. It stands near temptation: the
  council door, behind Ostrow, and at high Pull, behind *you* in the parsonage mirror. It offers and asks nothing.

**Who sees them:** the pastor, faintly, from Chapter 2. Margaret has seen the steeple light for forty years. June,
Sarah's seven-year-old (new), sees everything and mentions it casually. Frank sees only his wife. Harold sees nothing
and asks what you're doing out there at night. Spirits appear mostly after 9:00 p.m., in places you already know.

---

## 5. Followers ("the Gathered")

Becoming a follower is the moral question, not a score. People join through relationships and moments of need, such
as a widower or a teen with nowhere to stay. The choice is "There's a room at the Fellowship House" or "Who else could
you lean on?" Both are kind. Only one centers you.

- **Live-in Gathered** stay on the grounds in beds the player has built (section 6). They're more available and more
  dependent, and each one adds to Dependents.
- **Town Gathered** keep their homes on Maple Lane and Oak Street and come to help on their own time. Asking one to
  "just move in, it's easier" is a key choice.

**Roles** (assigned at the notice board once a week; buildings unlock some):
- **Garden:** the plot and the greenhouse.
- **Errands:** supply runs and deliveries.
- **Outreach:** help with no strings, or invitations that build favors. You choose.
- **Upkeep:** repairs, and they speed up construction.
- **Kitchen:** meals for the Gathered or for the town.
- **Night Watch:** stays on the grounds after dark. It raises Pull the most.

**Needs** are shown in dialogue, never as bars: rest, their own life, and belonging. Followers whose own lives erode
get *more* loyal, and that's the trap. It stays ambient: one quick board visit a week, no timers, no fail screens.
Neglected followers just drift home. You can finish the game with zero followers.

---

## 6. Funds and building the grounds (core system)

Money finally has a purpose: **expanding the church grounds.** It's the reason to care about the plate, and the
easiest place for ambition to hide.

### Where money comes from (and what it costs)

| Source | How it works | Moral weight |
|---|---|---|
| **Offerings** | The Sunday plate rises with congregation health | Clean, slow |
| **Donations** | Residents who trust you give for a named need | Clean when you say what it's for |
| **Fundraisers** | A bake sale, a car wash at Frank's bay, a harvest auction | Depends on how you ask: an honest ask versus guilt, pressure, or live-ins "pledging" their wages |
| **Favors** | Ostrow and Dunmore offer large sums, a zoning variance, or a bank extension | Fast and big, with strings. Each one adds Pull and a debt they'll call in at a council vote |

The oil bill and the old debt from Chapter 1 compete with building. Paying debts down first is the honest, slower
road.

### How money is shown (tunable, revisit after playtest)

- **Dollars appear only in the ledger and on the planning board.** Example: the Fellowship House costs $8,400, and
  the church has $5,100 on hand.
- **Dialogue never names amounts.** An offering is "Ruth pressed an envelope into your hand." A favor is "Let me take
  care of that for you." The ledger records the figure afterward.
- **Strings money shows its exact amount in the ledger**, so the temptation lands: "Ostrow's check: $3,300. Covers
  the gap exactly."
- **Trust, Pull and relationships are never numbers**, only tells and words.
- **Balancing needs:** no softlocks (the story never requires a purchase), a minimum weekly income floor so an
  honest, slow church can still build Tier 1, and all costs, income and the floor in `data/buildings.json` /
  `data/funds.json` for simple tuning. Log as a new decision, marked "revisit after playtest."

### How you build

You build from a **planning board in the church office**, which shares the ledger's page. Pick a project, see its
cost and what it needs, and commit funds. Harold may object in dialogue, but he can't block you. Construction shows
scaffolding on a **fixed, pre-placed site** on the expanded lot, starting at Reece's unfinished foundation, and takes
about a week. Upkeep followers shorten it. There's no grid and no free placement for now.

### Three tiers

| Tier | Building | For the town | For your influence |
|---|---|---|---|
| **1 (Chapter 2)** | **Workshop** (old shed) | Free repairs for neighbors | Shops lose repair work to you |
| | **Greenhouse / bigger garden** | Produce for shut-ins | Food that people come to depend on |
| **2 (Chapter 3)** | **Fellowship House** (dorms, 4 beds, then 8) | Emergency housing | Live-in Gathered, so Dependents |
| | **Kitchen and dining hall** | Community suppers | The church becomes where everyone eats |
| **3 (Chapter 4)** | **Meeting hall** | Neutral ground for town meetings | Council business moves onto your property |
| | **Small school or daycare** | Helps Sarah and working parents | Families' weekdays run through the church |
| | **Print shop** | The church newsletter, plus flyers for anyone | Your answer to Pearl's column |

Every building does real good, and that's the point. Its effect on the town versus on your influence depends on
**who paid** (a clean or a strings plaque), **who runs it** (town volunteers or live-ins), and **who it's open to.**

---

## 7. Chapter arc (about 5 chapters)

**Chapter 1: The First Sunday** (built, plus the seeds). The ladder's first rung is trust, person by person.

**Chapter 2: The Lit Window.** Spirits appear at night. The first people ask to stay or help, and the notice board
opens. Margaret shows you the deposits, and Reece's file box holds the first letter. The planning board opens with
Tier 1. Ostrow offers to "sort the oil bill with a friend." Your first invited-guest scene is the Maple Lane fence
dispute.

**Chapter 3: Too Fast.** The Fellowship House and dining hall can go up, and live-ins arrive. The creek floods, and
residents ask you to speak at the town hall. You become an active voice at Tuesday meetings. Harold questions the
money publicly, and Pearl's column starts asking about it too. Frank's wife becomes his story: do you help him grieve,
or keep him close by needing him?

**Chapter 4: The Crossroads.** Dunmore offers the land behind the church and enough to fund all of Tier 3, if the church
backs her development. A council seat opens. Sarah decides whether June attends the new daycare. Every named
character takes a stand.

**Chapter 5: What We Built.** The Harvest Supper is held in whatever you built, and the deciding council vote lands
the same week. It shows what Oakridge has become and who it belongs to.

### Endings: TBD

Possible directions to choose from later:
- **TBD:** A small, honest church woven into the town, with a modest campus paid for cleanly.
- **TBD:** You refused the strings, the church merges or closes, and the town is better for it.
- **TBD:** The church effectively runs Oakridge, from a grand campus to a friendly council.
- **TBD:** A public reckoning, when Pearl, Harold or the ledger brings it all out.

---

## 8. How existing characters fit

- **Margaret** kept writing the deposits down. She's your ally if you come clean. If you don't, she starts bringing
  in uninvited people, because the full Fellowship House feels like the church she remembers.
- **Harold** is the institutional brake. He reads the planning board, asks who paid, and never sees spirits. On the
  high-Pull path, he's voted off the deacon board.
- **Thomas** is the town's thermometer. He's a member, so he never voices suspicion. He just cheerfully mentions how
  much lumber the church is buying, and whether your workshop is cutting into his business.
- **Frank** carries "listening versus pitching" and his wife's ghost. His bay hosts the car wash fundraiser. On the
  high-Pull path he leaves and becomes the sharpest outsider voice.
- **Sarah** asks, through June and the daycare, whether the church is safe for her daughter.
- **Neighbors.** Ada, Ben and Cleo carry outsider gossip. Dale and Ruth are the first town Gathered, and the fence
  dispute is theirs.
- **New (kept small):** June, Ostrow, Dunmore, Pearl, Cal, and Reece (in letters, and possibly as a Lingerer).

---

## 9. New systems and their impact (high level)

| System | Impact on existing code and data |
|---|---|
| **Influence** | New `InfluenceState` autoload: Pull with seats, storefronts and dependents, plus the ladder stage. Dialogue actions (`add_pull`) and conditions (`pull_at_least`, `influence_stage_at_least`) in `dialogue_runner.gd`. |
| **Funds and building** | New `ChurchFunds` autoload: balance, a clean/strings tag per gift, debts, income floor, and build queue. `data/buildings.json` and `data/funds.json` hold tunable costs and income. The planning board UI sits next to the journal's church page. Sites are flag-gated nodes in `church_exterior.gd`, and the lot grows. |
| **Chapter state** | Chapter-aware week. Touches `reconcile_calendar`, `day_suggestions`, `day_card.gd` and `chapter_end.gd`. This is the biggest code risk. |
| **Inner voice** | Optional `thought` lines in the dialogue JSON, gated by Pull, plus a settings toggle. |
| **Night layer** | New `spirit.gd` and `data/spirits/*.json`, using the existing `TimeOfDay` / `HappeningSchedule` patterns. |
| **Gathered** | New `FollowerState` and `data/followers.json`. Live-in capacity comes from buildings. Roles feed `npc_schedule` / `schedule_agent`. |
| **Places and voices** | Town hall and diner interiors. Bark filters by Pull with an `outsider` tag, and a weekly column. A test checks that no member dialogue contains "cult". |
| **Save data** | **Version 4** adds influence, funds, buildings, chapter, followers and spirits. v3 files migrate with empty values (the D33 pattern). |

---

## 10. Proposed milestones (each sized for one agent run)

- **M7: Seeds and influence.** `InfluenceState`, save v4, Chapter 1 seeds, and the "no cult" test.
- **M8: Chapter state.** Chapter-aware calendar and a Chapter 2 scaffold. Chapter 1 must play identically.
- **M9: Funds and ledger.** `ChurchFunds`, offerings and donations, debts, the income floor, tuning data, and the ledger page. No buildings yet.
- **M10: Planning board and Tier 1.** Build sites, scaffolding, and the workshop and greenhouse on the expanded lot.
- **M11: Night layer.** Spirit framework, two Lingerers, prayer-lights, and the steeple light.
- **M12: Chapter 2, part A.** June, the deposits, Reece's file box, Ostrow's favor (the first strings money), and the
  inner voice.
- **M13: Gathered v1.** Town helpers, the notice board, and the Garden and Upkeep roles.
- **M14: Invited guest.** The fence dispute scene and the town hall interior (one agenda item, no full council yet).
- **M15: Chapter 2, part B.** The first fundraiser, the Sunday, Frank's wife, and the chapter close.
- **M16: Tier 2 and live-ins.** The Fellowship House and dining hall, live-in Gathered, and the Errands, Kitchen,
  Outreach and Night Watch roles.
- **M17: Council meetings.** Tuesday scenes, the five members' wants, Cal's diner, and Pearl's column.
- **M18 onward:** Chapters 3 to 5, Tier 3, the seat, and the tells pass. Endings wait for Nathan's decision. Art and
  audio passes slot in between.
