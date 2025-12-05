import 'package:flutter/material.dart';

/// Parchment & Ink theme for Juice Roll.
/// 
/// A warm, analog aesthetic inspired by the paper pocketfold origin of the
/// Juice Oracle. Evokes aged leather journals, parchment, and ink.
class JuiceTheme {
  JuiceTheme._();

  // ═══════════════════════════════════════════════════════════════════════════
  // COLOR PALETTE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Deep brown-black, like aged leather binding
  static const Color background = Color(0xFF1C1814);
  
  /// Warm dark brown for elevated surfaces
  static const Color surface = Color(0xFF2A2420);
  
  /// Slightly lighter surface for cards
  static const Color cardSurface = Color(0xFF342E28);
  
  /// Very dark brown-black for card backgrounds in history
  static const Color inkDark = Color(0xFF241E1A);
  
  /// Aged paper cream - primary accent
  static const Color parchment = Color(0xFFD4C5A9);
  
  /// Darker parchment for subtle elements
  static const Color parchmentDark = Color(0xFFB8A98C);
  
  /// Sepia brown - for ink and text
  static const Color ink = Color(0xFF3D3029);
  
  /// Antique gold for highlights and important elements
  static const Color gold = Color(0xFFC9A962);
  
  /// Sepia brown - for secondary accents
  static const Color sepia = Color(0xFF8B7355);
  
  /// Worn leather/rust accent
  static const Color rust = Color(0xFF8B4513);
  
  /// Juice brand orange (from logo)
  static const Color juiceOrange = Color(0xFFFF6B35);
  
  /// Muted red for danger/warnings
  static const Color danger = Color(0xFFB85450);
  
  /// Muted green for success/positive
  static const Color success = Color(0xFF6B8E6B);
  
  /// Muted blue for information
  static const Color info = Color(0xFF6B7B8E);
  
  /// Muted purple for mystical elements
  static const Color mystic = Color(0xFF8B7B9E);

  // ═══════════════════════════════════════════════════════════════════════════
  // CATEGORY COLORS (for roll buttons)
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Oracle/Fate rolls - warm cream (parchment)
  static const Color categoryOracle = Color(0xFFD4C5A9);
  
  /// World-building - aged yellow/amber
  static const Color categoryWorld = Color(0xFFD4A76A);
  
  /// Character/NPC - warm tan
  static const Color categoryCharacter = Color(0xFFB8A07A);
  
  /// Combat/Challenge - rust-touched
  static const Color categoryCombat = Color(0xFFA67B5B);
  
  /// Exploration - forest brown-green
  static const Color categoryExplore = Color(0xFF7A8B6B);
  
  /// Utility - muted gray-brown
  static const Color categoryUtility = Color(0xFF8B8078);

  // ═══════════════════════════════════════════════════════════════════════════
  // SEMANTIC COLORS (for roll type indicators)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Map<String, Color> rollTypeColors = {
    'fateCheck': mystic,
    'nextScene': info,
    'randomEvent': gold,
    'discoverMeaning': juiceOrange,
    'npcAction': categoryCharacter,
    'payThePrice': danger,
    'quest': rust,
    'interrupt': juiceOrange,
    'weather': info,
    'encounter': categoryExplore,
    'settlement': categoryWorld,
    'treasure': gold,
    'challenge': categoryCombat,
    'details': parchmentDark,
    'immersion': juiceOrange,
    'location': rust,
    'dialog': categoryCharacter,
    'dungeon': Color(0xFF6B6860),
    'wilderness': categoryExplore,
    'monster': danger,
    'abstractIcons': success,
    'standard': parchment,
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // TYPOGRAPHY
  // ═══════════════════════════════════════════════════════════════════════════

  /// Serif font for headers (evokes books and manuscripts)
  static const String fontFamilySerif = 'Georgia';
  
  /// Sans-serif font for body text (clean readability)
  static const String fontFamilySans = 'Roboto';
  
  /// Monospace font for dice values and code
  static const String fontFamilyMono = 'RobotoMono';

