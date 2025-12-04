# Juice Oracle Dice Roller – Design Doc

## 1. Physical Table Card Reference

The Juice Oracle table card has the following layout:

### Front Page
- **Details**: Color (d10), Property (d10+d6), Detail (d10), History (d10)
- **Immersion**: Sensory, Emotional Atmosphere

### First Inside Page (while folded)
- **Fate Check**: Result, Likely, Unlikely, Next Scene
- **Expectation/Behavior/Intensity/Scale**: Result, Intensity, 2dF + 1d6, Scale
- **Interrupt / Plot Point**: Action, Tension, Mystery, Social, Personal

### Second Inside Page (while folded)
- **Meaning Tables / Name Generator**: Discover Meaning (2d20), *, Name Generator (3d20)
- **Random Tables**: Modifier (d10), Idea (d10), Event (d10), Person (d10), Object (d10)

### Back Page
- **Quest**: Objective, Description, Focus, Preposition, Location
- **Random Event / Challenge**: Random Event (d10), Physical Challenge (d10), Mental Challenge (d10), DC, %
- **Pay the Price**: Pay the Price (d10), Major Plot Twist (d10)

### First Inside Page (while unfolded)
- **Wilderness**: Type, Environment, Encounter, Weather, Monster
- **Wilderness Monster Encounter**: Tracks (1d6-1@), 1-4 Easy, 5-8 Medium, 9-0 Hard, Doubles Boss (1)

### Second Inside Page (while unfolded)
- **NPC / Action**: Personality, Need, Motive/Topic, Action, Combat
- **Dialog**: Direction × Tone matrix (2d10)
- **Settlement**: Settlement Name, Establishment, Artisan, News

### Third Inside Page (while unfolded)
- **Object / Treasure**: Trinket, Treasure, Document, Accessory, Weapon, Armor (each with Quality, Material/Container, Type columns)

### Fourth Inside Page (while unfolded)
- **Dungeon Generator**: Next Area, Passage, Condition
- **Dungeon Encounter**: Encounter, Monster, Trap, Feature
- **Location**: 1d100 grid (5×5)

---

## 2. Overview

### What is Juice Oracle?

Juice Oracle is a portable solo-GM in a pocketfold: a dense set of tables and procedures that replace a human GM, so you can run RPGs (or improv stories) by yourself or with a GM who wants extra inspiration.

**Core mechanics inherited from Mythic GME:**
- **Fate Questions** – Yes/no questions with nuanced answers (Yes/No + And/But, Random Event, Invalid Assumption)
- **Discover Meaning** – Roll word pairs from meaning tables for open questions
- **Random Events** – Triggered events that pull from your Threads, Characters, Events, and Locations lists
- **Scene Transitions** – Roll to see if your next scene expectation is altered or interrupted

**What Juice adds:**
- A streamlined **Fate Check** using 2dF + 1d6 for more granular answers with a "yes-but" skew
- **Invalid Assumption** mechanic alongside Random Events
- **Intensity die** (1d6) indicating how significant the outcome is
- No Chaos Factor—pacing handled via scene transitions and random events
- Compact Wilderness, Dungeon, Encounter, and Treasure generators

### App Goal

Build a small iPhone app that rolls dice **in the ways the Juice Oracle uses them**, with presets for common Juice rolls.

- **Target:** iOS 17+
- **Dev platforms:** Windows / Linux (macOS only needed for signing & App Store builds)

### Reference Tables

All original Juice Oracle tables are in [`/reference/juice-oracle-text-tables/`](../reference/juice-oracle-text-tables/):

| File | Contents |
|------|----------|
| `fate-check.md` | Core 2dF+1d6 resolution table |
| `expectation-behavior-intensity-scale.md` | Intensity and scale modifiers |
| `random-event-challenge.md` | Random Event types, Physical/Mental challenges |
| `random-tables.md` | Modifier + Idea tables (RE/Alter) |
| `meaning-name-generator.md` | Discover Meaning words, Name Generator |
| `quest.md` | Quest generator tables |
| `npc-action.md` | NPC behavior determination |
| `pay-the-price.md` | Consequence tables |
| `interrupt-plot-point.md` | Interrupt and plot twist tables |
| `wilderness-table.md` | Environment, Weather, Monster formulas |
| `wilderness-monster-encounter.md` | Monster encounter details |
| `dungeon-generator.md` | Dungeon area generation |
| `dungeon-encounter.md` | Dungeon encounter tables |
| `settlement.md` | Settlement generation |
| `location.md` | Location details |
| `object-treasure.md` | Object and treasure properties |
| `natural-hazard-feature-dungeon.md` | Hazards and features |
| `dialog.md` | NPC dialog generation |
| `extended-npc-conversation.md` | Extended NPC interaction |
| `details.md` | Miscellaneous detail tables |
| `immersion.md` | Immersion and atmosphere |

### Implementation Status

Based on the physical card orientation above, here is the current button/feature coverage:

