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
    'check torches, eat rations.',
  'Close Thread': 
    'Roll on your thread list. That thread has ended. Determine why '
    'and what it means going forward, then remove it from the list.',
  'Converge Thread': 
    'Roll on your thread list. Something moves you closer to that thread, '
    'potentially joining and intertwining with your current storyline.',
  'Diverge Thread': 
    'Roll on your thread list. Something moves you away from that thread. '
    'If current thread: perhaps it splits into two separate threads.',
  'Immersion': 
    'Roll on the Immersion table and incorporate the sensory details '
    'into what is currently happening. Stay present in your character.',
  'Keyed Event': 
    'Something you WANT to happen, happens. Roll on your Keyed Event list, '
    'or roll a Plot Point if you have no keyed events prepared.',
  'New Character': 
    'A new NPC is present in the scene. Roll on NPC and Name tables, '
    'add to your character list. Could be person, creature, or important item.',
  'NPC Action': 
    'Roll on your Character list. That NPC performs an action. '
    'Use flashback, scene change, or default to your companion if not present.',
  'Plot Armor': 
    'Whatever issue you are dealing with is solved. This is your lifeline '
    'in an otherwise unforgiving world. Accept this gift gracefully.',
  'Remote Event': 
    'Something happens in a far away place. Roll on your Locations list '
    'or Location Grid. Incorporate into News next time in a Settlement.',
};

/// Suggested follow-up actions for each event focus type.
/// Maps focus name to a list of suggested actions with their labels.
const Map<String, List<EventFocusAction>> eventFocusActions = {
  'Advance Time': [
    EventFocusAction('weather', 'Roll Weather', 'Update conditions'),
  ],
  'Close Thread': [
    EventFocusAction('threadList', 'Roll on Thread List', 'Which thread ends'),
  ],
  'Converge Thread': [
    EventFocusAction('threadList', 'Roll on Thread List', 'Which thread converges'),
  ],
  'Diverge Thread': [
    EventFocusAction('threadList', 'Roll on Thread List', 'Which thread diverges'),
  ],
  'Immersion': [
    EventFocusAction('immersion', 'Roll Immersion', 'Sensory detail'),
  ],
  'Keyed Event': [
    EventFocusAction('plotPoint', 'Roll Plot Point', 'If no keyed events'),
  ],
  'New Character': [
    EventFocusAction('npc', 'Generate NPC', 'Roll on NPC tables'),
    EventFocusAction('name', 'Generate Name', 'Roll 3d20'),
  ],
  'NPC Action': [
    EventFocusAction('characterList', 'Roll on Character List', 'Which NPC acts'),
    EventFocusAction('npcAction', 'NPC Action', 'What they do'),
  ],
  'Plot Armor': [], // No follow-up needed - the problem is solved!
  'Remote Event': [
    EventFocusAction('locationList', 'Roll on Location List', 'Where it happens'),
  ],
};

/// Represents a suggested follow-up action for an event focus.
class EventFocusAction {
  final String id;
  final String label;
  final String hint;
  
  const EventFocusAction(this.id, this.label, this.hint);
}

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
