import 'package:flutter/material.dart';
import '../../models/roll_result.dart';
import '../../presets/name_generator.dart';
import '../theme/juice_theme.dart';

/// Dialog for Name Generator options.
class NameGeneratorDialog extends StatelessWidget {
  final NameGenerator nameGenerator;
  final void Function(RollResult) onRoll;

  const NameGeneratorDialog({
    super.key,
    required this.nameGenerator,
    required this.onRoll,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Name Generator',
        style: TextStyle(
          fontFamily: JuiceTheme.fontFamilySerif,
          color: JuiceTheme.parchment,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simple Method section
            const _NameSectionHeader(
              icon: Icons.casino,
              title: 'Simple Method',
              subtitle: 'Quick random names using 3d20',
            ),
            const SizedBox(height: 6),
            _NameDialogOption(
              title: '3d20 (Columns 1,2,3)',
              subtitle: 'Roll on all three columns',
              icon: Icons.grid_3x3,
              iconColor: JuiceTheme.gold,
              onTap: () {
                onRoll(nameGenerator.generate());
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 4),
            _NameDialogOption(
              title: '3d20 (Column 1 Only)',
              subtitle: 'Roll on column 1 three times',
              icon: Icons.view_column,
              iconColor: JuiceTheme.juiceOrange,
              onTap: () {
                onRoll(nameGenerator.generateColumn1Only());
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            
            // Pattern Method section
            const _NameSectionHeader(
              icon: Icons.pattern,
              title: 'Pattern Method',
              subtitle: 'Use pattern column for structured names',
            ),
            const SizedBox(height: 6),
            _NameDialogOption(
              title: 'Neutral',
              subtitle: 'Roll 1d20 for pattern',
              icon: Icons.balance,
              iconColor: JuiceTheme.parchmentDark,
              onTap: () {
                onRoll(nameGenerator.generatePatternNeutral());
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 4),
            // Masculine/Feminine row
            Row(
              children: [
                Expanded(
                  child: _NameGenderOption(
                    title: 'Masculine',
                    subtitle: '@- (disadvantage)',
                    icon: Icons.arrow_downward,
                    color: JuiceTheme.info,
                    onTap: () {
                      onRoll(nameGenerator.generateMasculine());
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _NameGenderOption(
                    title: 'Feminine',
                    subtitle: '@+ (advantage)',
                    icon: Icons.arrow_upward,
                    color: JuiceTheme.categoryCharacter,
                    onTap: () {
                      onRoll(nameGenerator.generateFeminine());
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Info box
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: JuiceTheme.parchmentDark.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, size: 12, color: JuiceTheme.gold),
                      const SizedBox(width: 4),
                      Text(
                        'Examples',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: JuiceTheme.gold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Simple: Tolimaea, Mayosid, Nenetar\n'
                    '• Masculine: Osuma, Likel, Risan\n'
                    '• Feminine: Nedeli, Eyosi, Kisora',
                    style: TextStyle(
                      fontSize: 9,
                      fontStyle: FontStyle.italic,
                      color: JuiceTheme.parchmentDark,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: JuiceTheme.parchmentDark)),
        ),
      ],
    );
  }
}

// =============================================================================
// HELPER WIDGETS (Private to this file)
// =============================================================================

/// Section header for Name Generator dialog.
class _NameSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _NameSectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: JuiceTheme.gold),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: JuiceTheme.parchment,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9,
                color: JuiceTheme.parchmentDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Dialog option for Name Generator.
class _NameDialogOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _NameDialogOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: JuiceTheme.gold.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8),
            color: JuiceTheme.gold.withValues(alpha: 0.05),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: JuiceTheme.parchment,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: JuiceTheme.parchmentDark,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: JuiceTheme.gold.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gender option for Name Generator (compact side-by-side).
class _NameGenderOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NameGenderOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(8),
            color: color.withValues(alpha: 0.1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 9,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
