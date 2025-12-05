import '../core/roll_engine.dart';
import '../models/roll_result.dart';
import 'details.dart';
import 'dungeon_generator.dart';
import 'random_event.dart';
import 'settlement.dart';
import 'wilderness.dart';

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
  final RandomEvent _randomEvent;
  final Wilderness _wilderness;
  final DungeonGenerator _dungeon;
  final Settlement _settlement;

  /// Objectives - d10
  static const List<String> objectives = [
    'Attain',     // 1
    'Create',     // 2
    'Deliver',    // 3
    'Destroy',    // 4
    'Fetch',      // 5
    'Infiltrate', // 6
    'Investigate',// 7
    'Negotiate',  // 8
    'Protect',    // 9
    'Survive',    // 0/10
  ];

  /// Descriptions - d10 (row 3 Colorful is italicized - references Color table)
  static const List<String> descriptions = [
    'Abandoned',  // 1
    'Cold',       // 2
    'Colorful',   // 3 (italic - roll Color table)
    'Connected',  // 4
    'Dark',       // 5
    'Friendly',   // 6
    'Hidden',     // 7
    'Mystical',   // 8
    'Remote',     // 9
    'Wounded',    // 0/10
  ];

  /// Focus - d10 (italicized entries reference other tables)
  static const List<String> focuses = [
    'Enemy',       // 1
    'Monster',     // 2 (italic - roll Monster Descriptors)
    'Event',       // 3 (italic - roll Event)
    'Environment', // 4 (italic - roll Environment)
    'Community',   // 5
    'Person',      // 6 (italic - roll Person)
    'Information', // 7
    'Location',    // 8 (italic - roll Settlement Name)
    'Object',      // 9 (italic - roll Object)
    'Ally',        // 0/10
  ];

  /// Prepositions - d10
  static const List<String> prepositions = [
    'Around',      // 1
    'Behind',      // 2
    'In Front Of', // 3
    'Near',        // 4
    'On Top Of',   // 5
    'At',          // 6
    'From',        // 7
    'Inside Of',   // 8
    'Outside Of',  // 9
    'Under',       // 0/10
  ];

  /// Locations - d10 (italicized entries reference other tables)
  static const List<String> locations = [
    'Community',         // 1
    'Dungeon Feature',   // 2 (italic - roll Dungeon Feature)
    'Dungeon',           // 3 (italic - roll Dungeon Name)
    'Environment',       // 4 (italic - roll Environment)
    'Event',             // 5 (italic - roll Event)
    'Natural Hazard',    // 6 (italic - roll Natural Hazard)
    'Outpost',           // 7
    'Settlement',        // 8 (italic - roll Settlement Name)
    'Transportation',    // 9
    'Wilderness Feature',// 0/10 (italic - roll Wilderness Feature)
  ];

  /// Description entries that require sub-rolls (italic in the original table)
  static const Set<String> _italicDescriptions = {'Colorful'};

  /// Focus entries that require sub-rolls (italic in the original table)
  static const Set<String> _italicFocuses = {
    'Monster', 'Event', 'Environment', 'Person', 'Location', 'Object'
  };

  /// Location entries that require sub-rolls (italic in the original table)
  static const Set<String> _italicLocations = {
    'Dungeon Feature', 'Dungeon', 'Environment', 'Event', 
    'Natural Hazard', 'Settlement', 'Wilderness Feature'
  };

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

/// Result of a Quest generation.
class QuestResult extends RollResult {
  final int objectiveRoll;
  final String objective;
  final int descriptionRoll;
  final String description;
  final int? descriptionSubRoll;
  final String? descriptionExpanded;
  final int focusRoll;
  final String focus;
  final int? focusSubRoll;
  final String? focusExpanded;
  final int prepositionRoll;
  final String preposition;
  final int locationRoll;
  final String location;
  final int? locationSubRoll;
  final String? locationExpanded;

