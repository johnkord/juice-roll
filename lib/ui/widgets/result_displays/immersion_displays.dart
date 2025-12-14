/// Immersion Display Builders - Display widgets for sensory and emotional results.
///
/// This module handles display for:
/// - [SensoryDetailResult] - Sensory detail with sense, detail, and location
/// - [EmotionalAtmosphereResult] - Emotional atmosphere with polarity and cause
/// - [FullImmersionResult] - Combined sensory and emotional immersion
library;

import 'package:flutter/material.dart';

import '../../../presets/details.dart';
import '../../../presets/immersion.dart';
import '../../theme/juice_theme.dart';
import '../result_display_registry.dart';

/// Register all Immersion display builders with the registry.
void registerImmersionDisplays() {
  ResultDisplayRegistry.register<SensoryDetailResult>(_buildSensoryDetailDisplay);
  ResultDisplayRegistry.register<EmotionalAtmosphereResult>(_buildEmotionalAtmosphereDisplay);
  ResultDisplayRegistry.register<FullImmersionResult>(_buildFullImmersionDisplay);
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════

/// Get icon for sense type
IconData _getSenseIcon(String sense) {
  switch (sense.toLowerCase()) {
    case 'see': return Icons.visibility;
    case 'hear': return Icons.hearing;
    case 'smell': return Icons.air;
    case 'feel': return Icons.touch_app;
    default: return Icons.sensors;
  }
}

/// Get color for sense type
Color _getSenseColor(String sense) {
  switch (sense.toLowerCase()) {
    case 'see': return JuiceTheme.info;
    case 'hear': return JuiceTheme.mystic;
    case 'smell': return JuiceTheme.success;
    case 'feel': return JuiceTheme.gold;
    default: return JuiceTheme.rust;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SENSORY DETAIL DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildSensoryDetailDisplay(SensoryDetailResult result, ThemeData theme) {
  final senseColor = _getSenseColor(result.sense);
  final senseIcon = _getSenseIcon(result.sense);
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Dice indicators row
      Row(
        children: [
          // Sense die
          _buildSenseDiceBadge(senseIcon, result.senseRoll, senseColor, theme),
          const SizedBox(width: 4),
          // Detail die
          _buildDiceBadge('d10', result.detailRoll, JuiceTheme.rust, theme),
          const SizedBox(width: 4),
          // Where die
          _buildLocationDiceBadge(result.whereRoll, theme),
          // Skew indicator if present
          if (result.skew != SkewType.none) ...[
            const SizedBox(width: 6),
            _buildSkewIndicator(result.skew, isEmotional: false, theme: theme),
          ],
        ],
      ),
      const SizedBox(height: 8),
      // Sensory result card
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              senseColor.withOpacity(0.15),
              senseColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: senseColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(senseIcon, size: 16, color: senseColor),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: senseColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    result.sense.toUpperCase(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: senseColor,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: JuiceTheme.sepia,
                  height: 1.3,
                ),
                children: [
                  const TextSpan(text: 'You '),
                  TextSpan(
                    text: result.sense.toLowerCase(),
                    style: TextStyle(fontWeight: FontWeight.bold, color: senseColor),
                  ),
                  const TextSpan(text: ' something '),
                  TextSpan(
                    text: result.detail.toLowerCase(),
                    style: TextStyle(fontWeight: FontWeight.bold, color: JuiceTheme.rust),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: result.where.toLowerCase(),
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: JuiceTheme.info,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// EMOTIONAL ATMOSPHERE DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildEmotionalAtmosphereDisplay(EmotionalAtmosphereResult result, ThemeData theme) {
  final polarityColor = result.isPositive ? JuiceTheme.success : JuiceTheme.danger;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Dice indicators row
      Row(
        children: [
          // Emotion die
          _buildEmotionDiceBadge(result.emotionRoll, theme),
          const SizedBox(width: 4),
          // Cause die
          _buildDiceBadge('d10', result.causeRoll, JuiceTheme.rust, theme),
          const SizedBox(width: 4),
          // Fate die indicator
          _buildFateDiceBadge(result.isPositive, polarityColor, theme),
          // Skew indicator if present
          if (result.skew != SkewType.none) ...[
            const SizedBox(width: 6),
            _buildSkewIndicator(result.skew, isEmotional: true, theme: theme),
          ],
        ],
      ),
      const SizedBox(height: 8),
      // Emotion result card
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              polarityColor.withOpacity(0.15),
              polarityColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: polarityColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emotion polarity and name
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: polarityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    result.isPositive ? Icons.sentiment_satisfied : Icons.sentiment_dissatisfied,
                    size: 16,
                    color: polarityColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  result.selectedEmotion,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: polarityColor,
                  ),
                ),
                const Spacer(),
                // Show the pair
                Text(
                  result.isPositive
                      ? '(vs ${result.negativeEmotion})'
                      : '(vs ${result.positiveEmotion})',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: JuiceTheme.parchmentDark60,
                    fontStyle: FontStyle.italic,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Cause
            RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: JuiceTheme.sepia,
                ),
                children: [
                  const TextSpan(text: 'because '),
                  TextSpan(
                    text: result.cause,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: JuiceTheme.rust,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// FULL IMMERSION DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildFullImmersionDisplay(FullImmersionResult result, ThemeData theme) {
  final senseColor = _getSenseColor(result.sensory.sense);
  final senseIcon = _getSenseIcon(result.sensory.sense);
  final polarityColor = result.emotional.isPositive ? JuiceTheme.success : JuiceTheme.danger;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Compact dice summary
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Sensory dice group
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: senseColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(senseIcon, size: 11, color: senseColor),
                  const SizedBox(width: 3),
                  Text(
                    '${result.sensory.senseRoll}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      fontWeight: FontWeight.bold,
                      color: senseColor,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    ' · ${result.sensory.detailRoll} · ${result.sensory.whereRoll}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      color: JuiceTheme.parchmentDark,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            // Emotional dice group
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: JuiceTheme.mystic15,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mood, size: 11, color: JuiceTheme.mystic),
                  const SizedBox(width: 3),
                  Text(
                    '${result.emotional.emotionRoll} · ${result.emotional.causeRoll}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      color: JuiceTheme.parchmentDark,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            // Fate die
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: polarityColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: polarityColor.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '1dF',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      fontWeight: FontWeight.bold,
                      color: polarityColor,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    result.emotional.isPositive ? '+' : '−',
                    style: TextStyle(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      fontWeight: FontWeight.bold,
                      color: polarityColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      // Sensory result card
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              senseColor.withOpacity(0.15),
              senseColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: senseColor.withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: senseColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(senseIcon, size: 18, color: senseColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: JuiceTheme.sepia,
                    height: 1.3,
                  ),
                  children: [
                    const TextSpan(text: 'You '),
                    TextSpan(
                      text: result.sensory.sense.toLowerCase(),
                      style: TextStyle(fontWeight: FontWeight.bold, color: senseColor),
                    ),
                    const TextSpan(text: ' something '),
                    TextSpan(
                      text: result.sensory.detail.toLowerCase(),
                      style: TextStyle(fontWeight: FontWeight.bold, color: JuiceTheme.rust),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: result.sensory.where.toLowerCase(),
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: JuiceTheme.info,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 6),
      // Emotional result card
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              polarityColor.withOpacity(0.15),
              polarityColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: polarityColor.withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: polarityColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                result.emotional.isPositive
                    ? Icons.sentiment_satisfied
                    : Icons.sentiment_dissatisfied,
                size: 18,
                color: polarityColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: JuiceTheme.sepia,
                      ),
                      children: [
                        const TextSpan(text: 'It causes '),
                        TextSpan(
                          text: result.emotional.selectedEmotion.toLowerCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: polarityColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: JuiceTheme.parchmentDark80,
                      ),
                      children: [
                        const TextSpan(text: 'because '),
                        TextSpan(
                          text: result.emotional.cause,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: JuiceTheme.rust,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED DICE BADGE HELPERS
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildSenseDiceBadge(IconData icon, int roll, Color color, ThemeData theme) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.2),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            '$roll',
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
  );
}

Widget _buildDiceBadge(String label, int roll, Color color, ThemeData theme) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.2),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: JuiceTheme.fontFamilyMono,
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 10,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            '$roll',
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
  );
}

Widget _buildLocationDiceBadge(int roll, ThemeData theme) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: JuiceTheme.info20,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.place, size: 12, color: JuiceTheme.info),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: JuiceTheme.info30,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            '$roll',
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
  );
}

Widget _buildEmotionDiceBadge(int roll, ThemeData theme) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: JuiceTheme.mystic20,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.mood, size: 12, color: JuiceTheme.mystic),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: JuiceTheme.mystic30,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            '$roll',
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
  );
}

Widget _buildFateDiceBadge(bool isPositive, Color polarityColor, ThemeData theme) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: polarityColor.withOpacity(0.2),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: polarityColor.withOpacity(0.5)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '1dF',
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: JuiceTheme.fontFamilyMono,
            fontWeight: FontWeight.bold,
            color: polarityColor,
            fontSize: 10,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: polarityColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Center(
            child: Text(
              isPositive ? '+' : '−',
              style: TextStyle(
                fontFamily: JuiceTheme.fontFamilyMono,
                fontWeight: FontWeight.bold,
                color: JuiceTheme.parchment,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildSkewIndicator(SkewType skew, {required bool isEmotional, required ThemeData theme}) {
  final isAdvantage = skew == SkewType.advantage;
  final color = isAdvantage ? JuiceTheme.success : JuiceTheme.danger;
  final icon = isEmotional
      ? (isAdvantage ? Icons.sentiment_very_satisfied : Icons.sentiment_very_dissatisfied)
      : (isAdvantage ? Icons.arrow_upward : Icons.arrow_downward);
  final label = isEmotional
      ? (isAdvantage ? 'Positive' : 'Negative')
      : (isAdvantage ? 'Closer' : 'Further');

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.2),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withOpacity(0.5)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    ),
  );
}
