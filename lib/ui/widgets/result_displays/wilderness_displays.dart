/// Wilderness and Monster Display Builders - Display widgets for exploration results.
///
/// This module handles display for:
/// - [WildernessAreaResult] - Wilderness environment/terrain
/// - [WildernessEncounterResult] - Wilderness encounter type with follow-ups
/// - [WildernessWeatherResult] - Weather conditions
/// - [FullMonsterEncounterResult] - Full monster group encounter
/// - [MonsterEncounterResult] - Single monster encounter
/// - [MonsterTracksResult] - Monster track signs
/// - [LocationResult] - Compass-based location grid
library;

import 'package:flutter/material.dart';

import '../../../core/fate_dice_formatter.dart';
import '../../../presets/monster_encounter.dart';
import '../../../presets/wilderness.dart';
import '../../../presets/location.dart';
import '../../theme/juice_theme.dart';
import '../result_display_registry.dart';

/// Register all Wilderness and Monster display builders with the registry.
void registerWildernessDisplays() {
  ResultDisplayRegistry.register<WildernessAreaResult>(_buildWildernessAreaDisplay);
  ResultDisplayRegistry.register<WildernessEncounterResult>(_buildWildernessEncounterDisplay);
  ResultDisplayRegistry.register<WildernessWeatherResult>(_buildWildernessWeatherDisplay);
  ResultDisplayRegistry.register<FullMonsterEncounterResult>(_buildFullMonsterEncounterDisplay);
  ResultDisplayRegistry.register<MonsterEncounterResult>(_buildMonsterEncounterDisplay);
  ResultDisplayRegistry.register<MonsterTracksResult>(_buildMonsterTracksDisplay);
  ResultDisplayRegistry.register<LocationResult>(_buildLocationDisplay);
}

