/// Details Display Builders - Display widgets for property and detail results.
///
/// This module handles display for:
/// - [PropertyResult] - Single property with intensity
/// - [DualPropertyResult] - Two properties combined
/// - [DetailResult] - Detail lookup (color, history, focus)
/// - [DetailWithFollowUpResult] - Detail with optional follow-up
library;

import 'package:flutter/material.dart';

import '../../../data/detail_guidance_data.dart';
import '../../../presets/details.dart';
import '../../theme/juice_theme.dart';
import '../result_display_registry.dart';

/// Register all Details display builders with the registry.
void registerDetailsDisplays() {
  ResultDisplayRegistry.register<PropertyResult>(_buildPropertyResultDisplay);
  ResultDisplayRegistry.register<DualPropertyResult>(_buildDualPropertyResultDisplay);
  ResultDisplayRegistry.register<DetailResult>(_buildDetailResultDisplay);
  ResultDisplayRegistry.register<DetailWithFollowUpResult>(_buildDetailWithFollowUpDisplay);
}

// ═══════════════════════════════════════════════════════════════════════════
// DUAL PROPERTY DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildDualPropertyResultDisplay(DualPropertyResult result, ThemeData theme) {
  const propertyColor = JuiceTheme.gold;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Dice display row - both properties' dice
      Row(
        children: [
          // First property dice
          _buildPropertyDicePair(result.property1.propertyRoll, result.property1.intensityRoll),
          const SizedBox(width: 8),
          Text('+', style: TextStyle(color: JuiceTheme.parchmentDark, fontSize: 12)),
          const SizedBox(width: 8),
          // Second property dice
          _buildPropertyDicePair(result.property2.propertyRoll, result.property2.intensityRoll),
        ],
      ),
      const SizedBox(height: 10),
      // Property results
      Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          _buildPropertyChip(result.property1, propertyColor),
          Icon(Icons.add, size: 14, color: JuiceTheme.parchmentDark),
          _buildPropertyChip(result.property2, propertyColor),
        ],
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// PROPERTY DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildPropertyResultDisplay(PropertyResult result, ThemeData theme) {
  const propertyColor = JuiceTheme.gold;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Dice display with property and intensity dice
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: JuiceTheme.rust20,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'd10',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: JuiceTheme.fontFamilyMono,
                    fontWeight: FontWeight.bold,
                    color: JuiceTheme.rust,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: JuiceTheme.rust30,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '${result.propertyRoll}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      fontWeight: FontWeight.bold,
                      color: JuiceTheme.parchment,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: JuiceTheme.info20,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'd6',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: JuiceTheme.fontFamilyMono,
                    fontWeight: FontWeight.bold,
                    color: JuiceTheme.info,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: JuiceTheme.info30,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '${result.intensityRoll}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      fontWeight: FontWeight.bold,
                      color: JuiceTheme.parchment,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      // Property result display
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              propertyColor.withOpacity(0.15),
              propertyColor.withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: propertyColor.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune, size: 16, color: propertyColor),
            const SizedBox(width: 8),
            Text(
              result.property,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: JuiceTheme.fontFamilySerif,
                color: propertyColor,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: propertyColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                result.intensityDescription,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: propertyColor,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// DETAIL WITH FOLLOW-UP DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildDetailWithFollowUpDisplay(DetailWithFollowUpResult result, ThemeData theme) {
  // Get guidance for the detail modifier result
  final guidance = result.detailResult.guidance;
  
  // Determine accent color based on guidance
  final Color accentColor;
  final IconData icon;
  if (guidance != null) {
    accentColor = _getDetailModifierColor(guidance);
    icon = _getDetailModifierIcon(guidance);
  } else {
    accentColor = Colors.teal;
    icon = Icons.help_outline;
  }
  
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    // Dice roll display
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            result.detailResult.secondRoll != null ? 'd10 @' : 'd10',
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: JuiceTheme.fontFamilyMono,
              fontWeight: FontWeight.bold,
              color: accentColor,
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.25),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              result.detailResult.secondRoll != null 
                  ? '${result.detailResult.roll}, ${result.detailResult.secondRoll}'
                  : '${result.detailResult.roll}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: JuiceTheme.fontFamilyMono,
                fontWeight: FontWeight.bold,
                color: JuiceTheme.parchment,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 8),
    // Result display with icon
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withOpacity(0.12),
            accentColor.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accentColor),
          const SizedBox(width: 8),
          Text(
            result.detailResult.result,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: JuiceTheme.fontFamilySerif,
              color: accentColor,
            ),
          ),
        ],
      ),
    ),
    // Show follow-up result (History or Property sub-roll)
    if (result.hasFollowUp && result.followUpText != null) ...[
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: JuiceTheme.gold10,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: JuiceTheme.gold30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.subdirectory_arrow_right, size: 14, color: JuiceTheme.gold),
            const SizedBox(width: 4),
            Text(
              result.followUpText!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: JuiceTheme.gold,
              ),
            ),
          ],
        ),
      ),
    ],
    // Show guidance for Detail Modifier results (Favors/Disfavors, Emotions, etc.)
    if (guidance != null) ...[
      const SizedBox(height: 10),
      _buildDetailModifierGuidance(guidance, accentColor, theme),
    ],
  ]);
}

