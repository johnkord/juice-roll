import '../core/roll_engine.dart';

// Re-export result classes for backward compatibility
export '../models/results/scale_result.dart';

import '../models/results/scale_result.dart';

/// Scale preset for the Juice Oracle.
/// Converts 2dF + 1d6 to percentage modifiers for quantity/value adjustments.
/// 
/// Based on expectation-behavior-intensity-scale.md Scale column.
/// Used when you need to modify a value (price, distance, duration, etc.)
class Scale {
  final RollEngine _rollEngine;

  /// Scale modifiers mapped by 2dF+1d6 sum (-1 to 8)
  static const Map<int, String> scaleModifiers = {
    -1: '-100%',  // -- (with low intensity)
    0: '-50%',
    1: '-25%',
    2: '-10%',
    3: '-',       // No change
    4: '-',       // No change
    5: '+10%',
    6: '+25%',
    7: '+50%',
    8: '+100%',
  };

  /// Numeric multipliers for programmatic use
  static const Map<int, double> scaleMultipliers = {
    -1: 0.0,    // -100%
    0: 0.5,     // -50%
    1: 0.75,    // -25%
    2: 0.9,     // -10%
    3: 1.0,     // No change
    4: 1.0,     // No change
    5: 1.1,     // +10%
    6: 1.25,    // +25%
    7: 1.5,     // +50%
    8: 2.0,     // +100%
  };

  Scale([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  /// Roll for a scale modifier (2dF + 1d6).
  ScaleResult roll() {
    // Roll 2 Fate dice
    final fateDice = _rollEngine.rollFateDice(2);
    final fateSum = fateDice[0] + fateDice[1];
    
    // Roll intensity die (1d6)
    final intensity = _rollEngine.rollDie(6);
    
    // Calculate total for scale lookup
    final total = fateSum + intensity;
    
    // Clamp to valid range (-1 to 8)
    final clampedTotal = total.clamp(-1, 8);
    
    final modifier = scaleModifiers[clampedTotal] ?? '-';
    final multiplier = scaleMultipliers[clampedTotal] ?? 1.0;

    return ScaleResult(
      fateDice: fateDice,
      fateSum: fateSum,
      intensity: intensity,
      total: total,
      modifier: modifier,
      multiplier: multiplier,
    );
  }

  /// Apply scale to a base value.
  ScaledValueResult applyToValue(num baseValue) {
    final scaleRoll = roll();
    final scaledValue = baseValue * scaleRoll.multiplier;
    
    return ScaledValueResult(
      scaleResult: scaleRoll,
      baseValue: baseValue,
      scaledValue: scaledValue,
    );
  }
}
