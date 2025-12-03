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
  String _selectedChaosLevel = 'Normal';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Next Scene'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current chaos level:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...NextScene.chaosLevels.entries.map((entry) {
            final isSelected = _selectedChaosLevel == entry.key;
            final modifierText = entry.value >= 0 ? '+${entry.value}' : '${entry.value}';

            return RadioListTile<String>(
              title: Text(entry.key),
              subtitle: Text('Modifier: $modifierText'),
              value: entry.key,
              groupValue: _selectedChaosLevel,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedChaosLevel = value);
                }
              },
              dense: true,
              selected: isSelected,
            );
          }),
          const SizedBox(height: 8),
          const Text(
            'Rolling doubles triggers a Random Event!',
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
    final result = widget.nextScene.determineScene(chaosLevel: _selectedChaosLevel);
    widget.onRoll(result);
    Navigator.pop(context);
  }
}
