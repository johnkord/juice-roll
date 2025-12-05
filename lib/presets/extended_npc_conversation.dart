import '../core/roll_engine.dart';
import '../models/roll_result.dart';
import 'details.dart' show SkewType;

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
class ExtendedNpcConversation {
  final RollEngine _rollEngine;

  /// Type of Information (1d100) - What kind of information the NPC provides
  static const List<String> informationTypes = [
    'A connection between a PC and',           // 1-3
    'A connection between a PC and',
    'A connection between a PC and',
    'A connection between an antagonist and',  // 4-6
    'A connection between an antagonist and',
    'A connection between an antagonist and',
    'A connection between an NPC and',         // 7-9
    'A connection between an NPC and',
    'A connection between an NPC and',
    'A financial boon involving',              // 10-12
    'A financial boon involving',
    'A financial boon involving',
    'A financial loss involving',              // 13-15
    'A financial loss involving',
    'A financial loss involving',
    'A gain in influence involving',           // 16-18
    'A gain in influence involving',
    'A gain in influence involving',
    'A loss of influence involving',           // 19-21
    'A loss of influence involving',
    'A loss of influence involving',
    'A loss of opportunity involving',         // 22-24
    'A loss of opportunity involving',
    'A loss of opportunity involving',
    'A material boon involving',               // 25-27
    'A material boon involving',
    'A material boon involving',
    'A material loss involving',               // 28-30
    'A material loss involving',
    'A material loss involving',
    'A mental boon involving',                 // 31-33
    'A mental boon involving',
    'A mental boon involving',
    'A mental loss involving',                 // 34-36
    'A mental loss involving',
    'A mental loss involving',
    'A negative change in',                    // 37-39
    'A negative change in',
    'A negative change in',
    'A physical boon involving',               // 40-42
    'A physical boon involving',
    'A physical boon involving',
    'A physical loss involving',               // 43-45
    'A physical loss involving',
    'A physical loss involving',
    'A positive change in',                    // 46-48
    'A positive change in',
    'A positive change in',
    'A significant insight related to',        // 49-51
    'A significant insight related to',
    'A significant insight related to',
    'A spiritual boon involving',              // 52-54
    'A spiritual boon involving',
    'A spiritual boon involving',
    'A spiritual loss involving',              // 55-57
    'A spiritual loss involving',
    'A spiritual loss involving',
    'An additional opportunity involving',     // 58-60
    'An additional opportunity involving',
    'An additional opportunity involving',
    'An alteration of',                        // 61-63
    'An alteration of',
    'An alteration of',
    'An ambush concerning',                    // 64-66
    'An ambush concerning',
    'An ambush concerning',
    'An emotional boon involving',             // 67-69
    'An emotional boon involving',
    'An emotional boon involving',
    'An emotional loss involving',             // 70-72
    'An emotional loss involving',
    'An emotional loss involving',
    'Historical/background knowledge about',   // 73-75
    'Historical/background knowledge about',
    'Historical/background knowledge about',
    'Negative news about',                     // 76-78
    'Negative news about',
    'Negative news about',
    'Positive news about',                     // 79-81
    'Positive news about',
    'Positive news about',
    'The acquisition of an ability involving', // 82-84
    'The acquisition of an ability involving',
    'The acquisition of an ability involving',
    'The acquisition of authority involving',  // 85-87
    'The acquisition of authority involving',
    'The acquisition of authority involving',
    'The identity of',                         // 88-90
    'The identity of',
    'The identity of',
    'The location of',                         // 91-93
    'The location of',
    'The location of',
    'The loss of an ability involving',        // 94-96
    'The loss of an ability involving',
    'The loss of an ability involving',
    'The loss of authority involving',         // 97-99
    'The loss of authority involving',
    'The loss of authority involving',
    'The truth is the exact opposite of what the PCs thought about', // 100
  ];

