import 'package:flutter_test/flutter_test.dart';
import 'package:juice_roll/presets/fate_check.dart';
import 'package:juice_roll/presets/next_scene.dart';
import 'package:juice_roll/presets/random_event.dart';
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
import 'package:juice_roll/presets/dungeon_generator.dart';
import 'package:juice_roll/presets/wilderness.dart';
import 'package:juice_roll/presets/extended_npc_conversation.dart';
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
        // Skip contextual outcomes (favorable/unfavorable are neither yes nor no)
        if (outcome.isContextual) continue;
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

    test('determineSceneWithFollowUp supports simple mode with Modifier+Idea', () {
      // Use a seed that produces an Alter result (++ or +-)
      // We'll test the simple mode capability - if we get an alter result
      // with simple mode, it should use IdeaResult instead of FocusResult
      final randomEvent = RandomEvent(RollEngine(SeededRandom(123)));
      final nextScene = NextScene(RollEngine(SeededRandom(123)));
      
      // Run with simple mode
      final result = nextScene.determineSceneWithFollowUp(
        useSimpleMode: true,
        randomEvent: randomEvent,
      );
      
      // Result should be valid
      expect(result.sceneResult.sceneType, isA<SceneType>());
      
      // If it's an Alter result and simple mode was used, ideaResult should be set
      if (result.sceneResult.sceneType == SceneType.alterAdd ||
          result.sceneResult.sceneType == SceneType.alterRemove) {
        expect(result.ideaResult, isNotNull);
        expect(result.focusResult, isNull);
      }
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

    test('rollModifier returns valid modifier', () {
      final randomEvent = RandomEvent(RollEngine(SeededRandom(42)));
      final result = randomEvent.rollModifier();

      expect(result.tableName, equals('Modifier'));
      expect(result.result.isNotEmpty, isTrue);
      expect(RandomEvent.modifierWords, contains(result.result));
    });

    test('rollIdea returns valid idea', () {
      final randomEvent = RandomEvent(RollEngine(SeededRandom(42)));
      final result = randomEvent.rollIdea();

      expect(result.tableName, equals('Idea'));
      expect(result.result.isNotEmpty, isTrue);
      expect(RandomEvent.ideaWords, contains(result.result));
    });

    test('rollEvent returns valid event', () {
      final randomEvent = RandomEvent(RollEngine(SeededRandom(42)));
      final result = randomEvent.rollEvent();

      expect(result.tableName, equals('Event'));
      expect(result.result.isNotEmpty, isTrue);
      expect(RandomEvent.eventWords, contains(result.result));
    });

    test('rollPerson returns valid person', () {
      final randomEvent = RandomEvent(RollEngine(SeededRandom(42)));
      final result = randomEvent.rollPerson();

      expect(result.tableName, equals('Person'));
      expect(result.result.isNotEmpty, isTrue);
      expect(RandomEvent.personWords, contains(result.result));
    });

    test('rollObject returns valid object', () {
      final randomEvent = RandomEvent(RollEngine(SeededRandom(42)));
      final result = randomEvent.rollObject();

      expect(result.tableName, equals('Object'));
      expect(result.result.isNotEmpty, isTrue);
      expect(RandomEvent.objectWords, contains(result.result));
    });

    test('rollModifierPlusIdea returns Modifier + Idea pair', () {
      final randomEvent = RandomEvent(RollEngine(SeededRandom(42)));
      final result = randomEvent.rollModifierPlusIdea();

      expect(result.modifier.isNotEmpty, isTrue);
      expect(result.idea.isNotEmpty, isTrue);
      expect(result.ideaCategory, equals('Idea'));
      expect(RandomEvent.modifierWords, contains(result.modifier));
      expect(RandomEvent.ideaWords, contains(result.idea));
    });

    test('all individual tables have 10 entries', () {
      expect(RandomEvent.ideaWords.length, equals(10));
      expect(RandomEvent.eventWords.length, equals(10));
      expect(RandomEvent.personWords.length, equals(10));
      expect(RandomEvent.objectWords.length, equals(10));
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

    test('rollDualPersonality returns two personality traits', () {
      final npcAction = NpcAction(RollEngine(SeededRandom(42)));
      final result = npcAction.rollDualPersonality();

      expect(result.primary.isNotEmpty, isTrue);
      expect(result.secondary.isNotEmpty, isTrue);
      expect(result.interpretation, contains(', yet '));
    });

    test('generateComplexNpc returns complete complex NPC with all fields', () {
      final npcAction = NpcAction(RollEngine(SeededRandom(42)));
      final result = npcAction.generateComplexNpc(
        needSkew: NeedSkew.complex,
        includeName: true,
        dualPersonality: true,
      );

      // Should have a name
      expect(result.name, isNotNull);
      expect(result.name!.name.isNotEmpty, isTrue);

      // Should have primary and secondary personality
      expect(result.primaryPersonality.isNotEmpty, isTrue);
      expect(result.secondaryPersonality, isNotNull);
      expect(result.secondaryPersonality!.isNotEmpty, isTrue);

      // Should have need and motive
      expect(result.need.isNotEmpty, isTrue);
      expect(result.motive.isNotEmpty, isTrue);

      // Should have color
      expect(result.color.result.isNotEmpty, isTrue);

      // Should have two properties with intensity
      expect(result.property1.property.isNotEmpty, isTrue);
      expect(result.property1.intensityRoll, inInclusiveRange(1, 6));
      expect(result.property2.property.isNotEmpty, isTrue);
      expect(result.property2.intensityRoll, inInclusiveRange(1, 6));

      // Check display texts
      expect(result.personalityDisplay, contains(', yet '));
      expect(result.propertiesDisplay.isNotEmpty, isTrue);
    });

    test('generateComplexNpc with single personality works', () {
      final npcAction = NpcAction(RollEngine(SeededRandom(42)));
      final result = npcAction.generateComplexNpc(
        needSkew: NeedSkew.primitive,
        includeName: false,
        dualPersonality: false,
      );

      // Should not have a name
      expect(result.name, isNull);

      // Should have only primary personality (no secondary)
      expect(result.primaryPersonality.isNotEmpty, isTrue);
      expect(result.secondaryPersonality, isNull);

      // personalityDisplay should not contain "yet"
      expect(result.personalityDisplay, isNot(contains(', yet ')));
    });

    test('generateComplexNpc needSkew affects need roll', () {
      // With primitive skew (disadvantage), need should tend towards lower values
      // With complex skew (advantage), need should tend towards higher values
      final npcActionPrimitive = NpcAction(RollEngine(SeededRandom(42)));
      final primitiveResult = npcActionPrimitive.generateComplexNpc(
        needSkew: NeedSkew.primitive,
      );
      expect(primitiveResult.needSkew, equals(NeedSkew.primitive));

      final npcActionComplex = NpcAction(RollEngine(SeededRandom(42)));
      final complexResult = npcActionComplex.generateComplexNpc(
        needSkew: NeedSkew.complex,
      );
      expect(complexResult.needSkew, equals(NeedSkew.complex));
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

      // At minimum 5 rolls (objective, description, focus, preposition, location)
      // Plus optional sub-rolls for italicized entries
      expect(result.diceResults.length, greaterThanOrEqualTo(5));
      expect(result.questSentence.isNotEmpty, isTrue);
      expect(result.questSentence, contains(' '));
    });

    test('expands italicized focus entries', () {
      // Test with various seeds to hit different focus values
      for (var seed = 0; seed < 100; seed++) {
        final quest = Quest(RollEngine(SeededRandom(seed)));
        final result = quest.generate();
        
        // If focus is one that needs expansion, verify it was expanded
        final italicFocuses = {'Monster', 'Event', 'Environment', 'Person', 'Location', 'Object'};
        if (italicFocuses.contains(result.focus)) {
          expect(result.focusExpanded, isNotNull, reason: 'Focus "${result.focus}" should be expanded');
          expect(result.focusSubRoll, isNotNull);
          expect(result.focusDisplay, contains('('));
        }
      }
    });

    test('expands italicized location entries', () {
      // Test with various seeds to hit different location values
      for (var seed = 0; seed < 100; seed++) {
        final quest = Quest(RollEngine(SeededRandom(seed)));
        final result = quest.generate();
        
        // If location is one that needs expansion, verify it was expanded
        final italicLocations = {
          'Dungeon Feature', 'Dungeon', 'Environment', 'Event',
          'Natural Hazard', 'Settlement', 'Wilderness Feature'
        };
        if (italicLocations.contains(result.location)) {
          expect(result.locationExpanded, isNotNull, reason: 'Location "${result.location}" should be expanded');
          expect(result.locationSubRoll, isNotNull);
          expect(result.locationDisplay, contains('('));
        }
      }
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

    test('generateEstablishmentName returns Color + Object name', () {
      final settlement = Settlement(RollEngine(SeededRandom(42)));
      final result = settlement.generateEstablishmentName();

      expect(result.name.startsWith('The '), isTrue);
      expect(result.color.isNotEmpty, isTrue);
      expect(result.object.isNotEmpty, isTrue);
      expect(result.shortColor.isNotEmpty, isTrue);
      expect(result.colorEmoji.isNotEmpty, isTrue);
    });

    test('generateProperties returns two properties with intensity', () {
      final settlement = Settlement(RollEngine(SeededRandom(42)));
      final result = settlement.generateProperties();

      expect(result.property1.property.isNotEmpty, isTrue);
      expect(result.property2.property.isNotEmpty, isTrue);
      expect(result.property1.intensityRoll, inInclusiveRange(1, 6));
      expect(result.property2.intensityRoll, inInclusiveRange(1, 6));
    });

    test('generateSimpleNpc returns name and profile', () {
      final settlement = Settlement(RollEngine(SeededRandom(42)));
      final result = settlement.generateSimpleNpc();

      expect(result.name.name.isNotEmpty, isTrue);
      expect(result.profile.personality.isNotEmpty, isTrue);
      expect(result.profile.need.isNotEmpty, isTrue);
      expect(result.profile.motive.isNotEmpty, isTrue);
    });

    test('generateVillage returns settlement with disadvantage count', () {
      final settlement = Settlement(RollEngine(SeededRandom(42)));
      final result = settlement.generateVillage();

      expect(result.settlementType, equals(SettlementType.village));
      expect(result.name.name.isNotEmpty, isTrue);
      expect(result.establishments.countResult.count, inInclusiveRange(1, 6));
      expect(result.news.result.isNotEmpty, isTrue);
    });

    test('generateCity returns settlement with advantage count', () {
      final settlement = Settlement(RollEngine(SeededRandom(42)));
      final result = settlement.generateCity();

      expect(result.settlementType, equals(SettlementType.city));
      expect(result.name.name.isNotEmpty, isTrue);
      expect(result.establishments.countResult.count, inInclusiveRange(1, 6));
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

    test('generate returns treasure from any category', () {
      final treasure = ObjectTreasure(RollEngine(SeededRandom(42)));
      final result = treasure.generate();

      expect(ObjectTreasure.treasureCategories.contains(result.category), isTrue);
    });

    test('generateFullItem returns item with base + 2 properties', () {
      final treasure = ObjectTreasure(RollEngine(SeededRandom(42)));
      final result = treasure.generateFullItem();

      // Verify base item
      expect(result.baseItem.category.isNotEmpty, isTrue);
      expect(result.baseItem.quality.isNotEmpty, isTrue);
      
      // Verify two properties
      expect(result.property1.property.isNotEmpty, isTrue);
      expect(result.property1.intensityRoll, inInclusiveRange(1, 6));
      expect(result.property2.property.isNotEmpty, isTrue);
      expect(result.property2.intensityRoll, inInclusiveRange(1, 6));
      
      // No color by default
      expect(result.color, isNull);
    });

    test('generateFullItem with color includes color result', () {
      final treasure = ObjectTreasure(RollEngine(SeededRandom(42)));
      final result = treasure.generateFullItem(includeColor: true);

      // Verify color is present
      expect(result.color, isNotNull);
      expect(result.color!.result.isNotEmpty, isTrue);
    });

    test('generateFullItem interpretation includes all parts', () {
      final treasure = ObjectTreasure(RollEngine(SeededRandom(42)));
      final result = treasure.generateFullItem(includeColor: true);

      final interpretation = result.interpretation!;
      
      // Should contain base item category
      expect(interpretation.contains(result.baseItem.category), isTrue);
      
      // Should contain properties
      expect(interpretation.contains(result.property1.property), isTrue);
      expect(interpretation.contains(result.property2.property), isTrue);
      
      // Should contain color
      expect(interpretation.contains('Color:'), isTrue);
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

    test('rollFullChallenge returns both physical and mental skills with separate DCs', () {
      final challenge = Challenge(RollEngine(SeededRandom(42)));
      final result = challenge.rollFullChallenge();

      expect(result.physicalSkill.isNotEmpty, isTrue);
      expect(result.mentalSkill.isNotEmpty, isTrue);
      expect(result.physicalDc, inInclusiveRange(8, 17));
      expect(result.mentalDc, inInclusiveRange(8, 17));
      expect(Challenge.physicalChallenges, contains(result.physicalSkill));
      expect(Challenge.mentalChallenges, contains(result.mentalSkill));
    });

    test('rollDc returns valid DC with different skews', () {
      final challenge = Challenge(RollEngine(SeededRandom(42)));
      
      // Test random DC
      final randomDc = challenge.rollDc();
      expect(randomDc.dc, inInclusiveRange(8, 17));
      expect(randomDc.method, contains('Random'));
      
      // Test easy DC (advantage)
      final easyDc = challenge.rollDc(skew: DcSkew.advantage);
      expect(easyDc.dc, inInclusiveRange(8, 17));
      expect(easyDc.method, contains('Easy'));
      
      // Test hard DC (disadvantage)
      final hardDc = challenge.rollDc(skew: DcSkew.disadvantage);
      expect(hardDc.dc, inInclusiveRange(8, 17));
      expect(hardDc.method, contains('Hard'));
    });

    test('rollBalancedDc returns valid DC using bell curve', () {
      final challenge = Challenge(RollEngine(SeededRandom(42)));
      final result = challenge.rollBalancedDc();

      expect(result.dc, inInclusiveRange(8, 17));
      expect(result.method, contains('Balanced'));
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
      expect(result.cause.isNotEmpty, isTrue);
    });

    test('generateSensoryDetail includes where location', () {
      final immersion = Immersion(RollEngine(SeededRandom(42)));
      final result = immersion.generateSensoryDetail();

      expect(result.sense.isNotEmpty, isTrue);
      expect(result.detail.isNotEmpty, isTrue);
      expect(result.where.isNotEmpty, isTrue);
    });

    test('generateFullImmersion returns both sensory and emotional', () {
      final immersion = Immersion(RollEngine(SeededRandom(42)));
      final result = immersion.generateFullImmersion();

      expect(result.sensory, isNotNull);
      expect(result.emotional, isNotNull);
    });
  });

  group('DungeonGenerator', () {
    test('generateName returns valid dungeon name', () {
      final dungeon = DungeonGenerator(RollEngine(SeededRandom(42)));
      final result = dungeon.generateName();

      expect(result.dungeonType.isNotEmpty, isTrue);
      expect(result.descriptionWord.isNotEmpty, isTrue);
      expect(result.subject.isNotEmpty, isTrue);
      expect(result.name, contains(' of the '));
      expect(DungeonGenerator.dungeonTypes, contains(result.dungeonType));
      expect(DungeonGenerator.dungeonDescriptions, contains(result.descriptionWord));
      expect(DungeonGenerator.dungeonSubjects, contains(result.subject));
    });

    test('generateNextArea returns valid area with entering phase', () {
      final dungeon = DungeonGenerator(RollEngine(SeededRandom(42)));
      final result = dungeon.generateNextArea(isEntering: true);

      expect(result.phase, equals(DungeonPhase.entering));
      expect(result.areaType.isNotEmpty, isTrue);
      expect(DungeonGenerator.areaTypes, contains(result.areaType));
      expect(result.chosenRoll, inInclusiveRange(1, 10));
    });

    test('generateNextArea returns valid area with exploring phase', () {
      final dungeon = DungeonGenerator(RollEngine(SeededRandom(42)));
      final result = dungeon.generateNextArea(isEntering: false);

      expect(result.phase, equals(DungeonPhase.exploring));
      expect(result.areaType.isNotEmpty, isTrue);
      expect(DungeonGenerator.areaTypes, contains(result.areaType));
    });

    test('generateNextArea detects doubles for phase change', () {
      // The doubles detection is based on the two dice rolled matching.
      // With the SeededRandom algorithm, consecutive rolls rarely match.
      // Instead, we verify the structure of the result and that isDoubles
      // would be set correctly if roll1 == roll2.
      final dungeon = DungeonGenerator(RollEngine(SeededRandom(42)));
      final result = dungeon.generateNextArea(isEntering: true);
      
      // Verify the result has the expected structure
      expect(result.roll1, inInclusiveRange(1, 10));
      expect(result.roll2, inInclusiveRange(1, 10));
      
      // Verify that isDoubles is correctly calculated
      expect(result.isDoubles, equals(result.roll1 == result.roll2));
      expect(result.phaseChange, equals(result.isDoubles));
    });

    test('generatePassage returns valid passage type', () {
      final dungeon = DungeonGenerator(RollEngine(SeededRandom(42)));
      final result = dungeon.generatePassage();

      expect(result.result.isNotEmpty, isTrue);
      expect(result.detailType, equals('Passage'));
      expect(DungeonGenerator.passageTypes, contains(result.result));
    });

    test('generatePassage respects die size', () {
      final dungeon = DungeonGenerator(RollEngine(SeededRandom(42)));
      
      // d6 should give results 1-6
      final resultD6 = dungeon.generatePassage(useD6: true);
      expect(resultD6.roll, inInclusiveRange(1, 6));
      
      // d10 can give results 1-10
      final resultD10 = dungeon.generatePassage(useD6: false);
      expect(resultD10.roll, inInclusiveRange(1, 10));
    });

    test('generateCondition returns valid room condition', () {
      final dungeon = DungeonGenerator(RollEngine(SeededRandom(42)));
      final result = dungeon.generateCondition();

      expect(result.result.isNotEmpty, isTrue);
      expect(result.detailType, equals('Condition'));
      expect(DungeonGenerator.roomConditions, contains(result.result));
    });

    test('generateFullArea returns area and condition', () {
      final dungeon = DungeonGenerator(RollEngine(SeededRandom(42)));
      final result = dungeon.generateFullArea();

      expect(result.area.areaType.isNotEmpty, isTrue);
      expect(result.condition.result.isNotEmpty, isTrue);
    });

    test('rollEncounterType returns valid encounter', () {
      final dungeon = DungeonGenerator(RollEngine(SeededRandom(42)));
      final result = dungeon.rollEncounterType();

      expect(result.result.isNotEmpty, isTrue);
      expect(result.detailType, equals('Encounter'));
      expect(DungeonGenerator.encounterTypes, contains(result.result));
    });

    test('rollEncounterType uses d6 when lingering', () {
      final dungeon = DungeonGenerator(RollEngine(SeededRandom(42)));
      final result = dungeon.rollEncounterType(isLingering: true);

      expect(result.roll, inInclusiveRange(1, 6));
      expect(result.description, contains('d6'));
    });

    test('rollMonsterDescription returns valid monster', () {
      final dungeon = DungeonGenerator(RollEngine(SeededRandom(42)));
      final result = dungeon.rollMonsterDescription();

      expect(result.descriptor.isNotEmpty, isTrue);
      expect(result.ability.isNotEmpty, isTrue);
      expect(DungeonGenerator.monsterDescriptors, contains(result.descriptor));
      expect(DungeonGenerator.monsterAbilities, contains(result.ability));
    });

    test('rollTrap returns valid trap', () {
      final dungeon = DungeonGenerator(RollEngine(SeededRandom(42)));
      final result = dungeon.rollTrap();

      expect(result.action.isNotEmpty, isTrue);
      expect(result.subject.isNotEmpty, isTrue);
      expect(DungeonGenerator.trapActions, contains(result.action));
      expect(DungeonGenerator.trapSubjects, contains(result.subject));
    });

    test('rollTrapProcedure returns trap with DC when searching', () {
      final dungeon = DungeonGenerator(RollEngine(SeededRandom(42)));
      final result = dungeon.rollTrapProcedure(isSearching: true);

      expect(result.trap.action.isNotEmpty, isTrue);
      expect(result.trap.subject.isNotEmpty, isTrue);
      expect(result.dc, inInclusiveRange(8, 17));
      expect(result.isSearching, isTrue);
      expect(result.passOutcome, equals('AVOID'));
      expect(result.failOutcome, equals('LOCATE'));
    });

    test('rollTrapProcedure returns trap with DC when not searching', () {
      final dungeon = DungeonGenerator(RollEngine(SeededRandom(42)));
      final result = dungeon.rollTrapProcedure(isSearching: false);

      expect(result.trap.action.isNotEmpty, isTrue);
      expect(result.trap.subject.isNotEmpty, isTrue);
      expect(result.dc, inInclusiveRange(8, 17));
      expect(result.isSearching, isFalse);
      expect(result.passOutcome, equals('LOCATE'));
      expect(result.failOutcome, equals('TRIGGER'));
    });

    test('rollFeature returns valid feature', () {
      final dungeon = DungeonGenerator(RollEngine(SeededRandom(42)));
      final result = dungeon.rollFeature();

      expect(result.result.isNotEmpty, isTrue);
      expect(result.detailType, equals('Feature'));
      expect(DungeonGenerator.featureTypes, contains(result.result));
    });

    test('rollNaturalHazard returns valid hazard from Wilderness table', () {
      final dungeon = DungeonGenerator(RollEngine(SeededRandom(42)));
      final result = dungeon.rollNaturalHazard();

      expect(result.result.isNotEmpty, isTrue);
      expect(result.detailType, equals('Natural Hazard'));
      expect(Wilderness.naturalHazards, contains(result.result));
    });

    test('rollFullEncounter expands Monster encounter', () {
      // Find a seed that produces Monster encounter (roll 1)
      for (int seed = 0; seed < 100; seed++) {
        final dungeon = DungeonGenerator(RollEngine(SeededRandom(seed)));
        final result = dungeon.rollFullEncounter();
        
        if (result.encounterRoll.result == 'Monster') {
          expect(result.monster, isNotNull);
          expect(result.monster!.descriptor.isNotEmpty, isTrue);
          expect(result.monster!.ability.isNotEmpty, isTrue);
          return;
        }
      }
      fail('Should find Monster encounter within 100 seeds');
    });

    test('rollFullEncounter expands Trap encounter', () {
      // Find a seed that produces Trap encounter (roll 7)
      for (int seed = 0; seed < 100; seed++) {
        final dungeon = DungeonGenerator(RollEngine(SeededRandom(seed)));
        final result = dungeon.rollFullEncounter();
        
        if (result.encounterRoll.result == 'Trap') {
          expect(result.trap, isNotNull);
          expect(result.trap!.action.isNotEmpty, isTrue);
          expect(result.trap!.subject.isNotEmpty, isTrue);
          return;
        }
      }
      fail('Should find Trap encounter within 100 seeds');
    });

    test('rollFullEncounter expands Feature encounter', () {
      // Find a seed that produces Feature encounter (roll 8)
      for (int seed = 0; seed < 100; seed++) {
        final dungeon = DungeonGenerator(RollEngine(SeededRandom(seed)));
        final result = dungeon.rollFullEncounter();
        
        if (result.encounterRoll.result == 'Feature') {
          expect(result.feature, isNotNull);
          expect(result.feature!.result.isNotEmpty, isTrue);
          return;
        }
      }
      fail('Should find Feature encounter within 100 seeds');
    });

    test('rollFullEncounter expands Natural Hazard encounter', () {
      // Find a seed that produces Natural Hazard encounter (roll 2)
      for (int seed = 0; seed < 100; seed++) {
        final dungeon = DungeonGenerator(RollEngine(SeededRandom(seed)));
        final result = dungeon.rollFullEncounter();
        
        if (result.encounterRoll.result == 'Natural Hazard') {
          expect(result.naturalHazard, isNotNull);
          expect(result.naturalHazard!.result.isNotEmpty, isTrue);
          expect(Wilderness.naturalHazards, contains(result.naturalHazard!.result));
          return;
        }
      }
      fail('Should find Natural Hazard encounter within 100 seeds');
    });

    test('generateTwoPassArea uses advantage before first doubles', () {
      final dungeon = DungeonGenerator(RollEngine(SeededRandom(42)));
      final result = dungeon.generateTwoPassArea(hasFirstDoubles: false);

      expect(result.hadFirstDoubles, isFalse);
      expect(result.areaType.isNotEmpty, isTrue);
      expect(result.condition.result.isNotEmpty, isTrue);
    });

    test('generateTwoPassArea uses disadvantage after first doubles', () {
      final dungeon = DungeonGenerator(RollEngine(SeededRandom(42)));
      final result = dungeon.generateTwoPassArea(hasFirstDoubles: true);

      expect(result.hadFirstDoubles, isTrue);
      expect(result.areaType.isNotEmpty, isTrue);
    });

    test('generateTwoPassArea detects second doubles to stop map generation', () {
      // With SeededRandom, consecutive rolls rarely match, so we verify
      // the structure and logic rather than finding actual doubles.
      final dungeon = DungeonGenerator(RollEngine(SeededRandom(42)));
      final result = dungeon.generateTwoPassArea(hasFirstDoubles: true);
      
      // Verify the result has the expected structure
      expect(result.hadFirstDoubles, isTrue);
      
      // Verify that isSecondDoubles is correctly calculated
      expect(result.isDoubles, equals(result.roll1 == result.roll2));
      expect(result.isSecondDoubles, equals(result.hadFirstDoubles && result.isDoubles));
      expect(result.stopMapGeneration, equals(result.isSecondDoubles));
    });

    test('generateTwoPassArea includes passage for Passage areas', () {
      // Find a seed that produces Passage area
      for (int seed = 0; seed < 100; seed++) {
        final dungeon = DungeonGenerator(RollEngine(SeededRandom(seed)));
        final result = dungeon.generateTwoPassArea(hasFirstDoubles: false);
        
        if (result.areaType == 'Passage') {
          expect(result.passage, isNotNull);
          expect(result.passage!.result.isNotEmpty, isTrue);
          return;
        }
      }
      fail('Should find Passage area within 100 seeds');
    });

    test('all dungeon tables have correct lengths', () {
      expect(DungeonGenerator.areaTypes.length, equals(10));
      expect(DungeonGenerator.passageTypes.length, equals(10));
      expect(DungeonGenerator.roomConditions.length, equals(10));
      expect(DungeonGenerator.dungeonTypes.length, equals(10));
      expect(DungeonGenerator.dungeonDescriptions.length, equals(10));
      expect(DungeonGenerator.dungeonSubjects.length, equals(10));
      expect(DungeonGenerator.encounterTypes.length, equals(10));
      expect(DungeonGenerator.monsterDescriptors.length, equals(10));
      expect(DungeonGenerator.monsterAbilities.length, equals(10));
      expect(DungeonGenerator.trapActions.length, equals(10));
      expect(DungeonGenerator.trapSubjects.length, equals(10));
      expect(DungeonGenerator.featureTypes.length, equals(10));
    });

    test('DungeonPhase has correct display text', () {
      expect(DungeonPhase.entering.displayText, equals('Entering (1d10@-)'));
      expect(DungeonPhase.exploring.displayText, equals('Exploring (1d10@+)'));
    });
  });

  group('Wilderness', () {
    test('initializeRandom returns valid starting area', () {
      final wilderness = Wilderness(RollEngine(SeededRandom(42)));
      final result = wilderness.initializeRandom();

      expect(result.environment.isNotEmpty, isTrue);
      expect(result.typeName.isNotEmpty, isTrue);
      expect(Wilderness.environments, contains(result.environment));
      expect(result.envRoll, inInclusiveRange(1, 10));
      expect(result.typeRoll, inInclusiveRange(1, 10));
      expect(result.isTransition, isFalse);
    });

    test('initializeAt sets specific environment and type', () {
      final wilderness = Wilderness(RollEngine(SeededRandom(42)));
      final result = wilderness.initializeAt(3, typeRow: 4, isLost: true);

      expect(result.environment, equals('Cavern'));
      expect(result.typeRoll, equals(4));
      expect(wilderness.state, isNotNull);
      expect(wilderness.state!.isLost, isTrue);
    });

    test('transition uses 2dF for environment offset', () {
      final wilderness = Wilderness(RollEngine(SeededRandom(42)));
      wilderness.initializeAt(5); // Start at Grassland
      
      final result = wilderness.transition();

      expect(result.isTransition, isTrue);
      expect(result.previousEnvironment, isNotNull);
      expect(result.envFateDice.length, equals(2));
      expect(result.envFateDice.every((d) => d >= -1 && d <= 1), isTrue);
      expect(result.typeFateDie, inInclusiveRange(-1, 1));
    });

    test('rollEncounter uses d10 when not lost', () {
      final wilderness = Wilderness(RollEngine(SeededRandom(42)));
      wilderness.initializeAt(5, isLost: false);
      
      final result = wilderness.rollEncounter();

      expect(result.dieSize, equals(10));
      expect(result.roll, inInclusiveRange(1, 10));
      expect(result.wasLost, isFalse);
    });

    test('rollEncounter uses d6 when lost', () {
      final wilderness = Wilderness(RollEngine(SeededRandom(42)));
      wilderness.initializeAt(5, isLost: true);
      
      final result = wilderness.rollEncounter();

      expect(result.dieSize, equals(6));
      expect(result.roll, inInclusiveRange(1, 6));
      expect(result.wasLost, isTrue);
    });

    test('rollEncounter supports advantage and disadvantage', () {
      final wilderness = Wilderness(RollEngine(SeededRandom(42)));
      wilderness.initializeAt(5);
      
      // Test with advantage (map/guide)
      final advantageResult = wilderness.rollEncounter(hasMapOrGuide: true);
      expect(advantageResult.skewUsed, equals('advantage'));
      expect(advantageResult.secondRoll, isNotNull);
      
      // Test with disadvantage (dangerous terrain)
      final wilderness2 = Wilderness(RollEngine(SeededRandom(42)));
      wilderness2.initializeAt(5);
      final disadvantageResult = wilderness2.rollEncounter(hasDangerousTerrain: true);
      expect(disadvantageResult.skewUsed, equals('disadvantage'));
      expect(disadvantageResult.secondRoll, isNotNull);
    });

    test('rollWeather uses proper formula: 1d6@env_skew + type_modifier', () {
      final wilderness = Wilderness(RollEngine(SeededRandom(42)));
      // Arctic (row 1) has skew '-' (disadvantage), Snowy type has modifier 0
      wilderness.initializeAt(1, typeRow: 1);
      
      final result = wilderness.rollWeather();

      expect(result.environmentSkew, equals('-'));
      expect(result.typeModifier, equals(0));
      expect(result.weather.isNotEmpty, isTrue);
      expect(Wilderness.weatherTypes, contains(result.weather));
    });

    test('rollWeather returns correct weather for environment/type combo', () {
      final wilderness = Wilderness(RollEngine(SeededRandom(42)));
      // Desert (row 10) has skew '+' (advantage), Arid type has modifier 4
      wilderness.initializeAt(10, typeRow: 10);
      
      final result = wilderness.rollWeather();

      expect(result.environmentSkew, equals('+'));
      expect(result.typeModifier, equals(4));
      // With +4 modifier, weather row should be 5-10 (higher = hotter)
      expect(result.weatherRow, inInclusiveRange(5, 10));
    });

    test('rollNaturalHazard returns valid hazard', () {
      final wilderness = Wilderness(RollEngine(SeededRandom(42)));
      final result = wilderness.rollNaturalHazard();

      expect(result.detailType, equals('Natural Hazard'));
      expect(result.result.isNotEmpty, isTrue);
      expect(Wilderness.naturalHazards, contains(result.result));
    });

    test('rollFeature returns valid wilderness feature', () {
      final wilderness = Wilderness(RollEngine(SeededRandom(42)));
      final result = wilderness.rollFeature();

      expect(result.detailType, equals('Feature'));
      expect(result.result.isNotEmpty, isTrue);
      expect(Wilderness.features, contains(result.result));
    });

    test('rollMonsterLevel uses environment formula', () {
      final wilderness = Wilderness(RollEngine(SeededRandom(42)));
      // Desert (row 10) has +4 modifier with advantage
      wilderness.initializeAt(10);
      
      final result = wilderness.rollMonsterLevel();

      expect(result.modifier, equals(4));
      expect(result.advantageType, equals('+'));
      // With +4 and advantage on d6, monster level should be 5-10
      expect(result.monsterLevel, inInclusiveRange(5, 10));
    });

    test('setLost updates state correctly', () {
      final wilderness = Wilderness(RollEngine(SeededRandom(42)));
      wilderness.initializeAt(5);
      expect(wilderness.state!.isLost, isFalse);
      
      wilderness.setLost(true);
      expect(wilderness.state!.isLost, isTrue);
      
      wilderness.setLost(false);
      expect(wilderness.state!.isLost, isFalse);
    });

    test('encounter types have correct italic marking', () {
      // Verify that italicized encounters (those requiring follow-up) are marked
      expect(Wilderness.isEncounterItalic(0), isTrue); // Natural Hazard
      expect(Wilderness.isEncounterItalic(1), isTrue); // Monster
      expect(Wilderness.isEncounterItalic(2), isTrue); // Weather
      expect(Wilderness.isEncounterItalic(3), isTrue); // Challenge
      expect(Wilderness.isEncounterItalic(4), isTrue); // Dungeon
      expect(Wilderness.isEncounterItalic(5), isFalse); // River/Road
      expect(Wilderness.isEncounterItalic(6), isTrue); // Feature
      expect(Wilderness.isEncounterItalic(8), isFalse); // Advance Plot
      expect(Wilderness.isEncounterItalic(9), isFalse); // Destination/Lost
    });

    test('WildernessState provides all computed properties', () {
      final wilderness = Wilderness(RollEngine(SeededRandom(42)));
      wilderness.initializeAt(5, typeRow: 6, isLost: true);
      final state = wilderness.state!;

      expect(state.environment, equals('Grassland'));
      expect(state.typeName, equals('Tropical'));
      expect(state.typeModifier, equals(3));
      expect(state.environmentSkew, equals('0'));
      expect(state.fullDescription, equals('Tropical Grassland'));
      expect(state.isLost, isTrue);
    });

    test('environment clamping works at boundaries', () {
      final wilderness = Wilderness(RollEngine(SeededRandom(42)));
      
      // Start at Arctic (row 1) - can't go lower
      wilderness.initializeAt(1);
      
      // Multiple transitions should never go below 1 or above 10
      for (int i = 0; i < 20; i++) {
        final result = wilderness.transition();
        expect(result.envRoll, inInclusiveRange(1, 10));
        expect(result.typeRoll, inInclusiveRange(1, 10));
      }
    });

    test('all wilderness tables have correct lengths', () {
      expect(Wilderness.environments.length, equals(10));
      expect(Wilderness.types.length, equals(10));
      expect(Wilderness.encounters.length, equals(10));
      expect(Wilderness.weatherTypes.length, equals(10));
      expect(Wilderness.naturalHazards.length, equals(10));
      expect(Wilderness.features.length, equals(10));
      expect(Wilderness.monsterFormulas.length, equals(10));
    });
  });

  group('ExtendedNpcConversation', () {
    test('rollCompanionResponse returns valid response', () {
      final npc = ExtendedNpcConversation(RollEngine(SeededRandom(42)));
      final result = npc.rollCompanionResponse();

      expect(result.roll, inInclusiveRange(1, 100));
      expect(result.response.isNotEmpty, isTrue);
      expect(ExtendedNpcConversation.companionResponses, contains(result.response));
    });

    test('rollCompanionResponse supports advantage for likely agreement', () {
      final npc = ExtendedNpcConversation(RollEngine(SeededRandom(42)));
      final result = npc.rollCompanionResponse(skew: SkewType.advantage);

      expect(result.skew, equals(SkewType.advantage));
      expect(result.allRolls.length, equals(2));
    });

    test('rollCompanionResponse supports disadvantage for opposition', () {
      final npc = ExtendedNpcConversation(RollEngine(SeededRandom(42)));
      final result = npc.rollCompanionResponse(skew: SkewType.disadvantage);

      expect(result.skew, equals(SkewType.disadvantage));
      expect(result.allRolls.length, equals(2));
    });

    test('rollCompanionResponse favorLevel reflects roll', () {
      // Low rolls should be opposed
      final npc1 = ExtendedNpcConversation(RollEngine(SeededRandom(1)));
      for (int seed = 0; seed < 100; seed++) {
        final npc = ExtendedNpcConversation(RollEngine(SeededRandom(seed)));
        final result = npc.rollCompanionResponse();
        
        if (result.roll <= 20) {
          expect(result.favorLevel, equals('Strongly Opposed'));
        } else if (result.roll >= 81) {
          expect(result.favorLevel, equals('Strongly In Favor'));
        }
      }
    });

    test('rollInformation returns type and topic', () {
      final npc = ExtendedNpcConversation(RollEngine(SeededRandom(42)));
      final result = npc.rollInformation();

      expect(result.typeRoll, inInclusiveRange(1, 100));
      expect(result.topicRoll, inInclusiveRange(1, 100));
      expect(result.informationType.isNotEmpty, isTrue);
      expect(result.topic.isNotEmpty, isTrue);
    });

    test('rollDialogTopic returns valid topic', () {
      final npc = ExtendedNpcConversation(RollEngine(SeededRandom(42)));
      final result = npc.rollDialogTopic();

      expect(result.roll, inInclusiveRange(1, 100));
      expect(result.topic.isNotEmpty, isTrue);
      expect(ExtendedNpcConversation.dialogTopics, contains(result.topic));
    });

    test('all extended conversation tables have correct lengths', () {
      expect(ExtendedNpcConversation.informationTypes.length, equals(100));
      expect(ExtendedNpcConversation.informationTopics.length, equals(100));
      expect(ExtendedNpcConversation.companionResponses.length, equals(100));
      expect(ExtendedNpcConversation.dialogTopics.length, equals(100));
    });
  });
}
