import '../roll_result.dart';
import 'json_utils.dart';
import 'details_result.dart' show SkewType;

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
    
    // Safely cast nested Maps (JSON may return Map<dynamic, dynamic>)
    final sensoryMeta = requireMap(meta['sensory'], 'sensory');
    final emotionalMeta = requireMap(meta['emotional'], 'emotional');
    
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