  /// Topic of Information (1d100) - What the information is about
  static const List<String> informationTopics = [
    'a beloved NPC',                                      // 1-3
    'a beloved NPC',
    'a beloved NPC',
    'a benefactor for the PCs',                           // 4-6
    'a benefactor for the PCs',
    'a benefactor for the PCs',
    'a combative NPC',                                    // 7-9
    'a combative NPC',
    'a combative NPC',
    'a dangerous location for the PCs',                   // 10-12
    'a dangerous location for the PCs',
    'a dangerous location for the PCs',
    'a despised NPC',                                     // 13-15
    'a despised NPC',
    'a despised NPC',
    'a distant location',                                 // 16-18
    'a distant location',
    'a distant location',
    'a group supportive to the PCs',                      // 19-21
    'a group supportive to the PCs',
    'a group supportive to the PCs',
    'a main antagonist',                                  // 22-24
    'a main antagonist',
    'a main antagonist',
    'a necessary artifact for fulfilling a vow',          // 25-27
    'a necessary artifact for fulfilling a vow',
    'a necessary artifact for fulfilling a vow',
    'a necessary object to complete a vow',               // 28-30
    'a necessary object to complete a vow',
    'a necessary object to complete a vow',
    'a person with important information about a side quest', // 31-33
    'a person with important information about a side quest',
    'a person with important information about a side quest',
    'a person with important information about an important thread', // 34-36
    'a person with important information about an important thread',
    'a person with important information about an important thread',
    'a previously unknown character connected to the plot',    // 37-39
    'a previously unknown character connected to the plot',
    'a previously unknown character connected to the plot',
    'a safe location for the PCs',                        // 40-42
    'a safe location for the PCs',
    'a safe location for the PCs',
    'a secret enemy hideout',                             // 43-45
    'a secret enemy hideout',
    'a secret enemy hideout',
    'a single PC',                                        // 46-48
    'a single PC',
    'a single PC',
    'a special status for a main antagonist',             // 49-51
    'a special status for a main antagonist',
    'a special status for a main antagonist',
    'a special status for a PC',                          // 52-54
    'a special status for a PC',
    'a special status for a PC',
    'a special status for an NPC',                        // 55-57
    'a special status for an NPC',
    'a special status for an NPC',
    'a traitor to the PCs',                               // 58-60
    'a traitor to the PCs',
    'a traitor to the PCs',
    'an enemy leader',                                    // 61-63
    'an enemy leader',
    'an enemy leader',
    'an enemy servant',                                   // 64-66
    'an enemy servant',
    'an enemy servant',
    'an enemy spy',                                       // 67-69
    'an enemy spy',
    'an enemy spy',
    'an enemy stronghold',                                // 70-72
    'an enemy stronghold',
    'an enemy stronghold',
    'an enemy who is now an ally',                        // 73-75
    'an enemy who is now an ally',
    'an enemy who is now an ally',
    "an enemy's current plan",                            // 76-78
    "an enemy's current plan",
    "an enemy's current plan",
    "an enemy's future plan",                             // 79-81
    "an enemy's future plan",
    "an enemy's future plan",
    'an important thread',                                // 82-84
    'an important thread',
    'an important thread',
    'an oppositional group that is not a main antagonist',// 85-87
    'an oppositional group that is not a main antagonist',
    'an oppositional group that is not a main antagonist',
    'the current setting',                                // 88-90
    'the current setting',
    'the current setting',
    'the current short-term goal',                        // 91-93
    'the current short-term goal',
    'the current short-term goal',
    'the PCs as a whole',                                 // 94-96
    'the PCs as a whole',
    'the PCs as a whole',
    'the road or passage to the next location',           // 97-99
    'the road or passage to the next location',
    'the road or passage to the next location',
    'a foundational truth of the world',                  // 100
  ];