// ═══════════════════════════════════════════════════════════════════════════
// DETAIL RESULT DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildDetailResultDisplay(DetailResult result, ThemeData theme) {
  // Different styling based on detail type
  final isColor = result.detailType == DetailType.color;
  final isHistory = result.detailType == DetailType.history;
  final isDetailModifier = result.detailType == DetailType.detail;
  final guidance = result.guidance;
  
  // Theme colors based on type and guidance
  final Color accentColor;
  final IconData icon;
  if (isColor) {
    accentColor = const Color(0xFF6B8EAE); // Blue-ish for color
    icon = Icons.palette;
  } else if (isHistory) {
    accentColor = JuiceTheme.rust;
    icon = Icons.history;
  } else if (isDetailModifier && guidance != null) {
    // Use guidance-based colors for detail modifier results
    accentColor = _getDetailModifierColor(guidance);
    icon = _getDetailModifierIcon(guidance);
  } else {
    accentColor = JuiceTheme.mystic;
    icon = Icons.help_outline;
  }
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Dice roll display
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              result.secondRoll != null ? 'd10 @' : 'd10',
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: JuiceTheme.fontFamilyMono,
                fontWeight: FontWeight.bold,
                color: accentColor,
                fontSize: 10,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.25),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                result.secondRoll != null 
                    ? '${result.roll}, ${result.secondRoll}'
                    : '${result.roll}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: JuiceTheme.fontFamilyMono,
                  fontWeight: FontWeight.bold,
                  color: JuiceTheme.parchment,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      // Result display - special treatment for Color
      if (isColor) ...[
        _buildColorResultDisplay(result, theme),
      ] else ...[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accentColor.withOpacity(0.12),
                accentColor.withOpacity(0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accentColor.withOpacity(0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: accentColor),
              const SizedBox(width: 8),
              Text(
                result.result,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: JuiceTheme.fontFamilySerif,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ),
      ],
      // Show guidance for Detail Modifier results (Favors/Disfavors, Emotions, etc.)
      if (isDetailModifier && guidance != null) ...[
        const SizedBox(height: 10),
        _buildDetailModifierGuidance(guidance, accentColor, theme),
      ],
    ],
  );
}

/// Get the accent color for a detail modifier based on its guidance.
Color _getDetailModifierColor(DetailModifierGuidance guidance) {
  switch (guidance.category) {
    case DetailModifierCategory.emotion:
      return guidance.isPositive ? JuiceTheme.success : JuiceTheme.danger;
    case DetailModifierCategory.pc:
      return guidance.isPositive ? JuiceTheme.success : JuiceTheme.danger;
    case DetailModifierCategory.thread:
      return guidance.isPositive ? JuiceTheme.info : JuiceTheme.juiceOrange;
    case DetailModifierCategory.npc:
      return guidance.isPositive ? JuiceTheme.mystic : JuiceTheme.rust;
    case DetailModifierCategory.followUp:
      return JuiceTheme.gold;
  }
}

