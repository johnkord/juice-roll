# Extract Result Classes from Preset Files - Refactoring Plan

**Priority:** 2 (High)  
**Status:** ✅ COMPLETED  
**Document Created:** 2025-12-XX  
**Last Updated:** 2025-12-11  
**Completion Date:** 2025-12-11

---

## Executive Summary

~~This document outlines a comprehensive plan to extract 68 `RollResult` subclasses from 20 preset files into dedicated result class files in `lib/models/results/`.~~ 

### ✅ REFACTORING COMPLETE

All 68+ RollResult subclasses have been successfully extracted into 23 dedicated result files in `lib/models/results/`. The refactoring was completed in 5 waves:

- **Wave 1:** 8 result files (discover_meaning, pay_the_price, abstract_icons, location, dialog, name, interrupt_plot_point, quest)
- **Wave 2:** 2 result files (scale, expectation_check)  
- **Wave 3:** 5 result files (random_event, fate_check, next_scene, details, npc_action)
- **Wave 4:** 4 result files (wilderness, monster_encounter, settlement, dungeon)
- **Wave 5:** 4 result files (object_treasure, extended_npc_conversation, immersion, challenge)

**All 321 tests pass. UI/UX unchanged. Backward compatibility preserved via re-exports.**

### ⚠️ MISSION CRITICAL CONSTRAINT
**The UI/UX must not change in any way.** Every result must display exactly as it does today. This will be verified through:
1. Running the full test suite after each extraction
2. Visual testing of key result displays
3. JSON serialization round-trip testing

---

## Current State Analysis

### Inventory of RollResult Classes

**Total classes in preset files:** 68 classes across 20 files

| Preset File | Classes | Class Names |
|-------------|---------|-------------|
| `settlement.dart` | 9 | SettlementNameResult, SettlementDetailResult, EstablishmentCountResult, MultiEstablishmentResult, FullSettlementResult, CompleteSettlementResult, EstablishmentNameResult, SettlementPropertiesResult, SimpleNpcResult |
| `dungeon_generator.dart` | 9 | DungeonNameResult, DungeonAreaResult, DungeonDetailResult, FullDungeonAreaResult, DungeonMonsterResult, DungeonTrapResult, DungeonEncounterResult, TwoPassAreaResult, TrapProcedureResult |
| `npc_action.dart` | 6 | NpcActionResult, MotiveWithFollowUpResult, SimpleNpcProfileResult, NpcProfileResult, DualPersonalityResult, ComplexNpcResult |
| `wilderness.dart` | 5 | WildernessAreaResult, WildernessEncounterResult, WildernessWeatherResult, WildernessDetailResult, MonsterLevelResult |
| `challenge.dart` | 5 | FullChallengeResult, DcResult, QuickDcResult, ChallengeSkillResult, PercentageChanceResult |
| `random_event.dart` | 4 | RandomEventResult, IdeaResult, RandomEventFocusResult, SingleTableResult |
| `details.dart` | 4 | DetailResult, PropertyResult, DualPropertyResult, DetailWithFollowUpResult |
| `next_scene.dart` | 3 | NextSceneResult, FocusResult, NextSceneWithFollowUpResult |
| `monster_encounter.dart` | 3 | FullMonsterEncounterResult, MonsterEncounterResult, MonsterTracksResult |
| `immersion.dart` | 3 | SensoryDetailResult, EmotionalAtmosphereResult, FullImmersionResult |
| `extended_npc_conversation.dart` | 3 | InformationResult, CompanionResponseResult, DialogTopicResult |
| `scale.dart` | 2 | ScaleResult, ScaledValueResult |
| `object_treasure.dart` | 2 | ObjectTreasureResult, ItemCreationResult |
| `quest.dart` | 1 | QuestResult |
| `pay_the_price.dart` | 1 | PayThePriceResult |
| `name_generator.dart` | 1 | NameResult |
| `location.dart` | 1 | LocationResult |
| `interrupt_plot_point.dart` | 1 | InterruptPlotPointResult |
| `fate_check.dart` | 1 | FateCheckResult |
| `expectation_check.dart` | 1 | ExpectationCheckResult |
| `discover_meaning.dart` | 1 | DiscoverMeaningResult |
| `dialog_generator.dart` | 1 | DialogResult |
| `abstract_icons.dart` | 1 | AbstractIconResult |

### Already Extracted (Reference Pattern)

Located in `lib/models/results/`:

