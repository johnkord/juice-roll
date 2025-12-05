import 'package:flutter/material.dart';
import 'ui/home_screen.dart';
import 'ui/theme/juice_theme.dart';

void main() {
  runApp(const JuiceRollApp());
}

/// JuiceRoll - A Juice Oracle dice rolling app.
/// 
/// A digital companion for the Juice Oracle, a solo RPG tool inspired by
/// Mythic GME, Ironsworn, and classic tabletop systems.
class JuiceRollApp extends StatelessWidget {
  const JuiceRollApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juice Roll',
      theme: JuiceTheme.themeData,
      home: const PhoneFrame(child: HomeScreen()),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Wraps the app in a phone-sized frame for web/desktop.
class PhoneFrame extends StatelessWidget {
  final Widget child;
  
  const PhoneFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: JuiceTheme.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 430, // iPhone 14 Pro Max width
            maxHeight: 932, // iPhone 14 Pro Max height
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: JuiceTheme.parchmentDark.withOpacity(0.3), width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Navigator(
                onGenerateRoute: (settings) => MaterialPageRoute(
                  builder: (context) => child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
