import '../core/roll_engine.dart';
import '../models/roll_result.dart';

/// Cardinal directions for location description
enum CardinalDirection {
  north,
  south,
  east,
  west,
  center,
}

/// Horizontal position on the grid
enum HorizontalPosition {
  west,    // Columns 1-2
  center,  // Column 3
  east,    // Columns 4-5
}

/// Vertical position on the grid
enum VerticalPosition {
  north,   // Rows 1-2
  center,  // Row 3
  south,   // Rows 4-5
}

/// Result of a location grid roll
class LocationResult extends RollResult {
  final int roll;               // 0-99 (from 1d100)
  final int row;                // 1-5 (top to bottom)
  final int column;             // 1-5 (left to right)
  final HorizontalPosition horizontalPosition;
  final VerticalPosition verticalPosition;

  LocationResult({
    required List<int> diceResults,
    required this.roll,
    required this.row,
    required this.column,
  }) : horizontalPosition = _getHorizontalPosition(column),
       verticalPosition = _getVerticalPosition(row),
       super(
          type: RollType.tableLookup,
          description: 'Location Grid',
          diceResults: diceResults,
          total: roll,
          interpretation: _buildInterpretation(row, column),
          metadata: {
            'roll': roll,
            'row': row,
            'column': column,
            'horizontalPosition': _getHorizontalPosition(column).name,
            'verticalPosition': _getVerticalPosition(row).name,
          },
        );

  static HorizontalPosition _getHorizontalPosition(int column) {
    if (column <= 2) return HorizontalPosition.west;
    if (column == 3) return HorizontalPosition.center;
    return HorizontalPosition.east;
  }

  static VerticalPosition _getVerticalPosition(int row) {
    if (row <= 2) return VerticalPosition.north;
    if (row == 3) return VerticalPosition.center;
    return VerticalPosition.south;
  }

  static String _buildInterpretation(int row, int column) {
    final hPos = _getHorizontalPosition(column);
    final vPos = _getVerticalPosition(row);
    
    // Handle center-center case
    if (hPos == HorizontalPosition.center && vPos == VerticalPosition.center) {
      return 'Center';
    }

    final parts = <String>[];
    
    // Add vertical position
    if (vPos != VerticalPosition.center) {
      parts.add(vPos.name[0].toUpperCase() + vPos.name.substring(1));
    }
    
    // Add horizontal position
    if (hPos != HorizontalPosition.center) {
      parts.add(hPos.name[0].toUpperCase() + hPos.name.substring(1));
    }

    return parts.isEmpty ? 'Center' : parts.join('-');
  }

  /// Get the grid cell range string (e.g., "48-51")
  String get rangeString {
    final startRange = ((row - 1) * 20) + ((column - 1) * 4);
    final endRange = startRange + 3;
    return '$startRange-$endRange';
  }

  /// Get the position description
  String get positionDescription => _buildInterpretation(row, column);

  @override
  String toString() => 'Location: Grid [$row,$column]: $positionDescription (Roll: $roll)';
}

/// Location grid generator using 1d100 to determine position on a 5×5 grid
class Location {
  static final RollEngine _engine = RollEngine();

  /// Grid ranges for each cell
  /// The grid is organized as:
  ///   - 5 columns × 5 rows = 25 cells
  ///   - Each cell covers 4 consecutive numbers (0-3, 4-7, etc.)
  ///   - Total: 100 possible values (0-99 from d100 treating 100 as 00)
  static const List<List<List<int>>> gridRanges = [
    // Row 1 (North)
    [[0, 3], [4, 7], [8, 11], [12, 15], [16, 19]],
    // Row 2
    [[20, 23], [24, 27], [28, 31], [32, 35], [36, 39]],
    // Row 3 (Center)
    [[40, 43], [44, 47], [48, 51], [52, 55], [56, 59]],
    // Row 4
    [[60, 63], [64, 67], [68, 71], [72, 75], [76, 79]],
    // Row 5 (South)
    [[80, 83], [84, 87], [88, 91], [92, 95], [96, 99]],
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

  /// Get all cells in a direction
  static List<List<int>> getCellsInDirection(CardinalDirection direction) {
    switch (direction) {
      case CardinalDirection.north:
        // Rows 1-2
        return [
          for (var row = 0; row < 2; row++)
            for (var col = 0; col < 5; col++)
              [row + 1, col + 1]
        ];
      case CardinalDirection.south:
        // Rows 4-5
        return [
          for (var row = 3; row < 5; row++)
            for (var col = 0; col < 5; col++)
              [row + 1, col + 1]
        ];
      case CardinalDirection.west:
        // Columns 1-2
        return [
          for (var row = 0; row < 5; row++)
            for (var col = 0; col < 2; col++)
              [row + 1, col + 1]
        ];
      case CardinalDirection.east:
        // Columns 4-5
        return [
          for (var row = 0; row < 5; row++)
            for (var col = 3; col < 5; col++)
              [row + 1, col + 1]
        ];
      case CardinalDirection.center:
        // Row 3, Column 3
        return [[3, 3]];
    }
  }

  /// Generate an ASCII representation of the grid
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
        
        // Highlight if the roll falls in this cell
        if (highlightRoll != null && 
            highlightRoll >= range[0] && 
            highlightRoll <= range[1]) {
          buffer.write('[${rangeStr}]');
        } else {
          buffer.write(' $rangeStr ');
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
    
    return buffer.toString();
  }
}
