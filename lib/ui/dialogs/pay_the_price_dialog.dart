import 'package:flutter/material.dart';
import '../../models/roll_result.dart';
import '../../presets/pay_the_price.dart';
import '../theme/juice_theme.dart';

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
    return AlertDialog(
      title: Text(
        'Pay the Price',
        style: TextStyle(
          fontFamily: JuiceTheme.fontFamilySerif,
          color: JuiceTheme.parchment,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intro explanation
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: JuiceTheme.danger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: JuiceTheme.danger.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber, size: 16, color: JuiceTheme.danger),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'So you failed a challenge. Time to Pay The Price! '
                        'Use this to determine the effect of your failure.',
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: JuiceTheme.parchment,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Pay The Price button - primary action
              _PayThePriceButton(
                title: 'Pay The Price',
                subtitle: 'Standard consequence (1d10)',
                icon: Icons.casino,
                color: JuiceTheme.rust,
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
                  color: JuiceTheme.sepia.withValues(alpha: 0.08),
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
                  color: JuiceTheme.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: JuiceTheme.danger.withValues(alpha: 0.2)),
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
              _PayThePriceButton(
                title: 'Major Plot Twist',
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
                  color: JuiceTheme.danger.withValues(alpha: 0.05),
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
                        color: JuiceTheme.danger.withValues(alpha: 0.8),
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
        ),
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

// =============================================================================
// HELPER WIDGETS (Private to this file)
// =============================================================================

class _PayThePriceButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PayThePriceButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontFamily: JuiceTheme.fontFamilySerif,
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
              Icon(Icons.chevron_right, size: 18, color: color.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceOutcomeChip extends StatelessWidget {
  final String label;

  const _PriceOutcomeChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: JuiceTheme.rust.withValues(alpha: 0.15),
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
        color: JuiceTheme.danger.withValues(alpha: 0.15),
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
