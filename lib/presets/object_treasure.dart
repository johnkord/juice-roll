import '../core/roll_engine.dart';
import '../models/roll_result.dart';
import 'details.dart' show SkewType;

/// Object and Treasure generator preset for the Juice Oracle.
/// Uses object-treasure.md for generating treasure details.
class ObjectTreasure {
  final RollEngine _rollEngine;

  // === TRINKET (1) ===
  static const List<String> trinketQualities = [
    'Broken',      // 1
    'Damaged',     // 2
    'Worn',        // 3
    'Simple',      // 4
    'Exceptional', // 5
    'Magic',       // 6
  ];

  static const List<String> trinketMaterials = [
    'Wood',    // 1
    'Bone',    // 2
    'Leather', // 3
    'Silver',  // 4
    'Gold',    // 5
    'Gem',     // 6
  ];

  static const List<String> trinketTypes = [
    'Toy/Game',   // 1
    'Bottle',     // 2
    'Instrument', // 3
    'Charm',      // 4
    'Tool',       // 5
    'Key',        // 6
  ];

  // === TREASURE (2) ===
  static const List<String> treasureQualities = [
    'Dusty',  // 1
    'Worn',   // 2
    'Sturdy', // 3
    'Fine',   // 4
    'New',    // 5
    'Ornate', // 6
  ];

  static const List<String> treasureContainers = [
    'None',    // 1
    'Pouch',   // 2
    'Box',     // 3
    'Satchel', // 4
    'Crate',   // 5
    'Chest',   // 6
  ];

  static const List<String> treasureContents = [
    'Food',         // 1
    'Art',          // 2
    'Deed',         // 3
    'Silver Coins', // 4
    'Gold Coins',   // 5
    'Gems',         // 6
  ];

  // === DOCUMENT (3) ===
  static const List<String> documentTypes = [
    'Song',        // 1
    'Picture',     // 2
    'Letter/Note', // 3
    'Scroll',      // 4
    'Journal',     // 5
    'Book',        // 6
  ];

  static const List<String> documentContents = [
    'Lewd',      // 1
    'Common',    // 2
    'Map',       // 3
    'Prophecy',  // 4
    'Arcane',    // 5
    'Forbidden', // 6
  ];

  static const List<String> documentSubjects = [
    'Religion',  // 1
    'Art',       // 2
    'Science',   // 3
    'Creatures', // 4
    'History',   // 5
    'Magic',     // 6
  ];

  // === ACCESSORY (4) ===
  static const List<String> accessoryQualities = [
    'Ruined',  // 1
    'Crude',   // 2
    'Simple',  // 3
    'Fine',    // 4
    'Crafted', // 5
    'Magic',   // 6
  ];

  static const List<String> accessoryMaterials = [
    'Wood',    // 1
    'Bone',    // 2
    'Leather', // 3
    'Silver',  // 4
    'Gold',    // 5
    'Gem',     // 6
  ];

  static const List<String> accessoryTypes = [
    'Headpiece', // 1
    'Emblem',    // 2
    'Earring',   // 3
    'Bracelet',  // 4
    'Necklace',  // 5
    'Ring',      // 6
  ];

  // === WEAPON (5) ===
  static const List<String> weaponQualities = [
    'Broken',     // 1
    'Improvised', // 2
    'Rough',      // 3
    'Simple',     // 4
    'Martial',    // 5
    'Masterwork', // 6
  ];

  static const List<String> weaponMaterials = [
    'Wood',       // 1
    'Bone',       // 2
    'Steel',      // 3
    'Silver',     // 4
    'Mithral',    // 5
    'Adamantine', // 6
  ];

  static const List<String> weaponTypes = [
    'Axe/Hammer',     // 1
    'Halberd/Spear',  // 2
    'Sword/Dagger',   // 3
    'Staff/Wand',     // 4
    'Bow',            // 5
    'Exotic',         // 6
  ];

  // === ARMOR (6) ===
  static const List<String> armorQualities = [
    'Broken',     // 1
    'Improvised', // 2
    'Tattered',   // 3
    'Simple',     // 4
    'Fine',       // 5
    'Masterwork', // 6
  ];

