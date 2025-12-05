import '../core/roll_engine.dart';
import '../models/roll_result.dart';
import 'wilderness.dart';

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

  /// Dungeon types - d10 (from natural-hazard-feature-dungeon.md)
  /// Format: "[Dungeon] of the [Description] [Subject]"
  static const List<String> dungeonTypes = [
    'Catacombs',   // 1
    'Cavern',      // 2
    'Crypt',       // 3
    'Fortress',    // 4
    'Hideout',     // 5
    'Lair',        // 6
    'Mine',        // 7
    'Ruins',       // 8
    'Sanctuary',   // 9
    'Temple',      // 0/10
  ];

  /// Dungeon name descriptions - d10 (from natural-hazard-feature-dungeon.md)
  static const List<String> dungeonDescriptions = [
    'Bloodstained',  // 1
    'Chaotic',       // 2
    'Endless',       // 3
    'Fallen',        // 4
    'Forbidden',     // 5
    'Forgotten',     // 6
    'Shattered',     // 7
    'Shrouded',      // 8
    'Silent',        // 9
    'Unknown',       // 0/10
  ];

  /// Dungeon name subjects - d10 (from natural-hazard-feature-dungeon.md)
  static const List<String> dungeonSubjects = [
    'Blades',     // 1
    'Blight',     // 2
    'Darkness',   // 3
    'Fury',       // 4
    'Lies',       // 5
    'Madness',    // 6
    'Mist',       // 7
    'Prophecy',   // 8
    'Runes',      // 9
    'Terror',     // 0/10
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
/// Format: "[Dungeon] of the [Description] [Subject]"
class DungeonNameResult extends RollResult {
  final int typeRoll;
  final String dungeonType;
  final int descriptionRoll;
  final String descriptionWord;
  final int subjectRoll;
  final String subject;

  DungeonNameResult({
    required this.typeRoll,
    required this.dungeonType,
    required this.descriptionRoll,
    required String description,
    required this.subjectRoll,
    required this.subject,
    DateTime? timestamp,
  }) : descriptionWord = description,
       super(
          type: RollType.dungeon,
          description: 'Dungeon Name',
          diceResults: [typeRoll, descriptionRoll, subjectRoll],
          total: typeRoll + descriptionRoll + subjectRoll,
          interpretation: '$dungeonType of the $description $subject',
          timestamp: timestamp,
          metadata: {
            'dungeonType': dungeonType,
            'description': description,
            'subject': subject,
          },
        );

  @override
  String get className => 'DungeonNameResult';

  factory DungeonNameResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return DungeonNameResult(
      typeRoll: diceResults[0],
      dungeonType: meta['dungeonType'] as String,
      descriptionRoll: diceResults[1],
      description: meta['description'] as String,
      subjectRoll: diceResults[2],
      subject: meta['subject'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  String get name => '$dungeonType of the $descriptionWord $subject';

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
    DateTime? timestamp,
  }) : super(
          type: RollType.dungeon,
          description: 'Dungeon Area (${phase.displayText})',
          diceResults: [roll1, roll2],
          total: chosenRoll,
          interpretation: _buildInterpretation(areaType, isDoubles, phase),
          timestamp: timestamp,
          metadata: {
            'phase': phase.name,
            'areaType': areaType,
            'isDoubles': isDoubles,
            'phaseChange': phaseChange,
          },
        );

  @override
  String get className => 'DungeonAreaResult';

  factory DungeonAreaResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return DungeonAreaResult(
      phase: DungeonPhase.values.firstWhere(
        (p) => p.name == meta['phase'],
        orElse: () => DungeonPhase.entering,
      ),
      roll1: diceResults[0],
      roll2: diceResults.length > 1 ? diceResults[1] : diceResults[0],
      chosenRoll: json['total'] as int,
      areaType: meta['areaType'] as String,
      isDoubles: meta['isDoubles'] as bool,
      phaseChange: meta['phaseChange'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

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
    DateTime? timestamp,
  }) : super(
          type: RollType.dungeon,
          description: description ?? 'Dungeon $detailType',
          diceResults: diceResultsList ?? [roll],
          total: roll,
          interpretation: result,
          timestamp: timestamp,
          metadata: {
            'detailType': detailType,
            'result': result,
          },
        );

  @override
  String get className => 'DungeonDetailResult';

  factory DungeonDetailResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return DungeonDetailResult(
      detailType: meta['detailType'] as String,
      roll: diceResults[0],
      result: meta['result'] as String,
      diceResultsList: diceResults,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

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
    DateTime? timestamp,
  }) : super(
          type: RollType.dungeon,
          description: 'Dungeon Area',
          diceResults: [...area.diceResults, ...condition.diceResults],
          total: area.total + condition.total,
          interpretation: '${area.areaType} (${condition.result})',
          timestamp: timestamp,
          metadata: {
            'area': area.metadata,
            'condition': condition.metadata,
          },
        );

  @override
  String get className => 'FullDungeonAreaResult';

  factory FullDungeonAreaResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    // Cannot fully reconstruct nested objects
    throw UnimplementedError('FullDungeonAreaResult.fromJson requires full nested data');
  }

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
    DateTime? timestamp,
  }) : super(
          type: RollType.dungeon,
          description: 'Dungeon Monster',
          diceResults: [descriptorRoll, abilityRoll],
          total: descriptorRoll + abilityRoll,
          interpretation: '$descriptor creature with $ability',
          timestamp: timestamp,
          metadata: {
            'descriptor': descriptor,
            'ability': ability,
          },
        );

  @override
  String get className => 'DungeonMonsterResult';

  factory DungeonMonsterResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return DungeonMonsterResult(
      descriptorRoll: diceResults[0],
      descriptor: meta['descriptor'] as String,
      abilityRoll: diceResults[1],
      ability: meta['ability'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

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
    DateTime? timestamp,
  }) : super(
          type: RollType.dungeon,
          description: 'Dungeon Trap',
          diceResults: [actionRoll, subjectRoll],
          total: actionRoll + subjectRoll,
          interpretation: '$action trap with $subject',
          timestamp: timestamp,
          metadata: {
            'action': action,
            'subject': subject,
          },
        );

  @override
  String get className => 'DungeonTrapResult';

  factory DungeonTrapResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return DungeonTrapResult(
      actionRoll: diceResults[0],
      action: meta['action'] as String,
      subjectRoll: diceResults[1],
      subject: meta['subject'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

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
  final DungeonDetailResult? naturalHazard;

  DungeonEncounterResult({
    required this.encounterRoll,
    this.monster,
    this.trap,
    this.feature,
    this.naturalHazard,
    DateTime? timestamp,
  }) : super(
          type: RollType.dungeon,
          description: 'Dungeon Encounter',
          diceResults: [
            ...encounterRoll.diceResults,
            if (monster != null) ...monster.diceResults,
            if (trap != null) ...trap.diceResults,
            if (feature != null) ...feature.diceResults,
            if (naturalHazard != null) ...naturalHazard.diceResults,
          ],
          total: encounterRoll.roll,
          interpretation: _buildInterpretation(encounterRoll, monster, trap, feature, naturalHazard),
          timestamp: timestamp,
          metadata: {
            'encounterType': encounterRoll.result,
            if (monster != null) 'monster': monster.metadata,
            if (trap != null) 'trap': trap.metadata,
            if (feature != null) 'feature': feature.metadata,
            if (naturalHazard != null) 'naturalHazard': naturalHazard.metadata,
          },
        );

  @override
  String get className => 'DungeonEncounterResult';

  factory DungeonEncounterResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    // Cannot fully reconstruct nested objects
    throw UnimplementedError('DungeonEncounterResult.fromJson requires full nested data');
  }

  static String _buildInterpretation(
    DungeonDetailResult encounter,
    DungeonMonsterResult? monster,
    DungeonTrapResult? trap,
    DungeonDetailResult? feature,
    DungeonDetailResult? naturalHazard,
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
    if (naturalHazard != null) {
      buffer.write(': ${naturalHazard.result}');
    }
    return buffer.toString();
  }

  @override
  String toString() {
    final buffer = StringBuffer('Encounter: ${encounterRoll.result}');
    if (monster != null) buffer.write(' - ${monster!.monsterDescription}');
    if (trap != null) buffer.write(' - ${trap!.trapDescription}');
    if (feature != null) buffer.write(' - ${feature!.result}');
    if (naturalHazard != null) buffer.write(' - ${naturalHazard!.result}');
    return buffer.toString();
  }
}

