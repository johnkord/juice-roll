import 'package:flutter/material.dart';
import '../theme/juice_theme.dart';
import '../shared/oracle_dialog.dart';
import '../../presets/dialog_generator.dart';
import '../../models/roll_result.dart';

/// Dialog for the NPC Dialog Grid mini-game.
/// A 5x5 grid where you maintain position and navigate via 2d10 rolls.
class DialogGeneratorDialog extends StatefulWidget {
  final DialogGenerator dialogGenerator;
  final void Function(RollResult) onRoll;

  const DialogGeneratorDialog({
    super.key,
    required this.dialogGenerator,
    required this.onRoll,
  });

  @override
  State<DialogGeneratorDialog> createState() => _DialogGeneratorDialogState();
}

class _DialogGeneratorDialogState extends State<DialogGeneratorDialog> {
  @override
  void initState() {
    super.initState();
    // If no conversation active, we're at Fact (center)
    if (!widget.dialogGenerator.isConversationActive) {
      widget.dialogGenerator.startConversation();
    }
  }

  void _rollDialog() {
    final result = widget.dialogGenerator.generate();
    widget.onRoll(result);
    // Close dialog to show result in roll history
    Navigator.pop(context);
  }

  void _startNewConversation() {
    widget.dialogGenerator.startConversation();
    setState(() {});
  }

  void _setPosition(int row, int col) {
    widget.dialogGenerator.setPosition(row, col);
    setState(() {});
  }

  Widget _buildGridCell(int row, int col) {
    final fragment = DialogGenerator.grid[row][col];
    final isCurrentPos = row == widget.dialogGenerator.currentRow && 
                        col == widget.dialogGenerator.currentCol;
    final isPastRow = row <= 1;
    
    return GestureDetector(
      onTap: () => _setPosition(row, col),
      child: Container(
        width: 54,
        height: 36,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isCurrentPos 
              ? JuiceTheme.mystic35
              : isPastRow 
                  ? JuiceTheme.sepia15
                  : JuiceTheme.parchment10,
          border: Border.all(
            color: isCurrentPos 
                ? JuiceTheme.mystic 
                : isPastRow 
                    ? JuiceTheme.sepia40
                    : Colors.grey.withOpacity(0.3),
            width: isCurrentPos ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            fragment,
            style: TextStyle(
              fontSize: 9,
              fontFamily: JuiceTheme.fontFamilySerif,
              fontWeight: isCurrentPos ? FontWeight.bold : FontWeight.normal,
              fontStyle: isPastRow ? FontStyle.italic : FontStyle.normal,
              color: isCurrentPos 
                  ? JuiceTheme.mystic 
                  : isPastRow 
                      ? JuiceTheme.sepia 
                      : Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return Column(
      children: [
        // Row labels for Past/Present with sepia styling
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Top 2 rows = ', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
              Text('Past', style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: JuiceTheme.sepia)),
              Text(' / Bottom 3 = ', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
              const Text('Present', style: TextStyle(fontSize: 10)),
            ],
          ),
        ),
        // The 5x5 grid
        for (int row = 0; row < 5; row++)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int col = 0; col < 5; col++)
                _buildGridCell(row, col),
            ],
          ),
      ],
    );
  }
  
  Widget _buildToneLegendChip(String tone, String direction, String range, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            direction,
            style: TextStyle(fontSize: 11, color: color),
          ),
          const SizedBox(width: 3),
          Text(
            tone,
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            range,
            style: TextStyle(
              fontSize: 8,
              fontFamily: JuiceTheme.fontFamilyMono,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.dialogGenerator.isConversationActive;
    final currentFragment = widget.dialogGenerator.currentPositionLabel;
    final isPast = widget.dialogGenerator.isCurrentPast;
    final dialogColor = JuiceTheme.mystic;
    
    return OracleDialog(
      icon: Icons.forum,
      title: 'NPC Dialog Grid',
      accentColor: dialogColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              // Instructions header
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: dialogColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: dialogColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tips_and_updates, size: 14, color: dialogColor),
                        const SizedBox(width: 4),
                        Text(
                          'A mini-game to generate NPC conversations.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: dialogColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '• Tap any cell to set your starting position\n'
                      '• Roll 2d10: 1st = Direction + Tone, 2nd = Subject\n'
                      '• Doubles = Conversation ends\n'
                      '• Edges wrap around',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              // The grid
              _buildGrid(),
              const SizedBox(height: 10),
              
              // Current state panel
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isActive 
                      ? JuiceTheme.success10
                      : JuiceTheme.juiceOrange10,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive ? JuiceTheme.success : JuiceTheme.juiceOrange,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isActive ? Icons.record_voice_over : Icons.voice_over_off,
                          size: 16,
                          color: isActive ? JuiceTheme.success : JuiceTheme.juiceOrange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isActive ? 'Conversation Active' : 'Conversation Ended',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isActive ? JuiceTheme.success : JuiceTheme.juiceOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Current: ',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: dialogColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            currentFragment,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: JuiceTheme.fontFamilySerif,
                              fontStyle: isPast ? FontStyle.italic : FontStyle.normal,
                              color: dialogColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isPast 
                                ? JuiceTheme.sepia20
                                : Colors.grey.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isPast ? 'Past' : 'Present',
                            style: TextStyle(
                              fontSize: 10,
                              fontStyle: isPast ? FontStyle.italic : FontStyle.normal,
                              color: isPast ? JuiceTheme.sepia : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (DialogGenerator.fragmentDescriptions[currentFragment] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        DialogGenerator.fragmentDescriptions[currentFragment]!,
                        style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              // Action buttons - moved above the legend
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _rollDialog,
                      icon: const Icon(Icons.casino, size: 18),
                      label: Text(isActive ? 'Roll 2d10' : 'Roll (New)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dialogColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _startNewConversation,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Reset to Fact (center)',
                    style: IconButton.styleFrom(
                      backgroundColor: JuiceTheme.success20,
                      foregroundColor: JuiceTheme.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              // Direction/Tone legend - compact 2x2 grid
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1st Die (Direction + Tone):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildToneLegendChip('Neutral', '↑', '1-2', JuiceTheme.info),
                        _buildToneLegendChip('Defensive', '←', '3-5', JuiceTheme.rust),
                        _buildToneLegendChip('Aggressive', '→', '6-8', JuiceTheme.danger),
                        _buildToneLegendChip('Helpful', '↓', '9-0', JuiceTheme.success),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '2nd Die (Subject):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '1-2: Them  •  3-5: Me  •  6-8: You  •  9-0: Us',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: JuiceTheme.fontFamilyMono,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
  }
}
