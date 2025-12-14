import 'package:flutter/material.dart';
import '../../presets/next_scene.dart';
import '../../presets/random_event.dart';
import '../../models/roll_result.dart';
import '../theme/juice_theme.dart';

/// Dialog for determining the next scene.
/// 
/// At the end of a scene, you probably have an idea of what the next scene may look like.
/// This dialog challenges that expectation with random alterations or interruptions.
class NextSceneDialog extends StatefulWidget {
  final NextScene nextScene;
  final void Function(RollResult) onRoll;

  const NextSceneDialog({
    super.key,
    required this.nextScene,
    required this.onRoll,
  });

  @override
  State<NextSceneDialog> createState() => _NextSceneDialogState();
}

class _NextSceneDialogState extends State<NextSceneDialog> {
  final RandomEvent _randomEvent = RandomEvent();
  bool _useSimpleMode = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Next Scene',
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
            // Introduction
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: JuiceTheme.info10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Challenge your expected next scene. Roll 2dF to see if the scene '
                'proceeds normally, is altered, or is interrupted.',
                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 12),
            
            // Dice outcome reference - compact grid
            _buildOutcomeReference(),
            const SizedBox(height: 8),
            
            // Simple mode toggle - improved styling
            _buildSimpleModeToggle(),
            
            const Divider(height: 16),
            
            // Main Actions Section
            const _SectionHeader(title: 'Roll Scene Transition', icon: Icons.movie_filter),
            const SizedBox(height: 4),
            _DialogOption(
              title: 'Quick Roll (2dF)',
              subtitle: 'Scene type only, roll follow-up manually',
              icon: Icons.bolt,
              iconColor: JuiceTheme.gold,
              onTap: () {
                final result = widget.nextScene.determineScene();
                widget.onRoll(result);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 4),
            _buildFullRollOption(),
            
            const Divider(height: 16),
            
            // Follow-up Tables Section
            const _SectionHeader(title: 'Follow-up Tables', icon: Icons.table_chart),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: _CompactOption(
                    title: 'Focus',
                    subtitle: 'd10',
                    icon: Icons.center_focus_strong,
                    iconColor: JuiceTheme.categoryWorld,
                    onTap: () {
                      final result = widget.nextScene.rollFocus();
                      widget.onRoll(result);
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _CompactOption(
                    title: 'Mod + Idea',
                    subtitle: '2d10',
                    icon: Icons.lightbulb_outline,
                    iconColor: JuiceTheme.juiceOrange,
                    onTap: () {
                      final result = _randomEvent.rollModifierPlusIdea();
                      widget.onRoll(result);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Examples section - collapsible style
            _buildExamplesSection(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close', style: TextStyle(color: JuiceTheme.parchmentDark)),
        ),
      ],
    );
  }

  Widget _buildOutcomeReference() {
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
                '2dF Scene Transitions',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: JuiceTheme.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _OutcomeRow(
                      symbols: '+ +',
                      label: 'Alter (Add)',
                      color: JuiceTheme.success,
                      tooltip: 'Roll Focus: Introduce or emphasize this element in the scene',
                    ),
                    _OutcomeRow(
                      symbols: '+ −',
                      label: 'Alter (Remove)',
                      color: JuiceTheme.categoryWorld,
                      tooltip: 'Roll Focus: Diminish or remove this element\'s influence from the scene',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _OutcomeRow(
                      symbols: '− +',
                      label: 'Interrupt (+)',
                      color: JuiceTheme.info,
                    ),
                    _OutcomeRow(
                      symbols: '− −',
                      label: 'Interrupt (−)',
                      color: JuiceTheme.danger,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: JuiceTheme.parchmentDark15,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Any ○',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: JuiceTheme.parchmentDark,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '= Normal (proceeds as expected)',
                style: TextStyle(fontSize: 10, color: JuiceTheme.parchmentDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleModeToggle() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _useSimpleMode = !_useSimpleMode),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: _useSimpleMode
                ? JuiceTheme.juiceOrange10
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _useSimpleMode
                  ? JuiceTheme.juiceOrange40
                  : JuiceTheme.parchmentDark20,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: _useSimpleMode
                        ? JuiceTheme.juiceOrange
                        : JuiceTheme.parchmentDark,
                    width: 2,
                  ),
                  color: _useSimpleMode
                      ? JuiceTheme.juiceOrange
                      : Colors.transparent,
                ),
                child: _useSimpleMode
                    ? Icon(Icons.check, size: 12, color: JuiceTheme.parchment)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Simple Mode: Use Modifier + Idea instead of Focus for Alter',
                  style: TextStyle(
                    fontSize: 10,
                    color: _useSimpleMode
                        ? JuiceTheme.juiceOrange
                        : JuiceTheme.parchmentDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullRollOption() {
    return _DialogOption(
      title: 'Full Roll (Auto)',
      subtitle: _useSimpleMode
          ? 'Auto-rolls Modifier+Idea (Alter) or Plot Point (Interrupt)'
          : 'Auto-rolls Focus (Alter) or Plot Point (Interrupt)',
      icon: Icons.auto_awesome,
      iconColor: JuiceTheme.mystic,
      highlighted: true,
      onTap: () {
        if (_useSimpleMode) {
          final result = widget.nextScene.determineSceneWithFollowUp(
            useSimpleMode: true,
            randomEvent: _randomEvent,
          );
          widget.onRoll(result);
        } else {
          final result = widget.nextScene.determineSceneWithFollowUp();
          widget.onRoll(result);
        }
        Navigator.pop(context);
      },
    );
  }

  Widget _buildExamplesSection() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: JuiceTheme.parchmentDark06,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: JuiceTheme.parchmentDark15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, size: 12, color: JuiceTheme.parchmentDark),
              const SizedBox(width: 4),
              Text(
                'Example: PC rents a room, expects to wake in morning',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: JuiceTheme.parchmentDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _ExampleRow(
            type: 'Normal',
            typeColor: JuiceTheme.parchmentDark,
            result: 'Wake up as expected.',
          ),
          _ExampleRow(
            type: 'Alter+',
            typeColor: JuiceTheme.success,
            result: '"Ally" → Friend knocks on door.',
          ),
          _ExampleRow(
            type: 'Alter−',
            typeColor: JuiceTheme.categoryWorld,
            result: '"Arctic" → Hot, stalls closed.',
          ),
          _ExampleRow(
            type: 'Int (+)',
            typeColor: JuiceTheme.info,
            result: '"Reinforcements" → Sheriff catches thief.',
          ),
          _ExampleRow(
            type: 'Int (−)',
            typeColor: JuiceTheme.danger,
            result: '"Battle" → Assassin visits!',
          ),
        ],
      ),
    );
  }
}