  static TextTheme get textTheme => TextTheme(
    // Display styles - large headers
    displayLarge: TextStyle(
      fontFamily: fontFamilySerif,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: parchment,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontFamily: fontFamilySerif,
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: parchment,
    ),
    displaySmall: TextStyle(
      fontFamily: fontFamilySerif,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: parchment,
    ),
    
    // Headline styles - section headers
    headlineLarge: TextStyle(
      fontFamily: fontFamilySerif,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: parchment,
    ),
    headlineMedium: TextStyle(
      fontFamily: fontFamilySerif,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: parchment,
    ),
    headlineSmall: TextStyle(
      fontFamily: fontFamilySerif,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: parchment,
    ),
    
    // Title styles - card titles, dialog titles
    titleLarge: TextStyle(
      fontFamily: fontFamilySerif,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: parchment,
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamilySans,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: parchment,
    ),
    titleSmall: TextStyle(
      fontFamily: fontFamilySans,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: parchment,
    ),
    
    // Body styles - main content
    bodyLarge: TextStyle(
      fontFamily: fontFamilySans,
      fontSize: 15,
      fontWeight: FontWeight.normal,
      color: parchment.withOpacity(0.95),
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamilySans,
      fontSize: 13,
      fontWeight: FontWeight.normal,
      color: parchment.withOpacity(0.9),
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamilySans,
      fontSize: 11,
      fontWeight: FontWeight.normal,
      color: parchment.withOpacity(0.7),
    ),
    
    // Label styles - buttons, chips
    labelLarge: TextStyle(
      fontFamily: fontFamilySans,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: parchment,
      letterSpacing: 0.5,
    ),
    labelMedium: TextStyle(
      fontFamily: fontFamilySans,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: parchment,
    ),
    labelSmall: TextStyle(
      fontFamily: fontFamilySans,
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: parchment.withOpacity(0.8),
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // COMPONENT STYLES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Embossed/debossed paper effect for buttons
  static BoxDecoration get buttonDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: gold.withOpacity(0.3), width: 1),
    boxShadow: [
      // Outer shadow (depth)
      BoxShadow(
        color: Colors.black.withOpacity(0.4),
        offset: const Offset(2, 2),
        blurRadius: 4,
      ),
      // Inner highlight (emboss effect)
      BoxShadow(
        color: parchment.withOpacity(0.05),
        offset: const Offset(-1, -1),
        blurRadius: 2,
      ),
    ],
  );

