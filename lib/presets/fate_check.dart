import '../core/roll_engine.dart';
import '../core/fate_dice_formatter.dart';
import '../models/roll_result.dart';

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
class FateCheck {
  final RollEngine _rollEngine;

  /// Likelihood modes for the Fate Check.
  /// Likely: If either die is +, result is Yes-like
  /// Unlikely: If either die is -, result is No-like
  static const List<String> likelihoods = [
    'Unlikely',
    'Even Odds',
    'Likely',
  ];

  FateCheck([RollEngine? rollEngine]) 
      : _rollEngine = rollEngine ?? RollEngine();

  /// Perform a Fate Check with the given likelihood.
  /// 
  /// Rolls 2dF (ordered) + 1d6 Intensity, then interprets the result.
  /// [primaryOnLeft] simulates which die is "primary" for double-blank handling.
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
    
    if (isDoubleBlanks) {
      // Primary on left → Random Event (answer is "Yes But")
      // Primary on right → Invalid Assumption
      specialTrigger = isPrimaryLeft 
          ? SpecialTrigger.randomEvent 
          : SpecialTrigger.invalidAssumption;
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
        return 'Something unexpected happens. Roll on the Random Event tables.';
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

  FateCheckResult({
    required this.likelihood,
    required this.fateDice,
    required this.fateSum,
    required this.intensity,
    required this.outcome,
    this.specialTrigger,
    this.primaryOnLeft = true,
  }) : super(
          type: RollType.fateCheck,
          description: 'Fate Check ($likelihood)',
          diceResults: [...fateDice, intensity],
          total: fateSum,
          interpretation: _buildInterpretation(outcome, intensity, specialTrigger),
          metadata: {
            'likelihood': likelihood,
            'fateDice': fateDice,
            'fateSum': fateSum,
            'intensity': intensity,
            'outcome': outcome.name,
            'specialTrigger': specialTrigger?.name,
            'primaryOnLeft': primaryOnLeft,
          },
        );

  static String _buildInterpretation(
    FateCheckOutcome outcome,
    int intensity,
    SpecialTrigger? trigger,
  ) {
    final parts = <String>[outcome.displayText];
    
    if (trigger != null) {
      parts.add(trigger.displayText);
    }
    
    return parts.join(' + ');
  }

  /// Get symbolic representation of the Fate dice.
  String get fateSymbols => FateDiceFormatter.diceToSymbols(fateDice);

  /// Whether this result triggered a special event.
  bool get hasSpecialTrigger => specialTrigger != null;

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
    return buffer.toString();
  }
}
