import 'package:flutter/material.dart';
import '../theme/juice_theme.dart';
import '../shared/oracle_dialog.dart';
import '../../presets/abstract_icons.dart';
import '../../models/roll_result.dart';

/// Dialog for Abstract Icons.
/// Based on Juice Oracle Right Extension - Roll 1d10 + 1d6 to pick an icon.
class AbstractIconsDialog extends StatelessWidget {
  final AbstractIcons abstractIcons;
  final void Function(RollResult) onRoll;

  // Theme colors - success green for abstract/visual creativity
  static const Color _iconColor = JuiceTheme.success;
  static const Color _gridColor = JuiceTheme.mystic;

  const AbstractIconsDialog({
    super.key,
    required this.abstractIcons,
    required this.onRoll,
  });

  // Build a use case item
  Widget _buildUseCase(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: _iconColor.withOpacity(0.8)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: JuiceTheme.parchment90,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build a grid cell preview
  Widget _buildGridCell(int row, int col, {bool isHighlighted = false}) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isHighlighted 
            ? _iconColor.withOpacity(0.4)
            : JuiceTheme.inkDark60,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: isHighlighted 
              ? _iconColor 
              : JuiceTheme.parchmentDark30,
          width: isHighlighted ? 1.5 : 0.5,
        ),
      ),
      child: isHighlighted
          ? Icon(Icons.image, size: 12, color: _iconColor)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return OracleDialog(
      icon: Icons.auto_awesome,
      title: 'Abstract Icons',
      accentColor: _iconColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              // Header explanation
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _iconColor.withOpacity(0.12),
                      _iconColor.withOpacity(0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _iconColor.withOpacity(0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.palette, size: 14, color: _iconColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Visual Inspiration • Symbol Interpretation',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _iconColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Roll 1d10 + 1d6 to pick an icon. These abstract images can be '
                      'used for inspiration instead of words. Inspired by Rory\'s Story Cubes.',
                      style: TextStyle(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: JuiceTheme.parchment85,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              
              // Mini grid visualization
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: JuiceTheme.inkDark50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _gridColor.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    // Grid header
                    Row(
                      children: [
                        Icon(Icons.grid_view, size: 14, color: _gridColor),
                        const SizedBox(width: 6),
                        Text(
                          'Icon Grid',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _gridColor,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _gridColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '10 × 6 = 60 icons',
                            style: TextStyle(
                              fontSize: 9,
                              fontFamily: JuiceTheme.fontFamilyMono,
                              color: _gridColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Mini grid preview (showing 4x4 sample)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Row labels
                        Column(
                          children: [
                            const SizedBox(height: 22),  // Offset for column labels
                            for (int r = 1; r <= 4; r++)
                              Container(
                                width: 16,
                                height: 20,
                                margin: const EdgeInsets.only(bottom: 2),
                                alignment: Alignment.center,
                                child: Text(
                                  '$r',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontFamily: JuiceTheme.fontFamilyMono,
                                    color: JuiceTheme.parchmentDark,
                                  ),
                                ),
                              ),
                            Container(
                              width: 16,
                              height: 20,
                              alignment: Alignment.center,
                              child: Text(
                                '⋮',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: JuiceTheme.parchmentDark60,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),
                        // Grid cells
                        Column(
                          children: [
                            // Column labels
                            Row(
                              children: [
                                for (int c = 1; c <= 4; c++)
                                  Container(
                                    width: 20,
                                    height: 16,
                                    margin: const EdgeInsets.only(right: 2),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$c',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontFamily: JuiceTheme.fontFamilyMono,
                                        color: JuiceTheme.parchmentDark,
                                      ),
                                    ),
                                  ),
                                Container(
                                  width: 20,
                                  height: 16,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '⋯',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: JuiceTheme.parchmentDark60,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Grid rows
                            for (int r = 1; r <= 4; r++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Row(
                                  children: [
                                    for (int c = 1; c <= 4; c++)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 2),
                                        child: _buildGridCell(r, c, isHighlighted: r == 2 && c == 3),
                                      ),
                                    Container(
                                      width: 20,
                                      height: 20,
                                      alignment: Alignment.center,
                                      child: Text(
                                        '⋯',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: JuiceTheme.parchmentDark40,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // Ellipsis row
                            Row(
                              children: [
                                for (int c = 1; c <= 5; c++)
                                  Container(
                                    width: 20,
                                    height: 20,
                                    margin: const EdgeInsets.only(right: 2),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '⋮',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: JuiceTheme.parchmentDark40,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Dice indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: JuiceTheme.rust15,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: JuiceTheme.rust40),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.casino, size: 12, color: JuiceTheme.rust),
                              const SizedBox(width: 4),
                              Text(
                                '1d10 → Row',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: JuiceTheme.fontFamilyMono,
                                  fontWeight: FontWeight.bold,
                                  color: JuiceTheme.rust,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: JuiceTheme.info15,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: JuiceTheme.info40),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.casino, size: 12, color: JuiceTheme.info),
                              const SizedBox(width: 4),
                              Text(
                                '1d6 → Col',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: JuiceTheme.fontFamilyMono,
                                  fontWeight: FontWeight.bold,
                                  color: JuiceTheme.info,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              
              // Usage hints section
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: JuiceTheme.inkDark40,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, size: 14, color: JuiceTheme.gold),
                        const SizedBox(width: 6),
                        Text(
                          'Uses',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: JuiceTheme.fontFamilySerif,
                            color: JuiceTheme.gold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildUseCase(Icons.swap_horiz, 'Alternative to word-based meaning tables'),
                    _buildUseCase(Icons.visibility, 'Visual inspiration for scenes or encounters'),
                    _buildUseCase(Icons.psychology, 'Interpret the symbol in your current context'),
                    _buildUseCase(Icons.layers, 'Use multiple icons for complex situations'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              
              // Roll button
              InkWell(
                onTap: () {
                  final result = abstractIcons.generate();
                  onRoll(result);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _iconColor,
                        _iconColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _iconColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, size: 20, color: JuiceTheme.inkDark),
                      const SizedBox(width: 10),
                      Text(
                        'Roll 1d10 + 1d6',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: JuiceTheme.fontFamilyMono,
                          color: JuiceTheme.inkDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Grid reference footer
              Center(
                child: Text(
                  'Rows: 1-9, 0  •  Columns: 1-6',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: JuiceTheme.fontFamilyMono,
                    color: JuiceTheme.parchmentDark70,
                  ),
                ),
              ),
            ],
          ),
        );
  }
}
