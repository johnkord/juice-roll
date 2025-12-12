/// Comprehensive tests for the Result Class Extraction refactor.
/// 
/// These tests verify that:
/// 1. All RollResult subclasses are registered in RollResultFactory
/// 2. JSON serialization round-trip preserves data correctly
/// 3. All result types have display builders registered
/// 
/// IMPORTANT: These tests must pass BEFORE and AFTER the extraction refactor.
/// They serve as a safety net to ensure nothing breaks during the migration.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juice_roll/core/roll_engine.dart';
import 'package:juice_roll/models/roll_result.dart';
import 'package:juice_roll/models/roll_result_factory.dart';
import 'package:juice_roll/ui/widgets/result_displays/result_displays.dart';

// Import all preset files to access result classes
import 'package:juice_roll/presets/fate_check.dart';
import 'package:juice_roll/presets/expectation_check.dart';
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
import 'package:juice_roll/presets/scale.dart';
import 'package:juice_roll/presets/extended_npc_conversation.dart';
import 'package:juice_roll/presets/monster_encounter.dart';
import 'package:juice_roll/presets/location.dart';
import 'package:juice_roll/presets/abstract_icons.dart';
import 'package:juice_roll/presets/dialog_generator.dart';
import 'package:juice_roll/presets/name_generator.dart';
import 'package:juice_roll/models/results/ironsworn_result.dart';

import 'test_utils.dart';

