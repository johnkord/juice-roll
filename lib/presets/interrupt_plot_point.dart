import '../core/roll_engine.dart';
import '../models/roll_result.dart';

/// Interrupt / Plot Point preset for the Juice Oracle.
/// Uses interrupt-plot-point.md for story interruptions.
class InterruptPlotPoint {
  final RollEngine _rollEngine;

  /// Categories (first d10 determines column) - mapped by ranges
  static const Map<int, String> categories = {
    1: 'Action',
    2: 'Action',
    3: 'Tension',
    4: 'Tension',
    5: 'Mystery',
    6: 'Mystery',
    7: 'Social',
    8: 'Social',
    9: 'Personal',
    0: 'Personal', // 10 = 0
  };

  /// Action events (1-2 column) - d10
  static const List<String> actionEvents = [
    'Abduction',    // 1
    'Barrier',      // 2
    'Battle',       // 3
    'Chase',        // 4
    'Collateral',   // 5
    'Crash',        // 6
    'Culmination',  // 7
    'Distraction',  // 8
    'Harm',         // 9
    'Intensify',    // 0/10
  ];

  /// Tension events (3-4 column) - d10
  static const List<String> tensionEvents = [
    'Choice',       // 1
    'Depletion',    // 2
    'Enemy',        // 3
    'Intimidation', // 4
    'Night',        // 5
    'Public',       // 6
    'Recurrence',   // 7
    'Remote',       // 8
    'Shady',        // 9
    'Trapped',      // 0/10
  ];

  /// Mystery events (5-6 column) - d10
  static const List<String> mysteryEvents = [
    'Alternate',     // 1
    'Behavior',      // 2
    'Connected',     // 3
    'Information',   // 4
    'Intercept',     // 5
    'Lucky',         // 6
    'Reappearance',  // 7
    'Revelation',    // 8
    'Secret',        // 9
    'Source',        // 0/10
  ];

  /// Social events (7-8 column) - d10
  static const List<String> socialEvents = [
    'Agreement',      // 1
    'Gathering',      // 2
    'Government',     // 3
    'Inadequate',     // 4
    'Injustice',      // 5
    'Misbehave',      // 6
    'Outcast',        // 7
    'Outside',        // 8
    'Reinforcements', // 9
    'Savior',         // 0/10
  ];

  /// Personal events (9-0 column) - d10
  static const List<String> personalEvents = [
    'Animosity',   // 1
    'Connection',  // 2
    'Dependent',   // 3
    'Ethical',     // 4
    'Flee',        // 5
    'Friend',      // 6
    'Help',        // 7
    'Home',        // 8
    'Humiliation', // 9
    'Offer',       // 0/10
  ];

  InterruptPlotPoint([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  /// Generate an interrupt/plot point (2d10).
  InterruptPlotPointResult generate() {
    final categoryRoll = _rollEngine.rollDie(10);
    final eventRoll = _rollEngine.rollDie(10);

    // Determine category
    final categoryKey = categoryRoll == 10 ? 0 : categoryRoll;
    final category = categories[categoryKey] ?? 'Action';

    // Get event from appropriate list
    final eventIndex = eventRoll == 10 ? 9 : eventRoll - 1;
    String event;
    switch (category) {
      case 'Action':
        event = actionEvents[eventIndex];
        break;
      case 'Tension':
        event = tensionEvents[eventIndex];
        break;
      case 'Mystery':
        event = mysteryEvents[eventIndex];
        break;
      case 'Social':
        event = socialEvents[eventIndex];
        break;
      case 'Personal':
        event = personalEvents[eventIndex];
        break;
      default:
        event = actionEvents[eventIndex];
    }

    return InterruptPlotPointResult(
      categoryRoll: categoryRoll,
      category: category,
      eventRoll: eventRoll,
      event: event,
    );
  }
}

/// Result of an Interrupt/Plot Point roll.
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
