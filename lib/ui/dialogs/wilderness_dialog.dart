import 'package:flutter/material.dart';
import '../theme/juice_theme.dart';
import '../shared/oracle_dialog.dart';
import '../shared/dialog_components.dart';
import '../../presets/wilderness.dart';
import '../../presets/dungeon_generator.dart';
import '../../presets/challenge.dart';
import '../../presets/monster_encounter.dart';
import '../../models/roll_result.dart';

/// Dialog for Wilderness exploration options.
/// Includes environment transitions, encounters, and monster levels.
/// 
/// State management is now external - the dialog receives state and
/// calls back when state changes.
class WildernessDialog extends StatefulWidget {
  final Wilderness wilderness;
  final WildernessState? wildernessState;
  final void Function(RollResult) onRoll;
  final void Function(WildernessState?) onStateChange;
  final DungeonGenerator dungeonGenerator;
  final Challenge challenge;

  const WildernessDialog({
    super.key,
    required this.wilderness,
    required this.wildernessState,
    required this.onRoll,
    required this.onStateChange,
    required this.dungeonGenerator,
    required this.challenge,
  });

  @override
  State<WildernessDialog> createState() => _WildernessDialogState();
}

class _WildernessDialogState extends State<WildernessDialog> {
  bool _hasDangerousTerrain = false;
  bool _hasMapOrGuide = false;
  bool _showEnvironmentPicker = false;
  int _selectedEnvironment = 6; // Default to Forest
  int _selectedType = 6; // Default to Tropical

