import '../roll_result.dart';
import 'json_utils.dart';

// Forward reference for WildernessState - it depends on Wilderness static accessors
// Import the preset to access static data
import '../../presets/wilderness.dart' show Wilderness;

/// Persistent state for wilderness exploration.
/// This is an immutable value object.
class WildernessState {
  final int environmentRow;  // 1-10
  final int typeRow;         // 1-10
  final bool isLost;         // Use d6 instead of d10 for encounters

  const WildernessState({
    required this.environmentRow,
    required this.typeRow,
    required this.isLost,
  });

  /// Create a copy with updated fields
  WildernessState copyWith({
    int? environmentRow,
    int? typeRow,
    bool? isLost,
  }) {
    return WildernessState(
      environmentRow: environmentRow ?? this.environmentRow,
      typeRow: typeRow ?? this.typeRow,
      isLost: isLost ?? this.isLost,
    );
  }

  String get environment => Wilderness.environments[environmentRow - 1];
  String get typeName => Wilderness.types[typeRow - 1]['name'] as String;
  int get typeModifier => Wilderness.types[typeRow - 1]['modifier'] as int;
  String get environmentSkew => Wilderness.types[environmentRow - 1]['skew'] as String;
  
  String get fullDescription => '$typeName $environment';

  @override
  String toString() => 'WildernessState($fullDescription, lost: $isLost)';
}

/// Result of generating a wilderness area.
/// Now includes the new state that should be stored.
class WildernessAreaResult extends RollResult {
  final List<int> envFateDice;
  final int envRoll;
  final String environment;
  final int typeFateDie;
  final int typeRoll;
  final String typeName;
  final int typeModifier;
  final bool isTransition;
  final String? previousEnvironment;
  final bool isManualSet;
  
  /// The new wilderness state after this roll.
  /// Caller should update their state storage with this.
  final WildernessState? newState;

  WildernessAreaResult({
    required this.envFateDice,
    required this.envRoll,
    required this.environment,
    required this.typeFateDie,
    required this.typeRoll,
    required this.typeName,
    required this.typeModifier,
    this.isTransition = false,
    this.previousEnvironment,
    this.isManualSet = false,
    this.newState,
    DateTime? timestamp,
  }) : super(
          type: RollType.weather, // Using weather as closest match
          description: isManualSet ? 'Set Wilderness Position' : (isTransition ? 'Wilderness Transition' : 'Wilderness Area'),
          diceResults: isManualSet ? [envRoll, typeRoll] : [...envFateDice, envRoll, typeFateDie, typeRoll],
          total: envRoll + typeRoll,
          interpretation: '$typeName $environment',
          timestamp: timestamp,
          metadata: {
            'environment': environment,
            'envRoll': envRoll,
            'envFateDice': envFateDice,
            'typeName': typeName,
            'typeRoll': typeRoll,
            'typeFateDie': typeFateDie,
            'typeModifier': typeModifier,
            'isTransition': isTransition,
            'isManualSet': isManualSet,
            if (previousEnvironment != null) 'previousEnvironment': previousEnvironment,
            if (newState != null) 'newState': {
              'environmentRow': newState.environmentRow,
              'typeRow': newState.typeRow,
              'isLost': newState.isLost,
            },
          },
        );

  @override
  String get className => 'WildernessAreaResult';

  factory WildernessAreaResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    WildernessState? state;
    if (meta['newState'] != null) {
      final stateJson = requireMap(meta['newState'], 'newState');
      state = WildernessState(
        environmentRow: stateJson['environmentRow'] as int,
        typeRow: stateJson['typeRow'] as int,
        isLost: stateJson['isLost'] as bool? ?? false,
      );
    }
    return WildernessAreaResult(
      envFateDice: (meta['envFateDice'] as List<dynamic>?)?.cast<int>() ?? [],
      envRoll: meta['envRoll'] as int? ?? 1,
      environment: meta['environment'] as String,
      typeFateDie: meta['typeFateDie'] as int? ?? 0,
      typeRoll: meta['typeRoll'] as int? ?? 1,
      typeName: meta['typeName'] as String,
      typeModifier: meta['typeModifier'] as int,
      isTransition: meta['isTransition'] as bool? ?? false,
      previousEnvironment: meta['previousEnvironment'] as String?,
      isManualSet: meta['isManualSet'] as bool? ?? false,
      newState: state,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  String get fullDescription => '$typeName $environment (+$typeModifier)';

  @override
  String toString() {
    if (isTransition && previousEnvironment != null) {
      return 'Transition: $previousEnvironment → $fullDescription';
    }
    return 'Wilderness: $fullDescription';
  }
}

/// Result of a wilderness encounter roll.
/// Now includes the new state that should be stored.
class WildernessEncounterResult extends RollResult {
  final int roll;
  final int? secondRoll;
  final String encounter;
  final bool requiresFollowUp;
  final int dieSize;
  final String skewUsed;
  final bool wasLost;
  final bool becameLost;
  final bool becameFound;
  final bool isItalic;
  final String? partialItalic;
  
