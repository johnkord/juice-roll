import '../core/roll_engine.dart';
import '../models/roll_result.dart';

/// Pay the Price preset for the Juice Oracle.
/// Determines consequences on failure using pay-the-price.md.
class PayThePrice {
  final RollEngine _rollEngine;

  /// Standard consequences - d10
  static const List<String> consequences = [
    'Action has Unintended Effect',       // 1
    'Current Situation Worsens',          // 2
    'Delayed / Disadvantaged',            // 3
    'Forced to Act Against Intentions',   // 4
    'New Danger / Foe Revealed',          // 5
    'Person / Community Exposed to Danger', // 6
    'Separated from Person / Thing',      // 7
    'Something of Value Lost / Destroyed', // 8
    'Surprise Complication',              // 9
    'Trusted Person Betrays You',         // 0/10
  ];

  /// Major plot twists (for critical failures) - d10
  static const List<String> majorTwists = [
    'Actions Benefit Enemy',            // 1
    'Assumption Is False',              // 2
    'Dark Secret Revealed',             // 3
    'Enemy Gains New Allies',           // 4
    'Enemy Shares a Common Goal',       // 5
    'It was all a Diversion',           // 6
    'Secret Alliance Revealed',         // 7
    'Someone Returns Unexpectedly',     // 8
    'Unrelated Situations Connected',   // 9
    'You are too late',                 // 0/10
  ];

  PayThePrice([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  /// Roll for a standard consequence.
  PayThePriceResult rollConsequence() {
    final roll = _rollEngine.rollDie(10);
    final index = roll == 10 ? 9 : roll - 1;
    final consequence = consequences[index];

    return PayThePriceResult(
      isMajorTwist: false,
      roll: roll,
      result: consequence,
    );
  }

  /// Roll for a major plot twist (critical failure).
  PayThePriceResult rollMajorTwist() {
    final roll = _rollEngine.rollDie(10);
    final index = roll == 10 ? 9 : roll - 1;
    final twist = majorTwists[index];

    return PayThePriceResult(
      isMajorTwist: true,
      roll: roll,
      result: twist,
    );
  }

  /// Roll with automatic major twist on doubles or critical.
  /// Pass the skill check dice to determine if it was a critical fail.
  PayThePriceResult rollWithCriticalCheck({bool isCriticalFail = false}) {
    if (isCriticalFail) {
      return rollMajorTwist();
    }
    return rollConsequence();
  }
}

/// Result of a Pay the Price roll.
class PayThePriceResult extends RollResult {
  final bool isMajorTwist;
  final int roll;
  final String result;

  PayThePriceResult({
    required this.isMajorTwist,
    required this.roll,
    required this.result,
    DateTime? timestamp,
  }) : super(
          type: RollType.payThePrice,
          description: isMajorTwist ? 'Major Plot Twist' : 'Pay the Price',
          diceResults: [roll],
          total: roll,
          interpretation: result,
          timestamp: timestamp,
          metadata: {
            'isMajorTwist': isMajorTwist,
            'result': result,
            'roll': roll,
          },
        );

  @override
  String get className => 'PayThePriceResult';

  factory PayThePriceResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    return PayThePriceResult(
      isMajorTwist: meta['isMajorTwist'] as bool? ?? false,
      roll: meta['roll'] as int? ?? (json['diceResults'] as List).first as int,
      result: meta['result'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() =>
      isMajorTwist ? 'Major Plot Twist: $result' : 'Pay the Price: $result';
}