  /// Companion Response (1d100) - Ordered from opposed (1) to in favor (100)
  static const List<String> companionResponses = [
    "You must be joking if you think I'll do that.",      // 1-2
    "You must be joking if you think I'll do that.",
    "I refuse to go along with that plan.",               // 3-4
    "I refuse to go along with that plan.",
    "That would never work because... There must be a better way.", // 5-6
    "That would never work because... There must be a better way.",
    "No way, that's too...",                              // 7-8
    "No way, that's too...",
    "What benefit could... possibly bring us?",           // 9-10
    "What benefit could... possibly bring us?",
    "I'm not comfortable with that idea.",                // 11-12
    "I'm not comfortable with that idea.",
    "We need to spend more time here doing...",           // 13-14
    "We need to spend more time here doing...",
    "Don't you think there's the risk of...?",            // 15-16
    "Don't you think there's the risk of...?",
    "Do we have enough... to do that?",                   // 17-18
    "Do we have enough... to do that?",
    "It's one option, but I would prefer to...",          // 19-20
    "It's one option, but I would prefer to...",
    "You go ahead. I'll join you later.",                 // 21-22
    "You go ahead. I'll join you later.",
    "I have my doubts, but maybe if we tweak it a bit...", // 23-24
    "I have my doubts, but maybe if we tweak it a bit...",
    "I don't think that is right...",                     // 25-26
    "I don't think that is right...",
    "Yes, but first we have to...",                       // 27-28
    "Yes, but first we have to...",
    "There are other priorities to take care of first.",  // 29-30
    "There are other priorities to take care of first.",
    "I'm willing to give it a shot, but we need a backup plan.", // 31-32
    "I'm willing to give it a shot, but we need a backup plan.",
    "Okay, I'll go along with it, but only if we take precautions.", // 33-34
    "Okay, I'll go along with it, but only if we take precautions.",
    "I'm in, but let's be careful not to overlook the consequences.", // 35-36
    "I'm in, but let's be careful not to overlook the consequences.",
    "I don't see this ending well.",                      // 37-38
    "I don't see this ending well.",
    "Can we also...?",                                    // 39-40
    "Can we also...?",
    "Wait, what if we do the exact opposite?",            // 41-42
    "Wait, what if we do the exact opposite?",
    "What if we take a completely unexpected route to get to...?", // 43-44
    "What if we take a completely unexpected route to get to...?",
    "I've got a wild plan that just might work...",       // 45-46
    "I've got a wild plan that just might work...",
    "Yes, but how about we surprise them with...",        // 47-48
    "Yes, but how about we surprise them with...",
    "We can do that, but we have to tone down the...",    // 49-50
    "We can do that, but we have to tone down the...",
    "Who would that benefit?",                            // 51-52
    "Who would that benefit?",
    "What is the next step?",                             // 53-54
    "What is the next step?",
    "When should we...?",                                 // 55-56
    "When should we...?",
    "Where should we...?",                                // 57-58
    "Where should we...?",
    "How do you plan on...?",                             // 59-60
    "How do you plan on...?",
    "What do you want?",                                  // 61-62
    "What do you want?",
    "You just figured this out?",                         // 63-64
    "You just figured this out?",
    "Did you consider...?",                               // 65-66
    "Did you consider...?",
    "Ha!",                                                // 67-68
    "Ha!",
    "That's a bit unfair.",                               // 69-70
    "That's a bit unfair.",
    "That is a really bad idea!",                         // 71-72
    "That is a really bad idea!",
    "There is something I need to tell you...",           // 73-74
    "There is something I need to tell you...",
    "Why is this happening?",                             // 75-76
    "Why is this happening?",
    "This is all very overwhelming!",                     // 77-78
    "This is all very overwhelming!",
    "Help!",                                              // 79-80
    "Help!",
    "Watch out!",                                         // 81-82
    "Watch out!",
    "Let's go!",                                          // 83-84
    "Let's go!",
    "I want to go home!",                                 // 85-86
    "I want to go home!",
    "Now is not a good time!",                            // 87-88
    "Now is not a good time!",
    "Sure, I'm on board with that.",                      // 89-90
    "Sure, I'm on board with that.",
    "Sounds good, I'm in.",                               // 91-92
    "Sounds good, I'm in.",
    "I'm willing to give it a try.",                      // 93-94
    "I'm willing to give it a try.",
    "Let's do it, no objections here.",                   // 95-96
    "Let's do it, no objections here.",
    "Okay, I'm with you on this one.",                    // 97-98
    "Okay, I'm with you on this one.",
    "I'm ready, let's go for it.",                        // 99-100
    "I'm ready, let's go for it.",
  ];

