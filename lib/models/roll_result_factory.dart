import 'package:flutter/foundation.dart';

import 'roll_result.dart';
import 'results/ironsworn_result.dart';
import '../presets/fate_check.dart';
import '../presets/random_event.dart';
import '../presets/monster_encounter.dart';
import '../presets/wilderness.dart';
import '../presets/expectation_check.dart';
import '../presets/discover_meaning.dart';
import '../presets/scale.dart';
import '../presets/next_scene.dart';
import '../presets/pay_the_price.dart';
import '../presets/interrupt_plot_point.dart';
import '../presets/quest.dart';
import '../presets/npc_action.dart';
import '../presets/details.dart';
import '../presets/challenge.dart';
import '../presets/immersion.dart';
import '../presets/dialog_generator.dart';
import '../presets/location.dart';
import '../presets/abstract_icons.dart';
import '../presets/object_treasure.dart';
import '../presets/settlement.dart';
import '../presets/extended_npc_conversation.dart';
import '../presets/dungeon_generator.dart';
import '../presets/name_generator.dart';

/// Factory for reconstructing RollResult subclasses from JSON.
/// 
/// This factory uses the 'className' field stored in the JSON to determine
/// which specific subclass to instantiate.
/// 
/// ## IMPORTANT: Adding new RollResult subclasses
/// 
/// When you create a new class that extends [RollResult], you MUST register
/// it in the [_registry] map below. Otherwise:
/// 
/// - Roll history will not persist correctly across app reloads
/// - Your custom result type will fall back to a generic RollResult
/// - Custom display formatting will be lost after reload
/// 
/// To register a new result class:
/// 
/// 1. Import the file containing your result class at the top of this file
/// 2. Add an entry to [_registry]: `'YourClassName': YourClassName.fromJson,`
/// 3. Ensure your class overrides `className` and implements `fromJson`
/// 
/// See [RollResult] documentation for the full checklist.
class RollResultFactory {
  /// Registry of class names to their fromJson constructors.
  /// 
  /// ⚠️ REMINDER: Add your new RollResult subclass here!
  /// If you created a new result type and it's not in this map,
  /// it will not deserialize correctly after app reload.
  static final Map<String, RollResult Function(Map<String, dynamic>)> _registry = {
    // Base
    'RollResult': RollResult.fromJson,
    
    // Fate Check
    'FateRollResult': FateRollResult.fromJson,
    'FateCheckResult': FateCheckResult.fromJson,
    
    // Random Event
    'RandomEventResult': RandomEventResult.fromJson,
    'RandomEventFocusResult': RandomEventFocusResult.fromJson,
    'IdeaResult': IdeaResult.fromJson,
    'SingleTableResult': SingleTableResult.fromJson,
    
    // Monster Encounter
    'FullMonsterEncounterResult': FullMonsterEncounterResult.fromJson,
    'MonsterEncounterResult': MonsterEncounterResult.fromJson,
    'MonsterTracksResult': MonsterTracksResult.fromJson,
    
    // Wilderness
    'WildernessAreaResult': WildernessAreaResult.fromJson,
    'WildernessEncounterResult': WildernessEncounterResult.fromJson,
    'WildernessWeatherResult': WildernessWeatherResult.fromJson,
    'WildernessDetailResult': WildernessDetailResult.fromJson,
    'MonsterLevelResult': MonsterLevelResult.fromJson,
    
    // Expectation Check
    'ExpectationCheckResult': ExpectationCheckResult.fromJson,
    
    // Discover Meaning
    'DiscoverMeaningResult': DiscoverMeaningResult.fromJson,
    
    // Scale
    'ScaleResult': ScaleResult.fromJson,
    'ScaledValueResult': ScaledValueResult.fromJson,
    
    // Next Scene
    'NextSceneResult': NextSceneResult.fromJson,
    'FocusResult': FocusResult.fromJson,
    'NextSceneWithFollowUpResult': NextSceneWithFollowUpResult.fromJson,
    
    // Pay the Price
    'PayThePriceResult': PayThePriceResult.fromJson,
    
    // Interrupt Plot Point
    'InterruptPlotPointResult': InterruptPlotPointResult.fromJson,
    
    // Quest
    'QuestResult': QuestResult.fromJson,
    
    // NPC Action
    'NpcActionResult': NpcActionResult.fromJson,
    'MotiveWithFollowUpResult': MotiveWithFollowUpResult.fromJson,
    'SimpleNpcProfileResult': SimpleNpcProfileResult.fromJson,
    'NpcProfileResult': NpcProfileResult.fromJson,
    'DualPersonalityResult': DualPersonalityResult.fromJson,
    'ComplexNpcResult': ComplexNpcResult.fromJson,
    
    // Details
    'DetailResult': DetailResult.fromJson,
    'PropertyResult': PropertyResult.fromJson,
    'DualPropertyResult': DualPropertyResult.fromJson,
    'DetailWithFollowUpResult': DetailWithFollowUpResult.fromJson,
    
    // Challenge
    'FullChallengeResult': FullChallengeResult.fromJson,
    'DcResult': DcResult.fromJson,
    'QuickDcResult': QuickDcResult.fromJson,
    'ChallengeSkillResult': ChallengeSkillResult.fromJson,
    'PercentageChanceResult': PercentageChanceResult.fromJson,
    
    // Immersion
    'SensoryDetailResult': SensoryDetailResult.fromJson,
    'EmotionalAtmosphereResult': EmotionalAtmosphereResult.fromJson,
    'FullImmersionResult': FullImmersionResult.fromJson,
    
    // Dialog Generator
    'DialogResult': DialogResult.fromJson,
    
    // Location
    'LocationResult': LocationResult.fromJson,
    
    // Abstract Icons
    'AbstractIconResult': AbstractIconResult.fromJson,
    
    // Object Treasure
    'ObjectTreasureResult': ObjectTreasureResult.fromJson,
    'ItemCreationResult': ItemCreationResult.fromJson,
    
    // Settlement
    'SettlementNameResult': SettlementNameResult.fromJson,
    'SettlementDetailResult': SettlementDetailResult.fromJson,
    'EstablishmentCountResult': EstablishmentCountResult.fromJson,
    'EstablishmentNameResult': EstablishmentNameResult.fromJson,
    'SettlementPropertiesResult': SettlementPropertiesResult.fromJson,
    'SimpleNpcResult': SimpleNpcResult.fromJson,
    'MultiEstablishmentResult': MultiEstablishmentResult.fromJson,
    'FullSettlementResult': FullSettlementResult.fromJson,
    'CompleteSettlementResult': CompleteSettlementResult.fromJson,
    
    // Extended NPC Conversation
    'InformationResult': InformationResult.fromJson,
    'CompanionResponseResult': CompanionResponseResult.fromJson,
    'DialogTopicResult': DialogTopicResult.fromJson,
    
    // Dungeon Generator
    'DungeonNameResult': DungeonNameResult.fromJson,
    'DungeonAreaResult': DungeonAreaResult.fromJson,
    'DungeonDetailResult': DungeonDetailResult.fromJson,
    'FullDungeonAreaResult': FullDungeonAreaResult.fromJson,
    'DungeonMonsterResult': DungeonMonsterResult.fromJson,
    'DungeonTrapResult': DungeonTrapResult.fromJson,
    'DungeonEncounterResult': DungeonEncounterResult.fromJson,
    'TwoPassAreaResult': TwoPassAreaResult.fromJson,
    'TrapProcedureResult': TrapProcedureResult.fromJson,
    
    // Name Generator
    'NameResult': NameResult.fromJson,
    
    // Ironsworn
    'IronswornActionResult': IronswornActionResult.fromJson,
    'IronswornProgressResult': IronswornProgressResult.fromJson,
    'IronswornOracleResult': IronswornOracleResult.fromJson,
    'IronswornYesNoResult': IronswornYesNoResult.fromJson,
    'IronswornCursedOracleResult': IronswornCursedOracleResult.fromJson,
    'IronswornMomentumBurnResult': IronswornMomentumBurnResult.fromJson,
    
    // ┌─────────────────────────────────────────────────────────────────┐
    // │  👆 ADD NEW RESULT CLASSES ABOVE THIS LINE!                     │
    // │                                                                 │
    // │  Format: 'ClassName': ClassName.fromJson,                       │
    // │                                                                 │
    // │  Don't forget to also import the file at the top!               │
    // └─────────────────────────────────────────────────────────────────┘
  };

  /// Reconstruct a RollResult from JSON, using the appropriate subclass.
  static RollResult fromJson(Map<String, dynamic> json) {
    final className = json['className'] as String?;
    
    // If no className, fall back to base RollResult
    if (className == null) {
      return RollResult.fromJson(json);
    }
    
    // Look up the factory function
    final factory = _registry[className];
    if (factory == null) {
      // Unknown class, fall back to base RollResult
      return RollResult.fromJson(json);
    }
    
    try {
      return factory(json);
    } catch (e, stackTrace) {
      // If deserialization fails, fall back to base RollResult
      // Log the error so we can fix the root cause
      assert(() {
        debugPrint('[RollResultFactory] Failed to deserialize $className: $e');
        debugPrint('[RollResultFactory] Stack trace: $stackTrace');
        return true;
      }());
      return RollResult.fromJson(json);
    }
  }
}
