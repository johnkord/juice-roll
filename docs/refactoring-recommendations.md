# Refactoring Recommendations for juice-roll

Based on a deep analysis of the codebase, here are the key areas that would benefit from refactoring, ordered by impact and urgency.

---

## 🔴 High Priority Refactors

### 1. **Massive Result Display Builder (6,945 lines)**
**File:** `lib/ui/widgets/result_display_builder.dart`

**Problem:**
- Single file with almost 7,000 lines of code
- Giant `buildDisplay()` method with 50+ `if/else if` type checks
- Every new `RollResult` type requires adding another branch here
- Hard to navigate, test, and maintain

**Recommended Solution:**
Use the **Visitor Pattern** or **Strategy Pattern** to dispatch display building:

```dart
// Option A: Visitor Pattern
abstract class RollResultVisitor<T> {
  T visitFateCheck(FateCheckResult result);
  T visitNextScene(NextSceneResult result);
  T visitNpcAction(NpcActionResult result);
  // ... etc
}

// Each RollResult implements accept()
abstract class RollResult {
  T accept<T>(RollResultVisitor<T> visitor);
}

// Option B: Registry Pattern (simpler)
class ResultDisplayRegistry {
  static final Map<Type, Widget Function(RollResult, ThemeData)> _builders = {
    FateCheckResult: (r, t) => FateCheckDisplayWidget(r as FateCheckResult, t),
    NextSceneResult: (r, t) => NextSceneDisplayWidget(r as NextSceneResult, t),
    // ...
  };
  
  Widget build(RollResult result, ThemeData theme) {
    final builder = _builders[result.runtimeType];
    return builder?.call(result, theme) ?? DefaultDisplay(result, theme);
  }
}
```

**Benefits:**
- Each result type has its own display widget file
- New result types don't require modifying the main builder
- Easier to test individual displays
- File size drops from 7,000 to ~200 lines

---

### 2. **Duplicated RollResult Subclasses in Preset Files (76 subclasses)**

**Problem:**
- There are **76 classes** extending `RollResult` scattered across preset files
- Each preset file (e.g., `npc_action.dart`, `settlement.dart`, `dungeon_generator.dart`) contains both:
  - Business logic (rolling dice, looking up tables)
  - Data model classes (result types with toJson/fromJson)
- Example: `npc_action.dart` has 1,572 lines with 6 different result classes embedded

**Recommended Solution:**
Extract result classes to dedicated files in `lib/models/results/`:

```
lib/models/results/
├── npc_results.dart          # NpcActionResult, NpcProfileResult, etc.
├── dungeon_results.dart      # DungeonAreaResult, DungeonEncounterResult, etc.
├── settlement_results.dart   # SettlementNameResult, EstablishmentResult, etc.
├── oracle_results.dart       # Already exists - good example!
└── ...
```

**Benefits:**
- Cleaner separation of concerns (logic vs. data)
- Preset files focus on dice rolling and table lookups
- Result classes are easier to find and maintain
- Reduces file sizes significantly

---

### 3. **RollResultFactory Manual Registry**
**File:** `lib/models/roll_result_factory.dart`

**Problem:**
- Manual map of 76+ class names to factory functions
- Easy to forget to register new result types
- Must be kept in sync with all result classes

**Recommended Solution:**
Use code generation or reflection:

```dart
// Option A: Use build_runner with json_serializable
// Each result class uses @JsonSerializable() annotation

// Option B: Self-registration pattern
abstract class RollResult {
  static final Map<String, RollResult Function(Map<String, dynamic>)> _registry = {};
  
  static void register<T extends RollResult>(
    String name, 
    T Function(Map<String, dynamic>) fromJson,
  ) {
    _registry[name] = fromJson;
  }
}

// Each result class registers itself at load time
class FateCheckResult extends RollResult {
  static final _init = RollResult.register('FateCheckResult', FateCheckResult.fromJson);
}
```

---

## 🟡 Medium Priority Refactors

### 4. **Duplicated Code in NPC Profile Generation**
**File:** `lib/presets/npc_action.dart`

**Problem:**
The same "motive expansion" logic is copied 4 times:
- `generateProfile()`
- `generateSimpleProfile()`
- `generateComplexNpc()`
- `rollMotiveWithFollowUp()`

```dart
// This pattern appears 4 times:
if (motive == 'History') {
  historyResult = _details.rollHistory();
} else if (motive == 'Focus') {
  focusResult = _nextScene.rollFocus();
  final expansion = _expandFocus(focusResult.focus);
  if (expansion != null) {
    focusExpansionRoll = expansion[0] as int;
    focusExpanded = expansion[1] as String;
  }
}
```

**Recommended Solution:**
Extract to a helper method:

