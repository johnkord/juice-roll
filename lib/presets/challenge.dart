import '../core/roll_engine.dart';
import '../data/challenge_data.dart' as data;

// Re-export result classes for backward compatibility
export '../models/results/challenge_result.dart'
    show DcSkew, ChallengeType, ChallengeTypeDisplay, FullChallengeResult, DcResult, QuickDcResult, ChallengeSkillResult, PercentageChanceResult;

// Import result classes for internal use
import '../models/results/challenge_result.dart';

/// Challenge generator preset for the Juice Oracle.
/// Uses random-event-challenge.md for skill challenges and DCs.
/// 
/// Core concept: Roll a physical challenge and a mental challenge, 
/// then create a situation where these challenges make sense.
/// PC must pass only one; otherwise, Pay The Price.
class Challenge {
  final RollEngine _rollEngine;

  /// Physical challenges - d10
  static List<String> get physicalChallenges => data.physicalChallenges;

  /// Mental challenges - d10
  static List<String> get mentalChallenges => data.mentalChallenges;

  /// DC values (corresponds to d10 roll) - from the table
  /// Row 1 = DC 17, Row 0/10 = DC 8
  static List<int> get dcValues => data.dcValues;

  /// Percentage chance ranges (corresponds to d100 roll) - for Balanced DC
  /// These form a bell curve weighting toward the middle DCs.
  static List<List<int>> get percentageRanges => data.percentageRanges;

  Challenge([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  /// Generate a FULL CHALLENGE: both physical and mental skills with independent DCs.
  /// This is the core challenge mechanic from the Juice instructions.
  /// PC must pass only ONE of these; otherwise, Pay The Price.
  /// 
  /// Per the Challenge Procedure:
  /// 1. Roll 1 Physical + 1 Mental challenge
  /// 2. Roll a DC for EACH challenge (independently)
  /// 3. Combine with current context to create a scene
  /// 4. PC chooses which path to attempt
  /// 5. Fail = Pay The Price
  FullChallengeResult rollFullChallenge({DcSkew dcSkew = DcSkew.none}) {
    // Roll physical challenge
    final physicalRoll = _rollEngine.rollDie(10);
    final physicalIndex = physicalRoll == 10 ? 9 : physicalRoll - 1;
    final physicalSkill = physicalChallenges[physicalIndex];
    
    // Roll DC for physical challenge
    final physicalDcResult = rollDc(skew: dcSkew);

    // Roll mental challenge
    final mentalRoll = _rollEngine.rollDie(10);
    final mentalIndex = mentalRoll == 10 ? 9 : mentalRoll - 1;
    final mentalSkill = mentalChallenges[mentalIndex];
    
    // Roll DC for mental challenge (independent from physical)
    final mentalDcResult = rollDc(skew: dcSkew);

    return FullChallengeResult(
      physicalRoll: physicalRoll,
      physicalSkill: physicalSkill,
      physicalDc: physicalDcResult.dc,
      mentalRoll: mentalRoll,
      mentalSkill: mentalSkill,
      mentalDc: mentalDcResult.dc,
      dcMethod: physicalDcResult.method, // Same method for both
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