| File | Contents |
|------|----------|
| `ironsworn_result.dart` | 6 Ironsworn-specific result classes (fully extracted, self-contained) |
| `table_lookup_result.dart` | TableLookupResult (extracted) |
| `oracle_results.dart` | Re-exports oracle classes from preset files (not yet extracted) |
| `character_results.dart` | Re-exports character classes from preset files (not yet extracted) |
| `world_results.dart` | Re-exports world-building classes from preset files (not yet extracted) |
| `exploration_results.dart` | Re-exports exploration classes from preset files (not yet extracted) |
| `value_objects.dart` | Lightweight embedded data objects |
| `json_utils.dart` | JSON serialization helpers |
| `results.dart` | Barrel file exporting all result modules |

---

## Target Architecture

### Proposed File Organization

After refactoring, `lib/models/results/` will contain:

```
lib/models/results/
├── results.dart                    # Barrel file (updated exports)
├── value_objects.dart              # Existing - lightweight data objects
├── json_utils.dart                 # Existing - JSON helpers
├── table_lookup_result.dart        # Existing - TableLookupResult
├── ironsworn_result.dart           # Existing - All Ironsworn results
│
├── oracle_results/                 # NEW DIRECTORY
│   ├── oracle_results.dart         # Barrel for oracle results
│   ├── fate_check_result.dart      # FateCheckResult + enums
│   ├── expectation_result.dart     # ExpectationCheckResult + enums
│   ├── random_event_result.dart    # RandomEventResult, IdeaResult, etc.
│   ├── next_scene_result.dart      # NextSceneResult, FocusResult, etc.
│   ├── discover_meaning_result.dart # DiscoverMeaningResult
│   └── interrupt_result.dart       # InterruptPlotPointResult
│
├── character_results/              # NEW DIRECTORY
│   ├── character_results.dart      # Barrel for character results
│   ├── npc_action_result.dart      # All NPC action/profile results
│   ├── dialog_result.dart          # DialogResult
│   ├── conversation_result.dart    # Extended NPC conversation results
│   └── name_result.dart            # NameResult
│
├── world_results/                  # NEW DIRECTORY  
│   ├── world_results.dart          # Barrel for world results
│   ├── settlement_result.dart      # All settlement results
│   ├── dungeon_result.dart         # All dungeon results
│   ├── quest_result.dart           # QuestResult
│   ├── object_treasure_result.dart # ObjectTreasureResult, ItemCreationResult
│   └── location_result.dart        # LocationResult
│
├── exploration_results/            # NEW DIRECTORY
│   ├── exploration_results.dart    # Barrel for exploration results
│   ├── wilderness_result.dart      # All wilderness results
│   ├── monster_result.dart         # All monster encounter results
│   ├── challenge_result.dart       # All challenge/DC results
│   └── scale_result.dart           # ScaleResult, ScaledValueResult
│
└── misc_results/                   # NEW DIRECTORY
    ├── misc_results.dart           # Barrel for misc results
    ├── immersion_result.dart       # All immersion results
    ├── details_result.dart         # All detail/property results
    ├── abstract_icon_result.dart   # AbstractIconResult
    └── pay_the_price_result.dart   # PayThePriceResult
```

### Alternative: Flat File Structure

If subdirectories feel like over-engineering, we could use a flat structure with consistent naming:

```
lib/models/results/
├── results.dart
├── value_objects.dart
├── json_utils.dart
├── table_lookup_result.dart
├── ironsworn_result.dart
├── fate_check_result.dart
├── expectation_result.dart
├── random_event_result.dart
├── next_scene_result.dart
├── discover_meaning_result.dart
├── interrupt_result.dart
├── npc_action_result.dart
├── dialog_result.dart
├── conversation_result.dart
├── name_result.dart
├── settlement_result.dart
├── dungeon_result.dart
├── quest_result.dart
├── object_treasure_result.dart
├── location_result.dart
├── wilderness_result.dart
├── monster_result.dart
├── challenge_result.dart
├── scale_result.dart
├── immersion_result.dart
├── details_result.dart
├── abstract_icon_result.dart
└── pay_the_price_result.dart
```

**Recommendation:** Start with flat structure for simplicity, evaluate subdirectory organization later if the flat structure becomes unwieldy.

---

## Extraction Process

### Per-File Workflow

For each preset file that contains RollResult classes:

#### Phase 1: Extract Result Classes

1. **Create the result file** in `lib/models/results/`
   - Copy all `class XxxResult extends RollResult` definitions
   - Copy associated enums, extensions, and helper classes
   - Add required imports (roll_result.dart, json_utils.dart, etc.)

