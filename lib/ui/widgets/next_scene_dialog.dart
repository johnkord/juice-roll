import 'package:flutter/material.dart';
import '../../presets/next_scene.dart';
import '../../presets/random_event.dart';
import '../../models/roll_result.dart';

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
      title: const Text('Next Scene'),
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
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Challenge your expected next scene. Roll 2dF to see if the scene '
                'proceeds normally, is altered, or is interrupted.',
                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Roll 2dF to determine scene transition:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('+ + = Alter (Add Focus)', style: TextStyle(fontSize: 11, fontFamily: 'monospace')),
                  Text('+ − = Alter (Remove Focus)', style: TextStyle(fontSize: 11, fontFamily: 'monospace')),
                  Text('− + = Interrupt (Favorable)', style: TextStyle(fontSize: 11, fontFamily: 'monospace')),
                  Text('− − = Interrupt (Unfavorable)', style: TextStyle(fontSize: 11, fontFamily: 'monospace')),
                  Text('Any ○ = Normal (proceeds as expected)', style: TextStyle(fontSize: 11, fontFamily: 'monospace')),
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
                ),
                const Expanded(
                  child: Text(
                    'Simple Mode: Use Modifier + Idea instead of Focus for Alter',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
            const Divider(),
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
            const Divider(),
            const Text('Follow-up Tables', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
            const Divider(),
            // Examples section
            const Text('Examples', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Your PC rents a room and heads to bed. Expected: wake up in morning.\n\n'
                '• Normal → Wake up as expected.\n'
                '• Alter (Add) + "Ally" → A friend knocks on the door.\n'
                '• Alter (Remove) + "Environment: Arctic" → Hot morning, some stalls closed.\n'
                '• Interrupt (Favorable) + "Reinforcements" → Sheriff catches a thief next door.\n'
                '• Interrupt (Unfavorable) + "Battle" → Assassin visits in the night!',
                style: TextStyle(fontSize: 9, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

/// A dialog option tile.
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
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 13)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 10)),
      dense: true,
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
}
