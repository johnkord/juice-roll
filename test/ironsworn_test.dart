import 'package:flutter_test/flutter_test.dart';
import 'package:juice_roll/models/results/ironsworn_result.dart';
import 'package:juice_roll/core/roll_engine.dart';
import 'test_utils.dart';

void main() {
  group('Ironsworn Roll Types', () {
    late RollEngine engine;

    setUp(() {
      engine = RollEngine(SeededRandom(42));
    });

    group('IronswornActionResult', () {
      test('strong hit when action score beats both challenge dice', () {
        // Action score 8 vs challenge dice [3, 5] = Strong Hit
        final result = IronswornActionResult(
          actionDie: 5,
          challengeDice: [3, 5],
          statBonus: 2,
          adds: 1,
        );
        
        expect(result.actionScore, equals(8));
        expect(result.outcome, equals(IronswornOutcome.strongHit));
        expect(result.outcome.isSuccess, isTrue);
      });

      test('weak hit when action score beats one challenge die', () {
        // Action score 6 vs challenge dice [4, 8] = Weak Hit
        final result = IronswornActionResult(
          actionDie: 4,
          challengeDice: [4, 8],
          statBonus: 2,
          adds: 0,
        );
        
        expect(result.actionScore, equals(6));
        expect(result.outcome, equals(IronswornOutcome.weakHit));
        expect(result.outcome.isSuccess, isTrue);
      });

      test('miss when action score beats neither challenge die', () {
        // Action score 4 vs challenge dice [5, 7] = Miss
        final result = IronswornActionResult(
          actionDie: 2,
          challengeDice: [5, 7],
          statBonus: 2,
          adds: 0,
        );
        
        expect(result.actionScore, equals(4));
        expect(result.outcome, equals(IronswornOutcome.miss));
        expect(result.outcome.isSuccess, isFalse);
      });

      test('detects match when challenge dice are equal', () {
        final matchResult = IronswornActionResult(
          actionDie: 4,
          challengeDice: [6, 6],
          statBonus: 2,
          adds: 0,
        );
        
        expect(matchResult.isMatch, isTrue);
        
        final noMatchResult = IronswornActionResult(
          actionDie: 4,
          challengeDice: [5, 7],
          statBonus: 2,
          adds: 0,
        );
        
        expect(noMatchResult.isMatch, isFalse);
      });

      test('action score calculation is correct', () {
        final result = IronswornActionResult(
          actionDie: 3,
          challengeDice: [5, 5],
          statBonus: 2,
          adds: 1,
        );
        
        expect(result.actionScore, equals(6)); // 3 + 2 + 1
        expect(result.actionDie, equals(3));
        expect(result.statBonus, equals(2));
        expect(result.adds, equals(1));
      });

      test('serialization round-trip preserves all data', () {
        final original = IronswornActionResult(
          actionDie: 5,
          challengeDice: [3, 7],
          statBonus: 2,
          adds: 1,
        );
        
        final json = original.toJson();
        final restored = IronswornActionResult.fromJson(json);
        
        expect(restored.actionDie, equals(original.actionDie));
        expect(restored.challengeDice, equals(original.challengeDice));
        expect(restored.statBonus, equals(original.statBonus));
        expect(restored.adds, equals(original.adds));
        expect(restored.actionScore, equals(original.actionScore));
        expect(restored.outcome, equals(original.outcome));
        expect(restored.isMatch, equals(original.isMatch));
      });

      test('toString provides readable output', () {
        final result = IronswornActionResult(
          actionDie: 4,
          challengeDice: [3, 5],
          statBonus: 2,
          adds: 0,
        );
        
        final output = result.toString();
        expect(output, contains('Action Roll'));
        expect(output, contains('Strong Hit'));
      });

      test('sections provides structured display data', () {
        final result = IronswornActionResult(
          actionDie: 4,
          challengeDice: [3, 5],
          statBonus: 2,
          adds: 0,
        );
        
        expect(result.sections.isNotEmpty, isTrue);
      });
    });

    group('IronswornProgressResult', () {
      test('strong hit when progress beats both challenge dice', () {
        final result = IronswornProgressResult(
          progressScore: 8,
          challengeDice: [3, 5],
        );
        
        expect(result.outcome, equals(IronswornOutcome.strongHit));
      });

      test('weak hit when progress beats one challenge die', () {
        final result = IronswornProgressResult(
          progressScore: 6,
          challengeDice: [4, 8],
        );
        
        expect(result.outcome, equals(IronswornOutcome.weakHit));
      });

      test('miss when progress beats neither challenge die', () {
        final result = IronswornProgressResult(
          progressScore: 3,
          challengeDice: [5, 7],
        );
        
        expect(result.outcome, equals(IronswornOutcome.miss));
      });

      test('detects match when challenge dice are equal', () {
        final result = IronswornProgressResult(
          progressScore: 8,
          challengeDice: [4, 4],
        );
        
        expect(result.isMatch, isTrue);
      });

      test('serialization round-trip preserves all data', () {
        final original = IronswornProgressResult(
          progressScore: 7,
          challengeDice: [4, 6],
        );
        
        final json = original.toJson();
        final restored = IronswornProgressResult.fromJson(json);
        
        expect(restored.progressScore, equals(original.progressScore));
        expect(restored.challengeDice, equals(original.challengeDice));
        expect(restored.outcome, equals(original.outcome));
        expect(restored.isMatch, equals(original.isMatch));
      });

      test('toString provides readable output', () {
        final result = IronswornProgressResult(
          progressScore: 6,
          challengeDice: [3, 8],
        );
        
        final output = result.toString();
        expect(output, contains('Progress Roll'));
        expect(output, contains('Weak Hit'));
      });
    });

    group('IronswornOracleResult', () {
      test('stores oracle roll value', () {
        final result = IronswornOracleResult(
          oracleRoll: 67,
        );
        
        expect(result.oracleRoll, equals(67));
        expect(result.total, equals(67));
      });

      test('can include oracle table name', () {
        final result = IronswornOracleResult(
          oracleRoll: 42,
          oracleTable: 'Character Role',
        );
        
        expect(result.oracleTable, equals('Character Role'));
        expect(result.description, contains('Character Role'));
      });

      test('serialization round-trip preserves all data', () {
        final original = IronswornOracleResult(
          oracleRoll: 88,
          oracleTable: 'Action',
        );
        
        final json = original.toJson();
        final restored = IronswornOracleResult.fromJson(json);
        
        expect(restored.oracleRoll, equals(original.oracleRoll));
        expect(restored.oracleTable, equals(original.oracleTable));
      });

      test('toString provides readable output', () {
        final result = IronswornOracleResult(
          oracleRoll: 55,
          oracleTable: 'Theme',
        );
        
        final output = result.toString();
        expect(output, contains('55'));
        expect(output, contains('Theme'));
      });
    });

    group('IronswornOutcome', () {
      test('all outcomes have display text', () {
        for (final outcome in IronswornOutcome.values) {
          expect(outcome.displayText.isNotEmpty, isTrue);
        }
      });

      test('all outcomes have descriptions', () {
        for (final outcome in IronswornOutcome.values) {
          expect(outcome.description.isNotEmpty, isTrue);
        }
      });

      test('isSuccess is correct for each outcome', () {
        expect(IronswornOutcome.strongHit.isSuccess, isTrue);
        expect(IronswornOutcome.weakHit.isSuccess, isTrue);
        expect(IronswornOutcome.miss.isSuccess, isFalse);
      });
    });

    group('Integration with RollEngine', () {
      test('can create action roll using roll engine', () {
        final actionDie = engine.rollDie(6);
        final challengeDice = engine.rollDice(2, 10);
        
        final result = IronswornActionResult(
          actionDie: actionDie,
          challengeDice: challengeDice,
          statBonus: 2,
          adds: 1,
        );
        
        expect(result.actionDie, greaterThanOrEqualTo(1));
        expect(result.actionDie, lessThanOrEqualTo(6));
        expect(result.challengeDice[0], greaterThanOrEqualTo(1));
        expect(result.challengeDice[0], lessThanOrEqualTo(10));
        expect(result.challengeDice[1], greaterThanOrEqualTo(1));
        expect(result.challengeDice[1], lessThanOrEqualTo(10));
        expect(IronswornOutcome.values.contains(result.outcome), isTrue);
      });

      test('can create progress roll using roll engine', () {
        final challengeDice = engine.rollDice(2, 10);
        
        final result = IronswornProgressResult(
          progressScore: 7,
          challengeDice: challengeDice,
        );
        
        expect(result.progressScore, equals(7));
        expect(IronswornOutcome.values.contains(result.outcome), isTrue);
      });

      test('can create oracle roll using roll engine', () {
        final oracleRoll = engine.rollDie(100);
        
        final result = IronswornOracleResult(
          oracleRoll: oracleRoll,
        );
        
        expect(result.oracleRoll, greaterThanOrEqualTo(1));
        expect(result.oracleRoll, lessThanOrEqualTo(100));
      });
    });

    group('IronswornYesNoResult', () {
      test('returns Yes when roll meets Almost Certain threshold', () {
        final result = IronswornYesNoResult(
          roll: 11,
          odds: IronswornOdds.almostCertain,
        );
        
        expect(result.isYes, isTrue);
        expect(result.odds.yesThreshold, equals(11));
      });

      test('returns No when roll is below threshold', () {
        final result = IronswornYesNoResult(
          roll: 10,
          odds: IronswornOdds.almostCertain,
        );
        
        expect(result.isYes, isFalse);
      });

      test('handles all odds levels correctly', () {
        // Almost Certain: 11+
        expect(IronswornYesNoResult(roll: 11, odds: IronswornOdds.almostCertain).isYes, isTrue);
        expect(IronswornYesNoResult(roll: 10, odds: IronswornOdds.almostCertain).isYes, isFalse);
        
        // Likely: 26+
        expect(IronswornYesNoResult(roll: 26, odds: IronswornOdds.likely).isYes, isTrue);
        expect(IronswornYesNoResult(roll: 25, odds: IronswornOdds.likely).isYes, isFalse);
        
        // 50/50: 51+
        expect(IronswornYesNoResult(roll: 51, odds: IronswornOdds.fiftyFifty).isYes, isTrue);
        expect(IronswornYesNoResult(roll: 50, odds: IronswornOdds.fiftyFifty).isYes, isFalse);
        
        // Unlikely: 76+
        expect(IronswornYesNoResult(roll: 76, odds: IronswornOdds.unlikely).isYes, isTrue);
        expect(IronswornYesNoResult(roll: 75, odds: IronswornOdds.unlikely).isYes, isFalse);
        
        // Small Chance: 91+
        expect(IronswornYesNoResult(roll: 91, odds: IronswornOdds.smallChance).isYes, isTrue);
        expect(IronswornYesNoResult(roll: 90, odds: IronswornOdds.smallChance).isYes, isFalse);
      });

      test('detects match on doubles', () {
        expect(IronswornYesNoResult(roll: 11, odds: IronswornOdds.likely).isMatch, isTrue);
        expect(IronswornYesNoResult(roll: 22, odds: IronswornOdds.likely).isMatch, isTrue);
        expect(IronswornYesNoResult(roll: 55, odds: IronswornOdds.likely).isMatch, isTrue);
        expect(IronswornYesNoResult(roll: 100, odds: IronswornOdds.likely).isMatch, isTrue);
        expect(IronswornYesNoResult(roll: 23, odds: IronswornOdds.likely).isMatch, isFalse);
      });

      test('serialization round-trip preserves data', () {
        final original = IronswornYesNoResult(
          roll: 42,
          odds: IronswornOdds.likely,
        );
        
        final json = original.toJson();
        final restored = IronswornYesNoResult.fromJson(json);
        
        expect(restored.roll, equals(original.roll));
        expect(restored.odds, equals(original.odds));
        expect(restored.isYes, equals(original.isYes));
      });
    });

    group('IronswornCursedOracleResult', () {
      test('detects curse when cursed die shows 10', () {
        final result = IronswornCursedOracleResult(
          oracleRoll: 50,
          cursedDie: 10,
        );
        
        expect(result.isCursed, isTrue);
      });

      test('no curse when cursed die is not 10', () {
        for (int i = 1; i <= 9; i++) {
          final result = IronswornCursedOracleResult(
            oracleRoll: 50,
            cursedDie: i,
          );
          
          expect(result.isCursed, isFalse, reason: 'Cursed die $i should not trigger curse');
        }
      });

      test('detects match on doubles in oracle roll', () {
        expect(IronswornCursedOracleResult(oracleRoll: 55, cursedDie: 5).isMatch, isTrue);
        expect(IronswornCursedOracleResult(oracleRoll: 56, cursedDie: 5).isMatch, isFalse);
      });

      test('serialization round-trip preserves data', () {
        final original = IronswornCursedOracleResult(
          oracleRoll: 77,
          cursedDie: 10,
        );
        
        final json = original.toJson();
        final restored = IronswornCursedOracleResult.fromJson(json);
        
        expect(restored.oracleRoll, equals(original.oracleRoll));
        expect(restored.cursedDie, equals(original.cursedDie));
        expect(restored.isCursed, equals(original.isCursed));
      });
    });

    group('IronswornMomentumBurnResult', () {
      test('calculates original and burned outcomes correctly', () {
        // Original: action 2 + stat 2 + adds 0 = 4 vs [5, 7] = miss
        // Burned: momentum 8 vs [5, 7] = strong hit
        final result = IronswornMomentumBurnResult(
          actionDie: 2,
          challengeDice: [5, 7],
          statBonus: 2,
          adds: 0,
          momentumValue: 8,
        );
        
        expect(result.originalActionScore, equals(4));
        expect(result.originalOutcome, equals(IronswornOutcome.miss));
        expect(result.burnedOutcome, equals(IronswornOutcome.strongHit));
        expect(result.wasUpgraded, isTrue);
      });

      test('detects when momentum burn did not upgrade', () {
        // Original: action 5 + stat 2 = 7 vs [4, 6] = strong hit
        // Burned: momentum 7 vs [4, 6] = strong hit (same)
        final result = IronswornMomentumBurnResult(
          actionDie: 5,
          challengeDice: [4, 6],
          statBonus: 2,
          adds: 0,
          momentumValue: 7,
        );
        
        expect(result.originalOutcome, equals(IronswornOutcome.strongHit));
        expect(result.burnedOutcome, equals(IronswornOutcome.strongHit));
        expect(result.wasUpgraded, isFalse);
      });

      test('detects match on challenge dice', () {
        final result = IronswornMomentumBurnResult(
          actionDie: 2,
          challengeDice: [6, 6],
          statBonus: 2,
          adds: 0,
          momentumValue: 8,
        );
        
        expect(result.isMatch, isTrue);
      });

      test('serialization round-trip preserves data', () {
        final original = IronswornMomentumBurnResult(
          actionDie: 3,
          challengeDice: [5, 8],
          statBonus: 2,
          adds: 1,
          momentumValue: 9,
        );
        
        final json = original.toJson();
        final restored = IronswornMomentumBurnResult.fromJson(json);
        
        expect(restored.actionDie, equals(original.actionDie));
        expect(restored.challengeDice, equals(original.challengeDice));
        expect(restored.momentumValue, equals(original.momentumValue));
        expect(restored.originalOutcome, equals(original.originalOutcome));
        expect(restored.burnedOutcome, equals(original.burnedOutcome));
      });
    });

    group('IronswornOracleResult with variable die types', () {
      test('supports d6 oracle', () {
        final result = IronswornOracleResult(
          oracleRoll: 4,
          dieType: 6,
        );
        
        expect(result.dieType, equals(6));
        expect(result.oracleRoll, equals(4));
      });

      test('supports d20 oracle', () {
        final result = IronswornOracleResult(
          oracleRoll: 17,
          dieType: 20,
        );
        
        expect(result.dieType, equals(20));
        expect(result.oracleRoll, equals(17));
      });

      test('serialization preserves die type', () {
        final original = IronswornOracleResult(
          oracleRoll: 5,
          dieType: 6,
        );
        
        final json = original.toJson();
        final restored = IronswornOracleResult.fromJson(json);
        
        expect(restored.dieType, equals(6));
      });
    });
  });
}
