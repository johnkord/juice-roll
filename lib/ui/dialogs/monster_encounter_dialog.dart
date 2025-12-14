import 'package:flutter/material.dart';
import '../theme/juice_theme.dart';
import '../shared/oracle_dialog.dart';
import '../shared/dialog_components.dart';
import '../../presets/wilderness.dart';
import '../../presets/monster_encounter.dart';
import '../../models/roll_result.dart';

/// Dialog for Monster Encounter options.
/// Environment-based encounters with difficulty levels.
class MonsterEncounterDialog extends StatefulWidget {
  final void Function(RollResult) onRoll;
  final WildernessState? wildernessState;

  const MonsterEncounterDialog({
    super.key,
    required this.onRoll,
    this.wildernessState,
  });

  @override
  State<MonsterEncounterDialog> createState() => _MonsterEncounterDialogState();
}

class _MonsterEncounterDialogState extends State<MonsterEncounterDialog> {
  int _selectedEnvironment = 6; // Default to Forest (1-indexed)

  @override
  void initState() {
    super.initState();
    // Use the wilderness state if available
    if (widget.wildernessState != null) {
      _selectedEnvironment = widget.wildernessState!.environmentRow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasWildernessState = widget.wildernessState != null;
    final envName = MonsterEncounter.environmentNames[(_selectedEnvironment - 1).clamp(0, 9)];
    final envFormula = MonsterEncounter.getEnvironmentFormula(_selectedEnvironment);
    final combatColor = JuiceTheme.categoryCombat;
    
    return OracleDialog(
      icon: Icons.pest_control,
      title: 'Monster Encounter',
      accentColor: combatColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              // Environment-based encounter section
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: JuiceTheme.categoryExplore12,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: JuiceTheme.categoryExplore40),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.landscape, size: 16, color: JuiceTheme.categoryExplore),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Environment: $envName ($envFormula)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: JuiceTheme.categoryExplore,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (hasWildernessState) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: JuiceTheme.categoryExplore15,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on, size: 10, color: JuiceTheme.categoryExplore),
                            const SizedBox(width: 4),
                            Text(
                              'From wilderness: ${widget.wildernessState!.fullDescription}',
                              style: TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: JuiceTheme.categoryExplore,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Environment selector
                    DropdownButtonFormField<int>(
                      value: _selectedEnvironment,
                      decoration: InputDecoration(
                        labelText: 'Select Environment',
                        labelStyle: TextStyle(color: JuiceTheme.parchmentDark, fontSize: 12),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: JuiceTheme.categoryExplore30),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: JuiceTheme.categoryExplore30),
                        ),
                      ),
                      dropdownColor: JuiceTheme.surface,
                      iconEnabledColor: JuiceTheme.parchment,
                      style: TextStyle(color: JuiceTheme.parchment, fontSize: 12),
                      selectedItemBuilder: (context) {
                        return List.generate(10, (i) {
                          final name = MonsterEncounter.environmentNames[i];
                          final formula = MonsterEncounter.getEnvironmentFormula(i + 1);
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${i + 1}. $name ($formula)',
                              style: TextStyle(fontSize: 12, color: JuiceTheme.parchment),
                            ),
                          );
                        });
                      },
                      items: List.generate(10, (i) {
                        final name = MonsterEncounter.environmentNames[i];
                        final formula = MonsterEncounter.getEnvironmentFormula(i + 1);
                        return DropdownMenuItem(
                          value: i + 1,
                          child: Row(
                            children: [
                              Text(
                                '${i + 1}. ',
                                style: TextStyle(fontSize: 13, color: JuiceTheme.sepia, fontFamily: JuiceTheme.fontFamilyMono),
                              ),
                              Expanded(
                                child: Text(
                                  name,
                                  style: TextStyle(fontSize: 13, color: JuiceTheme.parchment, fontWeight: FontWeight.w500),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: JuiceTheme.gold15,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  formula,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: JuiceTheme.gold,
                                    fontFamily: JuiceTheme.fontFamilyMono,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      onChanged: (v) => setState(() => _selectedEnvironment = v ?? 6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              // Full Encounter button - primary action
              _MonsterPrimaryButton(
                title: 'Full Encounter (By Environment)',
                subtitle: 'Row ($envFormula) + Difficulty (2d10) + Counts (1d6-1@)',
                icon: Icons.groups,
                onTap: () {
                  widget.onRoll(MonsterEncounter.generateFullEncounter(_selectedEnvironment));
                  Navigator.pop(context);
                },
              ),
              
              const SizedBox(height: 12),
              
              // Quick Rolls section
              SectionHeader(icon: Icons.flash_on, title: 'Quick Rolls', color: JuiceTheme.categoryCombat, iconSize: 14, showDivider: true),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: JuiceTheme.sepia08,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 11, color: JuiceTheme.sepia),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        MonsterEncounter.deadlyExplanation,
                        style: TextStyle(
                          fontSize: 9,
                          fontStyle: FontStyle.italic,
                          color: JuiceTheme.sepia,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _MonsterQuickButton(
                      title: 'Roll Encounter',
                      subtitle: '2d10 for row + difficulty\ndoubles = boss',
                      icon: Icons.casino,
                      color: combatColor,
                      onTap: () {
                        widget.onRoll(MonsterEncounter.rollEncounter());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MonsterQuickButton(
                      title: 'Roll Tracks',
                      subtitle: '1d6-1@ with disadvantage',
                      icon: Icons.pets,
                      color: JuiceTheme.sepia,
                      onTap: () {
                        widget.onRoll(MonsterEncounter.rollTracks());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // By Difficulty section
              SectionHeader(icon: Icons.trending_up, title: 'By Difficulty', color: JuiceTheme.categoryCombat, iconSize: 14, showDivider: true),
              const SizedBox(height: 6),
              // 2x2 grid for difficulties
              Row(
                children: [
                  Expanded(
                    child: _MonsterDifficultyChip(
                      label: 'Easy (1-4)',
                      subtitle: 'Lower CR monsters',
                      color: JuiceTheme.success,
                      onTap: () {
                        widget.onRoll(MonsterEncounter.rollEncounter(forcedDifficulty: MonsterDifficulty.easy));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _MonsterDifficultyChip(
                      label: 'Medium (5-8)',
                      subtitle: 'Standard CR',
                      color: JuiceTheme.juiceOrange,
                      onTap: () {
                        widget.onRoll(MonsterEncounter.rollEncounter(forcedDifficulty: MonsterDifficulty.medium));
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
                    child: _MonsterDifficultyChip(
                      label: 'Hard (9-0)',
                      subtitle: 'Higher CR monsters',
                      color: JuiceTheme.danger,
                      onTap: () {
                        widget.onRoll(MonsterEncounter.rollEncounter(forcedDifficulty: MonsterDifficulty.hard));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _MonsterDifficultyChip(
                      label: 'Boss',
                      subtitle: 'Legendary monster',
                      color: JuiceTheme.mystic,
                      icon: Icons.star,
                      onTap: () {
                        widget.onRoll(MonsterEncounter.rollEncounter(forcedDifficulty: MonsterDifficulty.boss));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Special Rows section
              SectionHeader(icon: Icons.star_border, title: 'Special Rows', color: JuiceTheme.categoryCombat, iconSize: 14, showDivider: true),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _MonsterSpecialRowButton(
                      label: '* (Nature/Plants)',
                      subtitle: 'Blights, hags, plant creatures',
                      icon: Icons.eco,
                      color: JuiceTheme.categoryExplore,
                      onTap: () {
                        widget.onRoll(MonsterEncounter.rollSpecialRow(humanoid: false));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _MonsterSpecialRowButton(
                      label: '** (Humanoids)',
                      subtitle: 'Bandits, scouts, veterans',
                      icon: Icons.person,
                      color: JuiceTheme.rust,
                      onTap: () {
                        widget.onRoll(MonsterEncounter.rollSpecialRow(humanoid: true));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
  }
}

/// Primary action button for Monster dialog
class _MonsterPrimaryButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  
  const _MonsterPrimaryButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final combatColor = JuiceTheme.categoryCombat;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: combatColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: combatColor.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: combatColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 18, color: combatColor),
              ),
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
                        color: combatColor,
                      ),
                    ),
                    const SizedBox(height: 2),
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
              Icon(Icons.chevron_right, size: 18, color: combatColor.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quick roll button for Monster dialog
class _MonsterQuickButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  
  const _MonsterQuickButton({
    required this.title,
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
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 9,
                  color: JuiceTheme.parchmentDark,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Difficulty chip for Monster dialog
class _MonsterDifficultyChip extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  final IconData? icon;
  final VoidCallback onTap;
  
  const _MonsterDifficultyChip({
    required this.label,
    required this.subtitle,
    required this.color,
    this.icon,
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 8,
                        color: JuiceTheme.parchmentDark,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 14, color: color.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Special row button for Monster dialog
class _MonsterSpecialRowButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  
  const _MonsterSpecialRowButton({
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
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 12, color: color),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: color,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 12, color: color.withOpacity(0.5)),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
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
