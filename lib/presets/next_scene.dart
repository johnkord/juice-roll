import '../core/roll_engine.dart';
import '../core/table_lookup.dart';
import '../models/roll_result.dart';

/// Next Scene preset for the Juice Oracle.
/// Determines what type of scene comes next in the narrative.
class NextScene {
  final RollEngine _rollEngine;

  /// Scene types table based on 2d6.
  static final LookupTable<SceneType> _sceneTable = LookupTable(
    name: 'Next Scene',
    entries: [
      const TableEntry(minValue: 2, maxValue: 2, result: SceneType.dramaticTwist),
      const TableEntry(minValue: 3, maxValue: 4, result: SceneType.complication),
      const TableEntry(minValue: 5, maxValue: 5, result: SceneType.delay),
      const TableEntry(minValue: 6, maxValue: 8, result: SceneType.expected),
      const TableEntry(minValue: 9, maxValue: 9, result: SceneType.advantage),
      const TableEntry(minValue: 10, maxValue: 11, result: SceneType.opportunity),
      const TableEntry(minValue: 12, maxValue: 12, result: SceneType.revelation),
    ],
  );

  /// Chaos factor modifiers for scene checks.
  static const Map<String, int> chaosLevels = {
    'Controlled': -2,
    'Stable': -1,
    'Normal': 0,
    'Unstable': 1,
    'Chaotic': 2,
  };

  NextScene([RollEngine? rollEngine]) 
      : _rollEngine = rollEngine ?? RollEngine();

  /// Determine the next scene type.
  NextSceneResult determineScene({String chaosLevel = 'Normal'}) {
    final modifier = chaosLevels[chaosLevel] ?? 0;
    final dice = _rollEngine.rollDice(2, 6);
    final sum = dice.reduce((a, b) => a + b);
    final modifiedSum = (sum + modifier).clamp(2, 12);
    
    final sceneType = _sceneTable.lookup(modifiedSum) ?? SceneType.expected;
    
    // Check for doubles (indicates interrupt/random event)
    final isDoubles = dice.length >= 2 && dice[0] == dice[1];

    return NextSceneResult(
      chaosLevel: chaosLevel,
      modifier: modifier,
      diceResults: dice,
      rawTotal: sum,
      modifiedTotal: modifiedSum,
      sceneType: sceneType,
      isInterrupt: isDoubles,
    );
  }
}

/// Types of scenes that can occur.
enum SceneType {
  dramaticTwist,
  complication,
  delay,
  expected,
  advantage,
  opportunity,
  revelation,
}

/// Extension to provide display text and descriptions for scene types.
extension SceneTypeDisplay on SceneType {
  String get displayText {
    switch (this) {
      case SceneType.dramaticTwist:
        return 'Dramatic Twist';
      case SceneType.complication:
        return 'Complication';
      case SceneType.delay:
        return 'Delay';
      case SceneType.expected:
        return 'Expected';
      case SceneType.advantage:
        return 'Advantage';
      case SceneType.opportunity:
        return 'Opportunity';
      case SceneType.revelation:
        return 'Revelation';
    }
  }

  String get description {
    switch (this) {
      case SceneType.dramaticTwist:
        return 'Something completely unexpected happens that changes everything.';
      case SceneType.complication:
        return 'The situation becomes more complex or difficult.';
      case SceneType.delay:
        return 'Progress is hindered or slowed.';
      case SceneType.expected:
        return 'The scene proceeds as anticipated.';
      case SceneType.advantage:
        return 'A small benefit or edge presents itself.';
      case SceneType.opportunity:
        return 'A significant chance for advancement appears.';
      case SceneType.revelation:
        return 'Important information or truth is revealed.';
    }
  }
}

/// Result of a Next Scene roll.
class NextSceneResult extends RollResult {
  final String chaosLevel;
  final int modifier;
  final int rawTotal;
  final int modifiedTotal;
  final SceneType sceneType;
  final bool isInterrupt;

  NextSceneResult({
    required this.chaosLevel,
    required this.modifier,
    required List<int> diceResults,
    required this.rawTotal,
    required this.modifiedTotal,
    required this.sceneType,
    required this.isInterrupt,
  }) : super(
          type: RollType.nextScene,
          description: 'Next Scene ($chaosLevel)',
          diceResults: diceResults,
          total: modifiedTotal,
          interpretation: '${sceneType.displayText}${isInterrupt ? ' + INTERRUPT!' : ''}',
          metadata: {
            'chaosLevel': chaosLevel,
            'modifier': modifier,
            'rawTotal': rawTotal,
            'sceneType': sceneType.name,
            'isInterrupt': isInterrupt,
          },
        );

  @override
  String toString() {
    final modStr = modifier >= 0 ? '+$modifier' : '$modifier';
    final interruptStr = isInterrupt ? ' [INTERRUPT - Random Event!]' : '';
    return 'Next Scene ($chaosLevel): ${diceResults.join('+')}$modStr = $modifiedTotal → ${sceneType.displayText}$interruptStr';
  }
}
