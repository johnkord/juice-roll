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

class _RollButtonState extends State<RollButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Create a muted, parchment-influenced version of the color
    final buttonColor = _blendWithParchment(widget.color);
    // More visible border - blend category color with gold for embossed effect
    final borderColor = Color.lerp(widget.color, JuiceTheme.gold, 0.3)!;
    // Brighter icon color for better visibility
    final brightIconColor = Color.lerp(JuiceTheme.parchment, Colors.white, 0.15)!;
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          // Base color with subtle gradient for paper texture effect
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isPressed 
                ? [
                    buttonColor.withOpacity(0.45),
                    buttonColor.withOpacity(0.35),
                  ]
                : [
                    buttonColor.withOpacity(0.25),
                    buttonColor.withOpacity(0.15),
                  ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isPressed ? JuiceTheme.gold.withOpacity(0.9) : borderColor.withOpacity(0.7),
            width: _isPressed ? 2.0 : 1.8,
          ),
          boxShadow: _isPressed
              ? [
                  // Inset shadow effect when pressed
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(1, 1),
                    blurRadius: 3,
                  ),
                ]
              : [
                  // Outer shadow for depth
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    offset: const Offset(2, 3),
                    blurRadius: 4,
                  ),
                  // Subtle inner highlight for embossed effect
                  BoxShadow(
                    color: JuiceTheme.parchment.withOpacity(0.03),
                    offset: const Offset(-1, -1),
                    blurRadius: 1,
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with subtle glow - brighter for visibility
            Icon(
              widget.icon,
              size: 24,
              color: brightIconColor,
              shadows: [
                Shadow(
                  color: widget.color.withOpacity(0.5),
                  blurRadius: 10,
                ),
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 2,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Label with serif font for parchment feel
            Text(
              widget.label,
              style: TextStyle(
                fontFamily: JuiceTheme.fontFamilySans,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: brightIconColor,
                letterSpacing: 0.3,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 2,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Blends the given color with parchment tones for a more cohesive look
  Color _blendWithParchment(Color color) {
    return Color.lerp(color, JuiceTheme.parchmentDark, 0.3)!;
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
