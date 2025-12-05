import '../core/roll_engine.dart';
import '../models/roll_result.dart';

/// Discover Meaning preset for the Juice Oracle.
/// Generates two-word prompts for open interpretation.
/// Uses the Meaning Tables from meaning-name-generator.md.
class DiscoverMeaning {
  final RollEngine _rollEngine;

  /// Adjective words (column 1) - d20
  static const List<String> adjectives = [
    'Ancient',      // 1
    'Betray',       // 2
    'Conceal',      // 3
    'Dangerous',    // 4
    'Helpful',      // 5
    'Loud',         // 6
    'Powerful',     // 7
    'Reveal',       // 8
    'Transform',    // 9
    'Unexpected',   // 10
    'Artificial',   // 11
    'Burning',      // 12
    'Communicate',  // 13
    'Deceive',      // 14
    'Dirty',        // 15
    'Disagreeable', // 16
    'Oppose',       // 17
    'Peaceful',     // 18
    'Reassuring',   // 19
    'Specialized',  // 20
  ];

  /// Noun words (column 2) - d20
  static const List<String> nouns = [
    'Burden',      // 1
    'Complexity',  // 2
    'Conflict',    // 3
    'Control',     // 4
    'Direction',   // 5
    'Happiness',   // 6
    'Memory',      // 7
    'Move',        // 8
    'Shadow',      // 9
    'Trust',       // 10
    'Assist',      // 11
    'Break',       // 12
    'Command',     // 13
    'Delay',       // 14
    'Duration',    // 15
    'Failure',     // 16
    'Fight',       // 17
    'Leave',       // 18
    'Sacrifice',   // 19
    'Threshold',   // 20
  ];

  DiscoverMeaning([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  /// Generate a meaning phrase (Adjective + Noun).
  DiscoverMeaningResult generate() {
    final adjRoll = _rollEngine.rollDie(20);
    final nounRoll = _rollEngine.rollDie(20);

    final adjective = adjectives[adjRoll - 1];
    final noun = nouns[nounRoll - 1];

    return DiscoverMeaningResult(
      adjectiveRoll: adjRoll,
      adjective: adjective,
      nounRoll: nounRoll,
      noun: noun,
    );
  }
}

/// Result of a Discover Meaning roll.
class DiscoverMeaningResult extends RollResult {
  final int adjectiveRoll;
  final String adjective;
  final int nounRoll;
  final String noun;

  DiscoverMeaningResult({
    required this.adjectiveRoll,
    required this.adjective,
    required this.nounRoll,
    required this.noun,
    DateTime? timestamp,
  }) : super(
          type: RollType.discoverMeaning,
          description: 'Discover Meaning',
          diceResults: [adjectiveRoll, nounRoll],
          total: adjectiveRoll + nounRoll,
          interpretation: '$adjective $noun',
          timestamp: timestamp,
          metadata: {
            'adjective': adjective,
            'noun': noun,
            'adjectiveRoll': adjectiveRoll,
            'nounRoll': nounRoll,
          },
        );

  @override
  String get className => 'DiscoverMeaningResult';

  factory DiscoverMeaningResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return DiscoverMeaningResult(
      adjectiveRoll: meta['adjectiveRoll'] as int? ?? diceResults[0],
      adjective: meta['adjective'] as String,
      nounRoll: meta['nounRoll'] as int? ?? diceResults[1],
      noun: meta['noun'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  String get meaning => '$adjective $noun';

  @override
  String toString() => 'Discover Meaning: $adjective $noun';
}
