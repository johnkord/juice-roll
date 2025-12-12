import '../roll_result.dart';

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
    DateTime? timestamp,
  }) : super(
          type: RollType.encounter,
          description: 'Monster Encounter',
          diceResults: diceResults,
          total: row + 1,
          interpretation: _buildInterpretation(monsters, hasBoss, bossMonster),
          timestamp: timestamp,
          metadata: {
            'row': row,
            'difficulty': difficulty.name,
            'hasBoss': hasBoss,
            'bossMonster': bossMonster,
            'monsters': monsters.map((m) => {
              'name': m.name, 
              'count': m.count,
              'code': m.code,
              'skewSymbol': m.skewSymbol,
            }).toList(),
            'environmentRow': environmentRow,
            'environmentFormula': environmentFormula,
            'wasDoubles': wasDoubles,
            'isForest': isForest,
          },
        );

  @override
  String get className => 'FullMonsterEncounterResult';

  factory FullMonsterEncounterResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final monstersList = (meta['monsters'] as List<dynamic>)
        .map((m) => MonsterCount(
              name: (m as Map<String, dynamic>)['name'] as String,
              count: m['count'] as int,
              code: m['code'] as String? ?? '',
              skewSymbol: m['skewSymbol'] as String? ?? '',
            ))
        .toList();
    
    return FullMonsterEncounterResult(
      diceResults: (json['diceResults'] as List<dynamic>).cast<int>(),
      row: meta['row'] as int,
      difficulty: MonsterDifficulty.values.byName(meta['difficulty'] as String),
      hasBoss: meta['hasBoss'] as bool,
      bossMonster: meta['bossMonster'] as String?,
      monsters: monstersList,
      environmentRow: meta['environmentRow'] as int,
      environmentFormula: meta['environmentFormula'] as String,
      wasDoubles: meta['wasDoubles'] as bool,
      isForest: meta['isForest'] as bool? ?? false,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

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
    DateTime? timestamp,
  }) : super(
          type: RollType.encounter,
          description: 'Monster Encounter',
          diceResults: diceResults,
          total: row + 1,
          interpretation: _buildInterpretation(monster, isDeadly, wasDoubles),
          timestamp: timestamp,
          metadata: {
            'row': row,
            'difficulty': difficulty.name,
            'monster': monster,
            'isDeadly': isDeadly,
            'difficultyRoll': difficultyRoll,
            'wasDoubles': wasDoubles,
          },
        );

  @override
  String get className => 'MonsterEncounterResult';

  factory MonsterEncounterResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    return MonsterEncounterResult(
      diceResults: (json['diceResults'] as List<dynamic>).cast<int>(),
      row: meta['row'] as int,
      difficulty: MonsterDifficulty.values.byName(meta['difficulty'] as String),
      monster: meta['monster'] as String,
      isDeadly: meta['isDeadly'] as bool,
      difficultyRoll: meta['difficultyRoll'] as int?,
      wasDoubles: meta['wasDoubles'] as bool? ?? false,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

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
    DateTime? timestamp,
  }) : super(
          type: RollType.encounter,
          description: 'Monster Tracks',
          diceResults: diceResults,
          total: modifier,
          interpretation: '$tracks (modifier: $modifier)',
          timestamp: timestamp,
          metadata: {
            'row': row,
            'tracks': tracks,
            'modifier': modifier,
          },
        );

  @override
  String get className => 'MonsterTracksResult';

  factory MonsterTracksResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    return MonsterTracksResult(
      diceResults: (json['diceResults'] as List<dynamic>).cast<int>(),
      row: meta['row'] as int,
      tracks: meta['tracks'] as String,
      modifier: meta['modifier'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() => 'Tracks: $tracks (modifier: $modifier)';
}
