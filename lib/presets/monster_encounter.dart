import '../core/roll_engine.dart';
import '../data/monster_encounter_data.dart' as data;

// Re-export result classes for backward compatibility
export '../models/results/monster_encounter_result.dart';

import '../models/results/monster_encounter_result.dart';

/// Monster encounter tables from wilderness exploration
/// 
/// **Data Separation:**
/// Static table data is stored in data/monster_encounter_data.dart.
/// This class provides backward-compatible static accessors.
class MonsterEncounter {
  static final RollEngine _engine = RollEngine();

  // ========== Static Accessors (delegate to data file) ==========

  /// Monster table rows (index 0-11)
  /// Rows 0-9 are standard, 10 is *, 11 is **
  /// Each entry: [Tracks, Easy, Medium, Hard, Boss]
  /// + prefix = half CR, - prefix = double CR
  static List<List<String>> get monsterTable => data.monsterTable;

  /// Full monster names for display
  static Map<String, String> get monsterFullNames => data.monsterFullNames;

  /// Environment-based monster formulas from the wilderness table
  /// Format: {'modifier': int, 'advantage': String} where advantage is '+', '-', or '0'
  static List<Map<String, dynamic>> get environmentFormulas => data.environmentFormulas;

  /// Environment names for display
  static List<String> get environmentNames => data.environmentNames;

  /// Roll for monster tracks (1d6-1@ with disadvantage)
  /// Returns the tracks found and a modifier for the encounter
  static MonsterTracksResult rollTracks({int? row}) {
    // Roll 1d6-1 for modifier
    final tracksRolls = _engine.rollDice(1, 6);
    final modifier = tracksRolls[0] - 1;
    
    final List<int> allDice = List.from(tracksRolls);

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
    final List<int> allDice = [];
    
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
