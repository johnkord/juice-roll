import '../core/roll_engine.dart';
import '../models/roll_result.dart';

/// Dungeon Generator preset for the Juice Oracle.
/// Uses a two-phase stateful generation system from dungeon-generator.md.
/// 
/// Phase 1 (Entering): Roll 1d10 with disadvantage (@-)
/// - Continue rolling until you get doubles
/// - Doubles indicate transition to Phase 2
/// 
/// Phase 2 (Exploring): Roll 1d10 with advantage (@+)
/// - Continue until conditions change
class DungeonGenerator {
  final RollEngine _rollEngine;

  /// Next Area results - d10
  static const List<String> areaTypes = [
    'Passage',        // 1
    'Chamber',        // 2
    'Chamber',        // 3
    'Locked',         // 4
    'Locked',         // 5
    'Vertical',       // 6
    'Vertical',       // 7
    'Exit',           // 8
    'Exit',           // 9
    'Boss/Treasure',  // 10
  ];

  /// Passage details - d10
  static const List<String> passageTypes = [
    'Dead End',           // 1
    'Narrow Crawlspace',  // 2
    'Stairs',             // 3
    'Slope',              // 4
    'T-Intersection',     // 5
    'Crossroads',         // 6
    'Bridge',             // 7
    'Flooded',            // 8
    'Collapsed',          // 9
    'Hidden Door',        // 10
  ];

  /// Room condition - d10
  static const List<String> roomConditions = [
    'Collapsed',   // 1
    'Flooded',     // 2
    'Burned',      // 3
    'Overgrown',   // 4
    'Ransacked',   // 5
    'Normal',      // 6
    'Pristine',    // 7
    'Converted',   // 8
    'Decorated',   // 9
    'Trapped',     // 10
  ];

  /// Dungeon name descriptors - d10
  static const List<String> dungeonDescriptors = [
    'Bloodstained',  // 1
    'Chaotic',       // 2
    'Cursed',        // 3
    'Fallen',        // 4
    'Frozen',        // 5
    'Hidden',        // 6
    'Lost',          // 7
    'Ruined',        // 8
    'Sacred',        // 9
    'Silent',        // 10
  ];

  /// Dungeon name subjects - d10
  static const List<String> dungeonSubjects = [
    'Blades',    // 1
    'Blight',    // 2
    'Darkness',  // 3
    'Doom',      // 4
    'Dread',     // 5
    'Eyes',      // 6
    'Flame',     // 7
    'Shadows',   // 8
    'Souls',     // 9
    'Whispers',  // 10
  ];

  // ============ DUNGEON ENCOUNTER TABLES ============

  /// Dungeon encounter types - d10
  /// Italicized entries (*) are the primary encounter types
  static const List<String> encounterTypes = [
    'Monster',         // 1 (primary)
    'Natural Hazard',  // 2 (primary)
    'Challenge',       // 3 (primary)
    'Immersion',       // 4 (primary)
    'Safety',          // 5
    'Known / None',    // 6
    'Trap',            // 7 (primary)
    'Feature',         // 8 (primary)
    'Key',             // 9
    'Treasure',        // 0/10 (primary)
  ];

  /// Monster descriptors - Column 1 of Monster table
  static const List<String> monsterDescriptors = [
    'Agile',        // 1
    'Beast',        // 2
    'Clothed',      // 3
    'Composite',    // 4
    'Decayed',      // 5
    'Elemental',    // 6
    'Inscribed',    // 7
    'Intimidating', // 8
    'Levitating',   // 9
    'Nightmarish',  // 0/10
  ];

  /// Monster special abilities - Column 2 of Monster table
  static const List<String> monsterAbilities = [
    'Climb',     // 1
    'Detect',    // 2
    'Drain',     // 3
    'Entangle',  // 4
    'Illusion',  // 5
    'Immune',    // 6
    'Magic',     // 7
    'Paralyze',  // 8
    'Pierce',    // 9
    'Ranged',    // 0/10
  ];

