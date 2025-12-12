import '../roll_result.dart';

/// Distance from center (rings of the bullseye)
enum LocationDistance {
  center, // Ring 0: Center cell only (row 3, col 3)
  close, // Ring 1: Adjacent to center (rows 2-4, cols 2-4, excluding center)
  far, // Ring 2: Outer ring (edge cells)
}

/// Compass direction for location
enum CompassDirection {
  north,
  northEast,
  east,
  southEast,
  south,
  southWest,
  west,
  northWest,
  center,
}

/// Result of a location grid roll
class LocationResult extends RollResult {
  final int roll; // 0-99 (from 1d100)
  final int row; // 1-5 (top to bottom)
  final int column; // 1-5 (left to right)
  final CompassDirection direction;
  final LocationDistance distance;

  LocationResult({
    required List<int> diceResults,
    required this.roll,
    required this.row,
    required this.column,
    DateTime? timestamp,
  })  : direction = getDirection(row, column),
        distance = getDistance(row, column),
        super(
          type: RollType.location,
          description: 'Location Grid',
          diceResults: diceResults,
          total: roll,
          interpretation: _buildInterpretation(row, column),
          timestamp: timestamp,
          metadata: {
            'roll': roll,
            'row': row,
            'column': column,
            'direction': getDirection(row, column).name,
            'distance': getDistance(row, column).name,
            'compassMethod': _buildCompassDescription(row, column),
            'zoomMethod': 'Grid position [$row,$column]',
          },
        );

  @override
  String get className => 'LocationResult';

  factory LocationResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return LocationResult(
      diceResults: diceResults,
      roll: meta['roll'] as int,
      row: meta['row'] as int,
      column: meta['column'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Get compass direction based on position relative to center (row 3, col 3)
  /// Public static method so it can be used by Location class.
  static CompassDirection getDirection(int row, int column) {
    // Center cell
    if (row == 3 && column == 3) return CompassDirection.center;

    // Determine vertical component
    final bool isNorth = row < 3;
    final bool isSouth = row > 3;

    // Determine horizontal component
    final bool isWest = column < 3;
    final bool isEast = column > 3;

    // Cardinal directions (on center row or column)
    if (row == 3) {
      return isWest ? CompassDirection.west : CompassDirection.east;
    }
    if (column == 3) {
      return isNorth ? CompassDirection.north : CompassDirection.south;
    }

    // Intercardinal directions (corners)
    if (isNorth && isWest) return CompassDirection.northWest;
    if (isNorth && isEast) return CompassDirection.northEast;
    if (isSouth && isWest) return CompassDirection.southWest;
    if (isSouth && isEast) return CompassDirection.southEast;

    return CompassDirection.center; // Fallback
  }

  /// Get distance from center (which ring of the bullseye)
  /// Public static method so it can be used by Location class.
  static LocationDistance getDistance(int row, int column) {
    // Center cell (row 3, col 3) = Ring 0
    if (row == 3 && column == 3) return LocationDistance.center;

    // Adjacent to center (rows 2-4, cols 2-4, excluding center) = Ring 1 (Close)
    if (row >= 2 && row <= 4 && column >= 2 && column <= 4) {
      return LocationDistance.close;
    }

    // Outer ring (edge cells) = Ring 2 (Far)
    return LocationDistance.far;
  }

  /// Build compass method description
  static String _buildCompassDescription(int row, int column) {
    final dir = getDirection(row, column);
    final dist = getDistance(row, column);

    if (dir == CompassDirection.center) {
      return 'Here (Center)';
    }

    // Format direction nicely
    String dirStr;
    switch (dir) {
      case CompassDirection.north:
        dirStr = 'North';
        break;
      case CompassDirection.northEast:
        dirStr = 'North-East';
        break;
      case CompassDirection.east:
        dirStr = 'East';
        break;
      case CompassDirection.southEast:
        dirStr = 'South-East';
        break;
      case CompassDirection.south:
        dirStr = 'South';
        break;
      case CompassDirection.southWest:
        dirStr = 'South-West';
        break;
      case CompassDirection.west:
        dirStr = 'West';
        break;
      case CompassDirection.northWest:
        dirStr = 'North-West';
        break;
      case CompassDirection.center:
        dirStr = 'Center';
        break;
    }

    // Distance description
    final distStr = dist == LocationDistance.close ? 'Close' : 'Far';

    return '$dirStr, $distStr';
  }

  static String _buildInterpretation(int row, int column) {
    return _buildCompassDescription(row, column);
  }

  /// Get the grid cell range string (e.g., "48-51")
  String get rangeString {
    final startRange = ((row - 1) * 20) + ((column - 1) * 4);
    final endRange = startRange + 3;
    return '$startRange-$endRange';
  }

  /// Get compass method description (direction + distance)
  String get compassDescription => _buildCompassDescription(row, column);

  /// Get zoom method description (grid position)
  String get zoomDescription => 'Grid position [$row,$column]';

  @override
  String toString() =>
      'Location: $compassDescription (Roll: $roll, Grid [$row,$column])';
}