  /// Extended NPC Dialog Topic (1d100) - What NPCs are talking about
  static const List<String> dialogTopics = [
    'A PC secret that has been made known',               // 1-2
    'A PC secret that has been made known',
    'A personal injury',                                  // 3-4
    'A personal injury',
    'A recent change in the family of an NPC',            // 5-6
    'A recent change in the family of an NPC',
    'A recent change in their own family',                // 7-8
    'A recent change in their own family',
    'A recent inaction and the consequences',             // 9-10
    'A recent inaction and the consequences',
    'A significant death',                                // 11-12
    'A significant death',
    'A source of wealth',                                 // 13-14
    'A source of wealth',
    'A specific location',                                // 15-16
    'A specific location',
    'An enemy secret that has been made known',           // 17-18
    'An enemy secret that has been made known',
    'Common knowledge about an enemy',                    // 19-20
    'Common knowledge about an enemy',
    'Current events',                                     // 21-22
    'Current events',
    'Famous people',                                      // 23-24
    'Famous people',
    'Famous places',                                      // 25-26
    'Famous places',
    'General knowledge of a region',                      // 27-28
    'General knowledge of a region',
    'Important political connections',                    // 29-30
    'Important political connections',
    'Important social connections',                       // 31-32
    'Important social connections',
    'Information that has recently been discovered',      // 33-34
    'Information that has recently been discovered',
    'Ingenious or outlandish ideas',                      // 35-36
    'Ingenious or outlandish ideas',
    'Items of importance',                                // 37-38
    'Items of importance',
    'Legends of heroic deeds',                            // 39-40
    'Legends of heroic deeds',
    'Legends of relics',                                  // 41-42
    'Legends of relics',
    'Local warbands',                                     // 43-44
    'Local warbands',
    'Particular equipment of a trade, craft, or occupation', // 45-46
    'Particular equipment of a trade, craft, or occupation',
    'Particular skills of a trade, craft, or occupation', // 47-48
    'Particular skills of a trade, craft, or occupation',
    'Powerful people',                                    // 49-50
    'Powerful people',
    'Recent political changes',                           // 51-52
    'Recent political changes',
    'Reported sightings of the First Born',               // 53-54
    'Reported sightings of the First Born',
    "Rumors of a PC's past",                              // 55-56
    "Rumors of a PC's past",
    "Rumors of an NPC's past",                            // 57-58
    "Rumors of an NPC's past",
    'Shifting political alliances',                       // 59-60
    'Shifting political alliances',
    'Small jobs or side quests that need to be done',     // 61-62
    'Small jobs or side quests that need to be done',
    'The acquisition of knowledge',                       // 63-64
    'The acquisition of knowledge',
    'The background of a PC',                             // 65-66
    'The background of a PC',
    'The background of an NPC',                           // 67-68
    'The background of an NPC',
    'The background of the community',                    // 69-70
    'The background of the community',
    'The culture of the community',                       // 71-72
    'The culture of the community',
    'The current leadership',                             // 73-74
    'The current leadership',
    'The distribution of wealth',                         // 75-76
    'The distribution of wealth',
    'The failures of a PC',                               // 77-78
    'The failures of a PC',
    'The failures of an NPC',                             // 79-80
    'The failures of an NPC',
    'The future of the community',                        // 81-82
    'The future of the community',
    'The most valuable experiences',                      // 83-84
    'The most valuable experiences',
    'The quickest way to fame',                           // 85-86
    'The quickest way to fame',
    'The value of experience',                            // 87-88
    'The value of experience',
    'Their own background',                               // 89-90
    'Their own background',
    'Their own failures',                                 // 91-92
    'Their own failures',
    'Upcoming events',                                    // 93-94
    'Upcoming events',
    'Useful contacts',                                    // 95-96
    'Useful contacts',
    'Where the power lies',                               // 97-98
    'Where the power lies',
    'Why the leadership needs to change',                 // 99-100
    'Why the leadership needs to change',
  ];

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

/// Result of rolling Information (2d100: Type + Topic).
class InformationResult extends RollResult {
  final int typeRoll;
  final int topicRoll;
  final String informationType;
  final String topic;