| Card Section | Table/Column | Button? | Notes |
|-------------|-------------|---------|-------|
| **Front Page** | | | |
| Details | Color | ✅ | Details dialog |
| Details | Property | ✅ | Details dialog (with intensity) |
| Details | Detail | ✅ | Details dialog |
| Details | History | ✅ | Details dialog |
| Immersion | Sensory | ✅ | Immerse dialog |
| Immersion | Emotional | ✅ | Immerse dialog |
| **First Inside (folded)** | | | |
| Fate Check | Result | ✅ | Fate button |
| Fate Check | Likely | ✅ | Fate dialog option |
| Fate Check | Unlikely | ✅ | Fate dialog option |
| Fate Check | Next Scene | ✅ | Scene button |
| Expectation | Result | ✅ | Expect button |
| Expectation | Intensity | ✅ | Included in roll |
| Expectation | Scale | ✅ | Scale button |
| Interrupt/Plot Point | Action | ✅ | Interrupt button |
| Interrupt/Plot Point | Tension | ✅ | Included in Interrupt |
| Interrupt/Plot Point | Mystery | ✅ | Included in Interrupt |
| Interrupt/Plot Point | Social | ✅ | Included in Interrupt |
| Interrupt/Plot Point | Personal | ✅ | Included in Interrupt |
| **Second Inside (folded)** | | | |
| Meaning Tables | Discover Meaning | ✅ | Meaning button |
| Meaning Tables | * (asterisk col) | ❓ | What is this column? |
| Name Generator | Name Generator | ✅ | Name button |
| Random Tables | Modifier | ✅ | Part of Event roll |
| Random Tables | Idea | ✅ | Part of Event roll |
| Random Tables | Event | ✅ | Part of Event roll |
| Random Tables | Person | ✅ | Part of Event roll |
| Random Tables | Object | ✅ | Part of Event roll |
| **Back Page** | | | |
| Quest | Objective | ✅ | Quest button |
| Quest | Description | ✅ | Included in Quest |
| Quest | Focus | ✅ | Included in Quest |
| Quest | Preposition | ✅ | Included in Quest |
| Quest | Location | ✅ | Included in Quest |
| Random Event | Random Event | ✅ | Event button |
| Challenge | Physical Challenge | ✅ | Challenge dialog |
| Challenge | Mental Challenge | ✅ | Challenge dialog |
| Challenge | DC | ✅ | Challenge dialog (Quick DC) |
| Challenge | % | ✅ | Challenge dialog (% Chance) |
| Pay the Price | Pay the Price | ✅ | Price dialog |
| Pay the Price | Major Plot Twist | ✅ | Price dialog option |
| **First Inside (unfolded)** | | | |
| Wilderness | Type | ❌ | **MISSING** - Environment type modifier |
| Wilderness | Environment | ❌ | **MISSING** - Terrain type |
| Wilderness | Encounter | ⚠️ | Partial - Explore dialog has wilderness encounter but different structure |
| Wilderness | Weather | ✅ | Explore dialog |
| Wilderness | Monster | ❌ | **MISSING** - Monster formula (+X@Y) |
| Monster Encounter | Tracks (1d6-1@) | ❌ | **MISSING** - Track detection |
| Monster Encounter | Easy/Medium/Hard | ❌ | **MISSING** - Difficulty-based monster lookup |
| Monster Encounter | Doubles Boss | ❌ | **MISSING** - Boss encounter on doubles |
| **Second Inside (unfolded)** | | | |
| NPC/Action | Personality | ✅ | NPC dialog |
| NPC/Action | Need | ✅ | NPC dialog (part of profile) |
| NPC/Action | Motive/Topic | ✅ | NPC dialog |
| NPC/Action | Action | ✅ | NPC dialog |
| NPC/Action | Combat | ✅ | NPC dialog |
| Dialog | Direction × Tone | ✅ | Dialog button |
| Settlement | Settlement Name | ✅ | Settle dialog |
| Settlement | Establishment | ✅ | Settle dialog |
| Settlement | Artisan | ✅ | Settle dialog (sub-roll of Establishment) |
| Settlement | News | ✅ | Settle dialog |
| **Third Inside (unfolded)** | | | |
| Object/Treasure | Trinket | ✅ | Treasure dialog |
| Object/Treasure | Treasure | ✅ | Treasure dialog |
| Object/Treasure | Document | ✅ | Treasure dialog |
| Object/Treasure | Accessory | ✅ | Treasure dialog |
| Object/Treasure | Weapon | ✅ | Treasure dialog |
| Object/Treasure | Armor | ✅ | Treasure dialog |
| **Fourth Inside (unfolded)** | | | |
| Dungeon Generator | Next Area | ✅ | Dungeon dialog |
| Dungeon Generator | Passage | ✅ | Dungeon dialog |
| Dungeon Generator | Condition | ✅ | Dungeon dialog |
| Dungeon Encounter | Encounter | ⚠️ | Partial - Explore dialog has dungeon encounter but different structure |
| Dungeon Encounter | Monster | ❌ | **MISSING** - Monster descriptor columns |
| Dungeon Encounter | Trap | ❌ | **MISSING** - Trap type columns |
| Dungeon Encounter | Feature | ❌ | **MISSING** - Feature column |
| Location | 1d100 grid | ❌ | **MISSING** - Grid location lookup |

### Missing Features Summary

**Wilderness Tables:**
1. **Wilderness Type/Environment** - The complex wilderness generation formula (2dF Env → 1dF Type)
2. **Monster Formula** - The +X@Y monster level calculation
3. **Monster Encounter Table** - Tracks, difficulty-based monsters, boss on doubles

**Dungeon Encounter:**
4. **Monster Descriptors** - Agile, Beast, Clothed, etc. columns
5. **Trap Table** - Trap type and trap trigger columns  
6. **Feature Table** - Library, Mural, Shrine, etc.

**Other:**
7. **Location Grid** - 1d100 → 5×5 grid position lookup

---

## 2.5 Wilderness Implementation Analysis

The current `wilderness.dart` implementation has significant gaps compared to the Juice Oracle instructions. This section documents the correct mechanics and implementation approach.

### Current vs Required Implementation

| Feature | Current Implementation | Required per Instructions |
|---------|----------------------|--------------------------|
| **Environment Selection** | Random d10 | 2dF offset from CURRENT environment (stateful) |
| **Type Selection** | Random d10 | 1dF offset from environment row (clamped at edges) |
| **Environment State** | None | Must track current environment row (1-10) |
| **Lost/Found State** | None | d10 normally, d6 when lost; roll 6 = found again |
| **Encounter Skew** | None | Disadvantage for dangerous terrain; Advantage with map/guide |
| **Weather Calculation** | Random d10 | 1d6 @ environment_skew + type_modifier |

### Correct Mechanics

#### Environment Transitions (2dF Offset)

When moving to a new hex, roll 2dF and sum them:
- Sum ranges from -2 to +2
- Apply as offset to current environment row
- Clamp result to 1-10 (table wraps naturally for most transitions)

**Example:** Currently in Forest (row 6). Roll 2dF → (0, +) → +1. New environment = row 7 = Swamp.

The 2dF creates a bell curve centered at 0:
- Most common: Same environment (0) or adjacent (±1)
- Less common: Two steps away (±2)

The table order creates natural biome transitions:
```
Arctic → Mountains → Cavern → Hills → Grassland → Forest → Swamp → Water → Coast → Desert
```

#### Type Selection (1dF Offset)

After determining the environment, roll 1dF for type:
- Type row = environment row + 1dF result
- **Important:** Does NOT wrap at edges
  - Arctic (row 1) + (-1) = Snowy (row 1), not Arid
  - Desert (row 10) + (+1) = Arid (row 10), not Snowy