  static const List<String> armorMaterials = [
    'Cloth',      // 1
    'Leather',    // 2
    'Bone/Fur',   // 3
    'Steel',      // 4
    'Mithral',    // 5
    'Adamantine', // 6
  ];

  static const List<String> armorTypes = [
    'Headpiece', // 1
    'Bottom',    // 2
    'Gloves',    // 3
    'Boots',     // 4
    'Top',       // 5
    'Shield',    // 6
  ];

  /// Treasure categories (d6)
  static const List<String> treasureCategories = [
    'Trinket',   // 1
    'Treasure',  // 2
    'Document',  // 3
    'Accessory', // 4
    'Weapon',    // 5
    'Armor',     // 6
  ];

  ObjectTreasure([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  /// Roll 4d6 for a complete treasure as per Juice instructions.
  /// First die = category, next 3 dice = properties.
  /// Skew: advantage = better item, disadvantage = worse item.
  ObjectTreasureResult generate({SkewType skew = SkewType.none}) {
    // Roll 4d6 with optional skew
    final die1 = _rollEngine.rollDie(6, skew: skew);
    final die2 = _rollEngine.rollDie(6, skew: skew);
    final die3 = _rollEngine.rollDie(6, skew: skew);
    final die4 = _rollEngine.rollDie(6, skew: skew);
    
    return generateFromRolls(die1, die2, die3, die4);
  }
  
  /// Generate treasure from specific 4d6 rolls.
  /// die1 = category, die2/die3/die4 = properties.
  ObjectTreasureResult generateFromRolls(int die1, int die2, int die3, int die4) {
    switch (die1) {
      case 1:
        return _createTrinket(die2, die3, die4);
      case 2:
        return _createTreasure(die2, die3, die4);
      case 3:
        return _createDocument(die2, die3, die4);
      case 4:
        return _createAccessory(die2, die3, die4);
      case 5:
        return _createWeapon(die2, die3, die4);
      case 6:
        return _createArmor(die2, die3, die4);
      default:
        return _createTrinket(die2, die3, die4);
    }
  }

  /// Generate treasure of a specific type (1-6) with skew.
  ObjectTreasureResult generateByType(int type, {SkewType skew = SkewType.none}) {
    switch (type) {
      case 1:
        return generateTrinket(skew: skew);
      case 2:
        return generateTreasure(skew: skew);
      case 3:
        return generateDocument(skew: skew);
      case 4:
        return generateAccessory(skew: skew);
      case 5:
        return generateWeapon(skew: skew);
      case 6:
        return generateArmor(skew: skew);
      default:
        return generateTrinket(skew: skew);
    }
  }

  /// Generate a trinket (3d6 for properties).
  ObjectTreasureResult generateTrinket({SkewType skew = SkewType.none}) {
    final qualityRoll = _rollEngine.rollDie(6, skew: skew);
    final materialRoll = _rollEngine.rollDie(6, skew: skew);
    final typeRoll = _rollEngine.rollDie(6, skew: skew);

    return _createTrinket(qualityRoll, materialRoll, typeRoll);
  }
  
  ObjectTreasureResult _createTrinket(int qualityRoll, int materialRoll, int typeRoll) {
    return ObjectTreasureResult(
      category: 'Trinket',
      quality: trinketQualities[qualityRoll - 1],
      material: trinketMaterials[materialRoll - 1],
      itemType: trinketTypes[typeRoll - 1],
      rolls: [1, qualityRoll, materialRoll, typeRoll],
      columnLabels: ['Quality', 'Material', 'Type'],
    );
  }

  /// Generate treasure (container + contents) (3d6 for properties).
  ObjectTreasureResult generateTreasure({SkewType skew = SkewType.none}) {
    final qualityRoll = _rollEngine.rollDie(6, skew: skew);
    final containerRoll = _rollEngine.rollDie(6, skew: skew);
    final contentsRoll = _rollEngine.rollDie(6, skew: skew);

    return _createTreasure(qualityRoll, containerRoll, contentsRoll);
  }
  
  ObjectTreasureResult _createTreasure(int qualityRoll, int containerRoll, int contentsRoll) {
    return ObjectTreasureResult(
      category: 'Treasure',
      quality: treasureQualities[qualityRoll - 1],
      material: treasureContainers[containerRoll - 1],
      itemType: treasureContents[contentsRoll - 1],
      rolls: [2, qualityRoll, containerRoll, contentsRoll],
      columnLabels: ['Quality', 'Container', 'Contents'],
    );
  }

  /// Generate a document (3d6 for properties).
  ObjectTreasureResult generateDocument({SkewType skew = SkewType.none}) {
    final typeRoll = _rollEngine.rollDie(6, skew: skew);
    final contentRoll = _rollEngine.rollDie(6, skew: skew);
    final subjectRoll = _rollEngine.rollDie(6, skew: skew);

    return _createDocument(typeRoll, contentRoll, subjectRoll);
  }
  
  ObjectTreasureResult _createDocument(int typeRoll, int contentRoll, int subjectRoll) {
    return ObjectTreasureResult(
      category: 'Document',
      quality: documentTypes[typeRoll - 1],
      material: documentContents[contentRoll - 1],
      itemType: documentSubjects[subjectRoll - 1],
      rolls: [3, typeRoll, contentRoll, subjectRoll],
      columnLabels: ['Type', 'Content', 'Subject'],
    );
  }

  /// Generate an accessory (3d6 for properties).
  ObjectTreasureResult generateAccessory({SkewType skew = SkewType.none}) {
    final qualityRoll = _rollEngine.rollDie(6, skew: skew);
    final materialRoll = _rollEngine.rollDie(6, skew: skew);
    final typeRoll = _rollEngine.rollDie(6, skew: skew);

    return _createAccessory(qualityRoll, materialRoll, typeRoll);
  }
  
  ObjectTreasureResult _createAccessory(int qualityRoll, int materialRoll, int typeRoll) {
    return ObjectTreasureResult(
      category: 'Accessory',
      quality: accessoryQualities[qualityRoll - 1],
      material: accessoryMaterials[materialRoll - 1],
      itemType: accessoryTypes[typeRoll - 1],
      rolls: [4, qualityRoll, materialRoll, typeRoll],
      columnLabels: ['Quality', 'Material', 'Type'],
    );
  }

  /// Generate a weapon (3d6 for properties).
  ObjectTreasureResult generateWeapon({SkewType skew = SkewType.none}) {
    final qualityRoll = _rollEngine.rollDie(6, skew: skew);
    final materialRoll = _rollEngine.rollDie(6, skew: skew);
    final typeRoll = _rollEngine.rollDie(6, skew: skew);

    return _createWeapon(qualityRoll, materialRoll, typeRoll);
  }
  
  ObjectTreasureResult _createWeapon(int qualityRoll, int materialRoll, int typeRoll) {
    return ObjectTreasureResult(
      category: 'Weapon',
      quality: weaponQualities[qualityRoll - 1],
      material: weaponMaterials[materialRoll - 1],
      itemType: weaponTypes[typeRoll - 1],
      rolls: [5, qualityRoll, materialRoll, typeRoll],
      columnLabels: ['Quality', 'Material', 'Type'],
    );
  }

  /// Generate armor (3d6 for properties).
  ObjectTreasureResult generateArmor({SkewType skew = SkewType.none}) {
    final qualityRoll = _rollEngine.rollDie(6, skew: skew);
    final materialRoll = _rollEngine.rollDie(6, skew: skew);
    final typeRoll = _rollEngine.rollDie(6, skew: skew);

    return _createArmor(qualityRoll, materialRoll, typeRoll);
  }
  
  ObjectTreasureResult _createArmor(int qualityRoll, int materialRoll, int typeRoll) {
    return ObjectTreasureResult(
      category: 'Armor',
      quality: armorQualities[qualityRoll - 1],
      material: armorMaterials[materialRoll - 1],
      itemType: armorTypes[typeRoll - 1],
      rolls: [6, qualityRoll, materialRoll, typeRoll],
      columnLabels: ['Quality', 'Material', 'Type'],
    );
  }
}

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
  }) : super(
          type: RollType.objectTreasure,
          description: category,
          diceResults: rolls,
          total: rolls.reduce((a, b) => a + b),
          interpretation: _buildInterpretation(category, quality, material, itemType, columnLabels),
          metadata: {
            'category': category,
            'quality': quality,
            'material': material,
            'itemType': itemType,
            'columnLabels': columnLabels,
          },
        );
  
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
