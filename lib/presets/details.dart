import '../core/roll_engine.dart';
import '../data/details_data.dart' as data;

// Re-export result classes for backward compatibility
export '../models/results/details_result.dart';

import '../models/results/details_result.dart';

/// Details generator preset for the Juice Oracle.
/// Uses details.md for colors, properties, and history.
class Details {
  final RollEngine _rollEngine;

  // ========== Static Accessors (delegate to data file) ==========

  /// Colors - d10
  static List<String> get colors => data.colors;

  /// Color emoji (for display)
  static List<String> get colorEmoji => data.colorEmoji;

  /// Properties - d10
  static List<String> get properties => data.properties;

  /// Detail modifiers - d10
  static List<String> get detailModifiers => data.detailModifiers;

  /// History context - d10
  static List<String> get histories => data.histories;

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
