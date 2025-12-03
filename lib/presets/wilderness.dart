import '../core/roll_engine.dart';
import '../models/roll_result.dart';

/// Wilderness Generator preset for the Juice Oracle.
/// Uses wilderness-table.md for terrain, encounters, and monster generation.
/// 
/// Formula: 2dF Env → 1dF Type; W: 1d6@E+T; M: 1d6+E
/// 
/// **State-Tracked System:**
/// - Current environment row (1-10) is tracked
/// - Transitions use 2dF offset from current environment
/// - Type uses 1dF offset from environment row (clamped at edges)
/// - Lost/Found state affects encounter die (d6 when lost, d10 when oriented)
class Wilderness {
  final RollEngine _rollEngine;

  /// Current wilderness state (null if not yet initialized)
  WildernessState? _state;

  /// Full environment list (d10, rows 1-10)
  static const List<String> environments = [
    'Arctic',     // 1
    'Mountains',  // 2
    'Cavern',     // 3
    'Hills',      // 4
    'Grassland',  // 5
    'Forest',     // 6
    'Swamp',      // 7
    'Water',      // 8
    'Coast',      // 9
    'Desert',     // 10
  ];

  /// Type data: modifier for weather, name, and weather skew symbol
  /// Indexed 0-9 for rows 1-10
  static const List<Map<String, dynamic>> types = [
    {'modifier': 0, 'name': 'Snowy', 'skew': '-'},     // 1
    {'modifier': 2, 'name': 'Rocky', 'skew': '-'},     // 2
    {'modifier': 3, 'name': 'Expansive', 'skew': '0'}, // 3
    {'modifier': 2, 'name': 'Windy', 'skew': '-'},     // 4
    {'modifier': 4, 'name': 'Scrub', 'skew': '0'},     // 5
    {'modifier': 3, 'name': 'Tropical', 'skew': '0'},  // 6
    {'modifier': 1, 'name': 'Dark', 'skew': '+'},      // 7
    {'modifier': 3, 'name': 'Exotic', 'skew': '+'},    // 8
    {'modifier': 4, 'name': 'Sandy', 'skew': '0'},     // 9
    {'modifier': 4, 'name': 'Arid', 'skew': '+'},      // 10
  ];

  /// Encounter types (d10)
  static const List<String> encounters = [
    'Natural Hazard',    // 1
    'Monster',           // 2
    'Weather',           // 3
    'Challenge',         // 4
    'Dungeon',           // 5
    'River/Road',        // 6
    'Feature',           // 7
    'Settlement/Camp',   // 8
    'Advance Plot',      // 9
    'Destination/Lost',  // 10
  ];

  /// Weather conditions (rows 1-10)
  static const List<String> weatherTypes = [
    'Blizzard',       // 1
    'Snow Flurries',  // 2
    'Freezing Cold',  // 3
    'Thunder Storm',  // 4
    'Heavy Rain',     // 5
    'Light Rain',     // 6
    'Heavy Clouds',   // 7
    'High Winds',     // 8
    'Clear Skies',    // 9
    'Scorching Heat', // 10
  ];

  /// Monster level formulas (modifier + advantage type) by environment
  static const List<Map<String, dynamic>> monsterFormulas = [
    {'modifier': 0, 'advantage': '-'},  // 1: Arctic +0@-
    {'modifier': 0, 'advantage': '0'},  // 2: Mountains +0@0
    {'modifier': 1, 'advantage': '-'},  // 3: Cavern +1@-
    {'modifier': 1, 'advantage': '0'},  // 4: Hills +1@0
    {'modifier': 3, 'advantage': '-'},  // 5: Grassland +3@-
    {'modifier': 2, 'advantage': '0'},  // 6: Forest +2@0
    {'modifier': 3, 'advantage': '+'},  // 7: Swamp +3@+
    {'modifier': 3, 'advantage': '0'},  // 8: Water +3@0
    {'modifier': 4, 'advantage': '-'},  // 9: Coast +4@-
    {'modifier': 4, 'advantage': '+'},  // 10: Desert +4@+
  ];

  /// Natural hazards (d10)
  static const List<String> naturalHazards = [
    'Creature Tracks',  // 1
    'Dust Storm',       // 2
    'Flood',            // 3
    'Fog',              // 4
    'Rockslide',        // 5
    'Unstable Ground',  // 6
    'Crevice',          // 7
    'Escarpment',       // 8
    'River Crossing',   // 9
    'Thick Plants',     // 10
  ];

