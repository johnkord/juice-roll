import '../roll_result.dart';
import 'json_utils.dart';
import 'details_result.dart';

/// Result of an Object/Treasure generation.
class ObjectTreasureResult extends RollResult {
  final String category;
  final String quality;
  final String material;
  final String itemType;
  final List<int> rolls;
  final List<String> columnLabels;

  ObjectTreasureResult({
    required this.category,
    required this.quality,
    required this.material,
    required this.itemType,
    required this.rolls,
    this.columnLabels = const ['Quality', 'Material', 'Type'],
    DateTime? timestamp,
  }) : super(
          type: RollType.objectTreasure,
          description: category,
          diceResults: rolls,
          total: rolls.reduce((a, b) => a + b),
          interpretation: _buildInterpretation(category, quality, material, itemType, columnLabels),
          timestamp: timestamp,
          metadata: {
            'category': category,
            'quality': quality,
            'material': material,
            'itemType': itemType,
            'columnLabels': columnLabels,
            'rolls': rolls,
          },
        );

  @override
  String get className => 'ObjectTreasureResult';

  factory ObjectTreasureResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return ObjectTreasureResult(
      category: meta['category'] as String,
      quality: meta['quality'] as String,
      material: meta['material'] as String,
      itemType: meta['itemType'] as String,
      rolls: (meta['rolls'] as List?)?.cast<int>() ?? diceResults,
      columnLabels: (meta['columnLabels'] as List?)?.cast<String>() ?? const ['Quality', 'Material', 'Type'],
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
  
  static String _buildInterpretation(String category, String quality, String material, String itemType, List<String> labels) {
    // Build descriptive output based on category
    switch (category) {
      case 'Treasure':
        // Treasure: quality container with contents
        if (material == 'None') {
          return '$quality $itemType';
        }
        return '$quality $material full of $itemType';
      case 'Document':
        // Document: type with content about subject
        return '$quality $material $itemType';
      default:
        // Default: quality material type
        return '$quality $material $itemType';
    }
  }

  String get fullDescription => interpretation ?? '$quality $material $itemType';
  
  /// Get formatted roll details showing each column
  String get rollDetails {
    final parts = <String>[];
    parts.add('Category: $category (${rolls[0]})');
    if (rolls.length >= 4) {
      parts.add('${columnLabels[0]}: $quality (${rolls[1]})');
      parts.add('${columnLabels[1]}: $material (${rolls[2]})');
      parts.add('${columnLabels[2]}: $itemType (${rolls[3]})');
    }
    return parts.join('\n');
  }

  @override
  String toString() => '$category: $fullDescription';
}

/// Result of the full Item Creation procedure.
/// Combines 4d6 Object/Treasure + 2 Property rolls + optional Color.
/// 
/// Example interpretation:
/// "Accessory: Simple Silver Necklace" with
/// Property 1: "Major Value" (1d10=9, 1d6=5)
/// Property 2: "Moderate Power" (1d10=5, 1d6=4)
/// Color: "Crimson Red" (optional, for appearance/elemental)
class ItemCreationResult extends RollResult {
  final ObjectTreasureResult baseItem;
  final PropertyResult property1;
  final PropertyResult property2;
  final DetailResult? color;

  ItemCreationResult({
    required this.baseItem,
    required this.property1,
    required this.property2,
    this.color,
  }) : super(
          type: RollType.objectTreasure,
          description: 'Item Creation',
          diceResults: _combineDiceResults(baseItem, property1, property2, color),
          total: baseItem.total + property1.total + property2.total + (color?.total ?? 0),
          interpretation: _buildInterpretation(baseItem, property1, property2, color),
          metadata: {
            'baseItem': baseItem.toJson(),
            'property1': property1.toJson(),
            'property2': property2.toJson(),
            if (color != null) 'color': color.toJson(),
          },
        );

  @override
  String get className => 'ItemCreationResult';

  /// Serialization - keep in sync with fromJson below.
  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'metadata': {
      'baseItem': baseItem.toJson(),
      'property1': property1.toJson(),
      'property2': property2.toJson(),
      if (color != null) 'color': color!.toJson(),
    },
  };

  /// Deserialization - keep in sync with toJson above.
  factory ItemCreationResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    
    // Safely cast nested Maps (JSON may return Map<dynamic, dynamic>)
    final baseItemJson = requireMap(meta['baseItem'], 'baseItem');
    final prop1Json = requireMap(meta['property1'], 'property1');
    final prop2Json = requireMap(meta['property2'], 'property2');
    final colorJson = safeMap(meta['color']);
    
    return ItemCreationResult(
      baseItem: ObjectTreasureResult.fromJson(baseItemJson),
      property1: PropertyResult.fromJson(prop1Json),
      property2: PropertyResult.fromJson(prop2Json),
      color: colorJson != null ? DetailResult.fromJson(colorJson) : null,
    );
  }

  static List<int> _combineDiceResults(
    ObjectTreasureResult baseItem,
    PropertyResult property1,
    PropertyResult property2,
    DetailResult? color,
  ) {
    return [
      ...baseItem.diceResults,
      ...property1.diceResults,
      ...property2.diceResults,
      if (color != null) ...color.diceResults,
    ];
  }

  static String _buildInterpretation(
    ObjectTreasureResult baseItem,
    PropertyResult property1,
    PropertyResult property2,
    DetailResult? color,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('${baseItem.category}: ${baseItem.fullDescription}');
    buffer.writeln('• ${property1.interpretation}');
    buffer.writeln('• ${property2.interpretation}');
    if (color != null) {
      buffer.write('• Color: ${color.interpretation}');
    }
    return buffer.toString().trim();
  }

  @override
  String toString() {
    final colorStr = color != null ? ' [${color!.result}]' : '';
    return 'Item: ${baseItem.fullDescription}$colorStr (${property1.intensityDescription} ${property1.property}, ${property2.intensityDescription} ${property2.property})';
  }
}