/// Result of Two-Pass dungeon area generation (for map pre-generation).
/// Does not include encounter rolls - only area, passage, and condition.
class TwoPassAreaResult extends RollResult {
  final int roll1;
  final int roll2;
  final int chosenRoll;
  final String areaType;
  final bool isDoubles;
  final bool hadFirstDoubles;
  final bool isSecondDoubles;
  final bool stopMapGeneration;
  final DungeonDetailResult condition;
  final DungeonDetailResult? passage;

  TwoPassAreaResult({
    required this.roll1,
    required this.roll2,
    required this.chosenRoll,
    required this.areaType,
    required this.isDoubles,
    required this.hadFirstDoubles,
    required this.isSecondDoubles,
    required this.stopMapGeneration,
    required this.condition,
    this.passage,
    DateTime? timestamp,
  }) : super(
          type: RollType.dungeon,
          description: _buildDescription(hadFirstDoubles, isSecondDoubles),
          diceResults: [
            roll1,
            roll2,
            ...condition.diceResults,
            if (passage != null) ...passage.diceResults,
          ],
          total: chosenRoll,
          interpretation: _buildInterpretation(
            areaType, 
            condition, 
            passage, 
            isDoubles, 
            hadFirstDoubles, 
            isSecondDoubles,
          ),
          timestamp: timestamp,
          metadata: {
            'areaType': areaType,
            'isDoubles': isDoubles,
            'isSecondDoubles': isSecondDoubles,
            'stopMapGeneration': stopMapGeneration,
            'condition': condition.metadata,
            if (passage != null) 'passage': passage.metadata,
          },
        );