  // Embedded follow-up result data (populated when auto-rolling)
  final int? followUpRoll;
  final String? followUpResult;
  final Map<String, dynamic>? followUpData;
  
  /// The new wilderness state after this roll.
  /// Caller should update their state storage with this.
  final WildernessState? newState;

  WildernessEncounterResult({
    required this.roll,
    this.secondRoll,
    required this.encounter,
    required this.requiresFollowUp,
    this.dieSize = 10,
    this.skewUsed = 'straight',
    this.wasLost = false,
    this.becameLost = false,
    this.becameFound = false,
    this.isItalic = false,
    this.partialItalic,
    this.followUpRoll,
    this.followUpResult,
    this.followUpData,
    this.newState,
    DateTime? timestamp,
  }) : super(
          type: RollType.encounter,
          description: 'Wilderness Encounter',
          diceResults: secondRoll != null ? [roll, secondRoll] : [roll],
          total: roll,
          interpretation: encounter,
          timestamp: timestamp,
          metadata: {
            'roll': roll,
            'secondRoll': secondRoll,
            'encounter': encounter,
            'requiresFollowUp': requiresFollowUp,
            'dieSize': dieSize,
            'skewUsed': skewUsed,
            'wasLost': wasLost,
            'becameLost': becameLost,
            'becameFound': becameFound,
            'isItalic': isItalic,
            if (partialItalic != null) 'partialItalic': partialItalic,
            if (followUpRoll != null) 'followUpRoll': followUpRoll,
            if (followUpResult != null) 'followUpResult': followUpResult,
            if (followUpData != null) 'followUpData': followUpData,
            if (newState != null) 'newState': {
              'environmentRow': newState.environmentRow,
              'typeRow': newState.typeRow,
              'isLost': newState.isLost,
            },
          },
        );

  /// Create a copy with follow-up data added
  WildernessEncounterResult withFollowUp({
    required int followUpRoll,
    required String followUpResult,
    Map<String, dynamic>? followUpData,
  }) {
    return WildernessEncounterResult(
      roll: roll,
      secondRoll: secondRoll,
      encounter: encounter,
      requiresFollowUp: requiresFollowUp,
      dieSize: dieSize,
      skewUsed: skewUsed,
      wasLost: wasLost,
      becameLost: becameLost,
      becameFound: becameFound,
      isItalic: isItalic,
      partialItalic: partialItalic,
      followUpRoll: followUpRoll,
      followUpResult: followUpResult,
      followUpData: followUpData,
      newState: newState,
      timestamp: timestamp,
    );
  }

  @override
  String get className => 'WildernessEncounterResult';

  factory WildernessEncounterResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    WildernessState? state;
    if (meta['newState'] != null) {
      final stateJson = requireMap(meta['newState'], 'newState');
      state = WildernessState(
        environmentRow: stateJson['environmentRow'] as int,
        typeRow: stateJson['typeRow'] as int,
        isLost: stateJson['isLost'] as bool? ?? false,
      );
    }
    return WildernessEncounterResult(
      roll: meta['roll'] as int? ?? (json['diceResults'] as List).first as int,
      secondRoll: meta['secondRoll'] as int?,
      encounter: meta['encounter'] as String,
      requiresFollowUp: meta['requiresFollowUp'] as bool? ?? false,
      dieSize: meta['dieSize'] as int? ?? 10,
      skewUsed: meta['skewUsed'] as String? ?? 'straight',
      wasLost: meta['wasLost'] as bool? ?? false,
      becameLost: meta['becameLost'] as bool? ?? false,
      becameFound: meta['becameFound'] as bool? ?? false,
      isItalic: meta['isItalic'] as bool? ?? false,
      partialItalic: meta['partialItalic'] as String?,
      followUpRoll: meta['followUpRoll'] as int?,
      followUpResult: meta['followUpResult'] as String?,
      followUpData: safeMap(meta['followUpData']),
      newState: state,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() {
    var result = 'Encounter (d$dieSize';
    if (skewUsed != 'straight') result += '@$skewUsed';
    result += '): $encounter';
    if (becameLost) result += ' [LOST]';
    if (becameFound) result += ' [FOUND]';
    if (requiresFollowUp) result += ' (roll details)';
    return result;
  }
}

/// Result of weather roll using proper formula
class WildernessWeatherResult extends RollResult {
  final int baseRoll;
  final int? secondRoll;
  final String environmentSkew;
  final int typeModifier;
  final int weatherRow;
  final String weather;
  final String environment;
  final String typeName;