/// Get the icon for a detail modifier based on its guidance.
IconData _getDetailModifierIcon(DetailModifierGuidance guidance) {
  switch (guidance.category) {
    case DetailModifierCategory.emotion:
      return guidance.isPositive ? Icons.sentiment_satisfied_alt : Icons.sentiment_dissatisfied;
    case DetailModifierCategory.pc:
      return guidance.isPositive ? Icons.thumb_up : Icons.thumb_down;
    case DetailModifierCategory.thread:
      return guidance.isPositive ? Icons.trending_up : Icons.trending_down;
    case DetailModifierCategory.npc:
      return guidance.isPositive ? Icons.person_add : Icons.person_remove;
    case DetailModifierCategory.followUp:
      return Icons.arrow_forward;
  }
}

/// Build the guidance widget for detail modifier results.
/// Based on Juice Oracle instructions pages 29-31.
/// Compact version - shows key prompt and follow-up roll only.
Widget _buildDetailModifierGuidance(
  DetailModifierGuidance guidance,
  Color accentColor,
  ThemeData theme,
) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: accentColor.withOpacity(0.08),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: accentColor.withOpacity(0.25)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main prompt - the key question to answer
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.help_outline,
              size: 14,
              color: accentColor,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                guidance.prompt,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        // Follow-up roll requirement (for Thread/NPC)
        if (guidance.followUpRoll != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.casino,
                size: 12,
                color: JuiceTheme.gold,
              ),
              const SizedBox(width: 4),
              Text(
                guidance.followUpRoll!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: JuiceTheme.gold,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

Widget _buildColorResultDisplay(DetailResult result, ThemeData theme) {
  // Map color names to actual colors for display
  final colorMap = {
    'Shade Black': Colors.black87,
    'Leather Brown': const Color(0xFF8B4513),
    'Highlight Yellow': Colors.yellow.shade600,
    'Forest Green': const Color(0xFF228B22),
    'Cobalt Blue': const Color(0xFF0047AB),
    'Crimson Red': const Color(0xFFDC143C),
    'Royal Violet': const Color(0xFF7851A9),
    'Metallic Silver': Colors.grey.shade400,
    'Midas Gold': const Color(0xFFFFD700),
    'Holy White': Colors.white70,
  };
  
  final displayColor = colorMap[result.result] ?? JuiceTheme.parchment;
  final isDark = displayColor.computeLuminance() < 0.5;
  
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: JuiceTheme.inkDark40,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: displayColor.withOpacity(0.6)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Color swatch
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: displayColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDark ? Colors.white24 : Colors.black26,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: displayColor.withOpacity(0.4),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Color name
        Text(
          result.result,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: JuiceTheme.fontFamilySerif,
            color: JuiceTheme.parchment,
          ),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildPropertyDicePair(int d10Value, int d6Value) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: JuiceTheme.rust15,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'd10',
              style: TextStyle(
                fontFamily: JuiceTheme.fontFamilyMono,
                fontSize: 9,
                color: JuiceTheme.rust,
              ),
            ),
            const SizedBox(width: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              decoration: BoxDecoration(
                color: JuiceTheme.rust25,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                '$d10Value',
                style: TextStyle(
                  fontFamily: JuiceTheme.fontFamilyMono,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: JuiceTheme.parchment,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 3),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: JuiceTheme.info15,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'd6',
              style: TextStyle(
                fontFamily: JuiceTheme.fontFamilyMono,
                fontSize: 9,
                color: JuiceTheme.info,
              ),
            ),
            const SizedBox(width: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              decoration: BoxDecoration(
                color: JuiceTheme.info25,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                '$d6Value',
                style: TextStyle(
                  fontFamily: JuiceTheme.fontFamilyMono,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: JuiceTheme.parchment,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildPropertyChip(PropertyResult property, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          color.withOpacity(0.15),
          color.withOpacity(0.08),
        ],
      ),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.tune, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          property.property,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: JuiceTheme.fontFamilySerif,
            color: color,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            property.intensityDescription,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 10,
            ),
          ),
        ),
      ],
    ),
  );
}
