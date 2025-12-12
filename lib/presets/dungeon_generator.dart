import '../core/roll_engine.dart';
import '../data/dungeon_data.dart' as data;
import 'wilderness.dart';

// Re-export result classes for backward compatibility
export '../models/results/dungeon_result.dart';

import '../models/results/dungeon_result.dart';

/// Dungeon Generator preset for the Juice Oracle.
/// Uses a two-phase stateful generation system.
/// 
/// Heading: NA: 1d10@- Until Doubles, Then NA: 1d10@+
/// 
/// Phase 1 (Entering): Roll 1d10 with disadvantage (@-)
/// - Continue rolling until you get doubles
/// - Doubles indicate transition to Phase 2
/// 
/// Phase 2 (Exploring): Roll 1d10 with advantage (@+)
/// - Continue with advantage after doubles are rolled
/// 
/// Skew Effects:
/// - Disadvantage: Sprawling, Branching Dungeons
/// - Advantage: Interconnected Dungeons with many Exits
/// 
/// **Data Separation:**
/// Static table data is stored in data/dungeon_data.dart.
/// This class provides backward-compatible static accessors.

class DungeonGenerator {
  final RollEngine _rollEngine;

  // ========== Static Accessors (delegate to data file) ==========

  /// Next Area results - d10
  static List<String> get areaTypes => data.dungeonAreaTypes;

  /// Passage details - d10
  static List<String> get passageTypes => data.dungeonPassageTypes;

  /// Room condition - d10
  static List<String> get roomConditions => data.dungeonRoomConditions;

  /// Dungeon types - d10
  static List<String> get dungeonTypes => data.dungeonTypes;

  /// Dungeon name descriptions - d10
  static List<String> get dungeonDescriptions => data.dungeonDescriptions;

  /// Dungeon name subjects - d10
  static List<String> get dungeonSubjects => data.dungeonSubjects;

  /// Dungeon encounter types - d10
  static List<String> get encounterTypes => data.dungeonEncounterTypes;

  /// Monster descriptors - Column 1 of Monster table (d10)
  static List<String> get monsterDescriptors => data.dungeonMonsterDescriptors;

  /// Monster special abilities - Column 2 of Monster table (d10)
  static List<String> get monsterAbilities => data.dungeonMonsterAbilities;

  /// Trap actions - Column 1 of Trap table (d10)
  static List<String> get trapActions => data.dungeonTrapActions;

  /// Trap subjects - Column 2 of Trap table (d10)
  static List<String> get trapSubjects => data.dungeonTrapSubjects;

  /// Feature types - d10
  static List<String> get featureTypes => data.dungeonFeatureTypes;

  /// Trap procedure info
  static String get trapProcedure => data.dungeonTrapProcedure;