/// Section header with icon.
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: JuiceTheme.gold),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Outcome row showing dice symbols and result.
class _OutcomeRow extends StatelessWidget {
  final String symbols;
  final String label;
  final Color color;
  final String? tooltip;

  const _OutcomeRow({
    required this.symbols,
    required this.label,
    required this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Container(
            width: 28,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              symbols,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color),
          ),
          if (tooltip != null) ...[
            const SizedBox(width: 2),
            Text(
              '*',
              style: TextStyle(fontSize: 8, color: color),
            ),
          ],
        ],
      ),
    );
    
    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        preferBelow: false,
        child: row,
      );
    }
    return row;
  }
}

/// Example row in the examples section.
class _ExampleRow extends StatelessWidget {
  final String type;
  final Color typeColor;
  final String result;

  const _ExampleRow({
    required this.type,
    required this.typeColor,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Text(
              type,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: typeColor,
              ),
            ),
          ),
          const Text('→ ', style: TextStyle(fontSize: 9)),
          Expanded(
            child: Text(
              result,
              style: const TextStyle(fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }
}

/// A dialog option tile with icon and clear visual affordance.
class _DialogOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool highlighted;
  final VoidCallback onTap;

  const _DialogOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.highlighted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
              children: [
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: highlighted ? iconColor : JuiceTheme.gold,
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
                  color: (highlighted ? iconColor : JuiceTheme.gold).withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact option for side-by-side layout.
class _CompactOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _CompactOption({
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: iconColor.withOpacity(0.4),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: iconColor.withOpacity(0.08),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: iconColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9,
                      color: iconColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: iconColor.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
