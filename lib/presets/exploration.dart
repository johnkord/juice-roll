import '../core/roll_engine.dart';
import '../core/table_lookup.dart';
import '../models/roll_result.dart';

/// Wilderness and Dungeon exploration presets.
/// Handles weather and encounter generation.
class Exploration {
  final RollEngine _rollEngine;

  /// Weather table for wilderness exploration (2d6).
  static final LookupTable<Weather> _weatherTable = LookupTable(
    name: 'Weather',
    entries: [
      const TableEntry(minValue: 2, maxValue: 2, result: Weather.extreme),
      const TableEntry(minValue: 3, maxValue: 4, result: Weather.harsh),
      const TableEntry(minValue: 5, maxValue: 5, result: Weather.poor),
      const TableEntry(minValue: 6, maxValue: 8, result: Weather.normal),
      const TableEntry(minValue: 9, maxValue: 9, result: Weather.fair),
      const TableEntry(minValue: 10, maxValue: 11, result: Weather.good),
      const TableEntry(minValue: 12, maxValue: 12, result: Weather.perfect),
    ],
  );

  /// Season modifiers for weather.
  static const Map<String, int> seasonModifiers = {
    'Spring': 0,
    'Summer': 1,
    'Autumn': 0,
    'Winter': -2,
  };

  /// Climate modifiers for weather.
  static const Map<String, int> climateModifiers = {
    'Arctic': -3,
    'Temperate': 0,
    'Tropical': 1,
    'Desert': 2,
  };

  /// Encounter type table for wilderness (2d6).
  static final LookupTable<EncounterType> _wildernessEncounterTable = LookupTable(
    name: 'Wilderness Encounter',
    entries: [
      const TableEntry(minValue: 2, maxValue: 2, result: EncounterType.majorThreat),
      const TableEntry(minValue: 3, maxValue: 4, result: EncounterType.minorThreat),
      const TableEntry(minValue: 5, maxValue: 5, result: EncounterType.obstacle),
      const TableEntry(minValue: 6, maxValue: 8, result: EncounterType.nothing),
      const TableEntry(minValue: 9, maxValue: 9, result: EncounterType.clue),
      const TableEntry(minValue: 10, maxValue: 11, result: EncounterType.discovery),
      const TableEntry(minValue: 12, maxValue: 12, result: EncounterType.special),
    ],
  );

  /// Encounter type table for dungeons (2d6).
  static final LookupTable<EncounterType> _dungeonEncounterTable = LookupTable(
    name: 'Dungeon Encounter',
    entries: [
      const TableEntry(minValue: 2, maxValue: 2, result: EncounterType.majorThreat),
      const TableEntry(minValue: 3, maxValue: 5, result: EncounterType.minorThreat),
      const TableEntry(minValue: 6, maxValue: 6, result: EncounterType.trap),
      const TableEntry(minValue: 7, maxValue: 7, result: EncounterType.nothing),
      const TableEntry(minValue: 8, maxValue: 8, result: EncounterType.puzzle),
      const TableEntry(minValue: 9, maxValue: 10, result: EncounterType.treasure),
      const TableEntry(minValue: 11, maxValue: 11, result: EncounterType.clue),
      const TableEntry(minValue: 12, maxValue: 12, result: EncounterType.special),
    ],
  );

  /// Encounter distance table (2d6).
  static final LookupTable<EncounterDistance> _distanceTable = LookupTable(
    name: 'Encounter Distance',
    entries: [
      const TableEntry(minValue: 2, maxValue: 3, result: EncounterDistance.surprise),
      const TableEntry(minValue: 4, maxValue: 5, result: EncounterDistance.close),
      const TableEntry(minValue: 6, maxValue: 8, result: EncounterDistance.medium),
      const TableEntry(minValue: 9, maxValue: 10, result: EncounterDistance.far),
      const TableEntry(minValue: 11, maxValue: 12, result: EncounterDistance.spotted),
    ],
  );

  /// Creature disposition table (2d6).
  static final LookupTable<Disposition> _dispositionTable = LookupTable(
    name: 'Disposition',
    entries: [
      const TableEntry(minValue: 2, maxValue: 2, result: Disposition.hostile),
      const TableEntry(minValue: 3, maxValue: 4, result: Disposition.unfriendly),
      const TableEntry(minValue: 5, maxValue: 5, result: Disposition.wary),
      const TableEntry(minValue: 6, maxValue: 8, result: Disposition.neutral),
      const TableEntry(minValue: 9, maxValue: 9, result: Disposition.curious),
      const TableEntry(minValue: 10, maxValue: 11, result: Disposition.friendly),
      const TableEntry(minValue: 12, maxValue: 12, result: Disposition.helpful),
    ],
  );

