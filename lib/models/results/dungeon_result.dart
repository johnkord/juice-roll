import '../roll_result.dart';

/// Advantage type for dungeon rolls
enum AdvantageType { none, advantage, disadvantage }

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

/// Result of dungeon area generation.
class DungeonAreaResult extends RollResult {
  final DungeonPhase phase;
  final int roll1;
  final int roll2;
  final int chosenRoll;
  final String areaType;
  final bool isDoubles;
  final bool phaseChange;
  final DungeonDetailResult? passage;

  DungeonAreaResult({
    required this.phase,
    required this.roll1,
    required this.roll2,
    required this.chosenRoll,
    required this.areaType,
    required this.isDoubles,
    required this.phaseChange,
    this.passage,
    DateTime? timestamp,
  }) : super(
          type: RollType.dungeon,
          description: 'Dungeon Area (${phase.displayText})',
          diceResults: [
            roll1, 
            roll2,
            if (passage != null) ...passage.diceResults,
          ],
          total: chosenRoll,
          interpretation: _buildInterpretation(areaType, isDoubles, phase, passage),
          timestamp: timestamp,
          metadata: {
            'phase': phase.name,
            'areaType': areaType,
            'isDoubles': isDoubles,
            'phaseChange': phaseChange,
            if (passage != null) 'passage': passage.metadata,
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
      // Note: passage is not reconstructed from JSON for simplicity
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  static String _buildInterpretation(String area, bool isDoubles, DungeonPhase phase, DungeonDetailResult? passage) {
    final buffer = StringBuffer(area);
    if (passage != null) {
      buffer.write(': ${passage.result}');
    }
    if (isDoubles) {
      if (phase == DungeonPhase.entering) {
        buffer.write(' (DOUBLES! Switch to Exploring)');
      } else {
        buffer.write(' (DOUBLES!)');
      }
    }
    return buffer.toString();
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('Dungeon Area: $areaType');
    if (passage != null) {
      buffer.write(' - ${passage!.result}');
    }
    if (isDoubles) {
      buffer.write(' [DOUBLES - Phase Change!]');
    }
    return buffer.toString();
  }
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
            // Store complete data for reconstruction
            'areaPhase': area.phase.name,
            'areaRoll1': area.roll1,
            'areaRoll2': area.roll2,
            'areaChosenRoll': area.chosenRoll,
            'areaType': area.areaType,
            'areaIsDoubles': area.isDoubles,
            'areaPhaseChange': area.phaseChange,
            'conditionDetailType': condition.detailType,
            'conditionRoll': condition.roll,
            'conditionResult': condition.result,
            'conditionDiceResults': condition.diceResults,
          },
        );

  @override
  String get className => 'FullDungeonAreaResult';

  factory FullDungeonAreaResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final timestamp = DateTime.parse(json['timestamp'] as String);
    
    // Reconstruct DungeonAreaResult
    final area = DungeonAreaResult(
      phase: DungeonPhase.values.firstWhere(
        (p) => p.name == meta['areaPhase'],
        orElse: () => DungeonPhase.entering,
      ),
      roll1: meta['areaRoll1'] as int,
      roll2: meta['areaRoll2'] as int,
      chosenRoll: meta['areaChosenRoll'] as int,
      areaType: meta['areaType'] as String,
      isDoubles: meta['areaIsDoubles'] as bool,
      phaseChange: meta['areaPhaseChange'] as bool,
    );
    
    // Reconstruct DungeonDetailResult
    final conditionDiceResults = (meta['conditionDiceResults'] as List).cast<int>();
    final condition = DungeonDetailResult(
      detailType: meta['conditionDetailType'] as String,
      roll: meta['conditionRoll'] as int,
      result: meta['conditionResult'] as String,
      diceResultsList: conditionDiceResults,
    );
    
