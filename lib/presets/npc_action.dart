import '../core/roll_engine.dart';
import '../models/roll_result.dart';
import 'details.dart';
import 'name_generator.dart';

/// NPC Disposition determines the die size for Action/Combat tables.
/// Passive NPCs roll d6, Active NPCs roll d10.
enum NpcDisposition {
  passive,  // d6 - gravitates toward helpful actions
  active,   // d10 - full range of actions including combat
}

/// NPC Context determines the skew for Action table.
/// Active context = advantage, Passive context = disadvantage.
enum NpcContext {
  passive,  // Roll with disadvantage
  active,   // Roll with advantage
}

/// NPC Focus determines the die size for Combat table.
/// Passive focus = d6, Active focus = d10.
enum NpcFocus {
  passive,  // d6 - defensive/warning actions
  active,   // d10 - full combat actions
}

/// NPC Objective determines the skew for Combat table.
/// Defensive = disadvantage, Offensive = advantage.
enum NpcObjective {
  defensive,  // Roll with disadvantage
  offensive,  // Roll with advantage
}

/// NPC Need skew for Maslow's hierarchy.
/// Disadvantage = more primitive needs, Advantage = more complex needs.
enum NeedSkew {
  none,          // Straight roll
  primitive,     // Disadvantage - basic needs (sustenance, shelter, etc.)
  complex,       // Advantage - higher needs (status, recognition, fulfillment)
}

/// NPC Action preset for the Juice Oracle.
/// Determines NPC behavior using npc-action.md tables.
/// 
/// Header notation: Disp: d 10A/6P; Ctx: @+A/-P; WH: ΔCtx, SH: ΔCtx & +/-1
/// - Disposition: d10 for Active, d6 for Passive
/// - Context: Roll with Advantage for Active, Disadvantage for Passive
/// - Weak Hit (social check): Change Context
/// - Strong Hit (social check): Change Context AND add/subtract 1 from roll
class NpcAction {
  final RollEngine _rollEngine;

  /// Personality traits - d10 (0-9 mapped to 1-10)
  static const List<String> personalities = [
    'Cautious',      // 1
    'Curious',       // 2
    'Careless',      // 3
    'Organized',     // 4
    'Reserved',      // 5
    'Outgoing',      // 6
    'Critical',      // 7
    'Compassionate', // 8
    'Confident',     // 9
    'Sensitive',     // 0/10
  ];

  /// NPC needs - d10
  static const List<String> needs = [
    'Sustenance',   // 1
    'Shelter',      // 2
    'Recovery',     // 3
    'Security',     // 4
    'Stability',    // 5
    'Friendship',   // 6
    'Acceptance',   // 7
    'Status',       // 8
    'Recognition',  // 9
    'Fulfillment',  // 0/10
  ];

  /// Motive/Topic - d10
  static const List<String> motives = [
    'History',      // 1 (italic in original - past)
    'Family',       // 2
    'Experience',   // 3
    'Flaws',        // 4
    'Reputation',   // 5
    'Superiors',    // 6
    'Wealth',       // 7
    'Equipment',    // 8
    'Treasure',     // 9
    'Focus',        // 0/10 (italic - context)
  ];

  /// Actions - d10
  static const List<String> actions = [
    'Ambiguous Action', // 1
    'Talks',            // 2
    'Continues',        // 3
    'Act: PC Interest', // 4
    'Next Most Logical',// 5
    'Gives Something',  // 6
    'End Encounter',    // 7
    'Act: Self Interest',// 8
    'Takes Something',  // 9
    'Enters Combat',    // 0/10
  ];

  /// Combat actions - d10
  static const List<String> combatActions = [
    'Defend',      // 1
    'Shift Focus', // 2
    'Seize',       // 3
    'Intimidate',  // 4
    'Advantage',   // 5
    'Coordinate',  // 6
    'Lure',        // 7
    'Destroy',     // 8
    'Precision',   // 9
    'Power',       // 0/10
  ];

