// Barrel file for RollResult types and utilities.
//
// Import this file to access all result-related classes:
// ```dart
// import 'package:juice_roll/models/results/results.dart';
// ```

// Lightweight value objects for embedded data
export 'value_objects.dart';

// Generic table lookup result
export 'table_lookup_result.dart';

// =============================================================================
// CATEGORIZED RESULT RE-EXPORTS
// =============================================================================

// Oracle results (Fate Check, Expectation Check, Random Event, Next Scene, etc.)
export 'oracle_results.dart';

// Character results (NPC, Dialog, Names)
export 'character_results.dart';

// World-building results (Settlement, Dungeon, Quest, Objects)
export 'world_results.dart';

// Exploration results (Wilderness, Monster, Challenge, Scale)
export 'exploration_results.dart';

// Re-export base RollResult for convenience
export '../roll_result.dart';
