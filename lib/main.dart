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
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
