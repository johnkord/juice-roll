import 'package:flutter/material.dart';
import '../theme/juice_theme.dart';
import '../shared/oracle_dialog.dart';
import '../../presets/location.dart';
import '../../models/roll_result.dart';

/// Dialog for Location Grid options.
/// A 5x5 bullseye grid for determining direction and distance.
class LocationDialog extends StatelessWidget {
  final void Function(RollResult) onRoll;

  // Theme color for location - rust for exploration/maps
  static const Color _locationColor = JuiceTheme.rust;
  static const Color _compassColor = JuiceTheme.categoryExplore;
  static const Color _zoomColor = JuiceTheme.mystic;

  const LocationDialog({
    super.key,
    required this.onRoll,
  });

  // Build a method card with icon and description
  Widget _buildMethodCard({
    required String title,
    required IconData icon,
    required String description,
    required String useFor,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: JuiceTheme.fontFamilySerif,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              fontSize: 11,
              color: JuiceTheme.parchment90,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lightbulb_outline, size: 12, color: color.withOpacity(0.8)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    useFor,
                    style: TextStyle(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: color.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build the visual grid representation
  Widget _buildGridVisual() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: JuiceTheme.inkDark50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _locationColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // North label
          Text(
            'N',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: JuiceTheme.fontFamilyMono,
              color: _compassColor,
            ),
          ),
          const SizedBox(height: 4),
          // Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // West label
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  'W',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: JuiceTheme.fontFamilyMono,
                    color: _compassColor,
                  ),
                ),
              ),
              // 5x5 grid
              Column(
                children: List.generate(5, (row) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (col) {
                      // Determine ring: 0=center, 1=close, 2=far
                      final isCenter = row == 2 && col == 2;
                      final isClose = !isCenter && 
                          row >= 1 && row <= 3 && 
                          col >= 1 && col <= 3;
                      
                      Color cellColor;
                      String symbol;
                      if (isCenter) {
                        cellColor = JuiceTheme.gold;
                        symbol = '◉';
                      } else if (isClose) {
                        cellColor = _locationColor;
                        symbol = '○';
                      } else {
                        cellColor = JuiceTheme.parchmentDark;
                        symbol = '·';
                      }
                      
                      return Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: cellColor.withOpacity(isCenter ? 0.3 : 0.15),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: cellColor.withOpacity(0.4),
                            width: isCenter ? 1.5 : 0.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            symbol,
                            style: TextStyle(
                              fontSize: 12,
                              color: cellColor,
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
              // East label
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'E',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: JuiceTheme.fontFamilyMono,
                    color: _compassColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // South label
          Text(
            'S',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: JuiceTheme.fontFamilyMono,
              color: _compassColor,
            ),
          ),
          const SizedBox(height: 10),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('◉', 'Center', JuiceTheme.gold),
              const SizedBox(width: 16),
              _buildLegendItem('○', 'Close', _locationColor),
              const SizedBox(width: 16),
              _buildLegendItem('·', 'Far', JuiceTheme.parchmentDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String symbol, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          symbol,
          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: JuiceTheme.parchment70,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return OracleDialog(
      icon: Icons.grid_on,
      accentColor: _locationColor,
      title: 'Location Grid',
      closeButtonText: 'Close',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Introduction
          OracleDialogIntro(
            icon: Icons.info_outline,
            iconColor: _locationColor,
            backgroundColor: _locationColor.withOpacity(0.08),
            borderColor: _locationColor.withOpacity(0.2),
            text: 'A 5×5 bullseye grid. Roll 1d100 to get both a direction and a distance.',
          ),
          const SizedBox(height: 12),
          
          // Compass Method
          _buildMethodCard(
            title: 'Compass Method',
            icon: Icons.explore,
            color: _compassColor,
            description: 'Imagine your PC at the center. Roll to get:\n'
                '• Direction (N, S, E, W, NE, NW, SE, SW)\n'
                '• Distance (Close or Far based on ring)',
            useFor: 'Next town, hex population, travel days, roads',
          ),
          
          // Zoom Method
          _buildMethodCard(
            title: 'Zoom Method',
            icon: Icons.zoom_in,
            color: _zoomColor,
            description: 'Use iterative zooming:\n'
                '1. Grid overlays world map → roll to zoom in\n'
                '2. Grid overlays region → roll again\n'
                '3. Grid overlays settlement → roll for building\n'
                '4. Keep zooming until you have your answer',
            useFor: 'Remote Events, hidden treasure locations',
          ),
          
          const SizedBox(height: 16),
          
          // Roll button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _locationColor,
                  _locationColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: _locationColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  onRoll(Location.roll());
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.casino, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Roll 1d100',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: JuiceTheme.fontFamilyMono,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Visual Grid
          _buildGridVisual(),
        ],
      ),
    );
  }
}
