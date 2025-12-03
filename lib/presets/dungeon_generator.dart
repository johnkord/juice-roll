import '../core/roll_engine.dart';
import '../models/roll_result.dart';

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

/// Advantage type for dungeon rolls
enum AdvantageType { none, advantage, disadvantage }

class DungeonGenerator {
  final RollEngine _rollEngine;

  /// Next Area results - d10
  /// Disadvantage = Sprawling, Branching Dungeons
  /// Advantage = Interconnected Dungeons with many Exits
  static const List<String> areaTypes = [
    'Passage',                       // 1
    'Small Chamber: 3 Doors',        // 2
    'Large Chamber: 3 Doors',        // 3
    'Small Chamber: 2 Doors',        // 4
    'Small Chamber: 1 Door',         // 5 (dead end!)
    'Locked Door',                   // 6
    'Known / Expected',              // 7
    'Exit / Stairs',                 // 8
    'Connection to Previous Area',   // 9
    'Passage',                       // 0/10
  ];

  /// Passage details - d10
  /// Die Size: d6 = Linear Dungeons, d10 = Branching Dungeons
  /// Skew: Disadvantage = Smaller Dungeons, Advantage = Larger Dungeons
  static const List<String> passageTypes = [
    'Dead End',            // 1
    'Narrow Crawlspace',   // 2
    'Bridge',              // 3
    'Long',                // 4
    'Wide',                // 5
    'Expected',            // 6
    'Right Angle Turn',    // 7
    'Side Passage',        // 8
    '3-Way Intersection',  // 9
    '4-Way Intersection',  // 0/10
  ];

  /// Room condition - d10
  /// Die Size: d6 = Unoccupied, d10 = Occupied
  /// Skew: Disadvantage = Worse Conditions, Advantage = Better Conditions
  static const List<String> roomConditions = [
    'Partially Collapsed',    // 1
    'Holes in Floor',         // 2
    'Flooded',                // 3
    'Ashes / Burned',         // 4
    'Damaged',                // 5
    'Expected',               // 6
    'Stripped Bare',          // 7
    'Used as Campsite',       // 8
    'Converted to Other Use', // 9
    'Pristine',               // 0/10
  ];

  /// Dungeon name descriptors - d10 (first word)
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
    'Silent',        // 0/10
  ];

  /// Dungeon name subjects - d10 (second word)
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
    'Whispers',  // 0/10
  ];

  // ============ DUNGEON ENCOUNTER TABLES ============

  /// Dungeon encounter types - d10
  /// Die Size: d6 = Lingering (10+ min in unsafe area), d10 = First entry
  /// Skew: Advantage = Better Encounters, Disadvantage = Worse Encounters
  /// 
  /// Heading: 10m 1d6 (NH: d6); Trap: 10m AP@+ A/L, PP L/T
  static const List<String> encounterTypes = [
    'Monster',         // 1
    'Natural Hazard',  // 2
    'Challenge',       // 3
    'Immersion',       // 4
    'Safety',          // 5
    'Known',           // 6
    'Trap',            // 7
    'Feature',         // 8
    'Key',             // 9
    'Treasure',        // 0/10
  ];

  /// Monster descriptors - Column 1 of Monster table (d10)
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

  /// Monster special abilities - Column 2 of Monster table (d10)
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

  /// Trap actions - Column 1 of Trap table (d10)
  static const List<String> trapActions = [
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

  /// Trap subjects - Column 2 of Trap table (d10)
  static const List<String> trapSubjects = [
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

  /// Trap procedure info from heading:
  /// "10m AP@+ A/L, PP L/T"
  /// - Spend 10 minutes for Active Perception check with advantage
  /// - Pass: Avoid, Fail: Locate
  /// - Passive Perception: Pass: Locate, Fail: Trigger
  static const String trapProcedure = '''
Trap Procedure:
• Active Perception (10 min, @+): Pass = Avoid, Fail = Locate
• Passive Perception: Pass = Locate, Fail = Trigger
  - Avoid: Find and completely bypass the trap
  - Locate: Find the trap, must disarm or bypass
  - Trigger: Suffer the consequences''';

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
  FullDungeonAreaResult generateFullArea({
    bool isEntering = true,
    bool isOccupied = true,
    AdvantageType conditionSkew = AdvantageType.none,
  }) {
    final area = generateNextArea(isEntering: isEntering);
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

  /// Generate a full dungeon encounter based on encounter type.
  /// [isLingering] if true, uses d6 (lingering in unsafe area 10+ min).
  /// [skew] determines encounter quality: advantage = better, disadvantage = worse.
  DungeonEncounterResult rollFullEncounter({bool isLingering = false, AdvantageType skew = AdvantageType.none}) {
    final encounterRoll = rollEncounterType(isLingering: isLingering, skew: skew);
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
    String? description,
    List<int>? diceResultsList,
  }) : super(
          type: RollType.dungeon,
          description: description ?? 'Dungeon $detailType',
          diceResults: diceResultsList ?? [roll],
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
  final int actionRoll;
  final String action;
  final int subjectRoll;
  final String subject;

  DungeonTrapResult({
    required this.actionRoll,
    required this.action,
    required this.subjectRoll,
    required this.subject,
  }) : super(
          type: RollType.dungeon,
          description: 'Dungeon Trap',
          diceResults: [actionRoll, subjectRoll],
          total: actionRoll + subjectRoll,
          interpretation: '$action trap with $subject',
          metadata: {
            'action': action,
            'subject': subject,
          },
        );

  String get trapDescription => '$action trap with $subject';

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
