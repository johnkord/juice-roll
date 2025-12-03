import '../core/roll_engine.dart';
import '../models/roll_result.dart';

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

  /// Roll for treasure type (d6) then generate that type.
  ObjectTreasureResult generateRandom() {
    final typeRoll = _rollEngine.rollDie(6);
    return generateByType(typeRoll);
  }

  /// Generate treasure of a specific type (1-6).
  ObjectTreasureResult generateByType(int type) {
    switch (type) {
      case 1:
        return generateTrinket();
      case 2:
        return generateTreasure();
      case 3:
        return generateDocument();
      case 4:
        return generateAccessory();
      case 5:
        return generateWeapon();
      case 6:
        return generateArmor();
      default:
        return generateTrinket();
    }
  }

  /// Generate a trinket (3d6).
  ObjectTreasureResult generateTrinket() {
    final qualityRoll = _rollEngine.rollDie(6);
    final materialRoll = _rollEngine.rollDie(6);
    final typeRoll = _rollEngine.rollDie(6);

    return ObjectTreasureResult(
      category: 'Trinket',
      quality: trinketQualities[qualityRoll - 1],
      material: trinketMaterials[materialRoll - 1],
      itemType: trinketTypes[typeRoll - 1],
      rolls: [qualityRoll, materialRoll, typeRoll],
    );
  }

  /// Generate treasure (container + contents) (3d6).
  ObjectTreasureResult generateTreasure() {
    final qualityRoll = _rollEngine.rollDie(6);
    final containerRoll = _rollEngine.rollDie(6);
    final contentsRoll = _rollEngine.rollDie(6);

    return ObjectTreasureResult(
      category: 'Treasure',
      quality: treasureQualities[qualityRoll - 1],
      material: treasureContainers[containerRoll - 1],
      itemType: treasureContents[contentsRoll - 1],
      rolls: [qualityRoll, containerRoll, contentsRoll],
    );
  }

  /// Generate a document (3d6).
  ObjectTreasureResult generateDocument() {
    final typeRoll = _rollEngine.rollDie(6);
    final contentRoll = _rollEngine.rollDie(6);
    final subjectRoll = _rollEngine.rollDie(6);

    return ObjectTreasureResult(
      category: 'Document',
      quality: documentTypes[typeRoll - 1],
      material: documentContents[contentRoll - 1],
      itemType: documentSubjects[subjectRoll - 1],
      rolls: [typeRoll, contentRoll, subjectRoll],
    );
  }

  /// Generate an accessory (3d6).
  ObjectTreasureResult generateAccessory() {
    final qualityRoll = _rollEngine.rollDie(6);
    final materialRoll = _rollEngine.rollDie(6);
    final typeRoll = _rollEngine.rollDie(6);

    return ObjectTreasureResult(
      category: 'Accessory',
      quality: accessoryQualities[qualityRoll - 1],
      material: accessoryMaterials[materialRoll - 1],
      itemType: accessoryTypes[typeRoll - 1],
      rolls: [qualityRoll, materialRoll, typeRoll],
    );
  }

  /// Generate a weapon (3d6).
  ObjectTreasureResult generateWeapon() {
    final qualityRoll = _rollEngine.rollDie(6);
    final materialRoll = _rollEngine.rollDie(6);
    final typeRoll = _rollEngine.rollDie(6);

    return ObjectTreasureResult(
      category: 'Weapon',
      quality: weaponQualities[qualityRoll - 1],
      material: weaponMaterials[materialRoll - 1],
      itemType: weaponTypes[typeRoll - 1],
      rolls: [qualityRoll, materialRoll, typeRoll],
    );
  }

  /// Generate armor (3d6).
  ObjectTreasureResult generateArmor() {
    final qualityRoll = _rollEngine.rollDie(6);
    final materialRoll = _rollEngine.rollDie(6);
    final typeRoll = _rollEngine.rollDie(6);

    return ObjectTreasureResult(
      category: 'Armor',
      quality: armorQualities[qualityRoll - 1],
      material: armorMaterials[materialRoll - 1],
      itemType: armorTypes[typeRoll - 1],
      rolls: [qualityRoll, materialRoll, typeRoll],
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

  ObjectTreasureResult({
    required this.category,
    required this.quality,
    required this.material,
    required this.itemType,
    required this.rolls,
  }) : super(
          type: RollType.objectTreasure,
          description: category,
          diceResults: rolls,
          total: rolls.reduce((a, b) => a + b),
          interpretation: '$quality $material $itemType',
          metadata: {
            'category': category,
            'quality': quality,
            'material': material,
            'itemType': itemType,
          },
        );

  String get fullDescription => '$quality $material $itemType';

  @override
  String toString() => '$category: $fullDescription';
}
