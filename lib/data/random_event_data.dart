/// Static table data for Random Event generator.
/// Extracted from random_event.dart to separate data from logic.
/// 
/// Reference: random-event-challenge.md and random-tables.md
library;

/// Event focus types - d10 (from random-event-challenge.md)
const List<String> eventFocusTypes = [
  'Advance Time',    // 1
  'Close Thread',    // 2
  'Converge Thread', // 3
  'Diverge Thread',  // 4
  'Immersion',       // 5
  'Keyed Event',     // 6
  'New Character',   // 7
  'NPC Action',      // 8
  'Plot Armor',      // 9
  'Remote Event',    // 0/10
];

/// Descriptions for each event focus type.
/// These provide guidance on how to interpret and use each result.
/// Reference: Juice Oracle instructions - Random Event section.
const Map<String, String> eventFocusDescriptions = {
  'Advance Time': 
    'Time in-game has advanced. Day turns to night, seasons change, '
    'guards change patrol, rituals complete. Do bookkeeping: roll weather, '
    'check torches, eat rations. If in a settlement, roll News.',
  'Close Thread': 
    'Roll on your thread list. That thread has ended without your intervention. '
    'Determine WHY it ended and what it means for the story, then remove it.',
  'Converge Thread': 
    'Roll on your thread list. Something moves you closer to that thread, '
    'intertwining with your current storyline. What connection was just revealed?',
  'Diverge Thread': 
    'Roll on your thread list. Something moves you away from that thread. '
    'If current thread: perhaps it splits into two. What obstacle or distraction appeared?',
  'Immersion': 
    'Roll on the Immersion table and incorporate the sensory details '
    'into what is currently happening. What do you see, hear, smell, or feel?',
  'Keyed Event': 
    'Something you WANT to happen, happens! Check your Keyed Event list. '
    'No keyed events prepared? Roll a Plot Point instead.',
  'New Character': 
    'A new NPC is present in the scene. Roll on NPC and Name tables, '
    'add to your character list. Could be person, creature, or important item.',
  'NPC Action': 
    'Roll on your Character list. That NPC performs an action. '
    'If not present: flashback, scene change, or default to your companion.',
  'Plot Armor': 
    '✨ Whatever issue you are dealing with is SOLVED. ✨ This is your lifeline '
    'in an unforgiving world. No follow-up needed—accept this gift!',
  'Remote Event': 
    'Something happens in a far away place that you don\'t yet know about. '
    'Roll Locations list or Location Grid. Add to News for next Settlement visit.',
};

/// Suggested follow-up actions for each event focus type.
/// Maps focus name to a list of suggested actions with their labels.
const Map<String, List<EventFocusAction>> eventFocusActions = {
  'Advance Time': [
    EventFocusAction('weather', 'Roll Weather', 'Update conditions'),
    EventFocusAction('news', 'Roll News', 'If in settlement'),
  ],
  'Close Thread': [
    EventFocusAction('threadList', 'Roll on Thread List', 'Which thread ends'),
    EventFocusAction('discoverMeaning', 'Discover Meaning', 'Why did it end?'),
  ],
  'Converge Thread': [
    EventFocusAction('threadList', 'Roll on Thread List', 'Which thread converges'),
    EventFocusAction('discoverMeaning', 'Discover Meaning', 'How are they connected?'),
  ],
  'Diverge Thread': [
    EventFocusAction('threadList', 'Roll on Thread List', 'Which thread diverges'),
    EventFocusAction('discoverMeaning', 'Discover Meaning', 'What causes the split?'),
  ],
  'Immersion': [
    EventFocusAction('immersion', 'Roll Immersion', 'Sensory detail'),
  ],
  'Keyed Event': [
    EventFocusAction('keyedEventList', 'Check Keyed Events', 'Your prepared events'),
    EventFocusAction('plotPoint', 'Roll Plot Point', 'Fallback if no keyed events'),
  ],
  'New Character': [
    EventFocusAction('npc', 'Generate NPC', 'Roll on NPC tables'),
    EventFocusAction('name', 'Generate Name', 'Roll 3d20'),
  ],
  'NPC Action': [
    EventFocusAction('characterList', 'Roll on Character List', 'Which NPC acts'),
    EventFocusAction('npcAction', 'NPC Action', 'What they do'),
    EventFocusAction('companion', 'Use Companion', 'If NPC not present'),
  ],
  'Plot Armor': [], // No follow-up needed - the problem is solved!
  'Remote Event': [
    EventFocusAction('locationList', 'Roll on Location List', 'Where it happens'),
    EventFocusAction('locationGrid', 'Location Grid', 'Alternative if no list'),
    EventFocusAction('discoverMeaning', 'Discover Meaning', 'What happened there?'),
  ],
};

