import 'package:flutter/material.dart';
import '../../models/roll_result.dart';
import '../../presets/immersion.dart';
import '../../presets/details.dart' show SkewType;
import '../theme/juice_theme.dart';

/// Dialog for Immersion options.
class ImmersionDialog extends StatelessWidget {
  final Immersion immersion;
  final void Function(RollResult) onRoll;

  const ImmersionDialog({
    super.key,
    required this.immersion,
    required this.onRoll,
  });

  // Section theme colors
  static const Color _fullImmersionColor = JuiceTheme.gold;
  static const Color _sensoryColor = JuiceTheme.info;
  static const Color _emotionalColor = JuiceTheme.mystic;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  JuiceTheme.juiceOrange.withValues(alpha: 0.3),
                  JuiceTheme.mystic.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.self_improvement, color: JuiceTheme.juiceOrange, size: 20),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Immersion',
                style: TextStyle(
                  fontFamily: JuiceTheme.fontFamilySerif,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Be your character',
                style: TextStyle(
                  fontSize: 11,
                  color: JuiceTheme.parchmentDark,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Introduction
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      JuiceTheme.juiceOrange.withValues(alpha: 0.12),
                      JuiceTheme.mystic.withValues(alpha: 0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: JuiceTheme.juiceOrange.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.psychology, 
                      color: JuiceTheme.juiceOrange.withValues(alpha: 0.7), 
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'See what they see, feel what they feel. Perfect when you\'re "stuck" — provides hints about the environment.',
                        style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              
              // ═══════════════════════════════════════════════════════════════
              // FULL IMMERSION - COMPLETE EXPERIENCE
              // ═══════════════════════════════════════════════════════════════
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _fullImmersionColor.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _fullImmersionColor.withValues(alpha: 0.12),
                      _fullImmersionColor.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Complete badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: _fullImmersionColor.withValues(alpha: 0.15),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 16, color: _fullImmersionColor),
                          const SizedBox(width: 6),
                          Text(
                            'Full Immersion',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _fullImmersionColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _fullImmersionColor.withValues(alpha: 0.4),
                                  _fullImmersionColor.withValues(alpha: 0.25),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: 10, color: _fullImmersionColor),
                                const SizedBox(width: 3),
                                Text(
                                  'COMPLETE',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: _fullImmersionColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Output format quote
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: JuiceTheme.inkDark.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(6),
                              border: Border(
                                left: BorderSide(
                                  color: _fullImmersionColor.withValues(alpha: 0.6),
                                  width: 3,
                                ),
                              ),
                            ),
                            child: const Text(
                              '"You [sense] something [detail] [where], and it causes [emotion] because [cause]"',
                              style: TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: JuiceTheme.parchment,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Roll button
                          _ImmersionRollButton(
                            label: 'Full Immersion',
                            subtitle: '5d10 + 1dF → Complete sensory experience',
                            icon: Icons.auto_awesome,
                            color: _fullImmersionColor,
                            isPrimary: true,
                            onTap: () {
                              onRoll(immersion.generateFullImmersion());
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              
              // ═══════════════════════════════════════════════════════════════
              // SENSORY DETAIL SECTION
              // ═══════════════════════════════════════════════════════════════
              _ImmersionSectionCard(
                icon: Icons.visibility,
                title: 'Sensory Detail',
                color: _sensoryColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reference info
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: JuiceTheme.inkDark.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDiceReference('d10', 'Sense', 'See (1-3), Hear (4-6), Smell (7-8), Feel (9-0)', _sensoryColor),
                          const SizedBox(height: 3),
                          _buildDiceReference('d10', 'Detail', 'Based on sense (Broken, Colorful, Shiny...)', _sensoryColor),
                          const SizedBox(height: 3),
                          _buildDiceReference('d10', 'Where', 'Above, Behind, In The Distance, Next To You...', _sensoryColor),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ImmersionRollButton(
                      label: 'Sensory Detail',
                      subtitle: '3d10 → "You [sense] something [detail] [where]"',
                      icon: Icons.visibility,
                      color: _sensoryColor,
                      onTap: () {
                        onRoll(immersion.generateSensoryDetail());
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _ImmersionSkewButton(
                            label: 'Closer',
                            subtitle: 'Near you',
                            icon: Icons.near_me,
                            color: JuiceTheme.success,
                            onTap: () {
                              onRoll(immersion.generateSensoryDetail(skew: SkewType.advantage));
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ImmersionSkewButton(
                            label: 'Further',
                            subtitle: 'Far away',
                            icon: Icons.explore,
                            color: JuiceTheme.info,
                            onTap: () {
                              onRoll(immersion.generateSensoryDetail(skew: SkewType.disadvantage));
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _ImmersionRollButton(
                      label: 'Distant Senses Only',
                      subtitle: 'd6 → See or Hear only (exploration/scouting)',
                      icon: Icons.remove_red_eye_outlined,
                      color: _sensoryColor.withValues(alpha: 0.7),
                      onTap: () {
                        onRoll(immersion.generateSensoryDetail(senseDie: 6));
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // ═══════════════════════════════════════════════════════════════
              // EMOTIONAL ATMOSPHERE SECTION
              // ═══════════════════════════════════════════════════════════════
              _ImmersionSectionCard(
                icon: Icons.mood,
                title: 'Emotional Atmosphere',
                color: _emotionalColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reference info
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: JuiceTheme.inkDark.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildSmallDieBadge('1dF', _emotionalColor),
                              const SizedBox(width: 6),
                              Text(
                                'polarity: (−/blank) negative, (+) positive',
                                style: TextStyle(fontSize: 9, color: JuiceTheme.parchmentDark),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Emotions paired as opposites: Despair↔Hope, Fear↔Courage, Anger↔Calm...',
                            style: TextStyle(fontSize: 9, color: JuiceTheme.parchmentDark),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Basic 6: Joy, Sadness, Fear, Anger, Disgust, Surprise',
                            style: TextStyle(fontSize: 9, fontStyle: FontStyle.italic, color: JuiceTheme.parchment),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ImmersionRollButton(
                      label: 'Emotional Atmosphere',
                      subtitle: '2d10 + 1dF → "It causes [emotion] because [cause]"',
                      icon: Icons.mood,
                      color: _emotionalColor,
                      onTap: () {
                        onRoll(immersion.generateEmotionalAtmosphere());
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _ImmersionSkewButton(
                            label: 'Positive',
                            subtitle: 'Hopeful',
                            icon: Icons.sentiment_satisfied_alt,
                            color: JuiceTheme.success,
                            onTap: () {
                              onRoll(immersion.generateEmotionalAtmosphere(skew: SkewType.advantage));
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ImmersionSkewButton(
                            label: 'Negative',
                            subtitle: 'Darker',
                            icon: Icons.sentiment_dissatisfied,
                            color: JuiceTheme.danger,
                            onTap: () {
                              onRoll(immersion.generateEmotionalAtmosphere(skew: SkewType.disadvantage));
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _ImmersionRollButton(
                      label: 'Basic Emotions Only',
                      subtitle: 'd6 → Joy, Sadness, Fear, Anger, Disgust, Surprise',
                      icon: Icons.emoji_emotions_outlined,
                      color: _emotionalColor.withValues(alpha: 0.7),
                      onTap: () {
                        onRoll(immersion.generateEmotionalAtmosphere(emotionDie: 6));
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Example
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: JuiceTheme.parchmentDark.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: JuiceTheme.parchmentDark.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.format_quote, size: 14, color: JuiceTheme.parchmentDark),
                        const SizedBox(width: 4),
                        Text(
                          'Example:',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: JuiceTheme.parchmentDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '"You see something discarded behind you, and it causes joy because you were warned about it"',
                      style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
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
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildDiceReference(String die, String label, String values, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSmallDieBadge(die, color),
        const SizedBox(width: 6),
        Text(
          '$label → ',
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            values,
            style: TextStyle(fontSize: 9, color: JuiceTheme.parchmentDark),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallDieBadge(String die, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        die,
        style: TextStyle(
          fontSize: 9,
          fontFamily: JuiceTheme.fontFamilyMono,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

// =============================================================================
// HELPER WIDGETS (Private to this file)
// =============================================================================

/// Section card for Immersion dialog
class _ImmersionSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;

  const _ImmersionSectionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withValues(alpha: 0.06),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Row(
              children: [
                Icon(icon, size: 15, color: color),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Roll button for Immersion dialog
class _ImmersionRollButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ImmersionRollButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isPrimary = false,
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
            gradient: isPrimary
                ? LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.25),
                      color.withValues(alpha: 0.15),
                    ],
                  )
                : null,
            color: isPrimary ? null : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: isPrimary ? 0.5 : 0.3),
              width: isPrimary ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 9,
                        color: JuiceTheme.parchmentDark.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 16, color: color.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skew button for Immersion dialog (Closer/Further, Positive/Negative)
class _ImmersionSkewButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ImmersionSkewButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9,
                      color: color.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