  /// Trap methods - Column 1 of Trap table
  static const List<String> trapMethods = [
    'Ambush',    // 1
    'Collapse',  // 2
    'Divert',    // 3
    'Imitate',   // 4
    'Lure',      // 5
    'Obscure',   // 6
    'Summon',    // 7
    'Surprise',  // 8
    'Surround',  // 9
    'Trigger',   // 0/10
  ];

  /// Trap effects - Column 2 of Trap table
  static const List<String> trapEffects = [
    'Alarm',      // 1
    'Barrier',    // 2
    'Decay',      // 3
    'Denizen',    // 4
    'Fall',       // 5
    'Fire',       // 6
    'Light',      // 7
    'Path',       // 8
    'Poison',     // 9
    'Projectile', // 0/10
  ];

  /// Feature types - d10
  static const List<String> featureTypes = [
    'Library',    // 1
    'Mural',      // 2
    'Mushrooms',  // 3
    'Prison',     // 4
    'Runes',      // 5
    'Shrine',     // 6
    'Storage',    // 7
    'Vault',      // 8
    'Well',       // 9
    'Workshop',   // 0/10
  ];

  /// Trap timing info: 10m intervals, 1d6 (NH: d6)
  /// AP@+ for Alarm/Lure, PP for Lock/Trap
  static const String trapTimingInfo = '10m: 1d6 (NH: d6); Trap: 10m AP@+ A/L, PP L/T';

