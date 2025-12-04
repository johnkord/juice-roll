import '../core/roll_engine.dart';
import '../models/roll_result.dart';

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
