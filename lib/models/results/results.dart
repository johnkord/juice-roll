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
// EXTRACTED STANDALONE RESULT CLASSES (Wave 1)
// =============================================================================

// Discover Meaning result
export 'discover_meaning_result.dart';

// Pay the Price result
export 'pay_the_price_result.dart';

// Abstract Icons result
export 'abstract_icons_result.dart';

// Location result (with enums)
export 'location_result.dart';

// Dialog result
export 'dialog_result.dart';

// Name result (with enums)
export 'name_result.dart';

// Interrupt Plot Point result
export 'interrupt_plot_point_result.dart';

// Quest result
export 'quest_result.dart';

// =============================================================================
// EXTRACTED STANDALONE RESULT CLASSES (Wave 2)
// =============================================================================

// Scale result
export 'scale_result.dart';

// Expectation Check result (with enum)
export 'expectation_check_result.dart';

// =============================================================================
// EXTRACTED STANDALONE RESULT CLASSES (Wave 3)
// =============================================================================

// Random Event result classes
export 'random_event_result.dart';

// Fate Check result (with enums)
export 'fate_check_result.dart';

// Next Scene result (with enums)
export 'next_scene_result.dart';

// Details result (with enums)
export 'details_result.dart';

// NPC Action result (with enums)
export 'npc_action_result.dart';

// =============================================================================
// EXTRACTED STANDALONE RESULT CLASSES (Wave 4)
// =============================================================================

// Wilderness result (with state class)
export 'wilderness_result.dart';

// Monster Encounter result (with enum and value class)
export 'monster_encounter_result.dart';

// Settlement result (with enum)
export 'settlement_result.dart';

// Dungeon result (with enums and result classes)
export 'dungeon_result.dart';

// =============================================================================
// EXTRACTED STANDALONE RESULT CLASSES (Wave 5)
// =============================================================================

// Object/Treasure result
export 'object_treasure_result.dart';

// Extended NPC Conversation result
export 'extended_npc_conversation_result.dart';

// Immersion result (with enums)
export 'immersion_result.dart';

// Challenge result (with enums and result classes)
export 'challenge_result.dart';

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