  InformationResult({
    required this.typeRoll,
    required this.topicRoll,
    required this.informationType,
    required this.topic,
    DateTime? timestamp,
  }) : super(
          type: RollType.npcAction,
          description: 'NPC Information (2d100)',
          diceResults: [typeRoll, topicRoll],
          total: typeRoll + topicRoll,
          interpretation: '$informationType $topic',
          timestamp: timestamp,
          metadata: {
            'typeRoll': typeRoll,
            'topicRoll': topicRoll,
            'informationType': informationType,
            'topic': topic,
          },
        );

  @override
  String get className => 'InformationResult';

  factory InformationResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return InformationResult(
      typeRoll: meta['typeRoll'] as int? ?? diceResults[0],
      topicRoll: meta['topicRoll'] as int? ?? diceResults[1],
      informationType: meta['informationType'] as String,
      topic: meta['topic'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() => '$informationType $topic';
}

/// Result of rolling Companion Response (1d100).
class CompanionResponseResult extends RollResult {
  final int roll;
  final String response;
  final SkewType skew;
  final List<int> allRolls;

  CompanionResponseResult({
    required this.roll,
    required this.response,
    required this.skew,
    required this.allRolls,
    DateTime? timestamp,
  }) : super(
          type: RollType.npcAction,
          description: _buildDescription(skew),
          diceResults: allRolls,
          total: roll,
          interpretation: response,
          timestamp: timestamp,
          metadata: {
            'roll': roll,
            'response': response,
            'skew': skew.name,
            'favor': _getFavorLevel(roll),
          },
        );

  @override
  String get className => 'CompanionResponseResult';

  factory CompanionResponseResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return CompanionResponseResult(
      roll: meta['roll'] as int? ?? diceResults[0],
      response: meta['response'] as String,
      skew: SkewType.values.firstWhere(
        (s) => s.name == meta['skew'],
        orElse: () => SkewType.none,
      ),
      allRolls: diceResults,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  static String _buildDescription(SkewType skew) {
    switch (skew) {
      case SkewType.advantage:
        return 'Companion Response (1d100@+ In Favor)';
      case SkewType.disadvantage:
        return 'Companion Response (1d100@- Opposed)';
      case SkewType.none:
        return 'Companion Response (1d100)';
    }
  }

  static String _getFavorLevel(int roll) {
    if (roll <= 20) return 'Strongly Opposed';
    if (roll <= 40) return 'Hesitant';
    if (roll <= 60) return 'Neutral/Questioning';
    if (roll <= 80) return 'Cautious Support';
    return 'Strongly In Favor';
  }

  /// Get the favor level of the response
  String get favorLevel => _getFavorLevel(roll);

  @override
  String toString() => response;
}

/// Result of rolling Extended NPC Dialog Topic (1d100).
class DialogTopicResult extends RollResult {
  final int roll;
  final String topic;

  DialogTopicResult({
    required this.roll,
    required this.topic,
    DateTime? timestamp,
  }) : super(
          type: RollType.npcAction,
          description: 'Dialog Topic (1d100)',
          diceResults: [roll],
          total: roll,
          interpretation: topic,
          timestamp: timestamp,
          metadata: {
            'roll': roll,
            'topic': topic,
          },
        );

  @override
  String get className => 'DialogTopicResult';

  factory DialogTopicResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return DialogTopicResult(
      roll: meta['roll'] as int? ?? diceResults[0],
      topic: meta['topic'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() => topic;
}
