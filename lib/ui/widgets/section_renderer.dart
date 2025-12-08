import 'package:flutter/material.dart';
import '../../models/roll_result.dart';
import '../../models/results/result_types.dart';
import '../../core/fate_dice_formatter.dart';
import '../theme/juice_theme.dart';

/// A generic renderer that displays RollResult using its sections.
/// 
/// This widget replaces type-specific display logic with a data-driven
/// approach where each RollResult provides its own display sections.
/// 
/// Uses JuiceTheme colors to match the parchment & ink aesthetic of the app.
class SectionRenderer extends StatelessWidget {
  final RollResult result;
  final ThemeData theme;
  final bool compact;

  const SectionRenderer({
    super.key,
    required this.result,
    required this.theme,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final sections = result.sections;
    
    if (sections.isEmpty) {
      // Fallback for results without sections
      return _buildFallbackDisplay();
    }

    // Dispatch by display type for layout strategy
    switch (result.displayType) {
      case ResultDisplayType.fateCheck:
        return _buildFateCheckLayout(sections);
      case ResultDisplayType.twoColumn:
        return _buildTwoColumnLayout(sections);
      case ResultDisplayType.hierarchical:
        return _buildHierarchicalLayout(sections);
      case ResultDisplayType.generated:
        return _buildGeneratedLayout(sections);
      case ResultDisplayType.stateful:
        return _buildStatefulLayout(sections);
      case ResultDisplayType.visual:
        return _buildVisualLayout(sections);
      case ResultDisplayType.standard:
        return _buildStandardLayout(sections);
      case ResultDisplayType.ironsworn:
        return _buildIronswornLayout(sections);
    }
  }

  /// Standard vertical layout of sections
  Widget _buildStandardLayout(List<ResultSection> sections) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((s) => _buildSection(s)).toList(),
    );
  }

  /// Fate check layout with dice symbols and outcome chip
  Widget _buildFateCheckLayout(List<ResultSection> sections) {
    // Find fate dice section
    final fateDiceSection = sections.firstWhere(
      (s) => s.label?.contains('dF') ?? false,
      orElse: () => sections.first,
    );
    
    // Find outcome section
    final outcomeSection = sections.firstWhere(
      (s) => s.label == 'Outcome' || (s.isEmphasized && !s.label!.contains('Trigger')),
      orElse: () => sections.last,
    );
    
    // Find trigger section (Random Event, Invalid Assumption)
    final triggerSection = sections.where(
      (s) => s.label?.contains('Trigger') ?? false
    ).firstOrNull;
    
    // Find meaning sections (for auto-rolled Random Event)
    final meaningSections = sections.where(
      (s) => s.label?.contains('Focus') ?? s.label?.contains('Meaning') ?? false
    ).toList();
    
    // Other sections (intensity, etc.)
    final otherSections = sections
        .where((s) => s != fateDiceSection && 
                      s != outcomeSection && 
                      s != triggerSection &&
                      !meaningSections.contains(s))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Fate dice display
            if (fateDiceSection.relatedDice != null)
              _buildFateDiceDisplay(fateDiceSection),
            const SizedBox(width: 12),
            // Intensity die and other inline values
            ...otherSections.where((s) => s.relatedDice != null || s.label == '1d6').take(1).map((s) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildCompactSection(s),
            )),
            const Spacer(),
            // Outcome chip
            _buildOutcomeChip(outcomeSection),
          ],
        ),
        // Special trigger (Random Event / Invalid Assumption)
        if (triggerSection != null) ...[
          const SizedBox(height: 8),
          _buildTriggerChip(triggerSection),
        ],
        // Auto-rolled Random Event details
        if (meaningSections.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildRandomEventDetails(meaningSections),
        ],
        // Intensity description
        ...otherSections.where((s) => s.sublabel != null && s.relatedDice == null).map((s) => Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            s.sublabel ?? s.value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: JuiceTheme.parchmentDark,
              fontStyle: FontStyle.italic,
            ),
          ),
        )),
      ],
    );
  }

  /// Build a trigger chip (Random Event, Invalid Assumption)
  Widget _buildTriggerChip(ResultSection section) {
    final color = section.colorValue != null 
        ? Color(section.colorValue!) 
        : JuiceTheme.gold;
    final isRandomEvent = section.value.contains('Random');
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isRandomEvent ? Icons.flash_on : Icons.warning_amber,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            section.value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Random Event details (Focus + Meaning)
  Widget _buildRandomEventDetails(List<ResultSection> sections) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: JuiceTheme.gold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: JuiceTheme.gold.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sections.map((s) {
          final isTitle = s.label?.contains('Focus') ?? false;
          return Text(
            isTitle ? '${s.label}: ${s.value}' : s.value,
            style: TextStyle(
              color: isTitle ? JuiceTheme.gold : JuiceTheme.parchment,
              fontWeight: isTitle ? FontWeight.bold : FontWeight.w500,
              fontSize: isTitle ? 12 : 13,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Two-column layout for side-by-side comparisons
  Widget _buildTwoColumnLayout(List<ResultSection> sections) {
    // Split sections into pairs
    final leftSections = <ResultSection>[];
    final rightSections = <ResultSection>[];
    
    for (var i = 0; i < sections.length; i++) {
      if (i % 2 == 0) {
        leftSections.add(sections[i]);
      } else {
        rightSections.add(sections[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: leftSections.map((s) => _buildSection(s)).toList(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rightSections.map((s) => _buildSection(s)).toList(),
          ),
        ),
      ],
    );
  }

  /// Hierarchical layout for nested/grouped results
  Widget _buildHierarchicalLayout(List<ResultSection> sections) {
    final groupedSections = <String, List<ResultSection>>{};
    final ungrouped = <ResultSection>[];
    
    for (final section in sections) {
      if (section.label != null && section.label!.contains(':')) {
        final parts = section.label!.split(':');
        final group = parts[0].trim();
        groupedSections.putIfAbsent(group, () => []).add(section);
      } else {
        ungrouped.add(section);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ungrouped sections first
        ...ungrouped.map((s) => _buildSection(s)),
        // Grouped sections
        ...groupedSections.entries.map((entry) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: JuiceTheme.sepia.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  entry.key,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: JuiceTheme.sepia,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: entry.value.map((s) => _buildSection(s)).toList(),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  /// Generated content layout (multi-part results like settlements, NPCs)
  Widget _buildGeneratedLayout(List<ResultSection> sections) {
    if (sections.isEmpty) return const SizedBox.shrink();
    
    // First section is typically the main result (name, title, etc.)
    final mainSection = sections.first;
    final detailSections = sections.skip(1).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header/main section with emphasis
        _buildEmphasizedSection(mainSection),
        if (detailSections.isNotEmpty) ...[
          const SizedBox(height: 8),
          // Detail sections with consistent styling
          ...detailSections.map((s) => _buildLabeledDetailRow(s)),
        ],
      ],
    );
  }

  /// Build a labeled detail row (used in generated layouts)
  Widget _buildLabeledDetailRow(ResultSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.label != null && section.label!.isNotEmpty)
            SizedBox(
              width: 70,
              child: Row(
                children: [
                  if (section.iconName != null) ...[
                    Icon(
                      _getIconFromName(section.iconName!),
                      size: 12,
                      color: section.colorValue != null 
                          ? Color(section.colorValue!) 
                          : JuiceTheme.parchmentDark,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Text(
                      '${section.label}:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: JuiceTheme.parchmentDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Text(
              section.value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: section.colorValue != null 
                    ? Color(section.colorValue!) 
                    : JuiceTheme.parchment,
                fontWeight: section.isEmphasized ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (section.sublabel != null)
            Text(
              section.sublabel!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: JuiceTheme.parchmentDark,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  /// Stateful layout (includes state change indicators)
  Widget _buildStatefulLayout(List<ResultSection> sections) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...sections.map((s) => _buildSection(s)),
        // State indicator
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: JuiceTheme.info.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: JuiceTheme.info.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.update,
                  size: 12,
                  color: JuiceTheme.info,
                ),
                const SizedBox(width: 4),
                Text(
                  'State Updated',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: JuiceTheme.info,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Visual layout (for image-based results like Abstract Icons)
  Widget _buildVisualLayout(List<ResultSection> sections) {
    // Check if result has an image
    if (result.imagePath != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dice/roll info first with styled badges
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: sections
                .where((s) => s.relatedDice != null)
                .map((s) => _buildDiceBadge(s))
                .toList(),
          ),
          const SizedBox(height: 12),
          // Image with styled container
          Center(
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: JuiceTheme.success.withOpacity(0.6),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: JuiceTheme.success.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    result.imagePath!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: JuiceTheme.parchment,
                        child: Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 40,
                            color: JuiceTheme.inkDark.withOpacity(0.3),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Other sections
          ...sections.where((s) => s.relatedDice == null).map((s) => _buildSection(s)),
        ],
      );
    }
    
    // Fallback if no image
    return _buildStandardLayout(sections);
  }

  /// Ironsworn layout for action/progress/oracle results
  Widget _buildIronswornLayout(List<ResultSection> sections) {
    // Ironsworn results have action dice vs challenge dice, or oracle rolls
    // For now, use standard layout which works well for Ironsworn
    // The specialized displays are in ResultDisplayBuilder
    return _buildStandardLayout(sections);
  }

  /// Build a styled dice badge for visual layouts
  Widget _buildDiceBadge(ResultSection section) {
    // Determine color based on label
    Color color;
    IconData icon;
    
    if (section.label?.contains('Row') ?? false) {
      color = JuiceTheme.rust;
      icon = Icons.arrow_downward;
    } else if (section.label?.contains('Col') ?? false) {
      color = JuiceTheme.info;
      icon = Icons.arrow_forward;
    } else {
      color = JuiceTheme.mystic;
      icon = Icons.grid_on;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color.withOpacity(0.8),
          ),
          const SizedBox(width: 4),
          if (section.label != null)
            Text(
              '${section.label} ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: color.withOpacity(0.8),
                fontSize: 11,
              ),
            ),
          Text(
            section.value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: JuiceTheme.fontFamilyMono,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Build a single section widget
  Widget _buildSection(ResultSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.iconName != null) ...[
            Icon(
              _getIconFromName(section.iconName!),
              size: 14,
              color: section.colorValue != null 
                  ? Color(section.colorValue!) 
                  : JuiceTheme.parchmentDark,
            ),
            const SizedBox(width: 4),
          ],
          if (section.label != null && section.label!.isNotEmpty)
            Text(
              '${section.label}: ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: JuiceTheme.parchmentDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          Expanded(
            child: Text(
              section.value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: section.isEmphasized ? FontWeight.bold : FontWeight.normal,
                color: section.colorValue != null 
                    ? Color(section.colorValue!) 
                    : JuiceTheme.parchment,
              ),
            ),
          ),
          if (section.sublabel != null)
            Text(
              section.sublabel!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: JuiceTheme.parchmentDark,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  /// Build a compact inline section
  Widget _buildCompactSection(ResultSection section) {
    final color = section.colorValue != null 
        ? Color(section.colorValue!) 
        : JuiceTheme.mystic;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (section.label != null)
            Text(
              '${section.label}: ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: color.withOpacity(0.8),
              ),
            ),
          Text(
            section.value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: JuiceTheme.fontFamilyMono,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Build an emphasized section (larger, colored)
  Widget _buildEmphasizedSection(ResultSection section) {
    final color = section.colorValue != null 
        ? Color(section.colorValue!) 
        : JuiceTheme.gold;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (section.iconName != null) ...[
            Icon(
              _getIconFromName(section.iconName!),
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            section.value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Build fate dice display with symbols
  Widget _buildFateDiceDisplay(ResultSection section) {
    final dice = section.relatedDice ?? [];
    return FateDiceFormatter.buildLabeledFateDiceDisplay(
      label: section.label ?? '2dF',
      dice: dice,
      theme: theme,
    );
  }

  /// Build outcome chip
  Widget _buildOutcomeChip(ResultSection section) {
    final color = section.colorValue != null 
        ? Color(section.colorValue!) 
        : JuiceTheme.parchment;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (section.iconName != null) ...[
            Icon(
              _getIconFromName(section.iconName!),
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            section.value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Fallback display when no sections
  Widget _buildFallbackDisplay() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: JuiceTheme.ink.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '[${result.diceResults.join(', ')}]',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: JuiceTheme.fontFamilyMono,
              color: JuiceTheme.parchment,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '= ${result.total}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: JuiceTheme.gold,
          ),
        ),
        if (result.interpretation != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              result.interpretation!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: JuiceTheme.parchment,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Convert icon name to IconData
  IconData _getIconFromName(String name) {
    switch (name) {
      // Status icons
      case 'check_circle':
        return Icons.check_circle;
      case 'cancel':
        return Icons.cancel;
      case 'warning':
        return Icons.warning;
      case 'warning_amber':
        return Icons.warning_amber;
      case 'info':
        return Icons.info;
      case 'error':
        return Icons.error;
      
      // Action icons
      case 'flash_on':
        return Icons.flash_on;
      case 'bolt':
        return Icons.bolt;
      case 'casino':
        return Icons.casino;
      case 'update':
        return Icons.update;
      case 'arrow_forward':
        return Icons.arrow_forward;
      case 'arrow_downward':
        return Icons.arrow_downward;
      
      // Location icons
      case 'place':
        return Icons.place;
      case 'location_on':
        return Icons.location_on;
      case 'location_city':
        return Icons.location_city;
      case 'explore':
        return Icons.explore;
      case 'terrain':
        return Icons.terrain;
      case 'business':
        return Icons.business;
      case 'home':
        return Icons.home;
      case 'grid_on':
        return Icons.grid_on;
      case 'map':
        return Icons.map;
      
      // Character icons
      case 'person':
        return Icons.person;
      case 'psychology':
        return Icons.psychology;
      case 'pets':
        return Icons.pets;
      case 'face':
        return Icons.face;
      case 'groups':
        return Icons.groups;
      
      // Object icons
      case 'image':
        return Icons.image;
      case 'diamond':
        return Icons.diamond;
      case 'star':
        return Icons.star;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'palette':
        return Icons.palette;
      
      // Combat/challenge icons
      case 'fitness_center':
        return Icons.fitness_center;
      case 'shield':
        return Icons.shield;
      case 'sports_martial_arts':
        return Icons.sports_martial_arts;
      
      // Weather icons
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'cloud':
        return Icons.cloud;
      case 'thunderstorm':
        return Icons.thunderstorm;
      
      // Dialog icons
      case 'chat':
        return Icons.chat;
      case 'chat_bubble':
        return Icons.chat_bubble;
      case 'campaign':
        return Icons.campaign;
      case 'record_voice_over':
        return Icons.record_voice_over;
      
      // Misc icons
      case 'theaters':
        return Icons.theaters;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'lightbulb_outline':
        return Icons.lightbulb_outline;
      case 'help_outline':
        return Icons.help_outline;
      case 'visibility':
        return Icons.visibility;
      case 'north':
        return Icons.north;
      case 'south':
        return Icons.south;
      case 'east':
        return Icons.east;
      case 'west':
        return Icons.west;
      
      default:
        return Icons.circle;
    }
  }
}

/// Extension to add section-based rendering capability to existing widgets
extension SectionRendererExtension on RollResult {
  /// Check if this result supports section-based rendering
  bool get hasSections => sections.isNotEmpty;
  
  /// Build a section-based display widget
  Widget buildSectionDisplay(ThemeData theme, {bool compact = false}) {
    return SectionRenderer(
      result: this,
      theme: theme,
      compact: compact,
    );
  }
}
