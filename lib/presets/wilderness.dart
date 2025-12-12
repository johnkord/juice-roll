import '../core/roll_engine.dart';
import '../data/wilderness_data.dart' as data;

// Re-export result classes for backward compatibility
export '../models/results/wilderness_result.dart';

import '../models/results/wilderness_result.dart';

/// Wilderness Generator preset for the Juice Oracle.
/// Uses wilderness-table.md for terrain, encounters, and monster generation.
/// 
/// Formula: 2dF Env → 1dF Type; W: 1d6@E+T; M: 1d6+E
/// 
/// **Stateless Design:**
/// This class is stateless - all methods take state as input and return
/// results that include any new state. State is managed externally in HomeState.
/// 
/// Benefits:
/// - Easier to test (pure functions)
/// - No hidden state mutations
/// - Single source of truth (HomeState/Session)
/// 
/// **Data Separation:**
/// Static table data is stored in data/wilderness_data.dart.
/// This class provides backward-compatible static accessors.
class Wilderness {
  final RollEngine _rollEngine;

  // ========== Static Accessors (delegate to data file) ==========
  
  /// Full environment list (d10, rows 1-10)
  static List<String> get environments => data.wildernessEnvironments;
  
  /// Type data: modifier for weather, name, and weather skew symbol
  static List<Map<String, dynamic>> get types => data.wildernessTypes;
  
  /// Encounter types (d10)
  static List<Map<String, dynamic>> get encounters => data.wildernessEncounters;
  
  /// Weather conditions (rows 1-10)
  static List<String> get weatherTypes => data.wildernessWeatherTypes;
  
  /// Monster level formulas (modifier + advantage type) by environment
  static List<Map<String, dynamic>> get monsterFormulas => data.wildernessMonsterFormulas;
  
  /// Natural hazards (d10)
  static List<String> get naturalHazards => data.wildernessNaturalHazards;
  
  /// Wilderness features (d10)
  static List<String> get features => data.wildernessFeatures;

  /// Get encounter name by index (for backwards compatibility)
  static String getEncounterName(int index) => data.getWildernessEncounterName(index);

  /// Check if encounter should be displayed in italics
  static bool isEncounterItalic(int index) => data.isWildernessEncounterItalic(index);
  
  /// For partial italic (Settlement/Camp), get the italic portion
  static String? getPartialItalic(int index) => data.getWildernessPartialItalic(index);

  Wilderness([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  /// Initialize wilderness with a random starting environment.
  /// Returns result with new state embedded in `newState`.
  WildernessAreaResult initializeRandom() {
    final envRoll = _rollEngine.rollDie(10);
    final envRow = envRoll == 10 ? 10 : envRoll;
    
    // Roll 1dF for initial type offset from environment
    final typeFate = _rollEngine.rollFateDice(1)[0];
    final typeRow = _clampTypeRow(envRow, typeFate);
    
    final newState = WildernessState(
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
      newState: newState,
    );
  }

  /// Initialize wilderness at a specific environment.
  /// Returns result with new state embedded in `newState`.
  WildernessAreaResult initializeAt(int environmentRow, {int? typeRow, bool isLost = false}) {
    final clampedEnv = environmentRow.clamp(1, 10);
    final clampedType = (typeRow ?? clampedEnv).clamp(1, 10);
    
    final newState = WildernessState(
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
      newState: newState,
    );
  }

  /// Transition to a new area using 2dF for environment + 1dF for type.
  /// Takes current state as parameter and returns result with new state.
  /// If no state provided, initializes randomly.
  WildernessAreaResult transition(WildernessState? currentState) {
    if (currentState == null) {
      return initializeRandom();
    }

    final previousEnv = currentState.environmentRow;
    final previousEnvName = environments[previousEnv - 1];
    
    // Roll 2dF for environment offset
    final envFateDice = _rollEngine.rollFateDice(2);
    final envOffset = envFateDice[0] + envFateDice[1];
    
    // Apply offset with clamping (no wrap)
    final newEnvRow = (previousEnv + envOffset).clamp(1, 10);
    
    // Roll 1dF for type offset from new environment
    final typeFate = _rollEngine.rollFateDice(1)[0];
    final newTypeRow = _clampTypeRow(newEnvRow, typeFate);
    
    final newState = WildernessState(
      environmentRow: newEnvRow,
      typeRow: newTypeRow,
      isLost: currentState.isLost,
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
      newState: newState,
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
  /// Takes current state as parameter and returns result with any state changes.
  WildernessEncounterResult rollEncounter({
    required WildernessState? currentState,
    bool? hasDangerousTerrain,
    bool? hasMapOrGuide,
  }) {
    final isLost = currentState?.isLost ?? false;
    
    // Determine die size based on lost state
    final dieSize = isLost ? 6 : 10;
    
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
    final encounterData = encounters[index];
    final encounter = encounterData['name'] as String;
    final isItalic = encounterData['isItalic'] as bool;
    final partialItalic = encounterData['partialItalic'] as String?;
    
    // Check for Lost/Found state transitions
    bool becameLost = false;
    bool becameFound = false;
    WildernessState? newState;
    
    if (currentState != null) {
      if (encounter == 'Destination/Lost' && !currentState.isLost) {
        // Became lost (caller decides whether to apply)
        becameLost = true;
      } else if (encounter == 'River/Road' && currentState.isLost) {
        // Found orientation again
        becameFound = true;
        newState = currentState.copyWith(isLost: false);
      }
    }

    return WildernessEncounterResult(
      roll: roll,
      secondRoll: secondRoll,
      encounter: encounter,
      requiresFollowUp: _requiresFollowUp(encounter),
      dieSize: dieSize,
      skewUsed: skewUsed,
      wasLost: isLost,
      becameLost: becameLost,
      becameFound: becameFound,
      isItalic: isItalic,
      partialItalic: partialItalic,
      newState: newState,
    );
  }

  bool _requiresFollowUp(String encounter) {
    return encounter == 'Natural Hazard' ||
           encounter == 'Monster' ||
           encounter == 'Weather' ||
           encounter == 'Challenge' ||
           encounter == 'Dungeon' ||
           encounter == 'Feature';
  }

  /// Roll for weather using proper formula: 1d6@environment_skew + type_modifier.
  /// Requires explicit state parameters.
  WildernessWeatherResult rollWeather({required int environmentRow, required int typeRow}) {
    final envRow = environmentRow.clamp(1, 10);
    final tRow = typeRow.clamp(1, 10);
    
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

  /// Calculate monster level using the formula from the environment.
  /// M: 1d6+E where E is environment modifier.
  MonsterLevelResult rollMonsterLevel({required int environmentRow}) {
    final envRow = environmentRow.clamp(1, 10);
    final envIndex = envRow - 1;
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

  // ========== Convenience Methods ==========
  
  /// Convenience method that takes WildernessState for weather roll.
  WildernessWeatherResult rollWeatherFromState(WildernessState state) {
    return rollWeather(
      environmentRow: state.environmentRow,
      typeRow: state.typeRow,
    );
  }
  
  /// Convenience method that takes WildernessState for monster level roll.
  MonsterLevelResult rollMonsterLevelFromState(WildernessState state) {
    return rollMonsterLevel(environmentRow: state.environmentRow);
  }

  // Legacy method for backwards compatibility
  /// Generate a full wilderness area (environment + type).
  /// @deprecated Use initializeRandom() or transition() instead.
  WildernessAreaResult generateArea() {
    return initializeRandom();
  }
}
