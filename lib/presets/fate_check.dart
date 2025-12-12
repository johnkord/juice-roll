import '../core/roll_engine.dart';

// Re-export result classes for backward compatibility
export '../models/results/fate_check_result.dart';

import '../models/results/fate_check_result.dart';
import 'random_event.dart';

/// Fate Check preset for the Juice Oracle.
/// Uses 2dF (Fate dice) + 1d6 (Intensity) to answer yes/no questions.
/// 
/// The Juice Oracle Fate Check uses ordered Fate dice:
/// - Primary die (tracked by color/position) determines base answer
/// - Secondary die modifies the answer (And/But)
/// - Double blanks: position determines Random Event vs Invalid Assumption
/// 
/// Primary interpretation:
/// - + = Yes-like result
/// - - = No-like result  
/// - 0 = Look to secondary (Favorable/Unfavorable)
/// 
/// Secondary modifies:
/// - ++ = Yes And, +- = Yes But
/// - -- = No And, -+ = No But
/// - 0+ = Favorable, 0- = Unfavorable
/// - 00 (primary left) = Random Event, 00 (primary right) = Invalid Assumption
/// 
/// When a Random Event is triggered (O O with primary on left), automatically
/// rolls on the Random Event tables to provide the event details.
class FateCheck {
  final RollEngine _rollEngine;
  final RandomEvent _randomEvent;

  /// Likelihood modes for the Fate Check.
  /// Likely: If either die is +, result is Yes-like
  /// Unlikely: If either die is -, result is No-like
  static const List<String> likelihoods = [
    'Unlikely',
    'Even Odds',
    'Likely',
  ];

  FateCheck([RollEngine? rollEngine]) 
      : _rollEngine = rollEngine ?? RollEngine(),
        _randomEvent = RandomEvent(rollEngine);

  /// Perform a Fate Check with the given likelihood.
  /// 
  /// Rolls 2dF (ordered) + 1d6 Intensity, then interprets the result.
  /// [primaryOnLeft] simulates which die is "primary" for double-blank handling.
  /// 
  /// If a Random Event is triggered (O O with primary on left), automatically
  /// rolls on the Random Event tables and includes the result.
  FateCheckResult check({
    String likelihood = 'Even Odds',
    bool? primaryOnLeft,
  }) {
    // Roll 2 Fate dice (ordered)
    final fateDice = _rollEngine.rollFateDice(2);
    final primary = fateDice[0];   // Primary die
    final secondary = fateDice[1]; // Secondary die
    
    // Roll Intensity die (1d6)
    final intensity = _rollEngine.rollDie(6);
    
    // Simulate position: if not specified, 50/50 chance for double blanks
    final isPrimaryLeft = primaryOnLeft ?? (_rollEngine.rollDie(2) == 1);
    
    // Check for special triggers (double blanks)
    final isDoubleBlanks = primary == 0 && secondary == 0;
    SpecialTrigger? specialTrigger;
    RandomEventResult? randomEventResult;
    
    if (isDoubleBlanks) {
      // Primary on left → Random Event (answer is "Yes But")
      // Primary on right → Invalid Assumption
      specialTrigger = isPrimaryLeft 
          ? SpecialTrigger.randomEvent 
          : SpecialTrigger.invalidAssumption;
      
      // Auto-roll Random Event if triggered
      if (specialTrigger == SpecialTrigger.randomEvent) {
        randomEventResult = _randomEvent.generate();
      }
    }
    
    // Determine outcome based on Juice Oracle rules
    final outcome = _interpretDice(primary, secondary, likelihood, isDoubleBlanks);

    return FateCheckResult(
      likelihood: likelihood,
      fateDice: fateDice,
      fateSum: primary + secondary,
      intensity: intensity,
      outcome: outcome,
      specialTrigger: specialTrigger,
      primaryOnLeft: isPrimaryLeft,
      randomEventResult: randomEventResult,
    );
  }

