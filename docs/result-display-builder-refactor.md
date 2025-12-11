# Result Display Builder Refactoring Plan

## Mission Critical: Complete Refactoring Guide

This document provides a step-by-step, safe, incremental refactoring strategy for `lib/ui/widgets/result_display_builder.dart` (6,946 lines).

---

## Problem Analysis

### Current State
```
result_display_builder.dart (6,946 lines)
├── Lines 1-47: Imports and class definition
├── Lines 48-180: buildDisplay() with 50+ if/else type checks
├── Lines 181-1100: Oracle display methods (Fate, Expectation, Scale, NextScene, RandomEvent, DiscoverMeaning)
├── Lines 1100-1600: NPC & Character display methods
├── Lines 1600-2100: Settlement & Treasure display methods
├── Lines 2100-2700: Challenge & DC display methods
├── Lines 2700-3700: Immersion & Details display methods
├── Lines 3700-5000: Wilderness, Dungeon, Dialog display methods
├── Lines 5000-5800: Name generator display
└── Lines 5800-6946: Ironsworn displays + helper methods
```

### Key Pain Points
1. **Massive if/else chain** - Adding a new result type requires modifying the central dispatcher
2. **7,000 lines in one file** - Difficult to navigate, test, and maintain
3. **Tight coupling** - Every result type is directly imported and checked
4. **Open/Closed violation** - Must modify existing code to add new types

---

## Refactoring Strategy: Display Registry Pattern

### Target Architecture
```
lib/ui/widgets/
├── result_display_builder.dart        (~100 lines - registry + dispatch)
├── result_display_registry.dart       (~150 lines - type registration)
└── result_displays/
    ├── oracle_displays.dart           (Fate, Expectation, Scale, etc.)
    ├── npc_displays.dart              (NpcAction, NpcProfile, ComplexNpc)
    ├── settlement_displays.dart       (SettlementName, Establishment, etc.)
    ├── challenge_displays.dart        (Challenge, DC, Skill)
    ├── exploration_displays.dart      (Wilderness, Location)
    ├── dungeon_displays.dart          (DungeonArea, Encounter, Trap)
    ├── ironsworn_displays.dart        (Action, Progress, Oracle)
    ├── details_displays.dart          (Property, Detail, Immersion)
    ├── dialog_displays.dart           (Dialog, Conversation)
    ├── name_displays.dart             (NameResult)
    └── base_display_helpers.dart      (Shared widgets + helper methods)
```

---

## Phase 1: Create Infrastructure (Non-Breaking)

### Step 1.1: Create the Display Registry

Create `/lib/ui/widgets/result_display_registry.dart`:

```dart
import 'package:flutter/material.dart';
import '../../models/roll_result.dart';

/// Function type for building a display widget from a result.
typedef DisplayBuilder<T extends RollResult> = Widget Function(T result, ThemeData theme);

/// Registry for result type display builders.
/// 
/// This replaces the massive if/else chain in ResultDisplayBuilder with a
/// type-safe, extensible registry pattern.
/// 
/// Usage:
/// ```dart
/// // Register during app initialization or in module files
/// ResultDisplayRegistry.register<FateCheckResult>(
///   (result, theme) => FateCheckDisplay(result: result, theme: theme),
/// );
/// 
/// // Build display
/// final widget = ResultDisplayRegistry.build(result, theme);
/// ```
class ResultDisplayRegistry {
  static final Map<Type, DisplayBuilder<RollResult>> _builders = {};
  
  /// Register a display builder for a specific result type.
  static void register<T extends RollResult>(DisplayBuilder<T> builder) {
    _builders[T] = (result, theme) => builder(result as T, theme);
  }
  
  /// Check if a type has a registered display builder.
  static bool hasBuilder(Type type) => _builders.containsKey(type);
  
  /// Build the display widget for a result.
  /// Returns null if no builder is registered for the type.
  static Widget? build(RollResult result, ThemeData theme) {
    final builder = _builders[result.runtimeType];
    return builder?.call(result, theme);
  }
  
  /// Get all registered types (for debugging).
  static List<Type> get registeredTypes => _builders.keys.toList();
}
```

### Step 1.2: Create Shared Helper Widgets

Create `/lib/ui/widgets/result_displays/base_display_helpers.dart`:

Extract common helper methods from the existing file:

```dart
import 'package:flutter/material.dart';
import '../../../ui/theme/juice_theme.dart';

/// Shared helper methods and widgets for result displays.
/// 
/// These were extracted from result_display_builder.dart to avoid
/// duplication across display modules.

