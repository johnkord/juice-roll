import 'package:flutter/material.dart';
import '../../presets/fate_check.dart';
import '../../models/roll_result.dart';
import '../theme/juice_theme.dart';

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
      title: Text(
        'Fate Check',
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
                color: JuiceTheme.mystic.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Ask a Yes/No question about the world. '
                'The dice will answer with intensity and nuance.',
                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 12),
            
            // Likelihood selection
            Text(
              'How likely is it?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: JuiceTheme.parchment,
              ),
            ),
            const SizedBox(height: 8),
            
            // Likelihood options as styled tiles
            _LikelihoodTile(
              title: 'Unlikely',
              subtitle: 'If either die is −, result is No-like',
              icon: Icons.remove_circle_outline,
              iconColor: JuiceTheme.danger,
              isSelected: _selectedLikelihood == 'Unlikely',
              onTap: () => setState(() => _selectedLikelihood = 'Unlikely'),
            ),
            const SizedBox(height: 6),
            _LikelihoodTile(
              title: 'Even Odds',
              subtitle: 'Standard 50/50 interpretation',
              icon: Icons.balance,
              iconColor: JuiceTheme.gold,
              isSelected: _selectedLikelihood == 'Even Odds',
              onTap: () => setState(() => _selectedLikelihood = 'Even Odds'),
            ),
            const SizedBox(height: 6),
            _LikelihoodTile(
              title: 'Likely',
              subtitle: 'If either die is +, result is Yes-like',
              icon: Icons.add_circle_outline,
              iconColor: JuiceTheme.success,
              isSelected: _selectedLikelihood == 'Likely',
              onTap: () => setState(() => _selectedLikelihood = 'Likely'),
            ),
            
            const Divider(height: 20),
            
            // Quick reference
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: JuiceTheme.gold.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: JuiceTheme.gold.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Reference',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ReferenceRow(symbol: '++', result: 'Yes And'),
                            _ReferenceRow(
                              symbol: '+0', 
                              result: 'Yes Because*',
                              tooltip: 'Use Intensity to scale the reason WHY',
                            ),
                            _ReferenceRow(symbol: '+-', result: 'Yes But'),
                            _ReferenceRow(
                              symbol: '0+', 
                              result: 'Favorable*',
                              tooltip: 'Answer = what HELPS your character',
                            ),
                            _ReferenceRow(symbol: '<0', result: 'Random Event'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ReferenceRow(
                              symbol: '>0', 
                              result: 'Invalid*',
                              tooltip: 'Your question has a false assumption',
                            ),
                            _ReferenceRow(
                              symbol: '0-', 
                              result: 'Unfavorable*',
                              tooltip: 'Answer = what HURTS your character',
                            ),
                            _ReferenceRow(symbol: '-+', result: 'No But'),
                            _ReferenceRow(
                              symbol: '-0', 
                              result: 'No Because*',
                              tooltip: 'Use Intensity to scale the reason WHY',
                            ),
                            _ReferenceRow(symbol: '--', result: 'No And'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            
            // Dice info
            Row(
              children: [
                Icon(Icons.casino, size: 14, color: JuiceTheme.parchmentDark),
                const SizedBox(width: 4),
                Text(
                  '2dF (Primary + Secondary) + 1d6 Intensity',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: JuiceTheme.parchmentDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: JuiceTheme.parchmentDark),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _performCheck,
          icon: Icon(Icons.help_outline, color: JuiceTheme.gold),
          label: Text(
            'Check Fate',
            style: TextStyle(color: JuiceTheme.gold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: JuiceTheme.surface,
            side: BorderSide(color: JuiceTheme.gold.withOpacity(0.5)),
          ),
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

/// Styled likelihood option tile.
class _LikelihoodTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _LikelihoodTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.isSelected,
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected 
                  ? iconColor.withOpacity(0.6) 
                  : JuiceTheme.gold.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected 
                ? iconColor.withOpacity(0.1) 
                : JuiceTheme.gold.withOpacity(0.03),
          ),
          child: Row(
            children: [
              // Radio indicator
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? iconColor : JuiceTheme.parchmentDark,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: iconColor,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? iconColor : JuiceTheme.parchment,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: JuiceTheme.parchmentDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quick reference row showing symbol → result.
class _ReferenceRow extends StatelessWidget {
  final String symbol;
  final String result;
  final String? tooltip;

  const _ReferenceRow({required this.symbol, required this.result, this.tooltip});

  @override
  Widget build(BuildContext context) {
    Widget row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              symbol,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: _getSymbolColor(),
              ),
            ),
          ),
          Expanded(
            child: Text(
              result,
              style: TextStyle(
                fontSize: 10,
                color: tooltip != null ? JuiceTheme.gold : null,
                fontWeight: tooltip != null ? FontWeight.w500 : null,
              ),
            ),
          ),
          if (tooltip != null)
            Icon(Icons.help_outline, size: 10, color: JuiceTheme.gold.withOpacity(0.6)),
        ],
      ),
    );
    
    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        preferBelow: true,
        textStyle: const TextStyle(fontSize: 11, color: Colors.white),
        decoration: BoxDecoration(
          color: JuiceTheme.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: JuiceTheme.gold.withOpacity(0.5)),
        ),
        child: row,
      );
    }
    return row;
  }

  Color _getSymbolColor() {
    if (symbol.startsWith('+')) return JuiceTheme.success;
    if (symbol.startsWith('-')) return JuiceTheme.danger;
    // Use gold for contextual outcomes (0+, 0-)
    if (symbol == '0+' || symbol == '0-') return JuiceTheme.gold;
    if (symbol.startsWith('0') || symbol.startsWith('<') || symbol.startsWith('>')) {
      return JuiceTheme.info;
    }
    return JuiceTheme.parchmentDark;
  }
}
