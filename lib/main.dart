import 'package:flutter/material.dart';
import 'ui/home_screen.dart';

void main() {
  runApp(const JuiceRollApp());
}

/// JuiceRoll - A Juice Oracle dice rolling app.
class JuiceRollApp extends StatelessWidget {
  const JuiceRollApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JuiceRoll',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 430, // iPhone 14 Pro Max width
          maxHeight: 932, // iPhone 14 Pro Max height
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade800, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ),
    );
  }
}
