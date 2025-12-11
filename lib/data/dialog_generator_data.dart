/// Static data tables for the Dialog Generator preset.
/// 
/// The Dialog Grid is a 5x5 grid-based mini-game for generating NPC conversations.
library;

/// The 5x5 Dialog Grid
/// Row 0-1: Past tense (italics in pocketfold)
/// Row 2-4: Present tense
/// Center (2,2): "Fact" - starting position
const List<List<String>> grid = [
  // Row 0 (Past)
  ['Fact', 'Denial', 'Query', 'Denial', 'Action'],
  // Row 1 (Past)
  ['Want', 'Query', 'Need', 'Query', 'Fact'],
  // Row 2 (Present) - Center row
  ['Action', 'Need', 'Fact', 'Action', 'Denial'],
  // Row 3 (Present)
  ['Need', 'Query', 'Denial', 'Query', 'Want'],
  // Row 4 (Present)
  ['Query', 'Support', 'Query', 'Support', 'Need'],
];

/// Dialog fragment descriptions for each type
const Map<String, String> fragmentDescriptions = {
  'Fact': 'NPC states a fact or observation',
  'Query': 'NPC asks a question',
  'Need': 'NPC expresses a need or requirement',
  'Want': 'NPC expresses a desire or wish',
  'Action': 'NPC describes or suggests an action',
  'Denial': 'NPC denies, refuses, or disagrees',
  'Support': 'NPC offers support or agreement',
};