  DungeonGenerator([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  /// Generate a dungeon name (2d10).
  DungeonNameResult generateName() {
    final descRoll = _rollEngine.rollDie(10);
    final subjRoll = _rollEngine.rollDie(10);

    final descriptor = dungeonDescriptors[descRoll - 1];
    final subject = dungeonSubjects[subjRoll - 1];

    return DungeonNameResult(
      descriptorRoll: descRoll,
      descriptor: descriptor,
      subjectRoll: subjRoll,
      subject: subject,
    );
  }

  /// Generate the next dungeon area.
  /// [isEntering] determines which phase: true = entering (1d10@-), false = exploring (1d10@+)
  DungeonAreaResult generateNextArea({bool isEntering = true}) {
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

    return DungeonAreaResult(
      phase: isEntering ? DungeonPhase.entering : DungeonPhase.exploring,
      roll1: result.sum1,
      roll2: result.sum2,
      chosenRoll: areaRoll,
      areaType: areaType,
      isDoubles: isDoubles,
      phaseChange: isDoubles,
    );
  }

  /// Generate passage details.
  DungeonDetailResult generatePassage() {
    final roll = _rollEngine.rollDie(10);
    final passage = passageTypes[roll - 1];

    return DungeonDetailResult(
      detailType: 'Passage',
      roll: roll,
      result: passage,
    );
  }

  /// Generate room condition.
  DungeonDetailResult generateCondition() {
    final roll = _rollEngine.rollDie(10);
    final condition = roomConditions[roll - 1];

    return DungeonDetailResult(
      detailType: 'Condition',
      roll: roll,
      result: condition,
    );
  }

  /// Generate a complete area (area type + condition).
  FullDungeonAreaResult generateFullArea({bool isEntering = true}) {
    final area = generateNextArea(isEntering: isEntering);
    final condition = generateCondition();

    return FullDungeonAreaResult(
      area: area,
      condition: condition,
    );
  }

  // ============ DUNGEON ENCOUNTER METHODS ============

  /// Roll for dungeon encounter type (1d10)
  DungeonDetailResult rollEncounterType() {
    final roll = _rollEngine.rollDie(10);
    final encounterType = encounterTypes[roll - 1];

    return DungeonDetailResult(
      detailType: 'Encounter',
      roll: roll,
      result: encounterType,
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

  /// Generate a trap (2d10 for method + effect)
  DungeonTrapResult rollTrap() {
    final methodRoll = _rollEngine.rollDie(10);
    final effectRoll = _rollEngine.rollDie(10);

    final method = trapMethods[methodRoll - 1];
    final effect = trapEffects[effectRoll - 1];

    return DungeonTrapResult(
      methodRoll: methodRoll,
      method: method,
      effectRoll: effectRoll,
      effect: effect,
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

  /// Generate a full dungeon encounter based on encounter type
  DungeonEncounterResult rollFullEncounter() {
    final encounterRoll = rollEncounterType();
    final encounterType = encounterRoll.result;

    DungeonMonsterResult? monster;
    DungeonTrapResult? trap;
    DungeonDetailResult? feature;

    // Based on encounter type, roll for additional details
    if (encounterType == 'Monster') {
      monster = rollMonsterDescription();
    } else if (encounterType == 'Trap') {
      trap = rollTrap();
    } else if (encounterType == 'Feature') {
      feature = rollFeature();
    }

    return DungeonEncounterResult(
      encounterRoll: encounterRoll,
      monster: monster,
      trap: trap,
      feature: feature,
    );
  }
}

/// Dungeon exploration phases.
enum DungeonPhase {
  entering,   // Roll with disadvantage until doubles
  exploring,  // Roll with advantage after doubles
}

extension DungeonPhaseDisplay on DungeonPhase {
  String get displayText {
    switch (this) {
      case DungeonPhase.entering:
        return 'Entering (1d10@-)';
      case DungeonPhase.exploring:
        return 'Exploring (1d10@+)';
    }
  }
}

/// Result of dungeon name generation.
class DungeonNameResult extends RollResult {
  final int descriptorRoll;
  final String descriptor;
  final int subjectRoll;
  final String subject;

  DungeonNameResult({
    required this.descriptorRoll,
    required this.descriptor,
    required this.subjectRoll,
    required this.subject,
  }) : super(
          type: RollType.dungeon,
          description: 'Dungeon Name',
          diceResults: [descriptorRoll, subjectRoll],
          total: descriptorRoll + subjectRoll,
          interpretation: 'The $descriptor $subject',
          metadata: {
            'descriptor': descriptor,
            'subject': subject,
          },
        );

  String get name => 'The $descriptor $subject';

  @override
  String toString() => 'Dungeon: $name';
}

/// Result of dungeon area generation.
class DungeonAreaResult extends RollResult {
  final DungeonPhase phase;
  final int roll1;
  final int roll2;
  final int chosenRoll;
  final String areaType;
  final bool isDoubles;
  final bool phaseChange;

  DungeonAreaResult({
    required this.phase,
    required this.roll1,
    required this.roll2,
    required this.chosenRoll,
    required this.areaType,
    required this.isDoubles,
    required this.phaseChange,
  }) : super(
          type: RollType.dungeon,
          description: 'Dungeon Area (${phase.displayText})',
          diceResults: [roll1, roll2],
          total: chosenRoll,
          interpretation: _buildInterpretation(areaType, isDoubles, phase),
          metadata: {
            'phase': phase.name,
            'areaType': areaType,
            'isDoubles': isDoubles,
            'phaseChange': phaseChange,
          },
        );

  static String _buildInterpretation(String area, bool isDoubles, DungeonPhase phase) {
    if (isDoubles) {
      if (phase == DungeonPhase.entering) {
        return '$area (DOUBLES! Switch to Exploring)';
      } else {
        return '$area (DOUBLES!)';
      }
    }
    return area;
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('Dungeon Area: $areaType');
    if (isDoubles) {
      buffer.write(' [DOUBLES - Phase Change!]');
    }
    return buffer.toString();
  }
}

/// Result of dungeon detail generation.
class DungeonDetailResult extends RollResult {
  final String detailType;
  final int roll;
  final String result;

  DungeonDetailResult({
    required this.detailType,
    required this.roll,
    required this.result,
  }) : super(
          type: RollType.dungeon,
          description: 'Dungeon $detailType',
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

/// Result of full dungeon area generation.
class FullDungeonAreaResult extends RollResult {
  final DungeonAreaResult area;
  final DungeonDetailResult condition;

  FullDungeonAreaResult({
    required this.area,
    required this.condition,
  }) : super(
          type: RollType.dungeon,
          description: 'Dungeon Area',
          diceResults: [...area.diceResults, ...condition.diceResults],
          total: area.total + condition.total,
          interpretation: '${area.areaType} (${condition.result})',
          metadata: {
            'area': area.metadata,
            'condition': condition.metadata,
          },
        );

  @override
  String toString() =>
      'Dungeon: ${area.areaType} - ${condition.result}${area.isDoubles ? ' [PHASE CHANGE]' : ''}';
}

/// Result of dungeon monster description generation (2d10)
class DungeonMonsterResult extends RollResult {
  final int descriptorRoll;
  final String descriptor;
  final int abilityRoll;
  final String ability;

  DungeonMonsterResult({
    required this.descriptorRoll,
    required this.descriptor,
    required this.abilityRoll,
    required this.ability,
  }) : super(
          type: RollType.dungeon,
          description: 'Dungeon Monster',
          diceResults: [descriptorRoll, abilityRoll],
          total: descriptorRoll + abilityRoll,
          interpretation: '$descriptor creature with $ability',
          metadata: {
            'descriptor': descriptor,
            'ability': ability,
          },
        );

  String get monsterDescription => '$descriptor creature with $ability';

  @override
  String toString() => 'Monster: $monsterDescription';
}

/// Result of dungeon trap generation (2d10)
class DungeonTrapResult extends RollResult {
  final int methodRoll;
  final String method;
  final int effectRoll;
  final String effect;

  DungeonTrapResult({
    required this.methodRoll,
    required this.method,
    required this.effectRoll,
    required this.effect,
  }) : super(
          type: RollType.dungeon,
          description: 'Dungeon Trap',
          diceResults: [methodRoll, effectRoll],
          total: methodRoll + effectRoll,
          interpretation: '$method trap with $effect',
          metadata: {
            'method': method,
            'effect': effect,
          },
        );

  String get trapDescription => '$method trap with $effect';

  @override
  String toString() => 'Trap: $trapDescription';
}

/// Result of full dungeon encounter
class DungeonEncounterResult extends RollResult {
  final DungeonDetailResult encounterRoll;
  final DungeonMonsterResult? monster;
  final DungeonTrapResult? trap;
  final DungeonDetailResult? feature;

  DungeonEncounterResult({
    required this.encounterRoll,
    this.monster,
    this.trap,
    this.feature,
  }) : super(
          type: RollType.dungeon,
          description: 'Dungeon Encounter',
          diceResults: [
            ...encounterRoll.diceResults,
            if (monster != null) ...monster.diceResults,
            if (trap != null) ...trap.diceResults,
            if (feature != null) ...feature.diceResults,
          ],
          total: encounterRoll.roll,
          interpretation: _buildInterpretation(encounterRoll, monster, trap, feature),
          metadata: {
            'encounterType': encounterRoll.result,
            if (monster != null) 'monster': monster.metadata,
            if (trap != null) 'trap': trap.metadata,
            if (feature != null) 'feature': feature.metadata,
          },
        );

  static String _buildInterpretation(
    DungeonDetailResult encounter,
    DungeonMonsterResult? monster,
    DungeonTrapResult? trap,
    DungeonDetailResult? feature,
  ) {
    final buffer = StringBuffer(encounter.result);
    if (monster != null) {
      buffer.write(': ${monster.monsterDescription}');
    }
    if (trap != null) {
      buffer.write(': ${trap.trapDescription}');
    }
    if (feature != null) {
      buffer.write(': ${feature.result}');
    }
    return buffer.toString();
  }

  @override
  String toString() {
    final buffer = StringBuffer('Encounter: ${encounterRoll.result}');
    if (monster != null) buffer.write(' - ${monster!.monsterDescription}');
    if (trap != null) buffer.write(' - ${trap!.trapDescription}');
    if (feature != null) buffer.write(' - ${feature!.result}');
    return buffer.toString();
  }
}
