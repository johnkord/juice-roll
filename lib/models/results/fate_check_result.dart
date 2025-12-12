import '../../core/fate_dice_formatter.dart';
import '../roll_result.dart';
import 'json_utils.dart';
import 'random_event_result.dart';

/// Special triggers from double blanks on Fate dice.
enum SpecialTrigger {
  /// Something unexpected happens - roll on Random Event tables.
  /// Triggered when primary die is on the LEFT.
  /// Answer is "Yes But".
  randomEvent,
  
  /// Your assumption about the situation was wrong.
  /// Triggered when primary die is on the RIGHT.
  /// Re-examine what you thought was true.
  invalidAssumption,
}

extension SpecialTriggerDisplay on SpecialTrigger {
  String get displayText {
    switch (this) {
      case SpecialTrigger.randomEvent:
        return 'Random Event!';
      case SpecialTrigger.invalidAssumption:
        return 'Invalid Assumption!';
    }
  }

  String get description {
    switch (this) {
      case SpecialTrigger.randomEvent:
        return 'Something unexpected happens. See the auto-rolled Random Event below.';
      case SpecialTrigger.invalidAssumption:
        return 'Your assumption about the situation was wrong. Re-examine what you thought was true.';
    }
  }
}

/// Possible outcomes from a Fate Check.
enum FateCheckOutcome {
  noAnd,
  noBecause,    // -0 result - "No" with a reason to discover
  no,           // Plain "No" (used in Likely/Unlikely columns)
  noBut,
  unfavorable,  // 0- result
  favorable,    // 0+ result  
  yesBut,
  yes,          // Plain "Yes" (used in Likely/Unlikely columns)
  yesBecause,   // +0 result - "Yes" with a reason to discover
  yesAnd,
}

/// Extension to provide display text for outcomes.
extension FateCheckOutcomeDisplay on FateCheckOutcome {
  String get displayText {
    switch (this) {
      case FateCheckOutcome.noAnd:
        return 'No, and...';
      case FateCheckOutcome.noBecause:
        return 'No, because...';
      case FateCheckOutcome.no:
        return 'No';
      case FateCheckOutcome.noBut:
        return 'No, but...';
      case FateCheckOutcome.unfavorable:
        return 'Unfavorable';
      case FateCheckOutcome.favorable:
        return 'Favorable';
      case FateCheckOutcome.yesBut:
        return 'Yes, but...';
      case FateCheckOutcome.yes:
        return 'Yes';
      case FateCheckOutcome.yesBecause:
        return 'Yes, because...';
      case FateCheckOutcome.yesAnd:
        return 'Yes, and...';
    }
  }
  
  String get description {
    switch (this) {
      case FateCheckOutcome.noAnd:
        return 'Strong No - with additional negative consequence';
      case FateCheckOutcome.noBecause:
        return 'No - use Intensity to determine the reason why';
      case FateCheckOutcome.no:
        return 'Plain No answer (Likely/Unlikely mode)';
      case FateCheckOutcome.noBut:
        return 'No - but with a silver lining';
      case FateCheckOutcome.unfavorable:
        return 'The answer is whatever is LEAST favorable to your character';
      case FateCheckOutcome.favorable:
        return 'The answer is whatever is MOST favorable to your character';
      case FateCheckOutcome.yesBut:
        return 'Yes - but with a complication';
      case FateCheckOutcome.yes:
        return 'Plain Yes answer (Likely/Unlikely mode)';
      case FateCheckOutcome.yesBecause:
        return 'Yes - use Intensity to determine the reason why';
      case FateCheckOutcome.yesAnd:
        return 'Strong Yes - with additional benefit';
    }
  }

  /// Whether this is fundamentally a "yes" answer.
  bool get isYes {
    return this == FateCheckOutcome.yesBut ||
           this == FateCheckOutcome.yes ||
           this == FateCheckOutcome.yesBecause ||
           this == FateCheckOutcome.yesAnd;
  }

  /// Whether this is fundamentally a "no" answer.
  bool get isNo {
    return this == FateCheckOutcome.noBut ||
           this == FateCheckOutcome.no ||
           this == FateCheckOutcome.noBecause ||
           this == FateCheckOutcome.noAnd;
  }
  
  /// Whether this is context-dependent (favorable/unfavorable).
  bool get isContextual {
    return this == FateCheckOutcome.favorable ||
           this == FateCheckOutcome.unfavorable;
  }
}

/// Result of a Fate Check.
class FateCheckResult extends RollResult {
  final String likelihood;
  final List<int> fateDice;
  final int fateSum;
  final int intensity;
  final FateCheckOutcome outcome;
  final SpecialTrigger? specialTrigger;
  final bool primaryOnLeft;
  /// Auto-rolled Random Event result when Random Event is triggered (O O with primary on left)
  final RandomEventResult? randomEventResult;

