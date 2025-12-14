/// Dungeon Display Builders - Display widgets for dungeon exploration results.
///
/// This module handles display for:
/// - [DungeonEncounterResult] - Dungeon encounter type with monster/trap
/// - [DungeonNameResult] - Generated dungeon name
/// - [DungeonAreaResult] - Dungeon area with phase-based skew
/// - [FullDungeonAreaResult] - Area with condition
/// - [TwoPassAreaResult] - Two-pass area generation with secrets
/// - [DungeonMonsterResult] - Monster description
/// - [DungeonTrapResult] - Trap description
/// - [TrapProcedureResult] - Trap with DC
/// - [DungeonDetailResult] - Dungeon detail/feature
library;

import 'package:flutter/material.dart';

import '../../../presets/dungeon_generator.dart';
import '../../theme/juice_theme.dart';
import '../result_display_registry.dart';

/// Register all Dungeon display builders with the registry.
void registerDungeonDisplays() {
  ResultDisplayRegistry.register<DungeonEncounterResult>(_buildDungeonEncounterDisplay);
  ResultDisplayRegistry.register<DungeonNameResult>(_buildDungeonNameDisplay);
  ResultDisplayRegistry.register<DungeonAreaResult>(_buildDungeonAreaDisplay);
  ResultDisplayRegistry.register<FullDungeonAreaResult>(_buildFullDungeonAreaDisplay);
  ResultDisplayRegistry.register<TwoPassAreaResult>(_buildTwoPassAreaDisplay);
  ResultDisplayRegistry.register<DungeonMonsterResult>(_buildDungeonMonsterDisplay);
  ResultDisplayRegistry.register<DungeonTrapResult>(_buildDungeonTrapDisplay);
  ResultDisplayRegistry.register<TrapProcedureResult>(_buildTrapProcedureDisplay);
  ResultDisplayRegistry.register<DungeonDetailResult>(_buildDungeonDetailDisplay);
}

// ═══════════════════════════════════════════════════════════════════════════
// DUNGEON ENCOUNTER DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildDungeonEncounterDisplay(DungeonEncounterResult result, ThemeData theme) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: JuiceTheme.rust10, borderRadius: BorderRadius.circular(8)),
      child: Text('Encounter: ${result.encounterRoll.result}', style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, fontWeight: FontWeight.bold, color: JuiceTheme.rust)),
    ),
    if (result.monster != null) ...[
      const SizedBox(height: 4),
      Text('Monster: ${result.monster!.monsterDescription}', style: theme.textTheme.bodyMedium),
    ],
    if (result.trap != null) ...[
      const SizedBox(height: 4),
      Text('Trap: ${result.trap!.trapDescription}', style: theme.textTheme.bodyMedium),
    ],
  ]);
}

// ═══════════════════════════════════════════════════════════════════════════
// DUNGEON NAME DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildDungeonNameDisplay(DungeonNameResult result, ThemeData theme) {
  return Row(children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: JuiceTheme.rust10, borderRadius: BorderRadius.circular(8)),
      child: Text('3d10: [${result.typeRoll}, ${result.descriptionRoll}, ${result.subjectRoll}]', style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, fontWeight: FontWeight.bold, color: JuiceTheme.rust)),
    ),
    const SizedBox(width: 8),
    Expanded(child: Text(result.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontFamily: JuiceTheme.fontFamilySerif))),
  ]);
}

// ═══════════════════════════════════════════════════════════════════════════
// DUNGEON AREA DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildDungeonAreaDisplay(DungeonAreaResult result, ThemeData theme) {
  final phaseColor = result.phase == DungeonPhase.entering ? JuiceTheme.gold : JuiceTheme.success;
  final phaseLabel = result.phase == DungeonPhase.entering ? '@-' : '@+';
  
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Wrap(spacing: 6, runSpacing: 4, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: phaseColor.withOpacity(0.15), borderRadius: BorderRadius.circular(4), border: Border.all(color: phaseColor.withOpacity(0.5))),
        child: Text('${result.roll1},${result.roll2} $phaseLabel → ${result.chosenRoll}', style: TextStyle(fontWeight: FontWeight.bold, color: phaseColor, fontFamily: JuiceTheme.fontFamilyMono, fontSize: 11)),
      ),
      if (result.isDoubles)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.amber)),
          child: Text('🎲 DOUBLES!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade800, fontSize: 11)),
        ),
    ]),
    const SizedBox(height: 4),
    Text(result.areaType, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
    if (result.passage != null) ...[
      const SizedBox(height: 4),
      Text('Passage: ${result.passage!.result}', style: theme.textTheme.bodySmall),
    ],
  ]);
}