2. **Add re-export to preset file**
   - Add `export '../models/results/xxx_result.dart';` at top of preset
   - This maintains backward compatibility for any external imports

3. **Update imports in preset file**
   - Replace local class references with import from the new result file

4. **Update RollResultFactory imports**
   - Change import from preset to result file
   - (Factory registrations remain unchanged)

#### Phase 2: Update Display System

5. **Update display module imports**
   - Change imports in `lib/ui/widgets/result_displays/` to use result files

#### Phase 3: Update Barrel Files

6. **Update `results.dart` barrel**
   - Add export for new result file
   - Remove or update any re-export patterns

#### Phase 4: Verify

7. **Run tests**
   - `flutter test` must pass completely
   - Pay attention to any display-related tests

8. **Visual verification** (spot check)
   - Run app and verify affected result displays look identical

---

## Detailed Extraction Order

Extraction will be performed in dependency order to minimize circular import issues:

### Wave 1: Standalone Results (No Dependencies)

These result classes have no dependencies on other result types:

1. **`discover_meaning_result.dart`** ← from `discover_meaning.dart` (1 class)
2. **`pay_the_price_result.dart`** ← from `pay_the_price.dart` (1 class)
3. **`abstract_icon_result.dart`** ← from `abstract_icons.dart` (1 class)
4. **`location_result.dart`** ← from `location.dart` (1 class)
5. **`quest_result.dart`** ← from `quest.dart` (1 class)
6. **`scale_result.dart`** ← from `scale.dart` (2 classes)
7. **`name_result.dart`** ← from `name_generator.dart` (1 class)

### Wave 2: Simple Dependencies

8. **`details_result.dart`** ← from `details.dart` (4 classes)
9. **`expectation_result.dart`** ← from `expectation_check.dart` (1 class + enums)
10. **`interrupt_result.dart`** ← from `interrupt_plot_point.dart` (1 class)

### Wave 3: Medium Complexity

11. **`random_event_result.dart`** ← from `random_event.dart` (4 classes + enums)
12. **`immersion_result.dart`** ← from `immersion.dart` (3 classes)
13. **`challenge_result.dart`** ← from `challenge.dart` (5 classes)
14. **`conversation_result.dart`** ← from `extended_npc_conversation.dart` (3 classes)
15. **`object_treasure_result.dart`** ← from `object_treasure.dart` (2 classes)

### Wave 4: Results with Result Dependencies

These reference other result types:

16. **`next_scene_result.dart`** ← from `next_scene.dart` (3 classes)
    - May reference `RandomEventResult`
17. **`fate_check_result.dart`** ← from `fate_check.dart` (1 class + enums)
    - References `RandomEventResult` (auto-rolled on special trigger)
18. **`dialog_result.dart`** ← from `dialog_generator.dart` (1 class)

### Wave 5: Complex/Large Files

19. **`npc_action_result.dart`** ← from `npc_action.dart` (6 classes + enums)
    - Many enums and extensions
20. **`monster_result.dart`** ← from `monster_encounter.dart` (3 classes)
21. **`wilderness_result.dart`** ← from `wilderness.dart` (5 classes)
22. **`settlement_result.dart`** ← from `settlement.dart` (9 classes)
23. **`dungeon_result.dart`** ← from `dungeon_generator.dart` (9 classes)

---

## What Gets Extracted (Per Class)

For each result class, the extraction includes:

### Always Extracted
- The `class XxxResult extends RollResult { ... }` definition
- Constructor(s)
- All instance fields
- `get className` override
- `toJson()` method
- `fromJson` factory constructor
- Any private helper methods used only by this class

### Extracted If Present
- Associated enums (e.g., `FateCheckOutcome`, `SceneType`)
- Extension methods on enums (e.g., `FateCheckOutcomeDisplay`)
- Related data classes (e.g., `SpecialTrigger`)
- Constants used only by the result class

### NOT Extracted (Stays in Preset)
- The preset class itself (e.g., `FateCheck`, `Settlement`)
- Preset methods that generate results
- Data tables (already extracted to `lib/data/`)
- Dialog widgets

---

## Files That Need Updates

### For Each Extraction

1. **New result file** - Created in `lib/models/results/`
2. **Original preset file** - Add re-export, update internal imports
3. **RollResultFactory** - Update import path
4. **Result display module** - Update import path
5. **Barrel file** - Update exports

### One-Time Updates

6. **`lib/models/results/results.dart`** - Final barrel file cleanup
7. **Tests** - May need import path updates

