import '../roll_result.dart';
import '../../core/fate_dice_formatter.dart';
import 'discover_meaning_result.dart';

/// Possible outcomes from an Expectation Check.
/// Based on the Expectation table from Juice instructions (page 55).
enum ExpectationOutcome {
  expectedIntensified, // ++
  expected, // +0
  nextMostExpected, // +- or -+
  favorable, // 0+
  modifiedIdea, // 00
  unfavorable, // 0-
  opposite, // -0
  oppositeIntensified, // --
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
        return 'Use the Modifier + Idea result to alter your expectation.';
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
        return 'Use the Modifier + Idea result to determine NPC action.';
      case ExpectationOutcome.unfavorable:
        return 'NPC behavior is less helpful than expected.';
      case ExpectationOutcome.opposite:
        return 'NPC does the opposite of what you expected.';
      case ExpectationOutcome.oppositeIntensified:
        return 'NPC does the opposite of what you expected, emphatically!';
    }
  }
}

/// Result of an Expectation Check.
class ExpectationCheckResult extends RollResult {
  final List<int> fateDice;
  final int fateSum;
  final ExpectationOutcome outcome;

  /// Auto-rolled Modifier + Idea result when outcome is Modified Idea (O O)
  final DiscoverMeaningResult? meaningResult;

  ExpectationCheckResult({
    required this.fateDice,
    required this.fateSum,
    required this.outcome,
    this.meaningResult,
    DateTime? timestamp,
  }) : super(
          type: RollType.expectationCheck,
          description: 'Expectation Check',
          diceResults: [
            ...fateDice,
            if (meaningResult != null) ...[
              meaningResult.adjectiveRoll,
              meaningResult.nounRoll
            ],
          ],
          total: fateSum,
          interpretation: meaningResult != null
              ? '${outcome.displayText}: ${meaningResult.meaning}'
              : outcome.displayText,
          timestamp: timestamp,
          metadata: {
            'fateDice': fateDice,
            'fateSum': fateSum,
            'outcome': outcome.name,
            if (meaningResult != null) 'meaning': meaningResult.meaning,
          },
        );

  @override
  String get className => 'ExpectationCheckResult';

  factory ExpectationCheckResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final fateDice = (meta['fateDice'] as List?)?.cast<int>() ??
        (json['diceResults'] as List).take(2).cast<int>().toList();
    return ExpectationCheckResult(
      fateDice: fateDice,
      fateSum: meta['fateSum'] as int? ?? json['total'] as int,
      outcome: ExpectationOutcome.values.firstWhere(
        (e) => e.name == (meta['outcome'] as String),
        orElse: () => ExpectationOutcome.expected,
      ),
      meaningResult: meta['meaning'] != null
          ? null // Cannot fully reconstruct meaningResult without full data
          : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Get symbolic representation of the Fate dice.
  String get fateSymbols => FateDiceFormatter.diceToSymbols(fateDice);

  /// Whether this result has an auto-rolled meaning (for Modified Idea outcome)
  bool get hasMeaning => meaningResult != null;

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Expectation Check:');
    buffer.writeln('  Dice: [$fateSymbols]');
    buffer.write('  Result: ${outcome.displayText}');
    if (meaningResult != null) {
      buffer.write('\n  Modifier + Idea: ${meaningResult!.meaning}');
    }
    return buffer.toString();
  }
}
