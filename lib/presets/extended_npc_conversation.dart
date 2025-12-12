import '../core/roll_engine.dart';
import '../data/extended_npc_conversation_data.dart' as data;
import 'details.dart' show SkewType;

// Re-export result classes for backward compatibility
export '../models/results/extended_npc_conversation_result.dart'
    show InformationResult, CompanionResponseResult, DialogTopicResult;

// Import result classes for internal use
import '../models/results/extended_npc_conversation_result.dart';

/// Extended NPC Conversation Tables preset for the Juice Oracle.
/// 
/// Alternative to the Dialog Grid mini-game for NPC conversations.
/// Provides tables for:
/// - Information (2d100): Type of Information + Topic of Information
/// - Companion Response (1d100): Ordered responses to "the plan"
/// - Extended NPC Dialog Topic (1d100): What NPCs are talking about
/// 
/// From the Juice instructions:
/// "NPCs make the world feel alive. Talking with them can help you world-build,
/// give you side quests, or give information that your character would otherwise
/// not have access to."
/// 
/// **Data Separation:**
/// Static table data is stored in data/extended_npc_conversation_data.dart.
/// This class provides backward-compatible static accessors.
class ExtendedNpcConversation {
  final RollEngine _rollEngine;

  // ========== Static Accessors (delegate to data file) ==========

  /// Type of Information (1d100) - What kind of information the NPC provides
  static List<String> get informationTypes => data.informationTypes;

  /// Topic of Information (1d100) - What the information is about
  static List<String> get informationTopics => data.informationTopics;

  /// Companion Response (1d100) - Ordered from opposed (1) to in favor (100)
  static List<String> get companionResponses => data.companionResponses;

  /// Extended NPC Dialog Topic (1d100) - What NPCs are talking about
  static List<String> get dialogTopics => data.dialogTopics;

  ExtendedNpcConversation([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  /// Roll 2d100 for Information (Type + Topic).
  /// Used when asking an NPC for information or overhearing a conversation.
  InformationResult rollInformation() {
    final typeRoll = _rollEngine.rollDie(100);
    final topicRoll = _rollEngine.rollDie(100);
    
    final informationType = informationTypes[typeRoll - 1];
    final topic = informationTopics[topicRoll - 1];

    return InformationResult(
      typeRoll: typeRoll,
      topicRoll: topicRoll,
      informationType: informationType,
      topic: topic,
    );
  }

  /// Roll 1d100 for Companion Response.
  /// Ordered such that bigger numbers are more in favor with "the plan".
  /// Use advantage for companions likely to agree, disadvantage for opposition.
  CompanionResponseResult rollCompanionResponse({SkewType skew = SkewType.none}) {
    int roll;
    List<int> allRolls = [];
    
    switch (skew) {
      case SkewType.advantage:
        final result = _rollEngine.rollWithAdvantage(1, 100);
        roll = result.chosenSum;
        allRolls = [result.sum1, result.sum2];
        break;
      case SkewType.disadvantage:
        final result = _rollEngine.rollWithDisadvantage(1, 100);
        roll = result.chosenSum;
        allRolls = [result.sum1, result.sum2];
        break;
      case SkewType.none:
        roll = _rollEngine.rollDie(100);
        allRolls = [roll];
    }
    
    final response = companionResponses[roll - 1];

    return CompanionResponseResult(
      roll: roll,
      response: response,
      skew: skew,
      allRolls: allRolls,
    );
  }

  /// Roll 1d100 for Extended NPC Dialog Topic.
  /// Can also be used for News, letters, books, writing on walls, etc.
  DialogTopicResult rollDialogTopic() {
    final roll = _rollEngine.rollDie(100);
    final topic = dialogTopics[roll - 1];

    return DialogTopicResult(
      roll: roll,
      topic: topic,
    );
  }
}