  /// Interpret dice according to Juice Oracle Fate Check rules.
  /// 
  /// Normal (Even Odds) column:
  /// - ++ → Yes And
  /// - +0 → Yes Because
  /// - +- → Yes But
  /// - 0+ → Favorable
  /// - 00 (primary left) → Yes But + Random Event
  /// - 00 (primary right) → Invalid Assumption
  /// - 0- → Unfavorable
  /// - -+ → No But
  /// - -0 → No Because
  /// - -- → No And
  /// 
  /// Likely column: If either die is +, result is Yes-like
  /// - ++ → Yes And
  /// - +0, 0+, >0 → Yes
  /// - +-, -+ → Yes But
  /// - <0 → Yes + Random Event
  /// - 0-, -0 → No
  /// - -- → No And
  /// 
  /// Unlikely column: If either die is -, result is No-like
  /// - ++ → Yes And
  /// - +0, 0+ → Yes
  /// - +-, -+ → No But
  /// - <0 → No + Random Event
  /// - >0, 0-, -0 → No
  /// - -- → No And
  FateCheckOutcome _interpretDice(
    int primary, 
    int secondary, 
    String likelihood,
    bool isDoubleBlanks,
  ) {
    // Handle Likely mode
    // Rule: If either die is +, result is Yes-like
    if (likelihood == 'Likely') {
      // ++ → Yes And
      if (primary == 1 && secondary == 1) return FateCheckOutcome.yesAnd;
      // -- → No And
      if (primary == -1 && secondary == -1) return FateCheckOutcome.noAnd;
      // +- or -+ → Yes But (both have a +, so Yes But)
      if ((primary == 1 && secondary == -1) || (primary == -1 && secondary == 1)) {
        return FateCheckOutcome.yesBut;
      }
      // +0 or 0+ → Yes (either die is +)
      if (primary == 1 || secondary == 1) {
        return FateCheckOutcome.yes; // "Yes" in Likely column
      }
      // Double blanks: <0 → Yes + Random Event, >0 → Yes
      if (isDoubleBlanks) {
        return FateCheckOutcome.yes;
      }
      // 0- or -0 → No (no + present)
      if ((primary == 0 && secondary == -1) || (primary == -1 && secondary == 0)) {
        return FateCheckOutcome.no;
      }
    }
    
    // Handle Unlikely mode
    // Rule: If either die is -, result is No-like
    if (likelihood == 'Unlikely') {
      // ++ → Yes And (no - present)
      if (primary == 1 && secondary == 1) return FateCheckOutcome.yesAnd;
      // -- → No And
      if (primary == -1 && secondary == -1) return FateCheckOutcome.noAnd;
      // +- or -+ → No But (both have a -, so No But)
      if ((primary == 1 && secondary == -1) || (primary == -1 && secondary == 1)) {
        return FateCheckOutcome.noBut;
      }
      // +0 or 0+ → Yes (no - present)
      if ((primary == 1 && secondary == 0) || (primary == 0 && secondary == 1)) {
        return FateCheckOutcome.yes;
      }
      // 0- or -0 → No (has a -)
      if ((primary == 0 && secondary == -1) || (primary == -1 && secondary == 0)) {
        return FateCheckOutcome.no;
      }
      // Double blanks: <0 → No + Random Event, >0 → No
      if (isDoubleBlanks) {
        return FateCheckOutcome.no;
      }
    }
    
    // Standard interpretation (Even Odds)
    
    // Double blanks special case - answer is "Yes But" for Random Event
    if (isDoubleBlanks) {
      return FateCheckOutcome.yesBut;
    }
    
    // Primary + = Yes-like
    if (primary == 1) {
      if (secondary == 1) return FateCheckOutcome.yesAnd;
      if (secondary == -1) return FateCheckOutcome.yesBut;
      return FateCheckOutcome.yesBecause; // +0 → Yes Because
    }
    
    // Primary - = No-like
    if (primary == -1) {
      if (secondary == -1) return FateCheckOutcome.noAnd;
      if (secondary == 1) return FateCheckOutcome.noBut;
      return FateCheckOutcome.noBecause; // -0 → No Because
    }
    
    // Primary 0 = look to secondary
    if (secondary == 1) return FateCheckOutcome.favorable;
    if (secondary == -1) return FateCheckOutcome.unfavorable;
    
    // Should not reach here (double blanks handled above)
    return FateCheckOutcome.favorable;
  }
}
