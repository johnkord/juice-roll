import '../core/roll_engine.dart';
import '../models/roll_result.dart';

/// Difficulty levels for monster encounters
enum MonsterDifficulty {
  easy,    // 1-4 on d10
  medium,  // 5-8 on d10
  hard,    // 9-0 on d10
  boss,    // Doubles only
}

/// Result of a monster encounter roll
class MonsterEncounterResult extends RollResult {
  final int row;                    // 0-11 (0-9 plus * and **)
  final MonsterDifficulty difficulty;
  final String monster;
  final bool isDeadly;              // 💀 indicator
  final int? difficultyRoll;        // The d10 roll that determined difficulty
  final bool wasDoubles;            // If doubles were rolled for boss

  MonsterEncounterResult({
    required List<int> diceResults,
    required this.row,
    required this.difficulty,
    required this.monster,
    required this.isDeadly,
    this.difficultyRoll,
    this.wasDoubles = false,
  }) : super(
          type: RollType.encounter,
          description: 'Monster Encounter',
          diceResults: diceResults,
          total: row + 1,
          interpretation: _buildInterpretation(monster, isDeadly, wasDoubles),
          metadata: {
            'row': row,
            'difficulty': difficulty.name,
            'monster': monster,
            'isDeadly': isDeadly,
            'wasDoubles': wasDoubles,
          },
        );

  static String _buildInterpretation(String monster, bool isDeadly, bool wasDoubles) {
    final deadlyMarker = isDeadly ? ' 💀' : '';
    final doublesMarker = wasDoubles ? ' (Doubles!)' : '';
    return '$monster$deadlyMarker$doublesMarker';
  }

  @override
  String toString() => 'Monster: $monster${isDeadly ? ' 💀' : ''}${wasDoubles ? ' (Doubles!)' : ''}';
}

/// Result of a monster tracks roll
class MonsterTracksResult extends RollResult {
  final int row;
  final String tracks;
  final int modifier;  // From the 1d6-1@ roll

  MonsterTracksResult({
    required List<int> diceResults,
    required this.row,
    required this.tracks,
    required this.modifier,
  }) : super(
          type: RollType.encounter,
          description: 'Monster Tracks',
          diceResults: diceResults,
          total: modifier,
          interpretation: '$tracks (modifier: $modifier)',
          metadata: {
            'row': row,
            'tracks': tracks,
            'modifier': modifier,
          },
        );

  @override
  String toString() => 'Tracks: $tracks (modifier: $modifier)';
}

/// Monster encounter tables from wilderness exploration
class MonsterEncounter {
  static final RollEngine _engine = RollEngine();

  /// Monster table rows (index 0-11)
  /// Rows 0-9 are standard, 10 is *, 11 is **
  /// Each entry: [Tracks, Easy, Medium, Hard, Boss]
  /// + prefix = half CR, - prefix = double CR
  static const List<List<String>> monsterTable = [
    // Row 1 (index 0)
    ['+ Wolf', '- Ice Mephit', '- Winter Wolf', 'Yeti', 'Werebear'],
    // Row 2 (index 1)
    ['+ Skeleton', '- Warhorse S', '- Wight', '- Nightmare', 'Wraith'],
    // Row 3 (index 2)
    ['+ Drow', '- G Spider', '- Quaggoth', '- Phase Spider', 'Drider'],
    // Row 4 (index 3)
    ['+ Goblin', '- Worg', '+ Hobgoblin', '+ Bugbear', 'Hob C'],
    // Row 5 (index 4)
    ['Orc', '- Orog', 'Orc EoG', '- Troll', 'Orc WC'],
    // Row 6* (index 5)
    ['Kobold', '+ G Weasel', '+ W Kobold', '+ Stirge', 'Y Dragon'],
    // Row 7 (index 6)
    ['Lizardfolk', 'G Lizard', 'L Shaman', '- G Crocodile', 'L King'],
    // Row 8 (index 7)
    ['+ Zombie', 'Ghoul', '- Mummy', 'Ogre Z', 'V Spawn'],
    // Row 9 (index 8)
    ['Yuan-ti PB', '- Cockatrice', '- Yuan-ti M', 'Basilisk', 'Medusa'],
    // Row 0 (index 9)
    ['Gnoll', '- G Hyena', 'Gnoll PL', '+ Jackalwere', 'Lamia'],
    // Row * (index 10)
    ['+ T Blight', '+ N Blight', '+ V Blight', '- S Mound', 'G Hag'],
    // Row ** (index 11)
    ['+ Bandit', 'Thug', 'Scout', '- Veteran', 'Bandit C'],
  ];

