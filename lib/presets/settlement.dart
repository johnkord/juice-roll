import '../core/roll_engine.dart';
import '../models/roll_result.dart';

/// Settlement type (village vs city).
enum SettlementType { village, city }

/// Settlement generator preset for the Juice Oracle.
/// Uses settlement.md for generating settlement details.
/// 
/// Per Juice rules:
/// - Villages: 1d6@disadvantage for establishment count, d6 for type
/// - Cities: 1d6@advantage for establishment count, d10 for type
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

  /// Establishments - d10 (d6 for villages, d10 for cities)
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
  
  /// Establishment descriptions for display.
  static const Map<String, String> establishmentDescriptions = {
    'Stable': 'Rent/buy horses, pay for transportation to another area.',
    'Tavern': 'Food, drink, stories, rumors. Great for NPC info and side quests.',
    'Inn': 'Spend the night and rest safely. Sometimes combined with Tavern.',
    'Entertainment': 'Market, bath house, casino, brothel, etc.',
    'General Store': 'Basics and common items. Stock up on rations and torches.',
    'Artisan': 'Specialist craftsperson. Better quality, repairs, custom orders.',
    'Courier': 'Send messages, money, packages. Receive news from other settlements.',
    'Temple': 'Pray, receive blessings, remove curses. Library access for history.',
    'Guild Hall': 'Quest distribution, guild services. May offer food and lodging.',
    'Magic Shop': 'Potions, arcane books, dark secrets, trinkets, artificers.',
  };

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
  
  /// Artisan descriptions.
  static const Map<String, String> artisanDescriptions = {
    'Artist': 'Painter, calligrapher, cartologist (maps), glassblower.',
    'Baker': 'Delicious meals, breads, rations.',
    'Tailor': 'Clothing, costumes, light armor.',
    'Tanner': 'Leather armor (medium), accessories, saddles.',
    'Archer': 'Bows, bowstrings, arrows, quivers.',
    'Blacksmith': 'Weapons, heavy armor, metal accessories.',
    'Carpenter': 'Wagons, structures, furniture, wood items.',
    'Apothecary': 'Medicine, herbs, pharmacy. Knowledge of flora.',
    'Jeweler': 'Gems, appraisal, cutting, magic infusion, engravings.',
    'Scribe': 'Formal letters, magical scrolls, legal documents, forgery.',
  };

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
  
  /// News descriptions.
  static const Map<String, String> newsDescriptions = {
    'War': 'Battle, civil war, trade war, gang rivalry, shop competition, debate.',
    'Sickness': 'Plague, celebrity illness, crop fungus, dying trees.',
    'Natural Disaster': 'Fire, earthquake, flood, tornado.',
    'Crime': 'Assassination, theft, racketeering, smuggling.',
    'Succession': 'Death, term ended, coming of age, election, retirement.',
    'Remote Event': 'News from far away. Update on a previous Remote Event.',
    'Arrival': 'Someone/something is coming. King? Army? Music group? Adventurers?',
    'Mail': 'You\'ve got mail! Letter or package. Good or bad news?',
    'Sale': 'Shop or market sale today. Act quick for discount!',
    'Celebration': 'Festival or event. Holiday? Birthday? Anniversary?',
  };

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
  /// [isVillage] determines die size: d6 for villages, d10 for cities.
  SettlementDetailResult rollEstablishment({bool isVillage = false}) {
    final dieSize = isVillage ? 6 : 10;
    final roll = _rollEngine.rollDie(dieSize);
    final index = roll == dieSize ? dieSize - 1 : roll - 1;
    var establishment = establishments[index];
    final description = establishmentDescriptions[establishment];

    // If artisan, roll on artisan table
    String? artisan;
    int? artisanRoll;
    String? artisanDescription;
    if (establishment == 'Artisan') {
      artisanRoll = _rollEngine.rollDie(10);
      final artisanIndex = artisanRoll == 10 ? 9 : artisanRoll - 1;
      artisan = artisans[artisanIndex];
      artisanDescription = artisanDescriptions[artisan];
      establishment = '$artisan (Artisan)';
    }

    return SettlementDetailResult(
      detailType: 'Establishment',
      roll: roll,
      result: establishment,
      subRoll: artisanRoll,
      subResult: artisan,
      detailDescription: artisanDescription ?? description,
      dieSize: dieSize,
    );
  }

  /// Roll for an artisan.
  SettlementDetailResult rollArtisan() {
    final roll = _rollEngine.rollDie(10);
    final index = roll == 10 ? 9 : roll - 1;
    final artisan = artisans[index];
    final description = artisanDescriptions[artisan];

    return SettlementDetailResult(
      detailType: 'Artisan',
      roll: roll,
      result: artisan,
      detailDescription: description,
    );
  }

  /// Roll for settlement news.
  SettlementDetailResult rollNews() {
    final roll = _rollEngine.rollDie(10);
    final index = roll == 10 ? 9 : roll - 1;
    final newsItem = news[index];
    final description = newsDescriptions[newsItem];

    return SettlementDetailResult(
      detailType: 'News',
      roll: roll,
      result: newsItem,
      detailDescription: description,
    );
  }
  
  /// Generate establishment count for a settlement.
  /// Villages: 1d6@disadvantage (smaller, fewer)
  /// Cities: 1d6@advantage (larger, more)
  EstablishmentCountResult rollEstablishmentCount({required SettlementType type}) {
    final dice = [_rollEngine.rollDie(6), _rollEngine.rollDie(6)];
    final int count;
    final String skewUsed;
    
    if (type == SettlementType.village) {
      // Disadvantage: take lower
      count = dice[0] < dice[1] ? dice[0] : dice[1];
      skewUsed = '@- (disadvantage)';
    } else {
      // Advantage: take higher
      count = dice[0] > dice[1] ? dice[0] : dice[1];
      skewUsed = '@+ (advantage)';
    }
    
    return EstablishmentCountResult(
      count: count,
      dice: dice,
      settlementType: type,
      skewUsed: skewUsed,
    );
  }
  
  /// Generate multiple establishments for a settlement.
  /// [type] determines die size and count roll skew.
  MultiEstablishmentResult generateEstablishments({required SettlementType type}) {
    final countResult = rollEstablishmentCount(type: type);
    final isVillage = type == SettlementType.village;
    
    final establishments = <SettlementDetailResult>[];
    for (var i = 0; i < countResult.count; i++) {
      establishments.add(rollEstablishment(isVillage: isVillage));
    }
    
    return MultiEstablishmentResult(
      countResult: countResult,
      establishments: establishments,
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
  
  /// Generate a complete village with name, multiple establishments, and news.
  CompleteSettlementResult generateVillage() {
    final name = generateName();
    final establishments = generateEstablishments(type: SettlementType.village);
    final newsItem = rollNews();
    
    return CompleteSettlementResult(
      settlementType: SettlementType.village,
      name: name,
      establishments: establishments,
      news: newsItem,
    );
  }
  
  /// Generate a complete city with name, multiple establishments, and news.
  CompleteSettlementResult generateCity() {
    final name = generateName();
    final establishments = generateEstablishments(type: SettlementType.city);
    final newsItem = rollNews();
    
    return CompleteSettlementResult(
      settlementType: SettlementType.city,
      name: name,
      establishments: establishments,
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
  final String? detailDescription;
  final int? dieSize;

  SettlementDetailResult({
    required this.detailType,
    required this.roll,
    required this.result,
    this.subRoll,
    this.subResult,
    this.detailDescription,
    this.dieSize,
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
            if (detailDescription != null) 'detailDescription': detailDescription,
            if (dieSize != null) 'dieSize': dieSize,
          },
        );

  @override
  String toString() => '$detailType: $result';
}

/// Result of rolling establishment count.
class EstablishmentCountResult extends RollResult {
  final int count;
  final List<int> dice;
  final SettlementType settlementType;
  final String skewUsed;

  EstablishmentCountResult({
    required this.count,
    required this.dice,
    required this.settlementType,
    required this.skewUsed,
  }) : super(
          type: RollType.settlement,
          description: 'Establishment Count',
          diceResults: dice,
          total: count,
          interpretation: '$count establishments',
          metadata: {
            'count': count,
            'settlementType': settlementType.name,
            'skewUsed': skewUsed,
          },
        );

  @override
  String toString() => 'Establishments: $count ($skewUsed)';
}

/// Result of generating multiple establishments.
class MultiEstablishmentResult extends RollResult {
  final EstablishmentCountResult countResult;
  final List<SettlementDetailResult> establishments;

  MultiEstablishmentResult({
    required this.countResult,
    required this.establishments,
  }) : super(
          type: RollType.settlement,
          description: 'Settlement Establishments',
          diceResults: [
            ...countResult.diceResults,
            ...establishments.expand((e) => e.diceResults),
          ],
          total: establishments.length,
          interpretation: establishments.map((e) => e.result).join(', '),
          metadata: {
            'count': countResult.count,
            'establishments': establishments.map((e) => e.result).toList(),
          },
        );

  @override
  String toString() => 'Establishments (${countResult.count}): ${establishments.map((e) => e.result).join(', ')}';
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

/// Result of generating a complete settlement (village or city).
class CompleteSettlementResult extends RollResult {
  final SettlementType settlementType;
  final SettlementNameResult name;
  final MultiEstablishmentResult establishments;
  final SettlementDetailResult news;

  CompleteSettlementResult({
    required this.settlementType,
    required this.name,
    required this.establishments,
    required this.news,
  }) : super(
          type: RollType.settlement,
          description: settlementType == SettlementType.village ? 'Village' : 'City',
          diceResults: [
            ...name.diceResults,
            ...establishments.diceResults,
            ...news.diceResults,
          ],
          total: name.total + establishments.total + news.total,
          interpretation: _formatInterpretation(settlementType, name, establishments, news),
          metadata: {
            'settlementType': settlementType.name,
            'name': name.name,
            'establishments': establishments.establishments.map((e) => e.result).toList(),
            'news': news.result,
          },
        );

  static String _formatInterpretation(
    SettlementType type,
    SettlementNameResult name,
    MultiEstablishmentResult establishments,
    SettlementDetailResult news,
  ) {
    final typeLabel = type == SettlementType.village ? 'Village' : 'City';
    final estList = establishments.establishments.map((e) => e.result).join(', ');
    return '$typeLabel of ${name.name}\nEstablishments: $estList\nNews: ${news.result}';
  }

  @override
  String toString() {
    final typeLabel = settlementType == SettlementType.village ? 'Village' : 'City';
    final buffer = StringBuffer();
    buffer.writeln('$typeLabel: ${name.name}');
    buffer.writeln('Establishments (${establishments.countResult.count}):');
    for (final est in establishments.establishments) {
      buffer.writeln('  • ${est.result}');
    }
    buffer.writeln('News: ${news.result}');
    return buffer.toString();
  }
}