    return FullDungeonAreaResult(
      area: area,
      condition: condition,
      timestamp: timestamp,
    );
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
            // Encounter roll data
            'encounterType': encounterRoll.result,
            'encounterDetailType': encounterRoll.detailType,
            'encounterRoll': encounterRoll.roll,
            'encounterDiceResults': encounterRoll.diceResults,
            // Monster data (if present)
            if (monster != null) 'monsterDescriptorRoll': monster.descriptorRoll,
            if (monster != null) 'monsterDescriptor': monster.descriptor,
            if (monster != null) 'monsterAbilityRoll': monster.abilityRoll,
            if (monster != null) 'monsterAbility': monster.ability,
            // Trap data (if present)
            if (trap != null) 'trapActionRoll': trap.actionRoll,
            if (trap != null) 'trapAction': trap.action,
            if (trap != null) 'trapSubjectRoll': trap.subjectRoll,
            if (trap != null) 'trapSubject': trap.subject,
            // Feature data (if present)
            if (feature != null) 'featureDetailType': feature.detailType,
            if (feature != null) 'featureRoll': feature.roll,
            if (feature != null) 'featureResult': feature.result,
            if (feature != null) 'featureDiceResults': feature.diceResults,
            // Natural Hazard data (if present)
            if (naturalHazard != null) 'hazardDetailType': naturalHazard.detailType,
            if (naturalHazard != null) 'hazardRoll': naturalHazard.roll,
            if (naturalHazard != null) 'hazardResult': naturalHazard.result,
            if (naturalHazard != null) 'hazardDiceResults': naturalHazard.diceResults,
          },
        );

  @override
  String get className => 'DungeonEncounterResult';

  factory DungeonEncounterResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final timestamp = DateTime.parse(json['timestamp'] as String);
    
    // Reconstruct encounter roll
    final encounterDiceResults = (meta['encounterDiceResults'] as List).cast<int>();
    final encounterRoll = DungeonDetailResult(
      detailType: meta['encounterDetailType'] as String,
      roll: meta['encounterRoll'] as int,
      result: meta['encounterType'] as String,
      diceResultsList: encounterDiceResults,
    );
    
    // Reconstruct monster if present
    DungeonMonsterResult? monster;
    if (meta.containsKey('monsterDescriptorRoll')) {
      monster = DungeonMonsterResult(
        descriptorRoll: meta['monsterDescriptorRoll'] as int,
        descriptor: meta['monsterDescriptor'] as String,
        abilityRoll: meta['monsterAbilityRoll'] as int,
        ability: meta['monsterAbility'] as String,
      );
    }
    
    // Reconstruct trap if present
    DungeonTrapResult? trap;
    if (meta.containsKey('trapActionRoll')) {
      trap = DungeonTrapResult(
        actionRoll: meta['trapActionRoll'] as int,
        action: meta['trapAction'] as String,
        subjectRoll: meta['trapSubjectRoll'] as int,
        subject: meta['trapSubject'] as String,
      );
    }
    
    // Reconstruct feature if present
    DungeonDetailResult? feature;
    if (meta.containsKey('featureDetailType')) {
      final featureDiceResults = (meta['featureDiceResults'] as List).cast<int>();
      feature = DungeonDetailResult(
        detailType: meta['featureDetailType'] as String,
        roll: meta['featureRoll'] as int,
        result: meta['featureResult'] as String,
        diceResultsList: featureDiceResults,
      );
    }
    
    // Reconstruct natural hazard if present
    DungeonDetailResult? naturalHazard;
    if (meta.containsKey('hazardDetailType')) {
      final hazardDiceResults = (meta['hazardDiceResults'] as List).cast<int>();
      naturalHazard = DungeonDetailResult(
        detailType: meta['hazardDetailType'] as String,
        roll: meta['hazardRoll'] as int,
        result: meta['hazardResult'] as String,
        diceResultsList: hazardDiceResults,
      );
    }
    
    return DungeonEncounterResult(
      encounterRoll: encounterRoll,
      monster: monster,
      trap: trap,
      feature: feature,
      naturalHazard: naturalHazard,
      timestamp: timestamp,
    );
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
            // Store complete data for reconstruction
            'roll1': roll1,
            'roll2': roll2,
            'chosenRoll': chosenRoll,
            'areaType': areaType,
            'isDoubles': isDoubles,
            'hadFirstDoubles': hadFirstDoubles,
            'isSecondDoubles': isSecondDoubles,
            'stopMapGeneration': stopMapGeneration,
            // Condition data
            'conditionDetailType': condition.detailType,
            'conditionRoll': condition.roll,
            'conditionResult': condition.result,
            'conditionDiceResults': condition.diceResults,
            // Passage data (if present)
            if (passage != null) 'passageDetailType': passage.detailType,
            if (passage != null) 'passageRoll': passage.roll,
            if (passage != null) 'passageResult': passage.result,
            if (passage != null) 'passageDiceResults': passage.diceResults,
          },
        );

  @override
  String get className => 'TwoPassAreaResult';

  factory TwoPassAreaResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final timestamp = DateTime.parse(json['timestamp'] as String);
    
    // Reconstruct condition
    final conditionDiceResults = (meta['conditionDiceResults'] as List).cast<int>();
    final condition = DungeonDetailResult(
      detailType: meta['conditionDetailType'] as String,
      roll: meta['conditionRoll'] as int,
      result: meta['conditionResult'] as String,
      diceResultsList: conditionDiceResults,
    );
    
    // Reconstruct passage if present
    DungeonDetailResult? passage;
    if (meta.containsKey('passageDetailType')) {
      final passageDiceResults = (meta['passageDiceResults'] as List).cast<int>();
      passage = DungeonDetailResult(
        detailType: meta['passageDetailType'] as String,
        roll: meta['passageRoll'] as int,
        result: meta['passageResult'] as String,
        diceResultsList: passageDiceResults,
      );
    }
    
    return TwoPassAreaResult(
      roll1: meta['roll1'] as int,
      roll2: meta['roll2'] as int,
      chosenRoll: meta['chosenRoll'] as int,
      areaType: meta['areaType'] as String,
      isDoubles: meta['isDoubles'] as bool,
      hadFirstDoubles: meta['hadFirstDoubles'] as bool,
      isSecondDoubles: meta['isSecondDoubles'] as bool,
      stopMapGeneration: meta['stopMapGeneration'] as bool,
      condition: condition,
      passage: passage,
      timestamp: timestamp,
    );
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
            // Trap data for reconstruction
            'trapActionRoll': trap.actionRoll,
            'trapAction': trap.action,
            'trapSubjectRoll': trap.subjectRoll,
            'trapSubject': trap.subject,
            // Procedure data
            'isSearching': isSearching,
            'dcRoll': dcRoll,
            'dcRolls': dcRolls,
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
    final timestamp = DateTime.parse(json['timestamp'] as String);
    
    // Reconstruct trap
    final trap = DungeonTrapResult(
      actionRoll: meta['trapActionRoll'] as int,
      action: meta['trapAction'] as String,
      subjectRoll: meta['trapSubjectRoll'] as int,
      subject: meta['trapSubject'] as String,
    );
    
    return TrapProcedureResult(
      trap: trap,
      isSearching: meta['isSearching'] as bool,
      dcRoll: meta['dcRoll'] as int,
      dcRolls: (meta['dcRolls'] as List).cast<int>(),
      dc: meta['dc'] as int,
      dcSkew: AdvantageType.values.firstWhere(
        (a) => a.name == meta['dcSkew'],
        orElse: () => AdvantageType.none,
      ),
      timestamp: timestamp,
    );
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
