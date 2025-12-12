import '../core/roll_engine.dart';
import '../data/next_scene_data.dart' as data;

// Re-export result classes for backward compatibility
export '../models/results/next_scene_result.dart';

import '../models/results/next_scene_result.dart';
import 'interrupt_plot_point.dart';
import 'random_event.dart';

/// Next Scene preset for the Juice Oracle.
/// Uses the Next Scene column from the Fate Check table (2dF).
/// Determines if the next scene proceeds normally, is altered, or is interrupted.
/// 
/// At the end of a scene, you probably have an idea of what the next scene may look like.
/// Mythic prompts you to challenge that expectation, and Juice does it in a streamlined fashion.
class NextScene {
  final RollEngine _rollEngine;
  final InterruptPlotPoint _plotPoint;

  /// Focus table - d10 (from quest.md Focus column)
  /// Entries in italics reference other tables but we keep them simple here.
  static List<String> get focuses => data.focuses;

  NextScene([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine(),
        _plotPoint = InterruptPlotPoint(rollEngine);

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

  /// Determine the next scene with automatic follow-up rolls.
  /// Returns NextSceneWithFollowUpResult which includes the focus or plot point.
  /// 
  /// If [useSimpleMode] is true and the result is an Alter, uses Modifier + Idea
  /// instead of the Focus table.
  NextSceneWithFollowUpResult determineSceneWithFollowUp({
    bool useSimpleMode = false,
    RandomEvent? randomEvent,
  }) {
    final sceneResult = determineScene();
    
    // Generate follow-up based on scene type
    FocusResult? focusResult;
    IdeaResult? ideaResult;
    InterruptPlotPointResult? plotPointResult;
    
    if (sceneResult.sceneType == SceneType.alterAdd || 
        sceneResult.sceneType == SceneType.alterRemove) {
      if (useSimpleMode && randomEvent != null) {
        // Simple mode: Use Modifier + Idea instead of Focus
        ideaResult = randomEvent.rollModifierPlusIdea();
      } else {
        focusResult = rollFocus();
      }
    } else if (sceneResult.sceneType == SceneType.interruptFavorable ||
               sceneResult.sceneType == SceneType.interruptUnfavorable) {
      plotPointResult = _plotPoint.generate();
    }
    
    return NextSceneWithFollowUpResult(
      sceneResult: sceneResult,
      focusResult: focusResult,
      ideaResult: ideaResult,
      plotPointResult: plotPointResult,
    );
  }

  /// Roll on the Focus table (1d10).
  FocusResult rollFocus() {
    final roll = _rollEngine.rollDie(10);
    final index = roll == 10 ? 9 : roll - 1;
    final focus = focuses[index];
    
    return FocusResult(
      roll: roll,
      focus: focus,
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