  Exploration([RollEngine? rollEngine]) 
      : _rollEngine = rollEngine ?? RollEngine();

  /// Roll for weather conditions.
  WeatherResult rollWeather({
    String season = 'Spring',
    String climate = 'Temperate',
  }) {
    final seasonMod = seasonModifiers[season] ?? 0;
    final climateMod = climateModifiers[climate] ?? 0;
    final totalMod = seasonMod + climateMod;

    final dice = _rollEngine.rollDice(2, 6);
    final sum = dice.reduce((a, b) => a + b);
    final modifiedSum = (sum + totalMod).clamp(2, 12);

    final weather = _weatherTable.lookup(modifiedSum) ?? Weather.normal;

    return WeatherResult(
      season: season,
      climate: climate,
      modifier: totalMod,
      diceResults: dice,
      rawTotal: sum,
      modifiedTotal: modifiedSum,
      weather: weather,
    );
  }

  /// Check for a wilderness encounter.
  EncounterResult checkWildernessEncounter({int dangerLevel = 0}) {
    return _checkEncounter(
      table: _wildernessEncounterTable,
      locationType: 'Wilderness',
      dangerLevel: dangerLevel,
    );
  }

  /// Check for a dungeon encounter.
  EncounterResult checkDungeonEncounter({int dangerLevel = 0}) {
    return _checkEncounter(
      table: _dungeonEncounterTable,
      locationType: 'Dungeon',
      dangerLevel: dangerLevel,
    );
  }

  EncounterResult _checkEncounter({
    required LookupTable<EncounterType> table,
    required String locationType,
    required int dangerLevel,
  }) {
    final dice = _rollEngine.rollDice(2, 6);
    final sum = dice.reduce((a, b) => a + b);
    final modifiedSum = (sum - dangerLevel).clamp(2, 12);

    final encounterType = table.lookup(modifiedSum) ?? EncounterType.nothing;

    // Roll distance and disposition if there's an encounter
    EncounterDistance? distance;
    Disposition? disposition;

    if (encounterType != EncounterType.nothing) {
      final distanceDice = _rollEngine.rollDice(2, 6);
      final distanceSum = distanceDice.reduce((a, b) => a + b);
      distance = _distanceTable.lookup(distanceSum);

      if (_isCreatureEncounter(encounterType)) {
        final dispDice = _rollEngine.rollDice(2, 6);
        final dispSum = dispDice.reduce((a, b) => a + b);
        disposition = _dispositionTable.lookup(dispSum);
      }
    }

    return EncounterResult(
      locationType: locationType,
      dangerLevel: dangerLevel,
      diceResults: dice,
      rawTotal: sum,
      modifiedTotal: modifiedSum,
      encounterType: encounterType,
      distance: distance,
      disposition: disposition,
    );
  }

  bool _isCreatureEncounter(EncounterType type) {
    return type == EncounterType.majorThreat ||
        type == EncounterType.minorThreat;
  }
}

/// Weather conditions.
enum Weather {
  extreme,
  harsh,
  poor,
  normal,
  fair,
  good,
  perfect,
}

extension WeatherDisplay on Weather {
  String get displayText {
    switch (this) {
      case Weather.extreme:
        return 'Extreme';
      case Weather.harsh:
        return 'Harsh';
      case Weather.poor:
        return 'Poor';
      case Weather.normal:
        return 'Normal';
      case Weather.fair:
        return 'Fair';
      case Weather.good:
        return 'Good';
      case Weather.perfect:
        return 'Perfect';
    }
  }

  String get description {
    switch (this) {
      case Weather.extreme:
        return 'Dangerous conditions. Seek shelter immediately. -4 to outdoor activities.';
      case Weather.harsh:
        return 'Difficult weather. Travel is risky. -2 to outdoor activities.';
      case Weather.poor:
        return 'Unpleasant conditions. -1 to outdoor activities.';
      case Weather.normal:
        return 'Typical weather for the season and climate.';
      case Weather.fair:
        return 'Pleasant conditions. +1 to outdoor activities.';
      case Weather.good:
        return 'Very nice weather. +2 to travel and outdoor activities.';
      case Weather.perfect:
        return 'Ideal conditions. +4 to all outdoor activities.';
    }
  }
}

/// Types of encounters.
enum EncounterType {
  nothing,
  clue,
  discovery,
  obstacle,
  minorThreat,
  majorThreat,
  trap,
  puzzle,
  treasure,
  special,
}

