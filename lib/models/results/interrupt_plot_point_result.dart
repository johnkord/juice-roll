import '../roll_result.dart';

/// Result of an Interrupt/Plot Point roll.
/// Uses a category (Action, Tension, Mystery, Social, Personal)
/// and an event from that category's table.
class InterruptPlotPointResult extends RollResult {
  final int categoryRoll;
  final String category;
  final int eventRoll;
  final String event;

  InterruptPlotPointResult({
    required this.categoryRoll,
    required this.category,
    required this.eventRoll,
    required this.event,
    DateTime? timestamp,
  }) : super(
          type: RollType.interruptPlotPoint,
          description: 'Interrupt / Plot Point',
          diceResults: [categoryRoll, eventRoll],
          total: categoryRoll + eventRoll,
          interpretation: '$category: $event',
          timestamp: timestamp,
          metadata: {
            'category': category,
            'event': event,
            'categoryRoll': categoryRoll,
            'eventRoll': eventRoll,
          },
        );

  @override
  String get className => 'InterruptPlotPointResult';

  factory InterruptPlotPointResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return InterruptPlotPointResult(
      categoryRoll: meta['categoryRoll'] as int? ?? diceResults[0],
      category: meta['category'] as String,
      eventRoll: meta['eventRoll'] as int? ?? diceResults[1],
      event: meta['event'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() => 'Interrupt ($category): $event';
}