// ═══════════════════════════════════════════════════════════════════════════
// FULL DUNGEON AREA DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildFullDungeonAreaDisplay(FullDungeonAreaResult result, ThemeData theme) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _buildDungeonAreaDisplay(result.area, theme),
    const SizedBox(height: 6),
    Text('Condition: ${result.condition.result}', style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
  ]);
}

// ═══════════════════════════════════════════════════════════════════════════
// TWO PASS AREA DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildTwoPassAreaDisplay(TwoPassAreaResult result, ThemeData theme) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: JuiceTheme.rust15, borderRadius: BorderRadius.circular(4), border: Border.all(color: JuiceTheme.rust50)),
      child: Text('${result.roll1},${result.roll2} → ${result.chosenRoll}', style: TextStyle(fontWeight: FontWeight.bold, color: JuiceTheme.rust, fontFamily: JuiceTheme.fontFamilyMono, fontSize: 11)),
    ),
    const SizedBox(height: 4),
    Text(result.areaType, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
    const SizedBox(height: 6),
    Text('Condition: ${result.condition.result}', style: theme.textTheme.bodySmall),
    if (result.passage != null) Text('Passage: ${result.passage!.result}', style: theme.textTheme.bodySmall),
    if (result.isSecondDoubles) Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: JuiceTheme.gold20, borderRadius: BorderRadius.circular(4)),
      child: Text('⚡ Secret/Treasure!', style: TextStyle(fontWeight: FontWeight.bold, color: JuiceTheme.gold, fontSize: 11)),
    ),
  ]);
}

// ═══════════════════════════════════════════════════════════════════════════
// DUNGEON MONSTER DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildDungeonMonsterDisplay(DungeonMonsterResult result, ThemeData theme) {
  return Row(children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: JuiceTheme.danger10, borderRadius: BorderRadius.circular(8)),
      child: Text('2d10: [${result.descriptorRoll}, ${result.abilityRoll}]', style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, color: JuiceTheme.danger)),
    ),
    const SizedBox(width: 8),
    Expanded(child: Text(result.monsterDescription, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
  ]);
}

// ═══════════════════════════════════════════════════════════════════════════
// DUNGEON TRAP DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildDungeonTrapDisplay(DungeonTrapResult result, ThemeData theme) {
  return Row(children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text('2d10: [${result.actionRoll}, ${result.subjectRoll}]', style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, color: Colors.orange)),
    ),
    const SizedBox(width: 8),
    Expanded(child: Text(result.trapDescription, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
  ]);
}

// ═══════════════════════════════════════════════════════════════════════════
// TRAP PROCEDURE DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildTrapProcedureDisplay(TrapProcedureResult result, ThemeData theme) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _buildDungeonTrapDisplay(result.trap, theme),
    const SizedBox(height: 6),
    Text('DC ${result.dc}', style: TextStyle(fontWeight: FontWeight.bold, color: JuiceTheme.gold)),
  ]);
}

// ═══════════════════════════════════════════════════════════════════════════
// DUNGEON DETAIL DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildDungeonDetailDisplay(DungeonDetailResult result, ThemeData theme) {
  return Row(children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: JuiceTheme.rust10, borderRadius: BorderRadius.circular(8)),
      child: Text('d10: ${result.roll}', style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, color: JuiceTheme.rust)),
    ),
    const SizedBox(width: 8),
    Expanded(child: Text(result.result, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
  ]);
}
