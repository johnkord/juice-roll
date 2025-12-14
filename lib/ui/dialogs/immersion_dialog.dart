import 'package:flutter/material.dart';
import '../../models/roll_result.dart';
import '../../presets/immersion.dart';
import '../../presets/details.dart' show SkewType;
import '../theme/juice_theme.dart';
import '../shared/oracle_dialog.dart';

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
    return OracleDialog(
      title: 'Immersion',
      subtitle: 'Be your character',
      icon: Icons.self_improvement,
      accentColor: JuiceTheme.juiceOrange,
      secondaryColor: JuiceTheme.mystic20,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Introduction
          const OracleDialogIntro(
            text: 'See what they see, feel what they feel. Perfect when you\'re "stuck" — provides hints about the environment.',
            icon: Icons.psychology,
          ),
          const SizedBox(height: 14),
          
          // ═══════════════════════════════════════════════════════════════
          // FULL IMMERSION - COMPLETE EXPERIENCE
          // ═══════════════════════════════════════════════════════════════
          OracleDialogSection(
            icon: Icons.auto_awesome,
            title: 'Full Immersion',
            color: _fullImmersionColor,
            isHighlighted: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Complete badge
                const Row(
                  children: [
                    OracleDialogBadge(
                      label: 'COMPLETE',
                      icon: Icons.star,
                      color: JuiceTheme.gold,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Output format quote
                OracleDialogQuote(
                  text: '"You [sense] something [detail] [where], and it causes [emotion] because [cause]"',
                  borderColor: _fullImmersionColor.withOpacity(0.6),
                ),
                const SizedBox(height: 10),
                // Roll button
                OracleRollButton(
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
          const SizedBox(height: 14),
          
          // ═══════════════════════════════════════════════════════════════
          // SENSORY DETAIL SECTION
          // ═══════════════════════════════════════════════════════════════
          OracleDialogSection(
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
                    color: JuiceTheme.inkDark30,
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
                OracleRollButton(
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
                      child: OracleSkewButton(
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
                      child: OracleSkewButton(
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
                OracleRollButton(
                  label: 'Distant Senses Only',
                  subtitle: 'd6 → See or Hear only (exploration/scouting)',
                  icon: Icons.remove_red_eye_outlined,
                  color: _sensoryColor.withOpacity(0.7),
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
          OracleDialogSection(
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
                    color: JuiceTheme.inkDark30,
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
                OracleRollButton(
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
                      child: OracleSkewButton(
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
                      child: OracleSkewButton(
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
                OracleRollButton(
                  label: 'Basic Emotions Only',
                  subtitle: 'd6 → Joy, Sadness, Fear, Anger, Disgust, Surprise',
                  icon: Icons.emoji_emotions_outlined,
                  color: _emotionalColor.withOpacity(0.7),
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
          const OracleDialogExample(
            text: '"You see something discarded behind you, and it causes joy because you were warned about it"',
          ),
        ],
      ),
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
        color: color.withOpacity(0.2),
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