Each environment naturally pairs with 3 types:
- Forest (6): Scrub (5), Tropical (6), Dark (7)
- Arctic (1): Snowy (1), Snowy (1), Rocky (2)

#### Lost/Found Cycle

The encounter table die changes based on orientation state:

| State | Encounter Die | Notes |
|-------|---------------|-------|
| **Oriented (normal)** | d10 | Full range of encounters |
| **Lost** | d6 | Restricted to rows 1-6 (more dangerous) |

**Transitions:**
- **Become Lost:** Roll 10 (Destination/Lost) when you have no destination → switch to d6
- **Become Found:** Roll 6 (Road/River) while lost → switch back to d10

This creates natural exploration pacing without a "death spiral."

#### Encounter Skew

| Condition | Skew |
|-----------|------|
| Dangerous territory / difficult terrain | Disadvantage |
| Have detailed map or guide | Advantage |
| Both (guide in dangerous area) | Straight (cancel out) |

**Effect of Advantage with map/guide:**
- More likely to find Road/River (row 6) → reorient faster if lost
- More likely to reach Destination (row 10) → shorter journeys
- Less likely to hit Natural Hazard/Monster (rows 1-2)

#### Weather Calculation

Weather is NOT a random d10. It's composed from environment and type:

```
Weather = 1d6 @ environment_skew + type_modifier
```

1. Look up environment row → get skew symbol (-, 0, +)
   - `-` = Disadvantage (colder results)
   - `0` = Straight roll
   - `+` = Advantage (warmer results)

2. Look up type row → get modifier (+0 to +4)

3. Roll 1d6 with the skew, add modifier

4. Result (clamped 1-10) gives weather:
   - 1 = Blizzard, 2 = Snow Flurries, 3 = Freezing Cold
   - 4 = Thunder Storm, 5 = Heavy Rain, 6 = Light Rain
   - 7 = Heavy Clouds, 8 = High Winds, 9 = Clear Skies, 10 = Scorching Heat

**Example:** Rocky Arctic (Type row 2, Env row 1)
- Environment row 1 has skew `-` (Disadvantage)
- Type row 2 has modifier +2
- Roll 1d6@Disadvantage → result 2 → +2 = 4 (Thunder Storm)
- But skewed toward cold, so more likely 3 (Freezing Cold) or less

**Example:** Sandy Coast (Type row 9, Env row 9)
- Environment row 9 has skew `0` (Straight)
- Type row 9 has modifier +4
- Roll 1d6 → result 3 → +4 = 7 (Heavy Clouds)
- Range: 5-10 (Heavy Rain to Scorching Heat), never snows on Sandy Coast

### State Model

The Wilderness system requires persistent state:

```dart
class WildernessState {
  int environmentRow;     // 1-10, current environment
  int typeRow;            // 1-10, current type
  bool isLost;            // d6 vs d10 for encounters
  
  // Derived
  String get environment => environments[environmentRow - 1];
  String get typeName => types[typeRow - 1]['name'];
  int get typeModifier => types[typeRow - 1]['modifier'];
  String get environmentSkew => types[environmentRow - 1]['fateMod'];
}
```

### Implementation Approach

1. **Add state tracking** to `Wilderness` class
2. **New method:** `transition()` - Uses 2dF + 1dF for environment/type change
3. **Update** `rollEncounter()` - Use d10/d6 based on `isLost`, check for Lost/Found transitions
4. **Update** `rollWeather()` - Use proper formula: 1d6@skew + modifier
5. **Add skew parameter** to encounter methods for terrain/guide modifiers

### Implemented: Position Management for Hex Generation

#### Problem Statement

Users need to generate adjacent hexes from previous positions, not just the current one. Use cases:
1. Generate a starting hex, then generate the 6 adjacent hexes around it
2. Generate one hex, do other activities, then return to generate more adjacent hexes
3. Start from a known location in an existing world (no roll history)

#### Chosen Solution

A hybrid approach combining **roll history integration** with **manual position setting**:

##### 1. Set Position from Roll History (Primary Method)

When viewing a `WildernessAreaResult` in the roll history detail sheet, users can tap **"Set as Current Position"** to make that hex the active position for future transitions.

**Flow:**
1. User taps a wilderness result in history
2. Detail sheet opens with a "Set as Current Position" button
3. Tapping the button sets that hex as the current wilderness state
4. User opens Wilderness dialog → shows the selected position
5. "Transition to Next Hex" generates from that position

**Implementation:**
```dart
// In RollHistory widget
onSetWildernessPosition: (envRow, typeRow) {
  wilderness.initializeAt(envRow, typeRow: typeRow);
}
```

##### 2. Manual Environment Picker (Secondary Method)

For users without roll history (new session, existing world, migrating from paper):

**In the Wilderness dialog:**
- "Set Known Position..." option expands to show an environment dropdown
- Dropdown lists all 10 Type+Environment combinations
- "Set Position" button activates the selected environment

**UI:**
```
┌─────────────────────────────────────┐
│ Environment: [▼ Tropical Forest ]   │
│                                     │
│ [📍 Set Position]                   │
└─────────────────────────────────────┘
```

**Implementation:**
```dart
// Dropdown with 10 options
List.generate(10, (i) {
  final env = Wilderness.environments[i];
  final type = Wilderness.types[i]['name'];
  return DropdownMenuItem(value: i + 1, child: Text('$type $env'));
})

// Set position
wilderness.initializeAt(selectedEnvironment, typeRow: selectedEnvironment);
```

#### Why This Approach?

| Alternative Considered | Why Not Chosen |
|----------------------|----------------|
| Named position stack | Added complexity; roll history already tracks positions |
| Clipboard/paste model | Poor mobile UX; volatile |
| Single bookmark slot | Too limiting for multiple branch points |
| Undo/redo stack | Confusing for branching; not intuitive |

**Benefits of chosen approach:**
- Zero new data structures (uses existing roll history)
- Discoverable UX (natural "tap to see details" → "set position")
- Covers both use cases (history users + fresh start users)
- Minimal code changes

#### Future Enhancements (Not Implemented)

If more sophisticated hex mapping is needed later:

1. **Starred positions** - Mark important hexes for quick access
2. **Direction tracking** - Record which direction each transition went
3. **Visual hex map** - Render explored hexes spatially
4. **Persistence** - Save wilderness state across sessions

---

## 2. Scenarios & Use Cases

