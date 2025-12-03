import '../core/roll_engine.dart';
import '../core/table_lookup.dart';
import '../models/roll_result.dart';

/// Fate Check preset for the Juice Oracle.
/// Answers yes/no questions with varying degrees of certainty.
class FateCheck {
  final RollEngine _rollEngine;

  /// Likelihood modifiers for the Fate Check.
  static const Map<String, int> likelihoods = {
    'Impossible': -4,
    'No Way': -3,
    'Very Unlikely': -2,
    'Unlikely': -1,
    'Even Odds': 0,
    'Likely': 1,
    'Very Likely': 2,
    'Near Sure Thing': 3,
    'A Sure Thing': 4,
  };

  /// Fate Check result table based on 2d6 + modifier.
  static final LookupTable<FateCheckOutcome> _outcomeTable = LookupTable(
    name: 'Fate Check',
    entries: [
      const TableEntry(minValue: -100, maxValue: 2, result: FateCheckOutcome.extremeNo),
      const TableEntry(minValue: 3, maxValue: 4, result: FateCheckOutcome.no),
      const TableEntry(minValue: 5, maxValue: 6, result: FateCheckOutcome.noAnd),
      const TableEntry(minValue: 7, maxValue: 7, result: FateCheckOutcome.noBut),
      const TableEntry(minValue: 8, maxValue: 8, result: FateCheckOutcome.yesBut),
      const TableEntry(minValue: 9, maxValue: 10, result: FateCheckOutcome.yesAnd),
      const TableEntry(minValue: 11, maxValue: 12, result: FateCheckOutcome.yes),
      const TableEntry(minValue: 13, maxValue: 100, result: FateCheckOutcome.extremeYes),
    ],
  );

  FateCheck([RollEngine? rollEngine]) 
      : _rollEngine = rollEngine ?? RollEngine();

  /// Perform a Fate Check with the given likelihood.
  FateCheckResult check({String likelihood = 'Even Odds'}) {
    final modifier = likelihoods[likelihood] ?? 0;
    final dice = _rollEngine.rollDice(2, 6);
    final sum = dice.reduce((a, b) => a + b);
    final modifiedSum = sum + modifier;
    
    final outcome = _outcomeTable.lookup(modifiedSum) ?? FateCheckOutcome.noBut;

    return FateCheckResult(
      likelihood: likelihood,
      modifier: modifier,
      diceResults: dice,
      rawTotal: sum,
      modifiedTotal: modifiedSum,
      outcome: outcome,
    );
  }
}

/// Possible outcomes from a Fate Check.
enum FateCheckOutcome {
  extremeNo,
  no,
  noAnd,
  noBut,
  yesBut,
  yesAnd,
  yes,
  extremeYes,
}

/// Extension to provide display text for outcomes.
extension FateCheckOutcomeDisplay on FateCheckOutcome {
  String get displayText {
    switch (this) {
      case FateCheckOutcome.extremeNo:
        return 'Extreme No!';
      case FateCheckOutcome.no:
        return 'No';
      case FateCheckOutcome.noAnd:
        return 'No, and...';
      case FateCheckOutcome.noBut:
        return 'No, but...';
      case FateCheckOutcome.yesBut:
        return 'Yes, but...';
      case FateCheckOutcome.yesAnd:
        return 'Yes, and...';
      case FateCheckOutcome.yes:
        return 'Yes';
      case FateCheckOutcome.extremeYes:
        return 'Extreme Yes!';
    }
  }
}

/// Result of a Fate Check.
class FateCheckResult extends RollResult {
  final String likelihood;
  final int modifier;
  final int rawTotal;
  final int modifiedTotal;
  final FateCheckOutcome outcome;

  FateCheckResult({
    required this.likelihood,
    required this.modifier,
    required List<int> diceResults,
    required this.rawTotal,
    required this.modifiedTotal,
    required this.outcome,
  }) : super(
          type: RollType.fateCheck,
          description: 'Fate Check ($likelihood)',
          diceResults: diceResults,
          total: modifiedTotal,
          interpretation: outcome.displayText,
          metadata: {
            'likelihood': likelihood,
            'modifier': modifier,
            'rawTotal': rawTotal,
          },
        );

  @override
  String toString() {
    final modStr = modifier >= 0 ? '+$modifier' : '$modifier';
    return 'Fate Check ($likelihood): ${diceResults.join('+')}$modStr = $modifiedTotal → ${outcome.displayText}';
  }
}
