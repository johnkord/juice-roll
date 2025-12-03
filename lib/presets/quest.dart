import '../core/roll_engine.dart';
import '../models/roll_result.dart';

/// Quest generator preset for the Juice Oracle.
/// Uses quest.md to generate full quest descriptions.
class Quest {
  final RollEngine _rollEngine;

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

  /// Descriptions - d10
  static const List<String> descriptions = [
    'Abandoned',  // 1
    'Cold',       // 2
    'Colorful',   // 3 (italic - roll on another table)
    'Connected',  // 4
    'Dark',       // 5
    'Friendly',   // 6
    'Hidden',     // 7
    'Mystical',   // 8
    'Remote',     // 9
    'Wounded',    // 0/10
  ];

  /// Focus - d10
  static const List<String> focuses = [
    'Enemy',       // 1
    'Monster',     // 2 (italic)
    'Event',       // 3 (italic)
    'Environment', // 4 (italic)
    'Community',   // 5
    'Person',      // 6 (italic)
    'Information', // 7
    'Location',    // 8 (italic)
    'Object',      // 9 (italic)
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

  /// Locations - d10
  static const List<String> locations = [
    'Community',         // 1
    'Dungeon Feature',   // 2 (italic)
    'Dungeon',           // 3 (italic)
    'Environment',       // 4 (italic)
    'Event',             // 5 (italic)
    'Natural Hazard',    // 6 (italic)
    'Outpost',           // 7
    'Settlement',        // 8 (italic)
    'Transportation',    // 9
    'Wilderness Feature',// 0/10 (italic)
  ];

  Quest([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  /// Generate a complete quest.
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

    return QuestResult(
      objectiveRoll: objRoll,
      objective: objective,
      descriptionRoll: descRoll,
      description: description,
      focusRoll: focusRoll,
      focus: focus,
      prepositionRoll: prepRoll,
      preposition: preposition,
      locationRoll: locRoll,
      location: location,
    );
  }
}

/// Result of a Quest generation.
class QuestResult extends RollResult {
  final int objectiveRoll;
  final String objective;
  final int descriptionRoll;
  final String description;
  final int focusRoll;
  final String focus;
  final int prepositionRoll;
  final String preposition;
  final int locationRoll;
  final String location;

  QuestResult({
    required this.objectiveRoll,
    required this.objective,
    required this.descriptionRoll,
    required this.description,
    required this.focusRoll,
    required this.focus,
    required this.prepositionRoll,
    required this.preposition,
    required this.locationRoll,
    required this.location,
  }) : super(
          type: RollType.quest,
          description: 'Quest',
          diceResults: [
            objectiveRoll,
            descriptionRoll,
            focusRoll,
            prepositionRoll,
            locationRoll
          ],
          total: objectiveRoll +
              descriptionRoll +
              focusRoll +
              prepositionRoll +
              locationRoll,
          interpretation: '$objective the $description $focus $preposition the $location',
          metadata: {
            'objective': objective,
            'description': description,
            'focus': focus,
            'preposition': preposition,
            'location': location,
          },
        );

  /// Get the full quest sentence.
  String get questSentence =>
      '$objective the $description $focus $preposition the $location';

  @override
  String toString() => 'Quest: $questSentence';
}