/// Represents a suggested follow-up action for an event focus.
class EventFocusAction {
  final String id;
  final String label;
  final String hint;
  
  const EventFocusAction(this.id, this.label, this.hint);
}

/// Guidance for interpreting Modifier + Idea results.
/// This is used in "Simple Mode" as an alternative to the Random Event Focus table.
/// Reference: Juice instructions - "Pro Tip: When you roll a Random Event in this mode, 
/// use the 'Modifier + Idea' tables to see what happens."
const String modifierIdeaGuidance = 
  'Use this result to alter the current scene or determine what happens next. '
  'Interpret the pairing creatively based on your current context.';

/// Category descriptions for Idea results.
/// These help users understand what each category represents.
const Map<String, String> ideaCategoryDescriptions = {
  'Idea': 'Abstract concepts—things to think about, motivations, or intangible elements.',
  'Event': 'Something that happens—plot triggers, occurrences, or changes in the story.',
  'Person': 'An NPC archetype—consider rolling on the NPC tables for more detail.',
  'Object': 'A symbolic item—could be literal or represent something thematically.',
};

/// Category probabilities for reference (d10 ranges).
const Map<String, String> ideaCategoryRanges = {
  'Idea': '1-3 (30%)',
  'Event': '4-6 (30%)',
  'Person': '7-8 (20%)',
  'Object': '9-0 (20%)',
};

/// Example keyed events from the Juice instructions.
/// Used as inspiration when the user hasn't prepared any.
const List<String> keyedEventExamples = [
  'Random Zombie Attack',
  'The BBEG appears',
  'Earthquake!',
  'The Ritual is Complete',
];

/// Extended guidance for specific event focuses.
/// These provide deeper context beyond the basic description.
const Map<String, String> eventFocusExtendedGuidance = {
  'Immersion':
    'Roll for a sense (See, Hear, Smell, Feel), a location (behind, in front, etc.), '
    'and optionally "what it causes" from the Emotion table. '
    'The darker emotions often present more interesting situations to overcome.',
  'Keyed Event':
    'Think of it like a timer—things you want to happen eventually. '
    'Examples: "Random Zombie Attack", "The BBEG appears", "Earthquake!"',
  'NPC Action':
    'The NPC should act on their own—they aren\'t sitting around idle. '
    'Consider their personality, needs, and motives from the NPC tables.',
  'Close Thread':
    'New threads will naturally form through play. It\'s only natural for threads '
    'to end without your intervention as time passes.',
  'Remote Event':
    'The rest of the world is still progressing forward. This event may become '
    'known or relevant later—track it for future News rolls.',
};

/// Modifier words - d10 (from random-tables.md)
const List<String> modifierWords = [
  'Change',     // 1
  'Continue',   // 2
  'Decrease',   // 3
  'Extra',      // 4
  'Increase',   // 5
  'Mundane',    // 6
  'Mysterious', // 7
  'Start',      // 8
  'Stop',       // 9
  'Strange',    // 0/10
];

/// Idea words (1-3) - d10
const List<String> ideaWords = [
  'Attention',     // 1
  'Communication', // 2
  'Danger',        // 3
  'Element',       // 4
  'Food',          // 5
  'Home',          // 6
  'Resource',      // 7
  'Rumor',         // 8
  'Secret',        // 9
  'Vow',           // 0/10
];

/// Event words (4-6) - d10
const List<String> eventWords = [
  'Ambush',    // 1
  'Anomaly',   // 2
  'Blessing',  // 3
  'Caravan',   // 4
  'Curse',     // 5
  'Discovery', // 6
  'Escape',    // 7
  'Journey',   // 8
  'Prophecy',  // 9
  'Ritual',    // 0/10
];

/// Person words (7-8) - d10
const List<String> personWords = [
  'Criminal',    // 1
  'Entertainer', // 2
  'Expert',      // 3
  'Mage',        // 4
  'Mercenary',   // 5
  'Noble',       // 6
  'Priest',      // 7
  'Ranger',      // 8
  'Soldier',     // 9
  'Transporter', // 0/10
];

/// Object words (9-0) - d10
const List<String> objectWords = [
  'Arrow',     // 1
  'Candle',    // 2
  'Cauldron',  // 3
  'Chain',     // 4
  'Claw',      // 5
  'Hook',      // 6
  'Hourglass', // 7
  'Quill',     // 8
  'Rose',      // 9
  'Skull',     // 0/10
];
