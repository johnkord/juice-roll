import 'package:flutter/material.dart';
import '../../models/roll_result.dart';
import '../../presets/details.dart';
import '../theme/juice_theme.dart';

/// Dialog for Details options.
class DetailsDialog extends StatelessWidget {
  final Details details;
  final void Function(RollResult) onRoll;

  const DetailsDialog({
    super.key,
    required this.details,
    required this.onRoll,
  });

  // Section theme colors
  static const Color _colorSectionColor = Color(0xFF6B8EAE); // Blue-ish
  static const Color _propertySectionColor = JuiceTheme.gold;
  static const Color _detailSectionColor = JuiceTheme.mystic;
  static const Color _historySectionColor = JuiceTheme.rust;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  JuiceTheme.gold.withValues(alpha: 0.3),
                  JuiceTheme.juiceOrange.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_fix_high, color: JuiceTheme.gold, size: 20),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Details',
                style: TextStyle(
                  fontFamily: JuiceTheme.fontFamilySerif,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Front Page',
                style: TextStyle(
                  fontSize: 11,
                  color: JuiceTheme.parchmentDark,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Introduction
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      JuiceTheme.parchmentDark.withValues(alpha: 0.12),
                      JuiceTheme.gold.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: JuiceTheme.parchmentDark.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, 
                      color: JuiceTheme.gold.withValues(alpha: 0.7), 
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Add flavor to NPCs, items, settlements, or interpret oracle results.',
                        style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              
              // ═══════════════════════════════════════════════════════════════
              // COLOR SECTION
              // ═══════════════════════════════════════════════════════════════
              _DetailsSectionCard(
                icon: Icons.palette,
                title: 'Color',
                color: _colorSectionColor,
                description: 'Eye/hair color, armor accents, banners, dragon species...',
                child: Column(
                  children: [
                    // Color swatches preview
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: JuiceTheme.inkDark.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _colorSwatch(Colors.black87),
                          _colorSwatch(Colors.brown),
                          _colorSwatch(Colors.yellow.shade700),
                          _colorSwatch(Colors.green.shade700),
                          _colorSwatch(Colors.blue.shade700),
                          _colorSwatch(Colors.red.shade700),
                          _colorSwatch(Colors.purple.shade400),
                          _colorSwatch(Colors.grey.shade400),
                          _colorSwatch(Colors.amber),
                          _colorSwatch(Colors.white70),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _DetailsRollButton(
                      label: 'Roll Color',
                      subtitle: 'd10',
                      icon: Icons.colorize,
                      color: _colorSectionColor,
                      onTap: () {
                        onRoll(details.rollColor());
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // ═══════════════════════════════════════════════════════════════
              // PROPERTY SECTION - ESSENTIAL
              // ═══════════════════════════════════════════════════════════════
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _propertySectionColor.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _propertySectionColor.withValues(alpha: 0.12),
                      _propertySectionColor.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Essential badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: _propertySectionColor.withValues(alpha: 0.15),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.tune, size: 16, color: _propertySectionColor),
                          const SizedBox(width: 6),
                          Text(
                            'Property',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _propertySectionColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _propertySectionColor.withValues(alpha: 0.4),
                                  _propertySectionColor.withValues(alpha: 0.25),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: 10, color: _propertySectionColor),
                                const SizedBox(width: 3),
                                Text(
                                  'ESSENTIAL',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: _propertySectionColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quote
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: JuiceTheme.inkDark.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(6),
                              border: const Border(
                                left: BorderSide(
                                  color: JuiceTheme.gold,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: const Text(
                              '"If you only take one table from this whole thing, take this one."',
                              style: TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: JuiceTheme.parchment,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Property & Intensity reference
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: JuiceTheme.inkDark.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: JuiceTheme.rust.withValues(alpha: 0.3),
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                            child: const Text('d10', 
                                              style: TextStyle(
                                                fontSize: 9, 
                                                fontFamily: JuiceTheme.fontFamilyMono,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text('Property', 
                                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      const Text(
                                        'Age • Size • Value • Style • Power • Quality...',
                                        style: TextStyle(fontSize: 9, color: JuiceTheme.parchmentDark),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: JuiceTheme.inkDark.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: JuiceTheme.info.withValues(alpha: 0.3),
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                            child: const Text('d6', 
                                              style: TextStyle(
                                                fontSize: 9, 
                                                fontFamily: JuiceTheme.fontFamilyMono,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text('Intensity', 
                                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      const Text(
                                        'Minimal → Minor → Mundane → Major → Max',
                                        style: TextStyle(fontSize: 9, color: JuiceTheme.parchmentDark),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Roll buttons
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _DetailsRollButton(
                                  label: 'Property ×2',
                                  subtitle: 'Recommended',
                                  icon: Icons.content_copy,
                                  color: _propertySectionColor,
                                  isPrimary: true,
                                  onTap: () {
                                    onRoll(details.rollTwoProperties());
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: _DetailsRollButton(
                                  label: '×1',
                                  subtitle: 'Single',
                                  icon: Icons.looks_one,
                                  color: _propertySectionColor,
                                  onTap: () {
                                    onRoll(details.rollProperty());
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // ═══════════════════════════════════════════════════════════════
              // DETAIL SECTION
              // ═══════════════════════════════════════════════════════════════
              _DetailsSectionCard(
                icon: Icons.help_outline,
                title: 'Detail',
                color: _detailSectionColor,
                description: 'Oracle threw a curveball? Ground meaning to a thread, character, or emotion.',
                child: Column(
                  children: [
                    _DetailsRollButton(
                      label: 'Roll Detail',
                      subtitle: 'Emotion / Favors / Disfavors (PC, Thread, NPC)',
                      icon: Icons.casino,
                      color: _detailSectionColor,
                      onTap: () {
                        onRoll(details.rollDetailWithFollowUp());
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _DetailsSkewButton(
                            label: 'Positive',
                            subtitle: 'Favorable',
                            icon: Icons.thumb_up_outlined,
                            color: JuiceTheme.success,
                            onTap: () {
                              onRoll(details.rollDetailWithFollowUp(skew: SkewType.advantage));
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _DetailsSkewButton(
                            label: 'Negative',
                            subtitle: 'Unfavorable',
                            icon: Icons.thumb_down_outlined,
                            color: JuiceTheme.danger,
                            onTap: () {
                              onRoll(details.rollDetailWithFollowUp(skew: SkewType.disadvantage));
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // ═══════════════════════════════════════════════════════════════
              // HISTORY SECTION
              // ═══════════════════════════════════════════════════════════════
              _DetailsSectionCard(
                icon: Icons.history,
                title: 'History',
                color: _historySectionColor,
                description: 'Tie elements to the past: backstory, past scenes, previous actions, or threads.',
                child: Column(
                  children: [
                    _DetailsRollButton(
                      label: 'Roll History',
                      subtitle: 'Backstory → Past Thread → Current Action...',
                      icon: Icons.auto_stories,
                      color: _historySectionColor,
                      onTap: () {
                        onRoll(details.rollHistory());
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _DetailsSkewButton(
                            label: 'Recent',
                            subtitle: 'Present',
                            icon: Icons.update,
                            color: JuiceTheme.info,
                            onTap: () {
                              onRoll(details.rollHistory(skew: SkewType.advantage));
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _DetailsSkewButton(
                            label: 'Distant',
                            subtitle: 'Past',
                            icon: Icons.hourglass_empty,
                            color: JuiceTheme.sepia,
                            onTap: () {
                              onRoll(details.rollHistory(skew: SkewType.disadvantage));
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _colorSwatch(Color color) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: JuiceTheme.parchmentDark.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
    );
  }
}

// =============================================================================
// HELPER WIDGETS (Private to this file)
// =============================================================================

/// Section card for Details dialog
class _DetailsSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final String description;
  final Widget child;

  const _DetailsSectionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withValues(alpha: 0.06),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Row(
              children: [
                Icon(icon, size: 15, color: color),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: JuiceTheme.parchmentDark.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Roll button for Details dialog
class _DetailsRollButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isPrimary;
  final VoidCallback onTap;

  const _DetailsRollButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.25),
                      color.withValues(alpha: 0.15),
                    ],
                  )
                : null,
            color: isPrimary ? null : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: isPrimary ? 0.5 : 0.3),
              width: isPrimary ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 9,
                        color: JuiceTheme.parchmentDark.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 16, color: color.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skew button (Positive/Negative, Recent/Distant)
class _DetailsSkewButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DetailsSkewButton({
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
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9,
                      color: color.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
