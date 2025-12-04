import 'package:flutter/material.dart';
import '../../presets/next_scene.dart';
import '../../models/roll_result.dart';

/// Dialog for determining the next scene.
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
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Next Scene'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Roll 2dF to determine scene transition:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('+ + = Alter (Add Focus)', style: TextStyle(fontSize: 12)),
                Text('+ − = Alter (Remove Focus)', style: TextStyle(fontSize: 12)),
                Text('− + = Interrupt (Favorable)', style: TextStyle(fontSize: 12)),
                Text('− − = Interrupt (Unfavorable)', style: TextStyle(fontSize: 12)),
                Text('Other = Normal scene', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Alter → Roll on Focus table\nInterrupt → Roll on Plot Point table',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          // Roll options
          ListTile(
            title: const Text('Quick Roll'),
            subtitle: const Text('2dF only, roll follow-up manually'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            onTap: () {
              final result = widget.nextScene.determineScene();
              widget.onRoll(result);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Full Roll'),
            subtitle: const Text('Auto-rolls Focus or Plot Point if needed'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            onTap: () {
              final result = widget.nextScene.determineSceneWithFollowUp();
              widget.onRoll(result);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Focus Only'),
            subtitle: const Text('Roll 1d10 on Focus table'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            onTap: () {
              final result = widget.nextScene.rollFocus();
              widget.onRoll(result);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
