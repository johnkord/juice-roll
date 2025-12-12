import '../core/roll_engine.dart';
import '../data/interrupt_plot_point_data.dart' as data;

// Re-export result class for backward compatibility
export '../models/results/interrupt_plot_point_result.dart';

import '../models/results/interrupt_plot_point_result.dart';

/// Interrupt / Plot Point preset for the Juice Oracle.
/// Uses interrupt-plot-point.md for story interruptions.
class InterruptPlotPoint {
  final RollEngine _rollEngine;

  /// Categories (first d10 determines column) - mapped by ranges
  static Map<int, String> get categories => data.categories;

  /// Action events (1-2 column) - d10
  static List<String> get actionEvents => data.actionEvents;

  /// Tension events (3-4 column) - d10
  static List<String> get tensionEvents => data.tensionEvents;

  /// Mystery events (5-6 column) - d10
  static List<String> get mysteryEvents => data.mysteryEvents;

  /// Social events (7-8 column) - d10
  static List<String> get socialEvents => data.socialEvents;

  /// Personal events (9-0 column) - d10
  static List<String> get personalEvents => data.personalEvents;

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
