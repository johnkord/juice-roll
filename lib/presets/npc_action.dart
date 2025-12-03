import '../core/roll_engine.dart';
import '../models/roll_result.dart';

/// NPC Action preset for the Juice Oracle.
/// Determines NPC behavior using npc-action.md tables.
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

  /// Roll for a single NPC action.
  NpcActionResult rollAction() {
    final roll = _rollEngine.rollDie(10);
    final index = roll == 10 ? 9 : roll - 1;
    final action = actions[index];

    return NpcActionResult(
      column: NpcColumn.action,
      roll: roll,
      result: action,
    );
  }

  /// Roll for NPC personality.
  NpcActionResult rollPersonality() {
    final roll = _rollEngine.rollDie(10);
    final index = roll == 10 ? 9 : roll - 1;
    final personality = personalities[index];

    return NpcActionResult(
      column: NpcColumn.personality,
      roll: roll,
      result: personality,
    );
  }

  /// Roll for NPC need.
  NpcActionResult rollNeed() {
    final roll = _rollEngine.rollDie(10);
    final index = roll == 10 ? 9 : roll - 1;
    final need = needs[index];

    return NpcActionResult(
      column: NpcColumn.need,
      roll: roll,
      result: need,
    );
  }

  /// Roll for NPC motive/topic.
  NpcActionResult rollMotive() {
    final roll = _rollEngine.rollDie(10);
    final index = roll == 10 ? 9 : roll - 1;
    final motive = motives[index];

    return NpcActionResult(
      column: NpcColumn.motive,
      roll: roll,
      result: motive,
    );
  }

  /// Roll for combat action.
  NpcActionResult rollCombatAction() {
    final roll = _rollEngine.rollDie(10);
    final index = roll == 10 ? 9 : roll - 1;
    final combatAction = combatActions[index];

    return NpcActionResult(
      column: NpcColumn.combat,
      roll: roll,
      result: combatAction,
    );
  }

  /// Generate a full NPC profile (personality + need + motive).
  NpcProfileResult generateProfile() {
    final persRoll = _rollEngine.rollDie(10);
    final needRoll = _rollEngine.rollDie(10);
    final motiveRoll = _rollEngine.rollDie(10);

    final personality = personalities[persRoll == 10 ? 9 : persRoll - 1];
    final need = needs[needRoll == 10 ? 9 : needRoll - 1];
    final motive = motives[motiveRoll == 10 ? 9 : motiveRoll - 1];

    return NpcProfileResult(
      personalityRoll: persRoll,
      personality: personality,
      needRoll: needRoll,
      need: need,
      motiveRoll: motiveRoll,
      motive: motive,
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

  NpcActionResult({
    required this.column,
    required this.roll,
    required this.result,
  }) : super(
          type: RollType.npcAction,
          description: 'NPC ${column.displayText}',
          diceResults: [roll],
          total: roll,
          interpretation: result,
          metadata: {
            'column': column.name,
            'result': result,
          },
        );

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

  NpcProfileResult({
    required this.personalityRoll,
    required this.personality,
    required this.needRoll,
    required this.need,
    required this.motiveRoll,
    required this.motive,
  }) : super(
          type: RollType.npcAction,
          description: 'NPC Profile',
          diceResults: [personalityRoll, needRoll, motiveRoll],
          total: personalityRoll + needRoll + motiveRoll,
          interpretation: '$personality / $need / $motive',
          metadata: {
            'personality': personality,
            'need': need,
            'motive': motive,
          },
        );

  @override
  String toString() =>
      'NPC Profile: $personality (needs $need, motivated by $motive)';
}
