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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Roll 2dF to determine scene transition:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('+ + = Alter (Add element)', style: TextStyle(fontSize: 12)),
                Text('+ − = Alter (Remove element)', style: TextStyle(fontSize: 12)),
                Text('− + = Interrupt (Favorable)', style: TextStyle(fontSize: 12)),
                Text('− − = Interrupt (Unfavorable)', style: TextStyle(fontSize: 12)),
                Text('Other = Normal scene', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Alter/Interrupt scenes require follow-up rolls.',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _determineScene,
          icon: const Icon(Icons.theaters),
          label: const Text('Next Scene'),
        ),
      ],
    );
  }

  void _determineScene() {
    final result = widget.nextScene.determineScene();
    widget.onRoll(result);
    Navigator.pop(context);
  }
}
