import '../core/roll_engine.dart';
import '../models/roll_result.dart';

/// Expectation Check preset for the Juice Oracle.
/// An alternative to Fate Check for players with existing expectations.
/// 
/// Instead of asking "Is X true?", you assume X is true and test
/// whether your expectation holds.
/// 
/// Also functions as NPC Behavior generation: assume what an NPC
/// will likely do, then test it.
/// 
/// Uses 2dF + 1d6 (similar to Fate Check structure).
class ExpectationCheck {
  final RollEngine _rollEngine;

  ExpectationCheck([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  /// Check if an expectation holds.
  ExpectationCheckResult check() {
    // Roll 2 Fate dice
    final fateDice = _rollEngine.rollFateDice(2);
    final primary = fateDice[0];
    final secondary = fateDice[1];
    
    // Roll Intensity die (1d6)
    final intensity = _rollEngine.rollDie(6);
    
    // Interpret the result
    final outcome = _interpretDice(primary, secondary);

    return ExpectationCheckResult(
      fateDice: fateDice,
      fateSum: primary + secondary,
      intensity: intensity,
      outcome: outcome,
    );
  }

  /// Interpret dice for expectation check.
  /// Based on the Expectation/Behavior table pattern.
  ExpectationOutcome _interpretDice(int primary, int secondary) {
    // ++ = Expected (fully)
    if (primary == 1 && secondary == 1) {
      return ExpectationOutcome.expected;
    }
    
    // +- or +0 = Favorable (expectation shifted in PC's favor)
    if (primary == 1) {
      return ExpectationOutcome.favorable;
    }
    
    // -+ or -0 = Unfavorable (expectation shifted against PC)
    if (primary == -1) {
      return ExpectationOutcome.unfavorable;
    }
    
    // -- = Opposite (completely wrong)
    if (primary == -1 && secondary == -1) {
      return ExpectationOutcome.opposite;
    }
    
    // 0+ = Favorable variant
    if (primary == 0 && secondary == 1) {
      return ExpectationOutcome.favorable;
    }
    
    // 0- = Unfavorable variant
    if (primary == 0 && secondary == -1) {
      return ExpectationOutcome.unfavorable;
    }
    
    // 00 = Mixed / roll again or interpret creatively
    return ExpectationOutcome.mixed;
  }
}

/// Possible outcomes from an Expectation Check.
enum ExpectationOutcome {
  expected,
  favorable,
  mixed,
  unfavorable,
  opposite,
}

extension ExpectationOutcomeDisplay on ExpectationOutcome {
  String get displayText {
    switch (this) {
      case ExpectationOutcome.expected:
        return 'As Expected';
      case ExpectationOutcome.favorable:
        return 'Favorable';
      case ExpectationOutcome.mixed:
        return 'Mixed';
      case ExpectationOutcome.unfavorable:
        return 'Unfavorable';
      case ExpectationOutcome.opposite:
        return 'Opposite!';
    }
  }

  String get description {
    switch (this) {
      case ExpectationOutcome.expected:
        return 'Your expectation is completely correct.';
      case ExpectationOutcome.favorable:
        return 'Your expectation is modified in your favor.';
      case ExpectationOutcome.mixed:
        return 'Neither favorable nor unfavorable. Interpret creatively.';
      case ExpectationOutcome.unfavorable:
        return 'Your expectation is modified against your favor.';
      case ExpectationOutcome.opposite:
        return 'The opposite of your expectation occurs!';
    }
  }
  
  /// For NPC behavior interpretation
  String get npcBehavior {
    switch (this) {
      case ExpectationOutcome.expected:
        return 'NPC does exactly what you expected.';
      case ExpectationOutcome.favorable:
        return 'NPC behavior benefits you more than expected.';
      case ExpectationOutcome.mixed:
        return 'NPC behavior is ambiguous or neutral.';
      case ExpectationOutcome.unfavorable:
        return 'NPC behavior is less helpful than expected.';
      case ExpectationOutcome.opposite:
        return 'NPC does the opposite of what you expected!';
    }
  }
}

/// Result of an Expectation Check.
class ExpectationCheckResult extends RollResult {
  final List<int> fateDice;
  final int fateSum;
  final int intensity;
  final ExpectationOutcome outcome;

  ExpectationCheckResult({
    required this.fateDice,
    required this.fateSum,
    required this.intensity,
    required this.outcome,
  }) : super(
          type: RollType.expectationCheck,
          description: 'Expectation Check',
          diceResults: [...fateDice, intensity],
          total: fateSum,
          interpretation: '${outcome.displayText} (${_intensityText(intensity)})',
          metadata: {
            'fateDice': fateDice,
            'fateSum': fateSum,
            'intensity': intensity,
            'outcome': outcome.name,
          },
        );

  static String _intensityText(int roll) {
    switch (roll) {
      case 1: return 'Minimal';
      case 2: return 'Mundane';
      case 3: return 'Minor';
      case 4: return 'Moderate';
      case 5: return 'Major';
      case 6: return 'Massive';
      default: return 'Unknown';
    }
  }

  /// Get symbolic representation of the Fate dice.
  String get fateSymbols {
    return fateDice.map((d) {
      switch (d) {
        case -1: return '−';
        case 0: return '○';
        case 1: return '+';
        default: return '?';
      }
    }).join(' ');
  }

  String get intensityDescription => _intensityText(intensity);

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Expectation Check:');
    buffer.writeln('  Dice: [$fateSymbols] + $intensity');
    buffer.writeln('  Result: ${outcome.displayText}');
    buffer.write('  Intensity: $intensityDescription');
    return buffer.toString();
  }
}
