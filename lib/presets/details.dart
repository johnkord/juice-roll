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

  /// Roll for TWO properties with intensity (d10 + d6 each).
  /// Per instructions: "Roll 1d10 to pick a property, then 1d6 to pick an intensity. Do this twice."
  DualPropertyResult rollTwoProperties() {
    final prop1 = rollProperty();
    final prop2 = rollProperty();
    return DualPropertyResult(property1: prop1, property2: prop2);
  }

  /// Roll for a detail modifier with optional skew.
  /// Advantage: More positive outcomes (Favors PC, Thread, NPC, Positive Emotion)
  /// Disadvantage: More negative outcomes (Disfavors PC, Thread, NPC, Negative Emotion)
  /// 
  /// Note: If result is "History" or "Property", use rollDetailWithFollowUp() 
  /// to automatically roll on those tables.
  DetailResult rollDetail({SkewType skew = SkewType.none}) {
    int roll;
    int? secondRoll;
    
    if (skew == SkewType.advantage) {
      final result = _rollEngine.rollWithAdvantage(1, 10);
      roll = result.chosenSum;
      secondRoll = result.sum2;
    } else if (skew == SkewType.disadvantage) {
      final result = _rollEngine.rollWithDisadvantage(1, 10);
      roll = result.chosenSum;
      secondRoll = result.sum2;
    } else {
      roll = _rollEngine.rollDie(10);
    }
    
    final index = roll == 10 ? 9 : roll - 1;
    final detail = detailModifiers[index];

    return DetailResult(
      detailType: DetailType.detail,
      roll: roll,
      secondRoll: secondRoll,
      result: detail,
      skew: skew,
      requiresFollowUp: detail == 'History' || detail == 'Property',
    );
  }

  /// Roll for a detail modifier with automatic follow-up for History/Property.
  /// 
  /// When the result is "History" or "Property", automatically rolls on
  /// the respective table and includes the result.
  DetailWithFollowUpResult rollDetailWithFollowUp({SkewType skew = SkewType.none}) {
    final detailResult = rollDetail(skew: skew);
    
    DetailResult? historyResult;
    PropertyResult? propertyResult;
    
    if (detailResult.result == 'History') {
      historyResult = rollHistory();
    } else if (detailResult.result == 'Property') {
      propertyResult = rollProperty();
    }
    
    return DetailWithFollowUpResult(
      detailResult: detailResult,
      historyResult: historyResult,
      propertyResult: propertyResult,
    );
  }

  /// Roll for history context with optional skew.
  /// Advantage: Closer to the present
  /// Disadvantage: Further into the past
  DetailResult rollHistory({SkewType skew = SkewType.none}) {
    int roll;
    int? secondRoll;
    
    if (skew == SkewType.advantage) {
      final result = _rollEngine.rollWithAdvantage(1, 10);
      roll = result.chosenSum;
      secondRoll = result.sum2;
    } else if (skew == SkewType.disadvantage) {
      final result = _rollEngine.rollWithDisadvantage(1, 10);
      roll = result.chosenSum;
      secondRoll = result.sum2;
    } else {
      roll = _rollEngine.rollDie(10);
    }
    
    final index = roll == 10 ? 9 : roll - 1;
    final history = histories[index];

    return DetailResult(
      detailType: DetailType.history,
      roll: roll,
      secondRoll: secondRoll,
      result: history,
      skew: skew,
    );
  }
}

/// Skew type for rolls
enum SkewType {
  none,
  advantage,
  disadvantage,
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
  final int? secondRoll;
  final String result;
  final String? emoji;
  final SkewType skew;
  final bool requiresFollowUp;

  DetailResult({
    required this.detailType,
    required this.roll,
    this.secondRoll,
    required this.result,
    this.emoji,
    this.skew = SkewType.none,
    this.requiresFollowUp = false,
    DateTime? timestamp,
  }) : super(
          type: RollType.details,
          description: detailType.displayText,
          diceResults: secondRoll != null ? [roll, secondRoll] : [roll],
          total: roll,
          interpretation: emoji != null ? '$emoji $result' : result,
          timestamp: timestamp,
          metadata: {
            'detailType': detailType.name,
            'result': result,
            'roll': roll,
            if (secondRoll != null) 'secondRoll': secondRoll,
            if (emoji != null) 'emoji': emoji,
            if (skew != SkewType.none) 'skew': skew.name,
            'requiresFollowUp': requiresFollowUp,
          },
        );

  @override
  String get className => 'DetailResult';

  factory DetailResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return DetailResult(
      detailType: DetailType.values.firstWhere(
        (e) => e.name == (meta['detailType'] as String),
        orElse: () => DetailType.detail,
      ),
      roll: meta['roll'] as int? ?? diceResults.first,
      secondRoll: meta['secondRoll'] as int?,
      result: meta['result'] as String,
      emoji: meta['emoji'] as String?,
      skew: meta['skew'] != null 
          ? SkewType.values.firstWhere((e) => e.name == meta['skew'])
          : SkewType.none,
      requiresFollowUp: meta['requiresFollowUp'] as bool? ?? false,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

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
    DateTime? timestamp,
  }) : super(
          type: RollType.details,
          description: 'Property',
          diceResults: [propertyRoll, intensityRoll],
          total: propertyRoll + intensityRoll,
          interpretation: '$property (${_intensityText(intensityRoll)})',
          timestamp: timestamp,
          metadata: {
            'property': property,
            'propertyRoll': propertyRoll,
            'intensity': intensityRoll,
          },
        );

  @override
  String get className => 'PropertyResult';

  factory PropertyResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return PropertyResult(
      propertyRoll: meta['propertyRoll'] as int? ?? diceResults[0],
      property: meta['property'] as String,
      intensityRoll: meta['intensity'] as int? ?? diceResults[1],
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  static String _intensityText(int roll) {
    switch (roll) {
      case 1:
        return 'Minimal';
      case 2:
        return 'Minor';
      case 3:
        return 'Mundane';
      case 4:
        return 'Moderate';
      case 5:
        return 'Major';
      case 6:
        return 'Maximum';
      default:
        return 'Unknown';
    }
  }

  String get intensityDescription => _intensityText(intensityRoll);

  @override
  String toString() => 'Property: $property ($intensityDescription)';
}

