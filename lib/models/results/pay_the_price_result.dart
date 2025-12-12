import '../roll_result.dart';

/// Result of a Pay the Price roll.
/// Generates consequences using Ironsworn-style outcomes.
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
