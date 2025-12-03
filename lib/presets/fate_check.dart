import '../core/roll_engine.dart';
import '../core/table_lookup.dart';
import '../models/roll_result.dart';

/// Fate Check preset for the Juice Oracle.
/// Uses 2dF (Fate dice) + 1d6 (Intensity) to answer yes/no questions.
/// 
/// The Juice Oracle Fate Check uses ordered Fate dice:
/// - Left die (primary) and Right die (secondary)
/// - Double blanks trigger special events based on which die is "primary"
class FateCheck {
  final RollEngine _rollEngine;

  /// Likelihood modes for the Fate Check.
  /// These shift interpretation rather than modifying dice.
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
  FateCheckResult check({String likelihood = 'Even Odds'}) {
    // Roll 2 Fate dice (ordered: left is primary, right is secondary)
    final fateDice = _rollEngine.rollFateDice(2);
    final leftDie = fateDice[0];   // Primary die
    final rightDie = fateDice[1];  // Secondary die
    final fateSum = leftDie + rightDie;
    
    // Roll Intensity die (1d6)
    final intensity = _rollEngine.rollDie(6);
    
    // Check for special triggers (double blanks)
    final isDoubleBlanks = leftDie == 0 && rightDie == 0;
    SpecialTrigger? specialTrigger;
    
    if (isDoubleBlanks) {
      // In Juice Oracle, primary die position determines the trigger:
      // - Primary on left (default) → Random Event
      // - Primary on right → Invalid Assumption
      // Since we always treat left as primary, we use intensity to determine:
      // - Intensity 1-3: Random Event (left-weighted)
      // - Intensity 4-6: Invalid Assumption (right-weighted)
      specialTrigger = intensity <= 3 
          ? SpecialTrigger.randomEvent 
          : SpecialTrigger.invalidAssumption;
    }
    
    // Determine base outcome from Fate dice sum
    final baseOutcome = _interpretFateSum(fateSum);
    
    // Apply likelihood shift
    final outcome = _applyLikelihood(baseOutcome, likelihood);

    return FateCheckResult(
      likelihood: likelihood,
      fateDice: fateDice,
      fateSum: fateSum,
      intensity: intensity,
      outcome: outcome,
      specialTrigger: specialTrigger,
    );
  }

  /// Interpret the sum of 2dF into a base outcome.
  /// Range is -2 to +2.
  FateCheckOutcome _interpretFateSum(int sum) {
    switch (sum) {
      case -2:
        return FateCheckOutcome.extremeNo;
      case -1:
        return FateCheckOutcome.noAnd;
      case 0:
        return FateCheckOutcome.mixed; // Could go either way
      case 1:
        return FateCheckOutcome.yesAnd;
      case 2:
        return FateCheckOutcome.extremeYes;
      default:
        return FateCheckOutcome.mixed;
    }
  }

  /// Apply likelihood to shift ambiguous results.
  FateCheckOutcome _applyLikelihood(FateCheckOutcome base, String likelihood) {
    // Only shift "mixed" results (sum of 0)
    if (base != FateCheckOutcome.mixed) {
      return base;
    }
    
    switch (likelihood) {
      case 'Unlikely':
        return FateCheckOutcome.noBut;
      case 'Likely':
        return FateCheckOutcome.yesBut;
      case 'Even Odds':
      default:
        // For even odds on mixed, lean slightly toward "yes but" (Ironsworn weak-hit vibe)
        return FateCheckOutcome.yesBut;
    }
  }
}

/// Special triggers from double blanks on Fate dice.
enum SpecialTrigger {
  /// Something unexpected happens - roll on Random Event tables.
  randomEvent,
  
  /// Your assumption about the situation was wrong.
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
  extremeNo,
  noAnd,
  noBut,
  mixed,      // Ambiguous - resolved by likelihood
  yesBut,
  yesAnd,
  extremeYes,
}

/// Extension to provide display text for outcomes.
extension FateCheckOutcomeDisplay on FateCheckOutcome {
  String get displayText {
    switch (this) {
      case FateCheckOutcome.extremeNo:
        return 'Extreme No!';
      case FateCheckOutcome.noAnd:
        return 'No, and...';
      case FateCheckOutcome.noBut:
        return 'No, but...';
      case FateCheckOutcome.mixed:
        return 'Mixed';
      case FateCheckOutcome.yesBut:
        return 'Yes, but...';
      case FateCheckOutcome.yesAnd:
        return 'Yes, and...';
      case FateCheckOutcome.extremeYes:
        return 'Extreme Yes!';
    }
  }

  /// Whether this is fundamentally a "yes" answer.
  bool get isYes {
    return this == FateCheckOutcome.yesBut ||
           this == FateCheckOutcome.yesAnd ||
           this == FateCheckOutcome.extremeYes;
  }

  /// Whether this is fundamentally a "no" answer.
  bool get isNo {
    return this == FateCheckOutcome.noBut ||
           this == FateCheckOutcome.noAnd ||
           this == FateCheckOutcome.extremeNo;
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

  FateCheckResult({
    required this.likelihood,
    required this.fateDice,
    required this.fateSum,
    required this.intensity,
    required this.outcome,
    this.specialTrigger,
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

  /// Whether this result triggered a special event.
  bool get hasSpecialTrigger => specialTrigger != null;

  /// Intensity description based on the d6 value.
  String get intensityDescription {
    switch (intensity) {
      case 1:
        return 'Minimal';
      case 2:
        return 'Weak';
      case 3:
        return 'Moderate';
      case 4:
        return 'Strong';
      case 5:
        return 'Powerful';
      case 6:
        return 'Extreme';
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
