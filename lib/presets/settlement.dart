import '../core/roll_engine.dart';
import '../data/settlement_data.dart' as data;
import 'details.dart';
import 'random_event.dart';
import 'npc_action.dart';
import 'name_generator.dart';

// Re-export result classes for backward compatibility
export '../models/results/settlement_result.dart';

import '../models/results/settlement_result.dart';

/// Settlement generator preset for the Juice Oracle.
/// Uses settlement.md for generating settlement details.
/// 
/// Per Juice rules:
/// - Villages: 1d6@disadvantage for establishment count, d6 for type
/// - Cities: 1d6@advantage for establishment count, d10 for type
/// 
/// **Establishment Naming:** Use Color + Object for naming (e.g., "The Crimson Hourglass")
/// - Each establishment gets a distinct color for map marking
/// - Each has an object as their emblem on the storefront sign
/// - The color/object pairing gives hints about the establishment's theme
/// 
/// **Settlement Properties:** Roll two properties to describe the settlement
/// (e.g., "Major Style" and "Minimal Weight")
/// 
/// **Data Separation:**
/// Static table data is stored in data/settlement_data.dart.
/// This class provides backward-compatible static accessors.
class Settlement {
  final RollEngine _rollEngine;
  late final Details _details;
  late final RandomEvent _randomEvent;
  late final NpcAction _npcAction;
  late final NameGenerator _nameGenerator;

  // ========== Static Accessors (delegate to data file) ==========

  /// Name prefixes - d10
  static List<String> get namePrefixes => data.settlementNamePrefixes;

  /// Name suffixes - d10
  static List<String> get nameSuffixes => data.settlementNameSuffixes;

  /// Establishments - d10 (d6 for villages, d10 for cities)
  static List<String> get establishments => data.settlementEstablishments;
  
  /// Establishment descriptions for display.
  static Map<String, String> get establishmentDescriptions => data.settlementEstablishmentDescriptions;

  /// Artisans - d10
  static List<String> get artisans => data.settlementArtisans;
  
  /// Artisan descriptions.
  static Map<String, String> get artisanDescriptions => data.settlementArtisanDescriptions;

  /// News/Events - d10
  static List<String> get news => data.settlementNews;
  
  /// News descriptions.
  static Map<String, String> get newsDescriptions => data.settlementNewsDescriptions;

  Settlement([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine() {
    _details = Details(_rollEngine);
    _randomEvent = RandomEvent(_rollEngine);
    _npcAction = NpcAction(_rollEngine);
    _nameGenerator = NameGenerator(_rollEngine);
  }

  /// Generate an establishment name using Color + Object pattern.
  /// Per instructions: "Use Color + Object for naming Establishments"
  /// Example: "The Crimson Hourglass", "The Violet Claw"
  EstablishmentNameResult generateEstablishmentName() {
    final colorResult = _details.rollColor();
    final objectResult = _randomEvent.rollObject();
    
    // Extract just the color name (without the full description)
    // e.g., "Crimson Red" -> "Crimson", "Cobalt Blue" -> "Cobalt"
    final colorParts = colorResult.result.split(' ');
    final shortColor = colorParts.isNotEmpty ? colorParts[0] : colorResult.result;
    
    final name = 'The $shortColor ${objectResult.result}';
    
    return EstablishmentNameResult(
      colorRoll: colorResult.roll,
      color: colorResult.result,
      shortColor: shortColor,
      colorEmoji: colorResult.emoji ?? '',
      objectRoll: objectResult.roll,
      object: objectResult.result,
      name: name,
    );
  }

  /// Generate settlement properties (roll two properties with intensity).
  /// Per instructions: "Roll two properties, such as 'Major Style' and 'Minimal Weight'"
  SettlementPropertiesResult generateProperties() {
    final prop1 = _details.rollProperty();
    final prop2 = _details.rollProperty();
    
    return SettlementPropertiesResult(
      property1: prop1,
      property2: prop2,
    );
  }

  /// Generate a simple NPC (name + personality + need + motive).
  /// Per instructions: "For each establishment, generate a simple NPC as the owner."
  SimpleNpcResult generateSimpleNpc({NeedSkew needSkew = NeedSkew.none}) {
    final nameResult = _nameGenerator.generate();
    final profileResult = _npcAction.generateSimpleProfile(needSkew: needSkew);
    
    return SimpleNpcResult(
      name: nameResult,
      profile: profileResult,
    );
  }

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
