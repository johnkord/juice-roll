/// Guidance data for Detail table results.
/// 
/// Based on the Juice Oracle instructions (pages 29-31), each detail
/// modifier has specific interpretation guidance and may require follow-up rolls.
/// 
/// Reference: Details section of juice_081425_instructions-1.md
library;

/// Detail modifier categories for determining guidance type.
enum DetailModifierCategory {
  emotion,      // Negative/Positive Emotion
  pc,           // Favors/Disfavors PC
  thread,       // Favors/Disfavors Thread
  npc,          // Favors/Disfavors NPC
  followUp,     // History, Property (requires sub-roll)
}

/// Guidance data for a specific detail modifier result.
class DetailModifierGuidance {
  final String result;
  final DetailModifierCategory category;
  final bool isPositive;
  final String description;
  final String prompt;
  final String? followUpRoll;
  final List<String> examples;
  final String? skewNote;

  const DetailModifierGuidance({
    required this.result,
    required this.category,
    required this.isPositive,
    required this.description,
    required this.prompt,
    this.followUpRoll,
    required this.examples,
    this.skewNote,
  });
}

/// Map of detail modifier results to their guidance.
/// Based on Juice Oracle instructions pages 29-31.
const Map<String, DetailModifierGuidance> detailModifierGuidance = {
  'Negative Emotion': DetailModifierGuidance(
    result: 'Negative Emotion',
    category: DetailModifierCategory.emotion,
    isPositive: false,
    description: 'The "thing" should evoke a negative emotion from your character.',
    prompt: 'What negative emotion does this evoke?',
    examples: [
      'A sword that is jagged, rusted, and bloodstained → Disgust',
      'A letter with a wax seal you recognize → Dread',
      'An empty room where someone should be → Worry',
    ],
    skewNote: 'Use the Immersion table\'s "and it causes" column for emotion ideas.',
  ),
  
  'Positive Emotion': DetailModifierGuidance(
    result: 'Positive Emotion',
    category: DetailModifierCategory.emotion,
    isPositive: true,
    description: 'The "thing" should evoke a positive emotion from your character.',
    prompt: 'What positive emotion does this evoke?',
    examples: [
      'A familiar crest on a shield → Relief, recognition',
      'A hidden compartment with supplies → Joy, hope',
      'A note from an old friend → Warmth, nostalgia',
    ],
    skewNote: 'Use the Immersion table\'s "and it causes" column for emotion ideas.',
  ),
  
  'Disfavors PC': DetailModifierGuidance(
    result: 'Disfavors PC',
    category: DetailModifierCategory.pc,
    isPositive: false,
    description: 'Whatever this "thing" is, it works against your character.',
    prompt: 'How does this hurt or hinder you?',
    examples: [
      'A mushroom with poisonous spores',
      'A door that\'s locked from the other side',
      'A witness who saw you at the scene',
    ],
  ),
  
  'Favors PC': DetailModifierGuidance(
    result: 'Favors PC',
    category: DetailModifierCategory.pc,
    isPositive: true,
    description: 'Whatever this "thing" is, it benefits your character.',
    prompt: 'How does this help or benefit you?',
    examples: [
      'A hidden passage that provides escape',
      'A document that proves your innocence',
      'A potion that\'s exactly what you needed',
    ],
  ),
  
  'Disfavors Thread': DetailModifierGuidance(
    result: 'Disfavors Thread',
    category: DetailModifierCategory.thread,
    isPositive: false,
    description: 'The "thing" has a detail that works against one of your active threads/quests.',
    prompt: 'Which thread does this hinder? How?',
    followUpRoll: 'Roll on your Thread list',
    examples: [
      'A letter reveals the enemy has already fled',
      'The key you needed was destroyed in the fire',
      'Your contact has switched sides',
    ],
  ),
  
  'Favors Thread': DetailModifierGuidance(
    result: 'Favors Thread',
    category: DetailModifierCategory.thread,
    isPositive: true,
    description: 'The "thing" has a detail that advances one of your active threads/quests.',
    prompt: 'Which thread does this advance? How?',
    followUpRoll: 'Roll on your Thread list',
    examples: [
      'A letter with a clue for finding the enemy',
      'A map showing the hidden entrance',
      'Evidence that confirms your suspicions',
    ],
  ),
  
  'Disfavors NPC': DetailModifierGuidance(
    result: 'Disfavors NPC',
    category: DetailModifierCategory.npc,
    isPositive: false,
    description: 'The "thing" has a detail that works against an NPC on your Character list.',
    prompt: 'Which NPC does this hurt? How?',
    followUpRoll: 'Roll on your Character list',
    examples: [
      'A complication that benefits your rival',
      'News that threatens an ally\'s position',
      'An object that reveals an NPC\'s secret',
    ],
  ),
  
  'Favors NPC': DetailModifierGuidance(
    result: 'Favors NPC',
    category: DetailModifierCategory.npc,
    isPositive: true,
    description: 'The "thing" has a detail that benefits an NPC on your Character list.',
    prompt: 'Which NPC does this help? How?',
    followUpRoll: 'Roll on your Character list',
    examples: [
      'Information that clears an ally\'s name',
      'Resources that strengthen a friend\'s position',
      'A development that aids someone\'s goals',
    ],
  ),
  
  'History': DetailModifierGuidance(
    result: 'History',
    category: DetailModifierCategory.followUp,
    isPositive: true, // Neutral, but marked true for display
    description: 'The "thing" connects to something from the past. Roll on the History table.',
    prompt: 'What past event does this connect to?',
    followUpRoll: 'Roll History (d10)',
    examples: [
      'This symbol appeared in a previous scene',
      'You recognize this from your backstory',
      'This relates to an earlier thread',
    ],
    skewNote: 'Advantage → More recent. Disadvantage → Further in the past.',
  ),
  
  'Property': DetailModifierGuidance(
    result: 'Property',
    category: DetailModifierCategory.followUp,
    isPositive: true, // Neutral, but marked true for display
    description: 'The "thing" has notable properties. Roll on the Property table.',
    prompt: 'What properties does this have?',
    followUpRoll: 'Roll Property (d10 + d6)',
    examples: [
      'Examine the object\'s Age, Durability, Value...',
      'Determine the NPC\'s Style, Power, Rarity...',
      'Describe the location\'s Size, Quality, Familiarity...',
    ],
  ),
};

/// Get guidance for a detail modifier result.
DetailModifierGuidance? getDetailGuidance(String result) {
  return detailModifierGuidance[result];
}

/// Check if a detail result requires guidance display.
bool detailNeedsGuidance(String result) {
  return detailModifierGuidance.containsKey(result);
}

/// Check if a detail result requires a follow-up roll.
bool detailRequiresFollowUp(String result) {
  final guidance = detailModifierGuidance[result];
  return guidance?.followUpRoll != null;
}

/// Check if a detail result is about emotions.
bool detailIsEmotion(String result) {
  final guidance = detailModifierGuidance[result];
  return guidance?.category == DetailModifierCategory.emotion;
}

/// Check if a detail result affects PC directly.
bool detailAffectsPC(String result) {
  final guidance = detailModifierGuidance[result];
  return guidance?.category == DetailModifierCategory.pc;
}

/// Check if a detail result affects a Thread.
bool detailAffectsThread(String result) {
  final guidance = detailModifierGuidance[result];
  return guidance?.category == DetailModifierCategory.thread;
}

/// Check if a detail result affects an NPC.
bool detailAffectsNPC(String result) {
  final guidance = detailModifierGuidance[result];
  return guidance?.category == DetailModifierCategory.npc;
}
