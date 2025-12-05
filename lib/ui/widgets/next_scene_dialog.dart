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
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Explanation text
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: JuiceTheme.info.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: JuiceTheme.info.withOpacity(0.3)),
              ),
              child: Text(
                'Challenge your expected next scene. Roll 2dF to see if the scene '
                'proceeds normally, is altered, or is interrupted.',
                style: TextStyle(
                  fontSize: 11, 
                  fontStyle: FontStyle.italic,
                  color: JuiceTheme.parchment,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Roll 2dF to determine scene transition:',
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 13,
                color: JuiceTheme.parchment,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: JuiceTheme.ink.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: JuiceTheme.parchmentDark.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('+ + = Alter (Add Focus)', style: TextStyle(fontSize: 11, fontFamily: JuiceTheme.fontFamilyMono, color: JuiceTheme.parchment)),
                  Text('+ − = Alter (Remove Focus)', style: TextStyle(fontSize: 11, fontFamily: JuiceTheme.fontFamilyMono, color: JuiceTheme.parchment)),
                  Text('− + = Interrupt (Favorable)', style: TextStyle(fontSize: 11, fontFamily: JuiceTheme.fontFamilyMono, color: JuiceTheme.parchment)),
                  Text('− − = Interrupt (Unfavorable)', style: TextStyle(fontSize: 11, fontFamily: JuiceTheme.fontFamilyMono, color: JuiceTheme.parchment)),
                  Text('Any ○ = Normal (proceeds as expected)', style: TextStyle(fontSize: 11, fontFamily: JuiceTheme.fontFamilyMono, color: JuiceTheme.parchment)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Simple mode toggle
            Row(
              children: [
                Checkbox(
                  value: _useSimpleMode,
                  onChanged: (v) => setState(() => _useSimpleMode = v ?? false),
                  visualDensity: VisualDensity.compact,
                  activeColor: JuiceTheme.gold,
                ),
                Expanded(
                  child: Text(
                    'Simple Mode: Use Modifier + Idea instead of Focus for Alter',
                    style: TextStyle(fontSize: 10, color: JuiceTheme.parchmentDark),
                  ),
                ),
              ],
            ),
            Divider(color: JuiceTheme.parchmentDark.withOpacity(0.2)),
            // Main roll options
            _DialogOption(
              title: 'Quick Roll (2dF)',
              subtitle: 'Scene type only, roll follow-up manually',
              onTap: () {
                final result = widget.nextScene.determineScene();
                widget.onRoll(result);
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Full Roll (Auto)',
              subtitle: _useSimpleMode
                  ? 'Auto-rolls Modifier+Idea (Alter) or Plot Point (Interrupt)'
                  : 'Auto-rolls Focus (Alter) or Plot Point (Interrupt)',
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
            ),
            Divider(color: JuiceTheme.parchmentDark.withOpacity(0.2)),
            Text(
              'Follow-up Tables', 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 12,
                color: JuiceTheme.parchment,
              ),
            ),
            const SizedBox(height: 4),
            _DialogOption(
              title: 'Focus (d10)',
              subtitle: 'For Alter results: Enemy, Monster, Event, Environment, Community...',
              onTap: () {
                final result = widget.nextScene.rollFocus();
                widget.onRoll(result);
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Modifier + Idea (2d10)',
              subtitle: 'Simple Mode alternative for Alter results',
              onTap: () {
                final result = _randomEvent.rollModifierPlusIdea();
                widget.onRoll(result);
                Navigator.pop(context);
              },
            ),
            Divider(color: JuiceTheme.parchmentDark.withOpacity(0.2)),
            // Examples section
            Text(
              'Examples', 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 11,
                color: JuiceTheme.parchmentDark,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: JuiceTheme.ink.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: JuiceTheme.parchmentDark.withOpacity(0.15)),
              ),
              child: Text(
                'Your PC rents a room and heads to bed. Expected: wake up in morning.\n\n'
                '• Normal → Wake up as expected.\n'
                '• Alter (Add) + "Ally" → A friend knocks on the door.\n'
                '• Alter (Remove) + "Environment: Arctic" → Hot morning, some stalls closed.\n'
                '• Interrupt (Favorable) + "Reinforcements" → Sheriff catches a thief next door.\n'
                '• Interrupt (Unfavorable) + "Battle" → Assassin visits in the night!',
                style: TextStyle(
                  fontSize: 9, 
                  fontFamily: JuiceTheme.fontFamilyMono,
                  color: JuiceTheme.parchmentDark,
                ),
              ),
            ),
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
}

/// A dialog option tile with clear visual affordance for clickability.
class _DialogOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DialogOption({
    required this.title,
    required this.subtitle,
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
                color: JuiceTheme.gold.withOpacity(0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: JuiceTheme.gold.withOpacity(0.08),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: JuiceTheme.gold,
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
                  color: JuiceTheme.gold.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