/// Result of rolling two properties (the standard way per instructions).
class DualPropertyResult extends RollResult {
  final PropertyResult property1;
  final PropertyResult property2;

  DualPropertyResult({
    required this.property1,
    required this.property2,
    DateTime? timestamp,
  }) : super(
          type: RollType.details,
          description: 'Properties',
          diceResults: [
            property1.propertyRoll, 
            property1.intensityRoll,
            property2.propertyRoll,
            property2.intensityRoll,
          ],
          total: property1.propertyRoll + property2.propertyRoll,
          interpretation: '${property1.interpretation} + ${property2.interpretation}',
          timestamp: timestamp,
          metadata: {
            'property1': property1.property,
            'property1Roll': property1.propertyRoll,
            'intensity1': property1.intensityRoll,
            'property2': property2.property,
            'property2Roll': property2.propertyRoll,
            'intensity2': property2.intensityRoll,
          },
        );

  @override
  String get className => 'DualPropertyResult';

  factory DualPropertyResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    return DualPropertyResult(
      property1: PropertyResult(
        propertyRoll: meta['property1Roll'] as int? ?? 1,
        property: meta['property1'] as String,
        intensityRoll: meta['intensity1'] as int? ?? 1,
      ),
      property2: PropertyResult(
        propertyRoll: meta['property2Roll'] as int? ?? 1,
        property: meta['property2'] as String,
        intensityRoll: meta['intensity2'] as int? ?? 1,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() => 
      'Properties: ${property1.property} (${property1.intensityDescription}) + ${property2.property} (${property2.intensityDescription})';
}

/// Result of a detail roll with automatic follow-up for History/Property.
/// 
/// When the detail result is "History" or "Property", the follow-up roll
/// is automatically performed and included in this result.
class DetailWithFollowUpResult extends RollResult {
  final DetailResult detailResult;
  /// Auto-rolled History result when detail is "History"
  final DetailResult? historyResult;
  /// Auto-rolled Property result when detail is "Property"
  final PropertyResult? propertyResult;

  DetailWithFollowUpResult({
    required this.detailResult,
    this.historyResult,
    this.propertyResult,
    DateTime? timestamp,
  }) : super(
          type: RollType.details,
          description: 'Detail',
          diceResults: [
            detailResult.roll,
            if (detailResult.secondRoll != null) detailResult.secondRoll!,
            if (historyResult != null) historyResult.roll,
            if (historyResult?.secondRoll != null) historyResult!.secondRoll!,
            if (propertyResult != null) ...[propertyResult.propertyRoll, propertyResult.intensityRoll],
          ],
          total: detailResult.roll,
          interpretation: _buildInterpretation(detailResult, historyResult, propertyResult),
          timestamp: timestamp,
          metadata: {
            'detail': detailResult.result,
            'detailRoll': detailResult.roll,
            if (detailResult.skew != SkewType.none) 'skew': detailResult.skew.name,
            if (historyResult != null) 'history': historyResult.result,
            if (propertyResult != null) 'property': propertyResult.property,
            if (propertyResult != null) 'propertyIntensity': propertyResult.intensityRoll,
          },
        );

  @override
  String get className => 'DetailWithFollowUpResult';

  factory DetailWithFollowUpResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return DetailWithFollowUpResult(
      detailResult: DetailResult(
        detailType: DetailType.detail,
        roll: meta['detailRoll'] as int? ?? diceResults.first,
        result: meta['detail'] as String,
        skew: meta['skew'] != null
            ? SkewType.values.firstWhere((e) => e.name == meta['skew'])
            : SkewType.none,
      ),
      // Note: historyResult and propertyResult cannot be fully reconstructed
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  static String _buildInterpretation(
    DetailResult detail,
    DetailResult? history,
    PropertyResult? property,
  ) {
    if (history != null) {
      return '${detail.result} → ${history.result}';
    }
    if (property != null) {
      return '${detail.result} → ${property.property} (${property.intensityDescription})';
    }
    return detail.result;
  }

  /// Whether this result has an auto-rolled follow-up.
  bool get hasFollowUp => historyResult != null || propertyResult != null;

  /// Get the follow-up text for display.
  String? get followUpText {
    if (historyResult != null) {
      return historyResult!.result;
    }
    if (propertyResult != null) {
      return '${propertyResult!.property} (${propertyResult!.intensityDescription})';
    }
    return null;
  }

  @override
  String toString() {
    if (historyResult != null) {
      return 'Detail: ${detailResult.result} → ${historyResult!.result}';
    }
    if (propertyResult != null) {
      return 'Detail: ${detailResult.result} → ${propertyResult!.property} (${propertyResult!.intensityDescription})';
    }
    return 'Detail: ${detailResult.result}';
  }
}