  @override
  Widget build(BuildContext context) {
    final state = widget.wildernessState;
    final isInitialized = state != null;
    
    return SimpleOracleDialog(
      title: 'Wilderness',
      closeButtonText: 'Close',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show current state if initialized
          if (isInitialized) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _WildernessStateCard(state: state)),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Reset Wilderness?'),
                        content: const Text('This will clear the current wilderness state. You will need to initialize a new starting area.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              widget.onStateChange(null);
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Wilderness state reset')),
                              );
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: JuiceTheme.sepia10,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: JuiceTheme.sepia30),
                    ),
                    child: Icon(
                      Icons.refresh,
                      size: 18,
                      color: JuiceTheme.sepia70,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // ========== Environment Section ==========
          SectionHeader(
            icon: Icons.terrain,
            title: 'Environment',
            color: JuiceTheme.categoryExplore,
            iconSize: 14,
          ),
          const SizedBox(height: 6),
          
          if (!isInitialized) ...[
            _WildernessActionButton(
              title: 'Initialize Random Area',
              subtitle: 'Start in a random environment (1d10 + 1dF)',
              icon: Icons.shuffle,
              color: JuiceTheme.categoryExplore,
              onTap: () {
                final result = widget.wilderness.initializeRandom();
                widget.onStateChange(result.newState);
                widget.onRoll(result);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 6),
            _WildernessActionButton(
              title: _showEnvironmentPicker ? 'Hide Picker' : 'Set Known Position...',
              subtitle: 'Start from an existing location',
              icon: _showEnvironmentPicker ? Icons.expand_less : Icons.expand_more,
              color: JuiceTheme.sepia,
              onTap: () => setState(() => _showEnvironmentPicker = !_showEnvironmentPicker),
            ),
          ] else ...[
            _WildernessActionButton(
              title: 'Transition to Next Area',
              subtitle: 'Move to adjacent area (2dF env + 1dF type)',
              icon: Icons.arrow_forward,
              color: JuiceTheme.categoryExplore,
              onTap: () {
                final result = widget.wilderness.transition(state);
                widget.onStateChange(result.newState);
                widget.onRoll(result);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 6),
            _WildernessActionButton(
              title: _showEnvironmentPicker ? 'Hide Picker' : 'Change Position...',
              subtitle: 'Set to a different location',
              icon: _showEnvironmentPicker ? Icons.expand_less : Icons.expand_more,
              color: JuiceTheme.sepia,
              onTap: () => setState(() => _showEnvironmentPicker = !_showEnvironmentPicker),
            ),
          ],

          // Environment picker
          if (_showEnvironmentPicker) ...[
            const SizedBox(height: 8),
            _WildernessEnvironmentPicker(
              selectedEnvironment: _selectedEnvironment,
              selectedType: _selectedType,
              onEnvironmentChanged: (v) => setState(() => _selectedEnvironment = v),
              onTypeChanged: (v) => setState(() => _selectedType = v),
              onConfirm: () {
                final result = widget.wilderness.initializeAt(_selectedEnvironment, typeRow: _selectedType);
                widget.onStateChange(result.newState);
                widget.onRoll(result);
                Navigator.pop(context);
              },
            ),
          ],
          const SizedBox(height: 14),

          // ========== Encounters Section ==========
          SectionHeader(
            icon: Icons.explore,
            title: 'Encounters',
            color: JuiceTheme.categoryExplore,
            iconSize: 14,
          ),
          const SizedBox(height: 6),

          // Skew toggles as compact chips
          Row(
            children: [
              _WildernessModifierChip(
                label: 'Dangerous',
                subtitle: 'Disadvantage',
                isSelected: _hasDangerousTerrain,
                color: JuiceTheme.danger,
                onTap: () => setState(() => _hasDangerousTerrain = !_hasDangerousTerrain),
              ),
              const SizedBox(width: 8),
              _WildernessModifierChip(
                label: 'Map/Guide',
                subtitle: 'Advantage',
                isSelected: _hasMapOrGuide,
                color: JuiceTheme.success,
                onTap: () => setState(() => _hasMapOrGuide = !_hasMapOrGuide),
              ),
            ],
          ),
          const SizedBox(height: 8),

          _WildernessActionButton(
            title: 'Roll Encounter',
            subtitle: isInitialized 
                ? 'What happens? (d${state.isLost ? 6 : 10}${_getSkewLabel()})'
                : 'What happens? (d10)',
            icon: Icons.casino,
            color: JuiceTheme.gold,
            onTap: () {
              _rollEncounterWithFollowUp();
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 6),

          if (isInitialized && state.isLost) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: JuiceTheme.danger10,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: JuiceTheme.danger30),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, size: 14, color: JuiceTheme.danger),
                  const SizedBox(width: 6),
                  Text(
                    'LOST - using d6 for encounters',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: JuiceTheme.danger,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      widget.onStateChange(state.copyWith(isLost: false));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No longer lost - using d10')),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Mark Found',
                      style: TextStyle(fontSize: 10, color: JuiceTheme.success),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
          ],

          // Secondary encounter options in a compact row
          Row(
            children: [
              Expanded(
                child: _WildernessCompactButton(
                  title: 'Weather',
                  icon: Icons.cloud,
                  color: JuiceTheme.info,
                  onTap: () {
                    // Use state if available, otherwise default to row 5/5
                    final envRow = state?.environmentRow ?? 5;
                    final typeRow = state?.typeRow ?? 5;
                    widget.onRoll(widget.wilderness.rollWeather(
                      environmentRow: envRow,
                      typeRow: typeRow,
                    ));
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _WildernessCompactButton(
                  title: 'Hazard',
                  icon: Icons.warning,
                  color: JuiceTheme.rust,
                  onTap: () {
                    widget.onRoll(widget.wilderness.rollNaturalHazard());
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _WildernessCompactButton(
                  title: 'Feature',
                  icon: Icons.place,
                  color: JuiceTheme.mystic,
                  onTap: () {
                    widget.onRoll(widget.wilderness.rollFeature());
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ========== Monster Level Section ==========
          SectionHeader(
            icon: Icons.pets,
            title: 'Monster Level',
            color: JuiceTheme.categoryExplore,
            iconSize: 14,
          ),
          const SizedBox(height: 6),

          _WildernessActionButton(
            title: 'Roll Monster Level',
            subtitle: isInitialized
                ? 'Based on ${state.environment} (${_getMonsterFormula(state.environmentRow)})'
                : '1d6+modifier with advantage/disadvantage',
            icon: Icons.catching_pokemon,
            color: JuiceTheme.danger,
            onTap: () {
              // Use state if available, otherwise default to row 5
              final envRow = state?.environmentRow ?? 5;
              widget.onRoll(widget.wilderness.rollMonsterLevel(
                environmentRow: envRow,
              ));
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _getMonsterFormula(int environmentRow) {
    // Monster formulas from the wilderness table
    const formulas = [
      '@-',      // 1 Arctic
      '+1@-',    // 2 Mountains
      '+1@-',    // 3 Cavern
      '+2',      // 4 Hills
      '+2@+',    // 5 Grassland
      '+3',      // 6 Forest
      '+3@+',    // 7 Swamp
      '+4',      // 8 Water
      '+4@+',    // 9 Coast
      '+4@+',    // 10 Desert
    ];
    final index = (environmentRow - 1).clamp(0, 9);
    return '1d6${formulas[index]}';
  }

  /// Roll an encounter and automatically roll any required follow-up
  void _rollEncounterWithFollowUp() {
    final currentState = widget.wildernessState;
    
    var encounterResult = widget.wilderness.rollEncounter(
      currentState: currentState,
      hasDangerousTerrain: _hasDangerousTerrain,
      hasMapOrGuide: _hasMapOrGuide,
    );
    
    // If follow-up is required, roll it and embed the result
    if (encounterResult.requiresFollowUp) {
      final encounter = encounterResult.encounter;
      final environmentRow = currentState?.environmentRow ?? 5;
      final typeRow = currentState?.typeRow ?? 5;
      
      if (encounter == 'Natural Hazard') {
        final hazard = widget.wilderness.rollNaturalHazard();
        encounterResult = encounterResult.withFollowUp(
          followUpRoll: hazard.roll,
          followUpResult: hazard.result,
        );
      } else if (encounter == 'Monster') {
        final monster = MonsterEncounter.generateFullEncounter(environmentRow);
        encounterResult = encounterResult.withFollowUp(
          followUpRoll: monster.row + 1,
          followUpResult: monster.encounterSummary,
          followUpData: {
            'difficulty': monster.difficulty.name,
            'hasBoss': monster.hasBoss,
            'bossMonster': monster.bossMonster,
            'environmentFormula': monster.environmentFormula,
          },
        );
      } else if (encounter == 'Weather') {
        final weather = widget.wilderness.rollWeather(
          environmentRow: environmentRow,
          typeRow: typeRow,
        );
        encounterResult = encounterResult.withFollowUp(
          followUpRoll: weather.weatherRow,
          followUpResult: weather.weather,
          followUpData: {
            'baseRoll': weather.baseRoll,
            'formula': weather.formula,
          },
        );
      } else if (encounter == 'Challenge') {
        final challenge = widget.challenge.rollFullChallenge();
        encounterResult = encounterResult.withFollowUp(
          followUpRoll: challenge.physicalRoll,
          followUpResult: '${challenge.physicalSkill} DC${challenge.physicalDc} / ${challenge.mentalSkill} DC${challenge.mentalDc}',
          followUpData: {
            'physicalSkill': challenge.physicalSkill,
            'physicalDc': challenge.physicalDc,
            'mentalSkill': challenge.mentalSkill,
            'mentalDc': challenge.mentalDc,
          },
        );
      } else if (encounter == 'Dungeon') {
        final dungeon = widget.dungeonGenerator.generateName();
        encounterResult = encounterResult.withFollowUp(
          followUpRoll: dungeon.typeRoll,
          followUpResult: dungeon.name,
          followUpData: {
            'type': dungeon.dungeonType,
            'description': dungeon.descriptionWord,
            'subject': dungeon.subject,
          },
        );
      } else if (encounter == 'Feature') {
        final feature = widget.wilderness.rollFeature();
        encounterResult = encounterResult.withFollowUp(
          followUpRoll: feature.roll,
          followUpResult: feature.result,
        );
      }
    }
    
    // Update wilderness state if the encounter changed it
    if (encounterResult.newState != null) {
      widget.onStateChange(encounterResult.newState);
    } else if (encounterResult.becameLost && currentState != null) {
      // If became lost, update the state
      widget.onStateChange(currentState.copyWith(isLost: true));
    }
    
    // Add the single encounter result (with embedded follow-up if any)
    widget.onRoll(encounterResult);
  }

  String _getSkewLabel() {
    if (_hasDangerousTerrain && _hasMapOrGuide) return ''; // Cancel out
    if (_hasDangerousTerrain) return '@-';
    if (_hasMapOrGuide) return '@+';
    return '';
  }
}

// ========== Wilderness Dialog Helper Widgets ==========

class _WildernessStateCard extends StatelessWidget {
  final WildernessState state;

  const _WildernessStateCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Icon(Icons.location_on, size: 16, color: JuiceTheme.categoryExplore),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  state.fullDescription,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: JuiceTheme.fontFamilySerif,
                    color: JuiceTheme.parchment,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _StateInfoChip(
                icon: Icons.cloud,
                label: 'Weather',
                value: '1d6@${state.environmentSkew}+${state.typeModifier}',
              ),
              const SizedBox(width: 8),
              if (state.isLost)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: JuiceTheme.danger20,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: JuiceTheme.danger50),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, size: 10, color: JuiceTheme.danger),
                      const SizedBox(width: 3),
                      Text(
                        'LOST',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: JuiceTheme.danger,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StateInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StateInfoChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: JuiceTheme.sepia10,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: JuiceTheme.parchmentDark),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 9,
              fontFamily: JuiceTheme.fontFamilyMono,
              color: JuiceTheme.parchmentDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _WildernessActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _WildernessActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 9,
                        color: JuiceTheme.parchmentDark,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 16, color: color.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WildernessCompactButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _WildernessCompactButton({
    required this.title,
    required this.icon,
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WildernessModifierChip extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _WildernessModifierChip({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: isSelected ? color.withOpacity(0.2) : JuiceTheme.sepia08,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected ? color.withOpacity(0.5) : JuiceTheme.sepia20,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 14,
                  color: isSelected ? color : JuiceTheme.parchmentDark,
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : JuiceTheme.parchment,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WildernessEnvironmentPicker extends StatelessWidget {
  final int selectedEnvironment;
  final int selectedType;
  final ValueChanged<int> onEnvironmentChanged;
  final ValueChanged<int> onTypeChanged;
  final VoidCallback onConfirm;

  const _WildernessEnvironmentPicker({
    required this.selectedEnvironment,
    required this.selectedType,
    required this.onEnvironmentChanged,
    required this.onTypeChanged,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: JuiceTheme.sepia08,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: JuiceTheme.sepia25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Environment dropdown
          DropdownButtonFormField<int>(
            value: selectedEnvironment,
            decoration: InputDecoration(
              labelText: 'Environment',
              labelStyle: TextStyle(color: JuiceTheme.parchmentDark),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: JuiceTheme.sepia30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: JuiceTheme.sepia30),
              ),
            ),
            dropdownColor: JuiceTheme.surface,
            iconEnabledColor: JuiceTheme.parchment,
            style: TextStyle(color: JuiceTheme.parchment, fontSize: 12),
            selectedItemBuilder: (context) {
              return List.generate(10, (i) {
                final env = Wilderness.environments[i];
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${i + 1}. $env',
                    style: TextStyle(fontSize: 12, color: JuiceTheme.parchment),
                  ),
                );
              });
            },
            items: List.generate(10, (i) {
              final env = Wilderness.environments[i];
              // Parse the environment string to separate name and formula
              final match = RegExp(r'(.+?)\s*(\([^)]+\))').firstMatch(env);
              final name = match?.group(1) ?? env;
              final formula = match?.group(2) ?? '';
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
                        name.trim(),
                        style: TextStyle(fontSize: 13, color: JuiceTheme.parchment, fontWeight: FontWeight.w500),
                      ),
                    ),
                    if (formula.isNotEmpty)
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
            onChanged: (v) => onEnvironmentChanged(v ?? 6),
          ),
          const SizedBox(height: 8),
          // Type dropdown
          DropdownButtonFormField<int>(
            value: selectedType,
            decoration: InputDecoration(
              labelText: 'Type',
              labelStyle: TextStyle(color: JuiceTheme.parchmentDark),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: JuiceTheme.sepia30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: JuiceTheme.sepia30),
              ),
            ),
            dropdownColor: JuiceTheme.surface,
            iconEnabledColor: JuiceTheme.parchment,
            style: TextStyle(color: JuiceTheme.parchment, fontSize: 12),
            selectedItemBuilder: (context) {
              return List.generate(10, (i) {
                final type = Wilderness.types[i]['name'] as String;
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${i + 1}. $type',
                    style: TextStyle(fontSize: 12, color: JuiceTheme.parchment),
                  ),
                );
              });
            },
            items: List.generate(10, (i) {
              final type = Wilderness.types[i]['name'] as String;
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
                        type,
                        style: TextStyle(fontSize: 13, color: JuiceTheme.parchment, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              );
            }),
            onChanged: (v) => onTypeChanged(v ?? 6),
          ),
          const SizedBox(height: 10),
          // Preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: JuiceTheme.categoryExplore15,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: JuiceTheme.categoryExplore40),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 14, color: JuiceTheme.categoryExplore),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${Wilderness.types[selectedType - 1]['name']} ${Wilderness.environments[selectedEnvironment - 1]}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: JuiceTheme.fontFamilySerif,
                      color: JuiceTheme.parchment,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onConfirm,
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Set Position'),
              style: ElevatedButton.styleFrom(
                backgroundColor: JuiceTheme.categoryExplore,
                foregroundColor: JuiceTheme.background,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