Based on all the Juice Oracle tables, the following scenarios represent the complete set of rolling use cases the app should support:

### 2.1 Core Oracle Mechanics

| Scenario | Tables Used | Dice | Description |
|----------|-------------|------|-------------|
| **Fate Check** | `fate-check.md` | 2dF + 1d6 | Yes/No questions with likelihood modifier (Unlikely/Even/Likely). Produces answers from "Yes And" to "No And" with Random Event or Invalid Assumption triggers on double blanks. |
| **Next Scene** | `fate-check.md` (Next Scene column) | 2dF | Determines if next scene proceeds normally, is altered (add/remove element), or is interrupted (favorable/unfavorable). |
| **Random Event** | `random-event-challenge.md`, `random-tables.md` | 3d10 | Generates story prompts: Event Type (Advance Time, Close Thread, NPC Action, etc.) + Modifier + Idea word pair. |
| **Discover Meaning** | `meaning-name-generator.md` | 2d20 | Two-word prompts for open interpretation (e.g., "Dangerous Trust", "Reveal Shadow"). |
| **Expectation Check** | `expectation-behavior-intensity-scale.md` | 2dF + 1d6 | General behavior/outcome determination: Expected, Favorable, Unfavorable, Opposite, etc. with intensity. |

#### Fate Check Usage

The Fate Check is the core mechanic. Roll 2dF + 1d6 where one Fate die is designated "primary" (tracked by position/color).

**Interpretation:**
- `+` on primary = Yes-like result; `-` on primary = No-like result
- Secondary die modifies: `++` = Yes And, `+-` = Yes But, `-+` = No But, `--` = No And
- Blank primary looks to secondary: `0+` = Favorable to PC, `0-` = Unfavorable to PC
- Double blanks (`00`): Primary on LEFT = Random Event (answer is "Yes But"); Primary on RIGHT = Invalid Assumption

**Likeliness modifiers:**
- **Likely:** If either die is `+`, result is Yes-like
- **Unlikely:** If either die is `-`, result is No-like

**Intensity (1d6):** Scales the magnitude of the answer:
1. Minimal, 2. Mundane, 3. Minor, 4. Moderate, 5. Major, 6. Massive

**Example:** "Is the tavern busy?" with `+03` = Yes (minor intensity). "Yes But" with intensity 6 = packed tight due to a major event.

#### Next Scene Usage

At scene end, roll 2dF to challenge your expectation of what comes next:

- **Any blanks** = Normal scene proceeds as expected
- **Primary `+`** = Alter scene (Add or Remove a Focus from the Focus table)
- **Primary `-`** = Interrupt scene (Favorable or Unfavorable based on secondary die)

For interrupts, roll on the Plot Point table to determine the nature of the interruption.

#### Random Event Types

Each event type prompts specific actions:
- **Advance Time:** Time passes in-game; update weather, check resources, handle environmental changes
- **Close Thread:** Roll on Thread list; that storyline ends
- **Converge Thread:** Roll on Thread list; something moves you closer to that thread
- **Diverge Thread:** Roll on Thread list; something pushes you away from that thread
- **Immersion:** Roll on Immersion table; incorporate sensory/emotional detail
- **Keyed Event:** Trigger a pre-planned event from your Event list (or roll Plot Point if none)
- **New Character:** A new NPC enters the scene; generate via NPC + Name tables
- **NPC Action:** Roll on Character list; that NPC takes action (use NPC Action table)
- **Plot Armor:** Whatever problem you face is solved; a narrative lifeline
- **Remote Event:** Something happens elsewhere; roll on Locations list for where

#### Expectation Check Usage

An alternative to Fate Check for players who already have an expectation of what should happen. Instead of asking "Is X true?", you assume X is true and test whether your expectation holds:

- **Expected:** Your expectation is correct
- **Favorable/Unfavorable:** Expectation modified in PC's favor/disfavor  
- **Opposite:** The opposite of your expectation occurs

Also functions as NPC Behavior generation: assume what an NPC will likely do, then test it.

#### Discover Meaning Usage

For open-ended questions where Yes/No isn't enough. Roll 2d20 to get a word pairing:
- First word: Adjective or Verb
- Second word: Noun or Noun-Verb

**Word selection:** Tables are sorted with "best 10" at top, so d10 works if no d20 available.

**Examples:**
- 10,16: "Unexpected Failure"
- 14,19: "Deceive Sacrifice"
- 4,18: "Dangerous Leave"

**In Simple Mode:** Use "Modifier + Idea" tables (d10 + d10) as a quick alternative when rolling Random Events.

**Abstract Icons Alternative:** Flip up the right flap to use pictographic icons instead of words for those who prefer visual inspiration.

### 2.2 Character & NPC Interactions

| Scenario | Tables Used | Dice | Description |
|----------|-------------|------|-------------|
| **NPC Action** | `npc-action.md` | d10 | Determines what an NPC does: Talks, Continues, Act (PC Interest), Act (Self Interest), Enter Combat, etc. |
| **NPC Personality** | `npc-action.md` | d10 | Generates NPC traits: Cautious, Curious, Organized, Compassionate, etc. |
| **NPC Need** | `npc-action.md` | d10 | What the NPC wants: Sustenance, Shelter, Security, Recognition, Fulfillment, etc. |
| **NPC Motive/Topic** | `npc-action.md` | d10 | What drives conversation: History, Family, Reputation, Wealth, Treasure, etc. |
| **NPC Combat Action** | `npc-action.md` | d10 | Combat behavior: Defend, Shift Focus, Seize, Intimidate, Coordinate, etc. |
| **Dialog Generation** | `dialog.md` | 2d10 | Direction (Neutral/Defensive/Aggressive/Helpful) + Tone (Them/Me/You/Us) → Subject matrix. Doubles end conversation. |
| **Extended NPC Info Type** | `extended-npc-conversation.md` | d100 | Type of plot knowledge an NPC can share (connections, boons, losses, insights, etc.). |
| **Extended NPC Info Topic** | `extended-npc-conversation.md` | d100 | Topic of information (antagonists, locations, artifacts, allies, enemies, etc.). |
| **Companion Response** | `extended-npc-conversation.md` | d100 | How a companion reacts to a proposal (from refusal to enthusiastic agreement). |
| **Extended Dialog Topic** | `extended-npc-conversation.md` | d100 | Deep conversation subjects for extended NPC interactions. |

