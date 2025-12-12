import '../roll_result.dart';

/// Advantage type for skewing rolls.
enum DcSkew {
  none,
  advantage,    // Easy - lower DC
  disadvantage, // Hard - higher DC
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

/// Result of a Full Challenge roll (both physical and mental with independent DCs).
/// Core challenge mechanic: PC must pass ONE of these, otherwise Pay The Price.
/// 
/// Per the Challenge Procedure:
/// - Each challenge has its own DC (not shared)
/// - One physical, one mental = two different paths forward
/// - Failing one may lock out the other option
/// - The difficulty of the challenge indicates the risk vs reward
class FullChallengeResult extends RollResult {
  final int physicalRoll;
  final String physicalSkill;
  final int physicalDc;
  final int mentalRoll;
  final String mentalSkill;
  final int mentalDc;
  final String dcMethod;

  FullChallengeResult({
    required this.physicalRoll,
    required this.physicalSkill,
    required this.physicalDc,
    required this.mentalRoll,
    required this.mentalSkill,
    required this.mentalDc,
    required this.dcMethod,
    DateTime? timestamp,
  }) : super(
          type: RollType.challenge,
          description: 'Challenge',
          diceResults: [physicalRoll, mentalRoll],
          total: physicalDc + mentalDc,
          interpretation: '$physicalSkill (DC $physicalDc) OR $mentalSkill (DC $mentalDc)',
          timestamp: timestamp,
          metadata: {
            'physicalSkill': physicalSkill,
            'physicalRoll': physicalRoll,
            'physicalDc': physicalDc,
            'mentalSkill': mentalSkill,
            'mentalRoll': mentalRoll,
            'mentalDc': mentalDc,
            'dcMethod': dcMethod,
          },
        );

  @override
  String get className => 'FullChallengeResult';

  factory FullChallengeResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return FullChallengeResult(
      physicalRoll: meta['physicalRoll'] as int? ?? diceResults[0],
      physicalSkill: meta['physicalSkill'] as String,
      physicalDc: meta['physicalDc'] as int,
      mentalRoll: meta['mentalRoll'] as int? ?? diceResults[1],
      mentalSkill: meta['mentalSkill'] as String,
      mentalDc: meta['mentalDc'] as int,
      dcMethod: meta['dcMethod'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() =>
      'Challenge: $physicalSkill (DC $physicalDc) or $mentalSkill (DC $mentalDc) via $dcMethod';
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
    DateTime? timestamp,
  }) : super(
          type: RollType.challenge,
          description: 'DC',
          diceResults: [roll],
          total: dc,
          interpretation: 'DC $dc ($method)',
          timestamp: timestamp,
          metadata: {
            'roll': roll,
            'dc': dc,
            'method': method,
          },
        );

  @override
  String get className => 'DcResult';

  factory DcResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    return DcResult(
      roll: meta['roll'] as int,
      dc: meta['dc'] as int,
      method: meta['method'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

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
    DateTime? timestamp,
  }) : super(
          type: RollType.challenge,
          description: 'Quick DC',
          diceResults: dice,
          total: dc,
          interpretation: 'DC $dc',
          timestamp: timestamp,
          metadata: {
            'dice': dice,
            'rawSum': rawSum,
            'dc': dc,
          },
        );

  @override
  String get className => 'QuickDcResult';

  factory QuickDcResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return QuickDcResult(
      dice: (meta['dice'] as List?)?.cast<int>() ?? diceResults,
      rawSum: meta['rawSum'] as int,
      dc: meta['dc'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

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
    DateTime? timestamp,
  }) : super(
          type: RollType.challenge,
          description: '${challengeType.displayText} Challenge',
          diceResults: [roll],
          total: roll,
          interpretation: '$skill (DC $suggestedDc)',
          timestamp: timestamp,
          metadata: {
            'challengeType': challengeType.name,
            'roll': roll,
            'skill': skill,
            'suggestedDc': suggestedDc,
          },
        );

  @override
  String get className => 'ChallengeSkillResult';

  factory ChallengeSkillResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    return ChallengeSkillResult(
      challengeType: ChallengeType.values.firstWhere(
        (e) => e.name == (meta['challengeType'] as String),
        orElse: () => ChallengeType.physical,
      ),
      roll: meta['roll'] as int,
      skill: meta['skill'] as String,
      suggestedDc: meta['suggestedDc'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

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

  @override
  String get className => 'PercentageChanceResult';

  /// Serialization - keep in sync with fromJson below.
  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'metadata': {
      'roll': roll,
      'minPercent': minPercent,
      'maxPercent': maxPercent,
      'percent': percent,
    },
  };

  /// Deserialization - keep in sync with toJson above.
  factory PercentageChanceResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    return PercentageChanceResult(
      roll: meta['roll'] as int,
      minPercent: meta['minPercent'] as int,
      maxPercent: meta['maxPercent'] as int,
      percent: meta['percent'] as int,
    );
  }
}
