import '../core/roll_engine.dart';
import '../data/object_treasure_data.dart' as data;
import 'details.dart' show Details, SkewType, DetailResult;

// Re-export result classes for backward compatibility
export '../models/results/object_treasure_result.dart'
    show ObjectTreasureResult, ItemCreationResult;

// Import result classes for internal use
import '../models/results/object_treasure_result.dart';

/// Object and Treasure generator preset for the Juice Oracle.
/// Uses object-treasure.md for generating treasure details.
class ObjectTreasure {
  final RollEngine _rollEngine;

  // === TRINKET (1) ===
  static List<String> get trinketQualities => data.trinketQualities;
  static List<String> get trinketMaterials => data.trinketMaterials;
  static List<String> get trinketTypes => data.trinketTypes;

  // === TREASURE (2) ===
  static List<String> get treasureQualities => data.treasureQualities;
  static List<String> get treasureContainers => data.treasureContainers;
  static List<String> get treasureContents => data.treasureContents;

  // === DOCUMENT (3) ===
  static List<String> get documentTypes => data.documentTypes;
  static List<String> get documentContents => data.documentContents;
  static List<String> get documentSubjects => data.documentSubjects;

  // === ACCESSORY (4) ===
  static List<String> get accessoryQualities => data.accessoryQualities;
  static List<String> get accessoryMaterials => data.accessoryMaterials;
  static List<String> get accessoryTypes => data.accessoryTypes;

  // === WEAPON (5) ===
  static List<String> get weaponQualities => data.weaponQualities;
  static List<String> get weaponMaterials => data.weaponMaterials;
  static List<String> get weaponTypes => data.weaponTypes;

  // === ARMOR (6) ===
  static List<String> get armorQualities => data.armorQualities;
  static List<String> get armorMaterials => data.armorMaterials;
  static List<String> get armorTypes => data.armorTypes;

  /// Treasure categories (d6)
  static List<String> get treasureCategories => data.treasureCategories;

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

  /// Generate a full item as per Item Creation procedure in Juice instructions.
  /// 
  /// To create an item:
  /// 1. Roll 4d6 on the Object/Treasure table (base item description)
  /// 2. Roll two properties (1d10+1d6 each) to flesh it out
  /// 3. Optionally roll a color for appearance or elemental powers
  /// 
  /// Example from instructions:
  /// 4d6 -> 4,3,4,5 -> "Accessory: Simple Silver Necklace"
  /// Property: 1d10+1d6 -> 9,5 -> Major Value
  /// Property: 1d10+1d6 -> 5,4 -> Moderate Power
  ItemCreationResult generateFullItem({
    SkewType skew = SkewType.none,
    bool includeColor = false,
  }) {
    final details = Details(_rollEngine);
    
    // Step 1: Roll 4d6 for base item
    final baseItem = generate(skew: skew);
    
    // Step 2: Roll two properties (1d10+1d6 each)
    final property1 = details.rollProperty();
    final property2 = details.rollProperty();
    
    // Step 3: Optionally roll color
    DetailResult? color;
    if (includeColor) {
      color = details.rollColor();
    }
    
    return ItemCreationResult(
      baseItem: baseItem,
      property1: property1,
      property2: property2,
      color: color,
    );
  }
}