  /// Pressed button state
  static BoxDecoration get buttonPressedDecoration => BoxDecoration(
    color: surface.withRed(surface.red - 10),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: gold.withOpacity(0.5), width: 1),
    boxShadow: [
      // Inset shadow (pressed effect)
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        offset: const Offset(1, 1),
        blurRadius: 2,
        spreadRadius: -1,
      ),
    ],
  );

  /// Card decoration (parchment-like)
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardSurface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: parchmentDark.withOpacity(0.15), width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        offset: const Offset(0, 2),
        blurRadius: 6,
      ),
    ],
  );

  /// Info box decoration (muted background)
  static BoxDecoration infoBoxDecoration(Color accentColor) => BoxDecoration(
    color: accentColor.withOpacity(0.08),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: accentColor.withOpacity(0.2), width: 1),
  );

  /// Dialog option decoration
  static BoxDecoration dialogOptionDecoration(Color accentColor) => BoxDecoration(
    color: accentColor.withOpacity(0.08),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: accentColor.withOpacity(0.25), width: 1),
  );

  /// Chip/tag decoration
  static BoxDecoration chipDecoration(Color color) => BoxDecoration(
    color: color.withOpacity(0.15),
    borderRadius: BorderRadius.circular(6),
    border: Border.all(color: color.withOpacity(0.4), width: 1),
  );

  /// Dice roll display box
  static BoxDecoration get diceBoxDecoration => BoxDecoration(
    color: ink.withOpacity(0.3),
    borderRadius: BorderRadius.circular(6),
    border: Border.all(color: parchmentDark.withOpacity(0.2), width: 1),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // THEME DATA
  // ═══════════════════════════════════════════════════════════════════════════

  static ThemeData get themeData => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Color scheme
    colorScheme: ColorScheme.dark(
      primary: gold,
      secondary: juiceOrange,
      tertiary: parchment,
      surface: surface,
      error: danger,
      onPrimary: background,
      onSecondary: background,
      onSurface: parchment,
      onError: parchment,
    ),
    
    // Scaffold
    scaffoldBackgroundColor: background,
    
    // App bar
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: parchment,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: fontFamilySerif,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: parchment,
      ),
      iconTheme: IconThemeData(color: gold),
    ),
    
    // Cards
    cardTheme: CardThemeData(
      color: cardSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: parchmentDark.withOpacity(0.15), width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
    ),
    
    // Dialogs
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: gold.withOpacity(0.2), width: 1),
      ),
      titleTextStyle: TextStyle(
        fontFamily: fontFamilySerif,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: parchment,
      ),
    ),
    
    // Elevated buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: surface,
        foregroundColor: gold,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: gold.withOpacity(0.4), width: 1),
        ),
        textStyle: TextStyle(
          fontFamily: fontFamilySans,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Text buttons
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: parchmentDark,
        textStyle: TextStyle(
          fontFamily: fontFamilySans,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    // Chips
    chipTheme: ChipThemeData(
      backgroundColor: surface,
      labelStyle: TextStyle(
        fontFamily: fontFamilySans,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: parchment,
      ),
      side: BorderSide(color: parchmentDark.withOpacity(0.3), width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    ),
    
    // Dividers
    dividerTheme: DividerThemeData(
      color: parchmentDark.withOpacity(0.2),
      thickness: 1,
      space: 16,
    ),
    
    // Icons
    iconTheme: IconThemeData(
      color: parchment,
      size: 24,
    ),
    
    // Input decoration (text fields)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ink.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: parchmentDark.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: parchmentDark.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: gold.withOpacity(0.5)),
      ),
      labelStyle: TextStyle(color: parchmentDark),
      hintStyle: TextStyle(color: parchmentDark.withOpacity(0.5)),
    ),
    
    // Checkbox
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return gold;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(background),
      side: BorderSide(color: parchmentDark.withOpacity(0.5), width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    
    // Radio
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return gold;
        }
        return parchmentDark.withOpacity(0.5);
      }),
    ),
    
    // Slider
    sliderTheme: SliderThemeData(
      activeTrackColor: gold,
      inactiveTrackColor: parchmentDark.withOpacity(0.3),
      thumbColor: gold,
      overlayColor: gold.withOpacity(0.2),
    ),
    
    // Progress indicator
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: gold,
      circularTrackColor: parchmentDark.withOpacity(0.2),
    ),
    
    // Bottom sheet
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    
    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: cardSurface,
      contentTextStyle: TextStyle(
        fontFamily: fontFamilySans,
        color: parchment,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
    
    // List tile
    listTileTheme: ListTileThemeData(
      textColor: parchment,
      iconColor: parchmentDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    
    // Text theme
    textTheme: textTheme,
    
    // Segmented button
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return gold.withOpacity(0.2);
          }
          return Colors.transparent;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return gold;
          }
          return parchmentDark;
        }),
        side: WidgetStateProperty.all(
          BorderSide(color: parchmentDark.withOpacity(0.3)),
        ),
      ),
    ),
    
    // Dropdown
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: TextStyle(
        fontFamily: fontFamilySans,
        color: parchment,
      ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(surface),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// EXTENSION HELPERS
// ═══════════════════════════════════════════════════════════════════════════

extension JuiceColors on BuildContext {
  /// Quick access to Juice theme colors
  JuiceThemeColors get juiceColors => JuiceThemeColors();
}

class JuiceThemeColors {
  Color get background => JuiceTheme.background;
  Color get surface => JuiceTheme.surface;
  Color get cardSurface => JuiceTheme.cardSurface;
  Color get parchment => JuiceTheme.parchment;
  Color get parchmentDark => JuiceTheme.parchmentDark;
  Color get ink => JuiceTheme.ink;
  Color get gold => JuiceTheme.gold;
  Color get rust => JuiceTheme.rust;
  Color get juiceOrange => JuiceTheme.juiceOrange;
  Color get danger => JuiceTheme.danger;
  Color get success => JuiceTheme.success;
  Color get info => JuiceTheme.info;
  Color get mystic => JuiceTheme.mystic;
  
  // Categories
  Color get categoryOracle => JuiceTheme.categoryOracle;
  Color get categoryWorld => JuiceTheme.categoryWorld;
  Color get categoryCharacter => JuiceTheme.categoryCharacter;
  Color get categoryCombat => JuiceTheme.categoryCombat;
  Color get categoryExplore => JuiceTheme.categoryExplore;
  Color get categoryUtility => JuiceTheme.categoryUtility;
}
