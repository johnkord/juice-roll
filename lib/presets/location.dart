import '../core/roll_engine.dart';
import '../models/roll_result.dart';

/// Distance from center (rings of the bullseye)
enum LocationDistance {
  center,     // Ring 0: Center cell only (row 3, col 3)
  close,      // Ring 1: Adjacent to center (rows 2-4, cols 2-4, excluding center)
  far,        // Ring 2: Outer ring (edge cells)
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
  final int roll;               // 0-99 (from 1d100)
  final int row;                // 1-5 (top to bottom)
  final int column;             // 1-5 (left to right)
  final CompassDirection direction;
  final LocationDistance distance;

  LocationResult({
    required List<int> diceResults,
    required this.roll,
    required this.row,
    required this.column,
    DateTime? timestamp,
  }) : direction = _getDirection(row, column),
       distance = _getDistance(row, column),
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
            'direction': _getDirection(row, column).name,
            'distance': _getDistance(row, column).name,
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
  static CompassDirection _getDirection(int row, int column) {
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
  static LocationDistance _getDistance(int row, int column) {
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
    final dir = _getDirection(row, column);
    final dist = _getDistance(row, column);
    
    if (dir == CompassDirection.center) {
      return 'Here (Center)';
    }
    
    // Format direction nicely
    String dirStr;
    switch (dir) {
      case CompassDirection.north: dirStr = 'North'; break;
      case CompassDirection.northEast: dirStr = 'North-East'; break;
      case CompassDirection.east: dirStr = 'East'; break;
      case CompassDirection.southEast: dirStr = 'South-East'; break;
      case CompassDirection.south: dirStr = 'South'; break;
      case CompassDirection.southWest: dirStr = 'South-West'; break;
      case CompassDirection.west: dirStr = 'West'; break;
      case CompassDirection.northWest: dirStr = 'North-West'; break;
      case CompassDirection.center: dirStr = 'Center'; break;
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
  String toString() => 'Location: $compassDescription (Roll: $roll, Grid [$row,$column])';
}

/// Location grid generator using 1d100 to determine position on a 5×5 grid
/// 
/// The grid is 5x5, colored like a bullseye:
/// - Center (row 3, col 3): The origin point
/// - Close (Ring 1): Cells adjacent to center
/// - Far (Ring 2): Edge/corner cells
/// 
/// Two methods of use:
/// 1. Compass Method: Direction + Distance from center
/// 2. Zoom Method: Iterative zooming into regions
class Location {
  static final RollEngine _engine = RollEngine();

  /// Grid ranges for each cell
  /// The grid is organized as:
  ///   - 5 columns × 5 rows = 25 cells
  ///   - Each cell covers 4 consecutive numbers (0-3, 4-7, etc.)
  ///   - Total: 100 possible values (0-99 from d100 treating 100 as 00)
  static const List<List<List<int>>> gridRanges = [
    // Row 1 (North) - Far
    [[0, 3], [4, 7], [8, 11], [12, 15], [16, 19]],
    // Row 2 - Mixed (edges Far, middle Close)
    [[20, 23], [24, 27], [28, 31], [32, 35], [36, 39]],
    // Row 3 (Center row) - Mixed (edges Far, middle Close, center Center)
    [[40, 43], [44, 47], [48, 51], [52, 55], [56, 59]],
    // Row 4 - Mixed (edges Far, middle Close)
    [[60, 63], [64, 67], [68, 71], [72, 75], [76, 79]],
    // Row 5 (South) - Far
    [[80, 83], [84, 87], [88, 91], [92, 95], [96, 99]],
  ];

  /// Distance ring for each cell (0 = center, 1 = close, 2 = far)
  static const List<List<int>> distanceRings = [
    [2, 2, 2, 2, 2],  // Row 1: all far
    [2, 1, 1, 1, 2],  // Row 2: edges far, middle close
    [2, 1, 0, 1, 2],  // Row 3: edges far, close, center
    [2, 1, 1, 1, 2],  // Row 4: edges far, middle close
    [2, 2, 2, 2, 2],  // Row 5: all far
  ];

  /// Roll 1d100 and determine grid position
  static LocationResult roll() {
    final rollResult = _engine.rollNdX(1, 100);
    // Treat 100 as 00 (index 0)
    final rollValue = rollResult == 100 ? 0 : rollResult - 1;  // Convert to 0-99
    
    return fromValue(rollValue, [rollResult]);
  }

  /// Get location from a specific value (0-99)
  static LocationResult fromValue(int value, [List<int>? diceResults]) {
    final clampedValue = value.clamp(0, 99);
    
    // Calculate row and column from value
    // Each row contains 20 values (5 columns × 4 values each)
    // Each column contains 4 values
    final row = (clampedValue ~/ 20) + 1;  // 1-5
    final columnOffset = clampedValue % 20;
    final column = (columnOffset ~/ 4) + 1;  // 1-5

    return LocationResult(
      diceResults: diceResults ?? [clampedValue],
      roll: clampedValue,
      row: row,
      column: column,
    );
  }

  /// Get the range for a specific grid cell
  static List<int> getRangeForCell(int row, int column) {
    final clampedRow = row.clamp(1, 5);
    final clampedColumn = column.clamp(1, 5);
    return gridRanges[clampedRow - 1][clampedColumn - 1];
  }

  /// Check if a value falls within a specific grid cell
  static bool isInCell(int value, int row, int column) {
    final range = getRangeForCell(row, column);
    return value >= range[0] && value <= range[1];
  }

  /// Get the distance ring for a cell (0 = center, 1 = close, 2 = far)
  static int getDistanceRing(int row, int column) {
    final clampedRow = row.clamp(1, 5);
    final clampedColumn = column.clamp(1, 5);
    return distanceRings[clampedRow - 1][clampedColumn - 1];
  }

  /// Get all cells at a specific distance
  static List<List<int>> getCellsAtDistance(LocationDistance distance) {
    final cells = <List<int>>[];
    final targetRing = distance == LocationDistance.center ? 0 
        : distance == LocationDistance.close ? 1 : 2;
    
    for (var row = 1; row <= 5; row++) {
      for (var col = 1; col <= 5; col++) {
        if (getDistanceRing(row, col) == targetRing) {
          cells.add([row, col]);
        }
      }
    }
    return cells;
  }

  /// Get all cells in a compass direction
  static List<List<int>> getCellsInDirection(CompassDirection direction) {
    final cells = <List<int>>[];
    
    for (var row = 1; row <= 5; row++) {
      for (var col = 1; col <= 5; col++) {
        final cellDir = LocationResult._getDirection(row, col);
        if (cellDir == direction) {
          cells.add([row, col]);
        }
      }
    }
    return cells;
  }

  /// Generate an ASCII representation of the grid with bullseye rings
  static String getGridDisplay({int? highlightRoll}) {
    final buffer = StringBuffer();
    buffer.writeln('                        North');
    buffer.writeln('        ┌───────┬───────┬───────┬───────┬───────┐');
    
    for (var row = 0; row < 5; row++) {
      final westLabel = row == 2 ? '  West  ' : '        ';
      final eastLabel = row == 2 ? '  East' : '';
      
      buffer.write(westLabel);
      buffer.write('│');
      
      for (var col = 0; col < 5; col++) {
        final range = gridRanges[row][col];
        final rangeStr = '${range[0].toString().padLeft(2)}-${range[1].toString().padLeft(2)}';
        final ring = distanceRings[row][col];
        
        // Highlight if the roll falls in this cell
        if (highlightRoll != null && 
            highlightRoll >= range[0] && 
            highlightRoll <= range[1]) {
          buffer.write('[${rangeStr}]');
        } else {
          // Show ring indicator
          final ringChar = ring == 0 ? '◉' : (ring == 1 ? '○' : '·');
          buffer.write('$ringChar$rangeStr$ringChar');
        }
        buffer.write('│');
      }
      buffer.writeln(eastLabel);
      
      if (row < 4) {
        buffer.writeln('        ├───────┼───────┼───────┼───────┼───────┤');
      }
    }
    
    buffer.writeln('        └───────┴───────┴───────┴───────┴───────┘');
    buffer.writeln('                        South');
    buffer.writeln('');
    buffer.writeln('◉ = Center  ○ = Close  · = Far');
    
    return buffer.toString();
  }
}
