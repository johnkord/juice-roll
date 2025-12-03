import 'package:flutter_test/flutter_test.dart';
import 'package:juice_roll/presets/fate_check.dart';
import 'package:juice_roll/presets/next_scene.dart';
import 'package:juice_roll/presets/random_event.dart';
import 'package:juice_roll/presets/exploration.dart';
import 'package:juice_roll/core/roll_engine.dart';
import 'test_utils.dart';

void main() {
  group('FateCheck', () {
    test('likelihoods contains expected values', () {
      expect(FateCheck.likelihoods.keys, contains('Even Odds'));
      expect(FateCheck.likelihoods.keys, contains('Likely'));
      expect(FateCheck.likelihoods.keys, contains('Unlikely'));
      expect(FateCheck.likelihoods['Even Odds'], equals(0));
    });

    test('check returns valid outcome', () {
      final fateCheck = FateCheck(RollEngine(SeededRandom(42)));
      final result = fateCheck.check();

      expect(result.diceResults.length, equals(2));
      expect(result.rawTotal, greaterThanOrEqualTo(2));
      expect(result.rawTotal, lessThanOrEqualTo(12));
      expect(FateCheckOutcome.values, contains(result.outcome));
    });

    test('modifier affects modifiedTotal', () {
      final fateCheck = FateCheck(RollEngine(SeededRandom(42)));
      
      final evenResult = fateCheck.check(likelihood: 'Even Odds');
      
      final fateCheck2 = FateCheck(RollEngine(SeededRandom(42)));
      final likelyResult = fateCheck2.check(likelihood: 'Likely');

      // Same dice, different modifiers
      expect(evenResult.rawTotal, equals(likelyResult.rawTotal));
      expect(likelyResult.modifiedTotal, equals(evenResult.modifiedTotal + 1));
    });

    test('all outcomes have display text', () {
      for (final outcome in FateCheckOutcome.values) {
        expect(outcome.displayText.isNotEmpty, isTrue);
      }
    });
  });

  group('NextScene', () {
    test('chaosLevels contains expected values', () {
      expect(NextScene.chaosLevels.keys, contains('Normal'));
      expect(NextScene.chaosLevels.keys, contains('Chaotic'));
      expect(NextScene.chaosLevels['Normal'], equals(0));
    });

    test('determineScene returns valid scene type', () {
      final nextScene = NextScene(RollEngine(SeededRandom(42)));
      final result = nextScene.determineScene();

      expect(result.diceResults.length, equals(2));
      expect(SceneType.values, contains(result.sceneType));
    });

    test('isInterrupt is true for doubles', () {
      // We need to find a seed that produces doubles
      bool foundDoubles = false;
      for (int seed = 0; seed < 1000 && !foundDoubles; seed++) {
        final nextScene = NextScene(RollEngine(SeededRandom(seed)));
        final result = nextScene.determineScene();
        if (result.diceResults[0] == result.diceResults[1]) {
          expect(result.isInterrupt, isTrue);
          foundDoubles = true;
        }
      }
      expect(foundDoubles, isTrue, reason: 'Should find doubles within 1000 seeds');
    });

    test('all scene types have display text and description', () {
      for (final type in SceneType.values) {
        expect(type.displayText.isNotEmpty, isTrue);
        expect(type.description.isNotEmpty, isTrue);
      }
    });
  });

  group('RandomEvent', () {
    test('generate returns valid event', () {
      final randomEvent = RandomEvent(RollEngine(SeededRandom(42)));
      final result = randomEvent.generate();

      expect(result.focusDice.length, equals(2));
      expect(EventFocus.values, contains(result.focus));
      expect(result.action.isNotEmpty, isTrue);
      expect(result.subject.isNotEmpty, isTrue);
    });

    test('generateIdea returns valid idea', () {
      final randomEvent = RandomEvent(RollEngine(SeededRandom(42)));
      final result = randomEvent.generateIdea();

      expect(result.action.isNotEmpty, isTrue);
      expect(result.subject.isNotEmpty, isTrue);
      expect(result.idea, contains('/'));
    });

    test('actionWords and subjectWords are not empty', () {
      expect(RandomEvent.actionWords.isNotEmpty, isTrue);
      expect(RandomEvent.subjectWords.isNotEmpty, isTrue);
    });

    test('all event focuses have display text and description', () {
      for (final focus in EventFocus.values) {
        expect(focus.displayText.isNotEmpty, isTrue);
        expect(focus.description.isNotEmpty, isTrue);
      }
    });
  });

  group('Exploration', () {
    group('Weather', () {
      test('rollWeather returns valid weather', () {
        final exploration = Exploration(RollEngine(SeededRandom(42)));
        final result = exploration.rollWeather();

        expect(result.diceResults.length, equals(2));
        expect(Weather.values, contains(result.weather));
      });

      test('season modifier affects result', () {
        final exploration = Exploration(RollEngine(SeededRandom(42)));
        final springResult = exploration.rollWeather(season: 'Spring');
        
        final exploration2 = Exploration(RollEngine(SeededRandom(42)));
        final winterResult = exploration2.rollWeather(season: 'Winter');

        expect(springResult.rawTotal, equals(winterResult.rawTotal));
        expect(springResult.modifier, greaterThan(winterResult.modifier));
      });

      test('climate modifier affects result', () {
        final exploration = Exploration(RollEngine(SeededRandom(42)));
        final temperateResult = exploration.rollWeather(climate: 'Temperate');
        
        final exploration2 = Exploration(RollEngine(SeededRandom(42)));
        final arcticResult = exploration2.rollWeather(climate: 'Arctic');

        expect(temperateResult.rawTotal, equals(arcticResult.rawTotal));
        expect(temperateResult.modifier, greaterThan(arcticResult.modifier));
      });

      test('all weather types have display text and description', () {
        for (final weather in Weather.values) {
          expect(weather.displayText.isNotEmpty, isTrue);
          expect(weather.description.isNotEmpty, isTrue);
        }
      });
    });

    group('Encounters', () {
      test('checkWildernessEncounter returns valid encounter', () {
        final exploration = Exploration(RollEngine(SeededRandom(42)));
        final result = exploration.checkWildernessEncounter();

        expect(result.diceResults.length, equals(2));
        expect(EncounterType.values, contains(result.encounterType));
        expect(result.locationType, equals('Wilderness'));
      });

      test('checkDungeonEncounter returns valid encounter', () {
        final exploration = Exploration(RollEngine(SeededRandom(42)));
        final result = exploration.checkDungeonEncounter();

        expect(result.diceResults.length, equals(2));
        expect(EncounterType.values, contains(result.encounterType));
        expect(result.locationType, equals('Dungeon'));
      });

      test('threat encounters include distance and disposition', () {
        // Find a seed that produces a threat encounter
        for (int seed = 0; seed < 1000; seed++) {
          final exploration = Exploration(RollEngine(SeededRandom(seed)));
          final result = exploration.checkWildernessEncounter(dangerLevel: 4);
          
          if (result.encounterType == EncounterType.majorThreat ||
              result.encounterType == EncounterType.minorThreat) {
            expect(result.distance, isNotNull);
            expect(result.disposition, isNotNull);
            return;
          }
        }
        fail('Should find a threat encounter within 1000 seeds');
      });

      test('danger level affects encounter probability', () {
        int threatsWithHighDanger = 0;
        int threatsWithLowDanger = 0;

        for (int i = 0; i < 500; i++) {
          final highDanger = Exploration(RollEngine(SeededRandom(i)));
          final lowDanger = Exploration(RollEngine(SeededRandom(i)));

          final highResult = highDanger.checkWildernessEncounter(dangerLevel: 3);
          final lowResult = lowDanger.checkWildernessEncounter(dangerLevel: -2);

          if (highResult.encounterType == EncounterType.majorThreat ||
              highResult.encounterType == EncounterType.minorThreat) {
            threatsWithHighDanger++;
          }
          if (lowResult.encounterType == EncounterType.majorThreat ||
              lowResult.encounterType == EncounterType.minorThreat) {
            threatsWithLowDanger++;
          }
        }

        expect(threatsWithHighDanger, greaterThan(threatsWithLowDanger));
      });

      test('all encounter types have display text', () {
        for (final type in EncounterType.values) {
          expect(type.displayText.isNotEmpty, isTrue);
        }
      });

      test('all distances have display text', () {
        for (final distance in EncounterDistance.values) {
          expect(distance.displayText.isNotEmpty, isTrue);
        }
      });

      test('all dispositions have display text', () {
        for (final disposition in Disposition.values) {
          expect(disposition.displayText.isNotEmpty, isTrue);
        }
      });
    });
  });
}
