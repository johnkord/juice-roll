import '../../core/fate_dice_formatter.dart';
import '../roll_result.dart';
import 'interrupt_plot_point_result.dart';
import 'random_event_result.dart';

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
        return 'Alter (Add Focus)';
      case SceneType.alterRemove:
        return 'Alter (Remove Focus)';
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
        return 'The scene is modified - add an element. Roll on the Focus table.';
      case SceneType.alterRemove:
        return 'The scene is modified - remove an element. Roll on the Focus table.';
      case SceneType.interruptFavorable:
        return 'The expected scene is interrupted by something favorable. Roll on the Plot Point table.';
      case SceneType.interruptUnfavorable:
        return 'The expected scene is interrupted by something unfavorable. Roll on the Plot Point table.';
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
        return 'Focus';
      case SceneType.interruptFavorable:
      case SceneType.interruptUnfavorable:
        return 'Plot Point';
    }
  }

  /// Whether this is an Alter scene type that needs interpretation guidance.
  bool get isAlter => this == SceneType.alterAdd || this == SceneType.alterRemove;

  /// Contextual guidance for Alter scene types.
  String? get alterGuidance {
    switch (this) {
      case SceneType.alterAdd:
        return 'Introduce or emphasize this element in the scene.';
      case SceneType.alterRemove:
        return 'Diminish or remove this element\'s influence from the scene.';
      default:
        return null;
    }
  }

  /// Example interpretations for Alter scene types.
  /// Returns a list of (focus, interpretation) pairs.
  List<(String, String)>? get alterExamples {
    switch (this) {
      case SceneType.alterAdd:
        return [
          ('Ally', 'A friend unexpectedly shows up'),
          ('Enemy', 'A rival appears in the scene'),
          ('Environment', 'Weather or terrain becomes a factor'),
        ];
      case SceneType.alterRemove:
        return [
          ('Environment → Arctic', 'An extremely hot morning; clear skies instead of snow'),
          ('Enemy', 'Your foe is absent or distracted'),
          ('Community', 'The usual crowds are gone'),
        ];
      default:
        return null;
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
    DateTime? timestamp,
  }) : super(
          type: RollType.nextScene,
          description: 'Next Scene',
          diceResults: fateDice,
          total: fateSum,
          interpretation: sceneType.displayText,
          timestamp: timestamp,
          metadata: {
            'fateDice': fateDice,
            'fateSum': fateSum,
            'sceneType': sceneType.name,
            'requiresFollowUp': sceneType.requiresFollowUp,
            'followUpRoll': sceneType.followUpRoll,
          },
        );

  @override
  String get className => 'NextSceneResult';

  factory NextSceneResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final fateDice = (meta['fateDice'] as List?)?.cast<int>() ?? 
                     (json['diceResults'] as List).cast<int>();
    return NextSceneResult(
      fateDice: fateDice,
      fateSum: meta['fateSum'] as int? ?? json['total'] as int,
      sceneType: SceneType.values.firstWhere(
        (e) => e.name == (meta['sceneType'] as String),
        orElse: () => SceneType.normal,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Get symbolic representation of the Fate dice.
  String get fateSymbols => FateDiceFormatter.diceToSymbols(fateDice);

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

/// Result of a Focus table roll (1d10).
class FocusResult extends RollResult {
  final int roll;
  final String focus;

  FocusResult({
    required this.roll,
    required this.focus,
    DateTime? timestamp,
  }) : super(
          type: RollType.nextScene,
          description: 'Focus',
          diceResults: [roll],
          total: roll,
          interpretation: focus,
          timestamp: timestamp,
          metadata: {
            'focus': focus,
            'roll': roll,
          },
        );

  @override
  String get className => 'FocusResult';

  factory FocusResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    return FocusResult(
      roll: meta['roll'] as int? ?? (json['diceResults'] as List).first as int,
      focus: meta['focus'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() => 'Focus: $focus';
}

/// Result of a Next Scene roll with automatic follow-up.
class NextSceneWithFollowUpResult extends RollResult {
  final NextSceneResult sceneResult;
  final FocusResult? focusResult;
  final IdeaResult? ideaResult;
  final InterruptPlotPointResult? plotPointResult;

  NextSceneWithFollowUpResult({
    required this.sceneResult,
    this.focusResult,
    this.ideaResult,
    this.plotPointResult,
    DateTime? timestamp,
  }) : super(
          type: RollType.nextScene,
          description: 'Next Scene',
          diceResults: [
            ...sceneResult.fateDice,
            if (focusResult != null) focusResult.roll,
            if (ideaResult != null) ...[ideaResult.modifierRoll, ideaResult.ideaRoll],
            if (plotPointResult != null) ...[plotPointResult.categoryRoll, plotPointResult.eventRoll],
          ],
          total: sceneResult.fateSum,
          interpretation: _buildInterpretation(sceneResult, focusResult, ideaResult, plotPointResult),
          timestamp: timestamp,
          metadata: {
            'sceneType': sceneResult.sceneType.name,
            'fateDice': sceneResult.fateDice,
            'fateSum': sceneResult.fateSum,
            if (focusResult != null) 'focus': focusResult.focus,
            if (ideaResult != null) 'idea': '${ideaResult.modifier} ${ideaResult.idea}',
            if (plotPointResult != null) 'plotPoint': '${plotPointResult.category}: ${plotPointResult.event}',
          },
        );

  @override
  String get className => 'NextSceneWithFollowUpResult';

  factory NextSceneWithFollowUpResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final fateDice = (meta['fateDice'] as List?)?.cast<int>() ?? 
                     (json['diceResults'] as List).take(2).cast<int>().toList();
    return NextSceneWithFollowUpResult(
      sceneResult: NextSceneResult(
        fateDice: fateDice,
        fateSum: meta['fateSum'] as int? ?? fateDice.fold(0, (a, b) => a + b),
        sceneType: SceneType.values.firstWhere(
          (e) => e.name == (meta['sceneType'] as String),
          orElse: () => SceneType.normal,
        ),
      ),
      // Note: sub-results cannot be fully reconstructed without full data
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  static String _buildInterpretation(
    NextSceneResult scene,
    FocusResult? focus,
    IdeaResult? idea,
    InterruptPlotPointResult? plotPoint,
  ) {
    final buffer = StringBuffer(scene.sceneType.displayText);
    if (focus != null) {
      buffer.write(' → ${focus.focus}');
    }
    if (idea != null) {
      buffer.write(' → ${idea.modifier} ${idea.idea}');
    }
    if (plotPoint != null) {
      buffer.write(' → ${plotPoint.category}: ${plotPoint.event}');
    }
    return buffer.toString();
  }

  /// Get the follow-up text for display.
  String? get followUpText {
    if (focusResult != null) {
      return focusResult!.focus;
    }
    if (ideaResult != null) {
      return '${ideaResult!.modifier} ${ideaResult!.idea}';
    }
    if (plotPointResult != null) {
      return '${plotPointResult!.category}: ${plotPointResult!.event}';
    }
    return null;
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Next Scene: [${sceneResult.fateSymbols}]');
    buffer.writeln('  Result: ${sceneResult.sceneType.displayText}');
    if (focusResult != null) {
      buffer.writeln('  Focus: ${focusResult!.focus}');
    }
    if (ideaResult != null) {
      buffer.writeln('  Idea: ${ideaResult!.modifier} ${ideaResult!.idea}');
    }
    if (plotPointResult != null) {
      buffer.write('  Plot Point: ${plotPointResult!.category} - ${plotPointResult!.event}');
    }
    return buffer.toString();
  }
}
