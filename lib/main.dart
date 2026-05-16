import 'package:flutter/material.dart';

void main() {
  runApp(const HibikiApp());
}

/// Minimal Flutter shell — feature branches add the Sanctuary app on top.
class HibikiApp extends StatelessWidget {
  const HibikiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hibiki',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4B6332)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'Hibiki',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