// ═══════════════════════════════════════════════════════════════════════════
// WILDERNESS AREA DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildWildernessAreaDisplay(WildernessAreaResult result, ThemeData theme) {
  final exploreColor = JuiceTheme.categoryExplore;
  
  // For manual set, show a simpler display
  if (result.isManualSet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: JuiceTheme.juiceOrange15,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: JuiceTheme.juiceOrange40),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pin_drop, size: 12, color: JuiceTheme.juiceOrange),
              const SizedBox(width: 4),
              Text(
                'POSITION SET',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: JuiceTheme.juiceOrange,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Result container
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: exploreColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: exploreColor.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.landscape, size: 18, color: exploreColor),
              const SizedBox(width: 8),
              Text(
                result.fullDescription,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: JuiceTheme.fontFamilySerif,
                  color: exploreColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  final fateSymbols = FateDiceFormatter.diceToSymbols(result.envFateDice);
  final typeSymbol = FateDiceFormatter.dieToSymbol(result.typeFateDie);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Type badge
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: exploreColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: exploreColor.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(result.isTransition ? Icons.swap_horiz : Icons.explore, size: 12, color: exploreColor),
            const SizedBox(width: 4),
            Text(
              result.isTransition ? 'TRANSITION' : 'INITIALIZE',
              style: theme.textTheme.labelSmall?.copyWith(
                color: exploreColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      // Dice display
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: exploreColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '2dF ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: JuiceTheme.fontFamilyMono,
                    color: exploreColor,
                  ),
                ),
                Text(
                  fateSymbols,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: JuiceTheme.fontFamilyMono,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: JuiceTheme.info10,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '1dF ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: JuiceTheme.fontFamilyMono,
                    color: JuiceTheme.info,
                  ),
                ),
                Text(
                  typeSymbol,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: JuiceTheme.fontFamilyMono,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      // Transition arrow and result
      if (result.isTransition && result.previousEnvironment != null)
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: JuiceTheme.sepia10,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                result.previousEnvironment!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: JuiceTheme.sepia,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.arrow_forward, size: 16, color: exploreColor),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: exploreColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: exploreColor.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.landscape, size: 16, color: exploreColor),
                    const SizedBox(width: 6),
                    Text(
                      result.fullDescription,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: JuiceTheme.fontFamilySerif,
                        color: exploreColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
      else
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: exploreColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: exploreColor.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.landscape, size: 16, color: exploreColor),
              const SizedBox(width: 6),
              Text(
                result.fullDescription,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: JuiceTheme.fontFamilySerif,
                  color: exploreColor,
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// WILDERNESS ENCOUNTER DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildWildernessEncounterDisplay(WildernessEncounterResult result, ThemeData theme) {
  final exploreColor = JuiceTheme.categoryExplore;
  
  // Determine encounter color based on type
  Color encounterColor = exploreColor;
  IconData encounterIcon = Icons.explore;
  
  if (result.encounter == 'Natural Hazard') {
    encounterColor = JuiceTheme.danger;
    encounterIcon = Icons.warning;
  } else if (result.encounter == 'Monster') {
    encounterColor = JuiceTheme.categoryCombat;
    encounterIcon = Icons.pest_control;
  } else if (result.encounter == 'Destination/Lost') {
    encounterColor = result.becameLost ? JuiceTheme.juiceOrange : JuiceTheme.info;
    encounterIcon = result.becameLost ? Icons.explore_off : Icons.flag;
  } else if (result.encounter == 'River/Road') {
    encounterColor = result.becameFound ? JuiceTheme.info : JuiceTheme.mystic;
    encounterIcon = Icons.route;
  } else if (result.encounter == 'Weather') {
    encounterColor = JuiceTheme.info;
    encounterIcon = Icons.cloud;
  } else if (result.encounter == 'Challenge') {
    encounterColor = JuiceTheme.mystic;
    encounterIcon = Icons.fitness_center;
  } else if (result.encounter == 'Feature') {
    encounterColor = JuiceTheme.sepia;
    encounterIcon = Icons.auto_awesome;
  } else if (result.encounter == 'Dungeon') {
    encounterColor = JuiceTheme.rust;
    encounterIcon = Icons.castle;
  } else if (result.encounter.contains('Settlement') || result.encounter.contains('Camp')) {
    encounterColor = JuiceTheme.gold;
    encounterIcon = Icons.home;
  }
  
  // Build the encounter text with italic styling where appropriate
  Widget encounterText;
  if (result.partialItalic != null) {
    // Settlement/Camp - only "Settlement" is italic
    encounterText = RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: result.partialItalic!,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: JuiceTheme.fontFamilySerif,
              color: encounterColor,
              fontStyle: FontStyle.italic,
            ),
          ),
          TextSpan(
            text: '/${result.encounter.split('/').last}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: JuiceTheme.fontFamilySerif,
              color: encounterColor,
            ),
          ),
        ],
      ),
    );
  } else {
    encounterText = Text(
      result.encounter,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontFamily: JuiceTheme.fontFamilySerif,
        color: encounterColor,
        fontStyle: result.isItalic ? FontStyle.italic : FontStyle.normal,
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Type badge and dice display row
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: exploreColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: exploreColor.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shuffle, size: 12, color: exploreColor),
                const SizedBox(width: 4),
                Text(
                  'ENCOUNTER',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: exploreColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: JuiceTheme.parchment50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'd${result.dieSize}${result.skewUsed != 'straight' ? '@${result.skewUsed[0].toUpperCase()}' : ''}: ${result.roll}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: JuiceTheme.fontFamilyMono,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (result.wasLost) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: JuiceTheme.juiceOrange20,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: JuiceTheme.juiceOrange50),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.explore_off, size: 10, color: JuiceTheme.juiceOrange),
                  const SizedBox(width: 3),
                  Text(
                    'LOST',
                    style: TextStyle(
                      fontSize: 10,
                      color: JuiceTheme.juiceOrange,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: 8),
      // Result container
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: encounterColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: encounterColor.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(encounterIcon, size: 16, color: encounterColor),
                const SizedBox(width: 6),
                encounterText,
              ],
            ),
          ),
          if (result.becameLost) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: JuiceTheme.juiceOrange20,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: JuiceTheme.juiceOrange50),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.explore_off, size: 12, color: JuiceTheme.juiceOrange),
                  const SizedBox(width: 4),
                  Text(
                    'Now Lost!',
                    style: TextStyle(fontSize: 11, color: JuiceTheme.juiceOrange, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
          if (result.becameFound) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: JuiceTheme.success20,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: JuiceTheme.success50),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 12, color: JuiceTheme.success),
                  const SizedBox(width: 4),
                  Text(
                    'Found!',
                    style: TextStyle(fontSize: 11, color: JuiceTheme.success, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      // Show follow-up result with arrow notation if present
      if (result.followUpResult != null) ...[
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.subdirectory_arrow_right, size: 16, color: JuiceTheme.sepia),
            const SizedBox(width: 6),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getFollowUpThemeColor(result.encounter).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getFollowUpThemeColor(result.encounter).withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: JuiceTheme.parchment50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'd10: ${result.followUpRoll}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: JuiceTheme.fontFamilyMono,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            result.followUpResult!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              fontFamily: JuiceTheme.fontFamilySerif,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (result.followUpData != null && result.encounter == 'Monster' && result.followUpData!['hasBoss'] == true) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: JuiceTheme.categoryCombat20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 12, color: JuiceTheme.categoryCombat),
                            const SizedBox(width: 4),
                            Text(
                              'Boss: ${result.followUpData!['bossMonster']}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: JuiceTheme.categoryCombat,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ] else if (result.requiresFollowUp) ...[
        // Legacy display for old results without embedded follow-up
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.subdirectory_arrow_right, size: 14, color: JuiceTheme.sepia50),
            const SizedBox(width: 4),
            Text(
              _getFollowUpHint(result.encounter),
              style: TextStyle(
                color: JuiceTheme.sepia70,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    ],
  );
}

/// Get theme color for follow-up section based on encounter type.
Color _getFollowUpThemeColor(String encounter) {
  switch (encounter) {
    case 'Monster':
      return JuiceTheme.categoryCombat;
    case 'Natural Hazard':
      return JuiceTheme.danger;
    case 'Weather':
      return JuiceTheme.info;
    case 'Challenge':
      return JuiceTheme.mystic;
    case 'Dungeon':
      return JuiceTheme.rust;
    case 'Feature':
      return JuiceTheme.sepia;
    default:
      return JuiceTheme.categoryExplore;
  }
}

/// Get hint text for follow-up actions based on encounter type.
String _getFollowUpHint(String encounter) {
  switch (encounter) {
    case 'Monster':
      return 'Roll Monster Encounter';
    case 'Natural Hazard':
      return 'Roll Natural Hazard';
    case 'Weather':
      return 'Roll Weather';
    case 'Challenge':
      return 'Roll Challenge';
    case 'Dungeon':
      return 'Roll Dungeon';
    case 'Feature':
      return 'Roll Feature';
    default:
      return 'Roll for details';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WILDERNESS WEATHER DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildWildernessWeatherDisplay(WildernessWeatherResult result, ThemeData theme) {
  return Row(children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text('d6@${result.environmentSkew}: ${result.baseRoll}', style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, fontWeight: FontWeight.bold, color: Colors.blue)),
    ),
    const SizedBox(width: 8),
    Text(result.weather, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
  ]);
}

// ═══════════════════════════════════════════════════════════════════════════
// FULL MONSTER ENCOUNTER DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildFullMonsterEncounterDisplay(FullMonsterEncounterResult result, ThemeData theme) {
  final combatColor = JuiceTheme.categoryCombat;
  
  final difficultyColor = switch (result.difficulty) {
    MonsterDifficulty.easy => JuiceTheme.success,
    MonsterDifficulty.medium => JuiceTheme.juiceOrange,
    MonsterDifficulty.hard => JuiceTheme.danger,
    MonsterDifficulty.boss => JuiceTheme.mystic,
  };

  // Parse dice results: first 1-2 dice are row roll (d6), last 2 are difficulty (d10)
  // Structure: [row dice...] + [diff d10, diff d10]
  final totalDice = result.diceResults.length;
  final rowDiceCount = totalDice - 2; // Last 2 are always the difficulty dice
  final rowDice = rowDiceCount > 0 ? result.diceResults.sublist(0, rowDiceCount) : <int>[];
  final diffDice = totalDice >= 2 ? result.diceResults.sublist(totalDice - 2) : <int>[];
  
  // Row dice label based on environment formula (advantage/disadvantage)
  final rowDiceLabel = rowDice.length == 2 ? '2d6' : '1d6';
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Type badge row
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: combatColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: combatColor.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.groups, size: 12, color: combatColor),
                const SizedBox(width: 4),
                Text(
                  'FULL ENCOUNTER',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: combatColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      // Dice display row - show row dice and difficulty dice separately
      Row(
        children: [
          // Row dice (1d6 or 2d6 for environment)
          if (rowDice.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: JuiceTheme.categoryExplore15,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Row $rowDiceLabel: ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      color: JuiceTheme.categoryExplore,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    '[${rowDice.join(", ")}]',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          if (rowDice.isNotEmpty && diffDice.isNotEmpty)
            const SizedBox(width: 6),
          // Difficulty dice (2d10)
          if (diffDice.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: difficultyColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Diff 2d10: ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      color: difficultyColor,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    '[${diffDice.join(", ")}]',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      const SizedBox(height: 6),
      // Environment and formula info
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: JuiceTheme.categoryExplore10,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.landscape, size: 12, color: JuiceTheme.categoryExplore),
                const SizedBox(width: 4),
                Text(
                  MonsterEncounter.environmentNames[(result.environmentRow - 1).clamp(0, 9)],
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: JuiceTheme.categoryExplore,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: JuiceTheme.info10,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              result.environmentFormula,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: JuiceTheme.fontFamilyMono,
                color: JuiceTheme.info,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      // Environment and difficulty row
      Row(
        children: [
          if (result.isForest && result.row == 10) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: JuiceTheme.categoryExplore20,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: JuiceTheme.categoryExplore40),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.eco, size: 10, color: JuiceTheme.categoryExplore),
                  const SizedBox(width: 3),
                  Text(
                    'FOREST→BLIGHTS',
                    style: TextStyle(
                      fontSize: 9,
                      color: JuiceTheme.categoryExplore,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: difficultyColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: difficultyColor.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (result.difficulty == MonsterDifficulty.boss)
                  Icon(Icons.star, size: 12, color: difficultyColor),
                if (result.difficulty == MonsterDifficulty.boss)
                  const SizedBox(width: 4),
                Text(
                  MonsterEncounter.difficultyName(result.difficulty),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: difficultyColor,
                  ),
                ),
              ],
            ),
          ),
          if (result.wasDoubles) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: JuiceTheme.mystic20,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: JuiceTheme.mystic40),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, size: 10, color: JuiceTheme.mystic),
                  const SizedBox(width: 3),
                  Text(
                    'DOUBLES!',
                    style: TextStyle(
                      fontSize: 9,
                      color: JuiceTheme.mystic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: 8),
      // Monster list
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: combatColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: combatColor.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.hasBoss && result.bossMonster != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: JuiceTheme.mystic15,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: JuiceTheme.mystic40),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 14, color: JuiceTheme.mystic),
                    const SizedBox(width: 6),
                    Text(
                      '1× ${result.bossMonster} (Boss)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: JuiceTheme.fontFamilySerif,
                        color: JuiceTheme.mystic,
                      ),
                    ),
                  ],
                ),
              ),
              if (result.monsters.any((m) => m.count > 0))
                const SizedBox(height: 6),
            ],
            ...result.monsters.where((m) => m.count > 0).map((monster) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                children: [
                  Icon(Icons.pest_control, size: 12, color: combatColor.withOpacity(0.6)),
                  const SizedBox(width: 6),
                  Text(
                    '${monster.count}× ${monster.name}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: JuiceTheme.fontFamilySerif,
                    ),
                  ),
                ],
              ),
            )),
            if (result.monsters.every((m) => m.count == 0) && !result.hasBoss)
              Row(
                children: [
                  Icon(Icons.sentiment_neutral, size: 14, color: JuiceTheme.sepia),
                  const SizedBox(width: 6),
                  Text(
                    'No monsters appeared (all rolled 0)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: JuiceTheme.sepia,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// MONSTER ENCOUNTER DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildMonsterEncounterDisplay(MonsterEncounterResult result, ThemeData theme) {
  final combatColor = JuiceTheme.categoryCombat;
  
  final difficultyColor = switch (result.difficulty) {
    MonsterDifficulty.easy => JuiceTheme.success,
    MonsterDifficulty.medium => JuiceTheme.juiceOrange,
    MonsterDifficulty.hard => JuiceTheme.danger,
    MonsterDifficulty.boss => JuiceTheme.mystic,
  };

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Type badge and dice row
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: combatColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: combatColor.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.casino, size: 12, color: combatColor),
                const SizedBox(width: 4),
                Text(
                  'ENCOUNTER',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: combatColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          if (result.diceResults.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: JuiceTheme.parchment50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '2d10: [${result.diceResults.join(", ")}]',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: JuiceTheme.fontFamilyMono,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: 6),
      // Difficulty and status flags
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: difficultyColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: difficultyColor.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (result.difficulty == MonsterDifficulty.boss)
                  Icon(Icons.star, size: 12, color: difficultyColor),
                if (result.difficulty == MonsterDifficulty.boss)
                  const SizedBox(width: 4),
                Text(
                  MonsterEncounter.difficultyName(result.difficulty),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: difficultyColor,
                  ),
                ),
              ],
            ),
          ),
          // Show DOUBLES! only if not Boss (Boss already implies doubles in its name)
          if (result.wasDoubles && result.difficulty != MonsterDifficulty.boss) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: JuiceTheme.mystic20,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: JuiceTheme.mystic40),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, size: 10, color: JuiceTheme.mystic),
                  const SizedBox(width: 3),
                  Text(
                    'DOUBLES!',
                    style: TextStyle(
                      fontSize: 9,
                      color: JuiceTheme.mystic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (result.isDeadly) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: JuiceTheme.danger20,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: JuiceTheme.danger40),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '💀',
                    style: TextStyle(fontSize: 10),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'DEADLY',
                    style: TextStyle(
                      fontSize: 9,
                      color: JuiceTheme.danger,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: 8),
      // Monster result
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: combatColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: combatColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pest_control, size: 16, color: combatColor),
            const SizedBox(width: 8),
            Text(
              result.monster,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: JuiceTheme.fontFamilySerif,
                color: combatColor,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// MONSTER TRACKS DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildMonsterTracksDisplay(MonsterTracksResult result, ThemeData theme) {
  final trackColor = JuiceTheme.sepia;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Type badge and dice row
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: trackColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: trackColor.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pets, size: 12, color: trackColor),
                const SizedBox(width: 4),
                Text(
                  'TRACKS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: trackColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          if (result.diceResults.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: JuiceTheme.parchment50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '1d6-1@: [${result.diceResults.join(", ")}]',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: JuiceTheme.fontFamilyMono,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: 6),
      // Modifier display
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: JuiceTheme.info10,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_circle_outline, size: 12, color: JuiceTheme.info),
                const SizedBox(width: 4),
                Text(
                  'Modifier: ${result.modifier >= 0 ? '+' : ''}${result.modifier}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: JuiceTheme.fontFamilyMono,
                    color: JuiceTheme.info,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      // Tracks result
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: trackColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: trackColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets, size: 16, color: trackColor),
            const SizedBox(width: 8),
            Text(
              result.tracks,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: JuiceTheme.fontFamilySerif,
                color: trackColor,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// LOCATION DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildLocationDisplay(LocationResult result, ThemeData theme) {
  final exploreColor = JuiceTheme.categoryExplore;
  final compassColor = JuiceTheme.info;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Compass description - the main result
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: exploreColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: exploreColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.explore, size: 18, color: exploreColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                result.compassDescription,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: exploreColor,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: exploreColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'd100: ${result.roll}',
                style: TextStyle(
                  fontFamily: JuiceTheme.fontFamilyMono,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: exploreColor,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      
      // 5x5 grid with selected cell highlighted
      Center(
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: JuiceTheme.surface50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: compassColor.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // North label
              Text('N', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontFamily: JuiceTheme.fontFamilyMono, color: compassColor)),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // West label
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text('W', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontFamily: JuiceTheme.fontFamilyMono, color: compassColor)),
                  ),
                  // 5x5 grid
                  Column(
                    children: List.generate(5, (row) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (col) {
                          // Grid uses 1-indexed (row 1-5, col 1-5)
                          final isSelected = (row + 1) == result.row && (col + 1) == result.column;
                          final isCenter = row == 2 && col == 2;
                          final isClose = !isCenter && row >= 1 && row <= 3 && col >= 1 && col <= 3;
                          
                          Color cellColor;
                          if (isSelected) {
                            cellColor = JuiceTheme.juiceOrange;
                          } else if (isCenter) {
                            cellColor = JuiceTheme.gold;
                          } else if (isClose) {
                            cellColor = exploreColor;
                          } else {
                            cellColor = JuiceTheme.parchmentDark;
                          }
                          
                          return Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: cellColor.withOpacity(isSelected ? 0.6 : (isCenter ? 0.3 : 0.15)),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: isSelected ? JuiceTheme.juiceOrange : cellColor.withOpacity(0.4),
                                width: isSelected ? 2 : (isCenter ? 1 : 0.5),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                isSelected ? '●' : (isCenter ? '◉' : (isClose ? '○' : '·')),
                                style: TextStyle(
                                  fontSize: isSelected ? 10 : 8,
                                  color: isSelected ? Colors.white : cellColor,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                  // East label
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text('E', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontFamily: JuiceTheme.fontFamilyMono, color: compassColor)),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              // South label
              Text('S', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontFamily: JuiceTheme.fontFamilyMono, color: compassColor)),
            ],
          ),
        ),
      ),
      const SizedBox(height: 6),
      
      // Grid position footer
      Center(
        child: Text(
          'Grid [${result.row},${result.column}]',
          style: TextStyle(
            fontSize: 10,
            fontFamily: JuiceTheme.fontFamilyMono,
            color: JuiceTheme.parchment60,
          ),
        ),
      ),
    ],
  );
}
