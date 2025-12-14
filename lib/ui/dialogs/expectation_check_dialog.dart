import 'package:flutter/material.dart';
import '../../models/roll_result.dart';
import '../../presets/expectation_check.dart';
import '../theme/juice_theme.dart';
import '../shared/oracle_dialog.dart';

/// Dialog for Expectation Check options.
class ExpectationCheckDialog extends StatelessWidget {
  final ExpectationCheck expectationCheck;
  final void Function(RollResult) onRoll;

  const ExpectationCheckDialog({
    super.key,
    required this.expectationCheck,
    required this.onRoll,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleOracleDialog(
      title: 'Expectation Check',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Introduction
          OracleDialogIntro(
            icon: Icons.help_outline,
            iconColor: JuiceTheme.info,
            backgroundColor: JuiceTheme.info10,
            text: 'Instead of asking "Is X true?", you assume X is true and test '
                'whether your expectation holds.',
          ),
          const SizedBox(height: 10),
          
          // Use cases row
          Row(
            children: [
              Expanded(
                child: _ExpectUseCaseBox(
                  icon: Icons.psychology,
                  title: 'Story Events',
                  example: '"The tavern is busy..."',
                  color: JuiceTheme.mystic,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _ExpectUseCaseBox(
                  icon: Icons.person,
                  title: 'NPC Behavior',
                  example: '"Guard will let me pass..."',
                  color: JuiceTheme.categoryCharacter,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Outcome reference grid
          _buildOutcomeGrid(),
          
          const SizedBox(height: 12),
          
          // Roll button
          _ExpectDialogOption(
            title: 'Roll 2dF',
            subtitle: 'Test your expectation',
            icon: Icons.casino,
            iconColor: JuiceTheme.gold,
            highlighted: true,
            onTap: () {
              onRoll(expectationCheck.check());
              Navigator.pop(context);
            },
          ),
          
          const SizedBox(height: 8),
          
          // Tip
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: JuiceTheme.parchmentDark08,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.tips_and_updates, size: 12, color: JuiceTheme.juiceOrange),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Tip: Think of your most-likely AND next-most-likely outcomes before rolling!',
                    style: TextStyle(
                      fontSize: 9,
                      fontStyle: FontStyle.italic,
                      color: JuiceTheme.parchmentDark,
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

  Widget _buildOutcomeGrid() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: JuiceTheme.gold05,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: JuiceTheme.gold20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.casino, size: 12, color: JuiceTheme.gold),
              const SizedBox(width: 4),
              Text(
                '2dF Outcomes',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: JuiceTheme.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Expected outcomes (positive zone)
          const Row(
            children: [
              _ExpectOutcomeChip(dice: '++', label: 'Expected!', color: JuiceTheme.success, isIntense: true),
              SizedBox(width: 4),
              _ExpectOutcomeChip(dice: '+○', label: 'Expected', color: JuiceTheme.success),
            ],
          ),
          const SizedBox(height: 4),
          // Middle outcomes
          const Row(
            children: [
              _ExpectOutcomeChip(dice: '+−', label: 'Next Most', color: JuiceTheme.gold),
              SizedBox(width: 4),
              _ExpectOutcomeChip(dice: '−+', label: 'Next Most', color: JuiceTheme.gold),
            ],
          ),
          const SizedBox(height: 4),
          // Modifier outcomes (contextual - what helps/hurts character)
          Row(
            children: [
              _ExpectOutcomeChip(
                dice: '○+', 
                label: 'Favorable*', 
                color: JuiceTheme.gold,
                tooltip: 'HELPS your character\'s situation.\nAsk: What modification benefits them?',
              ),
              const SizedBox(width: 4),
              _ExpectOutcomeChip(
                dice: '○−', 
                label: 'Unfavorable*', 
                color: JuiceTheme.gold,
                tooltip: 'HURTS your character\'s situation.\nAsk: What modification works against them?',
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Special & Opposite
          Row(
            children: [
              _ExpectOutcomeChip(
                dice: '○○', 
                label: 'Mod+Idea*', 
                color: JuiceTheme.juiceOrange, 
                isSpecial: true,
                tooltip: 'Twist your expectation using the\nauto-rolled Modifier + Idea pair.',
              ),
              const SizedBox(width: 4),
              const _ExpectOutcomeChip(dice: '−○', label: 'Opposite', color: JuiceTheme.danger),
            ],
          ),
          const SizedBox(height: 4),
          const Row(
            children: [
              _ExpectOutcomeChip(dice: '−−', label: 'Opposite!', color: JuiceTheme.danger, isIntense: true),
              Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// HELPER WIDGETS (Private to this file)
// =============================================================================

/// Use case box for Expectation Check dialog.
class _ExpectUseCaseBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String example;
  final Color color;

  const _ExpectUseCaseBox({
    required this.icon,
    required this.title,
    required this.example,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            example,
            style: TextStyle(
              fontSize: 9,
              fontStyle: FontStyle.italic,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Outcome chip for Expectation Check grid.
class _ExpectOutcomeChip extends StatelessWidget {
  final String dice;
  final String label;
  final Color color;
  final bool isIntense;
  final bool isSpecial;
  final String? tooltip;

  const _ExpectOutcomeChip({
    required this.dice,
    required this.label,
    required this.color,
    this.isIntense = false,
    this.isSpecial = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(isIntense || isSpecial ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(4),
        border: isIntense || isSpecial || tooltip != null
            ? Border.all(color: color.withOpacity(0.4), width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              dice,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isIntense || tooltip != null ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isIntense)
            Icon(Icons.whatshot, size: 10, color: color),
          if (isSpecial)
            Icon(Icons.auto_awesome, size: 10, color: color),
          if (tooltip != null)
            Icon(Icons.help_outline, size: 9, color: color.withOpacity(0.6)),
        ],
      ),
    );
    
    Widget content = tooltip != null
        ? Tooltip(
            message: tooltip!,
            preferBelow: true,
            textStyle: const TextStyle(fontSize: 11, color: Colors.white),
            decoration: BoxDecoration(
              color: JuiceTheme.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: container,
          )
        : container;
    
    return Expanded(child: content);
  }
}

/// Dialog option for Expectation Check.
class _ExpectDialogOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool highlighted;
  final VoidCallback onTap;

  const _ExpectDialogOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.highlighted = false,
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: highlighted
                  ? iconColor.withOpacity(0.5)
                  : JuiceTheme.gold30,
              width: highlighted ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: highlighted
                ? iconColor.withOpacity(0.1)
                : JuiceTheme.gold08,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: iconColor,
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
              const SizedBox(width: 10),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: iconColor.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