#### NPC Action Usage

NPCs make the world feel alive. When an NPC needs to act (via Random Event trigger or narrative need):

1. Roll d10 on NPC Action table to determine behavior type
2. If "Talks" - roll on Topic table to determine conversation subject
3. If action involves their interests - consider their Personality and Need
4. If entering combat - use NPC Combat Action for tactical behavior

**Context matters:** An absent NPC action can be a flashback, something that directly affects/was affected by them, or defaults to your companion.

#### Dialog Generation Usage

The Dialog table uses a 2d10 matrix system:
- First d10 determines **Direction** (Neutral/Defensive/Aggressive/Helpful)
- Second d10 determines **Tone** (Them/Me/You/Us)
- Cross-reference for Subject of conversation
- **Doubles end the conversation** - the NPC has said what they wanted to say

### 2.3 Plot & Story Development

| Scenario | Tables Used | Dice | Description |
|----------|-------------|------|-------------|
| **Pay the Price** | `pay-the-price.md` | d10 | Consequences on failure: Unintended Effect, Situation Worsens, Delayed, New Danger, etc. |
| **Major Plot Twist** | `pay-the-price.md` | d10 | Major twists on critical fail: Actions Benefit Enemy, Assumption False, Dark Secret Revealed, etc. |
| **Interrupt/Plot Point** | `interrupt-plot-point.md` | 2d10 | Category (Action/Tension/Mystery/Social/Personal) + Specific event (Abduction, Chase, Revelation, etc.). |
| **Quest Generator** | `quest.md` | 5d10 | Full quest: Objective (Attain/Destroy/Protect) + Description + Focus + Preposition + Location. |

#### Pay the Price Usage

Roll when failing a challenge. The table comes from Ironsworn and determines failure consequences:
- **Standard Failure:** Roll d10 on Pay the Price table
- **Miss with Match / Critical Fail:** Use Major Plot Twist table instead for more severe consequences

#### Interrupt/Plot Point Usage

Roll 2d10 to generate scene interruptions or keyed events:
- First d10 selects **Category** (Action, Tension, Mystery, Social, Personal)
- Second d10 selects **Specific Element** within that category

Use for: Scene interrupts, Keyed Event triggers, adding plot complexity.

#### Quest Generator Usage

Generates quests via 5d10 that read almost like an English sentence:
1. **Objective:** What to do (Attain, Destroy, Escort, Protect, etc.)
2. **Description:** Modifier (Abandoned, Hidden, Connected, etc.)
3. **Focus:** Target type (Community, Event, Environment, etc.) - may reference another table
4. **Preposition:** Relationship (Around, Inside Of, Under, etc.)
5. **Location:** Where (Settlement, Environment type, etc.) - may reference another table

**Example:** "Attain the hidden community under the community" = gain trust with a secret underground society.

**As Rumor Generator:** Make past tense and prepend "I heard..." to generate world news/rumors.

### 2.4 Exploration & Wilderness

| Scenario | Tables Used | Dice | Description |
|----------|-------------|------|-------------|
| **Environment Type** | `wilderness-table.md` | 2dF | Determine biome: Arctic, Mountains, Grassland, Forest, Swamp, Desert, etc. |
| **Weather** | `wilderness-table.md` | 1d6@skew | Environment-modified weather: Blizzard to Scorching Heat based on terrain. |
| **Wilderness Encounter** | `wilderness-table.md` | d10 | What happens: Natural Hazard, Monster, Weather, Challenge, Dungeon, River/Road, Feature, Settlement, Plot Advance. |
| **Monster Encounter** | `wilderness-monster-encounter.md` | formula-based | Environment-specific formula (e.g., +3@-) to determine creature type and difficulty. |
| **Tracks** | `wilderness-monster-encounter.md` | 1d6-1@ | What creature tracks are found. |
| **Natural Hazard** | `natural-hazard-feature-dungeon.md` | d10 | Hazards: Creature Tracks, Dust Storm, Flood, Fog, Rockslide, Crevice, River Crossing, etc. |
| **Wilderness Feature** | `natural-hazard-feature-dungeon.md` | d10 | Landmarks: Bones, Cairn, Chasm, Circle, Spring, Grave, Monument, Tower, Tree, Well. |

#### Wilderness Exploration Mode

Open the pocketfold to "Wilderness Exploration" mode (open book, fold backwards, open left page) for access to:
- Environment and weather tables
- Encounter tables
- NPC tables (with extended tables under the flap)

#### Weather Usage

Weather is environment-modified:
- Roll 1d6 with skew based on current environment
- Cold environments skew toward lower results (cold weather)
- Hot environments skew toward higher results (hot weather)
- Result indicates weather condition appropriate to the biome

#### Wilderness Encounter Flow

1. Roll d10 for encounter type
2. If **Monster** - use environment-specific formula for creature type
3. If **Natural Hazard** - roll on Natural Hazard table
4. If **Feature** - roll on Wilderness Feature table
5. If **Challenge** - use Challenge procedure to generate skill checks

### 2.5 Dungeon Exploration

| Scenario | Tables Used | Dice | Description |
|----------|-------------|------|-------------|
| **Dungeon Name** | `natural-hazard-feature-dungeon.md` | 3d10 | Format: "[Dungeon] of the [Description] [Subject]". E.g., "Ruins of the Shattered Lies". |
| **Dungeon Next Area** | `dungeon-generator.md` | 1d10@- / 1d10@+ | Stateful: Roll @- until doubles, then @+. Results: Passage, Chamber, Lock, Exit, etc. |
| **Passage Type** | `dungeon-generator.md` | d10 | Passage details: Dead End, Narrow Crawlspace, Bridge, Intersection, etc. |
| **Room Condition** | `dungeon-generator.md` | d10 | State of area: Collapsed, Flooded, Burned, Pristine, Converted, etc. |
| **Dungeon Encounter** | `dungeon-encounter.md` | d10 | What's in the room: Monster, Natural Hazard, Challenge, Immersion, Safety, Trap, Feature, Key, Treasure. |
| **Monster Traits** | `dungeon-encounter.md` | 2d10 | Appearance (Agile, Beast, Elemental, etc.) + Ability (Climb, Drain, Magic, etc.). |
| **Trap Type** | `dungeon-encounter.md` | 2d10 | Purpose (Ambush, Collapse, Lure, etc.) + Mechanism (Alarm, Decay, Fire, Poison, etc.). |
| **Dungeon Feature** | `dungeon-encounter.md` | d10 | Room features: Library, Mural, Mushrooms, Prison, Runes, Shrine, Vault, Well, Workshop. |