  /// Full monster names for display
  static const Map<String, String> monsterFullNames = {
    '+ Wolf': 'Wolf (½ CR)',
    '- Ice Mephit': 'Ice Mephit (2× CR)',
    '- Winter Wolf': 'Winter Wolf (2× CR)',
    'Yeti': 'Yeti',
    'Werebear': 'Werebear',
    '+ Skeleton': 'Skeleton (½ CR)',
    '- Warhorse S': 'Warhorse Skeleton (2× CR)',
    '- Wight': 'Wight (2× CR)',
    '- Nightmare': 'Nightmare (2× CR)',
    'Wraith': 'Wraith',
    '+ Drow': 'Drow (½ CR)',
    '- G Spider': 'Giant Spider (2× CR)',
    '- Quaggoth': 'Quaggoth (2× CR)',
    '- Phase Spider': 'Phase Spider (2× CR)',
    'Drider': 'Drider',
    '+ Goblin': 'Goblin (½ CR)',
    '- Worg': 'Worg (2× CR)',
    '+ Hobgoblin': 'Hobgoblin (½ CR)',
    '+ Bugbear': 'Bugbear (½ CR)',
    'Hob C': 'Hobgoblin Captain',
    'Orc': 'Orc',
    '- Orog': 'Orog (2× CR)',
    'Orc EoG': 'Orc Eye of Gruumsh',
    '- Troll': 'Troll (2× CR)',
    'Orc WC': 'Orc War Chief',
    'Kobold': 'Kobold',
    '+ G Weasel': 'Giant Weasel (½ CR)',
    '+ W Kobold': 'Winged Kobold (½ CR)',
    '+ Stirge': 'Stirge (½ CR)',
    'Y Dragon': 'Young Dragon',
    'Lizardfolk': 'Lizardfolk',
    'G Lizard': 'Giant Lizard',
    'L Shaman': 'Lizardfolk Shaman',
    '- G Crocodile': 'Giant Crocodile (2× CR)',
    'L King': 'Lizard King',
    '+ Zombie': 'Zombie (½ CR)',
    'Ghoul': 'Ghoul',
    '- Mummy': 'Mummy (2× CR)',
    'Ogre Z': 'Ogre Zombie',
    'V Spawn': 'Vampire Spawn',
    'Yuan-ti PB': 'Yuan-ti Pureblood',
    '- Cockatrice': 'Cockatrice (2× CR)',
    '- Yuan-ti M': 'Yuan-ti Malison (2× CR)',
    'Basilisk': 'Basilisk',
    'Medusa': 'Medusa',
    'Gnoll': 'Gnoll',
    '- G Hyena': 'Giant Hyena (2× CR)',
    'Gnoll PL': 'Gnoll Pack Lord',
    '+ Jackalwere': 'Jackalwere (½ CR)',
    'Lamia': 'Lamia',
    '+ T Blight': 'Twig Blight (½ CR)',
    '+ N Blight': 'Needle Blight (½ CR)',
    '+ V Blight': 'Vine Blight (½ CR)',
    '- S Mound': 'Shambling Mound (2× CR)',
    'G Hag': 'Green Hag',
    '+ Bandit': 'Bandit (½ CR)',
    'Thug': 'Thug',
    'Scout': 'Scout',
    '- Veteran': 'Veteran (2× CR)',
    'Bandit C': 'Bandit Captain',
  };

  /// Roll for monster tracks (1d6-1@ with disadvantage)
  /// Returns the tracks found and a modifier for the encounter
  static MonsterTracksResult rollTracks({int? row}) {
    // Roll 1d6-1 for modifier
    final tracksRolls = _engine.rollDice(1, 6);
    final modifier = tracksRolls[0] - 1;
    
    List<int> allDice = List.from(tracksRolls);

    // Roll for row if not specified (using d10 with disadvantage)
    int actualRow;
    if (row != null) {
      actualRow = row.clamp(0, 11);
    } else {
      // Roll d10 with disadvantage (@-)
      final rowRoll = _engine.rollWithDisadvantage(1, 10);
      actualRow = rowRoll.chosenSum == 10 ? 9 : rowRoll.chosenSum - 1;
      allDice.addAll([rowRoll.sum1, rowRoll.sum2]);
    }

    final tracksCode = monsterTable[actualRow][0];  // Column 0 is tracks
    final tracksName = monsterFullNames[tracksCode] ?? tracksCode;

    return MonsterTracksResult(
      diceResults: allDice,
      row: actualRow,
      tracks: tracksName,
      modifier: modifier,
    );
  }

