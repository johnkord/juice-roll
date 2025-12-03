import '../core/roll_engine.dart';
import '../models/roll_result.dart';

/// Next Scene preset for the Juice Oracle.
/// Uses the Next Scene column from the Fate Check table (2dF).
/// Determines if the next scene proceeds normally, is altered, or is interrupted.
class NextScene {
  final RollEngine _rollEngine;

  NextScene([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  /// Determine the next scene type using 2dF.
  NextSceneResult determineScene() {
    // Roll 2 Fate dice (ordered)
    final fateDice = _rollEngine.rollFateDice(2);
    final leftDie = fateDice[0];
    final rightDie = fateDice[1];
    final fateSum = leftDie + rightDie;

    // Determine scene outcome based on Fate Check Next Scene column
    final sceneType = _interpretFateDice(leftDie, rightDie);

    return NextSceneResult(
      fateDice: fateDice,
      fateSum: fateSum,
      sceneType: sceneType,
    );
  }

  /// Interpret the Fate dice for Next Scene.
  /// Based on fate-check.md Next Scene column.
  SceneType _interpretFateDice(int left, int right) {
    // + + = Alter (Add)
    if (left == 1 && right == 1) {
      return SceneType.alterAdd;
    }
    // + - = Alter (Remove)
    if (left == 1 && right == -1) {
      return SceneType.alterRemove;
    }
    // - + = Interrupt (Favorable)
    if (left == -1 && right == 1) {
      return SceneType.interruptFavorable;
    }
    // - - = Interrupt (Unfavorable)
    if (left == -1 && right == -1) {
      return SceneType.interruptUnfavorable;
    }
    // All other combinations = Normal
    return SceneType.normal;
  }
}

/// Types of scene transitions from the Juice Oracle.
enum SceneType {
  normal,
  alterAdd,
  alterRemove,
  interruptFavorable,
  interruptUnfavorable,
}

/// Extension to provide display text and descriptions for scene types.
extension SceneTypeDisplay on SceneType {
  String get displayText {
    switch (this) {
      case SceneType.normal:
        return 'Normal';
      case SceneType.alterAdd:
        return 'Alter (Add)';
      case SceneType.alterRemove:
        return 'Alter (Remove)';
      case SceneType.interruptFavorable:
        return 'Interrupt (Favorable)';
      case SceneType.interruptUnfavorable:
        return 'Interrupt (Unfavorable)';
    }
  }

  String get description {
    switch (this) {
      case SceneType.normal:
        return 'The scene proceeds as expected.';
      case SceneType.alterAdd:
        return 'The scene is modified - add an element. Roll Modifier + Idea.';
      case SceneType.alterRemove:
        return 'The scene is modified - remove an element. Roll Modifier + Idea.';
      case SceneType.interruptFavorable:
        return 'The scene is replaced by something favorable. Roll Random Event.';
      case SceneType.interruptUnfavorable:
        return 'The scene is replaced by something unfavorable. Roll Random Event.';
    }
  }

  /// Whether this result requires a follow-up roll.
  bool get requiresFollowUp {
    return this != SceneType.normal;
  }

  /// What type of follow-up roll is needed.
  String? get followUpRoll {
    switch (this) {
      case SceneType.normal:
        return null;
      case SceneType.alterAdd:
      case SceneType.alterRemove:
        return 'Modifier + Idea';
      case SceneType.interruptFavorable:
      case SceneType.interruptUnfavorable:
        return 'Random Event';
    }
  }
}

/// Result of a Next Scene roll.
class NextSceneResult extends RollResult {
  final List<int> fateDice;
  final int fateSum;
  final SceneType sceneType;

  NextSceneResult({
    required this.fateDice,
    required this.fateSum,
    required this.sceneType,
  }) : super(
          type: RollType.nextScene,
          description: 'Next Scene',
          diceResults: fateDice,
          total: fateSum,
          interpretation: sceneType.displayText,
          metadata: {
            'sceneType': sceneType.name,
            'requiresFollowUp': sceneType.requiresFollowUp,
            'followUpRoll': sceneType.followUpRoll,
          },
        );

  /// Get symbolic representation of the Fate dice.
  String get fateSymbols {
    return fateDice.map((d) {
      switch (d) {
        case -1:
          return '−';
        case 0:
          return '○';
        case 1:
          return '+';
        default:
          return '?';
      }
    }).join(' ');
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Next Scene: [$fateSymbols]');
    buffer.writeln('  Result: ${sceneType.displayText}');
    if (sceneType.requiresFollowUp) {
      buffer.write('  Follow-up: ${sceneType.followUpRoll}');
    }
    return buffer.toString();
  }
}
