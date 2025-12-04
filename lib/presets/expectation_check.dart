import '../core/roll_engine.dart';
import '../core/fate_dice_formatter.dart';
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
/// Uses 2dF only (no intensity die, unlike Fate Check).
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
    
    // Interpret the result
    final outcome = _interpretDice(primary, secondary);

    return ExpectationCheckResult(
      fateDice: fateDice,
      fateSum: primary + secondary,
      outcome: outcome,
    );
  }

  /// Interpret dice for expectation check.
  /// Based on the Expectation/Behavior table from Juice instructions (page 55).
  ExpectationOutcome _interpretDice(int primary, int secondary) {
    // ++ = Expected (Intensified)
    if (primary == 1 && secondary == 1) {
      return ExpectationOutcome.expectedIntensified;
    }
    
    // +0 = Expected
    if (primary == 1 && secondary == 0) {
      return ExpectationOutcome.expected;
    }
    
    // +- = Next Most Expected
    if (primary == 1 && secondary == -1) {
      return ExpectationOutcome.nextMostExpected;
    }
    
    // 0+ = Favorable
    if (primary == 0 && secondary == 1) {
      return ExpectationOutcome.favorable;
    }
    
    // 00 = Modified Idea (roll on Modifier + Idea table)
    if (primary == 0 && secondary == 0) {
      return ExpectationOutcome.modifiedIdea;
    }
    
    // 0- = Unfavorable
    if (primary == 0 && secondary == -1) {
      return ExpectationOutcome.unfavorable;
    }
    
    // -+ = Next Most Expected
    if (primary == -1 && secondary == 1) {
      return ExpectationOutcome.nextMostExpected;
    }
    
    // -0 = Opposite
    if (primary == -1 && secondary == 0) {
      return ExpectationOutcome.opposite;
    }
    
    // -- = Opposite (Intensified)
    if (primary == -1 && secondary == -1) {
      return ExpectationOutcome.oppositeIntensified;
    }
    
    // Fallback (should not reach here)
    return ExpectationOutcome.expected;
  }
}

/// Possible outcomes from an Expectation Check.
/// Based on the Expectation table from Juice instructions (page 55).
enum ExpectationOutcome {
  expectedIntensified,  // ++
  expected,             // +0
  nextMostExpected,     // +- or -+
  favorable,            // 0+
  modifiedIdea,         // 00
  unfavorable,          // 0-
  opposite,             // -0
  oppositeIntensified,  // --
}

extension ExpectationOutcomeDisplay on ExpectationOutcome {
  String get displayText {
    switch (this) {
      case ExpectationOutcome.expectedIntensified:
        return 'Expected (Intensified)';
      case ExpectationOutcome.expected:
        return 'Expected';
      case ExpectationOutcome.nextMostExpected:
        return 'Next Most Expected';
      case ExpectationOutcome.favorable:
        return 'Favorable';
      case ExpectationOutcome.modifiedIdea:
        return 'Modified Idea';
      case ExpectationOutcome.unfavorable:
        return 'Unfavorable';
      case ExpectationOutcome.opposite:
        return 'Opposite';
      case ExpectationOutcome.oppositeIntensified:
        return 'Opposite (Intensified)';
    }
  }

  String get description {
    switch (this) {
      case ExpectationOutcome.expectedIntensified:
        return 'Your expectation is completely correct, with emphasis!';
      case ExpectationOutcome.expected:
        return 'Your expectation is correct.';
      case ExpectationOutcome.nextMostExpected:
        return 'Not your first expectation, but your second choice occurs.';
      case ExpectationOutcome.favorable:
        return 'Your expectation is modified in your favor.';
      case ExpectationOutcome.modifiedIdea:
        return 'Roll on the Modifier + Idea table to alter your expectation.';
      case ExpectationOutcome.unfavorable:
        return 'Your expectation is modified against your favor.';
      case ExpectationOutcome.opposite:
        return 'The opposite of your expectation occurs.';
      case ExpectationOutcome.oppositeIntensified:
        return 'The opposite of your expectation occurs, with emphasis!';
    }
  }
  
  /// For NPC behavior interpretation
  String get npcBehavior {
    switch (this) {
      case ExpectationOutcome.expectedIntensified:
        return 'NPC does exactly what you expected, emphatically!';
      case ExpectationOutcome.expected:
        return 'NPC does what you expected.';
      case ExpectationOutcome.nextMostExpected:
        return 'NPC does your second-most-likely expectation.';
      case ExpectationOutcome.favorable:
        return 'NPC behavior benefits you more than expected.';
      case ExpectationOutcome.modifiedIdea:
        return 'Roll Modifier + Idea to determine NPC action.';
      case ExpectationOutcome.unfavorable:
        return 'NPC behavior is less helpful than expected.';
      case ExpectationOutcome.opposite:
        return 'NPC does the opposite of what you expected.';
      case ExpectationOutcome.oppositeIntensified:
        return 'NPC does the opposite of what you expected, emphatically!';
    }
  }
  
  /// Whether this outcome requires a follow-up roll on Modifier + Idea
  bool get requiresFollowUp => this == ExpectationOutcome.modifiedIdea;
}

/// Result of an Expectation Check.
class ExpectationCheckResult extends RollResult {
  final List<int> fateDice;
  final int fateSum;
  final ExpectationOutcome outcome;

  ExpectationCheckResult({
    required this.fateDice,
    required this.fateSum,
    required this.outcome,
  }) : super(
          type: RollType.expectationCheck,
          description: 'Expectation Check',
          diceResults: fateDice,
          total: fateSum,
          interpretation: outcome.displayText,
          metadata: {
            'fateDice': fateDice,
            'fateSum': fateSum,
            'outcome': outcome.name,
          },
        );

  /// Get symbolic representation of the Fate dice.
  String get fateSymbols => FateDiceFormatter.diceToSymbols(fateDice);

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Expectation Check:');
    buffer.writeln('  Dice: [$fateSymbols]');
    buffer.write('  Result: ${outcome.displayText}');
    return buffer.toString();
  }
}