  DungeonGenerator([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  /// Generate a dungeon name (3d10).
  /// Format: "[Dungeon] of the [Description] [Subject]"
  /// Example: "Ruins of the Shattered Lies"
  DungeonNameResult generateName() {
    final typeRoll = _rollEngine.rollDie(10);
    final descRoll = _rollEngine.rollDie(10);
    final subjRoll = _rollEngine.rollDie(10);

    final dungeonType = dungeonTypes[typeRoll - 1];
    final description = dungeonDescriptions[descRoll - 1];
    final subject = dungeonSubjects[subjRoll - 1];

    return DungeonNameResult(
      typeRoll: typeRoll,
      dungeonType: dungeonType,
      descriptionRoll: descRoll,
      description: description,
      subjectRoll: subjRoll,
      subject: subject,
    );
  }

  /// Generate the next dungeon area.
  /// [isEntering] determines which phase: true = entering (1d10@-), false = exploring (1d10@+)
  /// [includePassage] if true and area is "Passage", also rolls on Passage table and embeds result
  /// [useD6ForPassage] for linear dungeons (d6) vs branching (d10)
  /// [passageSkew] determines passage size: disadvantage = smaller, advantage = larger
  DungeonAreaResult generateNextArea({
    bool isEntering = true,
    bool includePassage = false,
    bool useD6ForPassage = false,
    AdvantageType passageSkew = AdvantageType.none,
  }) {
    final RollWithAdvantageResult result;
    
    if (isEntering) {
      // Phase 1: Roll with disadvantage
      result = _rollEngine.rollWithDisadvantage(1, 10);
    } else {
      // Phase 2: Roll with advantage
      result = _rollEngine.rollWithAdvantage(1, 10);
    }
    
    final areaRoll = result.chosenSum;
    final areaType = areaTypes[areaRoll - 1];
    
    // Check for doubles (triggers phase change)
    final isDoubles = result.sum1 == result.sum2;
    
    // If area is Passage and includePassage is true, roll on Passage table
    DungeonDetailResult? passage;
    if (includePassage && areaType == 'Passage') {
      passage = generatePassage(useD6: useD6ForPassage, skew: passageSkew);
    }

    return DungeonAreaResult(
      phase: isEntering ? DungeonPhase.entering : DungeonPhase.exploring,
      roll1: result.sum1,
      roll2: result.sum2,
      chosenRoll: areaRoll,
      areaType: areaType,
      isDoubles: isDoubles,
      phaseChange: isDoubles,
      passage: passage,
    );
  }

  /// Generate passage details.
  /// [useD6] for linear dungeons, d10 for branching dungeons.
  /// [skew] determines dungeon size: disadvantage = smaller, advantage = larger.
  DungeonDetailResult generatePassage({bool useD6 = false, AdvantageType skew = AdvantageType.none}) {
    final int roll;
    final List<int> diceResults;
    
    if (skew != AdvantageType.none) {
      final result = skew == AdvantageType.advantage
          ? _rollEngine.rollWithAdvantage(1, useD6 ? 6 : 10)
          : _rollEngine.rollWithDisadvantage(1, useD6 ? 6 : 10);
      roll = result.chosenSum;
      diceResults = [result.sum1, result.sum2];
    } else {
      roll = _rollEngine.rollDie(useD6 ? 6 : 10);
      diceResults = [roll];
    }
    
    final passage = passageTypes[roll - 1];
    final dieLabel = useD6 ? 'd6' : 'd10';
    final skewLabel = skew == AdvantageType.advantage ? '@+' : skew == AdvantageType.disadvantage ? '@-' : '';

    return DungeonDetailResult(
      detailType: 'Passage',
      roll: roll,
      result: passage,
      description: 'Passage ($dieLabel$skewLabel)',
      diceResultsList: diceResults,
    );
  }

  /// Generate room condition.
  /// [useD6] for unoccupied areas, d10 for occupied areas.
  /// [skew] determines condition quality: disadvantage = worse, advantage = better.
  DungeonDetailResult generateCondition({bool useD6 = false, AdvantageType skew = AdvantageType.none}) {
    final int roll;
    final List<int> diceResults;
    
    if (skew != AdvantageType.none) {
      final result = skew == AdvantageType.advantage
          ? _rollEngine.rollWithAdvantage(1, useD6 ? 6 : 10)
          : _rollEngine.rollWithDisadvantage(1, useD6 ? 6 : 10);
      roll = result.chosenSum;
      diceResults = [result.sum1, result.sum2];
    } else {
      roll = _rollEngine.rollDie(useD6 ? 6 : 10);
      diceResults = [roll];
    }
    
    final condition = roomConditions[roll - 1];
    final dieLabel = useD6 ? 'd6' : 'd10';
    final skewLabel = skew == AdvantageType.advantage ? '@+' : skew == AdvantageType.disadvantage ? '@-' : '';

    return DungeonDetailResult(
      detailType: 'Condition',
      roll: roll,
      result: condition,
      description: 'Condition ($dieLabel$skewLabel)',
      diceResultsList: diceResults,
    );
  }

  /// Generate a complete area (area type + condition).
  /// [isEntering] determines phase: true = entering (1d10@-), false = exploring (1d10@+)
  /// [isOccupied] determines condition die: true = d10, false = d6
  /// [conditionSkew] determines condition quality: advantage = better, disadvantage = worse
  /// [includePassage] if true and area is "Passage", also rolls on Passage table
  /// [useD6ForPassage] for linear dungeons (d6) vs branching (d10)
  /// [passageSkew] determines passage size: disadvantage = smaller, advantage = larger
  FullDungeonAreaResult generateFullArea({
    bool isEntering = true,
    bool isOccupied = true,
    AdvantageType conditionSkew = AdvantageType.none,
    bool includePassage = false,
    bool useD6ForPassage = false,
    AdvantageType passageSkew = AdvantageType.none,
  }) {
    final area = generateNextArea(
      isEntering: isEntering,
      includePassage: includePassage,
      useD6ForPassage: useD6ForPassage,
      passageSkew: passageSkew,
    );
    final condition = generateCondition(useD6: !isOccupied, skew: conditionSkew);

    return FullDungeonAreaResult(
      area: area,
      condition: condition,
    );
  }

  // ============ DUNGEON ENCOUNTER METHODS ============

  /// Roll for dungeon encounter type.
  /// [isLingering] if true, uses d6 (lingering in unsafe area 10+ min).
  /// [skew] determines encounter quality: advantage = better, disadvantage = worse.
  DungeonDetailResult rollEncounterType({bool isLingering = false, AdvantageType skew = AdvantageType.none}) {
    final int roll;
    final List<int> diceResults;
    final dieSize = isLingering ? 6 : 10;
    
    if (skew != AdvantageType.none) {
      final result = skew == AdvantageType.advantage
          ? _rollEngine.rollWithAdvantage(1, dieSize)
          : _rollEngine.rollWithDisadvantage(1, dieSize);
      roll = result.chosenSum;
      diceResults = [result.sum1, result.sum2];
    } else {
      roll = _rollEngine.rollDie(dieSize);
      diceResults = [roll];
    }
    
    final encounterType = encounterTypes[roll - 1];
    final dieLabel = isLingering ? 'd6' : 'd10';
    final skewLabel = skew == AdvantageType.advantage ? '@+' : skew == AdvantageType.disadvantage ? '@-' : '';

    return DungeonDetailResult(
      detailType: 'Encounter',
      roll: roll,
      result: encounterType,
      description: 'Encounter ($dieLabel$skewLabel)',
      diceResultsList: diceResults,
    );
  }

  /// Generate a monster description (2d10 for descriptor + ability)
  DungeonMonsterResult rollMonsterDescription() {
    final descRoll = _rollEngine.rollDie(10);
    final abilityRoll = _rollEngine.rollDie(10);

    final descriptor = monsterDescriptors[descRoll - 1];
    final ability = monsterAbilities[abilityRoll - 1];

    return DungeonMonsterResult(
      descriptorRoll: descRoll,
      descriptor: descriptor,
      abilityRoll: abilityRoll,
      ability: ability,
    );
  }

  /// Generate a trap (2d10 for action + subject)
  DungeonTrapResult rollTrap() {
    final actionRoll = _rollEngine.rollDie(10);
    final subjectRoll = _rollEngine.rollDie(10);

    final action = trapActions[actionRoll - 1];
    final subject = trapSubjects[subjectRoll - 1];

    return DungeonTrapResult(
      actionRoll: actionRoll,
      action: action,
      subjectRoll: subjectRoll,
      subject: subject,
    );
  }

  /// Full Trap Procedure from the Juice instructions.
  /// 
  /// Procedure:
  /// 1. BEFORE rolling encounter: decide if you're searching (10 min) or not
  /// 2. If searching: Active Perception @+ vs DC
  ///    - Pass: AVOID (find and completely bypass)
  ///    - Fail: LOCATE (find but must deal with it)
  /// 3. If NOT searching: Passive Perception vs DC
  ///    - Pass: LOCATE (find but must deal with it)
  ///    - Fail: TRIGGER (suffer consequences)
  /// 
  /// Returns the trap details + DC for the perception check.
  /// [isSearching] determines the procedure path and outcome meanings.
  /// [dcSkew] allows easy/hard DC adjustment.
  TrapProcedureResult rollTrapProcedure({
    bool isSearching = true,
    AdvantageType dcSkew = AdvantageType.none,
  }) {
    // Roll the trap type
    final trap = rollTrap();
    
    // Roll a DC for the perception check
    final int dcRoll;
    final List<int> dcRolls;
    
    if (dcSkew != AdvantageType.none) {
      final roll1 = _rollEngine.rollDie(10);
      final roll2 = _rollEngine.rollDie(10);
      // Advantage = lower DC (easier), disadvantage = higher DC (harder)
      // Lower rolls = higher DC in the DC table, so:
      // - For advantage (easy), take higher roll (lower index = lower DC? No - check logic)
      // Actually: roll 1 = DC 17, roll 10 = DC 8
      // So higher roll = lower DC = easier
      if (dcSkew == AdvantageType.advantage) {
        dcRoll = roll1 > roll2 ? roll1 : roll2; // Take higher for lower DC
      } else {
        dcRoll = roll1 < roll2 ? roll1 : roll2; // Take lower for higher DC
      }
      dcRolls = [roll1, roll2];
    } else {
      dcRoll = _rollEngine.rollDie(10);
      dcRolls = [dcRoll];
    }
    
    // Convert roll to DC (same as Challenge DC table)
    // Roll 1 = DC 17, Roll 10 = DC 8
    const dcValues = [17, 16, 15, 14, 13, 12, 11, 10, 9, 8];
    final dcIndex = dcRoll == 10 ? 9 : dcRoll - 1;
    final dc = dcValues[dcIndex];
    
    return TrapProcedureResult(
      trap: trap,
      isSearching: isSearching,
      dcRoll: dcRoll,
      dcRolls: dcRolls,
      dc: dc,
      dcSkew: dcSkew,
    );
  }

  /// Roll for a dungeon feature (1d10)
  DungeonDetailResult rollFeature() {
    final roll = _rollEngine.rollDie(10);
    final feature = featureTypes[roll - 1];

    return DungeonDetailResult(
      detailType: 'Feature',
      roll: roll,
      result: feature,
    );
  }

  /// Roll for a natural hazard (1d10 on first entry, 1d6 when lingering)
  /// Uses the same Natural Hazard table from Wilderness.
  DungeonDetailResult rollNaturalHazard({bool isLingering = false}) {
    final dieSize = isLingering ? 6 : 10;
    final roll = _rollEngine.rollDie(dieSize);
    final hazard = Wilderness.naturalHazards[roll - 1];

    return DungeonDetailResult(
      detailType: 'Natural Hazard',
      roll: roll,
      result: hazard,
      description: 'Natural Hazard (d$dieSize)',
    );
  }

  /// Generate a full dungeon encounter based on encounter type.
  /// [isLingering] if true, uses d6 (lingering in unsafe area 10+ min).
  /// [skew] determines encounter quality: advantage = better, disadvantage = worse.
  DungeonEncounterResult rollFullEncounter({bool isLingering = false, AdvantageType skew = AdvantageType.none}) {
    final encounterRoll = rollEncounterType(isLingering: isLingering, skew: skew);
    final encounterType = encounterRoll.result;

    DungeonMonsterResult? monster;
    DungeonTrapResult? trap;
    DungeonDetailResult? feature;
    DungeonDetailResult? naturalHazard;

    // Based on encounter type, roll for additional details
    if (encounterType == 'Monster') {
      monster = rollMonsterDescription();
    } else if (encounterType == 'Trap') {
      trap = rollTrap();
    } else if (encounterType == 'Feature') {
      feature = rollFeature();
    } else if (encounterType == 'Natural Hazard') {
      // Roll on Natural Hazard table - uses d6 if lingering
      naturalHazard = rollNaturalHazard(isLingering: isLingering);
    }

    return DungeonEncounterResult(
      encounterRoll: encounterRoll,
      monster: monster,
      trap: trap,
      feature: feature,
      naturalHazard: naturalHazard,
    );
  }

  // ============ TWO-PASS SUPPORT METHODS ============

  /// For Two-Pass method: generates just the Next Area and Passage for map creation.
  /// Does NOT roll encounters. Returns true in phaseChange if doubles occurred.
  /// 
  /// Two-Pass rules (from Juice instructions):
  /// - Start rolling 1d10 with Advantage (@+) for map generation
  /// - First doubles: switch to 1d10 with Disadvantage (@-)
  /// - Second doubles: stop generating - all unrevealed paths become "Small Chamber: 1 Door"
  ///
  /// This is the OPPOSITE of One-Pass which starts with @- and switches to @+.
  /// Two-Pass is designed for pre-generating maps quickly (advantage first gives
  /// more interconnected maps with exits, then disadvantage adds dead ends).
  TwoPassAreaResult generateTwoPassArea({
    required bool hasFirstDoubles,
    bool useD6ForPassage = false,
    AdvantageType passageSkew = AdvantageType.none,
  }) {
    // Two-Pass: starts with ADVANTAGE (@+), switches to DISADVANTAGE (@-) after first doubles
    // This is opposite of One-Pass which starts with @- and switches to @+
    final useAdvantage = !hasFirstDoubles;
    
    final RollWithAdvantageResult result;
    if (useAdvantage) {
      result = _rollEngine.rollWithAdvantage(1, 10);
    } else {
      result = _rollEngine.rollWithDisadvantage(1, 10);
    }
    
    final areaRoll = result.chosenSum;
    final areaType = areaTypes[areaRoll - 1];
    final isDoubles = result.sum1 == result.sum2;

    // Generate passage detail if applicable
    DungeonDetailResult? passage;
    if (areaType == 'Passage') {
      passage = generatePassage(useD6: useD6ForPassage, skew: passageSkew);
    }

    // Generate condition
    final condition = generateCondition(useD6: useD6ForPassage, skew: passageSkew);

    return TwoPassAreaResult(
      roll1: result.sum1,
      roll2: result.sum2,
      chosenRoll: areaRoll,
      areaType: areaType,
      isDoubles: isDoubles,
      hadFirstDoubles: hasFirstDoubles,
      isSecondDoubles: hasFirstDoubles && isDoubles,
      stopMapGeneration: hasFirstDoubles && isDoubles,
      condition: condition,
      passage: passage,
    );
  }
}
