import '../core/roll_engine.dart';
import '../data/quest_data.dart' as data;
import 'details.dart';
import 'dungeon_generator.dart';
import 'random_event.dart';
import 'settlement.dart';
import 'wilderness.dart';

// Re-export result class for backward compatibility
export '../models/results/quest_result.dart';

import '../models/results/quest_result.dart';

/// Quest generator preset for the Juice Oracle.
/// Uses quest.md to generate full quest descriptions.
/// 
/// Entries in italics reference other tables and are automatically expanded:
/// - Description row 3: Colorful → Color table
/// - Focus row 2: Monster → Monster Descriptors
/// - Focus row 3: Event → Event table
/// - Focus row 4: Environment → Environment table
/// - Focus row 6: Person → Person table
/// - Focus row 8: Location → Settlement Name
/// - Focus row 9: Object → Object table
/// - Location row 2: Dungeon Feature → Dungeon Feature table
/// - Location row 3: Dungeon → Dungeon Name
/// - Location row 4: Environment → Environment table
/// - Location row 5: Event → Event table
/// - Location row 6: Natural Hazard → Natural Hazard table
/// - Location row 8: Settlement → Settlement Name
/// - Location row 0/10: Wilderness Feature → Wilderness Feature table
class Quest {
  final RollEngine _rollEngine;
  // ignore: unused_field
  final RandomEvent _randomEvent;
  // ignore: unused_field
  final Wilderness _wilderness;
  final DungeonGenerator _dungeon;
  final Settlement _settlement;

  // ========== Static Accessors (delegate to data file) ==========

  /// Objectives - d10
  static List<String> get objectives => data.objectives;

  /// Descriptions - d10 (row 3 Colorful is italicized - references Color table)
  static List<String> get descriptions => data.descriptions;

  /// Focus - d10 (italicized entries reference other tables)
  static List<String> get focuses => data.focuses;

  /// Prepositions - d10
  static List<String> get prepositions => data.prepositions;

  /// Locations - d10 (italicized entries reference other tables)
  static List<String> get locations => data.locations;

  /// Description entries that require sub-rolls (italic in the original table)
  static Set<String> get _italicDescriptions => data.italicDescriptions;

  /// Focus entries that require sub-rolls (italic in the original table)
  static Set<String> get _italicFocuses => data.italicFocuses;

  /// Location entries that require sub-rolls (italic in the original table)
  static Set<String> get _italicLocations => data.italicLocations;

  Quest([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine(),
        _randomEvent = RandomEvent(rollEngine),
        _wilderness = Wilderness(rollEngine),
        _dungeon = DungeonGenerator(rollEngine),
        _settlement = Settlement(rollEngine);

  /// Expand a description entry by rolling on the appropriate sub-table.
  /// Returns [subRoll, expandedValue] or null if no expansion needed.
  List<dynamic>? _expandDescription(String description) {
    if (!_italicDescriptions.contains(description)) return null;

    final subRoll = _rollEngine.rollDie(10);
    final subIndex = subRoll == 10 ? 9 : subRoll - 1;

    switch (description) {
      case 'Colorful':
        // Use color table from Details
        return [subRoll, Details.colors[subIndex]];
      default:
        return null;
    }
  }

  /// Expand a focus entry by rolling on the appropriate sub-table.
  /// Returns [subRoll, expandedValue] or null if no expansion needed.
  List<dynamic>? _expandFocus(String focus) {
    if (!_italicFocuses.contains(focus)) return null;

    final subRoll = _rollEngine.rollDie(10);
    final subIndex = subRoll == 10 ? 9 : subRoll - 1;
    String expanded;

    switch (focus) {
      case 'Monster':
        // Use monster descriptors from dungeon generator
        expanded = DungeonGenerator.monsterDescriptors[subIndex];
        break;
      case 'Event':
        // Use event words from random event
        expanded = RandomEvent.eventWords[subIndex];
        break;
      case 'Environment':
        // Use wilderness environments
        expanded = Wilderness.environments[subIndex];
        break;
      case 'Person':
        // Use person words from random event
        expanded = RandomEvent.personWords[subIndex];
        break;
      case 'Location':
        // Generate a settlement name for location
        final name = _settlement.generateName();
        return [subRoll, name.name];
      case 'Object':
        // Use object words from random event
        expanded = RandomEvent.objectWords[subIndex];
        break;
      default:
        return null;
    }
    return [subRoll, expanded];
  }

  /// Expand a location entry by rolling on the appropriate sub-table.
  /// Returns [subRoll, expandedValue] or null if no expansion needed.
  List<dynamic>? _expandLocation(String location) {
    if (!_italicLocations.contains(location)) return null;

    final subRoll = _rollEngine.rollDie(10);
    final subIndex = subRoll == 10 ? 9 : subRoll - 1;
    String expanded;

    switch (location) {
      case 'Dungeon Feature':
        // Use dungeon feature types
        expanded = DungeonGenerator.featureTypes[subIndex];
        break;
      case 'Dungeon':
        // Generate a dungeon name
        final name = _dungeon.generateName();
        return [subRoll, name.name];
      case 'Environment':
        // Use wilderness environments
        expanded = Wilderness.environments[subIndex];
        break;
      case 'Event':
        // Use event words from random event
        expanded = RandomEvent.eventWords[subIndex];
        break;
      case 'Natural Hazard':
        // Use wilderness natural hazards
        expanded = Wilderness.naturalHazards[subIndex];
        break;
      case 'Settlement':
        // Generate a settlement name
        final name = _settlement.generateName();
        return [subRoll, name.name];
      case 'Wilderness Feature':
        // Use wilderness features
        expanded = Wilderness.features[subIndex];
        break;
      default:
        return null;
    }
    return [subRoll, expanded];
  }

  /// Generate a complete quest with expanded sub-table references.
  QuestResult generate() {
    final objRoll = _rollEngine.rollDie(10);
    final descRoll = _rollEngine.rollDie(10);
    final focusRoll = _rollEngine.rollDie(10);
    final prepRoll = _rollEngine.rollDie(10);
    final locRoll = _rollEngine.rollDie(10);

    final objective = objectives[objRoll == 10 ? 9 : objRoll - 1];
    final description = descriptions[descRoll == 10 ? 9 : descRoll - 1];
    final focus = focuses[focusRoll == 10 ? 9 : focusRoll - 1];
    final preposition = prepositions[prepRoll == 10 ? 9 : prepRoll - 1];
    final location = locations[locRoll == 10 ? 9 : locRoll - 1];

    // Expand italicized entries
    final descriptionExpansion = _expandDescription(description);
    final focusExpansion = _expandFocus(focus);
    final locationExpansion = _expandLocation(location);

    return QuestResult(
      objectiveRoll: objRoll,
      objective: objective,
      descriptionRoll: descRoll,
      description: description,
      descriptionSubRoll: descriptionExpansion?[0] as int?,
      descriptionExpanded: descriptionExpansion?[1] as String?,
      focusRoll: focusRoll,
      focus: focus,
      focusSubRoll: focusExpansion?[0] as int?,
      focusExpanded: focusExpansion?[1] as String?,
      prepositionRoll: prepRoll,
      preposition: preposition,
      locationRoll: locRoll,
      location: location,
      locationSubRoll: locationExpansion?[0] as int?,
      locationExpanded: locationExpansion?[1] as String?,
    );
  }
}