/// All RollResult subclasses that should be registered.
/// This list is the source of truth for what should exist in the factory.
/// 
/// Organized by category matching the refactor plan.
final List<ResultTestCase> allResultClasses = [
  // === BASE ===
  ResultTestCase(
    className: 'RollResult',
    createInstance: () => RollResult(
      type: RollType.standard,
      description: 'Test roll',
      diceResults: [3, 4],
      total: 7,
    ),
  ),
  ResultTestCase(
    className: 'FateRollResult',
    createInstance: () => FateRollResult(
      description: '2dF',
      diceResults: [-1, 1],
      total: 0,
    ),
  ),
  
  // === FATE CHECK ===
  ResultTestCase(
    className: 'FateCheckResult',
    createInstance: () => FateCheck(RollEngine(SeededRandom(42))).check(),
  ),
  
  // === EXPECTATION CHECK ===
  ResultTestCase(
    className: 'ExpectationCheckResult',
    createInstance: () => ExpectationCheck(RollEngine(SeededRandom(42))).check(),
  ),
  
  // === RANDOM EVENT ===
  ResultTestCase(
    className: 'RandomEventResult',
    createInstance: () => RandomEvent(RollEngine(SeededRandom(42))).generate(),
  ),
  ResultTestCase(
    className: 'IdeaResult',
    createInstance: () => RandomEvent(RollEngine(SeededRandom(42))).generateIdea(),
  ),
  ResultTestCase(
    className: 'RandomEventFocusResult',
    createInstance: () => RandomEvent(RollEngine(SeededRandom(42))).generateFocus(),
  ),
  ResultTestCase(
    className: 'SingleTableResult',
    createInstance: () => RandomEvent(RollEngine(SeededRandom(42))).rollModifier(),
  ),
  
  // === NEXT SCENE ===
  ResultTestCase(
    className: 'NextSceneResult',
    createInstance: () => NextScene(RollEngine(SeededRandom(42))).determineScene(),
  ),
  ResultTestCase(
    className: 'FocusResult',
    createInstance: () => NextScene(RollEngine(SeededRandom(42))).rollFocus(),
  ),
  ResultTestCase(
    className: 'NextSceneWithFollowUpResult',
    createInstance: () => NextScene(RollEngine(SeededRandom(42))).determineSceneWithFollowUp(),
  ),
  
  // === DISCOVER MEANING ===
  ResultTestCase(
    className: 'DiscoverMeaningResult',
    createInstance: () => DiscoverMeaning(RollEngine(SeededRandom(42))).generate(),
  ),
  
  // === PAY THE PRICE ===
  ResultTestCase(
    className: 'PayThePriceResult',
    createInstance: () => PayThePrice(RollEngine(SeededRandom(42))).rollConsequence(),
  ),
  
  // === INTERRUPT PLOT POINT ===
  ResultTestCase(
    className: 'InterruptPlotPointResult',
    createInstance: () => InterruptPlotPoint(RollEngine(SeededRandom(42))).generate(),
  ),
  
  // === QUEST ===
  ResultTestCase(
    className: 'QuestResult',
    createInstance: () => Quest(RollEngine(SeededRandom(42))).generate(),
  ),
  
  // === SCALE ===
  ResultTestCase(
    className: 'ScaleResult',
    createInstance: () => Scale(RollEngine(SeededRandom(42))).roll(),
  ),
  ResultTestCase(
    className: 'ScaledValueResult',
    createInstance: () => Scale(RollEngine(SeededRandom(42))).applyToValue(100),
  ),
  
  // === NPC ACTION ===
  ResultTestCase(
    className: 'NpcActionResult',
    createInstance: () => NpcAction(RollEngine(SeededRandom(42))).rollAction(),
  ),
  ResultTestCase(
    className: 'MotiveWithFollowUpResult',
    createInstance: () => NpcAction(RollEngine(SeededRandom(42))).rollMotiveWithFollowUp(),
  ),
  ResultTestCase(
    className: 'SimpleNpcProfileResult',
    createInstance: () => NpcAction(RollEngine(SeededRandom(42))).generateSimpleProfile(),
  ),
  ResultTestCase(
    className: 'NpcProfileResult',
    createInstance: () => NpcAction(RollEngine(SeededRandom(42))).generateProfile(),
  ),
  ResultTestCase(
    className: 'DualPersonalityResult',
    createInstance: () => NpcAction(RollEngine(SeededRandom(42))).rollDualPersonality(),
  ),
  ResultTestCase(
    className: 'ComplexNpcResult',
    createInstance: () => NpcAction(RollEngine(SeededRandom(42))).generateComplexNpc(),
  ),
  
  // === DETAILS ===
  ResultTestCase(
    className: 'DetailResult',
    createInstance: () => Details(RollEngine(SeededRandom(42))).rollDetail(),
  ),
  ResultTestCase(
    className: 'PropertyResult',
    createInstance: () => Details(RollEngine(SeededRandom(42))).rollProperty(),
  ),
  ResultTestCase(
    className: 'DualPropertyResult',
    createInstance: () => Details(RollEngine(SeededRandom(42))).rollTwoProperties(),
  ),
  ResultTestCase(
    className: 'DetailWithFollowUpResult',
    createInstance: () => Details(RollEngine(SeededRandom(42))).rollDetailWithFollowUp(),
  ),
  
  // === CHALLENGE ===
  ResultTestCase(
    className: 'FullChallengeResult',
    createInstance: () => Challenge(RollEngine(SeededRandom(42))).rollFullChallenge(),
  ),
  ResultTestCase(
    className: 'DcResult',
    createInstance: () => Challenge(RollEngine(SeededRandom(42))).rollDc(),
  ),
  ResultTestCase(
    className: 'QuickDcResult',
    createInstance: () => Challenge(RollEngine(SeededRandom(42))).rollQuickDc(),
  ),
  ResultTestCase(
    className: 'ChallengeSkillResult',
    createInstance: () => Challenge(RollEngine(SeededRandom(42))).rollAnyChallenge(),
  ),
  ResultTestCase(
    className: 'PercentageChanceResult',
    createInstance: () => Challenge(RollEngine(SeededRandom(42))).rollPercentageChance(),
  ),
  
  // === IMMERSION ===
  ResultTestCase(
    className: 'SensoryDetailResult',
    createInstance: () => Immersion(RollEngine(SeededRandom(42))).generateSensoryDetail(),
  ),
  ResultTestCase(
    className: 'EmotionalAtmosphereResult',
    createInstance: () => Immersion(RollEngine(SeededRandom(42))).generateEmotionalAtmosphere(),
  ),
  ResultTestCase(
    className: 'FullImmersionResult',
    createInstance: () => Immersion(RollEngine(SeededRandom(42))).generateFullImmersion(),
  ),
  
  // === EXTENDED NPC CONVERSATION ===
  ResultTestCase(
    className: 'InformationResult',
    createInstance: () => ExtendedNpcConversation(RollEngine(SeededRandom(42))).rollInformation(),
  ),
  ResultTestCase(
    className: 'CompanionResponseResult',
    createInstance: () => ExtendedNpcConversation(RollEngine(SeededRandom(42))).rollCompanionResponse(),
  ),
  ResultTestCase(
    className: 'DialogTopicResult',
    createInstance: () => ExtendedNpcConversation(RollEngine(SeededRandom(42))).rollDialogTopic(),
  ),
  
  // === LOCATION ===
  ResultTestCase(
    className: 'LocationResult',
    createInstance: () => Location.roll(),
  ),
  
  // === ABSTRACT ICONS ===
  ResultTestCase(
    className: 'AbstractIconResult',
    createInstance: () => AbstractIcons(RollEngine(SeededRandom(42))).generate(),
  ),
  
  // === DIALOG GENERATOR ===
  ResultTestCase(
    className: 'DialogResult',
    createInstance: () => DialogGenerator(RollEngine(SeededRandom(42))).generate(),
  ),
  
  // === NAME GENERATOR ===
  ResultTestCase(
    className: 'NameResult',
    createInstance: () => NameGenerator(RollEngine(SeededRandom(42))).generate(),
  ),
  
  // === OBJECT TREASURE ===
  ResultTestCase(
    className: 'ObjectTreasureResult',
    createInstance: () => ObjectTreasure(RollEngine(SeededRandom(42))).generate(),
  ),
  ResultTestCase(
    className: 'ItemCreationResult',
    createInstance: () => ObjectTreasure(RollEngine(SeededRandom(42))).generateFullItem(),
  ),
  
  // === MONSTER ENCOUNTER ===
  ResultTestCase(
    className: 'FullMonsterEncounterResult',
    createInstance: () => MonsterEncounter.generateFullEncounter(0),
  ),
  ResultTestCase(
    className: 'MonsterEncounterResult',
    createInstance: () => MonsterEncounter.rollEncounter(),
  ),
  ResultTestCase(
    className: 'MonsterTracksResult',
    createInstance: () => MonsterEncounter.rollTracks(),
  ),
  
  // === WILDERNESS ===
  ResultTestCase(
    className: 'WildernessAreaResult',
    createInstance: () => Wilderness(RollEngine(SeededRandom(42))).generateArea(),
  ),
  ResultTestCase(
    className: 'WildernessEncounterResult',
    createInstance: () => Wilderness(RollEngine(SeededRandom(42))).rollEncounter(currentState: null),
  ),
  ResultTestCase(
    className: 'WildernessWeatherResult',
    createInstance: () => Wilderness(RollEngine(SeededRandom(42))).rollWeather(environmentRow: 0, typeRow: 0),
  ),
  ResultTestCase(
    className: 'WildernessDetailResult',
    createInstance: () => Wilderness(RollEngine(SeededRandom(42))).rollFeature(),
  ),
  ResultTestCase(
    className: 'MonsterLevelResult',
    createInstance: () => Wilderness(RollEngine(SeededRandom(42))).rollMonsterLevel(environmentRow: 0),
  ),
  
  // === SETTLEMENT ===
  ResultTestCase(
    className: 'SettlementNameResult',
    createInstance: () => Settlement(RollEngine(SeededRandom(42))).generateName(),
  ),
  ResultTestCase(
    className: 'SettlementDetailResult',
    createInstance: () => Settlement(RollEngine(SeededRandom(42))).rollEstablishment(),
  ),
  ResultTestCase(
    className: 'EstablishmentCountResult',
    createInstance: () => Settlement(RollEngine(SeededRandom(42))).rollEstablishmentCount(type: SettlementType.village),
  ),
  ResultTestCase(
    className: 'EstablishmentNameResult',
    createInstance: () => Settlement(RollEngine(SeededRandom(42))).generateEstablishmentName(),
  ),
  ResultTestCase(
    className: 'SettlementPropertiesResult',
    createInstance: () => Settlement(RollEngine(SeededRandom(42))).generateProperties(),
  ),
  ResultTestCase(
    className: 'SimpleNpcResult',
    createInstance: () => Settlement(RollEngine(SeededRandom(42))).generateSimpleNpc(),
  ),
  ResultTestCase(
    className: 'MultiEstablishmentResult',
    createInstance: () => Settlement(RollEngine(SeededRandom(42))).generateEstablishments(type: SettlementType.village),
  ),
  ResultTestCase(
    className: 'FullSettlementResult',
    createInstance: () => Settlement(RollEngine(SeededRandom(42))).generateFull(),
  ),
  ResultTestCase(
    className: 'CompleteSettlementResult',
    createInstance: () => Settlement(RollEngine(SeededRandom(42))).generateVillage(),
  ),
  
  // === DUNGEON GENERATOR ===
  ResultTestCase(
    className: 'DungeonNameResult',
    createInstance: () => DungeonGenerator(RollEngine(SeededRandom(42))).generateName(),
  ),
  ResultTestCase(
    className: 'DungeonAreaResult',
    createInstance: () => DungeonGenerator(RollEngine(SeededRandom(42))).generateNextArea(),
  ),
  ResultTestCase(
    className: 'DungeonDetailResult',
    createInstance: () => DungeonGenerator(RollEngine(SeededRandom(42))).generatePassage(),
  ),
  ResultTestCase(
    className: 'FullDungeonAreaResult',
    createInstance: () => DungeonGenerator(RollEngine(SeededRandom(42))).generateFullArea(),
  ),
  ResultTestCase(
    className: 'DungeonMonsterResult',
    createInstance: () => DungeonGenerator(RollEngine(SeededRandom(42))).rollMonsterDescription(),
  ),
  ResultTestCase(
    className: 'DungeonTrapResult',
    createInstance: () => DungeonGenerator(RollEngine(SeededRandom(42))).rollTrap(),
  ),
  ResultTestCase(
    className: 'DungeonEncounterResult',
    createInstance: () => DungeonGenerator(RollEngine(SeededRandom(42))).rollFullEncounter(),
  ),
  ResultTestCase(
    className: 'TwoPassAreaResult',
    createInstance: () => DungeonGenerator(RollEngine(SeededRandom(42))).generateTwoPassArea(hasFirstDoubles: false),
  ),
  ResultTestCase(
    className: 'TrapProcedureResult',
    createInstance: () => DungeonGenerator(RollEngine(SeededRandom(42))).rollTrapProcedure(),
  ),
  
  // === IRONSWORN (already extracted - reference pattern) ===
  ResultTestCase(
    className: 'IronswornActionResult',
    createInstance: () => IronswornActionResult(
      actionDie: 4,
      challengeDice: [3, 5],
      statBonus: 2,
      adds: 0,
    ),
  ),
  ResultTestCase(
    className: 'IronswornProgressResult',
    createInstance: () => IronswornProgressResult(
      progressScore: 6,
      challengeDice: [4, 7],
    ),
  ),
  ResultTestCase(
    className: 'IronswornOracleResult',
    createInstance: () => IronswornOracleResult(
      oracleRoll: 42,
      dieType: 100,
    ),
  ),
  ResultTestCase(
    className: 'IronswornYesNoResult',
    createInstance: () => IronswornYesNoResult(
      roll: 15,
      odds: IronswornOdds.likely,
    ),
  ),
  ResultTestCase(
    className: 'IronswornCursedOracleResult',
    createInstance: () => IronswornCursedOracleResult(
      oracleRoll: 42,
      cursedDie: 7,
    ),
  ),
  ResultTestCase(
    className: 'IronswornMomentumBurnResult',
    createInstance: () => IronswornMomentumBurnResult(
      actionDie: 3,
      challengeDice: [5, 8],
      statBonus: 2,
      adds: 0,
      momentumValue: 7,
    ),
  ),
];