---

## Risk Mitigation

### Risk 1: Breaking JSON Serialization

**Mitigation:**
- The `className` property must remain identical
- `toJson()` and `fromJson` must produce identical output
- Run session history round-trip tests

### Risk 2: Breaking UI Display

**Mitigation:**
- Result type identity is preserved (same class, different location)
- Display registry uses `Type` which is unaffected by file location
- Visual spot-checks after each wave

### Risk 3: Circular Dependencies

**Mitigation:**
- Wave-based extraction order respects dependencies
- Use re-exports to maintain backward compatibility
- Can use `show` clauses to import only specific types

### Risk 4: Import Hell

**Mitigation:**
- Re-export from preset files during transition
- Update imports incrementally
- Barrel files provide single import points

---

## Rollback Strategy

If issues are found after extraction:

1. **Per-file rollback:** 
   - Delete the new result file
   - Remove the re-export from preset file
   - Revert any import changes
   - Git makes this trivial with `git checkout`

2. **Full rollback:**
   - `git reset --hard` to pre-refactor commit
   - Re-evaluate extraction strategy

---

## Success Criteria

### Must Pass
- [ ] All 234 tests pass (`flutter test`)
- [ ] No lint errors or warnings
- [ ] App builds successfully for all platforms

### UI/UX Verification
- [ ] Fate Check displays correctly (with random event trigger)
- [ ] Settlement generator shows all establishment details
- [ ] Dungeon generator displays area descriptions properly
- [ ] NPC profiles render with all personality aspects
- [ ] Session history loads correctly with diverse result types

### Code Quality
- [ ] Each result file is self-contained (no missing dependencies)
- [ ] Preset files focus on generation logic only
- [ ] RollResultFactory has clean import structure
- [ ] Barrel files provide convenient import points

---

## Estimated Effort

| Wave | Files | Classes | Est. Time |
|------|-------|---------|-----------|
| Wave 1 | 7 | 8 | 1-2 hours |
| Wave 2 | 3 | 6 | 1 hour |
| Wave 3 | 5 | 17 | 2-3 hours |
| Wave 4 | 3 | 5 | 1-2 hours |
| Wave 5 | 5 | 32 | 3-4 hours |
| **Total** | **23** | **68** | **8-12 hours** |

---

## Questions for Review - RESOLVED

1. **Flat vs. Subdirectory structure?**
   - ✅ **Decision: Flat structure**

2. **Re-export from presets during transition?**
   - ✅ **Decision: Yes, for backward compatibility**

3. **Order of extraction?**
   - ✅ **Decision: Wave-based as outlined above**

4. **Testing strategy?**
   - ✅ **Decision: Create comprehensive tests BEFORE implementation to ensure nothing breaks**

5. **Commit strategy?**
   - ✅ **Decision: One commit per wave, with descriptive messages**

---

## Pre-Implementation Testing

Before any extraction begins, comprehensive tests have been created to verify:

### Test File: `test/result_extraction_test.dart`

**87 new tests** covering:

1. **JSON Serialization Round-Trip Tests** ✅
   - Every RollResult subclass serializes and deserializes correctly
   - `className` property matches expected value
   - Correct type restored from JSON
   - RollType preserved through serialization

2. **Result Class Identity Tests** ✅
   - All 76 result classes are registered in RollResultFactory
   - Class names match between registration and actual classes

3. **Display Registry Coverage Tests** ✅
   - Registry initializes correctly
   - Display builders return valid widgets
   - Known gaps documented (10 classes use fallback displays)

### Pre-existing Issues Discovered

The tests uncovered some pre-existing serialization bugs (NOT refactor-related):
- `ExpectationCheckResult`: diceResults not fully preserved
- `NpcProfileResult`: diceResults recomputed on restore
- `SimpleNpcResult`: diceResults recomputed on restore
- `DungeonDetailResult`: description reconstructed differently

These are documented in the test file and excluded from strict comparison.
They should be fixed separately from this refactoring effort.

### Test Results
```
Total tests: 321 (234 existing + 87 new)
All tests passed!
```

These tests serve as a safety net during extraction - if any test fails after extraction, we know something broke.

---

## Next Steps

1. ✅ Plan approved
2. ✅ Comprehensive pre-implementation tests created (87 tests)
3. ✅ All tests passing (321 total)
4. ⏳ Proceed through waves with testing after each
5. ⏳ Update documentation when complete

---

*Plan approved on 2024-12-11. Pre-implementation tests completed. Ready for implementation.*
