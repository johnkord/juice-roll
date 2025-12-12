import '../roll_result.dart';
import 'details_result.dart' show SkewType;

/// Result of rolling Information (2d100: Type + Topic).
class InformationResult extends RollResult {
  final int typeRoll;
  final int topicRoll;
  final String informationType;
  final String topic;

  InformationResult({
    required this.typeRoll,
    required this.topicRoll,
    required this.informationType,
    required this.topic,
    DateTime? timestamp,
  }) : super(
          type: RollType.npcAction,
          description: 'NPC Information (2d100)',
          diceResults: [typeRoll, topicRoll],
          total: typeRoll + topicRoll,
          interpretation: '$informationType $topic',
          timestamp: timestamp,
          metadata: {
            'typeRoll': typeRoll,
            'topicRoll': topicRoll,
            'informationType': informationType,
            'topic': topic,
          },
        );

  @override
  String get className => 'InformationResult';

  factory InformationResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return InformationResult(
      typeRoll: meta['typeRoll'] as int? ?? diceResults[0],
      topicRoll: meta['topicRoll'] as int? ?? diceResults[1],
      informationType: meta['informationType'] as String,
      topic: meta['topic'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() => '$informationType $topic';
}

/// Result of rolling Companion Response (1d100).
class CompanionResponseResult extends RollResult {
  final int roll;
  final String response;
  final SkewType skew;
  final List<int> allRolls;

  CompanionResponseResult({
    required this.roll,
    required this.response,
    required this.skew,
    required this.allRolls,
    DateTime? timestamp,
  }) : super(
          type: RollType.npcAction,
          description: _buildDescription(skew),
          diceResults: allRolls,
          total: roll,
          interpretation: response,
          timestamp: timestamp,
          metadata: {
            'roll': roll,
            'response': response,
            'skew': skew.name,
            'favor': _getFavorLevel(roll),
          },
        );

  @override
  String get className => 'CompanionResponseResult';

  factory CompanionResponseResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return CompanionResponseResult(
      roll: meta['roll'] as int? ?? diceResults[0],
      response: meta['response'] as String,
      skew: SkewType.values.firstWhere(
        (s) => s.name == meta['skew'],
        orElse: () => SkewType.none,
      ),
      allRolls: diceResults,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  static String _buildDescription(SkewType skew) {
    switch (skew) {
      case SkewType.advantage:
        return 'Companion Response (1d100@+ In Favor)';
      case SkewType.disadvantage:
        return 'Companion Response (1d100@- Opposed)';
      case SkewType.none:
        return 'Companion Response (1d100)';
    }
  }

  static String _getFavorLevel(int roll) {
    if (roll <= 20) return 'Strongly Opposed';
    if (roll <= 40) return 'Hesitant';
    if (roll <= 60) return 'Neutral/Questioning';
    if (roll <= 80) return 'Cautious Support';
    return 'Strongly In Favor';
  }

  /// Get the favor level of the response
  String get favorLevel => _getFavorLevel(roll);

  @override
  String toString() => response;
}

/// Result of rolling Extended NPC Dialog Topic (1d100).
class DialogTopicResult extends RollResult {
  final int roll;
  final String topic;

  DialogTopicResult({
    required this.roll,
    required this.topic,
    DateTime? timestamp,
  }) : super(
          type: RollType.npcAction,
          description: 'Dialog Topic (1d100)',
          diceResults: [roll],
          total: roll,
          interpretation: topic,
          timestamp: timestamp,
          metadata: {
            'roll': roll,
            'topic': topic,
          },
        );

  @override
  String get className => 'DialogTopicResult';

  factory DialogTopicResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return DialogTopicResult(
      roll: meta['roll'] as int? ?? diceResults[0],
      topic: meta['topic'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() => topic;
}
