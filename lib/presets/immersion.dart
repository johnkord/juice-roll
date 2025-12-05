import '../core/roll_engine.dart';
import '../models/roll_result.dart';
import 'details.dart' show SkewType;

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

  /// Senses categories (first d10 determines column)
  static const Map<int, String> senseCategories = {
    1: 'See',
    2: 'See',
    3: 'See',
    4: 'Hear',
    5: 'Hear',
    6: 'Hear',
    7: 'Smell',
    8: 'Smell',
    9: 'Feel',
    0: 'Feel', // 10 = 0
  };

  /// See details - d10
  static const List<String> seeDetails = [
    'Broken',    // 1
    'Colorful',  // 2
    'Discarded', // 3
    'Edible',    // 4
    'Liquid',    // 5
    'Natural',   // 6
    'Odd',       // 7
    'Round',     // 8
    'Shiny',     // 9
    'Written',   // 0/10
  ];

  /// Hear details - d10
  static const List<String> hearDetails = [
    'Dripping',   // 1
    'Fire',       // 2
    'Footsteps',  // 3
    'Growling',   // 4
    'Laughter',   // 5
    'Music',      // 6
    'Scratching', // 7
    'Silence',    // 8
    'Talking',    // 9
    'Wind',       // 0/10
  ];

  /// Smell details - d10
  static const List<String> smellDetails = [
    'Alcohol', // 1
    'Blood',   // 2
    'Smoke',   // 3
    'Cooking', // 4
    'Decay',   // 5
    'Dust',    // 6
    'Flowers', // 7
    'Leather', // 8
    'Oil',     // 9
    'Soil',    // 0/10
  ];

  /// Feel details - d10
  static const List<String> feelDetails = [
    'Cold',     // 1
    'Damp',     // 2
    'Flexible', // 3
    'Furry',    // 4
    'Rough',    // 5
    'Sharp',    // 6
    'Slippery', // 7
    'Smooth',   // 8
    'Sticky',   // 9
    'Warm',     // 0/10
  ];

  /// Where? locations - d10
  static const List<String> whereLocations = [
    'Above',            // 1
    'Behind',           // 2
    'In Front',         // 3
    'In The Air',       // 4
    'In The Distance',  // 5
    'In The Next Room', // 6
    'In The Shadows',   // 7
    'Next To You',      // 8
    'On The Ground',    // 9
    'Under',            // 0/10
  ];

  /// Negative emotions - d10
  static const List<String> negativeEmotions = [
    'Despair',    // 1
    'Panic',      // 2
    'Fear',       // 3
    'Disgust',    // 4
    'Anger',      // 5
    'Sadness',    // 6
    'Arrogance',  // 7
    'Confusion',  // 8
    'Apathy',     // 9
    'Deja Vu',    // 0/10
  ];

  /// Positive emotions (opposites) - d10
  static const List<String> positiveEmotions = [
    'Hope',         // 1
    'Relief',       // 2
    'Courage',      // 3
    'Desire',       // 4
    'Calm',         // 5
    'Joy',          // 6
    'Selflessness', // 7
    'Clarity',      // 8
    'Nostalgia',    // 9
    'Awe',          // 0/10
  ];

  /// Causes - d10
  static const List<String> causes = [
    'help is on the way',          // 1
    'it is getting closer',        // 2
    'it may be valuable',          // 3
    'of a childhood event',        // 4
    'of a recent memory',          // 5
    'the source is unknown',       // 6
    'then it is suddenly gone',    // 7
    'you recognize it',            // 8
    'you were warned about it',    // 9
    'you weren\'t expecting it',   // 0/10
  ];

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

/// Result of a sensory detail roll.
class SensoryDetailResult extends RollResult {
  final int senseRoll;
  final String sense;
  final int detailRoll;
  final String detail;
  final int whereRoll;
  final String where;
  final SkewType skew;

  SensoryDetailResult({
    required this.senseRoll,
    required this.sense,
    required this.detailRoll,
    required this.detail,
    required this.whereRoll,
    required this.where,
    required this.skew,
    DateTime? timestamp,
  }) : super(
          type: RollType.immersion,
          description: 'Sensory Detail',
          diceResults: [senseRoll, detailRoll, whereRoll],
          total: senseRoll + detailRoll + whereRoll,
          interpretation: 'You $sense something $detail $where',
          timestamp: timestamp,
          metadata: {
            'sense': sense,
            'senseRoll': senseRoll,
            'detail': detail,
            'detailRoll': detailRoll,
            'where': where,
            'whereRoll': whereRoll,
            'skew': skew.name,
          },
        );

  @override
  String get className => 'SensoryDetailResult';

