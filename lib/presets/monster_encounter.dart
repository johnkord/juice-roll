import '../core/roll_engine.dart';
import '../models/roll_result.dart';

/// Difficulty levels for monster encounters
enum MonsterDifficulty {
  easy,    // 1-4 on d10
  medium,  // 5-8 on d10
  hard,    // 9-0 on d10
  boss,    // Doubles only
}

/// Represents a single monster type with its count in an encounter
class MonsterCount {
  final String code;
  final String name;
  final int count;
  final String skewSymbol; // '+', '-', or ''

  MonsterCount({
    required this.code,
    required this.name,
    required this.count,
    required this.skewSymbol,
  });

  @override
  String toString() => count > 0 ? '$count× $name' : '0× $name (none)';
}

/// Result of a full monster encounter with counts
class FullMonsterEncounterResult extends RollResult {
  final int row;
  final MonsterDifficulty difficulty;
  final bool hasBoss;
  final String? bossMonster;
  final List<MonsterCount> monsters;
  final int environmentRow;
  final String environmentFormula;
  final bool wasDoubles;
  final bool isForest; // Special case: Forest uses Blights for row 6

  FullMonsterEncounterResult({
    required List<int> diceResults,
    required this.row,
    required this.difficulty,
    required this.hasBoss,
    this.bossMonster,
    required this.monsters,
    required this.environmentRow,
    required this.environmentFormula,
    required this.wasDoubles,
    this.isForest = false,
  }) : super(
          type: RollType.encounter,
          description: 'Monster Encounter',
          diceResults: diceResults,
          total: row + 1,
          interpretation: _buildInterpretation(monsters, hasBoss, bossMonster),
          metadata: {
            'row': row,
            'difficulty': difficulty.name,
            'hasBoss': hasBoss,
            'bossMonster': bossMonster,
            'monsters': monsters.map((m) => {'name': m.name, 'count': m.count}).toList(),
            'environmentRow': environmentRow,
            'environmentFormula': environmentFormula,
            'wasDoubles': wasDoubles,
            'isForest': isForest,
          },
        );

  static String _buildInterpretation(List<MonsterCount> monsters, bool hasBoss, String? bossMonster) {
    final parts = <String>[];
    if (hasBoss && bossMonster != null) {
      parts.add('1× $bossMonster (Boss)');
    }
    for (final m in monsters) {
      if (m.count > 0) {
        parts.add('${m.count}× ${m.name}');
      }
    }
    return parts.isEmpty ? 'No monsters' : parts.join(', ');
  }

  /// Get a formatted summary of the encounter
  String get encounterSummary {
    final parts = <String>[];
    if (hasBoss && bossMonster != null) {
      parts.add('1 $bossMonster (Boss)');
    }
    for (final m in monsters.where((m) => m.count > 0)) {
      parts.add('${m.count} ${m.name}');
    }
    return parts.isEmpty ? 'No monsters appeared' : parts.join('\n');
  }

  @override
  String toString() => 'Encounter: $encounterSummary';
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

  /// Environment-based monster formulas from the wilderness table
  /// Format: {'modifier': int, 'advantage': String} where advantage is '+', '-', or '0'
  static const List<Map<String, dynamic>> environmentFormulas = [
    {'modifier': 0, 'advantage': '-'},  // 1: Arctic +0@-
    {'modifier': 0, 'advantage': '0'},  // 2: Mountains +0@0
    {'modifier': 1, 'advantage': '-'},  // 3: Cavern +1@-
    {'modifier': 1, 'advantage': '0'},  // 4: Hills +1@0
    {'modifier': 3, 'advantage': '-'},  // 5: Grassland +3@-
    {'modifier': 2, 'advantage': '0'},  // 6: Forest +2@0 (special: row 6 = Blights)
    {'modifier': 3, 'advantage': '+'},  // 7: Swamp +3@+
    {'modifier': 3, 'advantage': '0'},  // 8: Water +3@0
    {'modifier': 4, 'advantage': '-'},  // 9: Coast +4@-
    {'modifier': 4, 'advantage': '+'},  // 10: Desert +4@+
  ];

  /// Environment names for display
  static const List<String> environmentNames = [
    'Arctic', 'Mountains', 'Cavern', 'Hills', 'Grassland',
    'Forest', 'Swamp', 'Water', 'Coast', 'Desert'
  ];

  /// Get the formula string for an environment
  static String getEnvironmentFormula(int environmentRow) {
    final idx = (environmentRow - 1).clamp(0, 9);
    final formula = environmentFormulas[idx];
    final mod = formula['modifier'] as int;
    final adv = formula['advantage'] as String;
    return '+$mod@$adv';
  }