/// Build a section header with optional subtitle.
Widget buildSectionHeader(
  String title, 
  ThemeData theme, {
  String? subtitle,
  IconData? icon,
}) {
  return Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 4),
    child: Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: JuiceTheme.gold),
          const SizedBox(width: 6),
        ],
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: JuiceTheme.gold,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: JuiceTheme.parchmentDark.withOpacity(0.7),
            ),
          ),
        ],
      ],
    ),
  );
}

/// Build a labeled value row.
Widget buildLabeledValue(
  String label,
  String value,
  ThemeData theme, {
  int? roll,
  bool highlight = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: JuiceTheme.parchmentDark.withOpacity(0.8),
            ),
          ),
        ),
        if (roll != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: JuiceTheme.inkDark,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              '$roll',
              style: theme.textTheme.bodySmall?.copyWith(
                color: JuiceTheme.parchmentDark.withOpacity(0.6),
                fontFamily: JuiceTheme.fontFamilyMono,
                fontSize: 10,
              ),
            ),
          ),
        ],
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: highlight ? JuiceTheme.gold : JuiceTheme.parchment,
              fontWeight: highlight ? FontWeight.w600 : null,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Build a compact die result display.
Widget buildDieBox(
  int value, 
  ThemeData theme, {
  Color? color,
  bool large = false,
}) {
  return Container(
    width: large ? 36 : 28,
    height: large ? 36 : 28,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color ?? JuiceTheme.inkDark,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(
        color: JuiceTheme.parchmentDark.withOpacity(0.3),
      ),
    ),
    child: Text(
      '$value',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: JuiceTheme.parchment,
        fontFamily: JuiceTheme.fontFamilyMono,
        fontWeight: FontWeight.bold,
        fontSize: large ? 16 : 12,
      ),
    ),
  );
}

/// Build an Ironsworn-style die box with color coding.
Widget buildIronswornDieBox(
  int value,
  ThemeData theme, {
  required bool isActionDie,
  bool isChallenge1 = false,
  bool isChallenge2 = false,
}) {
  Color bgColor;
  Color textColor = JuiceTheme.parchment;
  
  if (isActionDie) {
    bgColor = JuiceTheme.mystic;
  } else if (isChallenge1) {
    bgColor = JuiceTheme.danger.withOpacity(0.8);
  } else {
    bgColor = JuiceTheme.rust;
  }
  
  return Container(
    width: 32,
    height: 32,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      '$value',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: textColor,
        fontFamily: JuiceTheme.fontFamilyMono,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

/// Get outcome color for Ironsworn results.
Color getChallengeColor(String outcome) {
  switch (outcome.toLowerCase()) {
    case 'strong hit':
      return JuiceTheme.success;
    case 'weak hit':
      return JuiceTheme.gold;
    case 'miss':
      return JuiceTheme.danger;
    default:
      return JuiceTheme.parchment;
  }
}

/// Build a divider line.
Widget buildDivider() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Divider(
      color: JuiceTheme.parchmentDark.withOpacity(0.2),
      height: 1,
    ),
  );
}
```

---

## Phase 2: Extract Display Widgets (Incremental)

Extract displays one category at a time, keeping the original code working as fallback.

### Step 2.1: Start with Ironsworn (Well-Contained)

Create `/lib/ui/widgets/result_displays/ironsworn_displays.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../models/results/ironsworn_result.dart';
import '../../theme/juice_theme.dart';
import 'base_display_helpers.dart';

/// Registers all Ironsworn display builders.
void registerIronswornDisplays() {
  ResultDisplayRegistry.register<IronswornActionResult>(buildIronswornActionDisplay);
  ResultDisplayRegistry.register<IronswornProgressResult>(buildIronswornProgressDisplay);
  ResultDisplayRegistry.register<IronswornOracleResult>(buildIronswornOracleDisplay);
  ResultDisplayRegistry.register<IronswornYesNoResult>(buildIronswornYesNoDisplay);
  ResultDisplayRegistry.register<IronswornCursedOracleResult>(buildIronswornCursedOracleDisplay);
  ResultDisplayRegistry.register<IronswornMomentumBurnResult>(buildIronswornMomentumBurnDisplay);
}