  factory SensoryDetailResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return SensoryDetailResult(
      senseRoll: meta['senseRoll'] as int? ?? diceResults[0],
      sense: meta['sense'] as String,
      detailRoll: meta['detailRoll'] as int? ?? diceResults[1],
      detail: meta['detail'] as String,
      whereRoll: meta['whereRoll'] as int? ?? diceResults[2],
      where: meta['where'] as String,
      skew: SkewType.values.firstWhere(
        (e) => e.name == (meta['skew'] as String),
        orElse: () => SkewType.none,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() => 'Sensory: You $sense something $detail $where';
}

/// Result of an emotional atmosphere roll.
class EmotionalAtmosphereResult extends RollResult {
  final int emotionRoll;
  final String negativeEmotion;
  final String positiveEmotion;
  final String selectedEmotion;
  final bool isPositive;
  final int causeRoll;
  final String cause;
  final SkewType skew;

  EmotionalAtmosphereResult({
    required this.emotionRoll,
    required this.negativeEmotion,
    required this.positiveEmotion,
    required this.selectedEmotion,
    required this.isPositive,
    required this.causeRoll,
    required this.cause,
    required this.skew,
    DateTime? timestamp,
  }) : super(
          type: RollType.immersion,
          description: 'Emotional Atmosphere',
          diceResults: [emotionRoll, causeRoll],
          total: emotionRoll + causeRoll,
          interpretation: 'It causes $selectedEmotion because $cause',
          timestamp: timestamp,
          metadata: {
            'negativeEmotion': negativeEmotion,
            'positiveEmotion': positiveEmotion,
            'selectedEmotion': selectedEmotion,
            'isPositive': isPositive,
            'emotionRoll': emotionRoll,
            'cause': cause,
            'causeRoll': causeRoll,
            'skew': skew.name,
          },
        );

  @override
  String get className => 'EmotionalAtmosphereResult';

  factory EmotionalAtmosphereResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return EmotionalAtmosphereResult(
      emotionRoll: meta['emotionRoll'] as int? ?? diceResults[0],
      negativeEmotion: meta['negativeEmotion'] as String,
      positiveEmotion: meta['positiveEmotion'] as String,
      selectedEmotion: meta['selectedEmotion'] as String,
      isPositive: meta['isPositive'] as bool,
      causeRoll: meta['causeRoll'] as int? ?? diceResults[1],
      cause: meta['cause'] as String,
      skew: SkewType.values.firstWhere(
        (e) => e.name == (meta['skew'] as String),
        orElse: () => SkewType.none,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() =>
      'Atmosphere: $selectedEmotion (${isPositive ? '+' : '-'}), because $cause';
}

/// Result of full immersion generation.
class FullImmersionResult extends RollResult {
  final SensoryDetailResult sensory;
  final EmotionalAtmosphereResult emotional;

  FullImmersionResult({
    required this.sensory,
    required this.emotional,
    DateTime? timestamp,
  }) : super(
          type: RollType.immersion,
          description: 'Full Immersion',
          diceResults: [...sensory.diceResults, ...emotional.diceResults],
          total: sensory.total + emotional.total,
          interpretation:
              'You ${sensory.sense.toLowerCase()} something ${sensory.detail.toLowerCase()} ${sensory.where.toLowerCase()}, and it causes ${emotional.selectedEmotion.toLowerCase()} because ${emotional.cause}',
          timestamp: timestamp,
          metadata: {
            'sensory': sensory.metadata,
            'emotional': emotional.metadata,
          },
        );

  @override
  String get className => 'FullImmersionResult';

  factory FullImmersionResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final sensoryMeta = meta['sensory'] as Map<String, dynamic>;
    final emotionalMeta = meta['emotional'] as Map<String, dynamic>;
    return FullImmersionResult(
      sensory: SensoryDetailResult(
        senseRoll: sensoryMeta['senseRoll'] as int,
        sense: sensoryMeta['sense'] as String,
        detailRoll: sensoryMeta['detailRoll'] as int,
        detail: sensoryMeta['detail'] as String,
        whereRoll: sensoryMeta['whereRoll'] as int,
        where: sensoryMeta['where'] as String,
        skew: SkewType.values.firstWhere(
          (e) => e.name == (sensoryMeta['skew'] as String),
          orElse: () => SkewType.none,
        ),
      ),
      emotional: EmotionalAtmosphereResult(
        emotionRoll: emotionalMeta['emotionRoll'] as int,
        negativeEmotion: emotionalMeta['negativeEmotion'] as String,
        positiveEmotion: emotionalMeta['positiveEmotion'] as String,
        selectedEmotion: emotionalMeta['selectedEmotion'] as String,
        isPositive: emotionalMeta['isPositive'] as bool,
        causeRoll: emotionalMeta['causeRoll'] as int,
        cause: emotionalMeta['cause'] as String,
        skew: SkewType.values.firstWhere(
          (e) => e.name == (emotionalMeta['skew'] as String),
          orElse: () => SkewType.none,
        ),
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() =>
      'Immersion: You ${sensory.sense.toLowerCase()} something ${sensory.detail.toLowerCase()} ${sensory.where.toLowerCase()}, and it causes ${emotional.selectedEmotion.toLowerCase()} because ${emotional.cause}';
}
