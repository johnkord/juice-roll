import '../roll_result.dart';

/// Result of a Discover Meaning roll.
/// Uses adjective + noun tables (d100 each) to generate evocative phrases.
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
            'adjectiveRoll': adjectiveRoll,
            'noun': noun,
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

  /// Get the full meaning phrase
  String get phrase => '$adjective $noun';

  /// Get the full meaning phrase (alias for phrase)
  String get meaning => '$adjective $noun';

  @override
  String toString() => 'Meaning: $phrase';
}
