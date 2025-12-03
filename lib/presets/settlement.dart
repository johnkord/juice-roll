import '../core/roll_engine.dart';
import '../models/roll_result.dart';

/// Settlement generator preset for the Juice Oracle.
/// Uses settlement.md for generating settlement details.
class Settlement {
  final RollEngine _rollEngine;

  /// Name prefixes - d10
  static const List<String> namePrefixes = [
    'Frost',  // 1
    'High',   // 2
    'Long',   // 3
    'Lost',   // 4
    'Raven',  // 5
    'Shield', // 6
    'Storm',  // 7
    'Sword',  // 8
    'Thorn',  // 9
    'Wolf',   // 0/10
  ];

  /// Name suffixes - d10
  static const List<String> nameSuffixes = [
    'Barrow', // 1
    'Brook',  // 2
    'Fall',   // 3
    'Haven',  // 4
    'Ridge',  // 5
    'River',  // 6
    'Rock',   // 7
    'Stead',  // 8
    'Stone',  // 9
    'Wood',   // 0/10
  ];

  /// Establishments - d10
  static const List<String> establishments = [
    'Stable',        // 1
    'Tavern',        // 2
    'Inn',           // 3
    'Entertainment', // 4
    'General Store', // 5
    'Artisan',       // 6 (roll on artisan table)
    'Courier',       // 7
    'Temple',        // 8
    'Guild Hall',    // 9
    'Magic Shop',    // 0/10
  ];

  /// Artisans - d10
  static const List<String> artisans = [
    'Artist',     // 1
    'Baker',      // 2
    'Tailor',     // 3
    'Tanner',     // 4
    'Archer',     // 5
    'Blacksmith', // 6
    'Carpenter',  // 7
    'Apothecary', // 8
    'Jeweler',    // 9
    'Scribe',     // 0/10
  ];

  /// News/Events - d10
  static const List<String> news = [
    'War',              // 1
    'Sickness',         // 2
    'Natural Disaster', // 3
    'Crime',            // 4
    'Succession',       // 5
    'Remote Event',     // 6
    'Arrival',          // 7
    'Mail',             // 8
    'Sale',             // 9
    'Celebration',      // 0/10
  ];

  Settlement([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  /// Generate a settlement name.
  SettlementNameResult generateName() {
    final prefixRoll = _rollEngine.rollDie(10);
    final suffixRoll = _rollEngine.rollDie(10);

    final prefix = namePrefixes[prefixRoll == 10 ? 9 : prefixRoll - 1];
    final suffix = nameSuffixes[suffixRoll == 10 ? 9 : suffixRoll - 1];

    return SettlementNameResult(
      prefixRoll: prefixRoll,
      prefix: prefix,
      suffixRoll: suffixRoll,
      suffix: suffix,
    );
  }

  /// Roll for an establishment.
  SettlementDetailResult rollEstablishment() {
    final roll = _rollEngine.rollDie(10);
    final index = roll == 10 ? 9 : roll - 1;
    var establishment = establishments[index];

    // If artisan, roll on artisan table
    String? artisan;
    int? artisanRoll;
    if (establishment == 'Artisan') {
      artisanRoll = _rollEngine.rollDie(10);
      final artisanIndex = artisanRoll == 10 ? 9 : artisanRoll - 1;
      artisan = artisans[artisanIndex];
      establishment = '$artisan Shop';
    }

    return SettlementDetailResult(
      detailType: 'Establishment',
      roll: roll,
      result: establishment,
      subRoll: artisanRoll,
      subResult: artisan,
    );
  }

  /// Roll for an artisan.
  SettlementDetailResult rollArtisan() {
    final roll = _rollEngine.rollDie(10);
    final index = roll == 10 ? 9 : roll - 1;
    final artisan = artisans[index];

    return SettlementDetailResult(
      detailType: 'Artisan',
      roll: roll,
      result: artisan,
    );
  }

  /// Roll for settlement news.
  SettlementDetailResult rollNews() {
    final roll = _rollEngine.rollDie(10);
    final index = roll == 10 ? 9 : roll - 1;
    final newsItem = news[index];

    return SettlementDetailResult(
      detailType: 'News',
      roll: roll,
      result: newsItem,
    );
  }

  /// Generate a full settlement (name + establishment + news).
  FullSettlementResult generateFull() {
    final name = generateName();
    final establishment = rollEstablishment();
    final newsItem = rollNews();

    return FullSettlementResult(
      name: name,
      establishment: establishment,
      news: newsItem,
    );
  }
}

/// Result of generating a settlement name.
class SettlementNameResult extends RollResult {
  final int prefixRoll;
  final String prefix;
  final int suffixRoll;
  final String suffix;

  SettlementNameResult({
    required this.prefixRoll,
    required this.prefix,
    required this.suffixRoll,
    required this.suffix,
  }) : super(
          type: RollType.settlement,
          description: 'Settlement Name',
          diceResults: [prefixRoll, suffixRoll],
          total: prefixRoll + suffixRoll,
          interpretation: '$prefix$suffix',
          metadata: {
            'prefix': prefix,
            'suffix': suffix,
          },
        );

  String get name => '$prefix$suffix';

  @override
  String toString() => 'Settlement: $name';
}

/// Result of rolling a settlement detail.
class SettlementDetailResult extends RollResult {
  final String detailType;
  final int roll;
  final String result;
  final int? subRoll;
  final String? subResult;

  SettlementDetailResult({
    required this.detailType,
    required this.roll,
    required this.result,
    this.subRoll,
    this.subResult,
  }) : super(
          type: RollType.settlement,
          description: 'Settlement $detailType',
          diceResults: subRoll != null ? [roll, subRoll] : [roll],
          total: roll + (subRoll ?? 0),
          interpretation: result,
          metadata: {
            'detailType': detailType,
            'result': result,
            if (subResult != null) 'subResult': subResult,
          },
        );

  @override
  String toString() => '$detailType: $result';
}

/// Result of generating a full settlement.
class FullSettlementResult extends RollResult {
  final SettlementNameResult name;
  final SettlementDetailResult establishment;
  final SettlementDetailResult news;

  FullSettlementResult({
    required this.name,
    required this.establishment,
    required this.news,
  }) : super(
          type: RollType.settlement,
          description: 'Settlement',
          diceResults: [
            ...name.diceResults,
            ...establishment.diceResults,
            ...news.diceResults,
          ],
          total: name.total + establishment.total + news.total,
          interpretation:
              '${name.name} - ${establishment.result} - ${news.result}',
          metadata: {
            'name': name.name,
            'establishment': establishment.result,
            'news': news.result,
          },
        );

  @override
  String toString() =>
      'Settlement: ${name.name}\n  Has: ${establishment.result}\n  News: ${news.result}';
}