  WildernessWeatherResult({
    required this.baseRoll,
    this.secondRoll,
    required this.environmentSkew,
    required this.typeModifier,
    required this.weatherRow,
    required this.weather,
    required this.environment,
    required this.typeName,
    DateTime? timestamp,
  }) : super(
          type: RollType.weather,
          description: 'Weather',
          diceResults: secondRoll != null ? [baseRoll, secondRoll] : [baseRoll],
          total: weatherRow,
          interpretation: weather,
          timestamp: timestamp,
          metadata: {
            'baseRoll': baseRoll,
            'secondRoll': secondRoll,
            'environmentSkew': environmentSkew,
            'typeModifier': typeModifier,
            'weatherRow': weatherRow,
            'weather': weather,
            'environment': environment,
            'typeName': typeName,
          },
        );

  @override
  String get className => 'WildernessWeatherResult';

  factory WildernessWeatherResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    return WildernessWeatherResult(
      baseRoll: meta['baseRoll'] as int? ?? (json['diceResults'] as List).first as int,
      secondRoll: meta['secondRoll'] as int?,
      environmentSkew: meta['environmentSkew'] as String? ?? '@',
      typeModifier: meta['typeModifier'] as int? ?? 0,
      weatherRow: meta['weatherRow'] as int? ?? json['total'] as int,
      weather: meta['weather'] as String,
      environment: meta['environment'] as String,
      typeName: meta['typeName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  String get formula => '1d6@$environmentSkew + $typeModifier';

  @override
  String toString() => 'Weather ($typeName $environment): $weather ($formula → $weatherRow)';
}

/// Result of a wilderness detail roll.
class WildernessDetailResult extends RollResult {
  final String detailType;
  final int roll;
  final String result;

  WildernessDetailResult({
    required this.detailType,
    required this.roll,
    required this.result,
    DateTime? timestamp,
  }) : super(
          type: RollType.weather,
          description: detailType,
          diceResults: [roll],
          total: roll,
          interpretation: result,
          timestamp: timestamp,
          metadata: {
            'detailType': detailType,
            'roll': roll,
            'result': result,
          },
        );

  @override
  String get className => 'WildernessDetailResult';

  factory WildernessDetailResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    return WildernessDetailResult(
      detailType: meta['detailType'] as String,
      roll: meta['roll'] as int? ?? (json['diceResults'] as List).first as int,
      result: meta['result'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() => '$detailType: $result';
}

/// Result of monster level calculation.
class MonsterLevelResult extends RollResult {
  final int baseRoll;
  final int? secondRoll;
  final int modifier;
  final String advantageType;
  final int monsterLevel;

  MonsterLevelResult({
    required this.baseRoll,
    this.secondRoll,
    required this.modifier,
    required this.advantageType,
    required this.monsterLevel,
    DateTime? timestamp,
  }) : super(
          type: RollType.encounter,
          description: 'Monster Level',
          diceResults: secondRoll != null ? [baseRoll, secondRoll] : [baseRoll],
          total: monsterLevel,
          timestamp: timestamp,
          interpretation: 'Level $monsterLevel (+$modifier@$advantageType)',
          metadata: {
            'baseRoll': baseRoll,
            'secondRoll': secondRoll,
            'modifier': modifier,
            'advantageType': advantageType,
            'monsterLevel': monsterLevel,
          },
        );

  @override
  String get className => 'MonsterLevelResult';

  factory MonsterLevelResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    return MonsterLevelResult(
      baseRoll: meta['baseRoll'] as int? ?? (json['diceResults'] as List).first as int,
      secondRoll: meta['secondRoll'] as int?,
      modifier: meta['modifier'] as int? ?? 0,
      advantageType: meta['advantageType'] as String? ?? '@',
      monsterLevel: meta['monsterLevel'] as int? ?? json['total'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() => 'Monster Level: $monsterLevel (1d6+$modifier@$advantageType)';
}
