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
          ...FateCheck.likelihoods.map((likelihood) {
            final isSelected = _selectedLikelihood == likelihood;
            final description = _getLikelihoodDescription(likelihood);

            return RadioListTile<String>(
              title: Text(likelihood),
              subtitle: Text(description),
              value: likelihood,
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
          const SizedBox(height: 12),
          const Text(
            'Rolls 2dF + 1d6 Intensity',
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
          onPressed: _performCheck,
          icon: const Icon(Icons.help_outline),
          label: const Text('Check Fate'),
        ),
      ],
    );
  }

  String _getLikelihoodDescription(String likelihood) {
    switch (likelihood) {
      case 'Unlikely':
        return 'If either die is −, result is No-like';
      case 'Likely':
        return 'If either die is +, result is Yes-like';
      case 'Even Odds':
      default:
        return 'Standard interpretation (50/50)';
    }
  }

  void _performCheck() {
    final result = widget.fateCheck.check(likelihood: _selectedLikelihood);
    widget.onRoll(result);
    Navigator.pop(context);
  }
}
