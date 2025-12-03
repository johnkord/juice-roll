import '../core/roll_engine.dart';
import '../models/roll_result.dart';

/// Challenge generator preset for the Juice Oracle.
/// Uses random-event-challenge.md for skill challenges and DCs.
class Challenge {
  final RollEngine _rollEngine;

  /// Physical challenges - d10
  static const List<String> physicalChallenges = [
    'Medicine',        // 1
    'Survival',        // 2
    'Animal Handling', // 3
    'Performance',     // 4
    'Intimidation',    // 5
    'Perception',      // 6
    'Sleight of Hand', // 7
    'Stealth',         // 8
    'Acrobatics',      // 9
    'Athletics',       // 0/10
  ];

  /// Mental challenges - d10
  static const List<String> mentalChallenges = [
    'Tool',        // 1
    'Nature',      // 2
    'Investigate', // 3
    'Persuasion',  // 4
    'Deception',   // 5
    'Language',    // 6
    'Religion',    // 7
    'Arcana',      // 8
    'History',     // 9
    'Insight',     // 0/10
  ];

  /// DC values (corresponds to d10 roll) - from the table
  static const List<int> dcValues = [
    17, // 1
    16, // 2
    15, // 3
    14, // 4
    13, // 5
    12, // 6
    11, // 7
    10, // 8
    9,  // 9
    8,  // 0/10
  ];

  /// Percentage chance ranges (corresponds to d10 roll) - from the table
  /// Format: [min, max] for each row
  static const List<List<int>> percentageRanges = [
    [1, 2],    // 1
    [3, 8],    // 2
    [9, 18],   // 3
    [19, 33],  // 4
    [34, 50],  // 5
    [51, 67],  // 6
    [68, 82],  // 7
    [83, 92],  // 8
    [93, 98],  // 9
    [99, 100], // 0/10
  ];

  Challenge([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  /// Generate a quick DC (2d6+6).
  QuickDcResult rollQuickDc() {
    final dice = _rollEngine.rollDice(2, 6);
    final sum = dice.reduce((a, b) => a + b);
    final dc = sum + 6;

    return QuickDcResult(
      dice: dice,
      rawSum: sum,
      dc: dc,
    );
  }

  /// Roll for a physical challenge skill.
  ChallengeSkillResult rollPhysicalChallenge() {
    final roll = _rollEngine.rollDie(10);
    final index = roll == 10 ? 9 : roll - 1;
    final skill = physicalChallenges[index];
    final dc = dcValues[index];

    return ChallengeSkillResult(
      challengeType: ChallengeType.physical,
      roll: roll,
      skill: skill,
      suggestedDc: dc,
    );
  }

  /// Roll for a mental challenge skill.
  ChallengeSkillResult rollMentalChallenge() {
    final roll = _rollEngine.rollDie(10);
    final index = roll == 10 ? 9 : roll - 1;
    final skill = mentalChallenges[index];
    final dc = dcValues[index];

    return ChallengeSkillResult(
      challengeType: ChallengeType.mental,
      roll: roll,
      skill: skill,
      suggestedDc: dc,
    );
  }

  /// Roll for any challenge (50/50 physical vs mental).
  ChallengeSkillResult rollAnyChallenge() {
    final typeRoll = _rollEngine.rollDie(2);
    if (typeRoll == 1) {
      return rollPhysicalChallenge();
    } else {
      return rollMentalChallenge();
    }
  }

  /// Roll for a percentage chance (d10 → % range).
  /// Use this to determine what % chance something has of occurring.
  PercentageChanceResult rollPercentageChance() {
    final roll = _rollEngine.rollDie(10);
    final index = roll == 10 ? 9 : roll - 1;
    final range = percentageRanges[index];
    final minPercent = range[0];
    final maxPercent = range[1];
    
    // Use midpoint as the representative percentage
    final percent = ((minPercent + maxPercent) / 2).round();

    return PercentageChanceResult(
      roll: roll,
      minPercent: minPercent,
      maxPercent: maxPercent,
      percent: percent,
    );
  }
}

/// Type of challenge.
enum ChallengeType {
  physical,
  mental,
}

extension ChallengeTypeDisplay on ChallengeType {
  String get displayText {
    switch (this) {
      case ChallengeType.physical:
        return 'Physical';
      case ChallengeType.mental:
        return 'Mental';
    }
  }
}

/// Result of a Quick DC roll.
class QuickDcResult extends RollResult {
  final List<int> dice;
  final int rawSum;
  final int dc;

  QuickDcResult({
    required this.dice,
    required this.rawSum,
    required this.dc,
  }) : super(
          type: RollType.challenge,
          description: 'Quick DC',
          diceResults: dice,
          total: dc,
          interpretation: 'DC $dc',
          metadata: {
            'rawSum': rawSum,
            'dc': dc,
          },
        );

  @override
  String toString() => 'Quick DC: $dc (${dice.join('+')}+6)';
}

/// Result of a challenge skill roll.
class ChallengeSkillResult extends RollResult {
  final ChallengeType challengeType;
  final int roll;
  final String skill;
  final int suggestedDc;

  ChallengeSkillResult({
    required this.challengeType,
    required this.roll,
    required this.skill,
    required this.suggestedDc,
  }) : super(
          type: RollType.challenge,
          description: '${challengeType.displayText} Challenge',
          diceResults: [roll],
          total: roll,
          interpretation: '$skill (DC $suggestedDc)',
          metadata: {
            'challengeType': challengeType.name,
            'skill': skill,
            'suggestedDc': suggestedDc,
          },
        );

  @override
  String toString() =>
      '${challengeType.displayText} Challenge: $skill (DC $suggestedDc)';
}

/// Result of a percentage chance roll.
class PercentageChanceResult extends RollResult {
  final int roll;
  final int minPercent;
  final int maxPercent;
  final int percent;

  PercentageChanceResult({
    required this.roll,
    required this.minPercent,
    required this.maxPercent,
    required this.percent,
  }) : super(
          type: RollType.challenge,
          description: '% Chance',
          diceResults: [roll],
          total: percent,
          interpretation: '$minPercent-$maxPercent%',
          metadata: {
            'roll': roll,
            'minPercent': minPercent,
            'maxPercent': maxPercent,
            'percent': percent,
          },
        );

  /// Get a readable description of the chance.
  String get chanceDescription {
    if (percent <= 5) return 'Very Unlikely';
    if (percent <= 20) return 'Unlikely';
    if (percent <= 40) return 'Possible';
    if (percent <= 60) return 'Even Odds';
    if (percent <= 80) return 'Likely';
    if (percent <= 95) return 'Very Likely';
    return 'Almost Certain';
  }

  @override
  String toString() => '% Chance: $minPercent-$maxPercent% ($chanceDescription)';
}
