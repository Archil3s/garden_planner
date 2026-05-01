import 'package:flutter/material.dart';

void main() {
  runApp(const DebugRevisionApp());
}

class DebugRevisionApp extends StatelessWidget {
  const DebugRevisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'debug-entry-20260425-060608',
      home: Scaffold(
        backgroundColor: const Color(0xFFFFD400),
        body: Center(
          child: Text(
            'FLUTTER DEBUG ENTRY IS RUNNING\ndebug-entry-20260425-060608',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
