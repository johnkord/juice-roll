import 'dart:math';

/// Core dice rolling engine for JuiceRoll.
/// Supports NdX dice, Fate dice, advantage/disadvantage, and skewed d6.
class RollEngine {
  final Random _random;

  RollEngine([Random? random]) : _random = random ?? Random();

  /// Roll a single die with [sides] sides (1 to sides inclusive).
  /// Supports optional skew for advantage (higher) or disadvantage (lower).
  int rollDie(int sides, {dynamic skew}) {
    if (sides < 1) {
      throw ArgumentError('Dice must have at least 1 side');
    }
    
    // Handle skew parameter - can be SkewType enum or other types
    if (skew == null) {
      return _random.nextInt(sides) + 1;
    }
    
    // Check for SkewType enum by string representation
    final skewStr = skew.toString();
    if (skewStr.contains('advantage')) {
      // Roll twice, take higher
      final r1 = _random.nextInt(sides) + 1;
      final r2 = _random.nextInt(sides) + 1;
      return r1 >= r2 ? r1 : r2;
    } else if (skewStr.contains('disadvantage')) {
      // Roll twice, take lower
      final r1 = _random.nextInt(sides) + 1;
      final r2 = _random.nextInt(sides) + 1;
      return r1 <= r2 ? r1 : r2;
    }
    
    // No skew or unrecognized - straight roll
    return _random.nextInt(sides) + 1;
  }

  /// Roll [count] dice with [sides] sides each.
  /// Returns a list of individual results.
  List<int> rollDice(int count, int sides) {
    if (count < 1) {
      throw ArgumentError('Must roll at least 1 die');
    }
    return List.generate(count, (_) => rollDie(sides));
  }

  /// Roll [count]d[sides] and return the sum.
  int rollNdX(int count, int sides) {
    return rollDice(count, sides).reduce((a, b) => a + b);
  }

  /// Roll a single Fate die (dF): returns -1, 0, or +1.
  /// Two faces show -, two show blank, two show +.
  int rollFateDie() {
    final roll = _random.nextInt(6);
    if (roll < 2) return -1; // - faces
    if (roll < 4) return 0;  // blank faces
    return 1;                // + faces
  }

  /// Roll [count] Fate dice and return individual results.
  List<int> rollFateDice(int count) {
    if (count < 1) {
      throw ArgumentError('Must roll at least 1 Fate die');
    }
    return List.generate(count, (_) => rollFateDie());
  }

  /// Roll [count] Fate dice and return the sum.
  int rollFate(int count) {
    return rollFateDice(count).reduce((a, b) => a + b);
  }

  /// Roll with advantage: roll [count]d[sides] twice, take the higher sum.
  RollWithAdvantageResult rollWithAdvantage(int count, int sides) {
    final roll1 = rollDice(count, sides);
    final roll2 = rollDice(count, sides);
    final sum1 = roll1.reduce((a, b) => a + b);
    final sum2 = roll2.reduce((a, b) => a + b);
    
    return RollWithAdvantageResult(
      roll1: roll1,
      roll2: roll2,
      sum1: sum1,
      sum2: sum2,
      chosenSum: sum1 >= sum2 ? sum1 : sum2,
      usedFirst: sum1 >= sum2,
    );
  }

  /// Roll with disadvantage: roll [count]d[sides] twice, take the lower sum.
  RollWithAdvantageResult rollWithDisadvantage(int count, int sides) {
    final roll1 = rollDice(count, sides);
    final roll2 = rollDice(count, sides);
    final sum1 = roll1.reduce((a, b) => a + b);
    final sum2 = roll2.reduce((a, b) => a + b);
    
    return RollWithAdvantageResult(
      roll1: roll1,
      roll2: roll2,
      sum1: sum1,
      sum2: sum2,
      chosenSum: sum1 <= sum2 ? sum1 : sum2,
      usedFirst: sum1 <= sum2,
    );
  }

  /// Roll a skewed d6: values weighted toward lower or higher results.
  /// [skew] < 0 favors lower results, [skew] > 0 favors higher results.
  /// [skew] should typically be between -3 and 3.
  int rollSkewedD6(int skew) {
    // Roll multiple d6 and take highest or lowest based on skew
    if (skew == 0) {
      return rollDie(6);
    }
    
    final absSkew = skew.abs();
    final rolls = rollDice(absSkew + 1, 6);
    
    if (skew > 0) {
      // Favor higher: take maximum
      return rolls.reduce((a, b) => a > b ? a : b);
    } else {
      // Favor lower: take minimum
      return rolls.reduce((a, b) => a < b ? a : b);
    }
  }
}

/// Result of a roll with advantage or disadvantage.
class RollWithAdvantageResult {
  final List<int> roll1;
  final List<int> roll2;
  final int sum1;
  final int sum2;
  final int chosenSum;
  final bool usedFirst;

  const RollWithAdvantageResult({
    required this.roll1,
    required this.roll2,
    required this.sum1,
    required this.sum2,
    required this.chosenSum,
    required this.usedFirst,
  });

  List<int> get chosenRoll => usedFirst ? roll1 : roll2;
  List<int> get discardedRoll => usedFirst ? roll2 : roll1;
  int get discardedSum => usedFirst ? sum2 : sum1;

  @override
  String toString() {
    return 'Chose $chosenSum from [$sum1, $sum2]';
  }
}