  NpcAction([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  /// Helper to get index from roll (handles 10 -> 9)
  int _getIndex(int roll) => roll == 10 ? 9 : roll - 1;

  /// Roll for a single NPC action with disposition and context.
  /// 
  /// Per the instructions:
  /// - Passive Disposition: Roll d6
  /// - Active Disposition: Roll d10
  /// - Active Context: Roll with advantage
  /// - Passive Context: Roll with disadvantage
  NpcActionResult rollAction({
    NpcDisposition disposition = NpcDisposition.active,
    NpcContext context = NpcContext.active,
  }) {
    final dieSize = disposition == NpcDisposition.passive ? 6 : 10;
    int roll;
    List<int> allRolls = [];
    
    if (context == NpcContext.active) {
      // Roll with advantage
      final result = _rollEngine.rollWithAdvantage(1, dieSize);
      roll = result.chosenSum;
      allRolls = [result.sum1, result.sum2];
    } else if (context == NpcContext.passive) {
      // Roll with disadvantage
      final result = _rollEngine.rollWithDisadvantage(1, dieSize);
      roll = result.chosenSum;
      allRolls = [result.sum1, result.sum2];
    } else {
      roll = _rollEngine.rollDie(dieSize);
      allRolls = [roll];
    }
    
    final index = _getIndex(roll);
    final action = actions[index];

    return NpcActionResult(
      column: NpcColumn.action,
      roll: roll,
      result: action,
      dieSize: dieSize,
      allRolls: allRolls,
      disposition: disposition,
      context: context,
    );
  }

  /// Roll for NPC personality (2 traits recommended for primary/secondary).
  NpcActionResult rollPersonality() {
    final roll = _rollEngine.rollDie(10);
    final index = _getIndex(roll);
    final personality = personalities[index];

    return NpcActionResult(
      column: NpcColumn.personality,
      roll: roll,
      result: personality,
    );
  }

  /// Roll for NPC need with optional skew.
  /// Disadvantage = more primitive needs (sustenance, shelter)
  /// Advantage = more complex needs (status, recognition, fulfillment)
  NpcActionResult rollNeed({NeedSkew skew = NeedSkew.none}) {
    int roll;
    List<int> allRolls = [];
    
    switch (skew) {
      case NeedSkew.primitive:
        final result = _rollEngine.rollWithDisadvantage(1, 10);
        roll = result.chosenSum;
        allRolls = [result.sum1, result.sum2];
        break;
      case NeedSkew.complex:
        final result = _rollEngine.rollWithAdvantage(1, 10);
        roll = result.chosenSum;
        allRolls = [result.sum1, result.sum2];
        break;
      case NeedSkew.none:
        roll = _rollEngine.rollDie(10);
        allRolls = [roll];
    }
    
    final index = _getIndex(roll);
    final need = needs[index];

    return NpcActionResult(
      column: NpcColumn.need,
      roll: roll,
      result: need,
      allRolls: allRolls,
      needSkew: skew,
    );
  }

  /// Roll for NPC motive/topic.
  /// Note: If result is "History" or "Focus", roll on those respective tables.
  NpcActionResult rollMotive() {
    final roll = _rollEngine.rollDie(10);
    final index = _getIndex(roll);
    final motive = motives[index];

    return NpcActionResult(
      column: NpcColumn.motive,
      roll: roll,
      result: motive,
    );
  }

  /// Roll for combat action with focus and objective.
  /// 
  /// Per the instructions:
  /// - Passive Focus: Roll d6 (defensive/warning actions)
  /// - Active Focus: Roll d10 (full combat actions)
  /// - Defensive Objective: Roll with disadvantage
  /// - Offensive Objective: Roll with advantage
  NpcActionResult rollCombatAction({
    NpcFocus focus = NpcFocus.active,
    NpcObjective objective = NpcObjective.offensive,
  }) {
    final dieSize = focus == NpcFocus.passive ? 6 : 10;
    int roll;
    List<int> allRolls = [];
    
    if (objective == NpcObjective.offensive) {
      // Roll with advantage
      final result = _rollEngine.rollWithAdvantage(1, dieSize);
      roll = result.chosenSum;
      allRolls = [result.sum1, result.sum2];
    } else {
      // Roll with disadvantage
      final result = _rollEngine.rollWithDisadvantage(1, dieSize);
      roll = result.chosenSum;
      allRolls = [result.sum1, result.sum2];
    }
    
    final index = _getIndex(roll);
    final combatAction = combatActions[index];

    return NpcActionResult(
      column: NpcColumn.combat,
      roll: roll,
      result: combatAction,
      dieSize: dieSize,
      allRolls: allRolls,
      focus: focus,
      objective: objective,
    );
  }

  /// Generate a full NPC profile (personality + need + motive).
  NpcProfileResult generateProfile({NeedSkew needSkew = NeedSkew.none}) {
    final persRoll = _rollEngine.rollDie(10);
    
    // Handle need with skew
    int needRoll;
    List<int> needAllRolls = [];
    switch (needSkew) {
      case NeedSkew.primitive:
        final result = _rollEngine.rollWithDisadvantage(1, 10);
        needRoll = result.chosenSum;
        needAllRolls = [result.sum1, result.sum2];
        break;
      case NeedSkew.complex:
        final result = _rollEngine.rollWithAdvantage(1, 10);
        needRoll = result.chosenSum;
        needAllRolls = [result.sum1, result.sum2];
        break;
      case NeedSkew.none:
        needRoll = _rollEngine.rollDie(10);
        needAllRolls = [needRoll];
    }
    
    final motiveRoll = _rollEngine.rollDie(10);

    final personality = personalities[_getIndex(persRoll)];
    final need = needs[_getIndex(needRoll)];
    final motive = motives[_getIndex(motiveRoll)];

    return NpcProfileResult(
      personalityRoll: persRoll,
      personality: personality,
      needRoll: needRoll,
      need: need,
      motiveRoll: motiveRoll,
      motive: motive,
      needSkew: needSkew,
      needAllRolls: needAllRolls,
    );
  }

  /// Generate a dual personality (primary + secondary traits).
  /// Per instructions: "You can optionally give them a secondary personality trait."
  /// Example: "Confident, yet Reserved"
  DualPersonalityResult rollDualPersonality() {
    final roll1 = _rollEngine.rollDie(10);
    final roll2 = _rollEngine.rollDie(10);
    
    final primary = personalities[_getIndex(roll1)];
    final secondary = personalities[_getIndex(roll2)];
    
    return DualPersonalityResult(
      primaryRoll: roll1,
      primary: primary,
      secondaryRoll: roll2,
      secondary: secondary,
    );
  }

  /// Generate a complex NPC profile.
  /// Per instructions (page 128-129): For complex NPCs like sidekicks:
  /// - Name (via NameGenerator)
  /// - 2 Personality traits (primary, optionally secondary)
  /// - Need (with advantage for people, disadvantage for monsters)
  /// - Motive
  /// - Color (1d10)
  /// - Two Properties (1d10+1d6 each)
  /// 
  /// Example from instructions:
  /// "Demor is someone with high self esteem who always sees the best in people,
  /// and yearns for people to someday see the best in them as well. They are
  /// trying to earn money. Demor has average looks and is pretty thin."
  ComplexNpcResult generateComplexNpc({
    NeedSkew needSkew = NeedSkew.complex, // Default to @+ for people NPCs
    bool includeName = true,
    bool dualPersonality = true,
  }) {
    final details = Details(_rollEngine);
    
    // Name (optional)
    NameResult? nameResult;
    if (includeName) {
      final nameGen = NameGenerator(_rollEngine);
      nameResult = nameGen.generatePatternNeutral();
    }
    
    // Personality (1 or 2 traits)
    final persRoll1 = _rollEngine.rollDie(10);
    final primary = personalities[_getIndex(persRoll1)];
    int? persRoll2;
    String? secondary;
    if (dualPersonality) {
      persRoll2 = _rollEngine.rollDie(10);
      secondary = personalities[_getIndex(persRoll2)];
    }
    
    // Need with skew
    int needRoll;
    List<int> needAllRolls = [];
    switch (needSkew) {
      case NeedSkew.primitive:
        final result = _rollEngine.rollWithDisadvantage(1, 10);
        needRoll = result.chosenSum;
        needAllRolls = [result.sum1, result.sum2];
        break;
      case NeedSkew.complex:
        final result = _rollEngine.rollWithAdvantage(1, 10);
        needRoll = result.chosenSum;
        needAllRolls = [result.sum1, result.sum2];
        break;
      case NeedSkew.none:
        needRoll = _rollEngine.rollDie(10);
        needAllRolls = [needRoll];
    }
    final need = needs[_getIndex(needRoll)];
    
    // Motive
    final motiveRoll = _rollEngine.rollDie(10);
    final motive = motives[_getIndex(motiveRoll)];
    
    // Color (1d10)
    final colorResult = details.rollColor();
    
    // Two Properties (1d10+1d6 each)
    final property1 = details.rollProperty();
    final property2 = details.rollProperty();
    
    return ComplexNpcResult(
      name: nameResult,
      primaryPersonalityRoll: persRoll1,
      primaryPersonality: primary,
      secondaryPersonalityRoll: persRoll2,
      secondaryPersonality: secondary,
      needRoll: needRoll,
      need: need,
      needSkew: needSkew,
      needAllRolls: needAllRolls,
      motiveRoll: motiveRoll,
      motive: motive,
      color: colorResult,
      property1: property1,
      property2: property2,
    );
  }
}

/// Which column of the NPC table was rolled.
enum NpcColumn {
  personality,
  need,
  motive,
  action,
  combat,
}

extension NpcColumnDisplay on NpcColumn {
  String get displayText {
    switch (this) {
      case NpcColumn.personality:
        return 'Personality';
      case NpcColumn.need:
        return 'Need';
      case NpcColumn.motive:
        return 'Motive/Topic';
      case NpcColumn.action:
        return 'Action';
      case NpcColumn.combat:
        return 'Combat';
    }
  }
}

/// Result of a single NPC column roll.
class NpcActionResult extends RollResult {
  final NpcColumn column;
  final int roll;
  final String result;
  final int? dieSize;
  final List<int>? allRolls;
  final NpcDisposition? disposition;
  final NpcContext? context;
  final NpcFocus? focus;
  final NpcObjective? objective;
  final NeedSkew? needSkew;

  NpcActionResult({
    required this.column,
    required this.roll,
    required this.result,
    this.dieSize,
    this.allRolls,
    this.disposition,
    this.context,
    this.focus,
    this.objective,
    this.needSkew,
  }) : super(
          type: RollType.npcAction,
          description: _buildDescription(column, dieSize, disposition, context, focus, objective, needSkew),
          diceResults: allRolls ?? [roll],
          total: roll,
          interpretation: result,
          metadata: _buildMetadata(column, result, dieSize, disposition, context, focus, objective, needSkew),
        );

  static String _buildDescription(
    NpcColumn column,
    int? dieSize,
    NpcDisposition? disposition,
    NpcContext? context,
    NpcFocus? focus,
    NpcObjective? objective,
    NeedSkew? needSkew,
  ) {
    final base = 'NPC ${column.displayText}';
    final parts = <String>[];
    
    if (dieSize != null) {
      parts.add('d$dieSize');
    }
    if (disposition != null) {
      parts.add(disposition == NpcDisposition.passive ? 'Passive' : 'Active');
    }
    if (context != null) {
      parts.add(context == NpcContext.active ? '@+' : '@-');
    }
    if (focus != null) {
      parts.add(focus == NpcFocus.passive ? 'Passive' : 'Active');
    }
    if (objective != null) {
      parts.add(objective == NpcObjective.offensive ? '@+' : '@-');
    }
    if (needSkew != null && needSkew != NeedSkew.none) {
      parts.add(needSkew == NeedSkew.primitive ? '@- Primitive' : '@+ Complex');
    }
    
    if (parts.isEmpty) return base;
    return '$base (${parts.join(' ')})';
  }

  static Map<String, dynamic> _buildMetadata(
    NpcColumn column,
    String result,
    int? dieSize,
    NpcDisposition? disposition,
    NpcContext? context,
    NpcFocus? focus,
    NpcObjective? objective,
    NeedSkew? needSkew,
  ) {
    return {
      'column': column.name,
      'result': result,
      if (dieSize != null) 'dieSize': dieSize,
      if (disposition != null) 'disposition': disposition.name,
      if (context != null) 'context': context.name,
      if (focus != null) 'focus': focus.name,
      if (objective != null) 'objective': objective.name,
      if (needSkew != null) 'needSkew': needSkew.name,
    };
  }

  @override
  String toString() => 'NPC ${column.displayText}: $result';
}

/// Result of generating a full NPC profile.
class NpcProfileResult extends RollResult {
  final int personalityRoll;
  final String personality;
  final int needRoll;
  final String need;
  final int motiveRoll;
  final String motive;
  final NeedSkew? needSkew;
  final List<int>? needAllRolls;

  NpcProfileResult({
    required this.personalityRoll,
    required this.personality,
    required this.needRoll,
    required this.need,
    required this.motiveRoll,
    required this.motive,
    this.needSkew,
    this.needAllRolls,
  }) : super(
          type: RollType.npcAction,
          description: needSkew != null && needSkew != NeedSkew.none
              ? 'NPC Profile (Need: ${needSkew == NeedSkew.primitive ? '@- Primitive' : '@+ Complex'})'
              : 'NPC Profile',
          diceResults: [personalityRoll, needRoll, motiveRoll],
          total: personalityRoll + needRoll + motiveRoll,
          interpretation: '$personality / $need / $motive',
          metadata: {
            'personality': personality,
            'need': need,
            'motive': motive,
            if (needSkew != null) 'needSkew': needSkew.name,
          },
        );

  @override
  String toString() =>
      'NPC Profile: $personality (needs $need, motivated by $motive)';
}

/// Result of rolling dual personality traits.
/// Per instructions: "You can optionally give them a secondary personality trait."
/// Example: "Confident, yet Reserved"
class DualPersonalityResult extends RollResult {
  final int primaryRoll;
  final String primary;
  final int secondaryRoll;
  final String secondary;

  DualPersonalityResult({
    required this.primaryRoll,
    required this.primary,
    required this.secondaryRoll,
    required this.secondary,
  }) : super(
          type: RollType.npcAction,
          description: 'Dual Personality',
          diceResults: [primaryRoll, secondaryRoll],
          total: primaryRoll + secondaryRoll,
          interpretation: '$primary, yet $secondary',
          metadata: {
            'primary': primary,
            'secondary': secondary,
          },
        );

  @override
  String toString() => 'Personality: $primary, yet $secondary';
}

/// Result of generating a complex NPC.
/// Per instructions (page 128-129): Complex NPCs include:
/// - Name (optional)
/// - 2 Personality traits (primary + optional secondary)
/// - Need (with advantage for people, disadvantage for monsters)
/// - Motive
/// - Color (1d10)
/// - Two Properties (1d10+1d6 each)
class ComplexNpcResult extends RollResult {
  final NameResult? name;
  final int primaryPersonalityRoll;
  final String primaryPersonality;
  final int? secondaryPersonalityRoll;
  final String? secondaryPersonality;
  final int needRoll;
  final String need;
  final NeedSkew needSkew;
  final List<int> needAllRolls;
  final int motiveRoll;
  final String motive;
  final DetailResult color;
  final PropertyResult property1;
  final PropertyResult property2;

  ComplexNpcResult({
    this.name,
    required this.primaryPersonalityRoll,
    required this.primaryPersonality,
    this.secondaryPersonalityRoll,
    this.secondaryPersonality,
    required this.needRoll,
    required this.need,
    required this.needSkew,
    required this.needAllRolls,
    required this.motiveRoll,
    required this.motive,
    required this.color,
    required this.property1,
    required this.property2,
  }) : super(
          type: RollType.npcAction,
          description: 'Complex NPC',
          diceResults: _buildDiceResults(
            name, primaryPersonalityRoll, secondaryPersonalityRoll, 
            needAllRolls, motiveRoll, color, property1, property2,
          ),
          total: primaryPersonalityRoll + needRoll + motiveRoll,
          interpretation: _buildInterpretation(
            name, primaryPersonality, secondaryPersonality, need, motive,
            color, property1, property2,
          ),
          metadata: _buildMetadata(
            name, primaryPersonality, secondaryPersonality, need, motive,
            needSkew, color, property1, property2,
          ),
        );

  static List<int> _buildDiceResults(
    NameResult? name, int persRoll1, int? persRoll2,
    List<int> needRolls, int motiveRoll, DetailResult color,
    PropertyResult prop1, PropertyResult prop2,
  ) {
    return [
      if (name != null) ...name.diceResults,
      persRoll1,
      if (persRoll2 != null) persRoll2,
      ...needRolls,
      motiveRoll,
      color.roll,
      prop1.propertyRoll, prop1.intensityRoll,
      prop2.propertyRoll, prop2.intensityRoll,
    ];
  }

  static String _buildInterpretation(
    NameResult? name, String primary, String? secondary,
    String need, String motive, DetailResult color,
    PropertyResult prop1, PropertyResult prop2,
  ) {
    final namePart = name != null ? '${name.name}: ' : '';
    final personalityPart = secondary != null 
        ? '$primary, yet $secondary' 
        : primary;
    return '$namePart$personalityPart / $need / $motive\n'
           '${color.emoji ?? ''} ${color.result}\n'
           '${prop1.intensityDescription} ${prop1.property} + ${prop2.intensityDescription} ${prop2.property}';
  }

  static Map<String, dynamic> _buildMetadata(
    NameResult? name, String primary, String? secondary,
    String need, String motive, NeedSkew needSkew,
    DetailResult color, PropertyResult prop1, PropertyResult prop2,
  ) {
    return {
      if (name != null) 'name': name.name,
      'primaryPersonality': primary,
      if (secondary != null) 'secondaryPersonality': secondary,
      'need': need,
      'motive': motive,
      'needSkew': needSkew.name,
      'color': color.result,
      'property1': '${prop1.intensityDescription} ${prop1.property}',
      'property2': '${prop2.intensityDescription} ${prop2.property}',
    };
  }

  /// Get personality display text.
  String get personalityDisplay => secondaryPersonality != null
      ? '$primaryPersonality, yet $secondaryPersonality'
      : primaryPersonality;

  /// Get properties display text.
  String get propertiesDisplay =>
      '${property1.intensityDescription} ${property1.property} + ${property2.intensityDescription} ${property2.property}';

  @override
  String toString() {
    final buffer = StringBuffer();
    if (name != null) {
      buffer.writeln('Name: ${name!.name}');
    }
    buffer.writeln('Personality: $personalityDisplay');
    buffer.writeln('Need: $need (${needSkew.name})');
    buffer.writeln('Motive: $motive');
    buffer.writeln('Color: ${color.emoji ?? ''} ${color.result}');
    buffer.writeln('Properties: $propertiesDisplay');
    return buffer.toString().trim();
  }
}