#### Dungeon Exploration Mode

Open the pocketfold to "Dungeon Exploration" mode (open book, fold backwards, open right page) for access to:
- Dungeon generation tables
- Dungeon encounter tables
- Close right flap for Discover Meaning access, or flip flap up for Abstract Icons

#### Dungeon Next Area - Stateful Generation

The dungeon generator uses a **two-phase stateful system**:

**Phase 1 (Entering):** Roll 1d10 with disadvantage (`@-`)
- Continue rolling until you get doubles
- Doubles indicate you've found something significant (transition to Phase 2)

**Phase 2 (Exploring):** Roll 1d10 with advantage (`@+`)
- Continue until conditions change
- Results: Passage, Chamber, Lock, Exit, Vertical Shift, etc.

This creates natural dungeon pacing with exploration followed by discovery.

#### Dungeon Encounter Flow

1. Roll d10 for encounter type in current area
2. If **Monster** - roll 2d10 for Appearance + Ability traits
3. If **Trap** - roll 2d10 for Purpose + Mechanism
4. If **Feature** - roll on Dungeon Feature table
5. If **Challenge** - use Challenge procedure
6. If **Immersion** - roll on Immersion table for atmospheric detail

### 2.6 Settlements & Locations

| Scenario | Tables Used | Dice | Description |
|----------|-------------|------|-------------|
| **Settlement Name** | `settlement.md` | 2d10 | Prefix (Frost, High, Raven, Storm, etc.) + Suffix (Barrow, Brook, Haven, River, etc.). |
| **Establishment** | `settlement.md` | d10 | What's available: Stable, Tavern, Inn, Temple, Guild Hall, Magic Shop, etc. |
| **Artisan** | `settlement.md` | d10 | Craftspeople: Artist, Baker, Tailor, Blacksmith, Carpenter, Apothecary, Jeweler, etc. |
| **Settlement News** | `settlement.md` | d10 | Current events: War, Sickness, Natural Disaster, Crime, Celebration, etc. |
| **Location (Grid)** | `location.md` | d100 | 5×5 grid position for directional placement (North/South/East/West/Center). |

#### Settlement Generation Usage

When entering or generating a settlement:
1. Roll 2d10 for **Settlement Name** (Prefix + Suffix)
2. Roll for **Establishments** to determine what services are available
3. Roll for **Artisans** to find specific craftspeople
4. Roll on **Settlement News** to learn what's currently happening

**News Feed:** When a Random Event triggers "Advance Time", roll on Settlement News to see what has changed. Also incorporate results from "Remote Event" triggers.

#### Location Grid Usage

The Location Grid provides a 5×5 spatial reference:
- Roll d100 to get coordinates
- Maps to directional placement (North/South/East/West/Center)
- Use for: placing locations relative to each other, determining where Remote Events occur, spatial puzzles |

### 2.7 Objects & Treasure

| Scenario | Tables Used | Dice | Description |
|----------|-------------|------|-------------|
| **Treasure Type** | `object-treasure.md` | d6 | Category: Trinket, Treasure, Document, Accessory, Weapon, Armor. |
| **Trinket** | `object-treasure.md` | 3d6 | Quality + Material (Wood/Bone/Leather/Silver/Gold/Gem) + Type (Toy/Bottle/Charm/Key). |
| **Treasure Container** | `object-treasure.md` | 3d6 | Quality + Container (None/Pouch/Box/Chest) + Contents (Food/Art/Coins/Gems). |
| **Document** | `object-treasure.md` | 3d6 | Type (Song/Letter/Scroll/Book) + Content (Lewd/Map/Arcane/Forbidden) + Subject. |
| **Accessory** | `object-treasure.md` | 3d6 | Quality + Material + Type (Headpiece/Emblem/Earring/Bracelet/Ring). |
| **Weapon** | `object-treasure.md` | 3d6 | Quality + Material (Steel/Silver/Mithral/Adamantine) + Type. |
| **Armor** | `object-treasure.md` | 3d6 | Quality + Material + Type (Headpiece/Gloves/Boots/Shield). |

#### Object/Treasure Generation Flow

1. Roll d6 to determine **Treasure Type** category
2. Roll 3d6 for the specific item within that category
3. Each d6 determines a different property (Quality/Material/Type or similar)

**Enhancing objects:** Use the Property table (d10 + d6) to add additional characteristics to any item. |

### 2.8 Challenges & Skills

| Scenario | Tables Used | Dice | Description |
|----------|-------------|------|-------------|
| **Quick DC** | `random-event-challenge.md` | 2d6+6 | Quick difficulty class generation (8-17). |
| **Physical Challenge** | `random-event-challenge.md` | d10 | Skill type: Medicine, Survival, Animal Handling, Perception, Stealth, Athletics, etc. |
| **Mental Challenge** | `random-event-challenge.md` | d10 | Skill type: Tool, Nature, Investigate, Persuasion, Deception, Arcana, History, etc. |

#### Challenge Procedure Usage

The Challenge procedure replaces a DM generating DCs and calling for checks:

1. Roll a **Physical Challenge** (d10) and a **Mental Challenge** (d10)
2. Invent a situation where both challenges make sense
3. Assign each a DC (use Quick DC if needed)
4. PC must pass **only one** of them
5. On failure, **Pay the Price**

**Philosophy:** Work backwards - roll the challenges first, then create a scenario that incorporates them. This creates interesting situations and prevents lock-out on single skill failures.

**Example:** Roll 8,2 = Stealth or Nature. Situation: "Find a way to capture the elusive magical creature." Player can either sneak up on it (Stealth) or use knowledge of its habits (Nature).

#### DC Generation Methods

1. **Completely Random:** 1d10 = DC (swingy)
2. **Balanced Challenge:** 1d100 on bell curve table (weights toward middle)
3. **Easy Challenge:** 1d10 with Advantage (skews lower)
4. **Hard Challenge:** 1d10 with Disadvantage (skews higher)
5. **Quick Challenge:** 2d6+6 (range 8-17)

### 2.9 Names & Details