  /// Roll for monster row based on environment formula
  /// Returns the row (0-11) on the monster table
  /// If doubles are rolled on 1d6, this is a Bandit encounter (row 11)
  static ({int row, List<int> dice, bool wasDoubles, bool isForest}) rollMonsterRowByEnvironment(int environmentRow) {
    final idx = (environmentRow - 1).clamp(0, 9);
    final formula = environmentFormulas[idx];
    final modifier = formula['modifier'] as int;
    final advantageType = formula['advantage'] as String;
    final isForest = environmentRow == 6;

    // Roll 1d6 or 2d6 depending on advantage
    int baseRoll;
    int? secondRoll;
    bool wasDoubles = false;

    if (advantageType == '+') {
      // Advantage: roll 2d6, take higher
      final die1 = _engine.rollDie(6);
      final die2 = _engine.rollDie(6);
      wasDoubles = die1 == die2;
      baseRoll = wasDoubles ? die1 : (die1 > die2 ? die1 : die2);
      secondRoll = die2;
    } else if (advantageType == '-') {
      // Disadvantage: roll 2d6, take lower
      final die1 = _engine.rollDie(6);
      final die2 = _engine.rollDie(6);
      wasDoubles = die1 == die2;
      baseRoll = wasDoubles ? die1 : (die1 < die2 ? die1 : die2);
      secondRoll = die2;
    } else {
      // Straight roll
      baseRoll = _engine.rollDie(6);
    }

    // If doubles, this is a Bandit encounter
    if (wasDoubles) {
      return (
        row: 11,  // ** row (Bandits)
        dice: secondRoll != null ? [baseRoll, secondRoll] : [baseRoll],
        wasDoubles: true,
        isForest: isForest,
      );
    }

    // Calculate the row: base + modifier, clamped to 1-10 (then converted to 0-9)
    final rawRow = baseRoll + modifier;
    int row = (rawRow).clamp(1, 10) - 1;  // Convert to 0-indexed

    // Special case: Forest environment and row 6 (index 5) = use Blights (* row)
    if (isForest && row == 5) {
      row = 10;  // * row (Blights)
    }

    return (
      row: row,
      dice: secondRoll != null ? [baseRoll, secondRoll] : [baseRoll],
      wasDoubles: false,
      isForest: isForest,
    );
  }

  /// Roll for the number of a specific monster type
  /// Uses 1d6-1 with advantage/disadvantage based on the monster's skew symbol
  /// Note: In Juice, "+" means advantage (take lower die = fewer monsters)
  /// and "-" means disadvantage (take higher die = more monsters).
  /// This is counterintuitive but matches the Juice instructions examples.
  static int rollMonsterCount(String skewSymbol) {
    int baseRoll;
    
    if (skewSymbol == '+') {
      // Advantage in Juice context: take LOWER die (results in fewer monsters)
      final result = _engine.rollWithDisadvantage(1, 6);  // Use disadvantage to take lower
      baseRoll = result.chosenSum;
    } else if (skewSymbol == '-') {
      // Disadvantage in Juice context: take HIGHER die (results in more monsters)
      final result = _engine.rollWithAdvantage(1, 6);  // Use advantage to take higher
      baseRoll = result.chosenSum;
    } else {
      // Straight roll
      baseRoll = _engine.rollDie(6);
    }
    
    // Result is 1d6-1, minimum 0
    return (baseRoll - 1).clamp(0, 5);
  }

  /// Generate a full monster encounter based on environment
  /// This follows the complete Juice procedure:
  /// 1. Roll for monster row using environment formula
  /// 2. Roll 2d10 for difficulty (doubles = boss)
  /// 3. Roll counts for each monster type included in the difficulty
  static FullMonsterEncounterResult generateFullEncounter(int environmentRow) {
    List<int> allDice = [];
    
    // Step 1: Roll for monster row
    final rowResult = rollMonsterRowByEnvironment(environmentRow);
    allDice.addAll(rowResult.dice);
    final row = rowResult.row;
    final monsterRowDoubles = rowResult.wasDoubles;
    final isForest = rowResult.isForest;
    
    // Step 2: Roll 2d10 for difficulty
    final diffDie1 = _engine.rollDie(10);
    final diffDie2 = _engine.rollDie(10);
    allDice.addAll([diffDie1, diffDie2]);
    
    final wasDoubles = diffDie1 == diffDie2;
    final diffRoll = diffDie1;
    
    MonsterDifficulty difficulty;
    if (wasDoubles) {
      difficulty = MonsterDifficulty.boss;
    } else if (diffRoll >= 1 && diffRoll <= 4) {
      difficulty = MonsterDifficulty.easy;
    } else if (diffRoll >= 5 && diffRoll <= 8) {
      difficulty = MonsterDifficulty.medium;
    } else {
      difficulty = MonsterDifficulty.hard;
    }
    
    // Step 3: Determine which monsters are in this encounter
    // Include all columns up to and including the difficulty column
    final maxColumn = _difficultyToColumn(difficulty);
    final hasBoss = wasDoubles;
    String? bossMonster;
    
    if (hasBoss) {
      final bossCode = monsterTable[row][4]; // Boss column
      bossMonster = monsterFullNames[bossCode] ?? bossCode;
    }
    
    // Roll counts for each monster type (columns 1-3 based on difficulty)
    final monsters = <MonsterCount>[];
    for (int col = 1; col <= maxColumn.clamp(1, 3); col++) {
      final monsterCode = monsterTable[row][col];
      final monsterName = monsterFullNames[monsterCode] ?? monsterCode;
      
      // Get skew symbol from the monster code
      String skewSymbol = '';
      if (monsterCode.startsWith('+ ')) {
        skewSymbol = '+';
      } else if (monsterCode.startsWith('- ')) {
        skewSymbol = '-';
      }
      
      final count = rollMonsterCount(skewSymbol);
      monsters.add(MonsterCount(
        code: monsterCode,
        name: monsterName,
        count: count,
        skewSymbol: skewSymbol,
      ));
    }
    
    return FullMonsterEncounterResult(
      diceResults: allDice,
      row: row,
      difficulty: difficulty,
      hasBoss: hasBoss,
      bossMonster: bossMonster,
      monsters: monsters,
      environmentRow: environmentRow,
      environmentFormula: getEnvironmentFormula(environmentRow),
      wasDoubles: wasDoubles || monsterRowDoubles,
      isForest: isForest,
    );
  }
}
