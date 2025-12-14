import 'package:flutter/material.dart';
import '../theme/juice_theme.dart';

/// A consistent base dialog widget for all Oracle dialogs.
/// 
/// Provides a unified structure with:
/// - Icon + title header with optional subtitle and page label
/// - Consistent padding and constraints
/// - Scrollable content with max height
/// - Standard Cancel action button
/// 
/// Example usage:
/// ```dart
/// OracleDialog(
///   title: 'Fate Check',
///   subtitle: 'Ask the oracle',
///   icon: Icons.help_outline,
///   accentColor: JuiceTheme.mystic,
///   content: Column(...),
/// )
/// ```
class OracleDialog extends StatelessWidget {
  /// The main title text.
  final String title;
  
  /// Optional subtitle displayed below the title.
  final String? subtitle;
  
  /// The icon displayed in the header.
  final IconData icon;
  
  /// The accent color for the icon container and gradient.
  final Color accentColor;
  
  /// Optional secondary color for gradient (defaults to accentColor with lower alpha).
  final Color? secondaryColor;
  
  /// The main content of the dialog.
  final Widget content;
  
  /// Additional action buttons (Cancel is always included).
  final List<Widget>? extraActions;
  
  /// Whether to show the icon in a decorated container.
  /// If false, shows just the icon without container.
  final bool showIconContainer;
  
  /// Maximum height fraction of screen (0.0 to 1.0).
  final double maxHeightFraction;
  
  /// Custom inset padding for the dialog.
  final EdgeInsetsGeometry? insetPadding;
  
  /// Custom content padding.
  final EdgeInsetsGeometry? contentPadding;
  
  /// Text for the close/cancel button.
  final String closeButtonText;
  
  /// Optional icon color override (defaults to accentColor).
  final Color? iconColor;

  const OracleDialog({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.accentColor,
    this.secondaryColor,
    required this.content,
    this.extraActions,
    this.showIconContainer = true,
    this.maxHeightFraction = 0.75,
    this.insetPadding,
    this.contentPadding,
    this.closeButtonText = 'Cancel',
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _buildTitle(),
      insetPadding: (insetPadding as EdgeInsets?) ?? 
          const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: (contentPadding as EdgeInsets?) ?? 
          const EdgeInsets.fromLTRB(12, 12, 12, 0),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * maxHeightFraction,
          maxWidth: 360,
        ),
        child: SingleChildScrollView(
          child: content,
        ),
      ),
      actions: [
        if (extraActions != null) ...extraActions!,
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(closeButtonText),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    final displayIconColor = iconColor ?? accentColor;
    
    if (!showIconContainer && subtitle == null) {
      // Simple title style (like Challenge, PayThePrice)
      return Row(
        children: [
          Icon(icon, color: displayIconColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: JuiceTheme.fontFamilySerif,
                color: JuiceTheme.parchment,
              ),
            ),
          ),
        ],
      );
    }

    // Rich title style with icon container (like Details, Immersion)
    final secondary = secondaryColor ?? accentColor.withOpacity(0.2);
    
    return Row(
      children: [
        if (showIconContainer)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withOpacity(0.3),
                  secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: displayIconColor, size: 20),
          )
        else
          Icon(icon, color: displayIconColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: JuiceTheme.fontFamilySerif,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: JuiceTheme.parchmentDark,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A simple oracle dialog for dialogs that just need a text title.
/// 
/// This is a convenience constructor for the simpler dialog style
/// used by Challenge, PayThePrice, etc.
class SimpleOracleDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? extraActions;
  final double maxHeightFraction;
  final String closeButtonText;

  const SimpleOracleDialog({
    super.key,
    required this.title,
    required this.content,
    this.extraActions,
    this.maxHeightFraction = 0.75,
    this.closeButtonText = 'Cancel',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: TextStyle(
          fontFamily: JuiceTheme.fontFamilySerif,
          color: JuiceTheme.parchment,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * maxHeightFraction,
          maxWidth: 360,
        ),
        child: SingleChildScrollView(
          child: content,
        ),
      ),
      actions: [
        if (extraActions != null) ...extraActions!,
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(closeButtonText),
        ),
      ],
    );
  }
}