| Scenario | Tables Used | Dice | Description |
|----------|-------------|------|-------------|
| **Name Generator** | `meaning-name-generator.md` | 3d20 | Fantasy name from syllable tables (M@-/F@+). |
| **Color** | `details.md` | d10 | Object color: Black, Brown, Yellow, Green, Blue, Red, Violet, Silver, Gold, White. |
| **Property** | `details.md` | d10 + d6 | Object property: Age, Durability, Power, Quality, Rarity, Size, Style, Value, Weight. |
| **Detail** | `details.md` | d10 | Emotional/contextual detail: Negative Emotion, Favors/Disfavors PC/NPC/Thread, etc. |
| **History** | `details.md` | d10 | Temporal context: Backstory, Past/Previous/Current Thread, Scene, or Action. |

#### Property Table Usage

**The most versatile table in Juice.** Roll 1d10 for property type, then 1d6 for intensity. Do this twice for rich descriptions.

**Use it for:**
- Generate/enhance items
- Describe NPCs
- Describe settlements
- Add flavor to anything

**Example:** "You see a town..." → Roll (2,3) = Mundane Durability + (6,5) = Major Rarity. Interpretation: Pretty average construction, but surprising to find a settlement this far out.

**Intensity scale:** 1=Minimal, 2=Mundane, 3=Minor, 4=Moderate, 5=Major, 6=Massive

#### Detail Table Usage

Use when random tables throw a curveball and you need to ground the meaning:

- **Positive/Negative Emotion:** The thing evokes an emotion (reference Immersion table's "and it causes" for emotion list)
- **Favors/Disfavors PC:** The thing is good/bad for your character
- **Favors/Disfavors Thread:** Roll on Thread list; the thing relates to that storyline
- **Favors/Disfavors NPC:** Roll on Character list; the thing relates to that NPC

**Use instead of (or with) Discover Meaning** when you need more grounded context.

#### History Table Usage

Not everything is about the present. Use to tie elements to the past:

- **Backstory:** Character's personal history
- **Past Thread/Scene:** Something from earlier in the adventure
- **Previous Action:** The most recent thing that happened

**Use for:** Invalid Assumption context, NPC conversation topics, flashback prompts, explaining why something exists.

**Variants:** Roll with Advantage for more recent, Disadvantage for further in the past.

### 2.10 Immersion & Atmosphere

| Scenario | Tables Used | Dice | Description |
|----------|-------------|------|-------------|
| **Sensory Detail** | `immersion.md` | 2d10 | Sense (See/Hear/Smell/Feel) + Detail (Broken, Dripping, Decay, Cold, etc.). |
| **Emotional Atmosphere** | `immersion.md` | 2d10 | Where? (Above, Behind, Shadows, etc.) + Emotion pair (Despair↔Hope, Fear↔Courage, etc.) + Cause. |

#### Immersion Table Usage

**The perfect table to roll when "stuck"** - it provides environmental hints that can guide decisions.

**Structure:** Roll multiple d10s to build a sensory scene:
1. **Sense:** What you perceive (See, Hear, Smell, Feel)
2. **What:** The detail perceived (Broken, Dripping, Decay, etc.)
3. **Where:** Location relative to you (Above, Behind, In the Shadows, etc.)
4. **Emotion:** What feeling it evokes (paired positive/negative emotions)
5. **Cause:** Why it affects you

**Sensory Variants:**
- d6: Only distant senses
- Advantage: Closer to you
- Disadvantage: Further from you

**Emotion Variants:**
- Roll 1dF with emotion: `-` or blank = negative emotion, `+` = positive emotion
- Weighted toward darker results (more interesting situations to overcome)

**Example:** "You see something discarded behind you, and it causes joy because you were warned about it."

**Use for:** Dungeon exploration decisions, scene atmosphere, breaking decision paralysis.

### 2.11 Scale & Intensity

| Scenario | Tables Used | Dice | Description |
|----------|-------------|------|-------------|
| **Intensity** | `expectation-behavior-intensity-scale.md` | 1d6 | Magnitude: Minimal, Mundane, Minor, Moderate, Major, Massive. |
| **Scale** | `expectation-behavior-intensity-scale.md` | 2dF + 1d6 | Percentage modifier: -50% to +50% with bell curve toward middle. |

#### Scale Table Usage

Use Scale to modify values rather than asking yes/no questions:

- **Shop prices:** Imagine normal price, roll Scale for adjustment. Higher = more expensive (come up with in-game reason).
- **Monster stats:** Scale HP up or down. Higher than expected = stronger creature (why has it survived?). Lower = wounded (what happened?).
- **Quantities:** How much of something is present.

**Mechanics:** 2dF + 1d6 creates a bell curve toward middle values.
- `+` or `-` on Fate dice = +1 or -1 to the d6 result
- Total maps to percentage: -50%, -25%, -10%, 0%, +10%, +25%, +50%

**Directional scaling:** If specifically trying to scale larger, use absolute value (a roll of "1" = "-25%" becomes "+25%").

### 2.12 Summary: Preset Priority

Based on table complexity and usage frequency, recommended implementation order:

**Phase 1 - Core (Done)**
1. ✅ Fate Check (2dF + 1d6)
2. ✅ Next Scene (2dF)
3. ✅ Random Event (3d10)
4. ✅ Exploration (Weather/Encounter)

**Phase 2 - Essential**
5. Discover Meaning (2d20)
6. NPC Action (d10 multi-column)
7. Pay the Price (d10)
8. Quest Generator (5d10)

**Phase 3 - Extended**
9. Dungeon Next Area (stateful 1d10@±)
10. Dungeon Encounter (d10 + sub-tables)
11. Settlement Generator (2d10 + sub-tables)
12. Object/Treasure (d6 + 3d6)

**Phase 4 - Deep**
13. Dialog Generator (2d10 matrix)
14. Interrupt/Plot Point (2d10 matrix)
15. Monster Encounter (formula parsing)
16. Extended NPC Conversation (d100 tables)
17. Immersion/Senses (5d10)
18. Details (d10 + d6)
19. Name Generator (3d20 syllables)
20. Location Grid (d100 → 5×5)

---

## 3. Tech Stack

- **Framework:** Flutter (Dart)
  - Cross-platform development on Windows/Linux
  - iOS builds via CI (GitHub Actions with Mac runner)

- **Architecture:** Simple MVVM
  - **Core roll engine** as pure functions (no UI dependencies, fully testable)
  - Thin UI layer for buttons, presets, and history

- **State & Storage**
  - In-memory state for current roll & session
  - `shared_preferences` for persistence (presets, settings, history)

- **Random Number Generation**
  - Platform PRNG via `dart:math`
  - Seed override for reproducible testing/sessions

---

## 4. Core Functional Requirements

### 4.1 Dice Primitives

| Primitive | Description |
|-----------|-------------|
| **NdX standard dice** | d4, d6, d8, d10, d12, d20, d100 with optional modifier |
| **Fate dice (dF)** | Values in {-1, 0, +1}. Ordered results for Random Event vs Invalid Assumption |
| **Advantage/Disadvantage** | Roll twice, keep higher (adv) or lower (dis) |
| **Skewed d6** | `1d6@+` = advantage, `1d6@-` = disadvantage |

### 4.2 Fate Check

The core Juice mechanic. See [`fate-check.md`](../reference/juice-oracle-text-tables/fate-check.md) for full table.

**Implementation:** 2dF (Fate dice) + 1d6 (Intensity)

- **Fate Dice:** Each shows `−` (-1), `○` (0), or `+` (+1). Sum ranges -2 to +2.
- **Intensity:** 1d6 indicating magnitude (Minimal → Extreme)
- **Likelihood:** Unlikely / Even Odds / Likely shifts ambiguous results
- **Special Triggers:** Double blanks (`○○`) trigger Random Event or Invalid Assumption

### 4.3 Next Scene

Determines scene transitions. Uses the Next Scene column from the Fate Check table.

- **Normal** – Scene proceeds as expected
- **Alter (Add/Remove)** – Scene is modified
- **Interrupt (Favorable/Unfavorable)** – Scene is replaced

### 4.4 Random Event

See [`random-event-challenge.md`](../reference/juice-oracle-text-tables/random-event-challenge.md) and [`random-tables.md`](../reference/juice-oracle-text-tables/random-tables.md).

Generates story prompts via:
1. **Event Type** (d10): Advance Time, Close Thread, NPC Action, etc.
2. **Modifier + Idea** (d10 + d10): Word pair from tables

### 4.5 Discover Meaning

See [`meaning-name-generator.md`](../reference/juice-oracle-text-tables/meaning-name-generator.md).

Two-word prompts for open interpretation: Adjective + Noun (e.g., "Dangerous Trust").

### 4.6 Exploration

See [`wilderness-table.md`](../reference/juice-oracle-text-tables/wilderness-table.md) and [`dungeon-generator.md`](../reference/juice-oracle-text-tables/dungeon-generator.md).

- **Weather:** 1d6@Environment + Type offset
- **Encounters:** Environment-specific monster formulas (e.g., `+3@-`)
- **Dungeon Areas:** Phase-based generation

---

## 5. Preset Roll Types

| Preset | Dice | Reference |
|--------|------|-----------|
| **Fate Check** | 2dF + 1d6 | `fate-check.md` |
| **Random Event** | d10 + d10 + d10 | `random-event-challenge.md`, `random-tables.md` |
| **Discover Meaning** | d20 + d20 | `meaning-name-generator.md` |
| **Quest** | d10 × 5 columns | `quest.md` |
| **Weather** | 1d6@skew | `wilderness-table.md` |
| **Wilderness Encounter** | formula-based | `wilderness-monster-encounter.md` |
| **Dungeon Encounter** | d10 | `dungeon-encounter.md` |
| **NPC Action** | d10 | `npc-action.md` |
| **Pay the Price** | d10 | `pay-the-price.md` |
| **Generic Roll** | NdX ± mod | — |

---

## 6. UI Structure

### Home Screen
- Grid of preset buttons
- Quick access to most-used rolls

### Roll Result Panel
- Preset name
- Raw dice with Fate symbols (+/−/○)
- Interpretation text
- Sub-roll details (expandable)

### History Screen
- Scrollable log with timestamps
- Tap to expand details
- Copy/share functionality

### Custom Roll Builder
- Die count, type, modifier
- Advantage/disadvantage toggle
- Save as preset option

---

## 7. Non-Functional Requirements

| Requirement | Details |
|-------------|---------|
| **Offline-first** | All tables bundled locally. No network dependency. |
| **Performance** | Roll + UI update < 50ms. |
| **Testability** | Roll engine in separate module with unit tests. |
| **Extensibility** | Tables loaded from reference files. |

---

## 8. Implementation Status

### ✅ Completed
- [x] Project setup (Flutter)
- [x] Core roll engine (`RollEngine` class)
  - Standard dice, Fate dice, advantage/disadvantage, skewed d6
- [x] Table lookup system (`LookupTable<T>`)
- [x] Fate Check preset (2dF + Intensity)
  - Fate dice with symbols, intensity descriptions
  - Random Event / Invalid Assumption triggers
- [x] Next Scene preset
- [x] Random Event preset (Focus + Action/Subject)
- [x] Wilderness preset (Weather, encounters, monsters)
- [x] Result models with metadata
- [x] Unit tests

### 🔲 Remaining
- [ ] Discover Meaning preset
- [ ] Quest generator preset
- [ ] NPC Action preset
- [ ] Pay the Price preset
- [ ] Dungeon Next Area (stateful)
- [ ] Monster encounter with formula parsing
- [ ] History persistence
- [ ] UI polish (haptics, animations)
- [ ] CI pipeline (GitHub Actions)
- [ ] iOS build and signing

---

## 9. File Structure

```
lib/
├── main.dart
├── core/
│   ├── roll_engine.dart      # Dice primitives
│   └── table_lookup.dart     # Generic lookup table
├── models/
│   └── roll_result.dart      # Base result class
├── presets/
│   ├── fate_check.dart       # Fate Check
│   ├── next_scene.dart       # Scene transitions
│   ├── random_event.dart     # Action/Subject generation
│   └── wilderness.dart       # Weather, encounter & monster tables
└── ui/
    ├── home_screen.dart
    └── widgets/
        ├── dice_roll_dialog.dart
        ├── fate_check_dialog.dart
        ├── next_scene_dialog.dart
        └── roll_history.dart

reference/
└── juice-oracle-text-tables/  # Source tables from PDF
    ├── fate-check.md
    ├── random-tables.md
    └── ...

test/
├── roll_engine_test.dart
├── table_lookup_test.dart
├── presets_test.dart
└── test_utils.dart
```