  /// Roll for a monster encounter
  /// Rolls 2d10 for row and difficulty, doubles = boss
  static MonsterEncounterResult rollEncounter({int? forcedRow, MonsterDifficulty? forcedDifficulty}) {
    List<int> allDice = [];
    int row;
    MonsterDifficulty difficulty;
    bool wasDoubles = false;
    int? difficultyRollValue;

    if (forcedRow != null && forcedDifficulty != null) {
      row = forcedRow.clamp(0, 11);
      difficulty = forcedDifficulty;
    } else {
      // Roll 2d10 for row and difficulty
      final die1 = _engine.rollDie(10);
      final die2 = _engine.rollDie(10);
      allDice = [die1, die2];

      final rowRoll = die1;
      final diffRoll = die2;
      difficultyRollValue = diffRoll;

      // Check for doubles (boss encounter)
      wasDoubles = rowRoll == diffRoll;

      // Convert row roll (1-10 becomes 0-9, where 10=0)
      row = forcedRow ?? (rowRoll == 10 ? 9 : rowRoll - 1);

      // Determine difficulty
      if (wasDoubles) {
        difficulty = MonsterDifficulty.boss;
      } else if (forcedDifficulty != null) {
        difficulty = forcedDifficulty;
      } else if (diffRoll >= 1 && diffRoll <= 4) {
        difficulty = MonsterDifficulty.easy;
      } else if (diffRoll >= 5 && diffRoll <= 8) {
        difficulty = MonsterDifficulty.medium;
      } else {
        difficulty = MonsterDifficulty.hard;
      }
    }

    // Get monster from table
    final columnIndex = _difficultyToColumn(difficulty);
    final monsterCode = monsterTable[row][columnIndex];
    final monsterName = monsterFullNames[monsterCode] ?? monsterCode;

    // Determine if deadly (has - prefix = 2× CR, or boss)
    final isDeadly = monsterCode.startsWith('-') || difficulty == MonsterDifficulty.boss;

    return MonsterEncounterResult(
      diceResults: allDice,
      row: row,
      difficulty: difficulty,
      monster: monsterName,
      isDeadly: isDeadly,
      difficultyRoll: difficultyRollValue,
      wasDoubles: wasDoubles,
    );
  }

  /// Roll for a specific row with specified difficulty
  static MonsterEncounterResult getMonster(int row, MonsterDifficulty difficulty) {
    final clampedRow = row.clamp(0, 11);
    final columnIndex = _difficultyToColumn(difficulty);
    final monsterCode = monsterTable[clampedRow][columnIndex];
    final monsterName = monsterFullNames[monsterCode] ?? monsterCode;
    final isDeadly = monsterCode.startsWith('-') || difficulty == MonsterDifficulty.boss;

    return MonsterEncounterResult(
      diceResults: [],
      row: clampedRow,
      difficulty: difficulty,
      monster: monsterName,
      isDeadly: isDeadly,
    );
  }

  /// Roll for special rows (* or **)
  /// Row 10 = * (nature/plants), Row 11 = ** (humanoids)
  static MonsterEncounterResult rollSpecialRow({bool humanoid = false, MonsterDifficulty? difficulty}) {
    final row = humanoid ? 11 : 10;
    
    if (difficulty != null) {
      return getMonster(row, difficulty);
    }

    // Roll for difficulty
    final diffRoll = _engine.rollDie(10);
    MonsterDifficulty actualDifficulty;
    
    if (diffRoll >= 1 && diffRoll <= 4) {
      actualDifficulty = MonsterDifficulty.easy;
    } else if (diffRoll >= 5 && diffRoll <= 8) {
      actualDifficulty = MonsterDifficulty.medium;
    } else {
      actualDifficulty = MonsterDifficulty.hard;
    }

    final columnIndex = _difficultyToColumn(actualDifficulty);
    final monsterCode = monsterTable[row][columnIndex];
    final monsterName = monsterFullNames[monsterCode] ?? monsterCode;
    final isDeadly = monsterCode.startsWith('-');

    return MonsterEncounterResult(
      diceResults: [diffRoll],
      row: row,
      difficulty: actualDifficulty,
      monster: monsterName,
      isDeadly: isDeadly,
      difficultyRoll: diffRoll,
    );
  }

  /// Convert difficulty enum to table column index
  static int _difficultyToColumn(MonsterDifficulty difficulty) {
    switch (difficulty) {
      case MonsterDifficulty.easy:
        return 1;
      case MonsterDifficulty.medium:
        return 2;
      case MonsterDifficulty.hard:
        return 3;
      case MonsterDifficulty.boss:
        return 4;
    }
  }

  /// Get display name for difficulty
  static String difficultyName(MonsterDifficulty difficulty) {
    switch (difficulty) {
      case MonsterDifficulty.easy:
        return 'Easy (1-4)';
      case MonsterDifficulty.medium:
        return 'Medium (5-8)';
      case MonsterDifficulty.hard:
        return 'Hard (9-0)';
      case MonsterDifficulty.boss:
        return 'Boss (Doubles)';
    }
  }

  /// Deadly encounter formula explanation
  static const String deadlyFormula = '💀: ∑CR>∑Lvl/(Lvl>4?2:4), Any CR>Lvl';
  static const String deadlyExplanation = 
    'Deadly if: Total CR > Total Level ÷ (2 if level > 4, else 4), or any single CR > Level';
}