  QuestResult({
    required this.objectiveRoll,
    required this.objective,
    required this.descriptionRoll,
    required this.description,
    this.descriptionSubRoll,
    this.descriptionExpanded,
    required this.focusRoll,
    required this.focus,
    this.focusSubRoll,
    this.focusExpanded,
    required this.prepositionRoll,
    required this.preposition,
    required this.locationRoll,
    required this.location,
    this.locationSubRoll,
    this.locationExpanded,
    DateTime? timestamp,
  }) : super(
          type: RollType.quest,
          description: 'Quest',
          diceResults: [
            objectiveRoll,
            descriptionRoll,
            if (descriptionSubRoll != null) descriptionSubRoll,
            focusRoll,
            if (focusSubRoll != null) focusSubRoll,
            prepositionRoll,
            locationRoll,
            if (locationSubRoll != null) locationSubRoll,
          ],
          total: objectiveRoll +
              descriptionRoll +
              (descriptionSubRoll ?? 0) +
              focusRoll +
              (focusSubRoll ?? 0) +
              prepositionRoll +
              locationRoll +
              (locationSubRoll ?? 0),
          interpretation: _buildInterpretation(
            objective, description, descriptionExpanded, focus, focusExpanded,
            preposition, location, locationExpanded,
          ),
          timestamp: timestamp,
          metadata: {
            'objective': objective,
            'objectiveRoll': objectiveRoll,
            'description': description,
            'descriptionRoll': descriptionRoll,
            if (descriptionExpanded != null) 'descriptionExpanded': descriptionExpanded,
            if (descriptionSubRoll != null) 'descriptionSubRoll': descriptionSubRoll,
            'focus': focus,
            'focusRoll': focusRoll,
            if (focusExpanded != null) 'focusExpanded': focusExpanded,
            if (focusSubRoll != null) 'focusSubRoll': focusSubRoll,
            'preposition': preposition,
            'prepositionRoll': prepositionRoll,
            'location': location,
            'locationRoll': locationRoll,
            if (locationExpanded != null) 'locationExpanded': locationExpanded,
            if (locationSubRoll != null) 'locationSubRoll': locationSubRoll,
          },
        );

  @override
  String get className => 'QuestResult';

  factory QuestResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    return QuestResult(
      objectiveRoll: meta['objectiveRoll'] as int? ?? 1,
      objective: meta['objective'] as String,
      descriptionRoll: meta['descriptionRoll'] as int? ?? 1,
      description: meta['description'] as String,
      descriptionSubRoll: meta['descriptionSubRoll'] as int?,
      descriptionExpanded: meta['descriptionExpanded'] as String?,
      focusRoll: meta['focusRoll'] as int? ?? 1,
      focus: meta['focus'] as String,
      focusSubRoll: meta['focusSubRoll'] as int?,
      focusExpanded: meta['focusExpanded'] as String?,
      prepositionRoll: meta['prepositionRoll'] as int? ?? 1,
      preposition: meta['preposition'] as String,
      locationRoll: meta['locationRoll'] as int? ?? 1,
      location: meta['location'] as String,
      locationSubRoll: meta['locationSubRoll'] as int?,
      locationExpanded: meta['locationExpanded'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  static String _buildInterpretation(
    String objective,
    String description,
    String? descriptionExpanded,
    String focus,
    String? focusExpanded,
    String preposition,
    String location,
    String? locationExpanded,
  ) {
    final descText = descriptionExpanded != null ? '$descriptionExpanded ($description)' : description;
    final focusText = focusExpanded != null ? '$focusExpanded ($focus)' : focus;
    final locationText = locationExpanded != null ? '$locationExpanded ($location)' : location;
    return '$objective the $descText $focusText $preposition the $locationText';
  }

  /// Get the display text for the description (with expansion if available).
  String get descriptionDisplay => descriptionExpanded != null ? '$descriptionExpanded ($description)' : description;

  /// Get the display text for the focus (with expansion if available).
  String get focusDisplay => focusExpanded != null ? '$focusExpanded ($focus)' : focus;

  /// Get the display text for the location (with expansion if available).
  String get locationDisplay => locationExpanded != null ? '$locationExpanded ($location)' : location;

  /// Get the full quest sentence.
  String get questSentence =>
      '$objective the $descriptionDisplay $focusDisplay $preposition the $locationDisplay';

  /// Check if the description was expanded from a sub-table.
  bool get hasDescriptionExpansion => descriptionExpanded != null;

  /// Check if the focus was expanded from a sub-table.
  bool get hasFocusExpansion => focusExpanded != null;

  /// Check if the location was expanded from a sub-table.
  bool get hasLocationExpansion => locationExpanded != null;

  @override
  String toString() => 'Quest: $questSentence';
}