/// An introduction/explanation box commonly used at the top of oracle dialogs.
class OracleDialogIntro extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;

  const OracleDialogIntro({
    super.key,
    required this.text,
    this.icon = Icons.lightbulb_outline,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? JuiceTheme.gold;
    final bgColor = backgroundColor ?? color.withOpacity(0.12);
    final border = borderColor ?? color.withOpacity(0.2);
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.withOpacity(0.7), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

/// A section card used within oracle dialogs.
/// If child is null, renders as a simple header row.
class OracleDialogSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final String? description;
  final Widget? child;
  final bool isHighlighted;

  const OracleDialogSection({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    this.description,
    this.child,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    // If no child, render as a simple header row
    if (child == null) {
      return Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: JuiceTheme.fontFamilySerif,
              color: color,
            ),
          ),
        ],
      );
    }
    
    if (isHighlighted) {
      return _buildHighlightedSection();
    }
    return _buildNormalSection();
  }

  Widget _buildNormalSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withOpacity(0.06),
        border: Border.all(
          color: color.withOpacity(0.2),
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
          if (description != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                description!,
                style: TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  color: JuiceTheme.parchmentDark80,
                ),
              ),
            ),
          if (description != null) const SizedBox(height: 8),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1.5,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.12),
            color.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with highlighted styling
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: color),
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
          Padding(
            padding: const EdgeInsets.all(10),
            child: child!,
          ),
        ],
      ),
    );
  }
}

/// A badge shown next to section titles (e.g., "ESSENTIAL", "COMPLETE").
class OracleDialogBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const OracleDialogBadge({
    super.key,
    required this.label,
    this.icon = Icons.star,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.4),
            color.withOpacity(0.25),
          ],
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// A standard roll button used in oracle dialogs.
class OracleRollButton extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final bool isPrimary;
  final VoidCallback onTap;

  const OracleRollButton({
    super.key,
    required this.label,
    this.subtitle,
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
                      color.withOpacity(0.25),
                      color.withOpacity(0.15),
                    ],
                  )
                : null,
            color: isPrimary ? null : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(isPrimary ? 0.5 : 0.3),
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
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 9,
                          color: JuiceTheme.parchmentDark70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 16, color: color.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact skew/variant button (e.g., Positive/Negative, Closer/Further).
class OracleSkewButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const OracleSkewButton({
    super.key,
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
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.35),
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
                      color: color.withOpacity(0.7),
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

/// A quoted text block for dialog examples or explanations.
class OracleDialogQuote extends StatelessWidget {
  final String text;
  final Color borderColor;

  const OracleDialogQuote({
    super.key,
    required this.text,
    this.borderColor = JuiceTheme.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: JuiceTheme.inkDark40,
        borderRadius: BorderRadius.circular(6),
        border: Border(
          left: BorderSide(
            color: borderColor,
            width: 3,
          ),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontStyle: FontStyle.italic,
          color: JuiceTheme.parchment,
        ),
      ),
    );
  }
}

/// An example section at the bottom of dialogs.
class OracleDialogExample extends StatelessWidget {
  final String text;
  final String? title;
  final IconData? icon;
  final Color? iconColor;
  // Legacy support
  final String? label;

  const OracleDialogExample({
    super.key,
    required this.text,
    this.title,
    this.icon,
    this.iconColor,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final displayLabel = title ?? label;
    final displayIcon = icon ?? Icons.format_quote;
    final displayColor = iconColor ?? JuiceTheme.parchmentDark;
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: JuiceTheme.parchmentDark08,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: JuiceTheme.parchmentDark15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (displayLabel != null)
            Row(
              children: [
                Icon(displayIcon, size: 14, color: displayColor),
                const SizedBox(width: 4),
                Text(
                  displayLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: displayColor,
                  ),
                ),
              ],
            ),
          if (displayLabel != null) const SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 9,
              fontStyle: FontStyle.italic,
              color: JuiceTheme.parchmentDark,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
