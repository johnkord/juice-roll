import 'package:flutter/material.dart';
import '../../models/roll_result.dart';
import '../../presets/pay_the_price.dart';
import '../theme/juice_theme.dart';
import '../shared/oracle_dialog.dart';

/// Dialog for Pay the Price options.
class PayThePriceDialog extends StatelessWidget {
  final PayThePrice payThePrice;
  final void Function(RollResult) onRoll;

  const PayThePriceDialog({
    super.key,
    required this.payThePrice,
    required this.onRoll,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleOracleDialog(
      title: 'Pay the Price',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Intro explanation
          const OracleDialogIntro(
            text: 'So you failed a challenge. Time to Pay The Price! '
                'Use this to determine the effect of your failure.',
            icon: Icons.warning_amber,
          ),
          const SizedBox(height: 14),

          // Pay The Price button - primary action
          OracleRollButton(
            label: 'Pay The Price',
            subtitle: 'Standard consequence (1d10)',
            icon: Icons.casino,
            color: JuiceTheme.rust,
            isPrimary: true,
            onTap: () {
              onRoll(payThePrice.rollConsequence());
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),

          // Standard consequences table
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: JuiceTheme.sepia08,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Possible Outcomes:',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: JuiceTheme.parchmentDark,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: const [
                    _PriceOutcomeChip('Unintended Effect'),
                    _PriceOutcomeChip('Situation Worsens'),
                    _PriceOutcomeChip('Delayed'),
                    _PriceOutcomeChip('Act Against Intentions'),
                    _PriceOutcomeChip('New Danger'),
                    _PriceOutcomeChip('Community in Danger'),
                    _PriceOutcomeChip('Separated'),
                    _PriceOutcomeChip('Value Lost'),
                    _PriceOutcomeChip('Complication'),
                    _PriceOutcomeChip('Betrayal'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Major Plot Twist section
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: JuiceTheme.danger08,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: JuiceTheme.danger20),
            ),
            child: Row(
              children: [
                Icon(Icons.bolt, size: 14, color: JuiceTheme.danger),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'For "Miss with a Match" or Critical Fail, use the Major Plot Twist:',
                    style: TextStyle(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: JuiceTheme.parchment,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Major Plot Twist button
          OracleRollButton(
            label: 'Major Plot Twist',
            subtitle: 'Critical failure consequence (1d10)',
            icon: Icons.bolt,
            color: JuiceTheme.danger,
            onTap: () {
              onRoll(payThePrice.rollMajorTwist());
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),

          // Major twists table
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: JuiceTheme.danger05,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Possible Twists:',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: JuiceTheme.danger80,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: const [
                    _PriceTwistChip('Benefits Enemy'),
                    _PriceTwistChip('Assumption False'),
                    _PriceTwistChip('Dark Secret'),
                    _PriceTwistChip('Enemy Allies'),
                    _PriceTwistChip('Common Goal'),
                    _PriceTwistChip('Diversion'),
                    _PriceTwistChip('Secret Alliance'),
                    _PriceTwistChip('Someone Returns'),
                    _PriceTwistChip('Connected'),
                    _PriceTwistChip('Too Late'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// =============================================================================
// HELPER WIDGETS (Private to this file)
// =============================================================================

class _PriceOutcomeChip extends StatelessWidget {
  final String label;

  const _PriceOutcomeChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: JuiceTheme.rust15,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          color: JuiceTheme.parchment,
        ),
      ),
    );
  }
}

class _PriceTwistChip extends StatelessWidget {
  final String label;

  const _PriceTwistChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: JuiceTheme.danger15,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          color: JuiceTheme.parchment,
        ),
      ),
    );
  }
}
