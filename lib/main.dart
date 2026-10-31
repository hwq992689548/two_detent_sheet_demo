import 'package:flutter/material.dart';

import 'demo/demo_home_page.dart';

void main() {
  runApp(const TwoDetentSheetDemoApp());
}

class TwoDetentSheetDemoApp extends StatelessWidget {
  const TwoDetentSheetDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '二段式 Sheet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF0EEE8),
      ),
      home: const DemoHomePage(),
    );
  }
}
