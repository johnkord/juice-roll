import '../core/roll_engine.dart';
import '../models/roll_result.dart';

/// Immersion generator preset for the Juice Oracle.
/// Uses immersion.md for sensory details and atmosphere.
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

  /// Generate a sensory detail (2d10).
  SensoryDetailResult generateSensoryDetail() {
    final senseRoll = _rollEngine.rollDie(10);
    final detailRoll = _rollEngine.rollDie(10);

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

    return SensoryDetailResult(
      senseRoll: senseRoll,
      sense: sense,
      detailRoll: detailRoll,
      detail: detail,
    );
  }

  /// Generate an emotional atmosphere (2d10 + cause).
  EmotionalAtmosphereResult generateEmotionalAtmosphere() {
    final whereRoll = _rollEngine.rollDie(10);
    final emotionRoll = _rollEngine.rollDie(10);
    final causeRoll = _rollEngine.rollDie(10);

    final whereIndex = whereRoll == 10 ? 9 : whereRoll - 1;
    final emotionIndex = emotionRoll == 10 ? 9 : emotionRoll - 1;
    final causeIndex = causeRoll == 10 ? 9 : causeRoll - 1;

    final where = whereLocations[whereIndex];
    final negativeEmotion = negativeEmotions[emotionIndex];
    final positiveEmotion = positiveEmotions[emotionIndex];
    final cause = causes[causeIndex];

    return EmotionalAtmosphereResult(
      whereRoll: whereRoll,
      where: where,
      emotionRoll: emotionRoll,
      negativeEmotion: negativeEmotion,
      positiveEmotion: positiveEmotion,
      causeRoll: causeRoll,
      cause: cause,
    );
  }

  /// Generate full immersion (sensory + emotional).
  FullImmersionResult generateFullImmersion() {
    final sensory = generateSensoryDetail();
    final emotional = generateEmotionalAtmosphere();

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

  SensoryDetailResult({
    required this.senseRoll,
    required this.sense,
    required this.detailRoll,
    required this.detail,
  }) : super(
          type: RollType.immersion,
          description: 'Sensory Detail',
          diceResults: [senseRoll, detailRoll],
          total: senseRoll + detailRoll,
          interpretation: 'You $sense something $detail',
          metadata: {
            'sense': sense,
            'detail': detail,
          },
        );

  @override
  String toString() => 'Sensory: You $sense something $detail';
}

/// Result of an emotional atmosphere roll.
class EmotionalAtmosphereResult extends RollResult {
  final int whereRoll;
  final String where;
  final int emotionRoll;
  final String negativeEmotion;
  final String positiveEmotion;
  final int causeRoll;
  final String cause;

  EmotionalAtmosphereResult({
    required this.whereRoll,
    required this.where,
    required this.emotionRoll,
    required this.negativeEmotion,
    required this.positiveEmotion,
    required this.causeRoll,
    required this.cause,
  }) : super(
          type: RollType.immersion,
          description: 'Emotional Atmosphere',
          diceResults: [whereRoll, emotionRoll, causeRoll],
          total: whereRoll + emotionRoll + causeRoll,
          interpretation: '$where, $negativeEmotion or $positiveEmotion, because $cause',
          metadata: {
            'where': where,
            'negativeEmotion': negativeEmotion,
            'positiveEmotion': positiveEmotion,
            'cause': cause,
          },
        );

  @override
  String toString() =>
      'Atmosphere: $where, $negativeEmotion/$positiveEmotion, because $cause';
}

/// Result of full immersion generation.
class FullImmersionResult extends RollResult {
  final SensoryDetailResult sensory;
  final EmotionalAtmosphereResult emotional;

  FullImmersionResult({
    required this.sensory,
    required this.emotional,
  }) : super(
          type: RollType.immersion,
          description: 'Full Immersion',
          diceResults: [...sensory.diceResults, ...emotional.diceResults],
          total: sensory.total + emotional.total,
          interpretation:
              '${sensory.interpretation}\n${emotional.interpretation}',
          metadata: {
            'sensory': sensory.metadata,
            'emotional': emotional.metadata,
          },
        );

  @override
  String toString() => 'Immersion:\n  $sensory\n  $emotional';
}