  @override
  String get className => 'TwoPassAreaResult';

  factory TwoPassAreaResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    // Cannot fully reconstruct nested objects
    throw UnimplementedError('TwoPassAreaResult.fromJson requires full nested data');
  }

  static String _buildDescription(bool hadFirstDoubles, bool isSecondDoubles) {
    if (isSecondDoubles) {
      return 'Two-Pass Map (2nd DOUBLES - STOP!)';
    } else if (hadFirstDoubles) {
      return 'Two-Pass Map (1d10@- after 1st doubles)';
    } else {
      return 'Two-Pass Map (1d10@+ until 1st doubles)';
    }
  }

  static String _buildInterpretation(
    String areaType,
    DungeonDetailResult condition,
    DungeonDetailResult? passage,
    bool isDoubles,
    bool hadFirstDoubles,
    bool isSecondDoubles,
  ) {
    final buffer = StringBuffer('$areaType (${condition.result})');
    if (passage != null) {
      buffer.write(' via ${passage.result}');
    }
    if (isSecondDoubles) {
      buffer.write(' [2nd DOUBLES - All unrevealed paths become Small Chamber: 1 Door]');
    } else if (isDoubles && !hadFirstDoubles) {
      buffer.write(' [DOUBLES - Switch to @- for remaining areas]');
    }
    return buffer.toString();
  }

  @override
  String toString() {
    final buffer = StringBuffer('Two-Pass: $areaType');
    if (isSecondDoubles) {
      buffer.write(' [STOP MAP GENERATION]');
    } else if (isDoubles && !hadFirstDoubles) {
      buffer.write(' [1st DOUBLES - switch to @-]');
    }
    return buffer.toString();
  }
}