  FateCheckResult({
    required this.likelihood,
    required this.fateDice,
    required this.fateSum,
    required this.intensity,
    required this.outcome,
    this.specialTrigger,
    this.primaryOnLeft = true,
    this.randomEventResult,
    DateTime? timestamp,
  }) : super(
          type: RollType.fateCheck,
          description: 'Fate Check ($likelihood)',
          diceResults: [
            ...fateDice, 
            intensity,
            if (randomEventResult != null) ...[
              randomEventResult.focusRoll,
              randomEventResult.modifierRoll,
              randomEventResult.ideaRoll,
            ],
          ],
          total: fateSum,
          interpretation: _buildInterpretation(outcome, intensity, specialTrigger, randomEventResult),
          timestamp: timestamp,
          metadata: {
            'likelihood': likelihood,
            'fateDice': fateDice,
            'fateSum': fateSum,
            'intensity': intensity,
            'outcome': outcome.name,
            'specialTrigger': specialTrigger?.name,
            'primaryOnLeft': primaryOnLeft,
            if (randomEventResult != null) 'randomEvent': {
              'focus': randomEventResult.focus,
              'focusRoll': randomEventResult.focusRoll,
              'modifier': randomEventResult.modifier,
              'modifierRoll': randomEventResult.modifierRoll,
              'idea': randomEventResult.idea,
              'ideaRoll': randomEventResult.ideaRoll,
            },
          },
        );

  @override
  String get className => 'FateCheckResult';

  factory FateCheckResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    RandomEventResult? randomEvent;
    if (meta['randomEvent'] != null) {
      final re = requireMap(meta['randomEvent'], 'randomEvent');
      randomEvent = RandomEventResult(
        focus: re['focus'] as String,
        focusRoll: re['focusRoll'] as int? ?? 0,
        modifier: re['modifier'] as String,
        modifierRoll: re['modifierRoll'] as int? ?? 0,
        idea: re['idea'] as String,
        ideaRoll: re['ideaRoll'] as int? ?? 0,
      );
    }
    
    return FateCheckResult(
      likelihood: meta['likelihood'] as String,
      fateDice: (meta['fateDice'] as List<dynamic>).cast<int>(),
      fateSum: meta['fateSum'] as int,
      intensity: meta['intensity'] as int,
      outcome: FateCheckOutcome.values.byName(meta['outcome'] as String),
      specialTrigger: meta['specialTrigger'] != null 
          ? SpecialTrigger.values.byName(meta['specialTrigger'] as String) 
          : null,
      primaryOnLeft: meta['primaryOnLeft'] as bool? ?? true,
      randomEventResult: randomEvent,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  static String _buildInterpretation(
    FateCheckOutcome outcome,
    int intensity,
    SpecialTrigger? trigger,
    RandomEventResult? randomEvent,
  ) {
    final parts = <String>[outcome.displayText];
    
    if (trigger != null) {
      parts.add(trigger.displayText);
    }
    
    if (randomEvent != null) {
      parts.add('${randomEvent.focus}: ${randomEvent.modifier} ${randomEvent.idea}');
    }
    
    return parts.join(' + ');
  }

  /// Get symbolic representation of the Fate dice.
  String get fateSymbols => FateDiceFormatter.diceToSymbols(fateDice);

  /// Whether this result triggered a special event.
  bool get hasSpecialTrigger => specialTrigger != null;
  
  /// Whether this result has an auto-rolled random event.
  bool get hasRandomEvent => randomEventResult != null;

  /// Intensity description based on the d6 value.
  /// Uses the "six M's" from design doc: Minimal, Minor, Mundane, Moderate, Major, Maximum
  String get intensityDescription {
    switch (intensity) {
      case 1:
        return 'Minimal';
      case 2:
        return 'Minor';
      case 3:
        return 'Mundane';
      case 4:
        return 'Moderate';
      case 5:
        return 'Major';
      case 6:
        return 'Maximum';
      default:
        return 'Unknown';
    }
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Fate Check ($likelihood):');
    buffer.writeln('  Fate: [$fateSymbols] = $fateSum');
    buffer.writeln('  Intensity: $intensity ($intensityDescription)');
    buffer.write('  Result: ${outcome.displayText}');
    if (specialTrigger != null) {
      buffer.write(' + ${specialTrigger!.displayText}');
    }
    if (randomEventResult != null) {
      buffer.write('\n  Random Event: ${randomEventResult!.focus}: ${randomEventResult!.modifier} ${randomEventResult!.idea}');
    }
    return buffer.toString();
  }
}
