import 'package:flutter/material.dart';
import '../theme/juice_theme.dart';
import '../../presets/random_event.dart';
import '../../models/roll_result.dart';

/// Dialog for Random Tables options.
/// Provides access to modifier, idea, event, person, and object tables.
class RandomTablesDialog extends StatelessWidget {
  final RandomEvent randomEvent;
  final void Function(RollResult) onRoll;

  const RandomTablesDialog({
    super.key,
    required this.randomEvent,
    required this.onRoll,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Random Tables',
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: JuiceTheme.sepia.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.auto_awesome, size: 14, color: JuiceTheme.gold),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '"Discover Meaning" provides abstract concepts. These tables provide something more concrete for nouns.',
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
              const SizedBox(height: 14),

              // Simple Mode / Alter Scene - primary action
              _RandomSectionHeader(
                icon: Icons.tune,
                title: 'Simple Mode / Alter Scene',
              ),
              const SizedBox(height: 4),
              _RandomPrimaryOption(
                title: 'Modifier + Idea',
                subtitle: 'Replaces Random Event table • 2d10',
                examples: 'Stop Food, Strange Resource, Increase Attention',
                onTap: () {
                  onRoll(randomEvent.rollModifierPlusIdea());
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 14),

              // Individual Tables section
              _RandomSectionHeader(
                icon: Icons.view_list,
                title: 'Individual Tables (d10)',
              ),
              const SizedBox(height: 6),
              _RandomIndividualTable(
                label: 'Modifier',
                examples: 'Change, Continue, Decrease, Extra, Increase, Stop, Strange...',
                color: JuiceTheme.rust,
                onTap: () {
                  onRoll(randomEvent.rollModifier());
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 4),
              _RandomIndividualTable(
                label: 'Idea',
                examples: 'Attention, Communication, Danger, Element, Food, Home...',
                color: JuiceTheme.mystic,
                onTap: () {
                  onRoll(randomEvent.rollIdea());
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 4),
              _RandomIndividualTable(
                label: 'Event',
                examples: 'Ambush, Anomaly, Blessing, Caravan, Curse, Discovery...',
                color: JuiceTheme.danger,
                onTap: () {
                  onRoll(randomEvent.rollEvent());
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 4),
              _RandomIndividualTable(
                label: 'Person',
                examples: 'Criminal, Entertainer, Expert, Mage, Mercenary, Noble...',
                color: JuiceTheme.info,
                onTap: () {
                  onRoll(randomEvent.rollPerson());
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 4),
              _RandomIndividualTable(
                label: 'Object',
                examples: 'Arrow, Candle, Cauldron, Chain, Claw, Hook, Quill, Skull...',
                color: JuiceTheme.success,
                onTap: () {
                  onRoll(randomEvent.rollObject());
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 14),

              // Modifier + Category section (combined options)
              _RandomSectionHeader(
                icon: Icons.merge_type,
                title: 'Modifier + Category',
              ),
              const SizedBox(height: 6),
              // 2x2 grid for modifier combinations
              Row(
                children: [
                  Expanded(
                    child: _RandomModifierCombo(
                      label: 'Random',
                      hint: '1-3: Idea, 4-6: Event\n7-8: Person, 9-0: Object',
                      color: JuiceTheme.parchmentDark,
                      onTap: () {
                        onRoll(randomEvent.generateIdea());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _RandomModifierCombo(
                      label: 'Event',
                      hint: 'Scene triggers',
                      color: JuiceTheme.danger,
                      onTap: () {
                        onRoll(randomEvent.generateIdea(category: IdeaCategory.event));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _RandomModifierCombo(
                      label: 'Person',
                      hint: 'NPC generation',
                      color: JuiceTheme.info,
                      onTap: () {
                        onRoll(randomEvent.generateIdea(category: IdeaCategory.person));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _RandomModifierCombo(
                      label: 'Object',
                      hint: 'Items & things',
                      color: JuiceTheme.success,
                      onTap: () {
                        onRoll(randomEvent.generateIdea(category: IdeaCategory.object));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Random Event Focus section
              _RandomSectionHeader(
                icon: Icons.shuffle,
                title: 'Random Event Focus',
              ),
              const SizedBox(height: 4),
              Text(
                'For double blanks on Fate Check (primary die left)',
                style: TextStyle(fontSize: 9, fontStyle: FontStyle.italic, color: JuiceTheme.parchmentDark),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _RandomFocusButton(
                      title: 'Focus Only',
                      subtitle: '1d10',
                      onTap: () {
                        onRoll(randomEvent.generateFocus());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _RandomFocusButton(
                      title: 'Full Event',
                      subtitle: '3d10',
                      isPrimary: true,
                      onTap: () {
                        onRoll(randomEvent.generate());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Compact Focus Reference
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: JuiceTheme.parchmentDark.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event Focus Reference:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                        color: JuiceTheme.parchmentDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '1 Advance Time  2 Close Thread  3 Converge  4 Diverge  5 Immersion\n'
                      '6 Keyed Event  7 New Character  8 NPC Action  9 Plot Armor  0 Remote',
                      style: TextStyle(
                        fontSize: 8,
                        fontFamily: JuiceTheme.fontFamilyMono,
                        color: JuiceTheme.parchment,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Tip box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: JuiceTheme.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 11, color: JuiceTheme.gold),
                    const SizedBox(width: 6),
                    Text(
                      'Tip: Use Color + Object for naming Establishments!',
                      style: TextStyle(
                        fontSize: 9,
                        fontStyle: FontStyle.italic,
                        color: JuiceTheme.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close', style: TextStyle(color: JuiceTheme.parchmentDark)),
        ),
      ],
    );
  }
}

/// Section header for Random Tables dialog.
class _RandomSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _RandomSectionHeader({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: JuiceTheme.gold),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: JuiceTheme.gold,
          ),
        ),
      ],
    );
  }
}

/// Primary featured option (Modifier + Idea).
class _RandomPrimaryOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final String examples;
  final VoidCallback onTap;

  const _RandomPrimaryOption({
    required this.title,
    required this.subtitle,
    required this.examples,
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                JuiceTheme.gold.withValues(alpha: 0.15),
                JuiceTheme.juiceOrange.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: JuiceTheme.gold.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(Icons.casino, size: 24, color: JuiceTheme.gold),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: JuiceTheme.parchment,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: JuiceTheme.parchmentDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      examples,
                      style: TextStyle(
                        fontSize: 9,
                        fontStyle: FontStyle.italic,
                        color: JuiceTheme.gold,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: JuiceTheme.gold),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual table row option.
class _RandomIndividualTable extends StatelessWidget {
  final String label;
  final String examples;
  final Color color;
  final VoidCallback onTap;

  const _RandomIndividualTable({
    required this.label,
    required this.examples,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: color,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  examples,
                  style: TextStyle(
                    fontSize: 9,
                    color: JuiceTheme.parchmentDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right, size: 14, color: color.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modifier combination button (2x2 grid).
class _RandomModifierCombo extends StatelessWidget {
  final String label;
  final String hint;
  final Color color;
  final VoidCallback onTap;

  const _RandomModifierCombo({
    required this.label,
    required this.hint,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Modifier + $label',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '+ $label',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  hint,
                  style: TextStyle(
                    fontSize: 8,
                    color: JuiceTheme.parchmentDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Focus button for Random Event Focus section.
class _RandomFocusButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isPrimary;
  final VoidCallback onTap;

  const _RandomFocusButton({
    required this.title,
    required this.subtitle,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPrimary ? JuiceTheme.categoryOracle : JuiceTheme.parchmentDark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isPrimary ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: isPrimary ? 0.5 : 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? color : JuiceTheme.parchment,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 8,
                    fontFamily: JuiceTheme.fontFamilyMono,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
