import 'package:flutter/material.dart';
import '../../models/roll_result.dart';
import '../../presets/details.dart';
import '../theme/juice_theme.dart';
import '../shared/oracle_dialog.dart';

/// Dialog for Details options.
class DetailsDialog extends StatelessWidget {
  final Details details;
  final void Function(RollResult) onRoll;

  const DetailsDialog({
    super.key,
    required this.details,
    required this.onRoll,
  });

  // Section theme colors
  static const Color _colorSectionColor = Color(0xFF6B8EAE); // Blue-ish
  static const Color _propertySectionColor = JuiceTheme.gold;
  static const Color _detailSectionColor = JuiceTheme.mystic;
  static const Color _historySectionColor = JuiceTheme.rust;

  @override
  Widget build(BuildContext context) {
    return OracleDialog(
      title: 'Details',
      subtitle: 'Front Page',
      icon: Icons.auto_fix_high,
      accentColor: JuiceTheme.gold,
      secondaryColor: JuiceTheme.juiceOrange20,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Introduction
          const OracleDialogIntro(
            text: 'Add flavor to NPCs, items, settlements, or interpret oracle results.',
            icon: Icons.lightbulb_outline,
          ),
          const SizedBox(height: 14),
          
          // ═══════════════════════════════════════════════════════════════
          // COLOR SECTION
          // ═══════════════════════════════════════════════════════════════
          OracleDialogSection(
            icon: Icons.palette,
            title: 'Color',
            color: _colorSectionColor,
            description: 'Eye/hair color, armor accents, banners, dragon species...',
            child: Column(
              children: [
                // Color swatches preview
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: JuiceTheme.inkDark50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _colorSwatch(Colors.black87),
                      _colorSwatch(Colors.brown),
                      _colorSwatch(Colors.yellow.shade700),
                      _colorSwatch(Colors.green.shade700),
                      _colorSwatch(Colors.blue.shade700),
                      _colorSwatch(Colors.red.shade700),
                      _colorSwatch(Colors.purple.shade400),
                      _colorSwatch(Colors.grey.shade400),
                      _colorSwatch(Colors.amber),
                      _colorSwatch(Colors.white70),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                OracleRollButton(
                  label: 'Roll Color',
                  subtitle: 'd10',
                  icon: Icons.colorize,
                  color: _colorSectionColor,
                  onTap: () {
                    onRoll(details.rollColor());
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // ═══════════════════════════════════════════════════════════════
          // PROPERTY SECTION - ESSENTIAL
          // ═══════════════════════════════════════════════════════════════
          OracleDialogSection(
            icon: Icons.tune,
            title: 'Property',
            color: _propertySectionColor,
            isHighlighted: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Essential badge row
                Row(
                  children: [
                    const OracleDialogBadge(
                      label: 'ESSENTIAL',
                      icon: Icons.star,
                      color: JuiceTheme.gold,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Quote
                const OracleDialogQuote(
                  text: '"If you only take one table from this whole thing, take this one."',
                  borderColor: JuiceTheme.gold,
                ),
                const SizedBox(height: 10),
                // Property & Intensity reference
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: JuiceTheme.inkDark30,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: JuiceTheme.rust30,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: const Text('d10', 
                                    style: TextStyle(
                                      fontSize: 9, 
                                      fontFamily: JuiceTheme.fontFamilyMono,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text('Property', 
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'Age • Size • Value • Style • Power • Quality...',
                              style: TextStyle(fontSize: 9, color: JuiceTheme.parchmentDark),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: JuiceTheme.inkDark30,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: JuiceTheme.info30,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: const Text('d6', 
                                    style: TextStyle(
                                      fontSize: 9, 
                                      fontFamily: JuiceTheme.fontFamilyMono,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text('Intensity', 
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'Minimal → Minor → Mundane → Major → Max',
                              style: TextStyle(fontSize: 9, color: JuiceTheme.parchmentDark),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Roll buttons
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: OracleRollButton(
                        label: 'Property ×2',
                        subtitle: 'Recommended',
                        icon: Icons.content_copy,
                        color: _propertySectionColor,
                        isPrimary: true,
                        onTap: () {
                          onRoll(details.rollTwoProperties());
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: OracleRollButton(
                        label: '×1',
                        subtitle: 'Single',
                        icon: Icons.looks_one,
                        color: _propertySectionColor,
                        onTap: () {
                          onRoll(details.rollProperty());
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // ═══════════════════════════════════════════════════════════════
          // DETAIL SECTION
          // ═══════════════════════════════════════════════════════════════
          OracleDialogSection(
            icon: Icons.help_outline,
            title: 'Detail',
            color: _detailSectionColor,
            description: 'Oracle threw a curveball? Ground meaning to a thread, character, or emotion.',
            child: Column(
              children: [
                OracleRollButton(
                  label: 'Roll Detail',
                  subtitle: 'Emotion / Favors / Disfavors (PC, Thread, NPC)',
                  icon: Icons.casino,
                  color: _detailSectionColor,
                  onTap: () {
                    onRoll(details.rollDetailWithFollowUp());
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OracleSkewButton(
                        label: 'Positive',
                        subtitle: 'Favorable',
                        icon: Icons.thumb_up_outlined,
                        color: JuiceTheme.success,
                        onTap: () {
                          onRoll(details.rollDetailWithFollowUp(skew: SkewType.advantage));
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OracleSkewButton(
                        label: 'Negative',
                        subtitle: 'Unfavorable',
                        icon: Icons.thumb_down_outlined,
                        color: JuiceTheme.danger,
                        onTap: () {
                          onRoll(details.rollDetailWithFollowUp(skew: SkewType.disadvantage));
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // ═══════════════════════════════════════════════════════════════
          // HISTORY SECTION
          // ═══════════════════════════════════════════════════════════════
          OracleDialogSection(
            icon: Icons.history,
            title: 'History',
            color: _historySectionColor,
            description: 'Tie elements to the past: backstory, past scenes, previous actions, or threads.',
            child: Column(
              children: [
                OracleRollButton(
                  label: 'Roll History',
                  subtitle: 'Backstory → Past Thread → Current Action...',
                  icon: Icons.auto_stories,
                  color: _historySectionColor,
                  onTap: () {
                    onRoll(details.rollHistory());
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OracleSkewButton(
                        label: 'Recent',
                        subtitle: 'Present',
                        icon: Icons.update,
                        color: JuiceTheme.info,
                        onTap: () {
                          onRoll(details.rollHistory(skew: SkewType.advantage));
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OracleSkewButton(
                        label: 'Distant',
                        subtitle: 'Past',
                        icon: Icons.hourglass_empty,
                        color: JuiceTheme.sepia,
                        onTap: () {
                          onRoll(details.rollHistory(skew: SkewType.disadvantage));
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorSwatch(Color color) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: JuiceTheme.parchmentDark30,
          width: 0.5,
        ),
      ),
    );
  }
}
