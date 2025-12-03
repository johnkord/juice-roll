import '../core/roll_engine.dart';
import '../models/roll_result.dart';

/// Details generator preset for the Juice Oracle.
/// Uses details.md for colors, properties, and history.
class Details {
  final RollEngine _rollEngine;

  /// Colors - d10
  static const List<String> colors = [
    'Shade Black',       // 1
    'Leather Brown',     // 2
    'Highlight Yellow',  // 3
    'Forest Green',      // 4
    'Cobalt Blue',       // 5
    'Crimson Red',       // 6
    'Royal Violet',      // 7
    'Metallic Silver',   // 8
    'Midas Gold',        // 9
    'Holy White',        // 0/10
  ];

  /// Color emoji (for display)
  static const List<String> colorEmoji = [
    '⬛', // Black
    '🟫', // Brown
    '🟨', // Yellow
    '🟩', // Green
    '🟦', // Blue
    '🟥', // Red
    '🟪', // Violet
    '⬜', // Silver
    '🟨', // Gold
    '⬜', // White
  ];

  /// Properties - d10
  static const List<String> properties = [
    'Age',        // 1
    'Durability', // 2
    'Familiarity',// 3
    'Power',      // 4
    'Quality',    // 5
    'Rarity',     // 6
    'Size',       // 7
    'Style',      // 8
    'Value',      // 9
    'Weight',     // 0/10
  ];

  /// Detail modifiers - d10
  static const List<String> detailModifiers = [
    'Negative Emotion',  // 1
    'Disfavors PC',      // 2
    'Disfavors Thread',  // 3
    'Disfavors NPC',     // 4
    'History',           // 5 (italic - roll on history)
    'Property',          // 6 (italic - roll on property)
    'Favors NPC',        // 7
    'Favors Thread',     // 8
    'Favors PC',         // 9
    'Positive Emotion',  // 0/10
  ];

  /// History context - d10
  static const List<String> histories = [
    'Backstory',        // 1
    'Past Thread',      // 2
    'Previous Thread',  // 3
    'Past Scene',       // 4
    'Previous Scene',   // 5
    'Current Thread',   // 6
    'Past Action',      // 7
    'Current Scene',    // 8
    'Previous Action',  // 9
    'Current Action',   // 0/10
  ];

  Details([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  /// Roll for a color.
  DetailResult rollColor() {
    final roll = _rollEngine.rollDie(10);
    final index = roll == 10 ? 9 : roll - 1;
    final color = colors[index];
    final emoji = colorEmoji[index];

    return DetailResult(
      detailType: DetailType.color,
      roll: roll,
      result: color,
      emoji: emoji,
    );
  }

  /// Roll for a property with intensity (d10 + d6).
  PropertyResult rollProperty() {
    final propRoll = _rollEngine.rollDie(10);
    final intensityRoll = _rollEngine.rollDie(6);
    final index = propRoll == 10 ? 9 : propRoll - 1;
    final property = properties[index];

    return PropertyResult(
      propertyRoll: propRoll,
      property: property,
      intensityRoll: intensityRoll,
    );
  }

  /// Roll for a detail modifier.
  DetailResult rollDetail() {
    final roll = _rollEngine.rollDie(10);
    final index = roll == 10 ? 9 : roll - 1;
    final detail = detailModifiers[index];

    return DetailResult(
      detailType: DetailType.detail,
      roll: roll,
      result: detail,
    );
  }

  /// Roll for history context.
  DetailResult rollHistory() {
    final roll = _rollEngine.rollDie(10);
    final index = roll == 10 ? 9 : roll - 1;
    final history = histories[index];

    return DetailResult(
      detailType: DetailType.history,
      roll: roll,
      result: history,
    );
  }
}

/// Type of detail being rolled.
enum DetailType {
  color,
  property,
  detail,
  history,
}

extension DetailTypeDisplay on DetailType {
  String get displayText {
    switch (this) {
      case DetailType.color:
        return 'Color';
      case DetailType.property:
        return 'Property';
      case DetailType.detail:
        return 'Detail';
      case DetailType.history:
        return 'History';
    }
  }
}

/// Result of a detail roll.
class DetailResult extends RollResult {
  final DetailType detailType;
  final int roll;
  final String result;
  final String? emoji;

  DetailResult({
    required this.detailType,
    required this.roll,
    required this.result,
    this.emoji,
  }) : super(
          type: RollType.details,
          description: detailType.displayText,
          diceResults: [roll],
          total: roll,
          interpretation: emoji != null ? '$emoji $result' : result,
          metadata: {
            'detailType': detailType.name,
            'result': result,
            if (emoji != null) 'emoji': emoji,
          },
        );

  @override
  String toString() =>
      '${detailType.displayText}: ${emoji != null ? '$emoji ' : ''}$result';
}

/// Result of a property roll with intensity.
class PropertyResult extends RollResult {
  final int propertyRoll;
  final String property;
  final int intensityRoll;

  PropertyResult({
    required this.propertyRoll,
    required this.property,
    required this.intensityRoll,
  }) : super(
          type: RollType.details,
          description: 'Property',
          diceResults: [propertyRoll, intensityRoll],
          total: propertyRoll + intensityRoll,
          interpretation: '$property (${_intensityText(intensityRoll)})',
          metadata: {
            'property': property,
            'intensity': intensityRoll,
          },
        );

  static String _intensityText(int roll) {
    switch (roll) {
      case 1:
        return 'Minimal';
      case 2:
        return 'Minor';
      case 3:
        return 'Moderate';
      case 4:
        return 'Major';
      case 5:
        return 'Maximum';
      case 6:
        return 'Extreme';
      default:
        return 'Unknown';
    }
  }

  String get intensityDescription => _intensityText(intensityRoll);

  @override
  String toString() => 'Property: $property ($intensityDescription)';
}