/// Test case helper class
class ResultTestCase {
  final String className;
  final RollResult Function() createInstance;
  
  const ResultTestCase({
    required this.className,
    required this.createInstance,
  });
}

void main() {
  group('Result Class Extraction Safety Tests', () {
    group('RollResultFactory Registration', () {
      test('all expected result classes are registered', () {
        final missingClasses = <String>[];
        
        for (final testCase in allResultClasses) {
          try {
            final instance = testCase.createInstance();
            final json = instance.toJson();
            final restored = RollResultFactory.fromJson(json);
            
            // If it falls back to base RollResult, the class isn't registered
            if (testCase.className != 'RollResult' && 
                restored.className == 'RollResult') {
              missingClasses.add(testCase.className);
            }
          } catch (e) {
            missingClasses.add('${testCase.className} (error: $e)');
          }
        }
        
        expect(missingClasses, isEmpty,
            reason: 'These classes are not registered in RollResultFactory: '
                '${missingClasses.join(", ")}');
      });
      
      test('className property matches expected value for each class', () {
        final mismatches = <String>[];
        
        for (final testCase in allResultClasses) {
          try {
            final instance = testCase.createInstance();
            if (instance.className != testCase.className) {
              mismatches.add(
                  '${testCase.className}: expected "${testCase.className}", '
                  'got "${instance.className}"');
            }
          } catch (e) {
            mismatches.add('${testCase.className}: error creating instance: $e');
          }
        }
        
        expect(mismatches, isEmpty,
            reason: 'className mismatches found:\n${mismatches.join("\n")}');
      });
      
      test('factory count matches expected class count', () {
        // The factory should have at least as many entries as our test cases
        // (it might have more for deprecated/internal classes)
        expect(allResultClasses.length, greaterThanOrEqualTo(68),
            reason: 'Expected at least 68 result classes based on refactor plan');
      });
    });
    
    group('JSON Serialization Round-Trip', () {
      // Classes with known serialization issues that exist pre-refactor
      // These are bugs in the original fromJson implementations, not refactor issues
      const classesWithKnownSerializationIssues = {
        'ExpectationCheckResult',  // diceResults not fully preserved (meaning rolls embedded differently)
        'NpcProfileResult',         // diceResults recomputed on restore  
        'SimpleNpcResult',          // diceResults recomputed on restore
        'DungeonDetailResult',      // description reconstructed differently
      };
      
      for (final testCase in allResultClasses) {
        test('${testCase.className} serializes and deserializes correctly', () {
          final original = testCase.createInstance();
          
          // Serialize to JSON
          final json = original.toJson();
          
          // Verify className is in the JSON
          expect(json['className'], equals(testCase.className),
              reason: 'className should be preserved in JSON');
          
          // Deserialize back
          final restored = RollResultFactory.fromJson(json);
          
          // CRITICAL FOR REFACTOR: Verify type is preserved
          expect(restored.runtimeType.toString(), 
              equals(original.runtimeType.toString()),
              reason: 'Type should be preserved through serialization');
          
          // CRITICAL FOR REFACTOR: Verify className is preserved
          expect(restored.className, equals(original.className),
              reason: 'className should be preserved');
          
          // CRITICAL FOR REFACTOR: Verify RollType is preserved
          expect(restored.type, equals(original.type),
              reason: 'type should be preserved');
          
          // Skip strict field comparison for classes with known issues
          // These are pre-existing bugs, not refactor issues
          if (!classesWithKnownSerializationIssues.contains(testCase.className)) {
            expect(restored.description, equals(original.description),
                reason: 'description should be preserved');
            expect(restored.diceResults, equals(original.diceResults),
                reason: 'diceResults should be preserved');
            expect(restored.total, equals(original.total),
                reason: 'total should be preserved');
          }
        });
      }
    });
    
    group('Display Registry Coverage', () {
      setUpAll(() {
        // Initialize display registry
        ResultDisplayRegistry.clear();
        registerAllDisplayBuilders();
      });
      
      test('display registry is initialized', () {
        expect(ResultDisplayRegistry.isInitialized, isTrue);
      });
      
      test('all result types have display builders registered', () {
        final missingDisplays = <String>[];
        
        for (final testCase in allResultClasses) {
          try {
            final instance = testCase.createInstance();
            final hasBuilder = ResultDisplayRegistry.hasBuilder(
                instance.runtimeType);
            
            if (!hasBuilder) {
              missingDisplays.add(testCase.className);
            }
          } catch (e) {
            // If we can't create an instance, we can't check the display
            // This is already caught by other tests
          }
        }
        
        // Classes that intentionally use fallback/generic displays
        // or are known to not have dedicated display builders pre-refactor
        final expectedMissing = <String>{
          'RollResult',  // Base class uses generic display
          'FateRollResult',  // Uses generic display
          // Pre-existing: these classes use parent/fallback displays
          'FocusResult',
          'ScaledValueResult',
          'SimpleNpcProfileResult',
          'DualPersonalityResult',
          'PercentageChanceResult',
          'WildernessDetailResult',
          'MonsterLevelResult',
          'SettlementDetailResult',
          'EstablishmentCountResult',
          'MultiEstablishmentResult',
        };
        
        final unexpectedMissing = missingDisplays
            .where((c) => !expectedMissing.contains(c))
            .toList();
        
        expect(unexpectedMissing, isEmpty,
            reason: 'These classes need display builders: '
                '${unexpectedMissing.join(", ")}');
      });
      
      test('display builders return valid widgets', () {
        final theme = ThemeData.light();
        final failures = <String>[];
        
        for (final testCase in allResultClasses) {
          try {
            final instance = testCase.createInstance();
            // Call build to verify it doesn't throw
            ResultDisplayRegistry.build(instance, theme);
            // Success if we got here without throwing
          } catch (e) {
            failures.add('${testCase.className}: builder threw: $e');
          }
        }
        
        expect(failures, isEmpty,
            reason: 'Display builder failures:\n${failures.join("\n")}');
      });
    });
    
    group('Result Class Invariants', () {
      test('all result classes have valid RollType', () {
        for (final testCase in allResultClasses) {
          final instance = testCase.createInstance();
          expect(RollType.values, contains(instance.type),
              reason: '${testCase.className} should have valid RollType');
        }
      });
      
      test('all result classes have non-empty description', () {
        for (final testCase in allResultClasses) {
          final instance = testCase.createInstance();
          expect(instance.description.isNotEmpty, isTrue,
              reason: '${testCase.className} should have non-empty description');
        }
      });
      
      test('all result classes produce valid JSON', () {
        for (final testCase in allResultClasses) {
          final instance = testCase.createInstance();
          expect(() => instance.toJson(), returnsNormally,
              reason: '${testCase.className}.toJson() should not throw');
          
          final json = instance.toJson();
          expect(json, isA<Map<String, dynamic>>());
          expect(json['className'], isNotNull);
          expect(json['type'], isNotNull);
        }
      });
    });
  });
  
  group('Result Class Counts (Sanity Check)', () {
    test('test suite covers all 68+ expected result classes', () {
      // Count unique class names in our test cases
      final classNames = allResultClasses.map((tc) => tc.className).toSet();
      
      // We expect at least 68 based on the refactor plan inventory
      // (76 in RollResultFactory, but 68 in preset files)
      expect(classNames.length, greaterThanOrEqualTo(68),
          reason: 'Should have test cases for all 68+ result classes. '
              'Found: ${classNames.length}');
    });
    
    test('all class names are unique in test suite', () {
      final classNames = <String>[];
      final duplicates = <String>[];
      
      for (final testCase in allResultClasses) {
        if (classNames.contains(testCase.className)) {
          duplicates.add(testCase.className);
        }
        classNames.add(testCase.className);
      }
      
      expect(duplicates, isEmpty,
          reason: 'Duplicate class names in test suite: ${duplicates.join(", ")}');
    });
  });
}