extension EncounterTypeDisplay on EncounterType {
  String get displayText {
    switch (this) {
      case EncounterType.nothing:
        return 'Nothing';
      case EncounterType.clue:
        return 'Clue';
      case EncounterType.discovery:
        return 'Discovery';
      case EncounterType.obstacle:
        return 'Obstacle';
      case EncounterType.minorThreat:
        return 'Minor Threat';
      case EncounterType.majorThreat:
        return 'Major Threat';
      case EncounterType.trap:
        return 'Trap';
      case EncounterType.puzzle:
        return 'Puzzle';
      case EncounterType.treasure:
        return 'Treasure';
      case EncounterType.special:
        return 'Special';
    }
  }
}

/// Encounter distances.
enum EncounterDistance {
  surprise,
  close,
  medium,
  far,
  spotted,
}

extension EncounterDistanceDisplay on EncounterDistance {
  String get displayText {
    switch (this) {
      case EncounterDistance.surprise:
        return 'Surprise! (Very Close)';
      case EncounterDistance.close:
        return 'Close Range';
      case EncounterDistance.medium:
        return 'Medium Range';
      case EncounterDistance.far:
        return 'Far Range';
      case EncounterDistance.spotted:
        return 'Spotted from Afar';
    }
  }
}

/// Creature dispositions.
enum Disposition {
  hostile,
  unfriendly,
  wary,
  neutral,
  curious,
  friendly,
  helpful,
}

extension DispositionDisplay on Disposition {
  String get displayText {
    switch (this) {
      case Disposition.hostile:
        return 'Hostile';
      case Disposition.unfriendly:
        return 'Unfriendly';
      case Disposition.wary:
        return 'Wary';
      case Disposition.neutral:
        return 'Neutral';
      case Disposition.curious:
        return 'Curious';
      case Disposition.friendly:
        return 'Friendly';
      case Disposition.helpful:
        return 'Helpful';
    }
  }
}

/// Result of a weather roll.
class WeatherResult extends RollResult {
  final String season;
  final String climate;
  final int modifier;
  final int rawTotal;
  final int modifiedTotal;
  final Weather weather;

  WeatherResult({
    required this.season,
    required this.climate,
    required this.modifier,
    required List<int> diceResults,
    required this.rawTotal,
    required this.modifiedTotal,
    required this.weather,
  }) : super(
          type: RollType.weather,
          description: 'Weather ($season, $climate)',
          diceResults: diceResults,
          total: modifiedTotal,
          interpretation: weather.displayText,
          metadata: {
            'season': season,
            'climate': climate,
            'weather': weather.name,
          },
        );

  @override
  String toString() {
    final modStr = modifier >= 0 ? '+$modifier' : '$modifier';
    return 'Weather ($season, $climate): ${diceResults.join('+')}$modStr = $modifiedTotal → ${weather.displayText}';
  }
}

/// Result of an encounter check.
class EncounterResult extends RollResult {
  final String locationType;
  final int dangerLevel;
  final int rawTotal;
  final int modifiedTotal;
  final EncounterType encounterType;
  final EncounterDistance? distance;
  final Disposition? disposition;

  EncounterResult({
    required this.locationType,
    required this.dangerLevel,
    required List<int> diceResults,
    required this.rawTotal,
    required this.modifiedTotal,
    required this.encounterType,
    this.distance,
    this.disposition,
  }) : super(
          type: RollType.encounter,
          description: '$locationType Encounter',
          diceResults: diceResults,
          total: modifiedTotal,
          interpretation: _buildInterpretation(encounterType, distance, disposition),
          metadata: {
            'locationType': locationType,
            'dangerLevel': dangerLevel,
            'encounterType': encounterType.name,
            'distance': distance?.name,
            'disposition': disposition?.name,
          },
        );

  static String _buildInterpretation(
    EncounterType type,
    EncounterDistance? distance,
    Disposition? disposition,
  ) {
    if (type == EncounterType.nothing) {
      return 'No encounter';
    }

    final parts = <String>[type.displayText];
    if (distance != null) {
      parts.add(distance.displayText);
    }
    if (disposition != null) {
      parts.add(disposition.displayText);
    }
    return parts.join(' - ');
  }

  @override
  String toString() {
    final dangerStr = dangerLevel != 0 ? ' (Danger: $dangerLevel)' : '';
    if (encounterType == EncounterType.nothing) {
      return '$locationType Encounter$dangerStr: No encounter';
    }

    final buffer = StringBuffer();
    buffer.writeln('$locationType Encounter$dangerStr:');
    buffer.writeln('  Type: ${encounterType.displayText}');
    if (distance != null) {
      buffer.writeln('  Distance: ${distance!.displayText}');
    }
    if (disposition != null) {
      buffer.write('  Disposition: ${disposition!.displayText}');
    }
    return buffer.toString().trim();
  }
}
