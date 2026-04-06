/// Settlement Display Builders - Display widgets for settlement-related roll results.
///
/// This module handles display for:
/// - [SettlementNameResult] - Settlement name with prefix + suffix
/// - [EstablishmentNameResult] - Establishment name with color + object
/// - [SettlementPropertiesResult] - Settlement properties with intensity
/// - [CompleteSettlementResult] - Full settlement with establishments and news
/// - [FullSettlementResult] - Simple full settlement display
library;

import 'package:flutter/material.dart';

import '../../../presets/settlement.dart';
import '../../theme/juice_theme.dart';
import '../result_display_registry.dart';

/// Register all Settlement display builders with the registry.
void registerSettlementDisplays() {
  ResultDisplayRegistry.register<SettlementNameResult>(
      _buildSettlementNameDisplay);
  ResultDisplayRegistry.register<EstablishmentNameResult>(
      _buildEstablishmentNameDisplay);
  ResultDisplayRegistry.register<SettlementPropertiesResult>(
      _buildSettlementPropertiesDisplay);
  ResultDisplayRegistry.register<CompleteSettlementResult>(
      _buildCompleteSettlementDisplay);
  ResultDisplayRegistry.register<FullSettlementResult>(
      _buildFullSettlementDisplay);
}

// ═══════════════════════════════════════════════════════════════════════════
// SETTLEMENT NAME DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildSettlementNameDisplay(
    SettlementNameResult result, ThemeData theme) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.brown.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '2d10: [${result.prefixRoll}, ${result.suffixRoll}]',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: JuiceTheme.fontFamilyMono,
            fontWeight: FontWeight.bold,
            color: Colors.brown.shade700,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${result.prefix} + ${result.suffix}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// ESTABLISHMENT NAME DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildEstablishmentNameDisplay(
    EstablishmentNameResult result, ThemeData theme) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.teal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '2d10: [${result.colorRoll}, ${result.objectRoll}]',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: JuiceTheme.fontFamilyMono,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade700,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        '${result.colorEmoji} ${result.name}',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// SETTLEMENT PROPERTIES DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildSettlementPropertiesDisplay(
    SettlementPropertiesResult result, ThemeData theme) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.teal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'd10+d6: [${result.property1.propertyRoll}+${result.property1.intensityRoll}], [${result.property2.propertyRoll}+${result.property2.intensityRoll}]',
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: JuiceTheme.fontFamilyMono,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade700,
          ),
        ),
      ),
      const SizedBox(height: 6),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          Chip(
            label: Text(
                '${result.property1.intensityDescription} ${result.property1.property}'),
            backgroundColor: Colors.teal.withOpacity(0.2),
            side: const BorderSide(color: Colors.teal),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
          const Text('+'),
          Chip(
            label: Text(
                '${result.property2.intensityDescription} ${result.property2.property}'),
            backgroundColor: Colors.teal.withOpacity(0.2),
            side: const BorderSide(color: Colors.teal),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// COMPLETE SETTLEMENT DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildCompleteSettlementDisplay(
    CompleteSettlementResult result, ThemeData theme) {
  final typeLabel =
      result.settlementType == SettlementType.village ? 'Village' : 'City';
  final typeColor = result.settlementType == SettlementType.village
      ? const Color.fromARGB(255, 182, 142, 128)
      : const Color.fromARGB(255, 115, 156, 177);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: typeColor.withOpacity(0.5)),
            ),
            child: Text(
              typeLabel,
              style: TextStyle(
                color: typeColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              result.name.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Text(
        'Establishments (${result.establishments.countResult.count}):',
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 2),
      ...result.establishments.establishments.map((est) => Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              '• ${est.result}',
              style: theme.textTheme.bodySmall,
            ),
          )),
      const SizedBox(height: 4),
      Text(
        'News: ${result.news.result}',
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// FULL SETTLEMENT DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildFullSettlementDisplay(
    FullSettlementResult result, ThemeData theme) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        result.name.name,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        'Has: ${result.establishment.result}',
        style: theme.textTheme.bodySmall,
      ),
      Text(
        'News: ${result.news.result}',
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
      ),
    ],
  );
}
