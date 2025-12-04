import '../core/roll_engine.dart';
import '../models/roll_result.dart';

/// Advantage type for skewing rolls.
enum DcSkew {
  none,
  advantage,    // Easy - lower DC
  disadvantage, // Hard - higher DC
}

/// Challenge generator preset for the Juice Oracle.
/// Uses random-event-challenge.md for skill challenges and DCs.
/// 
/// Core concept: Roll a physical challenge and a mental challenge, 
/// then create a situation where these challenges make sense.
/// PC must pass only one; otherwise, Pay The Price.
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
  /// Row 1 = DC 17, Row 0/10 = DC 8
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

  /// Percentage chance ranges (corresponds to d100 roll) - for Balanced DC
  /// These form a bell curve weighting toward the middle DCs.
  static const List<List<int>> percentageRanges = [
    [1, 2],    // 1 -> DC 17
    [3, 8],    // 2 -> DC 16
    [9, 18],   // 3 -> DC 15
    [19, 33],  // 4 -> DC 14
    [34, 50],  // 5 -> DC 13
    [51, 67],  // 6 -> DC 12
    [68, 82],  // 7 -> DC 11
    [83, 92],  // 8 -> DC 10
    [93, 98],  // 9 -> DC 9
    [99, 100], // 0/10 -> DC 8
  ];

  Challenge([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  /// Generate a FULL CHALLENGE: both physical and mental skills with DCs.
  /// This is the core challenge mechanic from the Juice instructions.
  /// PC must pass only ONE of these; otherwise, Pay The Price.
  FullChallengeResult rollFullChallenge({DcSkew dcSkew = DcSkew.none}) {
    // Roll physical challenge
    final physicalRoll = _rollEngine.rollDie(10);
    final physicalIndex = physicalRoll == 10 ? 9 : physicalRoll - 1;
    final physicalSkill = physicalChallenges[physicalIndex];

    // Roll mental challenge
    final mentalRoll = _rollEngine.rollDie(10);
    final mentalIndex = mentalRoll == 10 ? 9 : mentalRoll - 1;
    final mentalSkill = mentalChallenges[mentalIndex];

    // Roll DC with optional skew
    final dcResult = rollDc(skew: dcSkew);

    return FullChallengeResult(
      physicalRoll: physicalRoll,
      physicalSkill: physicalSkill,
      mentalRoll: mentalRoll,
      mentalSkill: mentalSkill,
      dc: dcResult.dc,
      dcMethod: dcResult.method,
    );
  }

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

  /// Roll for a DC using 1d10 with optional advantage/disadvantage.
  /// - Advantage (Easy): Take lower of 2d10 -> lower DC
  /// - Disadvantage (Hard): Take higher of 2d10 -> higher DC
  DcResult rollDc({DcSkew skew = DcSkew.none}) {
    int roll;
    String method;

    switch (skew) {
      case DcSkew.advantage:
        // Easy: roll 2d10, take lower (lower index = higher DC, but we want lower DC)
        // Actually, lower roll = higher index in the DC table = lower DC value
        final roll1 = _rollEngine.rollDie(10);
        final roll2 = _rollEngine.rollDie(10);
        // Take higher roll for lower DC
        roll = roll1 > roll2 ? roll1 : roll2;
        method = 'Easy (1d10@+)';
      case DcSkew.disadvantage:
        // Hard: roll 2d10, take higher (higher index = lower DC, but we want higher DC)
        // Take lower roll for higher DC
        final roll1 = _rollEngine.rollDie(10);
        final roll2 = _rollEngine.rollDie(10);
        roll = roll1 < roll2 ? roll1 : roll2;
        method = 'Hard (1d10@-)';
      case DcSkew.none:
        roll = _rollEngine.rollDie(10);
        method = 'Random (1d10)';
    }

    final index = roll == 10 ? 9 : roll - 1;
    final dc = dcValues[index];

    return DcResult(
      roll: roll,
      dc: dc,
      method: method,
    );
  }

  /// Roll for a Balanced DC using d100 bell curve.
  /// Weights toward middle DCs (10-14).
  DcResult rollBalancedDc() {
    final d100 = _rollEngine.rollDie(100);
    
    // Find which range the roll falls into
    int index = 0;
    for (int i = 0; i < percentageRanges.length; i++) {
      if (d100 >= percentageRanges[i][0] && d100 <= percentageRanges[i][1]) {
        index = i;
        break;
      }
    }

    final dc = dcValues[index];

    return DcResult(
      roll: d100,
      dc: dc,
      method: 'Balanced (1d100)',
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

/// Result of a Full Challenge roll (both physical and mental).
/// Core challenge mechanic: PC must pass ONE of these, otherwise Pay The Price.
class FullChallengeResult extends RollResult {
  final int physicalRoll;
  final String physicalSkill;
  final int mentalRoll;
  final String mentalSkill;
  final int dc;
  final String dcMethod;

  FullChallengeResult({
    required this.physicalRoll,
    required this.physicalSkill,
    required this.mentalRoll,
    required this.mentalSkill,
    required this.dc,
    required this.dcMethod,
  }) : super(
          type: RollType.challenge,
          description: 'Challenge',
          diceResults: [physicalRoll, mentalRoll],
          total: dc,
          interpretation: '$physicalSkill OR $mentalSkill (DC $dc)',
          metadata: {
            'physicalSkill': physicalSkill,
            'mentalSkill': mentalSkill,
            'dc': dc,
            'dcMethod': dcMethod,
          },
        );

  @override
  String toString() =>
      'Challenge: $physicalSkill or $mentalSkill (DC $dc via $dcMethod)';
}

/// Result of a DC roll.
class DcResult extends RollResult {
  final int roll;
  final int dc;
  final String method;

  DcResult({
    required this.roll,
    required this.dc,
    required this.method,
  }) : super(
          type: RollType.challenge,
          description: 'DC',
          diceResults: [roll],
          total: dc,
          interpretation: 'DC $dc ($method)',
          metadata: {
            'roll': roll,
            'dc': dc,
            'method': method,
          },
        );

  @override
  String toString() => 'DC $dc ($method)';
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
