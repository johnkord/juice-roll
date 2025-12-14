import 'package:flutter/material.dart';
import '../theme/juice_theme.dart';

/// A styled roll button with Parchment & Ink aesthetic.
/// 
/// Features an embossed paper-like appearance with subtle depth effects.
class RollButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final String? category;

  const RollButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.color,
    this.category,
  });

  @override
  State<RollButton> createState() => _RollButtonState();
}

class _RollButtonState extends State<RollButton> {
  bool _isPressed = false;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // CACHED DECORATION VALUES
  // Pre-computed to avoid creating new objects on every build/animation frame.
  // These are rebuilt only when the widget's color changes.
  // ═══════════════════════════════════════════════════════════════════════════
  
  late BoxDecoration _normalDecoration;
  late BoxDecoration _pressedDecoration;
  late Color _brightIconColor;
  late List<Shadow> _iconShadows;
  late TextStyle _labelStyle;
  
  /// Cached static values shared across all instances
  static const _borderRadius = BorderRadius.all(Radius.circular(12));
  static const _pressedShadows = [
    BoxShadow(
      color: Color(0x80000000), // Colors.black.withOpacity(0.5)
      offset: Offset(1, 1),
      blurRadius: 3,
    ),
  ];
  static const _normalShadows = [
    BoxShadow(
      color: Color(0x66000000), // Colors.black.withOpacity(0.4)
      offset: Offset(2, 3),
      blurRadius: 4,
    ),
    BoxShadow(
      color: Color(0x08D4C5A9), // JuiceTheme.parchment03
      offset: Offset(-1, -1),
      blurRadius: 1,
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    _buildCachedValues();
  }
  
  @override
  void didUpdateWidget(RollButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only rebuild cached values if the color changed
    if (oldWidget.color != widget.color) {
      _buildCachedValues();
    }
  }
  
  /// Pre-compute all color-dependent decorations and styles.
  void _buildCachedValues() {
    final buttonColor = Color.lerp(widget.color, JuiceTheme.parchmentDark, 0.3)!;
    final borderColor = Color.lerp(widget.color, JuiceTheme.gold, 0.3)!;
    _brightIconColor = Color.lerp(JuiceTheme.parchment, Colors.white, 0.15)!;
    
    // Pre-compute gradient colors
    final normalGradientColors = [
      buttonColor.withOpacity(0.25),
      buttonColor.withOpacity(0.15),
    ];
    final pressedGradientColors = [
      buttonColor.withOpacity(0.45),
      buttonColor.withOpacity(0.35),
    ];
    
    _normalDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: normalGradientColors,
      ),
      borderRadius: _borderRadius,
      border: Border.all(
        color: borderColor.withOpacity(0.7),
        width: 1.8,
      ),
      boxShadow: _normalShadows,
    );
    
    _pressedDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: pressedGradientColors,
      ),
      borderRadius: _borderRadius,
      border: Border.all(
        color: JuiceTheme.gold90,
        width: 2.0,
      ),
      boxShadow: _pressedShadows,
    );
    
    _iconShadows = [
      Shadow(
        color: widget.color.withOpacity(0.5),
        blurRadius: 10,
      ),
      const Shadow(
        color: Color(0x4D000000), // Colors.black.withOpacity(0.3)
        blurRadius: 2,
        offset: Offset(1, 1),
      ),
    ];
    
    _labelStyle = TextStyle(
      fontFamily: JuiceTheme.fontFamilySans,
      fontSize: 14,
      fontWeight: FontWeight.w900,
      color: _brightIconColor,
      letterSpacing: 0.3,
      shadows: const [
        Shadow(
          color: Color(0x80000000), // Colors.black.withOpacity(0.5)
          blurRadius: 2,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: _isPressed ? _pressedDecoration : _normalDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: 24,
              color: _brightIconColor,
              shadows: _iconShadows,
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: _labelStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Button category constants for grouping
class ButtonCategory {
  static const String oracle = 'oracle';
  static const String world = 'world';
  static const String character = 'character';
  static const String combat = 'combat';
  static const String explore = 'explore';
  static const String utility = 'utility';
}
