import 'package:flutter/material.dart';
import '../../models/roll_result.dart';
import '../../presets/challenge.dart';
import '../theme/juice_theme.dart';
import '../shared/oracle_dialog.dart';
import '../shared/dialog_components.dart';

/// Dialog for Challenge options.
class ChallengeDialog extends StatelessWidget {
  final Challenge challenge;
  final void Function(RollResult) onRoll;

  const ChallengeDialog({
    super.key,
    required this.challenge,
    required this.onRoll,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleOracleDialog(
      title: 'Challenge',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Challenge Procedure explanation
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: JuiceTheme.categoryCombat12,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: JuiceTheme.categoryCombat30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.fitness_center, size: 14, color: JuiceTheme.categoryCombat),
                    const SizedBox(width: 6),
                    Text(
                      'Challenge Procedure',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: JuiceTheme.parchment,
                        fontFamily: JuiceTheme.fontFamilySerif,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '1. Roll Physical + Mental challenge with DCs\n'
                  '2. Create a situation where both make sense\n'
                  '3. Choose ONE path - only need to pass one!\n'
                  '4. Fail = Pay The Price (may lock out other option)',
                  style: TextStyle(
                    fontSize: 10,
                    color: JuiceTheme.parchment85,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Full Challenge section - primary action
          SectionHeader(
            icon: Icons.fitness_center,
            title: 'Full Challenge',
            color: JuiceTheme.categoryCombat,
            iconSize: 14,
          ),
          const SizedBox(height: 4),
          Text(
            'Rolls 1 Physical + 1 Mental with separate DCs for each:',
            style: TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: JuiceTheme.parchmentDark,
            ),
          ),
          const SizedBox(height: 6),
          // 3 difficulty options as chips
          Row(
            children: [
              Expanded(
                child: _ChallengeDifficultyChip(
                  label: 'Random DCs',
                  hint: '1d10 each',
                  color: JuiceTheme.parchmentDark,
                  onTap: () {
                    onRoll(challenge.rollFullChallenge());
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _ChallengeDifficultyChip(
                  label: 'Easy DCs',
                  hint: 'advantage',
                  color: JuiceTheme.success,
                  onTap: () {
                    onRoll(challenge.rollFullChallenge(dcSkew: DcSkew.advantage));
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _ChallengeDifficultyChip(
                  label: 'Hard DCs',
                  hint: 'disadvantage',
                  color: JuiceTheme.danger,
                  onTap: () {
                    onRoll(challenge.rollFullChallenge(dcSkew: DcSkew.disadvantage));
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // DC Methods section
          SectionHeader(
            icon: Icons.gavel,
            title: 'DC Methods',
            color: JuiceTheme.categoryCombat,
            iconSize: 14,
          ),
          const SizedBox(height: 4),
          Text(
            '5 ways to generate a DC:',
            style: TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: JuiceTheme.parchmentDark,
            ),
          ),
          const SizedBox(height: 6),
          // 2x3 grid for DC methods
          Row(
            children: [
              Expanded(
                child: _ChallengeDcOption(
                  title: 'Quick DC',
                  subtitle: '2d6+6',
                  range: '8-18',
                  color: JuiceTheme.gold,
                  onTap: () {
                    onRoll(challenge.rollQuickDc());
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _ChallengeDcOption(
                  title: 'Random DC',
                  subtitle: '1d10',
                  range: '8-17',
                  color: JuiceTheme.parchmentDark,
                  onTap: () {
                    onRoll(challenge.rollDc());
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
                child: _ChallengeDcOption(
                  title: 'Balanced DC',
                  subtitle: '1d100 bell',
                  range: 'middle DCs',
                  color: JuiceTheme.info,
                  onTap: () {
                    onRoll(challenge.rollBalancedDc());
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _ChallengeDcOption(
                  title: 'Easy DC',
                  subtitle: '1d10@+',
                  range: 'lower DC',
                  color: JuiceTheme.success,
                  onTap: () {
                    onRoll(challenge.rollDc(skew: DcSkew.advantage));
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _ChallengeDcOption(
                  title: 'Hard DC',
                  subtitle: '1d10@−',
                  range: 'higher DC',
                  color: JuiceTheme.danger,
                  onTap: () {
                    onRoll(challenge.rollDc(skew: DcSkew.disadvantage));
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Individual Skills section
          SectionHeader(
            icon: Icons.sports_martial_arts,
            title: 'Individual Skills',
            color: JuiceTheme.categoryCombat,
            iconSize: 14,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _ChallengeSkillButton(
                  title: 'Physical',
                  color: JuiceTheme.rust,
                  skills: 'Medicine, Survival, Athletics...',
                  onTap: () {
                    onRoll(challenge.rollPhysicalChallenge());
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ChallengeSkillButton(
                  title: 'Mental',
                  color: JuiceTheme.mystic,
                  skills: 'Nature, Arcana, Insight...',
                  onTap: () {
                    onRoll(challenge.rollMentalChallenge());
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Examples section (compact)
          SectionHeader(
            icon: Icons.lightbulb_outline,
            title: 'Examples',
            color: JuiceTheme.categoryCombat,
            iconSize: 14,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: JuiceTheme.sepia10,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ChallengeExample(
                  rolls: '8,2',
                  physical: 'Stealth',
                  mental: 'Nature',
                  scenario: 'Capture an elusive creature',
                ),
                SizedBox(height: 4),
                _ChallengeExample(
                  rolls: '7,6',
                  physical: 'Sleight of Hand',
                  mental: 'Language',
                  scenario: 'Communicate with natives',
                ),
                SizedBox(height: 4),
                _ChallengeExample(
                  rolls: '9,7',
                  physical: 'Acrobatics',
                  mental: 'Religion',
                  scenario: 'Display martial arts/tai chi',
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

class _ChallengeDifficultyChip extends StatelessWidget {
  final String label;
  final String hint;
  final Color color;
  final VoidCallback onTap;

  const _ChallengeDifficultyChip({
    required this.label,
    required this.hint,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
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
    );
  }
}

class _ChallengeDcOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final String range;
  final Color color;
  final VoidCallback onTap;

  const _ChallengeDcOption({
    required this.title,
    required this.subtitle,
    required this.range,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 8,
                  fontFamily: JuiceTheme.fontFamilyMono,
                  color: JuiceTheme.parchmentDark,
                ),
              ),
              Text(
                range,
                style: TextStyle(
                  fontSize: 7,
                  color: JuiceTheme.parchmentDark70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChallengeSkillButton extends StatelessWidget {
  final String title;
  final Color color;
  final String skills;
  final VoidCallback onTap;

  const _ChallengeSkillButton({
    required this.title,
    required this.color,
    required this.skills,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    title == 'Physical' ? Icons.directions_run : Icons.psychology,
                    size: 14,
                    color: color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                skills,
                style: TextStyle(
                  fontSize: 8,
                  color: JuiceTheme.parchmentDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChallengeExample extends StatelessWidget {
  final String rolls;
  final String physical;
  final String mental;
  final String scenario;

  const _ChallengeExample({
    required this.rolls,
    required this.physical,
    required this.mental,
    required this.scenario,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: JuiceTheme.categoryCombat20,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            rolls,
            style: TextStyle(
              fontSize: 8,
              fontFamily: JuiceTheme.fontFamilyMono,
              fontWeight: FontWeight.bold,
              color: JuiceTheme.categoryCombat,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 9, color: JuiceTheme.parchment),
              children: [
                TextSpan(
                  text: physical,
                  style: TextStyle(color: JuiceTheme.rust, fontWeight: FontWeight.w600),
                ),
                const TextSpan(text: ' or '),
                TextSpan(
                  text: mental,
                  style: TextStyle(color: JuiceTheme.mystic, fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: ' - $scenario',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
