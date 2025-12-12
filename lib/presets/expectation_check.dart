import '../core/roll_engine.dart';

// Re-export result classes for backward compatibility
export '../models/results/expectation_check_result.dart';

import '../models/results/expectation_check_result.dart';
import 'discover_meaning.dart';

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
/// 
/// When the result is "O O" (Modified Idea), automatically rolls on the
/// Modifier + Idea (Discover Meaning) table to provide the modification.
class ExpectationCheck {
  final RollEngine _rollEngine;
  final DiscoverMeaning _discoverMeaning;

  ExpectationCheck([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine(),
        _discoverMeaning = DiscoverMeaning(rollEngine);

  /// Check if an expectation holds.
  ExpectationCheckResult check() {
    // Roll 2 Fate dice
    final fateDice = _rollEngine.rollFateDice(2);
    final primary = fateDice[0];
    final secondary = fateDice[1];
    
    // Interpret the result
    final outcome = _interpretDice(primary, secondary);
    
    // If the outcome is Modified Idea (O O), auto-roll on Discover Meaning table
    DiscoverMeaningResult? meaningResult;
    if (outcome == ExpectationOutcome.modifiedIdea) {
      meaningResult = _discoverMeaning.generate();
    }

    return ExpectationCheckResult(
      fateDice: fateDice,
      fateSum: primary + secondary,
      outcome: outcome,
      meaningResult: meaningResult,
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
