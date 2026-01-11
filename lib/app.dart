import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

class CodexApp extends StatelessWidget {
  const CodexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Codex',
      debugShowCheckedModeBanner: false,

      // Brand colors - we'll make these theme-driven in M8
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C3FDB), // Deep purple
          brightness: Brightness.light,
        ),
        fontFamily: 'sans-serif',
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C3FDB),
          brightness: Brightness.dark,
          surface: const Color(0xFF0A0A0F), // Near black
        ),
        fontFamily: 'sans-serif',
      ),

      themeMode: ThemeMode.dark, // Default to dark theme

      home: const HomeScreen(),
    );
  }
}
