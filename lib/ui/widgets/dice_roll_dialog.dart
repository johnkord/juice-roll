import 'package:flutter/material.dart';
import '../../core/roll_engine.dart';
import '../../models/roll_result.dart';

/// Dialog for rolling custom dice (NdX, Fate, advantage/disadvantage, skewed).
class DiceRollDialog extends StatefulWidget {
  final RollEngine rollEngine;
  final void Function(RollResult) onRoll;

  const DiceRollDialog({
    super.key,
    required this.rollEngine,
    required this.onRoll,
  });

  @override
  State<DiceRollDialog> createState() => _DiceRollDialogState();
}

class _DiceRollDialogState extends State<DiceRollDialog> {
  int _diceCount = 2;
  int _diceSides = 6;
  int _modifier = 0;
  int _skew = 0;
  bool _advantage = false;
  bool _disadvantage = false;
  bool _useFateDice = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Roll Dice'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dice Type Toggle
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Standard'), icon: Icon(Icons.casino)),
                ButtonSegment(value: true, label: Text('Fate'), icon: Icon(Icons.auto_awesome)),
              ],
              selected: {_useFateDice},
              onSelectionChanged: (selected) {
                setState(() {
                  _useFateDice = selected.first;
                  if (_useFateDice) {
                    _diceCount = 4;
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            if (!_useFateDice) ...[
              // Dice Count
              Row(
                children: [
                  const Text('Number of dice:'),
                  const Spacer(),
                  IconButton(
                    onPressed: _diceCount > 1 ? () => setState(() => _diceCount--) : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Text(
                    '$_diceCount',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: _diceCount < 20 ? () => setState(() => _diceCount++) : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),

              // Dice Sides
              Row(
                children: [
                  const Text('Dice sides:'),
                  const Spacer(),
                  DropdownButton<int>(
                    value: _diceSides,
                    items: const [
                      DropdownMenuItem(value: 4, child: Text('d4')),
                      DropdownMenuItem(value: 6, child: Text('d6')),
                      DropdownMenuItem(value: 8, child: Text('d8')),
                      DropdownMenuItem(value: 10, child: Text('d10')),
                      DropdownMenuItem(value: 12, child: Text('d12')),
                      DropdownMenuItem(value: 20, child: Text('d20')),
                      DropdownMenuItem(value: 100, child: Text('d100')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _diceSides = value);
                      }
                    },
                  ),
                ],
              ),

              // Skewed d6 (only for d6)
              if (_diceSides == 6) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Skew:'),
                    Expanded(
                      child: Slider(
                        value: _skew.toDouble(),
                        min: -3,
                        max: 3,
                        divisions: 6,
                        label: _skew == 0 ? 'None' : (_skew > 0 ? 'High +$_skew' : 'Low $_skew'),
                        onChanged: (value) {
                          setState(() => _skew = value.round());
                        },
                      ),
                    ),
                    Text(
                      _skew == 0 ? 'None' : (_skew > 0 ? '+$_skew' : '$_skew'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],

              // Advantage/Disadvantage
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Advantage'),
                      value: _advantage,
                      onChanged: (value) {
                        setState(() {
                          _advantage = value ?? false;
                          if (_advantage) _disadvantage = false;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Disadvantage'),
                      value: _disadvantage,
                      onChanged: (value) {
                        setState(() {
                          _disadvantage = value ?? false;
                          if (_disadvantage) _advantage = false;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Fate Dice Count
              Row(
                children: [
                  const Text('Number of Fate dice:'),
                  const Spacer(),
                  IconButton(
                    onPressed: _diceCount > 1 ? () => setState(() => _diceCount--) : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Text(
                    '$_diceCount',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: _diceCount < 10 ? () => setState(() => _diceCount++) : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],

            // Modifier
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Modifier:'),
                const Spacer(),
                IconButton(
                  onPressed: _modifier > -10 ? () => setState(() => _modifier--) : null,
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  _modifier >= 0 ? '+$_modifier' : '$_modifier',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: _modifier < 10 ? () => setState(() => _modifier++) : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),

            // Roll Preview
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _buildRollDescription(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _performRoll,
          icon: const Icon(Icons.casino),
          label: const Text('Roll!'),
        ),
      ],
    );
  }

  String _buildRollDescription() {
    final buffer = StringBuffer();

    if (_useFateDice) {
      buffer.write('${_diceCount}dF');
    } else {
      buffer.write('$_diceCount d$_diceSides');
      if (_skew != 0 && _diceSides == 6) {
        buffer.write(' (skew ${_skew > 0 ? '+$_skew' : '$_skew'})');
      }
    }

    if (_modifier != 0) {
      buffer.write(_modifier >= 0 ? ' +$_modifier' : ' $_modifier');
    }

    if (_advantage) {
      buffer.write(' (advantage)');
    } else if (_disadvantage) {
      buffer.write(' (disadvantage)');
    }

    return buffer.toString();
  }

  void _performRoll() {
    RollResult result;

    if (_useFateDice) {
      final dice = widget.rollEngine.rollFateDice(_diceCount);
      final sum = dice.reduce((a, b) => a + b) + _modifier;

      result = FateRollResult(
        description: '${_diceCount}dF${_modifier != 0 ? (_modifier >= 0 ? '+$_modifier' : '$_modifier') : ''}',
        diceResults: dice,
        total: sum,
      );
    } else if (_advantage) {
      final advResult = widget.rollEngine.rollWithAdvantage(_diceCount, _diceSides);
      result = RollResult(
        type: RollType.advantage,
        description: '$_diceCount d$_diceSides (advantage)',
        diceResults: advResult.chosenRoll,
        total: advResult.chosenSum + _modifier,
        interpretation: 'Chose ${advResult.chosenSum} over ${advResult.discardedSum}',
        metadata: {
          'discarded': advResult.discardedRoll,
          'discardedSum': advResult.discardedSum,
        },
      );
    } else if (_disadvantage) {
      final disResult = widget.rollEngine.rollWithDisadvantage(_diceCount, _diceSides);
      result = RollResult(
        type: RollType.disadvantage,
        description: '$_diceCount d$_diceSides (disadvantage)',
        diceResults: disResult.chosenRoll,
        total: disResult.chosenSum + _modifier,
        interpretation: 'Chose ${disResult.chosenSum} over ${disResult.discardedSum}',
        metadata: {
          'discarded': disResult.discardedRoll,
          'discardedSum': disResult.discardedSum,
        },
      );
    } else if (_skew != 0 && _diceSides == 6) {
      // Skewed d6 - roll each die with skew
      final dice = List.generate(_diceCount, (_) => widget.rollEngine.rollSkewedD6(_skew));
      final sum = dice.reduce((a, b) => a + b) + _modifier;
      result = RollResult(
        type: RollType.skewed,
        description: '$_diceCount d6 (skew ${_skew > 0 ? '+$_skew' : '$_skew'})',
        diceResults: dice,
        total: sum,
        metadata: {'skew': _skew},
      );
    } else {
      // Standard roll
      final dice = widget.rollEngine.rollDice(_diceCount, _diceSides);
      final sum = dice.reduce((a, b) => a + b) + _modifier;
      result = RollResult(
        type: RollType.standard,
        description: '$_diceCount d$_diceSides${_modifier != 0 ? (_modifier >= 0 ? '+$_modifier' : '$_modifier') : ''}',
        diceResults: dice,
        total: sum,
      );
    }

    widget.onRoll(result);
    Navigator.pop(context);
  }
}
