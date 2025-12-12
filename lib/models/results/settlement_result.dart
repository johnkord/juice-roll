import '../roll_result.dart';
import 'details_result.dart';
import 'npc_action_result.dart';
import 'name_result.dart';

/// Settlement type (village vs city).
enum SettlementType { village, city }

/// Result of rolling a settlement name.
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
    DateTime? timestamp,
  }) : super(
          type: RollType.settlement,
          description: 'Settlement Name',
          diceResults: [prefixRoll, suffixRoll],
          total: prefixRoll + suffixRoll,
          interpretation: '$prefix$suffix',
          timestamp: timestamp,
          metadata: {
            'prefix': prefix,
            'prefixRoll': prefixRoll,
            'suffix': suffix,
            'suffixRoll': suffixRoll,
          },
        );

  @override
  String get className => 'SettlementNameResult';

  factory SettlementNameResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return SettlementNameResult(
      prefixRoll: meta['prefixRoll'] as int? ?? diceResults[0],
      prefix: meta['prefix'] as String,
      suffixRoll: meta['suffixRoll'] as int? ?? diceResults[1],
      suffix: meta['suffix'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

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
    DateTime? timestamp,
  }) : super(
          type: RollType.settlement,
          description: 'Settlement $detailType',
          diceResults: subRoll != null ? [roll, subRoll] : [roll],
          total: roll + (subRoll ?? 0),
          interpretation: result,
          timestamp: timestamp,
          metadata: {
            'detailType': detailType,
            'result': result,
            if (subResult != null) 'subResult': subResult,
            if (detailDescription != null) 'detailDescription': detailDescription,
            if (dieSize != null) 'dieSize': dieSize,
          },
        );

  @override
  String get className => 'SettlementDetailResult';

  factory SettlementDetailResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return SettlementDetailResult(
      detailType: meta['detailType'] as String,
      roll: diceResults[0],
      result: meta['result'] as String,
      subRoll: diceResults.length > 1 ? diceResults[1] : null,
      subResult: meta['subResult'] as String?,
      detailDescription: meta['detailDescription'] as String?,
      dieSize: meta['dieSize'] as int?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

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
    DateTime? timestamp,
  }) : super(
          type: RollType.settlement,
          description: 'Establishment Count',
          diceResults: dice,
          total: count,
          interpretation: '$count establishments',
          timestamp: timestamp,
          metadata: {
            'count': count,
            'settlementType': settlementType.name,
            'skewUsed': skewUsed,
          },
        );

  @override
  String get className => 'EstablishmentCountResult';

  factory EstablishmentCountResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return EstablishmentCountResult(
      count: meta['count'] as int,
      dice: diceResults,
      settlementType: SettlementType.values.firstWhere(
        (t) => t.name == meta['settlementType'],
        orElse: () => SettlementType.village,
      ),
      skewUsed: meta['skewUsed'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

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
    DateTime? timestamp,
  }) : super(
          type: RollType.settlement,
          description: 'Settlement Establishments',
          diceResults: [
            ...countResult.diceResults,
            ...establishments.expand((e) => e.diceResults),
          ],
          total: establishments.length,
          interpretation: establishments.map((e) => e.result).join(', '),
          timestamp: timestamp,
          metadata: {
            'count': countResult.count,
            'establishments': establishments.map((e) => e.result).toList(),
          },
        );

  @override
  String get className => 'MultiEstablishmentResult';

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'countResult': countResult.toJson(),
    'establishments': establishments.map((e) => e.toJson()).toList(),
  };

  factory MultiEstablishmentResult.fromJson(Map<String, dynamic> json) {
    return MultiEstablishmentResult(
      countResult: EstablishmentCountResult.fromJson(
        json['countResult'] as Map<String, dynamic>,
      ),
      establishments: (json['establishments'] as List)
          .map((e) => SettlementDetailResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

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
    DateTime? timestamp,
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
          timestamp: timestamp,
          metadata: {
            'name': name.name,
            'establishment': establishment.result,
            'news': news.result,
          },
        );

  @override
  String get className => 'FullSettlementResult';

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'name': name.toJson(),
    'establishment': establishment.toJson(),
    'news': news.toJson(),
  };

  factory FullSettlementResult.fromJson(Map<String, dynamic> json) {
    return FullSettlementResult(
      name: SettlementNameResult.fromJson(
        json['name'] as Map<String, dynamic>,
      ),
      establishment: SettlementDetailResult.fromJson(
        json['establishment'] as Map<String, dynamic>,
      ),
      news: SettlementDetailResult.fromJson(
        json['news'] as Map<String, dynamic>,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

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
    DateTime? timestamp,
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
          timestamp: timestamp,
          metadata: {
            'settlementType': settlementType.name,
            'name': name.name,
            'establishments': establishments.establishments.map((e) => e.result).toList(),
            'news': news.result,
          },
        );

  @override
  String get className => 'CompleteSettlementResult';

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'settlementType': settlementType.name,
    'name': name.toJson(),
    'establishments': establishments.toJson(),
    'news': news.toJson(),
  };

  factory CompleteSettlementResult.fromJson(Map<String, dynamic> json) {
    return CompleteSettlementResult(
      settlementType: SettlementType.values.firstWhere(
        (t) => t.name == json['settlementType'],
        orElse: () => SettlementType.village,
      ),
      name: SettlementNameResult.fromJson(
        json['name'] as Map<String, dynamic>,
      ),
      establishments: MultiEstablishmentResult.fromJson(
        json['establishments'] as Map<String, dynamic>,
      ),
      news: SettlementDetailResult.fromJson(
        json['news'] as Map<String, dynamic>,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

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

/// Result of generating an establishment name using Color + Object pattern.
/// Per instructions: "Use Color + Object for naming Establishments"
/// Example: "The Crimson Hourglass", "The Violet Claw"
class EstablishmentNameResult extends RollResult {
  final int colorRoll;
  final String color;
  final String shortColor;
  final String colorEmoji;
  final int objectRoll;
  final String object;
  final String name;

  EstablishmentNameResult({
    required this.colorRoll,
    required this.color,
    required this.shortColor,
    required this.colorEmoji,
    required this.objectRoll,
    required this.object,
    required this.name,
    DateTime? timestamp,
  }) : super(
          type: RollType.settlement,
          description: 'Establishment Name',
          diceResults: [colorRoll, objectRoll],
          total: colorRoll + objectRoll,
          interpretation: '$colorEmoji $name',
          timestamp: timestamp,
          metadata: {
            'color': color,
            'colorRoll': colorRoll,
            'shortColor': shortColor,
            'colorEmoji': colorEmoji,
            'object': object,
            'objectRoll': objectRoll,
            'name': name,
          },
        );

  @override
  String get className => 'EstablishmentNameResult';

  factory EstablishmentNameResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return EstablishmentNameResult(
      colorRoll: meta['colorRoll'] as int? ?? diceResults[0],
      color: meta['color'] as String,
      shortColor: meta['shortColor'] as String,
      colorEmoji: meta['colorEmoji'] as String,
      objectRoll: meta['objectRoll'] as int? ?? diceResults[1],
      object: meta['object'] as String,
      name: meta['name'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() => 'Establishment: $colorEmoji $name';
}

/// Result of generating settlement properties.
/// Per instructions: "Roll two properties, such as 'Major Style' and 'Minimal Weight'"
class SettlementPropertiesResult extends RollResult {
  final PropertyResult property1;
  final PropertyResult property2;

  SettlementPropertiesResult({
    required this.property1,
    required this.property2,
    DateTime? timestamp,
  }) : super(
          type: RollType.settlement,
          description: 'Settlement Properties',
          diceResults: [
            property1.propertyRoll,
            property1.intensityRoll,
            property2.propertyRoll,
            property2.intensityRoll,
          ],
          total: property1.propertyRoll + property2.propertyRoll,
          interpretation: '${property1.interpretation} + ${property2.interpretation}',
          timestamp: timestamp,
          metadata: {
            'property1': property1.property,
            'property1Roll': property1.propertyRoll,
            'intensity1': property1.intensityRoll,
            'property2': property2.property,
            'property2Roll': property2.propertyRoll,
            'intensity2': property2.intensityRoll,
          },
        );

  @override
  String get className => 'SettlementPropertiesResult';

  factory SettlementPropertiesResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    return SettlementPropertiesResult(
      property1: PropertyResult(
        propertyRoll: meta['property1Roll'] as int? ?? 1,
        property: meta['property1'] as String,
        intensityRoll: meta['intensity1'] as int? ?? 1,
      ),
      property2: PropertyResult(
        propertyRoll: meta['property2Roll'] as int? ?? 1,
        property: meta['property2'] as String,
        intensityRoll: meta['intensity2'] as int? ?? 1,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() =>
      'Properties: ${property1.intensityDescription} ${property1.property} + ${property2.intensityDescription} ${property2.property}';
}

/// Result of generating a simple NPC (name + profile).
/// Per instructions: "For each establishment, generate a simple NPC as the owner."
class SimpleNpcResult extends RollResult {
  final NameResult name;
  final SimpleNpcProfileResult profile;

  SimpleNpcResult({
    required this.name,
    required this.profile,
    DateTime? timestamp,
  }) : super(
          type: RollType.settlement,
          description: 'Simple NPC',
          diceResults: [
            ...name.diceResults,
            ...profile.diceResults,
          ],
          total: name.total + profile.total,
          interpretation: '${name.name}: ${profile.personality}, ${profile.need}, ${profile.motive}',
          timestamp: timestamp,
          metadata: {
            'name': name.name,
            'personality': profile.personality,
            'need': profile.need,
            'motive': profile.motive,
          },
        );

  @override
  String get className => 'SimpleNpcResult';

  factory SimpleNpcResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    // Cannot fully reconstruct, but provide basic info
    return SimpleNpcResult(
      name: NameResult(
        rolls: [1],
        syllables: [meta['name'] as String],
        name: meta['name'] as String,
        style: NameStyle.neutral,
        method: NameMethod.simple,
      ),
      profile: SimpleNpcProfileResult(
        personalityRoll: 1,
        personality: meta['personality'] as String,
        needRoll: 1,
        need: meta['need'] as String,
        motiveRoll: 1,
        motive: meta['motive'] as String,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() =>
      'NPC: ${name.name} - ${profile.personality}, ${profile.need}, ${profile.motive}';
}