  /// Wilderness features (d10)
  static const List<String> features = [
    'Bones',     // 1
    'Cairn',     // 2
    'Chasm',     // 3
    'Circle',    // 4
    'Spring',    // 5
    'Grave',     // 6
    'Monument',  // 7
    'Tower',     // 8
    'Tree',      // 9
    'Well',      // 10
  ];

  Wilderness([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  /// Get current state (null if not initialized)
  WildernessState? get state => _state;

  /// Initialize wilderness with a random starting environment
  WildernessAreaResult initializeRandom() {
    final envRoll = _rollEngine.rollDie(10);
    final envRow = envRoll == 10 ? 10 : envRoll;
    
    // Roll 1dF for initial type offset from environment
    final typeFate = _rollEngine.rollFateDice(1)[0];
    final typeRow = _clampTypeRow(envRow, typeFate);
    
    _state = WildernessState(
      environmentRow: envRow,
      typeRow: typeRow,
      isLost: false,
    );

    return WildernessAreaResult(
      envFateDice: [0, 0], // No offset for initial
      envRoll: envRoll,
      environment: environments[envRow - 1],
      typeFateDie: typeFate,
      typeRoll: typeRow,
      typeName: types[typeRow - 1]['name'] as String,
      typeModifier: types[typeRow - 1]['modifier'] as int,
      isTransition: false,
      previousEnvironment: null,
    );
  }

  /// Initialize wilderness at a specific environment (for testing or setting up)
  /// Returns a WildernessAreaResult for logging in history
  WildernessAreaResult initializeAt(int environmentRow, {int? typeRow, bool isLost = false}) {
    final clampedEnv = environmentRow.clamp(1, 10);
    final clampedType = (typeRow ?? clampedEnv).clamp(1, 10);
    
    _state = WildernessState(
      environmentRow: clampedEnv,
      typeRow: clampedType,
      isLost: isLost,
    );

    return WildernessAreaResult(
      envFateDice: [0, 0], // No dice for manual set
      envRoll: clampedEnv,
      environment: environments[clampedEnv - 1],
      typeFateDie: 0, // No dice for manual set
      typeRoll: clampedType,
      typeName: types[clampedType - 1]['name'] as String,
      typeModifier: types[clampedType - 1]['modifier'] as int,
      isTransition: false,
      previousEnvironment: null,
      isManualSet: true,
    );
  }

  /// Transition to a new hex using 2dF for environment + 1dF for type
  /// This is the main method for wilderness exploration
  WildernessAreaResult transition() {
    if (_state == null) {
      return initializeRandom();
    }

    final previousEnv = _state!.environmentRow;
    final previousEnvName = environments[previousEnv - 1];
    
    // Roll 2dF for environment offset
    final envFateDice = _rollEngine.rollFateDice(2);
    final envOffset = envFateDice[0] + envFateDice[1];
    
    // Apply offset with clamping (no wrap)
    final newEnvRow = (previousEnv + envOffset).clamp(1, 10);
    
    // Roll 1dF for type offset from new environment
    final typeFate = _rollEngine.rollFateDice(1)[0];
    final newTypeRow = _clampTypeRow(newEnvRow, typeFate);
    
    // Update state
    _state = WildernessState(
      environmentRow: newEnvRow,
      typeRow: newTypeRow,
      isLost: _state!.isLost,
    );

    return WildernessAreaResult(
      envFateDice: envFateDice,
      envRoll: newEnvRow,
      environment: environments[newEnvRow - 1],
      typeFateDie: typeFate,
      typeRoll: newTypeRow,
      typeName: types[newTypeRow - 1]['name'] as String,
      typeModifier: types[newTypeRow - 1]['modifier'] as int,
      isTransition: true,
      previousEnvironment: previousEnvName,
    );
  }

  /// Clamp type row so it doesn't wrap at edges
  /// Arctic stays Snowy (row 1), Desert stays Arid (row 10)
  int _clampTypeRow(int envRow, int fateOffset) {
    final rawType = envRow + fateOffset;
    return rawType.clamp(1, 10);
  }

  /// Roll for a wilderness encounter.
  /// Uses d10 when oriented, d6 when lost.
  /// Optionally apply skew for dangerous terrain (disadvantage) or map/guide (advantage).
  WildernessEncounterResult rollEncounter({
    bool? hasDangerousTerrain,
    bool? hasMapOrGuide,
  }) {
    // Determine die size based on lost state
    final dieSize = (_state?.isLost ?? false) ? 6 : 10;
    
    // Calculate net skew
    final dangerSkew = (hasDangerousTerrain ?? false) ? -1 : 0;
    final guideSkew = (hasMapOrGuide ?? false) ? 1 : 0;
    final netSkew = dangerSkew + guideSkew;
    
    int roll;
    int? secondRoll;
    String skewUsed;
    
    if (netSkew > 0) {
      // Advantage
      final result = _rollEngine.rollWithAdvantage(1, dieSize);
      roll = result.chosenSum;
      secondRoll = result.sum2;
      skewUsed = 'advantage';
    } else if (netSkew < 0) {
      // Disadvantage
      final result = _rollEngine.rollWithDisadvantage(1, dieSize);
      roll = result.chosenSum;
      secondRoll = result.sum2;
      skewUsed = 'disadvantage';
    } else {
      roll = _rollEngine.rollDie(dieSize);
      skewUsed = 'straight';
    }
    
    final index = roll == 10 ? 9 : roll - 1;
    final encounter = encounters[index];
    
    // Check for Lost/Found state transitions
    bool becameLost = false;
    bool becameFound = false;
    
    if (_state != null) {
      if (encounter == 'Destination/Lost' && !_state!.isLost) {
        // Became lost (only if no specific destination in mind - caller decides)
        becameLost = true;
      } else if (encounter == 'River/Road' && _state!.isLost) {
        // Found orientation again
        becameFound = true;
        _state = WildernessState(
          environmentRow: _state!.environmentRow,
          typeRow: _state!.typeRow,
          isLost: false,
        );
      }
    }

    return WildernessEncounterResult(
      roll: roll,
      secondRoll: secondRoll,
      encounter: encounter,
      requiresFollowUp: _requiresFollowUp(encounter),
      dieSize: dieSize,
      skewUsed: skewUsed,
      wasLost: _state?.isLost ?? false,
      becameLost: becameLost,
      becameFound: becameFound,
    );
  }

  /// Mark the character as lost (use d6 for encounters)
  void setLost(bool isLost) {
    if (_state != null) {
      _state = WildernessState(
        environmentRow: _state!.environmentRow,
        typeRow: _state!.typeRow,
        isLost: isLost,
      );
    }
  }

  bool _requiresFollowUp(String encounter) {
    return encounter == 'Natural Hazard' ||
           encounter == 'Monster' ||
           encounter == 'Weather' ||
           encounter == 'Challenge' ||
           encounter == 'Dungeon' ||
           encounter == 'Feature';
  }

  /// Roll for weather using proper formula: 1d6@environment_skew + type_modifier
  /// Uses current state if available, otherwise requires explicit parameters.
  WildernessWeatherResult rollWeather({int? environmentRow, int? typeRow}) {
    final envRow = environmentRow ?? _state?.environmentRow ?? 5;
    final tRow = typeRow ?? _state?.typeRow ?? 5;
    
    // Get environment skew symbol from the type table (indexed by environment row)
    final envSkew = types[envRow - 1]['skew'] as String;
    final typeModifier = types[tRow - 1]['modifier'] as int;
    
    // Roll 1d6 with appropriate skew
    int baseRoll;
    int? secondRoll;
    
    if (envSkew == '+') {
      final result = _rollEngine.rollWithAdvantage(1, 6);
      baseRoll = result.chosenSum;
      secondRoll = result.sum2;
    } else if (envSkew == '-') {
      final result = _rollEngine.rollWithDisadvantage(1, 6);
      baseRoll = result.chosenSum;
      secondRoll = result.sum2;
    } else {
      baseRoll = _rollEngine.rollDie(6);
    }
    
    // Add modifier and clamp to 1-10
    final weatherRow = (baseRoll + typeModifier).clamp(1, 10);
    final weather = weatherTypes[weatherRow - 1];

    return WildernessWeatherResult(
      baseRoll: baseRoll,
      secondRoll: secondRoll,
      environmentSkew: envSkew,
      typeModifier: typeModifier,
      weatherRow: weatherRow,
      weather: weather,
      environment: environments[envRow - 1],
      typeName: types[tRow - 1]['name'] as String,
    );
  }

  /// Roll for natural hazard.
  WildernessDetailResult rollNaturalHazard() {
    final roll = _rollEngine.rollDie(10);
    final index = roll == 10 ? 9 : roll - 1;
    final hazard = naturalHazards[index];

    return WildernessDetailResult(
      detailType: 'Natural Hazard',
      roll: roll,
      result: hazard,
    );
  }

  /// Roll for wilderness feature.
  WildernessDetailResult rollFeature() {
    final roll = _rollEngine.rollDie(10);
    final index = roll == 10 ? 9 : roll - 1;
    final feature = features[index];

    return WildernessDetailResult(
      detailType: 'Feature',
      roll: roll,
      result: feature,
    );
  }

  /// Calculate monster level using the formula from current environment.
  /// M: 1d6+E where E is environment modifier.
  MonsterLevelResult rollMonsterLevel({int? environmentRow}) {
    final envRow = environmentRow ?? _state?.environmentRow ?? 5;
    final envIndex = (envRow - 1).clamp(0, 9);
    final formula = monsterFormulas[envIndex];
    final modifier = formula['modifier'] as int;
    final advantageType = formula['advantage'] as String;

    // Roll 1d6 with appropriate advantage
    int baseRoll;
    int? secondRoll;
    
    if (advantageType == '+') {
      final result = _rollEngine.rollWithAdvantage(1, 6);
      baseRoll = result.chosenSum;
      secondRoll = result.sum2;
    } else if (advantageType == '-') {
      final result = _rollEngine.rollWithDisadvantage(1, 6);
      baseRoll = result.chosenSum;
      secondRoll = result.sum2;
    } else {
      baseRoll = _rollEngine.rollDie(6);
    }

    final monsterLevel = baseRoll + modifier;

    return MonsterLevelResult(
      baseRoll: baseRoll,
      secondRoll: secondRoll,
      modifier: modifier,
      advantageType: advantageType,
      monsterLevel: monsterLevel,
    );
  }

  // Legacy method for backwards compatibility
  /// Generate a full wilderness area (environment + type).
  /// @deprecated Use initializeRandom() or transition() instead.
  WildernessAreaResult generateArea() {
    return initializeRandom();
  }
}

/// Persistent state for wilderness exploration
class WildernessState {
  final int environmentRow;  // 1-10
  final int typeRow;         // 1-10
  final bool isLost;         // Use d6 instead of d10 for encounters

  WildernessState({
    required this.environmentRow,
    required this.typeRow,
    required this.isLost,
  });

  String get environment => Wilderness.environments[environmentRow - 1];
  String get typeName => Wilderness.types[typeRow - 1]['name'] as String;
  int get typeModifier => Wilderness.types[typeRow - 1]['modifier'] as int;
  String get environmentSkew => Wilderness.types[environmentRow - 1]['skew'] as String;
  
  String get fullDescription => '$typeName $environment';

  @override
  String toString() => 'WildernessState($fullDescription, lost: $isLost)';
}

/// Result of generating a wilderness area.
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
  }) : super(
          type: RollType.weather, // Using weather as closest match
          description: isManualSet ? 'Set Wilderness Position' : (isTransition ? 'Wilderness Transition' : 'Wilderness Area'),
          diceResults: isManualSet ? [envRoll, typeRoll] : [...envFateDice, envRoll, typeFateDie, typeRoll],
          total: envRoll + typeRoll,
          interpretation: '$typeName $environment',
          metadata: {
            'environment': environment,
            'typeName': typeName,
            'typeModifier': typeModifier,
            'isTransition': isTransition,
            'isManualSet': isManualSet,
            if (previousEnvironment != null) 'previousEnvironment': previousEnvironment,
          },
        );

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
  }) : super(
          type: RollType.encounter,
          description: 'Wilderness Encounter',
          diceResults: secondRoll != null ? [roll, secondRoll] : [roll],
          total: roll,
          interpretation: encounter,
          metadata: {
            'encounter': encounter,
            'requiresFollowUp': requiresFollowUp,
            'dieSize': dieSize,
            'skewUsed': skewUsed,
            'wasLost': wasLost,
            'becameLost': becameLost,
            'becameFound': becameFound,
          },
        );

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
  }) : super(
          type: RollType.weather,
          description: 'Weather',
          diceResults: secondRoll != null ? [baseRoll, secondRoll] : [baseRoll],
          total: weatherRow,
          interpretation: weather,
          metadata: {
            'baseRoll': baseRoll,
            'environmentSkew': environmentSkew,
            'typeModifier': typeModifier,
            'weatherRow': weatherRow,
            'weather': weather,
            'environment': environment,
            'typeName': typeName,
          },
        );

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
  }) : super(
          type: RollType.weather,
          description: detailType,
          diceResults: [roll],
          total: roll,
          interpretation: result,
          metadata: {
            'detailType': detailType,
            'result': result,
          },
        );

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
  }) : super(
          type: RollType.encounter,
          description: 'Monster Level',
          diceResults: secondRoll != null ? [baseRoll, secondRoll] : [baseRoll],
          total: monsterLevel,
          interpretation: 'Level $monsterLevel (+$modifier@$advantageType)',
          metadata: {
            'baseRoll': baseRoll,
            'modifier': modifier,
            'advantageType': advantageType,
            'monsterLevel': monsterLevel,
          },
        );

  @override
  String toString() => 'Monster Level: $monsterLevel (1d6+$modifier@$advantageType)';
}
