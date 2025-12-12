import '../core/roll_engine.dart';
import '../data/immersion_data.dart' as data;
import 'details.dart' show SkewType;

// Re-export result classes for backward compatibility
export '../models/results/immersion_result.dart'
    show SensoryDetailResult, EmotionalAtmosphereResult, FullImmersionResult;

// Import result classes for internal use
import '../models/results/immersion_result.dart';

/// Immersion generator preset for the Juice Oracle.
/// Uses immersion.md for sensory details and atmosphere.
/// 
/// Full Immersion roll is 5d10 + 1dF:
/// - Sense (d10): 1-3=See, 4-6=Hear, 7-8=Smell, 9-0=Feel
/// - Detail (d10): Based on sense category
/// - Where (d10): Location of the sensory detail
/// - Emotion (d10): The emotional reaction
/// - Fate (1dF): Negative (-/blank) or Positive (+)
/// - Cause (d10): Why it causes that emotion
class Immersion {
  final RollEngine _rollEngine;

  // ========== Static Accessors (delegate to data file) ==========

  /// Senses categories (first d10 determines column)
  static Map<int, String> get senseCategories => data.senseCategories;

  /// See details - d10
  static List<String> get seeDetails => data.seeDetails;

  /// Hear details - d10
  static List<String> get hearDetails => data.hearDetails;

  /// Smell details - d10
  static List<String> get smellDetails => data.smellDetails;

  /// Feel details - d10
  static List<String> get feelDetails => data.feelDetails;

  /// Where? locations - d10
  static List<String> get whereLocations => data.whereLocations;

  /// Negative emotions - d10
  static List<String> get negativeEmotions => data.negativeEmotions;

  /// Positive emotions (opposites) - d10
  static List<String> get positiveEmotions => data.positiveEmotions;

  /// Causes - d10
  static List<String> get causes => data.causes;

  Immersion([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  /// Generate a sensory detail (3d10: Sense + Detail + Where).
  /// 
  /// Variants:
  /// - senseDie: d6 = "Only distant senses", d10 = "All senses" (default)
  /// - skew: advantage = "closer to you", disadvantage = "further from you"
  SensoryDetailResult generateSensoryDetail({
    int senseDie = 10,
    SkewType skew = SkewType.none,
  }) {
    final senseRoll = _rollEngine.rollDie(senseDie);
    final detailRoll = _rollEngine.rollDie(10);
    final whereRolls = skew == SkewType.none
        ? [_rollEngine.rollDie(10)]
        : [_rollEngine.rollDie(10), _rollEngine.rollDie(10)];
    
    // For skew: advantage = closer (lower), disadvantage = further (higher)
    final whereRoll = skew == SkewType.advantage
        ? whereRolls.reduce((a, b) => a < b ? a : b)
        : skew == SkewType.disadvantage
            ? whereRolls.reduce((a, b) => a > b ? a : b)
            : whereRolls[0];

    // Determine sense category
    final senseKey = senseRoll == 10 ? 0 : senseRoll;
    final sense = senseCategories[senseKey] ?? 'See';

    // Get detail from appropriate list
    final detailIndex = detailRoll == 10 ? 9 : detailRoll - 1;
    String detail;
    switch (sense) {
      case 'See':
        detail = seeDetails[detailIndex];
        break;
      case 'Hear':
        detail = hearDetails[detailIndex];
        break;
      case 'Smell':
        detail = smellDetails[detailIndex];
        break;
      case 'Feel':
        detail = feelDetails[detailIndex];
        break;
      default:
        detail = seeDetails[detailIndex];
    }
    
    // Get where location
    final whereIndex = whereRoll == 10 ? 9 : whereRoll - 1;
    final where = whereLocations[whereIndex];

    return SensoryDetailResult(
      senseRoll: senseRoll,
      sense: sense,
      detailRoll: detailRoll,
      detail: detail,
      whereRoll: whereRoll,
      where: where,
      skew: skew,
    );
  }

  /// Generate an emotional atmosphere (2d10 + 1dF: Emotion + Fate + Cause).
  /// 
  /// Variants:
  /// - emotionDie: d6 = "Basic Emotions" (top 6), d10 = "Extended Emotions" (default)
  /// - skew: advantage = "roughly positive", disadvantage = "more negative"
  EmotionalAtmosphereResult generateEmotionalAtmosphere({
    int emotionDie = 10,
    SkewType skew = SkewType.none,
  }) {
    final emotionRolls = skew == SkewType.none
        ? [_rollEngine.rollDie(emotionDie)]
        : [_rollEngine.rollDie(emotionDie), _rollEngine.rollDie(emotionDie)];
    final causeRoll = _rollEngine.rollDie(10);
    
    // For emotion skew: advantage = positive (higher index), disadvantage = negative (lower index)
    final emotionRoll = skew == SkewType.advantage
        ? emotionRolls.reduce((a, b) => a > b ? a : b)
        : skew == SkewType.disadvantage
            ? emotionRolls.reduce((a, b) => a < b ? a : b)
            : emotionRolls[0];
    
    // Roll 1dF to determine emotion polarity:
    // - or blank (1-4) = negative emotion
    // + (5-6) = positive emotion
    final fateDieRoll = _rollEngine.rollFateDie();
    final isPositive = fateDieRoll == 1; // + result

    final emotionIndex = emotionRoll == 10 ? 9 : emotionRoll - 1;
    final causeIndex = causeRoll == 10 ? 9 : causeRoll - 1;

    final negativeEmotion = negativeEmotions[emotionIndex];
    final positiveEmotion = positiveEmotions[emotionIndex];
    final cause = causes[causeIndex];
    final selectedEmotion = isPositive ? positiveEmotion : negativeEmotion;

    return EmotionalAtmosphereResult(
      emotionRoll: emotionRoll,
      negativeEmotion: negativeEmotion,
      positiveEmotion: positiveEmotion,
      selectedEmotion: selectedEmotion,
      isPositive: isPositive,
      causeRoll: causeRoll,
      cause: cause,
      skew: skew,
    );
  }

  /// Generate full immersion (5d10 + 1dF: sensory + emotional).
  /// This combines: Sense + Detail + Where + Emotion + Fate + Cause
  FullImmersionResult generateFullImmersion({
    int senseDie = 10,
    int emotionDie = 10,
    SkewType sensorySkew = SkewType.none,
    SkewType emotionSkew = SkewType.none,
  }) {
    final sensory = generateSensoryDetail(senseDie: senseDie, skew: sensorySkew);
    final emotional = generateEmotionalAtmosphere(emotionDie: emotionDie, skew: emotionSkew);

    return FullImmersionResult(
      sensory: sensory,
      emotional: emotional,
    );
  }
}