Widget buildIronswornActionDisplay(IronswornActionResult result, ThemeData theme) {
  final outcomeColor = getChallengeColor(result.outcome);
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Outcome header
      Text(
        result.outcome.toUpperCase(),
        style: theme.textTheme.titleMedium?.copyWith(
          color: outcomeColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      const SizedBox(height: 12),
      
      // Dice display
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Action die
          Column(
            children: [
              Text(
                'Action',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: JuiceTheme.parchmentDark.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              buildIronswornDieBox(result.actionDie, theme, isActionDie: true),
              if (result.stat != null) ...[
                const SizedBox(height: 2),
                Text(
                  '+${result.stat}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: JuiceTheme.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'vs',
              style: theme.textTheme.bodySmall?.copyWith(
                color: JuiceTheme.parchmentDark.withOpacity(0.5),
              ),
            ),
          ),
          
          // Challenge dice
          Row(
            children: [
              Column(
                children: [
                  Text(
                    'Challenge',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: JuiceTheme.parchmentDark.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      buildIronswornDieBox(
                        result.challengeDie1, 
                        theme, 
                        isActionDie: false,
                        isChallenge1: true,
                      ),
                      const SizedBox(width: 8),
                      buildIronswornDieBox(
                        result.challengeDie2, 
                        theme, 
                        isActionDie: false,
                        isChallenge2: true,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      
      // Score summary
      if (result.actionScore != null) ...[
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Score: ${result.actionScore}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: JuiceTheme.parchment,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
      
      // Match indicator
      if (result.isMatch) ...[
        const SizedBox(height: 8),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: JuiceTheme.mystic.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: JuiceTheme.mystic),
            ),
            child: Text(
              'MATCH!',
              style: theme.textTheme.labelMedium?.copyWith(
                color: JuiceTheme.mystic,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    ],
  );
}

// ... Continue with other Ironsworn displays
// (Copy the method implementations from result_display_builder.dart)
```

### Step 2.2: Update ResultDisplayBuilder to Use Registry

Modify `buildDisplay()` to check the registry first:

```dart
Widget buildDisplay(RollResult result) {
  // Try registry first (new pattern)
  final registryWidget = ResultDisplayRegistry.build(result, theme);
  if (registryWidget != null) {
    return registryWidget;
  }
  
  // Fall back to existing if/else chain (gradually remove)
  if (result is FateCheckResult) {
    return _buildFateCheckDisplay(result);
  }
  // ... rest of existing code
}
```

---

## Phase 3: Migrate Categories (One at a Time)

### Migration Order (by dependency and isolation)

1. **Ironsworn** (6 types) - Most isolated, no dependencies on other displays
2. **Oracle** (Fate, Expectation, Scale, NextScene, RandomEvent, DiscoverMeaning)
3. **NPC** (NpcAction, NpcProfile, ComplexNpc, Motive)
4. **Challenge** (Challenge, DC, QuickDC, Skill)
5. **Settlement** (SettlementName, Establishment, Properties, Complete, Full)
6. **Dungeon** (Area, Encounter, Monster, Trap, Detail, TwoPass)
7. **Wilderness** (Area, Encounter, Weather, Monster, Location)
8. **Details** (Property, Detail, Immersion, Sensory, Emotional)
9. **Dialog** (Dialog, Information, Companion, Topic)
10. **Name** (NameResult)
11. **Misc** (Abstract Icons, Pay Price, Quest, Interrupt)

### For Each Category:

1. Create the display file (e.g., `oracle_displays.dart`)
2. Copy display methods from `result_display_builder.dart`
3. Convert methods to standalone functions
4. Add registration function
5. Register in app initialization
6. Remove if/else branch from `buildDisplay()`
7. Run tests to verify
8. Delete old methods from `result_display_builder.dart`

---

## Phase 4: Wire Up Registration

### Step 4.1: Create Display Module Initializer

Create `/lib/ui/widgets/result_displays/result_displays.dart`:

```dart
/// Barrel file for result display registration.
/// 
/// Call [registerAllDisplayBuilders] during app initialization
/// to register all result type display builders.
library;

import 'ironsworn_displays.dart';
import 'oracle_displays.dart';
import 'npc_displays.dart';
import 'settlement_displays.dart';
import 'challenge_displays.dart';
import 'dungeon_displays.dart';
import 'wilderness_displays.dart';
import 'details_displays.dart';
import 'dialog_displays.dart';
import 'name_displays.dart';

export '../result_display_registry.dart';
export 'base_display_helpers.dart';

/// Register all display builders.
/// Call this once during app initialization.
void registerAllDisplayBuilders() {
  registerIronswornDisplays();
  registerOracleDisplays();
  registerNpcDisplays();
  registerSettlementDisplays();
  registerChallengeDisplays();
  registerDungeonDisplays();
  registerWildernessDisplays();
  registerDetailsDisplays();
  registerDialogDisplays();
  registerNameDisplays();
}
```

### Step 4.2: Update main.dart

```dart
void main() {
  // Initialize display builders registry
  registerAllDisplayBuilders();    // For UI display
  
  runApp(const JuiceRollApp());
}
```

---

## Phase 5: Final Cleanup

After all categories are migrated:

1. **Remove old methods** from `result_display_builder.dart`
2. **Remove unused imports**
3. **Simplify buildDisplay()** to just use the registry
4. **Delete the if/else chain entirely**

Final `result_display_builder.dart` (~100 lines):

```dart
import 'package:flutter/material.dart';
import '../../models/roll_result.dart';
import 'result_display_registry.dart';
import 'result_displays/base_display_helpers.dart';

/// Centralized result display builder.
///
/// Delegates to registered display builders via [ResultDisplayRegistry].
class ResultDisplayBuilder {
  final ThemeData theme;

  const ResultDisplayBuilder(this.theme);

  /// Build the display widget for any result type.
  Widget buildDisplay(RollResult result) {
    // Use registry for all known types
    final widget = ResultDisplayRegistry.build(result, theme);
    if (widget != null) {
      return widget;
    }

    // Handle standard dice roll types
    if (result.type == RollType.standard ||
        result.type == RollType.advantage ||
        result.type == RollType.disadvantage ||
        result.type == RollType.skewed) {
      return _buildGenericDiceRollDisplay(result);
    }

    // Default fallback
    return _buildDefaultDisplay(result);
  }

  Widget _buildGenericDiceRollDisplay(RollResult result) {
    // Keep generic implementations here
  }

  Widget _buildDefaultDisplay(RollResult result) {
    // Keep fallback implementation here
  }
}
```

---

## Testing Strategy

### Unit Tests for Each Display

```dart
// test/ui/widgets/result_displays/ironsworn_displays_test.dart
void main() {
  testWidgets('IronswornActionResult displays correctly', (tester) async {
    final result = IronswornActionResult(
      actionDie: 4,
      challengeDie1: 3,
      challengeDie2: 7,
      stat: 2,
      outcome: 'Weak Hit',
    );
    
    await tester.pumpWidget(
      MaterialApp(
        theme: JuiceTheme.themeData,
        home: Scaffold(
          body: buildIronswornActionDisplay(result, JuiceTheme.themeData),
        ),
      ),
    );
    
    expect(find.text('WEAK HIT'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('+2'), findsOneWidget);
  });
}
```

### Integration Test

```dart
// test/ui/widgets/result_display_builder_test.dart
void main() {
  setUpAll(() {
    registerAllDisplayBuilders();
  });

  testWidgets('displays all registered result types', (tester) async {
    // Create one of each result type
    final results = [
      FateCheckResult(...),
      IronswornActionResult(...),
      NpcActionResult(...),
      // ... all types
    ];
    
    for (final result in results) {
      final widget = ResultDisplayBuilder(theme).buildDisplay(result);
      expect(widget, isNotNull);
      // Verify it's not the default fallback
      expect(widget.runtimeType, isNot(equals(_DefaultDisplay)));
    }
  });
}
```

---

## Risk Mitigation

1. **Keep fallback chain during migration** - The old if/else still works until removed
2. **Migrate one category at a time** - Easier to debug and rollback
3. **Test after each category** - Catch issues early
4. **Git commits per category** - Easy to revert specific changes
5. **Run full test suite** - `flutter test` after each phase

---

## Estimated Effort

| Phase | Description | Time Estimate |
|-------|-------------|---------------|
| 1 | Create infrastructure | 1-2 hours |
| 2 | Extract first category (Ironsworn) | 2-3 hours |
| 3 | Migrate remaining 10 categories | 8-12 hours |
| 4 | Wire up registration | 30 minutes |
| 5 | Final cleanup and testing | 2-3 hours |
| **Total** | | **15-20 hours** |

---

## Success Metrics

- [ ] `result_display_builder.dart` < 150 lines
- [ ] No if/else type checking chain
- [ ] Each display category in its own file (~300-600 lines each)
- [ ] All existing tests pass
- [ ] New tests for registry and displays
- [ ] Adding a new result type requires only:
  1. Create the result class
  2. Register in RollResultFactory (for JSON)
  3. Create display function
  4. Register in ResultDisplayRegistry (for UI)