```dart
/// Expands a motive roll into history/focus sub-rolls if needed.
({DetailResult? history, FocusResult? focus, int? expansionRoll, String? expanded}) 
_expandMotive(String motive) {
  if (motive == 'History') {
    return (history: _details.rollHistory(), focus: null, expansionRoll: null, expanded: null);
  }
  if (motive == 'Focus') {
    final focusResult = _nextScene.rollFocus();
    final expansion = _expandFocus(focusResult.focus);
    return (
      history: null, 
      focus: focusResult, 
      expansionRoll: expansion?[0] as int?, 
      expanded: expansion?[1] as String?,
    );
  }
  return (history: null, focus: null, expansionRoll: null, expanded: null);
}
```

---

### 5. **Duplicated "Need Skew" Switch Statements**
**File:** `lib/presets/npc_action.dart`

**Problem:**
The NeedSkew handling logic is duplicated 5 times:

```dart
switch (needSkew) {
  case NeedSkew.primitive:
    final result = _rollEngine.rollWithDisadvantage(1, 10);
    needRoll = result.chosenSum;
    needAllRolls = [result.sum1, result.sum2];
    break;
  case NeedSkew.complex:
    final result = _rollEngine.rollWithAdvantage(1, 10);
    needRoll = result.chosenSum;
    needAllRolls = [result.sum1, result.sum2];
    break;
  case NeedSkew.none:
    needRoll = _rollEngine.rollDie(10);
    needAllRolls = [needRoll];
}
```

**Recommended Solution:**
Add a helper method to `RollEngine` or `NpcAction`:

```dart
/// Roll a d10 with optional need skew.
({int roll, List<int> allRolls}) rollWithNeedSkew(NeedSkew skew) {
  switch (skew) {
    case NeedSkew.primitive:
      final r = rollWithDisadvantage(1, 10);
      return (roll: r.chosenSum, allRolls: [r.sum1, r.sum2]);
    case NeedSkew.complex:
      final r = rollWithAdvantage(1, 10);
      return (roll: r.chosenSum, allRolls: [r.sum1, r.sum2]);
    case NeedSkew.none:
      final r = rollDie(10);
      return (roll: r, allRolls: [r]);
  }
}
```

---

### 6. **Similar Patterns in DungeonGenerator and Wilderness**

**Files:** 
- `lib/presets/dungeon_generator.dart` (1,306 lines)
- `lib/presets/wilderness.dart` (812 lines)

**Problem:**
Both have similar patterns for:
- Advantage/disadvantage rolling with skew
- Phase-based state management
- Multi-step result composition

**Recommended Solution:**
Create shared abstractions:

```dart
/// Mixin for presets that use advantage/disadvantage rolling with skew
mixin SkewedRolling {
  RollEngine get rollEngine;
  
  ({int roll, List<int> allRolls}) rollWithSkew(int dieSize, AdvantageType skew) {
    // Centralized skew logic
  }
}

/// Base class for phase-based exploration generators
abstract class PhaseBasedGenerator {
  bool isEntering = true;
  void transitionPhase();
  // Common phase management
}
```

---

## 🟢 Low Priority / Nice-to-Have

### 7. **Extract Static Data Constants**

**Status:** Partially done (e.g., `data/npc_action_data.dart`, `data/dungeon_data.dart`)

**Problem:**
Some preset files still have large static `const List<String>` tables inline:
- `details.dart` - colors, properties, histories
- `discover_meaning.dart` - adjectives, nouns
- `random_event.dart` - event words, person words, object words

**Recommendation:**
Complete the extraction to `lib/data/` files for consistency:
- `data/details_data.dart`
- `data/meaning_data.dart`
- `data/random_event_data.dart`

---

### 8. **Consider Using freezed for Result Classes**

**Problem:**
76 result classes with manual:
- Constructor boilerplate
- toJson/fromJson implementations
- toString overrides
- Equality comparisons

**Recommendation:**
Evaluate using `freezed` package for immutable data classes:

```dart
@freezed
class FateCheckResult with _$FateCheckResult {
  const factory FateCheckResult({
    required List<int> fateDice,
    required int intensity,
    required FateCheckOutcome outcome,
    // ...
  }) = _FateCheckResult;

  factory FateCheckResult.fromJson(Map<String, dynamic> json) => 
      _$FateCheckResultFromJson(json);
}
```

**Trade-offs:**
- (+) Less boilerplate, generated equality/hashCode
- (-) Build step required, learning curve
- (-) Existing 76 classes would need migration

---

### 9. **Dialog Files Are Large but Acceptable**

**Files:** Various UI dialogs (400-900 lines each)

**Assessment:**
The dialog files are large but reasonably scoped:
- Each handles one specific feature
- They're self-contained
- UI code is inherently verbose in Flutter

**Optional improvements:**
- Extract common dialog scaffolding to a base class
- Create shared widgets for common patterns (labeled die displays, section headers)

