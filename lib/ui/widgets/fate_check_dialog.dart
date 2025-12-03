import 'package:flutter/material.dart';
import '../../presets/fate_check.dart';
import '../../models/roll_result.dart';

/// Dialog for performing a Fate Check.
class FateCheckDialog extends StatefulWidget {
  final FateCheck fateCheck;
  final void Function(RollResult) onRoll;

  const FateCheckDialog({
    super.key,
    required this.fateCheck,
    required this.onRoll,
  });

  @override
  State<FateCheckDialog> createState() => _FateCheckDialogState();
}

class _FateCheckDialogState extends State<FateCheckDialog> {
  String _selectedLikelihood = 'Even Odds';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Fate Check'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How likely is it?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...FateCheck.likelihoods.entries.map((entry) {
            final isSelected = _selectedLikelihood == entry.key;
            final modifierText = entry.value >= 0 ? '+${entry.value}' : '${entry.value}';

            return RadioListTile<String>(
              title: Text(entry.key),
              subtitle: Text('Modifier: $modifierText'),
              value: entry.key,
              groupValue: _selectedLikelihood,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedLikelihood = value);
                }
              },
              dense: true,
              selected: isSelected,
            );
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _performCheck,
          icon: const Icon(Icons.help_outline),
          label: const Text('Check Fate'),
        ),
      ],
    );
  }

  void _performCheck() {
    final result = widget.fateCheck.check(likelihood: _selectedLikelihood);
    widget.onRoll(result);
    Navigator.pop(context);
  }
}
