import 'package:flutter/material.dart';
import '../theme/juice_theme.dart';

/// A scrollable content wrapper with scroll indicators for dialogs.
/// Shows up/down arrows when content can be scrolled.
class ScrollableDialogContent extends StatefulWidget {
  final Widget? child;
  final List<Widget>? children;

  const ScrollableDialogContent({
    super.key,
    this.child,
    this.children,
  }) : assert(child != null || children != null, 'Either child or children must be provided');

  @override
  State<ScrollableDialogContent> createState() => _ScrollableDialogContentState();
}

class _ScrollableDialogContentState extends State<ScrollableDialogContent> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollUp = false;
  bool _canScrollDown = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollIndicators);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollIndicators());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollIndicators);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollIndicators() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    setState(() {
      _canScrollUp = position.pixels > 0;
      _canScrollDown = position.pixels < position.maxScrollExtent - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scroll up indicator
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: _canScrollUp ? 16 : 0,
          child: _canScrollUp
              ? Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        JuiceTheme.surface,
                        JuiceTheme.surface.withValues(alpha: 0),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      size: 14,
                      color: JuiceTheme.parchmentDark.withValues(alpha: 0.6),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        // Main scrollable content
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: widget.child ?? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.children!,
            ),
          ),
        ),
        // Scroll down indicator
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: _canScrollDown ? 16 : 0,
          child: _canScrollDown
              ? Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        JuiceTheme.surface,
                        JuiceTheme.surface.withValues(alpha: 0),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 14,
                      color: JuiceTheme.parchmentDark.withValues(alpha: 0.6),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// Helper widget for section headers with icons.
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;

  const SectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? JuiceTheme.gold;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: c),
          const SizedBox(width: 6),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: c)),
        ],
      ),
    );
  }
}

/// A dialog option button.
class DialogOption extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? color;

  const DialogOption({
    super.key,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? JuiceTheme.gold;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: c.withValues(alpha: 0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: c.withValues(alpha: 0.08),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: c,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: JuiceTheme.parchmentDark,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: c.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A helper widget for displaying detail rows.
class DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const DetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

/// Compact dialog option for side-by-side layouts (e.g., advantage/disadvantage).
class CompactDialogOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const CompactDialogOption({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(
                color: iconColor.withValues(alpha: 0.4),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: iconColor.withValues(alpha: 0.08),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: iconColor),
                const SizedBox(width: 4),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: iconColor,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 9,
                          color: iconColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