/// Result of the Trap Procedure.
/// 
/// Trap Procedure workflow (from Juice instructions):
/// 1. BEFORE rolling encounter: decide if searching (10 min) or not
/// 2. If searching: Active Perception @+ vs DC
///    - Pass: AVOID (find and completely bypass the trap)
///    - Fail: LOCATE (find the trap, must disarm/bypass)
/// 3. If NOT searching: Passive Perception vs DC
///    - Pass: LOCATE (find the trap, must disarm/bypass)
///    - Fail: TRIGGER (suffer the consequences)
/// 
/// Notes:
/// - Searching takes 10 minutes
/// - Any action in a room takes 10 minutes
/// - Lingering >10 min in non-Safety room = roll another encounter (d6)
/// - For parties: only one character needs to search
///   - If no one searches, randomly pick who triggers on fail
class TrapProcedureResult extends RollResult {
  final DungeonTrapResult trap;
  final bool isSearching;
  final int dcRoll;
  final List<int> dcRolls;
  final int dc;
  final AdvantageType dcSkew;

  TrapProcedureResult({
    required this.trap,
    required this.isSearching,
    required this.dcRoll,
    required this.dcRolls,
    required this.dc,
    required this.dcSkew,
    DateTime? timestamp,
  }) : super(
          type: RollType.dungeon,
          description: 'Trap Procedure',
          diceResults: [
            ...trap.diceResults,
            ...dcRolls,
          ],
          total: dc,
          interpretation: _buildInterpretation(trap, isSearching, dc, dcSkew),
          timestamp: timestamp,
          metadata: {
            'trap': trap.metadata,
            'isSearching': isSearching,
            'dc': dc,
            'dcSkew': dcSkew.name,
            'passOutcome': isSearching ? 'AVOID' : 'LOCATE',
            'failOutcome': isSearching ? 'LOCATE' : 'TRIGGER',
          },
        );

  @override
  String get className => 'TrapProcedureResult';

  factory TrapProcedureResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    // Cannot fully reconstruct nested objects
    throw UnimplementedError('TrapProcedureResult.fromJson requires full nested data');
  }

  static String _buildInterpretation(
    DungeonTrapResult trap,
    bool isSearching,
    int dc,
    AdvantageType dcSkew,
  ) {
    final buffer = StringBuffer();
    buffer.write('${trap.trapDescription}\n');
    buffer.write('Perception DC $dc');
    if (dcSkew != AdvantageType.none) {
      buffer.write(' (${dcSkew == AdvantageType.advantage ? 'Easy' : 'Hard'})');
    }
    buffer.write('\n');
    if (isSearching) {
      buffer.write('Searching (10 min, @+): Pass=AVOID, Fail=LOCATE');
    } else {
      buffer.write('Passive Perception: Pass=LOCATE, Fail=TRIGGER');
    }
    return buffer.toString();
  }

  /// What happens on a passed perception check
  String get passOutcome => isSearching ? 'AVOID' : 'LOCATE';
  
  /// What happens on a failed perception check  
  String get failOutcome => isSearching ? 'LOCATE' : 'TRIGGER';
  
  /// Description of AVOID outcome
  static const String avoidDescription = 
      'You find the trap and completely bypass it. No issues.';
  
  /// Description of LOCATE outcome
  static const String locateDescription = 
      'You find the trap but must disarm or bypass it.';
  
  /// Description of TRIGGER outcome
  static const String triggerDescription = 
      'You trigger the trap and suffer the consequences.';

  @override
  String toString() {
    final buffer = StringBuffer('Trap: ${trap.trapDescription}');
    buffer.write(' [DC $dc]');
    buffer.write(isSearching ? ' (Search: Avoid/Locate)' : ' (Passive: Locate/Trigger)');
    return buffer.toString();
  }
}
