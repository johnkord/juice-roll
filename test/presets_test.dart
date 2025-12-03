import 'package:flutter_test/flutter_test.dart';
import 'package:juice_roll/presets/fate_check.dart';
import 'package:juice_roll/presets/next_scene.dart';
import 'package:juice_roll/presets/random_event.dart';
import 'package:juice_roll/presets/exploration.dart';
import 'package:juice_roll/presets/discover_meaning.dart';
import 'package:juice_roll/presets/npc_action.dart';
import 'package:juice_roll/presets/pay_the_price.dart';
import 'package:juice_roll/presets/quest.dart';
import 'package:juice_roll/presets/interrupt_plot_point.dart';
import 'package:juice_roll/presets/settlement.dart';
import 'package:juice_roll/presets/object_treasure.dart';
import 'package:juice_roll/presets/challenge.dart';
import 'package:juice_roll/presets/details.dart';
import 'package:juice_roll/presets/immersion.dart';
import 'package:juice_roll/core/roll_engine.dart';
import 'test_utils.dart';

void main() {
  group('FateCheck', () {
    test('likelihoods contains expected values', () {
      expect(FateCheck.likelihoods, contains('Even Odds'));
      expect(FateCheck.likelihoods, contains('Likely'));
      expect(FateCheck.likelihoods, contains('Unlikely'));
    });

    test('check returns valid outcome with fate dice and intensity', () {
      final fateCheck = FateCheck(RollEngine(SeededRandom(42)));
      final result = fateCheck.check();

      // Should have 2 Fate dice + 1 Intensity die
      expect(result.diceResults.length, equals(3));
      
      // Fate dice should be in range -1 to +1
      expect(result.fateDice.length, equals(2));
      for (final die in result.fateDice) {
        expect(die, inInclusiveRange(-1, 1));
      }
      
      // Fate sum should be in range -2 to +2
      expect(result.fateSum, inInclusiveRange(-2, 2));
      
      // Intensity should be 1-6
      expect(result.intensity, inInclusiveRange(1, 6));
      
      expect(FateCheckOutcome.values, contains(result.outcome));
    });

    test('intensity has descriptive text', () {
      final fateCheck = FateCheck(RollEngine(SeededRandom(42)));
      final result = fateCheck.check();

      expect(result.intensityDescription.isNotEmpty, isTrue);
    });

    test('fateSymbols returns readable representation', () {
      final fateCheck = FateCheck(RollEngine(SeededRandom(42)));
      final result = fateCheck.check();

      // Should contain valid symbols: +, −, or ○
      expect(result.fateSymbols, isNotEmpty);
      expect(result.fateSymbols, matches(RegExp(r'^[+−○]( [+−○])?$')));
    });

    test('double blanks trigger special event', () {
      // Find a seed that produces double blanks (both dice = 0)
      bool foundDoubleBlanks = false;
      for (int seed = 0; seed < 5000 && !foundDoubleBlanks; seed++) {
        final fateCheck = FateCheck(RollEngine(SeededRandom(seed)));
        final result = fateCheck.check();
        
        if (result.fateDice[0] == 0 && result.fateDice[1] == 0) {
          expect(result.hasSpecialTrigger, isTrue);
          expect(result.specialTrigger, isNotNull);
          expect(
            result.specialTrigger == SpecialTrigger.randomEvent ||
            result.specialTrigger == SpecialTrigger.invalidAssumption,
            isTrue,
          );
          foundDoubleBlanks = true;
        }
      }
      expect(foundDoubleBlanks, isTrue, 
          reason: 'Should find double blanks within 5000 seeds');
    });

    test('non-double-blanks do not trigger special events', () {
      // Find a seed that does NOT produce double blanks
      for (int seed = 0; seed < 100; seed++) {
        final fateCheck = FateCheck(RollEngine(SeededRandom(seed)));
        final result = fateCheck.check();
        
        if (result.fateDice[0] != 0 || result.fateDice[1] != 0) {
          expect(result.hasSpecialTrigger, isFalse);
          expect(result.specialTrigger, isNull);
          return;
        }
      }
      fail('Should find non-double-blanks within 100 seeds');
    });

    test('all outcomes have display text', () {
      for (final outcome in FateCheckOutcome.values) {
        expect(outcome.displayText.isNotEmpty, isTrue);
      }
    });

    test('all special triggers have display text and description', () {
      for (final trigger in SpecialTrigger.values) {
        expect(trigger.displayText.isNotEmpty, isTrue);
        expect(trigger.description.isNotEmpty, isTrue);
      }
    });

    test('isYes and isNo are mutually exclusive', () {
      for (final outcome in FateCheckOutcome.values) {
        if (outcome == FateCheckOutcome.mixed) continue;
        expect(outcome.isYes != outcome.isNo, isTrue,
            reason: '$outcome should be yes XOR no');
      }
    });
  });

  group('NextScene', () {
    test('determineScene returns valid scene type', () {
      final nextScene = NextScene(RollEngine(SeededRandom(42)));
      final result = nextScene.determineScene();

      expect(result.diceResults.length, equals(2));
      expect(SceneType.values, contains(result.sceneType));
    });

    test('fateSymbols returns readable representation', () {
      final nextScene = NextScene(RollEngine(SeededRandom(42)));
      final result = nextScene.determineScene();

      expect(result.fateSymbols, isNotEmpty);
      expect(result.fateSymbols, matches(RegExp(r'^[+−○] [+−○]$')));
    });

    test('all scene types have display text and description', () {
      for (final type in SceneType.values) {
        expect(type.displayText.isNotEmpty, isTrue);
        expect(type.description.isNotEmpty, isTrue);
      }
    });

    test('alter scenes require follow-up rolls', () {
      expect(SceneType.alterAdd.requiresFollowUp, isTrue);
      expect(SceneType.alterRemove.requiresFollowUp, isTrue);
      expect(SceneType.normal.requiresFollowUp, isFalse);
    });

    test('interrupt scenes require follow-up rolls', () {
      expect(SceneType.interruptFavorable.requiresFollowUp, isTrue);
      expect(SceneType.interruptUnfavorable.requiresFollowUp, isTrue);
    });
  });

  group('RandomEvent', () {
    test('generate returns valid event', () {
      final randomEvent = RandomEvent(RollEngine(SeededRandom(42)));
      final result = randomEvent.generate();

      expect(result.diceResults.length, equals(3)); // 1d10 event + 2d10 idea
      expect(result.focus.isNotEmpty, isTrue);
      expect(result.modifier.isNotEmpty, isTrue);
      expect(result.idea.isNotEmpty, isTrue);
    });

    test('generateIdea returns valid idea', () {
      final randomEvent = RandomEvent(RollEngine(SeededRandom(42)));
      final result = randomEvent.generateIdea();

      expect(result.modifier.isNotEmpty, isTrue);
      expect(result.idea.isNotEmpty, isTrue);
    });

    test('modifierWords list is not empty', () {
      expect(RandomEvent.modifierWords.isNotEmpty, isTrue);
      expect(RandomEvent.modifierWords.length, equals(10));
    });

    test('eventFocusTypes list has 10 entries', () {
      expect(RandomEvent.eventFocusTypes.length, equals(10));
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

  group('DiscoverMeaning', () {
    test('generate returns valid word pair', () {
      final discoverMeaning = DiscoverMeaning(RollEngine(SeededRandom(42)));
      final result = discoverMeaning.generate();

      expect(result.diceResults.length, equals(2)); // 2d20
      expect(result.adjective.isNotEmpty, isTrue);
      expect(result.noun.isNotEmpty, isTrue);
      expect(result.meaning, contains(' '));
    });

    test('adjectives and nouns lists have 20 entries each', () {
      expect(DiscoverMeaning.adjectives.length, equals(20));
      expect(DiscoverMeaning.nouns.length, equals(20));
    });
  });

  group('NpcAction', () {
    test('generateProfile returns complete profile', () {
      final npcAction = NpcAction(RollEngine(SeededRandom(42)));
      final result = npcAction.generateProfile();

      expect(result.personality.isNotEmpty, isTrue);
      expect(result.need.isNotEmpty, isTrue);
      expect(result.motive.isNotEmpty, isTrue);
    });

    test('rollPersonality returns valid result', () {
      final npcAction = NpcAction(RollEngine(SeededRandom(42)));
      final result = npcAction.rollPersonality();

      expect(result.result.isNotEmpty, isTrue);
      expect(result.column, equals(NpcColumn.personality));
    });

    test('rollAction returns valid result', () {
      final npcAction = NpcAction(RollEngine(SeededRandom(42)));
      final result = npcAction.rollAction();

      expect(result.result.isNotEmpty, isTrue);
      expect(result.column, equals(NpcColumn.action));
    });

    test('rollCombatAction returns valid result', () {
      final npcAction = NpcAction(RollEngine(SeededRandom(42)));
      final result = npcAction.rollCombatAction();

      expect(result.result.isNotEmpty, isTrue);
      expect(result.column, equals(NpcColumn.combat));
    });
  });

  group('PayThePrice', () {
    test('rollConsequence returns valid consequence', () {
      final payThePrice = PayThePrice(RollEngine(SeededRandom(42)));
      final result = payThePrice.rollConsequence();

      expect(result.result.isNotEmpty, isTrue);
      expect(result.isMajorTwist, isFalse);
    });

    test('rollMajorTwist returns major twist', () {
      final payThePrice = PayThePrice(RollEngine(SeededRandom(42)));
      final result = payThePrice.rollMajorTwist();

      expect(result.result.isNotEmpty, isTrue);
      expect(result.isMajorTwist, isTrue);
    });

    test('consequences list is not empty', () {
      expect(PayThePrice.consequences.isNotEmpty, isTrue);
    });

    test('majorTwists list is not empty', () {
      expect(PayThePrice.majorTwists.isNotEmpty, isTrue);
    });
  });

  group('Quest', () {
    test('generate returns complete quest', () {
      final quest = Quest(RollEngine(SeededRandom(42)));
      final result = quest.generate();

      expect(result.diceResults.length, equals(5)); // 5d10
      expect(result.questSentence.isNotEmpty, isTrue);
      expect(result.questSentence, contains(' '));
    });
  });

  group('InterruptPlotPoint', () {
    test('generate returns valid interrupt', () {
      final interrupt = InterruptPlotPoint(RollEngine(SeededRandom(42)));
      final result = interrupt.generate();

      expect(result.category.isNotEmpty, isTrue);
      expect(result.event.isNotEmpty, isTrue);
    });

    test('categories and events are properly structured', () {
      expect(InterruptPlotPoint.categories.length, equals(10));
    });
  });

  group('Settlement', () {
    test('generateName returns valid name', () {
      final settlement = Settlement(RollEngine(SeededRandom(42)));
      final result = settlement.generateName();

      expect(result.name.isNotEmpty, isTrue);
    });

    test('generateFull returns complete settlement', () {
      final settlement = Settlement(RollEngine(SeededRandom(42)));
      final result = settlement.generateFull();

      expect(result.name.name.isNotEmpty, isTrue);
      expect(result.establishment.result.isNotEmpty, isTrue);
      expect(result.news.result.isNotEmpty, isTrue);
    });
  });

  group('ObjectTreasure', () {
    test('generateTrinket returns valid trinket', () {
      final treasure = ObjectTreasure(RollEngine(SeededRandom(42)));
      final result = treasure.generateTrinket();

      expect(result.category, equals('Trinket'));
      expect(result.quality.isNotEmpty, isTrue);
    });

    test('generateWeapon returns valid weapon', () {
      final treasure = ObjectTreasure(RollEngine(SeededRandom(42)));
      final result = treasure.generateWeapon();

      expect(result.category, equals('Weapon'));
      expect(result.quality.isNotEmpty, isTrue);
      expect(result.material.isNotEmpty, isTrue);
    });

    test('generateArmor returns valid armor', () {
      final treasure = ObjectTreasure(RollEngine(SeededRandom(42)));
      final result = treasure.generateArmor();

      expect(result.category, equals('Armor'));
      expect(result.quality.isNotEmpty, isTrue);
      expect(result.itemType.isNotEmpty, isTrue);
    });

    test('generateRandom returns treasure from any category', () {
      final treasure = ObjectTreasure(RollEngine(SeededRandom(42)));
      final result = treasure.generateRandom();

      expect(ObjectTreasure.treasureCategories.contains(result.category), isTrue);
    });
  });

  group('Challenge', () {
    test('rollQuickDc returns valid DC', () {
      final challenge = Challenge(RollEngine(SeededRandom(42)));
      final result = challenge.rollQuickDc();

      expect(result.dc, inInclusiveRange(8, 18)); // 2d6+6
    });

    test('rollPhysicalChallenge returns valid challenge', () {
      final challenge = Challenge(RollEngine(SeededRandom(42)));
      final result = challenge.rollPhysicalChallenge();

      expect(result.skill.isNotEmpty, isTrue);
      expect(result.challengeType, equals(ChallengeType.physical));
      expect(result.suggestedDc, inInclusiveRange(8, 17));
    });

    test('rollMentalChallenge returns valid challenge', () {
      final challenge = Challenge(RollEngine(SeededRandom(42)));
      final result = challenge.rollMentalChallenge();

      expect(result.skill.isNotEmpty, isTrue);
      expect(result.challengeType, equals(ChallengeType.mental));
      expect(result.suggestedDc, inInclusiveRange(8, 17));
    });
  });

  group('Details', () {
    test('rollColor returns valid color', () {
      final details = Details(RollEngine(SeededRandom(42)));
      final result = details.rollColor();

      expect(result.result.isNotEmpty, isTrue);
      expect(result.detailType, equals(DetailType.color));
    });

    test('rollProperty returns valid property with intensity', () {
      final details = Details(RollEngine(SeededRandom(42)));
      final result = details.rollProperty();

      expect(result.property.isNotEmpty, isTrue);
      expect(result.intensityRoll, inInclusiveRange(1, 6));
    });

    test('rollHistory returns valid history context', () {
      final details = Details(RollEngine(SeededRandom(42)));
      final result = details.rollHistory();

      expect(result.result.isNotEmpty, isTrue);
      expect(result.detailType, equals(DetailType.history));
    });
  });

  group('Immersion', () {
    test('generateSensoryDetail returns valid immersion', () {
      final immersion = Immersion(RollEngine(SeededRandom(42)));
      final result = immersion.generateSensoryDetail();

      expect(result.sense.isNotEmpty, isTrue);
      expect(result.detail.isNotEmpty, isTrue);
    });

    test('generateEmotionalAtmosphere returns complete atmosphere', () {
      final immersion = Immersion(RollEngine(SeededRandom(42)));
      final result = immersion.generateEmotionalAtmosphere();

      expect(result.negativeEmotion.isNotEmpty, isTrue);
      expect(result.positiveEmotion.isNotEmpty, isTrue);
      expect(result.where.isNotEmpty, isTrue);
      expect(result.cause.isNotEmpty, isTrue);
    });

    test('generateFullImmersion returns both sensory and emotional', () {
      final immersion = Immersion(RollEngine(SeededRandom(42)));
      final result = immersion.generateFullImmersion();

      expect(result.sensory, isNotNull);
      expect(result.emotional, isNotNull);
    });
  });
}
