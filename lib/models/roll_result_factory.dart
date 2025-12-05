import 'roll_result.dart';
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
class RollResultFactory {
  /// Registry of class names to their fromJson constructors.
  /// Classes not in this registry will fall back to base RollResult.
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
    'NpcProfileResult': NpcProfileResult.fromJson,
    
    // Details
    'DetailResult': DetailResult.fromJson,
    'PropertyResult': PropertyResult.fromJson,
    'DetailWithFollowUpResult': DetailWithFollowUpResult.fromJson,
    
    // Challenge
    'FullChallengeResult': FullChallengeResult.fromJson,
    'ChallengeSkillResult': ChallengeSkillResult.fromJson,
    'QuickDcResult': QuickDcResult.fromJson,
    
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
    } catch (e) {
      // If deserialization fails, fall back to base RollResult
      return RollResult.fromJson(json);
    }
  }
}