---

## Summary: Recommended Action Order

| Priority | Task | Impact | Effort | Status |
|----------|------|--------|--------|---------|
| 1 | Refactor `ResultDisplayBuilder` using registry pattern | High | Medium | ✅ **COMPLETE** |
| 2 | Extract result classes from preset files | High | High | ⬜ Not started |
| 3 | Consolidate motive expansion logic | Medium | Low | ✅ **COMPLETE** |
| 4 | Consolidate need skew logic | Medium | Low | ✅ **COMPLETE** |
| 5 | Complete data extraction to `lib/data/` | Low | Low | ⬜ Not started |
| 6 | Evaluate `freezed` for new result classes | Low | High | ⬜ Not started |

### Refactoring Progress

#### ResultDisplayBuilder Migration (Priority 1) ✅ COMPLETE

**Infrastructure Created:**
- ✅ `lib/ui/widgets/result_display_registry.dart` - Type-safe registry pattern
- ✅ `lib/ui/widgets/result_displays/` directory structure
- ✅ `lib/ui/widgets/result_displays/base_display_helpers.dart` - Shared widgets
- ✅ `lib/ui/widgets/result_displays/result_displays.dart` - Barrel file with init
- ✅ Updated `main.dart` to initialize display registry

**Migrated Categories (64 types total):**
- ✅ **Ironsworn** (6 types) - `ironsworn_displays.dart`
  - IronswornActionResult
  - IronswornProgressResult  
  - IronswornOracleResult
  - IronswornYesNoResult
  - IronswornCursedOracleResult
  - IronswornMomentumBurnResult

- ✅ **Oracle** (9 types) - `oracle_displays.dart`
  - FateCheckResult
  - ExpectationCheckResult
  - ScaleResult
  - NextSceneResult
  - NextSceneWithFollowUpResult
  - RandomEventResult
  - RandomEventFocusResult
  - IdeaResult
  - DiscoverMeaningResult

- ✅ **NPC** (4 types) - `npc_displays.dart`
  - MotiveWithFollowUpResult
  - NpcActionResult
  - NpcProfileResult
  - ComplexNpcResult

- ✅ **Settlement** (5 types) - `settlement_displays.dart`
  - SettlementNameResult
  - EstablishmentNameResult
  - SettlementPropertiesResult
  - CompleteSettlementResult
  - FullSettlementResult

- ✅ **Challenge** (4 types) - `challenge_displays.dart`
  - FullChallengeResult
  - ChallengeSkillResult
  - DcResult
  - QuickDcResult

- ✅ **Immersion** (3 types) - `immersion_displays.dart`
  - SensoryDetailResult
  - EmotionalAtmosphereResult
  - FullImmersionResult

- ✅ **Details** (4 types) - `details_displays.dart`
  - PropertyResult
  - DualPropertyResult
  - DetailResult
  - DetailWithFollowUpResult

- ✅ **Wilderness & Monster** (7 types) - `wilderness_displays.dart`
  - WildernessAreaResult
  - WildernessEncounterResult
  - WildernessWeatherResult
  - FullMonsterEncounterResult
  - MonsterEncounterResult
  - MonsterTracksResult
  - LocationResult

- ✅ **Dungeon** (9 types) - `dungeon_displays.dart`
  - DungeonEncounterResult
  - DungeonNameResult
  - DungeonAreaResult
  - FullDungeonAreaResult
  - TwoPassAreaResult
  - DungeonMonsterResult
  - DungeonTrapResult
  - TrapProcedureResult
  - DungeonDetailResult

- ✅ **Misc** (13 types) - `misc_displays.dart`
  - PayThePriceResult
  - QuestResult
  - InterruptPlotPointResult
  - SimpleNpcResult
  - ItemCreationResult
  - ObjectTreasureResult
  - FateRollResult
  - DialogResult
  - AbstractIconResult
  - InformationResult
  - CompanionResponseResult
  - DialogTopicResult
  - NameResult

**Migration Results:**
- All 64 specific result types migrated to registry pattern
- result_display_builder.dart reduced from 6,946 lines to 320 lines
- All 234 tests pass
- No if/else type checking chains remain for specific result types

**Architecture:**
- `result_display_builder.dart` - Registry lookup + generic dice fallback
- `result_displays/result_displays.dart` - Barrel file with initialization
- `result_displays/*.dart` - 10 category files with display builders

---

## Architectural Strengths to Preserve

The codebase has good patterns that should be maintained:
- ✅ `PresetRegistry` for lazy-loading presets
- ✅ Separation of data files in `lib/data/`
- ✅ `HomeState` and `HomeStateNotifier` for state management
- ✅ Result re-export files (`oracle_results.dart`, `character_results.dart`)
- ✅ Consistent `toJson`/`fromJson` patterns
- ✅ Good test coverage structure

